{ config, pkgs, lib, inputs, ... }:

let
  stickerSite = inputs.stickers.packages.x86_64-linux.site;
in {
  networking.hostName = "sen";

  # Modules
  ellie.linode.enable = true;
  ellie.nginx-server.enable = true;
  ellie.fail2ban.enable = true;
  ellie.logrotate-nginx.enable = true;
  ellie.transmission.enable = true;
  ellie.health = {
    enable = true;
    ntfyTopicFile = "/etc/secrets/ntfy_topic";
    ntfyTokenFile = "/etc/secrets/ntfy_token";
    loginNotify.ignoredCIDRs = [ "e@202.83.104.81/32" ];
    healthEndpoint = "health.monoid.al";
    deadManSwitch = {
      enable = true;
      peerName = "bow";
      peerUrl = "https://health.home.monoid.al";
    };
  };
  ellie.dns = {
    enable = true;
    trustedCIDRs = [
      "192.168.1.0/24" # LAN (no-op on sen, kept for consistency)
      "202.83.104.81/32" # home WAN
      "172.104.175.207/32" # sen public (loopback to self)
    ];
    peerHost = "bow.home.monoid.al";
    peerIP = "202.83.104.81";
    localHosts = [
      "192.168.1.148 ultimate-guitar.com"
      "192.168.1.148 www.ultimate-guitar.com"
      "192.168.1.148 tabs.ultimate-guitar.com"
      "192.168.1.148 static.ultimate-guitar.com"
    ];
    webUIVHost = "pihole.monoid.al";
    webUIPublic = true;
    webUIBasicAuthFile = "/etc/nginx/auth/transmission.monoid.al";
    dotVHostName = "sen.monoid.al";
    dnsListenAddresses = [ "127.0.0.1" "172.104.175.207" ];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3604511d-9883-4045-9f7e-bb49ed1be42c";
    fsType = "ext4";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/8af325d4-31b1-4274-a57c-72d708589360"; }
    { device = "/swapfile"; }
  ];

  # Networking
  networking.usePredictableInterfaceNames = false;
  networking.firewall.enable = true;

  time.timeZone = "Asia/Singapore";

  boot.kernel.sysctl = {
    "net.core.rmem_max" = 4194304;
    "net.core.wmem_max" = 1048576;
  };

  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "65536";
  }];

  services.journald.extraConfig = ''
    SystemMaxUse=512M
  '';

  # Redirect ug.monoid.al → ug.home.monoid.al (the actual ug-proxy
  # public vhost, which lives on bow and is gated by basic auth).
  # Lets users / bookmarks use the shorter monoid.al name without
  # having to expose ug-proxy on sen itself.
  services.nginx.virtualHosts."ug.monoid.al" = {
    forceSSL = true;
    useACMEHost = "monoid.al";
    globalRedirect = "ug.home.monoid.al";
  };

  # Public sticker pack registry — no auth required.
  services.nginx.virtualHosts."monoid.al" = {
    forceSSL = true;
    useACMEHost = "monoid.al";
    locations."/stickers/" = {
      alias = "${stickerSite}/";
      extraConfig = ''
        index index.html;
        autoindex off;
      '';
    };
    # Redirect bare /stickers to /stickers/
    locations."= /stickers" = {
      return = "301 /stickers/";
    };
  };

  # Notify via ntfy every 10 minutes with sticker site access log
  systemd.services.sticker-access-notify = {
    description = "Notify sticker site accesses via ntfy";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      StateDirectory = "sticker-notify";
      ExecStart = pkgs.writeScript "sticker-access-notify" ''
        #!${pkgs.python3}/bin/python3
        """Parse nginx access log for /stickers/ hits, geo-lookup IPs, send ntfy."""
        import collections, json, os, re, subprocess, sys, urllib.request

        STATE_FILE = "/var/lib/sticker-notify/last-pos"
        LOG = "/var/log/nginx/access.log"
        TOPIC_FILE = "/etc/secrets/ntfy_topic"
        TOKEN_FILE = "/etc/secrets/ntfy_token"

        # nginx combined log format regex
        # 1.2.3.4 - - [14/May/2026:10:00:00 +0800] "GET /path HTTP/2.0" 200 1234 "ref" "ua"
        LOG_RE = re.compile(
            r'^(\S+)\s+'           # IP
            r'\S+\s+\S+\s+'        # ident, user
            r'\[[^]]+\]\s+'        # [date]
            r'"(\S+)\s+(\S+)\s+'   # "METHOD URL
        )

        if not os.path.isfile(LOG):
            sys.exit(0)

        # Read position state
        last_pos = 0
        if os.path.isfile(STATE_FILE):
            try:
                last_pos = int(open(STATE_FILE).read().strip())
            except (ValueError, OSError):
                last_pos = 0

        current_size = os.path.getsize(LOG)

        # Handle log rotation
        if current_size < last_pos:
            last_pos = 0

        # Read new bytes
        with open(LOG, "rb") as f:
            f.seek(last_pos)
            new_data = f.read()

        # Save position (do this early so we don't re-process on failure)
        with open(STATE_FILE, "w") as f:
            f.write(str(current_size))

        if not new_data:
            sys.exit(0)

        # Parse lines, extract sticker hits
        hits = []  # list of (ip, url)
        for line in new_data.decode("utf-8", errors="replace").splitlines():
            m = LOG_RE.match(line)
            if not m:
                continue
            ip, method, url = m.group(1), m.group(2), m.group(3)
            if url.startswith("/stickers/"):
                hits.append((ip, url))

        if not hits:
            sys.exit(0)

        # Aggregate: count per (ip, url)
        counter = collections.Counter(hits)

        # Group by IP
        by_ip = collections.defaultdict(list)
        for (ip, url), count in counter.items():
            by_ip[ip].append((count, url))

        # Geo-lookup unique IPs via ip-api.com batch endpoint
        unique_ips = list(by_ip.keys())
        geo = {}
        try:
            batch = [{"query": ip, "fields": "query,countryCode"} for ip in unique_ips[:100]]
            req = urllib.request.Request(
                "http://ip-api.com/batch",
                data=json.dumps(batch).encode(),
                headers={"Content-Type": "application/json"},
            )
            with urllib.request.urlopen(req, timeout=10) as resp:
                for r in json.loads(resp.read()):
                    geo[r.get("query", "")] = r.get("countryCode", "??")
        except Exception:
            pass

        # Build report, condensing lines that share count + directory + extension
        # e.g. "2  /stickers/stellarcats/2/18.png" x6 => "2 /stickers/stellarcats/2/{18,05,...}.png"
        def format_hits(ip_hits):
            result = []
            # Group by count
            by_count = collections.defaultdict(list)
            for count, url in ip_hits:
                by_count[count].append(url)
            for count in sorted(by_count, reverse=True):
                urls = by_count[count]
                # Try to group urls that share (directory, extension)
                groupable = {}   # (dir, ext) -> [basename_without_ext]
                ungroupable = []
                for url in urls:
                    if "/" in url and "." in url.rsplit("/", 1)[-1]:
                        dir_part = url.rsplit("/", 1)[0]
                        filename = url.rsplit("/", 1)[1]
                        stem, ext = filename.rsplit(".", 1)
                        groupable.setdefault((dir_part, ext), []).append(stem)
                    else:
                        ungroupable.append(url)
                for (dir_part, ext), stems in sorted(groupable.items()):
                    if len(stems) == 1:
                        result.append(f"  {count:3d}  {dir_part}/{stems[0]}.{ext}")
                    else:
                        joined = ",".join(stems)
                        result.append(f"  {count:3d}  {dir_part}/{{{joined}}}.{ext}")
                for url in ungroupable:
                    result.append(f"  {count:3d}  {url}")
            return result

        lines = []
        for ip, ip_hits in sorted(by_ip.items(), key=lambda x: -sum(c for c, _ in x[1])):
            cc = geo.get(ip, "??")
            total = sum(c for c, _ in ip_hits)
            lines.append(f"{ip} ({cc}) - {total} hits")
            lines.extend(format_hits(ip_hits))
        report = "\n".join(lines)

        # Send via ntfy
        try:
            topic = open(TOPIC_FILE).read().strip()
            token = open(TOKEN_FILE).read().strip()
        except OSError as e:
            print(f"Cannot read secrets: {e}", file=sys.stderr)
            sys.exit(1)

        req = urllib.request.Request(
            f"https://ntfy.sh/{topic}",
            data=report.encode(),
            headers={
                "Authorization": f"Bearer {token}",
                "Title": "[sen] Sticker site visitors",
                "Tags": "eyes",
            },
        )
        urllib.request.urlopen(req, timeout=10)
      '';
    };
  };

  systemd.timers.sticker-access-notify = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/10";
      Persistent = true;
    };
  };

  programs.mosh.enable = true;

  services.openssh = {
    enable = true;
    # Non-default port to drop ~99% of scanner noise. Make sure to
    # update ~/.ssh/config and any deploy/CI tooling.
    ports = [ 50539 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      # MaxAuthTries=2 gives a one-typo grace per connection without
      # letting a scanner burn 6 password attempts per TCP connection.
      # Combined with PasswordAuthentication=false above, this only
      # affects key-auth: ssh will try identities in order and
      # disconnect after 2 wrong keys. If ssh-agent has many identities
      # loaded, set IdentitiesOnly=yes in ~/.ssh/config for sen.
      MaxAuthTries = 2;
      LoginGraceTime = "30s";
    };
  };

  # Users
  ellie.users.enable = true;
  users.users.e.extraGroups = lib.mkAfter [ "transmission" ];

  # Nix
  nix.settings.auto-optimise-store = true;
  nix.optimise = {
    automatic = true;
    dates = [ "daily" ];
  };
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 3d";
  };
  nix.extraOptions = ''
    min-free = ${toString (512 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';
  nix.settings.trusted-public-keys = [
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw="
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  system.stateVersion = "20.09";
}

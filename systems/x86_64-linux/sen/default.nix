{ config, pkgs, lib, inputs, ... }:

let
  stickerSite = inputs.stickers.packages.x86_64-linux.site;

  # Shared script: parse an nginx access log for unique visitor IPs,
  # geo-lookup their country, and send a one-liner-per-IP report via ntfy.
  # Usage: access-notify <log> <state-dir> <title> <tag> <label>
  accessNotify = pkgs.writeScript "access-notify" ''
    #!${pkgs.python3}/bin/python3
    import json, os, re, sys, urllib.request

    LOG, STATE_DIR, TITLE, TAG, LABEL = sys.argv[1:6]
    STATE_FILE = os.path.join(STATE_DIR, "last-pos")
    TOPIC_FILE = "/etc/secrets/ntfy_topic"
    TOKEN_FILE = "/etc/secrets/ntfy_token"
    IGNORED_IPS = {"202.83.104.81"}
    LOG_RE = re.compile(r'^(\S+)\s+')

    if not os.path.isfile(LOG):
        sys.exit(0)

    last_pos = 0
    if os.path.isfile(STATE_FILE):
        try:
            last_pos = int(open(STATE_FILE).read().strip())
        except (ValueError, OSError):
            last_pos = 0

    current_size = os.path.getsize(LOG)
    if current_size < last_pos:
        last_pos = 0

    with open(LOG, "rb") as f:
        f.seek(last_pos)
        new_data = f.read()

    with open(STATE_FILE, "w") as f:
        f.write(str(current_size))

    if not new_data:
        sys.exit(0)

    ips = set()
    for line in new_data.decode("utf-8", errors="replace").splitlines():
        m = LOG_RE.match(line)
        if m and m.group(1) not in IGNORED_IPS:
            ips.add(m.group(1))

    if not ips:
        sys.exit(0)

    geo = {}
    try:
        batch = [{"query": ip, "fields": "query,countryCode"} for ip in list(ips)[:100]]
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

    lines = [f"{ip} from {geo.get(ip, '??')} accessed {LABEL}" for ip in sorted(ips)]
    report = "\n".join(lines)

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
            "Title": TITLE,
            "Tags": TAG,
        },
    )
    urllib.request.urlopen(req, timeout=10)
  '';

  mkAccessNotifyService = { name, log, title, tag, label }: {
    "${name}-access-notify" = {
      description = "Notify ${name} site accesses via ntfy";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "${name}-notify";
        ExecStart = ''${accessNotify} ${log} /var/lib/${name}-notify "${title}" ${tag} ${label}'';
      };
    };
  };

  mkAccessNotifyTimer = { name }: {
    "${name}-access-notify" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:0/10";
        Persistent = true;
      };
    };
  };

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

  services.wordle = {
    enable = true;
    hostName = "wordle.monoid.al";
    useACMEHost = "monoid.al";
  };

  # Separate access log for wordle so the notify script can find its requests
  # (the default combined log doesn't include the vhost name).
  services.nginx.virtualHosts."wordle.monoid.al".extraConfig = ''
    access_log /var/log/nginx/wordle-access.log;
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
        access_log /var/log/nginx/sticker-access.log;
        index index.html;
        autoindex off;
      '';
    };
    # Redirect bare /stickers to /stickers/
    locations."= /stickers" = {
      return = "301 /stickers/";
    };
  };

  systemd.services = mkAccessNotifyService {
    name = "sticker";
    log = "/var/log/nginx/sticker-access.log";
    title = "[sen] Sticker site visitors";
    tag = "eyes";
    label = "monoid.al/stickers";
  } // mkAccessNotifyService {
    name = "wordle";
    log = "/var/log/nginx/wordle-access.log";
    title = "[sen] Wordle visitors";
    tag = "game_die";
    label = "wordle.monoid.al";
  };

  systemd.timers = mkAccessNotifyTimer { name = "sticker"; }
    // mkAccessNotifyTimer { name = "wordle"; };

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
  ellie.low-disk-space.enable = true;
  nix.settings.trusted-public-keys = [
    "orion:s0C06f1M46DCpHUUP2r8iIrhfytkCbXWltMeMMa4jbw="
    "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    "light-hope:xkiDuhgkaC8uE9r3/Rr1R1QFozkqxP///eb+cdMFByA="
  ];

  system.stateVersion = "20.09";
}

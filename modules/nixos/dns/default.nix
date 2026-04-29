{ lib, pkgs, config, ... }@inputs:

with lib;
let
  cfg = config.ellie.dns;

  yamlFormat = pkgs.formats.yaml { };

  # Settings shared by both stubby instances.
  stubbyCommon = {
    resolution_type = "GETDNS_RESOLUTION_STUB";
    dns_transport_list = [ "GETDNS_TRANSPORT_TLS" ];
    tls_authentication = "GETDNS_AUTHENTICATION_REQUIRED";
    tls_query_padding_blocksize = 128;
    edns_client_subnet_private = 1;
    idle_timeout = 10000;
  };

  # stubby-upstream: pi-hole's upstream DoT resolver (forwards to Cloudflare).
  upstreamYaml = yamlFormat.generate "stubby-upstream.yml" (stubbyCommon // {
    appdata_dir = "/var/cache/stubby-upstream";
    round_robin_upstreams = 1;
    listen_addresses = [ "127.0.0.1@5353" ];
    upstream_recursive_servers = [
      { address_data = "1.1.1.1"; tls_auth_name = "cloudflare-dns.com"; }
      { address_data = "1.0.0.1"; tls_auth_name = "cloudflare-dns.com"; }
    ];
  });

  # stubby-peer: forwards to peer host's DoT endpoint, used as resolv.conf
  # secondary so local programs get encrypted failover.
  hasPeer = cfg.peerHost != null && cfg.peerIP != null;
  peerYaml = yamlFormat.generate "stubby-peer.yml" (stubbyCommon // {
    appdata_dir = "/var/cache/stubby-peer";
    listen_addresses = [ "127.0.0.2@53" ];
    upstream_recursive_servers = [
      {
        address_data = cfg.peerIP;
        tls_auth_name = cfg.peerHost;
        tls_port = 853;
      }
    ];
  });

in {
  options.ellie.dns = {
    enable = mkEnableOption "DNS / pi-hole resolver with encrypted upstream and peer failover";

    trustedCIDRs = mkOption {
      type = types.listOf types.str;
      description = ''
        Source CIDRs allowed to reach this host's port 53 and 853, and
        the optional pi-hole web UI.
      '';
    };

    peerHost = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        TLS-validated hostname of the peer DNS server. Used by stubby-peer
        to forward encrypted DNS over port 853 (e.g. "sen.monoid.al" or
        "thanos.home.monoid.al"). Hostname must match a SAN on the peer's
        ACME cert.
      '';
    };

    peerIP = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "IP address of peerHost (used for stubby's address pinning).";
    };

    localHosts = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Static A records to publish via dnsmasq. Each entry is an
        `<ip> <name>` string (e.g. "192.168.1.148 thanos").
      '';
    };

    localTLD = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Optional pseudo-TLD (e.g. "thanos") that dnsmasq treats as
        local-only via `local=/<tld>/`.
      '';
    };

    webUIVHost = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If set, an nginx vhost is created for the pi-hole web UI,
        restricted to trustedCIDRs + 127.0.0.1.
      '';
    };

    webUIPublic = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If true, the web UI is served over HTTPS using the ACME cert
        and protected by basic auth from webUIBasicAuthFile. If false,
        the vhost is plain HTTP (suitable for LAN-only pseudo-TLDs).
      '';
    };

    webUIBasicAuthFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        Path to an htpasswd-format file used for nginx basic auth on
        the web UI vhost. Only used when webUIPublic = true. If null,
        defaults to /etc/nginx/auth/<webUIVHost>.
      '';
    };

    dotVHostName = mkOption {
      type = types.str;
      description = ''
        Hostname this server presents on port 853 for DoT. Must be a SAN
        on the wildcard cert (e.g. "thanos.home.monoid.al" or
        "sen.monoid.al"). Used in stream block labels and for operator
        clarity; the actual TLS cert comes from acmeCertName.
      '';
    };

    dnsListenAddresses = mkOption {
      type = types.listOf types.str;
      description = ''
        IPs that pi-hole/dnsmasq should bind for DNS service. Required
        to avoid grabbing 127.0.0.2:53 (which conflicts with the
        stubby-peer listener). Typical:
          [ "127.0.0.1" "<this host's LAN/public IP>" ].
      '';
    };

    acmeCertName = mkOption {
      type = types.str;
      default = "monoid.al";
      description = ''
        `security.acme.certs.<name>` whose TLS material backs the DoT
        listener and (when webUIPublic) the web UI vhost.
      '';
    };
  };

  config = mkIf cfg.enable {
    # ─── Free up port 53 for pi-hole ─────────────────────────────────────
    services.resolved.extraConfig = ''
      DNSStubListener=no
      MulticastDNS=off
    '';

    # ─── Pi-hole ─────────────────────────────────────────────────────────
    services.pihole-ftl = {
      enable = true;
      # Firewall is managed below to scope source IPs.
      openFirewallDNS = false;
      openFirewallWebserver = false;
      queryLogDeleter.enable = true;
      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          type = "block";
          enabled = true;
          description = "Steven Black's HOSTS";
        }
      ];
      settings = {
        dhcp.active = false;
        dns = {
          expandHosts = true;
          # All upstream queries go through stubby-upstream → Cloudflare DoT.
          upstreams = [ "127.0.0.1#5353" ];
          hosts = cfg.localHosts;
        };
        misc.dnsmasq_lines =
          (lib.optional (cfg.localTLD != null) "local=/${cfg.localTLD}/")
          ++ [
            "domain-needed"
            "bogus-priv"
            "stop-dns-rebind"
            "rebind-localhost-ok"
            "dns-forward-max=150"
            # Bind only to the configured addresses so stubby-peer can
            # claim 127.0.0.2:53 without an EADDRINUSE collision.
            "bind-interfaces"
          ]
          ++ map (a: "listen-address=${a}") cfg.dnsListenAddresses;
        ntp = {
          ipv4.active = false;
          ipv6.active = false;
          sync.active = false;
        };
      };
      useDnsmasqConfig = true;
    };

    services.pihole-web = {
      enable = true;
      ports = [ 8053 ];
    };

    # Bind the FTL webserver to localhost only; nginx terminates and proxies.
    services.pihole-ftl.settings.webserver.port = lib.mkForce "127.0.0.1:8053";
    services.pihole-ftl.settings.webserver.interface.theme = "lcars";

    # Silence a benign FTL.log warning about a missing versions file.
    systemd.tmpfiles.rules = [
      "f /etc/pihole/versions 0644 pihole pihole - -"
    ];

    # ─── stubby instances ────────────────────────────────────────────────
    # stubby-upstream: pi-hole's upstream (→ Cloudflare DoT).
    # stubby-peer:     resolv.conf secondary (→ peer DoT) — conditional.
    systemd.services = {
      stubby-upstream = {
        description = "stubby DoT upstream forwarder (pi-hole → Cloudflare)";
        after = [ "network.target" ];
        before = [ "pihole-FTL.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "notify";
          ExecStart = "${pkgs.stubby}/bin/stubby -C ${upstreamYaml}";
          DynamicUser = true;
          CacheDirectory = "stubby-upstream";
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
          Restart = "on-failure";
        };
      };
    } // lib.optionalAttrs hasPeer {
      stubby-peer = {
        description = "stubby DoT peer forwarder (resolv.conf failover)";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "notify";
          ExecStart = "${pkgs.stubby}/bin/stubby -C ${peerYaml}";
          DynamicUser = true;
          CacheDirectory = "stubby-peer";
          AmbientCapabilities = "CAP_NET_BIND_SERVICE";
          CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
          Restart = "on-failure";
        };
      };
    };

    # ─── /etc/resolv.conf ────────────────────────────────────────────────
    # Local pi-hole primary; stubby-peer secondary (encrypted to peer).
    networking.nameservers =
      [ "127.0.0.1" ] ++ (lib.optional hasPeer "127.0.0.2");

    # ─── DoT listener (nginx stream :853) ────────────────────────────────
    services.nginx.streamConfig = ''
      upstream dns_local_${replaceStrings [ "." "-" ] [ "_" "_" ] cfg.dotVHostName} {
        server 127.0.0.1:53;
      }
      server {
        listen 853 ssl;
        listen [::]:853 ssl;
        ssl_certificate     /var/lib/acme/${cfg.acmeCertName}/fullchain.pem;
        ssl_certificate_key /var/lib/acme/${cfg.acmeCertName}/key.pem;
        ssl_protocols       TLSv1.2 TLSv1.3;
        ssl_session_cache   shared:DOT:10m;
        proxy_pass          dns_local_${replaceStrings [ "." "-" ] [ "_" "_" ] cfg.dotVHostName};
        proxy_timeout       30s;
      }
    '';

    # ─── Web UI vhost (conditional) ──────────────────────────────────────
    services.nginx.virtualHosts = lib.optionalAttrs (cfg.webUIVHost != null) {
      ${cfg.webUIVHost} = {
        forceSSL = cfg.webUIPublic;
        useACMEHost = if cfg.webUIPublic then cfg.acmeCertName else null;
        basicAuthFile = if cfg.webUIPublic
          then (if cfg.webUIBasicAuthFile != null
                then cfg.webUIBasicAuthFile
                else "/etc/nginx/auth/${cfg.webUIVHost}")
          else null;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8053";
          extraConfig = ''
            ${concatMapStringsSep "\n" (cidr: "allow ${cidr};") cfg.trustedCIDRs}
            allow 127.0.0.1;
            deny all;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
      };
    };

    # ─── Firewall ────────────────────────────────────────────────────────
    # Open ports 53 (UDP+TCP) and 853 (TCP) only to trustedCIDRs.
    networking.firewall.extraCommands = lib.concatMapStringsSep "\n" (cidr: ''
      iptables -I nixos-fw -s ${cidr} -p udp --dport 53  -j nixos-fw-accept
      iptables -I nixos-fw -s ${cidr} -p tcp --dport 53  -j nixos-fw-accept
      iptables -I nixos-fw -s ${cidr} -p tcp --dport 853 -j nixos-fw-accept
    '') cfg.trustedCIDRs;
  };
}

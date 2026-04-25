{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "pihole" {
  # Free up port 53 for pihole-ftl's dnsmasq
  services.resolved.extraConfig = ''
    DNSStubListener=no
    MulticastDNS=off
  '';

  services.pihole-ftl = {
    enable = true;
    openFirewallDNS = true;
    # Web UI is bound to localhost and proxied via nginx (which has its own
    # firewall rules), so the FTL webserver port doesn't need opening.
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
        upstreams = [ "1.1.1.1" "1.0.0.1" ];
        hosts = [
          "192.168.1.148 thanos"
          "192.168.1.148 pihole.thanos"
          "192.168.1.148 restic.thanos"
        ];
      };
      # Treat the `.thanos` pseudo-TLD as local-only so dnsmasq answers from
      # `hosts` instead of forwarding to upstream and getting NXDOMAIN.
      misc.dnsmasq_lines = [
        "local=/thanos/"
      ];
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
    # Required by the option even though we override the resulting webserver.port
    # below to bind only to localhost.
    ports = [ 8053 ];
  };

  # Bind the web UI to localhost only; nginx terminates TLS and proxies it.
  # pihole-web's `ports` option doesn't accept interface binding, so override
  # the resulting setting directly.
  services.pihole-ftl.settings.webserver.port =
    lib.mkForce "127.0.0.1:8053";

  # Silence a benign FTL.log warning about a missing versions file.
  systemd.tmpfiles.rules = [
    "f /etc/pihole/versions 0644 pihole pihole - -"
  ];

  services.nginx.virtualHosts."pihole.thanos" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8053";
      extraConfig = ''
        allow 192.168.1.0/24;
        allow 127.0.0.1;
        deny all;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      '';
    };
  };
}

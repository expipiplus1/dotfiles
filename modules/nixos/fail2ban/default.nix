{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "fail2ban" {
  # Filter regexes for apps fail2ban doesn't ship by default. Each
  # filter must define a `failregex` matching auth failures with a
  # named `<HOST>` group that fail2ban substitutes its IP regex into.
  environment.etc = lib.mkMerge [
    (lib.mkIf config.ellie.home-assistant.enable {
      "fail2ban/filter.d/home-assistant.conf".text = ''
        [Definition]
        failregex = ^.*Login attempt or request with invalid authentication from <HOST>.*$
                    ^.*Failed login attempt .* from <HOST>.*$
        ignoreregex =
      '';
    })

    (lib.mkIf config.ellie.jellyfin.enable {
      "fail2ban/filter.d/jellyfin.conf".text = ''
        [Definition]
        failregex = ^.*Authentication request for .* has been denied \(IP: <HOST>\)\..*$
        ignoreregex =
      '';
    })

    (lib.mkIf config.ellie.immich.enable {
      "fail2ban/filter.d/immich.conf".text = ''
        [Definition]
        failregex = ^.*Failed login attempt for user .* from ip address <HOST>.*$
        ignoreregex =
      '';
    })
  ];

  services.fail2ban = {
    enable = true;
    ignoreIP = [ "202.83.104.81" ];

    # Repeat offenders get exponentially longer bans.
    # Default factor 2.0; we use 4 so 10m -> 40m -> 2h40 -> 10h40 -> ...
    # so a chronic scanner is locked out for the rest of the day after
    # ~3 ban cycles instead of bouncing back every 10 minutes.
    bantime-increment = {
      enable = true;
      factor = "4";
    };

    jails = {
      # Tighten the default sshd jail (nixpkgs ships it as a structured
      # form, so we extend it the same way rather than replace with a
      # freeform string).
      #
      # maxretry=3 with sshd MaxAuthTries=2 means: legitimate users
      # who fumble (e.g. wrong key from a fresh laptop) get banned only
      # if they make >= 2 connection attempts; scanners that exhaust
      # MaxAuthTries on a single connection burn 2 fails per connection
      # so they trip the ban on the second connection in <findtime.
      #
      # bantime-increment (configured above) makes repeat offenders
      # progressively worse off, so a chronic /24-rotating botnet
      # exhausts itself.
      sshd.settings = {
        maxretry = 3;
        findtime = "1m";
        bantime = "10m";
      };

      # The recidive jail bans any IP that has been banned by another
      # jail multiple times. Catches the rotating-IP-in-a-/24 botnets
      # that throttle to stay just below per-jail thresholds: each
      # individual ban-then-return cycle counts here and after a few
      # cycles the IP is meta-banned across all services for a week.
      recidive = ''
        enabled  = true
        filter   = recidive
        backend  = systemd
        journalmatch = _SYSTEMD_UNIT=fail2ban.service
        maxretry = 3
        findtime = 1d
        bantime  = 1w
        action   = iptables-allports[name=recidive]
      '';

      nginx-botsearch = ''
        enabled  = true
        filter   = nginx-botsearch
        action = iptables-multiport[name=NGINXBOT, port="http,https", protocol=tcp]
      '';
      nginx-http-auth = ''
        enabled  = true
        filter   = nginx-http-auth
        action = iptables-multiport[name=NGINXAUTH, port="http,https", protocol=tcp]
      '';
      nginx-bad-request = ''
        enabled  = true
        filter   = nginx-bad-request
        bantime  = 1h
        action   = iptables-multiport[name=NGINXBADREQ, port="http,https", protocol=tcp]
      '';
      nginx-forbidden = ''
        enabled  = true
        filter   = nginx-forbidden
        bantime  = 1h
        action   = iptables-multiport[name=NGINXFORBID, port="http,https", protocol=tcp]
      '';
    } // lib.optionalAttrs config.ellie.home-assistant.enable {
      home-assistant = ''
        enabled  = true
        filter   = home-assistant
        backend  = systemd
        journalmatch = _SYSTEMD_UNIT=home-assistant.service
        maxretry = 5
        findtime = 10m
        bantime  = 1h
        action   = iptables-multiport[name=HASS, port="http,https", protocol=tcp]
      '';
    } // lib.optionalAttrs config.ellie.jellyfin.enable {
      jellyfin = ''
        enabled  = true
        filter   = jellyfin
        backend  = systemd
        journalmatch = _SYSTEMD_UNIT=jellyfin.service
        maxretry = 5
        findtime = 10m
        bantime  = 1h
        action   = iptables-multiport[name=JELLYFIN, port="http,https", protocol=tcp]
      '';
    } // lib.optionalAttrs config.ellie.immich.enable {
      immich = ''
        enabled  = true
        filter   = immich
        backend  = systemd
        journalmatch = _SYSTEMD_UNIT=immich-server.service
        maxretry = 5
        findtime = 10m
        bantime  = 1h
        action   = iptables-multiport[name=IMMICH, port="http,https", protocol=tcp]
      '';
    };
  };
}

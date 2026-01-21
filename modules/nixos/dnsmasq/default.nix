{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "dnsmasq" {
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.dnsmasq = {
    enable = true;
    settings = {
      "domain-needed" = true;
      "bogus-priv" = true;
      "no-resolv" = true;
      "server" = [ "208.67.220.220" "8.8.4.4" ];
      "listen-address" = "0.0.0.0";
      "bind-interfaces" = true;
      "cache-size" = 10000;
      "log-queries" = true;
      "log-facility" = "/tmp/ad-block.log";
      "local-ttl" = 300;
      "no-hosts" = true;
      "conf-file" = "/etc/assets/hosts-blocklists/dnsmasq/dnsmasq.blacklist.txt";
    };
  };
}

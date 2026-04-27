{ lib, pkgs, config, ... }@inputs:
lib.internal.simpleModule inputs "nginx-server" {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    defaults.email = "acme@sub.monoid.al";
    acceptTerms = true;

    # Wildcard cert for monoid.al, issued via Namecheap DNS-01.
    # Both sen and thanos request this same cert. Their renewal cycles are
    # naturally out of phase (~1 week apart at issuance time) so they don't
    # race on Namecheap's full-replace setHosts API in practice.
    #
    # `--dns.propagation-disable-ans` skips lego's authoritative-NS check,
    # which dials freedns{1..5}.registrar-servers.com directly. On hosts
    # without working IPv6 (e.g. sen on Linode when the IPv6 path is down)
    # those dials use AAAA first and hang. Let's Encrypt does its own
    # multi-perspective propagation check server-side, so this only drops
    # a redundant client-side gate — it does not weaken validation.
    certs."monoid.al" = {
      domain = "monoid.al";
      extraDomainNames = [ "*.monoid.al" "*.home.monoid.al" ];
      dnsProvider = "namecheap";
      environmentFile = "/etc/acme/namecheap.env";
      group = "nginx";
      extraLegoFlags = [ "--dns.propagation-disable-ans" ];
    };
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    appendHttpConfig = ''
      server_names_hash_bucket_size 64;
    '';
  };
}

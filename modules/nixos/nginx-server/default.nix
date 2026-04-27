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
    recommendedTlsSettings = true;

    # Security headers applied to every vhost. `always` makes nginx
    # emit them on error responses (e.g. 401 from a basic-auth probe)
    # too. HSTS deliberately omits `includeSubDomains` so that a future
    # plain-HTTP `*.thanos` LAN vhost doesn't get refused by browsers
    # that have remembered the policy from the wildcard parent.
    appendHttpConfig = ''
      server_names_hash_bucket_size 64;
      server_tokens off;

      add_header Strict-Transport-Security "max-age=15552000" always;
      add_header X-Content-Type-Options "nosniff" always;
      add_header X-Frame-Options "SAMEORIGIN" always;
      add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    '';
  };
}

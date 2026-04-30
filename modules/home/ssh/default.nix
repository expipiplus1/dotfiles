{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "ssh" {
  programs.ssh = {
    enable = true;

    # Future-proof: home-manager 25.11 deprecates the implicit default
    # block in favour of an explicit Host * matchBlock.
    enableDefaultConfig = false;

    matchBlocks = {
      # Default identity for any host that doesn't override it.
      "*".identityFile = "~/.ssh/id_ed25519";

      # Public Linode VM. Non-default port to drop scanner noise.
      # IdentitiesOnly forces ssh to offer ONLY the listed key so that
      # MaxAuthTries=2 on the server isn't tripped by other agent-
      # loaded keys being offered first.
      sen = {
        hostname = "monoid.al";
        port = 50539;
        user = "e";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      # Oracle Cloud VPS. Same non-default-port pattern as sen.
      haku = {
        hostname = "152.69.215.136";
        port = 49813;
        user = "e";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      # LAN hosts.
      bow = { hostname = "192.168.1.148"; user = "e"; };
      sophie = { hostname = "192.168.1.118"; user = "e"; };

      # Borrowed shell account on a friend's box.
      orion = { hostname = "192.168.1.121"; user = "j"; };

      # Code forges. User comes from the host (git@), not from us.
      "gitlab.haskell.org" = { };

      github-as-slangbot = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/slangbot";
        identitiesOnly = true;
      };

      "gitlab-master.nvidia.com" = {
        hostname = "gitlab-master.nvidia.com";
        port = 12051;
        user = "git";
        identityFile = "~/.ssh/internal-gitlab-2";
        identitiesOnly = true;
      };
    };
  };
}

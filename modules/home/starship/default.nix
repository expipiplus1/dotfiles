{ lib, ... }@inputs:
lib.internal.simpleModule inputs "starship" {
  programs.starship = {
    enable = true;
    settings = {
      character.success_symbol = "[\\$](bold green)";
      character.error_symbol = "[\\$](bold red)";
      package.disabled = true;
      aws.disabled = true;
      cmake.disabled = true;

      directory = {
        truncate_to_repo = false;
        truncation_length = 0;
      };

      lua.disabled = true;

      c.disabled = true;

      nix_shell = {
        disabled = false;
        style = "fg:yellow dimmed";
        symbol = "\\[nix-shell\\]";
        format = "[$symbol]($style) ";
      };
      haskell.disabled = true;

      git_branch = { symbol = ""; };
      git_status = { disabled = true; };

      username.format = "[$user]($style)@";
      hostname.format = "[$hostname]($style) in ";

      custom.direnv = {
        disabled = false;
        format = "[\\[direnv\\]]($style) ";
        style = "fg:yellow dimmed";
        when = "env | grep -E '^DIRENV_FILE='";
      };

      custom.jj = {
        command = ''
          jj log -r@ -l1 --ignore-working-copy --no-graph --color always  -T '
            separate(" ",
              branches.map(|x| if(
                  x.name().substr(0, 10).starts_with(x.name()),
                  x.name().substr(0, 10),
                  x.name().substr(0, 9) ++ "…")
                ).join(" "),
              tags.map(|x| if(
                  x.name().substr(0, 10).starts_with(x.name()),
                  x.name().substr(0, 10),
                  x.name().substr(0, 9) ++ "…")
                ).join(" "),
              surround("\"","\"",
                if(
                   description.first_line().substr(0, 24).starts_with(description.first_line()),
                   description.first_line().substr(0, 24),
                   description.first_line().substr(0, 23) ++ "…"
                )
              ),
              if(conflict, "conflict"),
              if(divergent, "divergent"),
              if(hidden, "hidden"),
            )
          '
        '';
        detect_folders = [ ".jj" ];
      };

      custom.jjstate = {
        detect_folders = [ ".jj" ];
        command = ''
          jj log -r@ -l1 --no-graph -T "" --stat | tail -n1 | sd "(\d+) files? changed, (\d+) insertions?\(\+\), (\d+) deletions?\(-\)" " ''${1}m ''${2}+ ''${3}-" | sd " 0." ""
        '';
      };
    };
  };
}

{ lib, config, pkgs, ... }@inputs:
lib.internal.simpleModule inputs "tg" {
  home.packages = with pkgs; [tg];
  xdg.configFile = {
    "tg/conf.py".source = pkgs.writers.writePython3
      "conf.py" {}
      ''
        import os


        def read_file(file_path):
            try:
                # Open the file in read mode
                with open(file_path, 'r') as file:
                    # Read the file content
                    content = file.read()
                    # Strip leading and trailing whitespace
                    stripped_content = content.strip()
                    return stripped_content
            except FileNotFoundError:
                print(f"Error: The file '{file_path}' was not found.")
            except IOError as e:
                print(f"Error: I/O error reading '{file_path}'. Details: {e}")
            except Exception as e:
                print(f"An unexpected error occurred: {e}")


        # TODO: sops-nix or agenix for this
        PHONE = read_file(os.path.expanduser("~/dotfiles/phone"))

        CHAT_FLAGS = {
            "online": "●",
            "pinned": "P",
            "muted": "M",
            # chat is marked as unread
            "unread": "U",
            # last msg haven't been seen by recipient
            "unseen": "✓",
            "secret": "🔒",
            "seen": "✓✓",  # leave empty if you don't want to see it
        }
        MSG_FLAGS = {
            "selected": "*",
            "forwarded": "F",
            "new": "N",
            "unseen": "U",
            "edited": "E",
            "pending": "...",
            "failed": "😮",
            "seen": "✓✓",  # leave empty if you don't want to see it
        }
      '';
    };
}

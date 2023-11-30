{ lib, config, pkgs, ... }@inputs: lib.internal.simpleModule inputs "plasma"
{
  programs.plasma = {
    enable = true;
    configFile = {
      kcminputrc.Mouse.X11LibInputXAccelProfileFlat = false;
      kcminputrc."Libinput.5426.131.Razer Razer Basilisk X HyperSpeed".PointerAccelerationProfile =
        1;

      kcminputrc.Keyboard.RepeatDelay = 320;
      kcminputrc.Keyboard.RepeatRate = 35;

      kdeglobals.KDE.ScrollbarLeftClickNavigatesByPage = false;

      kdeglobals.KDE.SingleClick = false;

      kwinrc = {
        Compositing.LatencyPolicy = "Medium";

        NightColor = {
          Active = true;
          LatitudeFixed = 1.3;
          LongitudeFixed = 103.95;
          Mode = "Location";
        };

        Plugins = { screenedgeEnabled = false; };

        TabBox.HighlightWindows = false;
        TabBox.LayoutName = "thumbnail_switcher";

        Xwayland.Scale = 1.5;
      };

      plasmarc.Theme.name = "breeze-light";
      kxkbrc.Layout.Options = "caps:escape";

      plasmanotifyrc."Applications.tidal-hifi".ShowPopups = false;

    };
  };
}

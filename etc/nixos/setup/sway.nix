# Sway configuration
{ config, pkgs, lib, ... }:

let
  username = "etircopyh";
  swayRun = pkgs.writeShellScript "sway-run-test" ''
    SWAYLOGDIR="$HOME/.local/share/logs"

    [ ! -d "$SWAYLOGDIR" ] && command mkdir -p "$SWAYLOGDIR"

    echosplit () {
        echo ""
        echo "==========================================================================================="
        echo "------------------------- $@ ---------------------------------"
        echo "==========================================================================================="
    }

    if [ "$SWAY_DEBUG" = true ]; then
        echosplit "$(date)" >> "$SWAYLOGDIR/sway_debug.log"
        exec sway --verbose --debug >> "$SWAYLOGDIR/sway_debug.log"
    else
        echosplit "$(date)" >> "$SWAYLOGDIR/sway.log"
        exec sway 2>> "$SWAYLOGDIR/sway.log"
    fi
  '';
in

{

  #imports = [ ];

    programs.sway = {
        enable = true;
        wrapperFeatures.gtk = true;
        extraPackages = with pkgs; [
            seatd
            swaylock        # Screen locker
            swayidle
            qt5.qtwayland
            wl-clipboard    # Clipboard
            waybar          # Bar
            mako            # Notification daemon
            grim            # Screenshot tool
            slurp
            foot            # Terminal
            wf-recorder     # Screen recorder
            dex             # Autostart
            imv             # Image viewer
            wofi            # App launcher
            font-awesome
            adapta-gtk-theme
            glib            # GSettings
        ];
        extraSessionCommands = ''
            export XDG_SESSION_TYPE=wayland
            export XDG_SESSION_DESKTOP=sway
            export DESKTOP_SESSION=sway
            # Needs qt5.qtwayland in systemPackages
            export QT_QPA_PLATFORM=wayland-egl
            export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"

            # Wayland Support Variables
            export ELM_ACCEL=gl
            export ELM_DISPLAY=wl
            export ELM_ENGINE=wayland_egl
            export MOZ_ENABLE_WAYLAND=1
            export QT_QPA_PLATFORM=wayland-egl
            export CLUTTER_BACKEND=wayland
            export SDL_VIDEODRIVER=wayland
            export ECORE_EVAS_ENGINE=wayland_egl
            export _JAVA_AWT_WM_NONREPARENTING=1
        '';
    };

    services.greetd = {
        enable = true;
        restart = false;
        settings = {
            default_session = {
                command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway-run";
                user = "greeter";
            };
            initial_session = {
                command = "sway-run";
                user = "${username}";
            };
        };
    };

    programs.waybar.enable = true;
    programs.xwayland.enable = lib.mkForce false;

    environment = {
        etc = {
            # Put config files in /etc. Note that you also can put these in ~/.config, but then you can't manage them with NixOS anymore!
            "sway/config".source = "/home/${username}/GitRepos/arch.conf/dotfiles/user/.config/sway/config";
            "xdg/waybar/config".source = "/home/${username}/GitRepos/arch.conf/dotfiles/user/.config/waybar/config";
            "xdg/waybar/style.css".source = "/home/${username}/GitRepos/arch.conf/dotfiles/user/.config/waybar/style.css";
        };
    };

    environment.systemPackages = with pkgs; [
        (
            pkgs.writeTextFile {
                name = "startsway";
                destination = "/bin/startsway";
                executable = true;
                text = ''
                    #! ${pkgs.bash}/bin/bash

                    # first import environment variables from the login manager
                    systemctl --user import-environment
                    # then start the service
                    exec systemctl --user start sway.service
                '';
            }
        )
    ];

    systemd.user.targets.sway-session = {
        description = "Sway compositor session";
        documentation = [ "man:systemd.special(7)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
    };

    systemd.user.services.sway = {
        description = "Sway - Wayland window manager";
        documentation = [ "man:sway(5)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
        # We explicitly unset PATH here, as we want it to be set by
        # systemctl --user import-environment in startsway
        environment.PATH = lib.mkForce null;
        serviceConfig = {
            Type = "simple";
            ExecStart = ''
                ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
            '';
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
        };
    };

    #systemd.user.services.waybar = {
    #  description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
    #  documentation = [ "man:waybar(5)" ];
    #  partOf = [ "graphical-session.target" ];
    #  wantedBy = [ "sway-session.target" ];
    #  serviceConfig = {
    #      Type = "simple";
    #      ExecStart = ''
    #          ${pkgs.waybar}/bin/waybar
    #      '';
    #  };
    #};


    systemd.user.services.mako = {
        description = "A lightweight Wayland notification daemon";
        documentation = [ "man:mako(1)" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "sway-session.target" ];
        serviceConfig = {
            Type = "simple";
            ExecStart = ''
                ${pkgs.mako}/bin/mako
            '';
        };
    };
}

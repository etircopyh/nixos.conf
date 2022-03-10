# NixOS configuration file
# man 5 configuration.nix
{ config, inputs, ... }:

let
    username = "etircopyh";

    nur-repo = import inputs.nur {
        nurpkgs = import inputs.nixpkgs {
            system = "x86_64-linux";
            overlays = [];
        };

        repoOverrides = {
            shlyupa-nur-repo = import inputs.nur-shlyupa {};
        };
    };

    nurOverlay = self: super: {
        nur = import inputs.nur {
            nurpkgs = super;
            pkgs = super;
            repoOverrides = {
                shlyupa-nur-repo = import inputs.nur-shlyupa {
                    pkgs = super;
                };
            };
        };
    };

    overlays = [
        nurOverlay
        #nur-repo.repos.shlyupa-nur-repo.overlays.portal
    ];

    nixpkgsConfig = {
        allowUnfree = true;
        allowBroken = true;
    };

    pkgs = import inputs.nixpkgs {
        system = "x86_64-linux";
        config = nixpkgsConfig;
        overlays = overlays;
    };
    xdgConfig = config.environment.sessionVariables.XDG_CONFIG_HOME;

    inherit (pkgs) lib;
in

with lib;
{
    imports =
        [
            (import inputs.hardware-configuration)
            (import inputs.sway)              # SwayWM configuration
            (import inputs.zsh)               # ZSH configuration
        ];

    nixpkgs.overlays = overlays;

    # Boot setup
    boot = {
        loader.systemd-boot = {
            enable = true;
            configurationLimit = 10;
        };
        loader.efi.canTouchEfiVariables = mkForce false;
        supportedFilesystems = [ "zfs" "btrfs" ];
        zfs.enableUnstable = true;
        kernelPackages = pkgs.linuxPackages_xanmod;
        consoleLogLevel = 3;
        kernelParams = [ "systemd.restore_state=0" "audit=0" "i915.modeset=1" "i915.enable_fbc=1" "i915.enable_psr=0" "i915.enable_dc=0" "i915.fastboot=1" "i915.nuclear_pageflip=1" "intel_pstate=active" "pcie_aspm.policy=performance" "mitigations=off" "nowatchdog" "nmi_watchdog=0" "ipv6.disable=1" "cryptomgr.notests" "intel_iommu=igfx_off" "kvm-intel.nested=1" "no_timer_check" "noreplace-smp" "page_alloc_shuffle=1" "rcu_nocbs=0-64" "rcupdate.rcu_expedited=1" "tsc=reliable" "zfs.zfs_arc_max=3221225472" "boot.shell_on_fail" ];
        initrd.availableKernelModules = [ "zfs" "sd_mod" "ahci" "i915" "ath9k" "atl1c" "atkbd" "i8042" ];
        kernelModules = [ "bfq" ];
        blacklistedKernelModules = [ "iTC0_wdt" "uvcvideo" ];
        extraModprobeConfig = ''
        # Disable some power saving
            options snd_hda_intel enable_msi=1 power_save=0 power_save_controller=N
            options ath9k ps_enable=0
        # Prevent kernel from creating bond0 device
            options bonding max_bonds=0
        '';
        cleanTmpDir = true;
        kernel.sysctl = {
        # Kernel
            "kernel.sysrq" = 1;
        # Virtual memory
            "vm.swappiness" = 30;
            "vm.dirty_background_ratio" = 5;
            "vm.dirty_ratio" = 5;
            "vm.vfs_cache_pressure" = 50;
            "vm.min_free_kbytes" = 131072;
            "vm.max_map_count" = 262144;
        # Network performance
            "net.core.netdev_max_backlog" = 8192;
            "net.core.netdev_budget" = 50000;
            "net.core.netdev_budget_usecs" = 5000;
            "net.core.rmem_default" = 1048576;
            "net.core.rmem_max" = 16777216;
            "net.core.wmem_default" = 1048576;
            "net.core.wmem_max" = 16777216;
            "net.core.optmem_max" = 65536;
            "net.ipv4.tcp_rmem" = "4096 1048576 2097152";
            "net.ipv4.tcp_wmem" = "4096 65536 16777216";
            "net.ipv4.udp_rmem_min" = 8192;
            "net.ipv4.udp_wmem_min" = 8192;
            "net.ipv4.tcp_fastopen" = 3;
            "net.ipv4.tcp_max_syn_backlog" = 8192;
            "net.ipv4.tcp_max_tw_buckets" = 2000000;
            "net.ipv4.tcp_tw_reuse" = 1;
            "net.ipv4.tcp_early_retrans" = 1;
            "net.ipv4.tcp_fin_timeout" = 10;
            "net.ipv4.tcp_slow_start_after_idle" = 0;
            "net.ipv4.tcp_keepalive_time" = 60;
            "net.ipv4.tcp_keepalive_intvl" = 10;
            "net.ipv4.tcp_keepalive_probes" = 6;
            "net.ipv4.tcp_mtu_probing" = 1;
            "net.ipv4.tcp_sack" = 1;
            "net.ipv4.ip_local_port_range" = "30000 65535";
            "net.core.default_qdisc" = "fq_pie";
            "net.ipv4.tcp_congestion_control" = "yeah";
        # Network security
            "net.ipv4.tcp_rfc1337" = 1;
            "net.ipv4.tcp_timestamps" = 0;
            "net.ipv4.tcp_syn_retries" = 3;
            "net.ipv4.tcp_synack_retries" = 2;
            "net.ipv4.tcp_syncookies" = 1;
            "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
            "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
            "net.ipv4.conf.default.rp_filter" = 1;
            "net.ipv4.conf.*.rp_filter" = 1;
            "net.ipv4.conf.all.rp_filter" = 1;
            "net.ipv4.conf.all.accept_redirects" = 0;
            "net.ipv4.conf.default.accept_redirects" = 0;
            "net.ipv4.conf.all.secure_redirects" = 0;
            "net.ipv4.conf.default.secure_redirects" = 0;
            "net.ipv6.conf.all.accept_redirects" = 0;
            "net.ipv6.conf.default.accept_redirects" = 0;
            "net.ipv4.conf.all.send_redirects" = 0;
            "net.ipv4.conf.default.send_redirects" = 0;
        # Disable IPv6
            "net.ipv6.conf.default.disable_ipv6" = 1;
            "net.ipv6.conf.lo.disable_ipv6" = 1;
            "net.ipv6.conf.all.disable_ipv6" = 1;
            "net.ipv6.conf.eth0.disable_ipv6" = 1;
            "net.ipv6.conf.wlan0.disable_ipv6" = 1;
        };
    };

    # Security
    security = {
      rtkit.enable = true;
      apparmor.enable = mkForce false;
      pam.loginLimits = [
          { domain = "${username}"; item = "memlock"; type = "soft"; value = "64"; }
          { domain = "${username}"; item = "memlock"; type = "hard"; value = "128"; }
      ];
      sudo.extraConfig = ''
        Defaults insults
        Defaults timestamp_timeout=10
        Defaults passwd_timeout=0
        Defaults passprompt="[sudo] password for %p: "
      '';
    };

    # Power management
    powerManagement = {
        cpuFreqGovernor = "performance";
        scsiLinkPolicy = "max_performance";
    };

    # Networking stuff
    networking = {
        hostName = "nixos-usb";
        hostId = "e7bfdb3e";
        resolvconf = {
            enable = true;
            useLocalResolver = true;
            extraOptions = [ "trust-ad" ];
            extraConfig = ''
                name_server_blacklist="0.0.0.0 127.0.0.1"
            '';
        };
        wireless.iwd = {
            enable = true;
            settings = {
                General = {
                    AddressRandomization = "once";
                };
                Network = {
                    EnableIPv6 = false;
                    NameResolvingService = "resolvconf";
                };
            };
        };
        dhcpcd.enable = false;
        useNetworkd = true;
        enableIPv6 = false;
        useDHCP = false;
        firewall.enable = false;
        hosts = {
        # The following lines are desirable for IPv4 capable hosts
            "127.0.0.1" = [ "localhost" ];
            "255.255.255.255" = [ "broadcasthost" ];
            "0.0.0.0" = [ "0.0.0.0" ];

        # The following lines are desirable for IPv6 capable hosts
            "::1" = [ "localhost" "ip6-localhost" "ip6-loopback" ];
            "ff00::0" = [ "ip6-localnet" ];
            "ff02::1" = [ "ip6-allnodes" ];
            "ff02::2" = [ "ip6-allrouters" ];
            "ff02::3" = [ "ip6-allhosts" ];
        };
        #timeServers = [ "0.europe.pool.ntp.org" "1.europe.pool.ntp.org" "2.europe.pool.ntp.org" "3.europe.pool.ntp.org" ];
        usePredictableInterfaceNames = false;
    };

    systemd = {
        coredump.enable = true;
        coredump.extraConfig = "Storage=none";
        network.netdevs = {
            bond007 = {
                enable = true;
                netdevConfig = {
                    Name = "bond007";
                    Kind = "bond";
                };
                bondConfig = {
                    Mode = "active-backup";
                    PrimaryReselectPolicy = "always";
                    MIIMonitorSec = "1s";
                };
            };
        };
        network.networks = {
            bond007 = {
                enable = true;
                name = "bond007";
                DHCP = "ipv4";
                routes = [ {
                    routeConfig = {
                        Gateway = "_dhcp4";
                        InitialCongestionWindow = 30;
                        InitialAdvertisedReceiveWindow = 30;
                    };
                } ];
                dhcpV4Config = {
                    Anonymize = true;
                };
                networkConfig = {
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = "no";
                };
            };
            eth0 = {
                enable = true;
                name = "eth0";
                DHCP = "ipv4";
                bond = [ "bond007" ];
                routes = [ {
                    routeConfig = {
                        Gateway = "_dhcp4";
                        InitialCongestionWindow = 30;
                        InitialAdvertisedReceiveWindow = 30;
                    };
                } ];
                dhcpV4Config = {
                    Anonymize = true;
                };
                networkConfig = {
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = "no";
                    PrimarySlave = true;
                };
            };
            wlan0 = {
                enable = true;
                name = "wlan0";
                DHCP = "ipv4";
                bond = [ "bond007" ];
                routes = [ {
                    routeConfig = {
                        Gateway = "_dhcp4";
                        InitialCongestionWindow = 30;
                        InitialAdvertisedReceiveWindow = 30;
                    };
                } ];
                dhcpV4Config = {
                    Anonymize = true;
                };
                networkConfig = {
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = "no";
                };
            };
        };
        tmpfiles.rules = [
          "L /tmp/kotatogram-data - - - - /home/${username}/.local/share/KotatogramDesktop"
        ];
    };

    # Services
    services = {
        udev.extraRules = ''
            # Set scheduler for NVMe
            ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
            # Set scheduler for SSD and eMMC
            ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
            # Set scheduler for rotating disks
            ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"

            # Power management rules
            # PCI
            SUBSYSTEM=="pci", ATTR{power/control}="on"
            # USB
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"

            # iwd
            SUBSYSTEM=="rfkill", ENV{RFKILL_NAME}=="phy0", ENV{RFKILL_TYPE}=="wlan", ACTION=="change", ENV{RFKILL_STATE}=="1", RUN+="${pkgs.systemd}/bin/systemctl --no-block start iwd.service"
            SUBSYSTEM=="rfkill", ENV{RFKILL_NAME}=="phy0", ENV{RFKILL_TYPE}=="wlan", ACTION=="change", ENV{RFKILL_STATE}=="0", RUN+="${pkgs.systemd}/bin/systemctl --no-block stop iwd.service"
        '';
        dnscrypt-proxy2 = {
            enable = true;
            settings = {
                server_names = [ "quad9-dnscrypt-ip4-nofilter-ecs-pri" "dnscrypt.eu-nl" "v.dnscrypt.uk-ipv4" "cloudflare-security" ];
                ipv6_servers = false;
                require_dnssec = true;

                require_nofilter = false;

                block_ipv6 = true;

                cache = true;
            };
        };
        timesyncd = {
            enable = true;
            servers= [ "0.ua.pool.ntp.org" "1.ua.pool.ntp.org" "2.ua.pool.ntp.org" "3.ua.pool.ntp.org" ];
            extraConfig = ''
                FallbackNTP=0.arch.pool.ntp.org 1.nixos.pool.ntp.org 2.arch.pool.ntp.org 3.nixos.pool.ntp.org
                PollIntervalMinSec=20480
                PollIntervalMaxSec=40960
            '';
        };
        resolved = {
            enable = false;
            dnssec = "false";
            llmnr = "false";
            fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
            extraConfig = ''
                DNSOverTLS=no
                MulticastDNS=yes
                Cache=yes
                DNSStubListener=yes
                ReadEtcHosts=yes
            '';
        };
        journald.extraConfig = ''
            Storage=volatile
            Compress=yes
            SystemMaxUse=50M
            SystemMaxFileSize=15M
            RuntimeMaxUse=50M
            RuntimeMaxFileSize=10M
            Audit=no
        '';
        logind.killUserProcesses = true;
        gnome.at-spi2-core.enable = mkForce false;
        gnome.gnome-keyring.enable = mkForce false;
    };

    # Systemd services
    systemd.services = {
        systemd-networkd-wait-online.enable = false;
    };

    #systemd.services.dnscrypt-proxy2.serviceConfig = {
    #    StateDirectory = mkForce "dnscrypt-proxy2";
    #};

    systemd.services.polkit = {
        restartIfChanged = false;
    };

    # Portals
    xdg.portal = {
        enable = true;
        gtkUsePortal = true;
        extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-kde
        ];
    };

    # Locale
    i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [ "en_US.UTF-8/UTF-8" "en_GB.UTF-8/UTF-8" ];
        extraLocaleSettings = {
            LC_MEASUREMENT = "C";
            LC_TIME = "en_GB.UTF-8";
        };
    };

    console = {
        packages = with pkgs; [ terminus_font ];
        font = "ter-v16n";
        keyMap = "us";
        earlySetup = true;
    };

    # Time zone.
    time.timeZone = "Europe/Kiev";

    # Fonts
    fonts = {
        fontconfig = {
            antialias = true;
            subpixel.rgba = "none";
            localConf = ''
                <alias>
                    <family>terminal</family>
                    <prefer>
                        <family>Hasklug Nerd Font</family>
                        <family>Noto Color Emoji</family>
                    </prefer>
                </alias>
            '';
            #crOSMaps = true;
            #useNotoCjk = true;
            defaultFonts = {
                sansSerif = [ "DejaVu Sans" "Arimo Nerd Font" ];
                emoji = [ "JoyPixels" ];
            };
        };
        fontDir.enable = true;
        fonts = with pkgs; [
            roboto
            hasklig
            #noto-fonts-cjk
            ibm-plex
            #font-awesome
            (nerdfonts.override { fonts = [ "Arimo" ]; })
        ];
    };

    hardware = {
        opengl = {
            enable = true;
            extraPackages = with pkgs; [
                vaapiIntel
                libGL
                libva-utils
                libdrm
            ];
        };
        bluetooth = {
            powerOnBoot = true;
            enable = true;
            package = pkgs.bluezFull;
            settings = { General = { Experimental = true; }; };
        };
    };

    gtk.iconCache.enable = true;

    # Global packages
    environment.systemPackages = with pkgs; [
    # Basic software
        #dbus-broker
        toybox
        curl
        tree
        git
        imv
        brightnessctl
        unzip
        zip
        p7zip
        file
        jq
        lm_sensors
        pciutils
        usbutils
        dex
        playerctl
        #aria2
        neofetch
        htop
        alacritty                      # Terminal
        lf                             # TUI File Manager

    # Libraries
        libarchive

    # System customization
        bibata-cursors
        papirus-icon-theme
        breeze-gtk
        materia-theme
        gsettings-desktop-schemas
        libsForQt5.qtstyleplugin-kvantum

    # Audio
        lxqt.pavucontrol-qt
        pamixer
        #ladspaPlugins

    # User software
        kotatogram-desktop
        #tdesktop
        firefox-wayland
        qutebrowser
        qbittorrent
        flameshot
        mate.mate-calc
        mpv
        yt-dlp-light
        #vscodium
        #mate.mate-polkit
        mate.engrampa
        #mate.caja
        #steam
        #steam-run-native
        #lutris
        #pactl

    # Nix/NixOS stuff
        nix-index

    # Rust written replacement
        uutils-coreutils
        #amp
        sd
        du-dust
        #watchexec
        #tokei
        ripgrep
        fd
        skim
        bat
        exa
        gitAndTools.delta
        zoxide

    # File system
        go-mtpfs
        sshfs

    # Development
        #autoPatchelfHook
        #patchelf
        #shellcheck
        libclang
        sumneko-lua-language-server
        rnix-lsp

    # Terminal
        starship
        grml-zsh-config
        fnm
    ];

    environment.localBinInPath = true;
    #environment.memoryAllocator.provider = "jemalloc";

    # Session variables
    environment.sessionVariables = rec {
        MANPAGER = "nvim +Man!";
        BROWSER = "firefox";
        VISUAL = "$EDITOR";
        SYSTEMD_EDITOR = "$EDITOR";
        SYSTEM = "$(uname -s)";
        TERMINAL = "foot";
        QT_XFT = "true";
        ZDOTDIR = "$HOME/.config/zsh";
        ZHOME = "$HOME/.config/zsh";
        NO_AT_BRIDGE = "1";
        XDG_CACHE_HOME = "/tmp/${username}/.cache";
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_BIN_HOME = "$HOME/.local/bin";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_LIB_HOME = "$HOME/.local/lib";
        XDG_STATE_HOME = "$HOME/.local/state";
    };

    programs = {
        git = {
            enable = true;
            config = {
                "core" = {
                    "editor" = "nvim";
                    "pager" = "delta";
                };
                "init" = {
                    "defaultBranch" = "master";
                };
                "interactive" = {
                    "diffFilter" = "delta --color-only";
                };
                "user" = {
                    "name" = "Ivan";
                    "email" = "etircopyhdot@gmail.com";
                };
                "gpg" = {
                    "program" = "gpg2";
                };
                "credential" = {
                    "helper" = "cache --timeout 14400";
                    "username" = "${username}";
                };
                "commit" = {
                    "verbose" = "true";
                };
                "tag" = {
                    "gpgsign" = "true";
                };
                "pull" = {
                    "default" = "current";
                    "rebase" = "false";
                };
                "push" = {
                    "default" = "current";
                };
                "rebase" = {
                    "autoSquash" = "true";
                    "autoStash" = "true";
                    "stat" = "true";
                };
                "grep" = {
                    "lineNumber" = "true";
                };
                "pager" = {
                    "diff" = "delta";
                    "log" = "delta";
                    "reflog" = "delta";
                    "show" = "delta";
                };
            };
        };

        gnupg = {
            agent = {
                enable = true;
                enableSSHSupport = false;
            };
            package = pkgs.gnupg;
        };
        tmux = {
            enable = true;
            keyMode = "vi";
            shortcut = "a";
            terminal = "tmux-256color";
            escapeTime = 0;
            historyLimit = 10000;
            aggressiveResize = true;
            customPaneNavigationAndResize = true;
        };
        neovim = {
            enable = true;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
            withRuby = false;
            configure = {
                packages.myPlugins = with pkgs.vimPlugins; {
                    start = [
                        (nvim-treesitter.withPlugins (
                            plugins: with plugins; [
                                tree-sitter-nix
                                tree-sitter-python
                                tree-sitter-c
                                tree-sitter-cpp
                            ]
                        ))
                    ];
                };
                customRC = ''
                    source ${xdgConfig}/nvim/init.vim
                '';
            };
        };
        qt5ct.enable = true;
        #adb.enable = true;
        #npm.enable = true;
        #steam.enable = true;
        #chromium.enable = true;
    };

    qt5.style = "kvantum";

    # DBUS
    services.dbus = {
        enable = true;
        apparmor = "disabled";
    };

    services.printing.enable = false;

    # Sound
    #sound.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = false;
        config.pipewire = {
            "context.properties" = {
                "default.clock.allowed-rates" = [ 44100 48000 96000 ];
            };
        };
        media-session.config = {
            bluez-monitor = {
                # Matches all cards
                matches = [ { "device.name" = "~bluez_card.*"; } ];
                properties = {
                    "bluez5.enable-msbc" = true;
                    "bluez5.enable-sbc-xq" = true;
                    "bluez5.enable-hw-volume" = true;
                    "bluez5.enable-faststream" = true;
                    "bluez5.dummy-avrcp-player" = false;
                };

                actions = {
                    update-props = {
                        "bluez5.a2dp.ldac.quality" = "mq";
                    };
                };

                rules = [
                    {
                        matches = [
                            # Matches all sources
                            { "node.name" = "~bluez_input.*"; }
                            # Matches all outputs
                            { "node.name" = "~bluez_output.*"; }
                        ];
                        actions = {
                            "update-props" = {
                                "node.pause-on-idle" = false;
                                "session.suspend-timeout-seconds" = 5;
                            };
                        };
                    }
                ];
            };
        };
    };

    # ZRAM setup
    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        numDevices = 1;
    };

    services.fstrim = {
        enable = true;
        interval = "weekly";
    };

    # X11
    services.xserver = {
        enable = false;
        layout = "us,ru";
        xkbModel = "asus_laptop";
        xkbOptions = "grp:caps_toggle,grp:switch,altwin:menu_win";
        videoDrivers = [ "modesetting" ];
        #useGlamor = true;
        # Enable touchpad support.
        #libinput.enable = true;
        # KDE
        displayManager = {
            sddm.enable = false;
            autoLogin.enable = true;
            autoLogin.user = "${username}";
        };
        desktopManager.plasma5.enable = false;
    };

    #services.colord.enable = true;

    # TTY Login
    services.getty = {
      #autologinUser = "${username}";
      extraArgs = [ "--skip-login" ];
      loginOptions = "${username}";
      #greetingLine = "";
    };

    nix.registry.self.flake = inputs.self;

    environment.etc."channels/nixpkgs".source = inputs.nixpkgs;
    #environment.etc."channels/home-manager".source = inputs.home-manager;
    #"home-manager=/etc/channels/home-manager"
    nix = {
        nixPath = mkForce [
            "nixpkgs=/etc/channels/nixpkgs"
            "nixos-config=/etc/nixos/configuration.nix"
            "nixpkgs-overlays=/etc/nixos/overlays-compat"
        ];
        package = pkgs.nixUnstable;
        extraOptions = "experimental-features = nix-command flakes";
        useSandbox = false;
        autoOptimiseStore = true;
        buildCores = 5;
        trustedUsers = [ "root" "@wheel" ];
    };

    # Nixpkgs configuration
    nixpkgs.config = nixpkgsConfig;

    documentation.doc.enable = false;

    # User configuration
    users = {
        defaultUserShell = pkgs.zsh;
        #mutableUsers = false;
        users = {
            root = {
                #useDefaultShell = true;
                shell = pkgs.zsh;
                #hashedPassword = "";
                #description = "Root";
            };
            ${username} = {
                isNormalUser = true;
                createHome = true;
                useDefaultShell = true;
                #hashedPassword = "";
                extraGroups = [ "wheel" "uucp" "audio" "video" ];
            };
        };
    };

    system.stateVersion = "22.05";
}

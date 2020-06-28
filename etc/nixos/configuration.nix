# NixOS configuration file
# man 5 configuration.nix
{ config, pkgs, lib, ... }:

{
    imports =
        [
            ./hardware-configuration.nix # The results of the hardware scan. (Don't edit)
            /home/etircopyh/.config/nixos/sway.nix # SwayWM configuration
            /home/etircopyh/.config/nixos/zsh.nix  # ZSH configuration
            # /home/etircopyh/.config/nixos/pkgoverride.nix
        ];

    # Use the systemd-boot EFI boot loader.
    # boot.loader.efiBootStub = {
    #     enable = true;
    #     efiDisk = "/dev/sdb";
    #     efiPartition = "2";
    #     efiSysMountPoint = "/boot";
    #     runEfibootmgr = false;
    #     installStartupNsh = false;
    #     installShell = false;
    # };

    # Boot setup
    boot = {
        loader.systemd-boot.enable = true;
        #loader.efi.canTouchEfiVariables = true;
        supportedFilesystems = [ "zfs" ];
        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [ "systemd.restore_state=0" "audit=0" "i915.modeset=1" "i915.enable_fbc=1" "i915.enable_psr=0" "i915.enable_dc=0" "i915.fastboot=1" "i915.nuclear_pageflip=1" "pcie_aspm.policy=performance" "mitigations=off" "nowatchdog" "nmi_watchdog=0" "ipv6.disable=1" "cryptomgr.notests" "intel_iommu=igfx_off" "kvm-intel.nested=1" "no_timer_check" "noreplace-smp" "page_alloc_shuffle=1" "rcu_nocbs=0-64" "rcupdate.rcu_expedited=1" "tsc=reliable" ];
        initrd.availableKernelModules = lib.mkForce [ "zfs" "sd_mod" "ahci" "i915" ];
        blacklistedKernelModules = [ "iTC0_wdt" "uvcvideo" ];
        cleanTmpDir = true;
        kernel.sysctl = {
        # Kernel
            "kernel.sysrq" = 1;
            "kernel.printk" = "3 3 3 3";
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
            "net.ipv6.conf.eth*.disable_ipv6" = 1;
            "net.ipv6.conf.wlan*.disable_ipv6" = 1;
        };
    };

    # Power management
    powerManagement = {
        cpuFreqGovernor = "performance";
        scsiLinkPolicy = "max_performance";
    };

    # Networking stuff
    networking = {
        hostName = "nixsys";
        hostId = "e7bfdb3e";
        wireless.iwd.enable = true;  # Enables wireless support via iwd.
        dhcpcd.enable = false;
        useNetworkd = true;
        enableIPv6 = false;
        useDHCP = false;
        interfaces.eth0.useDHCP = true;
        interfaces.wlan0.useDHCP = true;
        firewall.enable = false;
        # Open ports in the firewall.
        # firewall.allowedTCPPorts = [ ... ];
        # firewall.allowedUDPPorts = [ ... ];
        # Configure network proxy if necessary
        # proxy.default = "http://user:password@proxy:port/";
        # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
        hosts = {
        # The following lines are desirable for IPv4 capable hosts
            "127.0.0.1" = [ "localhost" ];
            # "127.0.0.1" = [ "localhost.localdomain" ];
            # "127.0.0.1" = [ "local" ];
            "255.255.255.255" = [ "broadcasthost" ];
            "0.0.0.0" = [ "0.0.0.0" ];

        # The following lines are desirable for IPv6 capable hosts
            "::1" = [ "localhost" "ip6-localhost" "ip6-loopback" ];
            # "fe80::1%lo0" = [ "localhost" ];
            "ff00::0" = [ "ip6-localnet" ];
            # "ff00::0" = [ "ip6-mcastprefix" ];
            "ff02::1" = [ "ip6-allnodes" ];
            "ff02::2" = [ "ip6-allrouters" ];
            "ff02::3" = [ "ip6-allhosts" ];
        };
        timeServers = [ "0.europe.pool.ntp.org" "1.europe.pool.ntp.org" "2.europe.pool.ntp.org" "3.europe.pool.ntp.org" ];
        usePredictableInterfaceNames = false;
    };

    systemd = {
        coredump.enable = true;
        coredump.extraConfig = "Storage=none";
        network.networks = {
            eth0 = {
                name = "eth0";
                DHCP = "ipv4";
                networkConfig = {
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = "no";
                };
            };
            wlan0 = {
                name = "wlan0";
                DHCP = "ipv4";
                networkConfig = {
                    LinkLocalAddressing = "no";
                    IPv6AcceptRA = "no";
                };
            };
        };
    };

    # Services
    services = {
        dnscrypt-proxy2 = {
            enable = true;
            configFile = /home/etircopyh/.config/dnscrypt-proxy/dnscrypt-proxy.toml;
        };
        resolved.enable = false;
        resolved.dnssec = false;
        logind.killUserProcesses = true;
        nscd.enable = true;
        gnome3.at-spi2-core.enable = lib.mkForce false;
        gnome3.gnome-keyring.enable = lib.mkForce false;
    };

    # Portals
    # xdg.portal = {
    #     enable = true;
    #     extraPortals = with pkgs; [
    #         xdg-desktop-portal-kde
    #     ];
    # };

    # Locale
    i18n = {
        defaultLocale = "en_US.UTF-8";
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
        fontconfig.antialias = true;
        fontconfig.subpixel.rgba = "none";
        fontconfig.hinting.enable = true;
    };

    hardware = {
        opengl = {
            enable = true;
            driSupport32Bit = true;
            extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
            extraPackages = with pkgs; [
                vaapiIntel
                vaapiVdpau
                libGL
                libva-utils
                libdrm
            ];
        };
        bluetooth = {
            enable = true;
            package = pkgs.bluezFull; # pkgs.bluez/bluezFull
        };
        pulseaudio = {
            enable = true;
        support32Bit = true;
            package = pkgs.pulseaudioFull; # pkgs.pulseaudio/pulseaudioFull
            configFile = /home/etircopyh/.config/pulse/default.pa;
            daemon.config = {
                daemonize = "no";
                high-priority = "yes";
                nice-level = "-15";
                resample-method = "speex-float-10";
                enable-lfe-remixing = "no";
                flat-volumes = "no";
                default-sample-format = "float32le";
                default-sample-rate = "44100";
                alternate-sample-rate = "96000";
                default-sample-channels = "2";
                default-channel-map = "front-left,front-right";
            };
        };
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        curl
        bat                            # better cat
        iwd
        dex
        aria2
        exa
        neofetch
        htop
        alacritty                      # Terminal
        hasklig
        ibm-plex
        bibata-cursors
        papirus-icon-theme
        breeze-gtk
        firefox-wayland
        lxqt.pavucontrol-qt
        pantheon.elementary-calculator # Calculator
        git
        ix
        imv
        unzip
        zip
        unrar
        file
        jq
        pciutils
        usbutils
        pamixer
        ladspaPlugins
        #kotatogram-desktop              # TG-desktop fork
        tdesktop
        brightnessctl
        mpv
        playerctl                       # mpris2
        dnscrypt-proxy2
        youtube-dl-light
        nix-index
        neovim
        vimPlugins.vim-plug
        shellcheck
        ripgrep
        vscodium
        mate.caja
        fzf                             # FZF
        steam-run-native
        steam
        #ntfs3g
        #gcc-unwrapped.lib
        #gdb
        #lutris
        #SDL2
        #autoPatchelfHook
        #patchelf
        # Xorg
        #xclip
        #flameshot
        #maim
        # ZSH
        starship
        zsh-autosuggestions             # Fish-like autosuggestions
        zsh-completions                 # Additional completions
        zsh-history-substring-search    # Substring search
        zsh-syntax-highlighting         # Syntax highlighting
        zsh-command-time
        nix-zsh-completions             # Nix completions
        grml-zsh-config
    ];

    # Session variables
    environment.sessionVariables = rec {
        SYSTEM = "$(uname -s)";
        ZSHCONFIG = "~/.zsh-config";
        TERMINAL = "alacritty";
        BROWSER = "firefox";
        EDITOR = "nvim";
        VISUAL = "$EDITOR";
        SYSTEMD_EDITOR = "$EDITOR";
    };

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Enable CUPS to print documents.
    services.printing.enable = false;

    # Sound
    sound.enable = true;
    nixpkgs.config.pulseaudio = true;

    # ZRAM setup
    zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
        numDevices = 1;
    };

    # X11 windowing system.
    services.xserver = {
        enable = false;
        layout = "us,ru";
        xkbModel = "asus_laptop";
        xkbOptions = "grp:caps_toggle,grp:switch,altwin:menu_win";
        videoDrivers = [ "modesetting" ];
        # useGlamor = true;
        # Enable touchpad support.
        # libinput.enable = true;
        # Enable the KDE Desktop Environment
        displayManager.sddm.enable = false;
        desktopManager.plasma5.enable = false;
        # displayManager.lightdm = {
        #     enable = false;
        #     greeter.enable = false;
        # };
    };

    # Enable the KDE Desktop Environment.
    # services.xserver.displayManager.sddm.enable = true;
    # services.xserver.desktopManager.plasma5.enable = true;

    # users.mutableUsers = false;

    services.mingetty.autologinUser = "etircopyh";
    nixpkgs.config = {
        allowUnfree = true;
        allowBroken = true;
        # permittedInsecurePackages = [
        #     "p7zip-16.02"
        # ];
    };

    users = {
        defaultUserShell = pkgs.zsh;
        # mutableUsers = false;
        users = {
            root = {
                # isNormalUser = true;
                # createHome = true;
                # home = "/root";
                # useDefaultShell = true;
                shell = pkgs.zsh;
                # hashedPassword = "";
                # description = "Root";
            };
        # Define a user account. Don't forget to set a password with ‘passwd’.
            etircopyh = {
                isNormalUser = true;
                createHome = true;
                # home = "/home/etircopyh";
                useDefaultShell = true;
                # shell = pkgs.zsh;
                # hashedPassword = "";
                # description = "User";
                extraGroups = [ "wheel" "uucp" "audio" ];
            };
        };
    };

    # This value determines the NixOS release with which your system is to be
    # compatible, in order to avoid breaking some software such as database
    # servers. You should change this only after NixOS release notes say you
    # should.
    system.stateVersion = "19.09";
}

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
        kernelParams = [ "systemd.restore_state=0" "audit=0" "i915.modeset=1" "i915.enable_fbc=1" "i915.enable_psr=0" "i915.enable_dc=0" "i915.fastboot=1" "i915.nuclear_pageflip=1" "intel_pstate=active" "pcie_aspm.policy=performance" "mitigations=off" "nowatchdog" "nmi_watchdog=0" "ipv6.disable=1" "cryptomgr.notests" "intel_iommu=igfx_off" "kvm-intel.nested=1" "no_timer_check" "noreplace-smp" "page_alloc_shuffle=1" "rcu_nocbs=0-64" "rcupdate.rcu_expedited=1" "tsc=reliable" ];
        initrd.availableKernelModules = lib.mkForce [ "zfs" "sd_mod" "ahci" "i915" ];
        kernelModules = [ "bfq" ];
        blacklistedKernelModules = [ "iTC0_wdt" "uvcvideo" ];
        extraModprobeConfig = ''
            options snd_hda_intel enable_msi=1 power_save=0 power_save_controller=N
            options ath9k ps_enable=0 use_msi=1
        '';
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
            "net.ipv6.conf.eth0.disable_ipv6" = 1;
            "net.ipv6.conf.wlan0.disable_ipv6" = 1;
        };
    };

    # Security
    security.rtkit.enable = true;
    security.apparmor.enable = lib.mkForce false;

    # Power management
    powerManagement = {
        cpuFreqGovernor = "schedutil";
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
        udev.extraRules = ''
            # set scheduler for NVMe
            ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
            # set scheduler for SSD and eMMC
            ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
            # set scheduler for rotating disks
            ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
            # Power management rules
            # PCI
            SUBSYSTEM=="pci", ATTR{power/control}="on"
            # USB
            ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
        '';
        dnscrypt-proxy2 = {
            enable = true;
            configFile = /home/etircopyh/.config/dnscrypt-proxy/dnscrypt-proxy.toml;
        };
        resolved.enable = false;
        resolved.dnssec = false;
        throttled = {
            enable = true;
            extraConfig = ''
                [AC]
                # Update the registers every this many seconds
                Update_Rate_s: 5
                # Max package power for time window #1
                PL1_Tdp_W: 45
                # Time window #1 duration
                PL1_Duration_s: 35
                # Max package power for time window #2
                PL2_Tdp_W: 56
                # Time window #2 duration
                PL2_Duration_S: 0.002
                # Max allowed temperature before throttling
                Trip_Temp_C: 95
                # Set HWP energy performance hints to 'performance' on high load (EXPERIMENTAL)
                HWP_Mode: True
                # Set cTDP to normal=0, down=1 or up=2 (EXPERIMENTAL)
                cTDP: 0
                # Disable BDPROCHOT (EXPERIMENTAL)
                Disable_BDPROCHOT: False
            '';
        };
        logind.killUserProcesses = true;
        gnome3.at-spi2-core.enable = lib.mkForce false;
        gnome3.gnome-keyring.enable = lib.mkForce false;
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
        fontDir.enable = true;
        fonts = with pkgs; [
            hasklig
            ibm-plex
            font-awesome
        ];
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
    };

    # List packages installed in system profile.
    environment.systemPackages = with pkgs; [
    # Basic software
        curl
        git
        ix
        imv
        brightnessctl
        gnupg
        unzip
        zip
        unrar
        file
        jq
        lm_sensors
        pciutils
        usbutils
        iwd
        dnscrypt-proxy2
        dex
        playerctl                       # mpris
        neovim
        tmux
        # vimPlugins.vim-plug
        # aria2
        neofetch
        htop
        alacritty                      # Terminal

    # Libraries
        libarchive

    # System customization
        bibata-cursors
        papirus-icon-theme
        breeze-gtk

    # Audio
        lxqt.pavucontrol-qt
        pamixer
        ladspaPlugins

    # User software
        # kotatogram-desktop             # TG-desktop fork
        ark
        tdesktop
        firefox-wayland
        pantheon.elementary-calculator  # Calculator
        mpv
        youtube-dl-light
        vscodium
        #mate.caja
        fzf                             # FZF
        #steam
        #steam-run-native
        #lutris
        #SDL2

    # Nix/NixOS stuff
        nix-index

    # Rust written replacement
        uutils-coreutils
        amp
        sd
        du-dust
        watchexec
        tokei
        ripgrep
        fd
        skim
        bat                            # better cat
        exa
        gitAndTools.delta

    # File system
        #ntfs3g
        go-mtpfs
        sshfs

    # Development
        #gcc-unwrapped.lib
        #gdb
        #autoPatchelfHook
        #patchelf
        shellcheck

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
        LIBVA_DRIVER_NAME = "i965";
        NO_AT_BRIDGE = "1";
    };

    programs = {
        qt5ct.enable = true;
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
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
        jack.enable = false;
    };
    # nixpkgs.config.pulseaudio = true;

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
        displayManager = {
            sddm.enable = false;
            autoLogin.enable = true;
            autoLogin.user = "etircopyh";
        };
        desktopManager.plasma5.enable = false;
    };

    # users.mutableUsers = false;

    services.mingetty.autologinUser = "etircopyh";
    nixpkgs.config = {
        allowUnfree = true;
        allowBroken = true;
        packageOverrides = pkgs: {
            nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
                inherit pkgs;
            };
        };
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
    system.stateVersion = "20.03";
}

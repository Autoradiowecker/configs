# * Edit this configuration file to define what should be installed on
# * your system.  Help is available in the configuration.nix(5) man page
# * and in the NixOS manual (accessible by running ‘nixos-help’).

#  useful commands
#  sudo nixos-rebuild switch -I nixos-config=/home/clemensguenther/repos/configsLaptop/configuration.nix --upgrade
#  nix-collect-garbage

{ config, pkgs, ... }:

let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz";
  autostartPrograms = [ pkgs.firefox pkgs.thunderbird pkgs.discord pkgs.fish pkgs.vscode ]; #https://github.com/nix-community/home-manager/issues/3447
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelParams = ["quiet"];
  #boot.plymouth.enable = true; 
  #boot.plymouth.theme="breeze"; #breeze theme is ugly. Dont want to look how to change it right now
  

  #gives fish nix directorys
  programs.fish.enable = true;
  programs.fish.shellAliases = {
    copy = "cp";
    egrep = "egrep --color=auto";
    explorer = "xdg-open";
    fgrep = "fgrep --color=auto";
    grep = "grep --color=auto";
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
    lisa = "ls -lisa";
    move = "mv";
  };
  programs.fish.shellInit = 
    "neofetch";
  

  networking.hostName = "clemensLaptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "amdgpu" ];
  # maybe enable southen islands?? see https://nixos.wiki/wiki/AMD_GPU

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  environment.gnome.excludePackages = with pkgs.gnome; [
    cheese      # photo booth
    eog         # image viewer
    epiphany    # web browser
    evince      # document viewer
    geary       # email client
    seahorse    # password manager
    simple-scan # document scanner
    totem       # video player
    yelp        # help viewer

    #baobab      # disk usage analyzer
    #file-roller # archive manager
    #gedit       # text editor
    #gnome-calculator gnome-calendar gnome-characters gnome-clocks gnome-contacts
    #gnome-font-viewer gnome-logs gnome-maps gnome-music gnome-photos gnome-screenshot
    #gnome-system-monitor gnome-weather gnome-disk-utility pkgs.gnome-connections
  ];

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "de";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "de";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  system.copySystemConfiguration = true;  
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  #standard Shell to fish
  programs.bash = {
  interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.clemensguenther = {
    isNormalUser = true;
    description = "Clemens Günther";
    extraGroups = [ "networkmanager" "wheel" "vboxusers" "docker"];
    packages = with pkgs; [
      firefox
	    thunderbird
    ];
  };
  
  home-manager.users.clemensguenther = {

    programs.git = {
      enable = true;
      userName  = "Autoradiowecker";
      userEmail = "clemens-g@gmx.de";
    };

    home.file = builtins.listToAttrs (map #https://github.com/nix-community/home-manager/issues/3447
      (pkg:
        {
          name = ".config/autostart/" + pkg.pname + ".desktop";
          value =
            if pkg ? desktopItem then {
              # Application has a desktopItem entry. 
              # Assume that it was made with makeDesktopEntry, which exposes a
              # text attribute with the contents of the .desktop file
              text = pkg.desktopItem.text;
            } else {
              # Application does *not* have a desktopItem entry. Try to find a
              # matching .desktop name in /share/apaplications
              source = (pkg + "/share/applications/" + pkg.pname + ".desktop");
            };
        })
      autostartPrograms);

    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";
  };

  nixpkgs.config = {
    allowUnfree = true; # Allow unfree packages
  packageOverrides = pkgs: { #Add unstable Packages
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };
  
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];  # Allow flakes
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  brave
    bottles 
    #cups-kyocera
    caffeine-ng
    copyq # env QT_QPA_PLATFORM=xcb copyq
    discord
    drawio
    elixir
    #etcher #deprecated 2024-06 (uses EOL electron)
    filezilla 
    fish
    # flatpak
    git
    gnome.gnome-tweaks
    gnomeExtensions.pop-shell
    gsmartcontrol # ! doesnt work
    jetbrains.rider
    libarchive
    libnvme # ! ???
    libreoffice
    linuxConsoleTools
    # libzbd # ! ??? 
    lutris
    memtest86-efi # ! doesnt work 
    neofetch
    openssl
    pavucontrol
    # pgadmin4
    postman #cant download package
    space-cadet-pinball
    smartmontools
    spotify
    steam
    unstable.stepmania
    # unstable.gnome.zenity
    unstable.livebook #start cmd livebook server
    unzip
    # virtualbox https://discourse.nixos.org/t/virtualbox-kernel-driver-not-accessible/18629 TLDR: virtual box is enabled by virtualisation.virtualbox.host.enable = true;
    vlc
    vscode
    winetricks
    wineWowPackages.stable
    yt-dlp
  ];           

virtualisation.docker.enable = true;
virtualisation.virtualbox.guest.enable = true;
virtualisation.virtualbox.host.enable = true;
virtualisation.virtualbox.host.enableExtensionPack = true;

#Power Management
powerManagement.enable = true;
services.thermald.enable = true;
services.auto-cpufreq.enable = true;
services.auto-cpufreq.settings = {
  battery = {
     governor = "powersave";
     turbo = "never";
  };
  charger = {
     governor = "performance";
     turbo = "auto";
  };
};
powerManagement.powertop.enable = true; # maybe makes usb Devices unresponsive

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;

  # Open ports in the firewall.
   networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

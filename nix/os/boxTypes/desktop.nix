#
# NixOS config for desktops machines, with GUI stuff.
#

{ config, pkgs, ... }: {

  system.stateVersion = "16.09";

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    support32Bit = true; # needed for Steam
  };

  hardware.bluetooth.enable = false;

  hardware.opengl.driSupport32Bit = true; # needed for Steam

  networking = {
    networkmanager.enable = true;
    #nameservers = [ "8.8.8.8" "8.8.4.4" ];
    nameservers = [ "208.67.222.222" "208.67.220.220" ];
    firewall.allowPing = true;
    firewall.allowedTCPPorts = [
      51413 # bittorrent
    ];
  };

  i18n.consoleFont = "Lat2-Terminus16";
  i18n.consoleKeyMap = "us";

  #time.timeZone = "America/Los_Angeles"; # Pacific
  #time.timeZone = "America/Denver"; # Mountain
  #time.timeZone = "America/Chicago"; # Central
  time.timeZone = "America/New_York"; # Eastern

  environment.etc."fuse.conf".text = ''
    user_allow_other
  '';

  environment.systemPackages = with pkgs; [
    android-udev-rules curl docker emacs
    gparted gptfdisk htop lsof man_db
    openssl tree vim wget which
  ];

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish.enable = true;
    publish.addresses = true;
  };

  services.nixosManual.showManual = true;

  services.printing = {
    enable = false;
    drivers = with pkgs; [ gutenprint hplipWithPlugin ];
  };

  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.gnome3.enable = true;
    windowManager.xmonad.enable  = false;
    displayManager.gdm.enable    = true;
    autoRepeatDelay    = 250;
    autoRepeatInterval =  50;
  };

  services.unclutter.enable = false;

  systemd.user.services.emacs = {

    description = "Emacs Daemon";

    environment = {
      GTK_DATA_PREFIX = config.system.path;
      SSH_AUTH_SOCK   = "%t/ssh-agent";
      GTK_PATH        = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
      NIX_PROFILES    = "${pkgs.lib.concatStringsSep " " config.environment.profiles}";
      TERMINFO_DIRS   = "/run/current-system/sw/share/terminfo";
      ASPELL_CONF     = "dict-dir /run/current-system/sw/lib/aspell";
    };

    serviceConfig = {
      Type      = "forking";
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; emacs --daemon --no-desktop'";
      ExecStop  = "${pkgs.emacs}/bin/emacsclient --eval '(kill-emacs)'";
      Restart   = "always";
    };

    wantedBy = [ "default.target" ];
  };

  systemd.services.emacs.enable = true;

  virtualisation.virtualbox.host = {
    enable              = false;
    enableHardening     = false;
    addNetworkInterface = true;
  };

  virtualisation.docker = {
    enable        = false;
    storageDriver = "devicemapper";
  };

  fonts = {
    enableFontDir          = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts lato inconsolata symbola ubuntu_font_family
      unifont vistafonts
    ];
  };

  users.extraUsers.chris = {
    isNormalUser = true;
    description = "Chris Martin";
    extraGroups = [
      "audio" "disk" "docker" "networkmanager" "plugdev"
      "systemd-journal" "wheel" "vboxusers" "video"
    ];
    uid = 1000;
  };

  # Yubikey
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0402|0403|0406|0407|0410", TAG+="uaccess"
  '';

  # https://stackoverflow.com/questions/33180784
  nix.extraOptions = "binary-caches-parallel-connections = 5";

}

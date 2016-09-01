#
# Renzo is a Dell XPS 13 non-touch, circa early 2016.
#

{ config, pkgs, ... }: {

  imports = [ ../boxTypes/desktop.nix ];

  boot = {
    initrd.luks.devices = [{
      name   = "root";
      device = "/dev/nvme0n1p3";
      preLVM = true;
    }];
    loader = {
      grub.device = "/dev/nvme0n1";
      gummiboot.enable = false;
    };
    kernelPackages = pkgs.linuxPackages_4_4;
    kernelModules  = ["snd-hda-intel"];
    extraKernelParams = ["pci=nocrs"];
    cleanTmpDir = true;
  };

  nixpkgs.config.virtualbox.enableExtensionPack =
    let _ = pkgs.fetchurl {
      url = "http://download.virtualbox.org/virtualbox/5.0.26/Oracle_VM_VirtualBox_Extension_Pack-5.0.26-108824.vbox-extpack";
      sha256 = "015id31c4qs0nzpf7xii7kfcr3dhdrx7drz8iwjs201xpb3h48rg";
    }; in true;

  services.redshift = { enable = true; } //
    config.nixpkgs.config.locations.atlanta;

  services.xserver.synaptics = {
    enable      = true;
    minSpeed    = "0.8";
    maxSpeed    = "1.4";
    accelFactor = "0.05";
  };

  #services.xserver.videoDrivers = [ "displaylink" "modesetting" ];

  environment.etc."modprobe.d/alsa-base.conf".text = ''
    options snd-hda-intel index=1 model=dell-headset-multi
    options snd-hda-intel index=0 model=auto vid=8086 pid=9d70
  '';
}

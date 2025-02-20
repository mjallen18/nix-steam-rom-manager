# Steam Rom Manager NixOS Home Manager Configuration

## Usage

### Nix Flake
Inputs: steam-rom-manager.url = "github:mjallen18/nix-steam-rom-manager";
~~~
nixosConfigurations = {
  "<hostname>" = nixpkgs-unstable.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      home-manager.nixosModules.home-manager
      {
        home-manager.users.<username> = { pkgs, ...}: {
          imports = [ 
            steam-rom-manager.homeManagerModules.default
          ];
        };
      }
    ];
  };
};
~~~

### Configuration
~~~
programs.steam-rom-manager = {
  enable = true;
  steamUsername = "<steam username>";
  
  environmentVariables = {
    romsDirectory = "/path/to/your/roms";
    steamDirectory = "/home/<username>/.local/share/Steam";
  };

  emulators = {
    ryujinx = {
      enable = true;
    };
    pcsx2 = {
      enable = true;
    };
    # Add other emulators as needed
  };
};
~~~
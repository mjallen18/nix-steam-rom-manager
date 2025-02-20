# Steam Rom Manager NixOS Home Manager Configuration

## Usage

### Nix Flake
* Inputs: steam-rom-manager.url = "github:mjallen18/nix-steam-rom-manager";
* ```nixosConfigurations = {
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
    };```
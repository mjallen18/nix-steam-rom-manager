{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.steam-rom-manager;
in {
  options.programs.steam-rom-manager = {
    enable = mkEnableOption "Steam ROM Manager";
    
    package = mkOption {
      type = types.package;
      default = steam-rom-manager;
      description = "Steam ROM Manager package";
    };

    fuzzyMatcher = {
      timestamps = {
        check = mkOption {
          type = types.int;
          default = 0;
          description = "Timestamp for fuzzy matcher check";
        };
        download = mkOption {
          type = types.int;
          default = 0;
          description = "Timestamp for fuzzy matcher download";
        };
      };
      verbose = mkOption {
        type = types.bool;
        default = false;
        description = "Enable verbose logging for fuzzy matcher";
      };
      filterProviders = mkOption {
        type = types.bool;
        default = true;
        description = "Filter image providers";
      };
    };

    environmentVariables = {
      steamDirectory = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/.local/share/Steam";
        description = "Steam installation directory";
      };

      romsDirectory = mkOption {
        type = types.str;
        default = "${config.home.homeDirectory}/Emulation/roms";
        description = "Base directory for ROM files";
      };

      retroarchPath = mkOption {
        type = types.str;
        default = "";
        description = "Path to RetroArch executable";
      };

      raCoresDirectory = mkOption {
        type = types.str;
        default = "";
        description = "RetroArch cores directory";
      };

      localImagesDirectory = mkOption {
        type = types.str;
        default = "";
        description = "Directory for local images";
      };
    };

    previewSettings = {
      retrieveCurrentSteamImages = mkOption {
        type = types.bool;
        default = true;
        description = "Retrieve current Steam images";
      };

      disableCategories = mkOption {
        type = types.bool;
        default = false;
        description = "Disable Steam categories";
      };

      deleteDisabledShortcuts = mkOption {
        type = types.bool;
        default = false;
        description = "Delete disabled shortcuts";
      };

      imageZoomPercentage = mkOption {
        type = types.int;
        default = 30;
        description = "Image zoom percentage in preview";
      };

      preload = mkOption {
        type = types.bool;
        default = false;
        description = "Preload images";
      };

      hideUserAccount = mkOption {
        type = types.bool;
        default = false;
        description = "Hide user account in preview";
      };
    };

    enabledProviders = mkOption {
      type = types.listOf types.str;
      default = [ "sgdb" "steamCDN" ];
      description = "Enabled image providers";
    };

    imageProviderSettings = {
      sgdb = {
        nsfw = mkOption {
          type = types.bool;
          default = false;
          description = "Allow NSFW content from SteamGridDB";
        };

        humor = mkOption {
          type = types.bool;
          default = false;
          description = "Allow humor content from SteamGridDB";
        };

        styles = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Preferred art styles for SteamGridDB";
        };

        stylesHero = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Preferred hero art styles for SteamGridDB";
        };

        stylesLogo = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Preferred logo styles for SteamGridDB";
        };

        stylesIcon = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Preferred icon styles for SteamGridDB";
        };

        imageMotionTypes = mkOption {
          type = types.listOf types.str;
          default = [ "static" ];
          description = "Allowed image motion types";
        };

        sizes = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Preferred image sizes";
        };

        sizesHero = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Preferred hero image sizes";
        };

        sizesIcon = mkOption {
          type = types.listOf types.str;
          default = [];
          description = "Preferred icon sizes";
        };
      };
    };

    batchDownloadSize = mkOption {
      type = types.int;
      default = 50;
      description = "Number of images to download in a batch";
    };

    dnsServers = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Custom DNS servers for image downloads";
    };

    language = mkOption {
      type = types.str;
      default = "en-US";
      description = "Application language";
    };

    theme = mkOption {
      type = types.str;
      default = "Deck";
      description = "Application theme";
    };

    emudeckInstall = mkOption {
      type = types.bool;
      default = false;
      description = "Is this an EmuDeck installation";
    };

    autoUpdate = mkOption {
      type = types.bool;
      default = false;
      description = "Enable automatic updates";
    };

    offlineMode = mkOption {
      type = types.bool;
      default = false;
      description = "Run in offline mode";
    };

    navigationWidth = mkOption {
      type = types.int;
      default = 0;
      description = "Navigation panel width";
    };

    clearLogOnTest = mkOption {
      type = types.bool;
      default = true;
      description = "Clear log when testing configuration";
    };

    steamUsername = mkOption {
      type = types.str;
      description = "Steam username for configuration";
    };

    emulators = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options = {
          enable = mkEnableOption "emulator configuration";
          package = mkOption {
            type = types.package;
            default = 
              if name == "pcsx2" then pkgs.pcsx2
              else if name == "citra" then pkgs.citra-nightly
              else if name == "yuzu" then pkgs.yuzu
              else if name == "ryujinx" then pkgs.ryujinx-greemdev
              else if name == "rpcs3" then pkgs.rpcs3
              else if name == "dolphin-emu" then pkgs.dolphinEmu
              else if name == "duckstation" then pkgs.duckstation
              else if name == "melonDS" then pkgs.melonDS
              else if name == "cemu" then pkgs.cemu
              else if name == "ppsspp" then pkgs.ppsspp
              else if name == "mame" then pkgs.mame
              else if name == "dosbox" then pkgs.dosbox
              else if name == "snes9x" then pkgs.snes9x-gtk
              else if name == "mgba" then pkgs.mgba
              else if name == "mupen64plus" then pkgs.mupen64plus
              else if name == "retroarch" then pkgs.retroarch
              else if name == "flycast" then pkgs.flycast
              else pkgs.${name};
            description = "Emulator package";
          };
          romFolder = mkOption {
            type = types.str;
            default = "";
            description = "Name of the ROM folder (defaults to common configuration)";
          };
          fileTypes = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "List of ROM file types (defaults to common configuration)";
          };
          extraArgs = mkOption {
            type = types.str;
            default = "--fullscreen \"\${filePath}\"";
            description = "Additional emulator arguments";
          };
        };
      }));
      default = {};
      description = "Emulator configurations";
    };
  };
}
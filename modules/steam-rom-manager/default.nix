{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.steam-rom-manager;

  # Function to find the main binary in a package
  findMainBinary = pkg:
    let
      pkgName = pkg.pname or (builtins.parseDrvName pkg.name).name;
      
      commonVariants = [
        pkgName
        "${pkgName}-qt"
        "${pkgName}-gtk"
        "${pkgName}-emu"
        "Ryujinx"
      ];
      
      existingVariant = findFirst 
        (variant: builtins.pathExists "${pkg}/bin/${variant}") 
        null 
        commonVariants;
    in
      if existingVariant != null 
      then existingVariant
      else pkgName;

  # Common emulator configurations with default packages
  commonEmulatorConfigs = {
    ryujinx = {
      romFolder = "switch";
      fileTypes = [ ".nca" ".NCA" ".nro" ".NRO" ".nso" ".NSO" ".nsp" ".NSP" ".xci" ".XCI" ];
      package = pkgs.ryujinx;
    };
    yuzu = {
      romFolder = "switch";
      fileTypes = [ ".nsp" ".NSP" ".xci" ".XCI" ];
      package = pkgs.yuzu;
    };
    pcsx2 = {
      romFolder = "ps2";
      fileTypes = [ ".iso" ".ISO" ".bin" ".BIN" ".chd" ".CHD" ];
      package = pkgs.pcsx2;
    };
    rpcs3 = {
      romFolder = "ps3";
      fileTypes = [ ".iso" ".ISO" ".bin" ".BIN" ".pkg" ".PKG" ];
      package = pkgs.rpcs3;
    };
    dolphin-emu = {
      romFolder = "gc";
      fileTypes = [ ".iso" ".ISO" ".gcm" ".GCM" ".ciso" ".CISO" ];
      package = pkgs.dolphin-emu;
    };
    duckstation = {
      romFolder = "psx";
      fileTypes = [ ".iso" ".ISO" ".bin" ".BIN" ".chd" ".CHD" ".pbp" ".PBP" ];
      package = pkgs.duckstation;
    };
    melonDS = {
      romFolder = "nds";
      fileTypes = [ ".nds" ".NDS" ];
      package = pkgs.melonDS;
    };
    cemu = {
      romFolder = "wiiu";
      fileTypes = [ ".wud" ".WUD" ".wux" ".WUX" ".rpx" ".RPX" ];
      package = pkgs.cemu;
    };
    ppsspp = {
      romFolder = "psp";
      fileTypes = [ ".iso" ".ISO" ".cso" ".CSO" ".pbp" ".PBP" ];
      package = pkgs.ppsspp;
    };
    mame = {
      romFolder = "arcade";
      fileTypes = [ ".zip" ".ZIP" ".7z" ".7Z" ];
      package = pkgs.mame;
    };
    dosbox = {
      romFolder = "dos";
      fileTypes = [ ".exe" ".EXE" ".bat" ".BAT" ".com" ".COM" ];
      package = pkgs.dosbox;
    };
    snes9x = {
      romFolder = "snes";
      fileTypes = [ ".smc" ".SMC" ".sfc" ".SFC" ".fig" ".FIG" ];
      package = pkgs.snes9x-gtk;
    };
    mgba = {
      romFolder = "gba";
      fileTypes = [ ".gba" ".GBA" ];
      package = pkgs.mgba;
    };
    mupen64plus = {
      romFolder = "n64";
      fileTypes = [ ".n64" ".N64" ".v64" ".V64" ".z64" ".Z64" ];
      package = pkgs.mupen64plus;
    };
    retroarch = {
      romFolder = "retroarch";
      fileTypes = [ ".zip" ".ZIP" ".7z" ".7Z" ".iso" ".ISO" ".bin" ".BIN" ".chd" ".CHD" ];
      package = pkgs.retroarch;
    };
    flycast = {
      romFolder = "dreamcast";
      fileTypes = [ ".gdi" ".GDI" ".cdi" ".CDI" ".chd" ".CHD" ];
      package = pkgs.flycast;
    };
    citra = {
      romFolder = "3ds";
      fileTypes = [ ".3ds" ".3DS" ".cia" ".CIA" ".cxi" ".CXI" ];
      package = pkgs.citra-nightly;
    };
  };

  # Create parser configuration
  mkParserConfig = name: emu: 
  let
    # Use the provided package or fall back to the default if available
    package = emu.package;
    # Get the binary name dynamically
    binaryName = findMainBinary package;
    
    orderedConfig = [
      # Basic parser configuration
      { name = "parserType"; value = "Glob"; }
      { name = "configTitle"; value = name; }
      { name = "steamDirectory"; value = "\${steamdirglobal}"; }
      { name = "romDirectory"; value = "${cfg.environmentVariables.romsDirectory}/${if emu.romFolder != "" then emu.romFolder else commonEmulatorConfigs.${name}.romFolder}"; }
      { name = "steamCategories"; value = [""]; }
      
      # Executable configuration
      { name = "executableArgs"; value = emu.extraArgs; }
      { name = "executableModifier"; value = "\"\${exePath}\""; }
      { name = "startInDirectory"; value = "${cfg.environmentVariables.romsDirectory}/${if emu.romFolder != "" then emu.romFolder else commonEmulatorConfigs.${name}.romFolder}"; }
      { name = "titleModifier"; value = "\${fuzzyTitle}"; }
      
      # Controller settings
      { name = "fetchControllerTemplatesButton"; value = null; }
      { name = "removeControllersButton"; value = null; }
      { name = "steamInputEnabled"; value = "1"; }
      
      # Image provider configuration
      { name = "imageProviders"; value = cfg.enabledProviders; }
      { name = "onlineImageQueries"; value = [ "\${fuzzyTitle}" ]; }
      { name = "imagePool"; value = "\${fuzzyTitle}"; }
      
      # DRM and user account settings
      { name = "drmProtect"; value = false; }
      { name = "userAccounts"; value = {
        specifiedAccounts = [ "Global" ];
      }; }
      
      # Parser-specific settings
      { name = "parserInputs"; value = {
        glob = "\${title}@(${concatStringsSep "|" (if emu.fileTypes != [] then emu.fileTypes else commonEmulatorConfigs.${name}.fileTypes)})";
      }; }
      
      # Executable details
      { name = "executable"; value = {
        path = "${package}/bin/${binaryName}";
        shortcutPassthrough = false;
        appendArgsToExecutable = true;
      }; }
      
      # Title and fuzzy matching configuration
      { name = "titleFromVariable"; value = {
        limitToGroups = [];
        caseInsensitiveVariables = false;
        skipFileIfVariableWasNotFound = false;
      }; }
      
      { name = "fuzzyMatch"; value = {
        replaceDiacritics = true;
        removeCharacters = true;
        removeBrackets = true;
      }; }
      
      # Controller configuration
      { name = "controllers"; value = {
        ps4 = null;
        ps5 = null;
        ps5_edge = null;
        xbox360 = null;
        xboxone = null;
        xboxelite = null;
        switch_joycon_left = null;
        switch_joycon_right = null;
        switch_pro = null;
        neptune = null;
        steamcontroller_gordon = null;
      }; }
      
      # Image provider API configuration
      { name = "imageProviderAPIs"; value = {
        sgdb = cfg.imageProviderSettings.sgdb;
      }; }
      
      # Default and local image settings
      { name = "defaultImage"; value = {
        tall = "";
        long = "";
        hero = "";
        logo = "";
        icon = "";
      }; }
      
      { name = "localImages"; value = {
        tall = "";
        long = "";
        hero = "";
        logo = "";
        icon = "";
      }; }
      
      # Parser identification
      { name = "parserId"; value = name; }
      { name = "version"; value = 25; }
    ];
    
    # Function to convert our ordered list into properly formatted JSON
    makeOrderedJSON = pairs:
      let
        joined = builtins.concatStringsSep "," 
          (map (pair: "\"${pair.name}\":${builtins.toJSON pair.value}") pairs);
      in
      "{${joined}}";
  in
    makeOrderedJSON orderedConfig;

  # Fetch the SVG icon file
  steam-rom-manager-icon = pkgs.fetchurl {
    name = "steam-rom-manager.svg";
    url = "https://raw.githubusercontent.com/SteamGridDB/steam-rom-manager/master/src/assets/icons/steam-rom-manager.svg";
    hash = "sha256-DKzNIs5UhIWAVRTfinvCb8WqeDniPWw9Z08/p/Zpa9E=";
  };

  # # Create Steam ROM Manager package
  steam-rom-manager-appimage = pkgs.writeShellScriptBin "steam-rom-manager" ''
  exec ${pkgs.appimage-run}/bin/appimage-run ${pkgs.fetchurl {
    name = "steam-rom-manager-2.5.29.AppImage";
    url = "https://github.com/SteamGridDB/steam-rom-manager/releases/download/v2.5.29/Steam-ROM-Manager-2.5.29.AppImage";
    hash = "sha256-6ZJ+MGIgr2osuQuqD6N9NnPiJFNq/HW6ivG8tyXUhvs=";
  }} "$@"
'';

in {
  imports = [
    ./options.nix
  ];

  config = mkIf cfg.enable {
    home.packages = [ pkgs.appimage-run steam-rom-manager-appimage ]
      ++ mapAttrsToList (_: v: v.package) (filterAttrs (_: v: v.enable) cfg.emulators);

    xdg.dataFile = {
      "icons/hicolor/scalable/apps/steam-rom-manager.svg".source = steam-rom-manager-icon;
    };

    xdg.desktopEntries.steam-rom-manager = {
      name = "Steam ROM Manager";
      exec = "${steam-rom-manager-appimage}/bin/steam-rom-manager";
      icon = "steam-rom-manager";
      categories = [ "Game" "Utility" ];
      type = "Application";
      terminal = false;
      comment = "Add ROMs to Steam with artwork";
      settings = {
        "X-KDE-StartupNotify" = "true";
        "X-KDE-SubstituteUID" = "false";
        "X-DBUS-StartupType" = "Unique";
      };
    };

    xdg.configFile = {
      "steam-rom-manager/userData/userSettings.json".text = builtins.toJSON {
        fuzzyMatcher = {
          timestamps = {
            check = cfg.fuzzyMatcher.timestamps.check;
            download = cfg.fuzzyMatcher.timestamps.download;
          };
          verbose = cfg.fuzzyMatcher.verbose;
          filterProviders = cfg.fuzzyMatcher.filterProviders;
        };
        environmentVariables = {
          steamDirectory = cfg.environmentVariables.steamDirectory;
          userAccounts = "\${${cfg.steamUsername}}";
          romsDirectory = cfg.environmentVariables.romsDirectory;
          retroarchPath = cfg.environmentVariables.retroarchPath;
          raCoresDirectory = cfg.environmentVariables.raCoresDirectory;
          localImagesDirectory = cfg.environmentVariables.localImagesDirectory;
        };
        previewSettings = cfg.previewSettings;
        enabledProviders = cfg.enabledProviders;
        imageProviderAPIs = {
          sgdb = cfg.imageProviderSettings.sgdb;
        };
        batchDownloadSize = cfg.batchDownloadSize;
        dnsServers = cfg.dnsServers;
        language = cfg.language;
        theme = cfg.theme;
        emudeckInstall = cfg.emudeckInstall;
        autoUpdate = cfg.autoUpdate;
        offlineMode = cfg.offlineMode;
        navigationWidth = cfg.navigationWidth;
        clearLogOnTest = cfg.clearLogOnTest;
        version = 8;
      };

      "steam-rom-manager/userData/userConfigurations.json".text = 
      let
        configs = mapAttrsToList (name: emu: 
          mkParserConfig name (emu // {
            romFolder = if emu.romFolder != "" then emu.romFolder else commonEmulatorConfigs.${name}.romFolder;
            # binaryName = if emu.binaryName != "" then emu.binaryName else commonEmulatorConfigs.${name}.binaryName;
          })
        ) (filterAttrs (_: v: v.enable) cfg.emulators);
        
        configsJson = "[${concatStringsSep "," configs}]";
      in
      configsJson;
    };
  };
}
{
  pkgs,
  lib,
  config,
  ...
}: let
  # Apps that should get real F1-F12 instead of media keys. Edit this file
  # (or use the Hammerspoon menu bar item, see ./hammerspoon.nix) to add/remove
  # apps, then `rebuild` to apply.
  fnKeyApps = builtins.fromJSON (builtins.readFile ./fn-key-apps.json);

  escapeBundleId = id: "^" + (lib.replaceStrings ["."] ["\\."] id) + "$";

  fnKeyNumbers = lib.range 1 12;

  # Physical F-row key, forced into real function-key semantics (fn+F{n})
  # regardless of the system-wide "use F1..F12 as standard function keys"
  # setting, which is otherwise what a bare press falls back to.
  fnManipulator = conditions: n: {
    type = "basic";
    from = {
      key_code = "f${toString n}";
      modifiers = {optional = ["any"];};
    };
    to = [
      {
        key_code = "f${toString n}";
        modifiers = ["fn"];
      }
    ];
    conditions = conditions;
  };

  autoFnRule = {
    description = "Force standard function keys in listed apps (see fn-key-apps.json)";
    manipulators =
      map (fnManipulator [
        {
          type = "frontmost_application_if";
          bundle_identifiers = map (a: escapeBundleId a.bundleId) fnKeyApps;
        }
      ])
      fnKeyNumbers;
  };

  forceFnRule = {
    description = "Force standard function keys everywhere (manual override profile)";
    manipulators = map (fnManipulator []) fnKeyNumbers;
  };

  baseRules = [
    {
      description = "Ctrl + Left Click to Left Click";
      manipulators = [
        {
          type = "basic";
          from = {
            pointing_button = "button1";
            modifiers = {
              mandatory = ["left_control"];
              optional = ["caps_lock"];
            };
          };
          to = [
            {pointing_button = "button1";}
            {key_code = "left_control";}
          ];
        }
      ];
    }
    {
      description = "Caps Lock -> LeftCommand+Control+Shift+Option, Caps Lock -> Escape (if held alone for > 150 ms)";
      manipulators = [
        {
          type = "basic";
          from = {
            key_code = "caps_lock";
            modifiers = {optional = ["any"];};
          };
          to = [
            {
              key_code = "left_shift";
              modifiers = ["left_option" "left_command" "left_control"];
            }
          ];
          to_if_alone = [
            {
              key_code = "escape";
              hold_down_milliseconds = 150;
            }
          ];
        }
      ];
    }
    {
      description = "Right command => Right commmand, Backspace if alone";
      enabled = false;
      manipulators = [
        {
          type = "basic";
          from = {
            key_code = "right_command";
            modifiers = {optional = ["any"];};
          };
          parameters = {"basic.to_if_alone_threshold_milliseconds" = 100;};
          to = [{key_code = "right_command";}];
          to_if_alone = [{key_code = "delete_or_backspace";}];
        }
      ];
    }
  ];

  baseDevices = [
    {
      identifiers = {
        is_keyboard = true;
        product_id = 71;
        vendor_id = 9494;
      };
      simple_modifications = [
        {
          from = {key_code = "left_command";};
          to = [{key_code = "left_option";}];
        }
        {
          from = {key_code = "left_option";};
          to = [{key_code = "left_command";}];
        }
      ];
    }
    {
      identifiers = {
        is_keyboard = true;
        product_id = 59;
        vendor_id = 9494;
      };
      simple_modifications = [
        {
          from = {key_code = "left_command";};
          to = [{key_code = "left_option";}];
        }
        {
          from = {key_code = "left_option";};
          to = [{key_code = "left_command";}];
        }
      ];
    }
    {
      identifiers = {is_keyboard = true;};
      simple_modifications = [
        {
          from = {apple_vendor_top_case_key_code = "keyboard_fn";};
          to = [{key_code = "left_control";}];
        }
        {
          from = {key_code = "grave_accent_and_tilde";};
          to = [{apple_vendor_top_case_key_code = "keyboard_fn";}];
        }
        {
          from = {key_code = "left_control";};
          to = [{apple_vendor_top_case_key_code = "keyboard_fn";}];
        }
        {
          from = {key_code = "non_us_backslash";};
          to = [{key_code = "grave_accent_and_tilde";}];
        }
      ];
    }
    {
      identifiers = {
        is_keyboard = true;
        product_id = 787;
        vendor_id = 13364;
      };
      simple_modifications = [
        {
          from = {key_code = "non_us_backslash";};
          to = [{apple_vendor_top_case_key_code = "keyboard_fn";}];
        }
      ];
    }
    {
      identifiers = {
        is_keyboard = true;
        product_id = 4640;
        vendor_id = 12771;
      };
      simple_modifications = [
        {
          from = {key_code = "left_command";};
          to = [{key_code = "left_option";}];
        }
        {
          from = {key_code = "left_option";};
          to = [{key_code = "left_command";}];
        }
        {
          from = {key_code = "non_us_backslash";};
          to = [{apple_vendor_top_case_key_code = "keyboard_fn";}];
        }
      ];
    }
    {
      identifiers = {
        is_pointing_device = true;
        product_id = 64160;
        vendor_id = 9639;
      };
      ignore = false;
      ignore_vendor_events = true;
      simple_modifications = [
        {
          from = {pointing_button = "button4";};
          to = [{pointing_button = "button31";}];
        }
      ];
    }
    {
      identifiers = {
        is_keyboard = true;
        is_pointing_device = true;
        product_id = 24926;
        vendor_id = 7504;
      };
      ignore = false;
      manipulate_caps_lock_led = false;
    }
  ];

  mkProfile = {
    name,
    selected,
    fnRule,
  }: {
    inherit name selected;
    virtual_hid_keyboard = {keyboard_type_v2 = "ansi";};
    complex_modifications = {rules = baseRules ++ [fnRule];};
    devices = baseDevices;
  };

  karabinerSettings = {
    global = {
      show_in_menu_bar = false;
    };
    profiles = [
      (mkProfile {
        name = "Default profile";
        selected = true;
        fnRule = autoFnRule;
      })
      (mkProfile {
        name = "Force Function Keys";
        selected = false;
        fnRule = forceFnRule;
      })
    ];
  };

  karabinerJson = (pkgs.formats.json {}).generate "karabiner.json" karabinerSettings;
in {
  # Karabiner Elements writes back to karabiner.json at runtime (profile
  # switches, GUI toggles, machine_specific entries), so it can't be a
  # read-only nix-store symlink. Instead, copy the generated file into place
  # on every activation so nix stays the source of truth on rebuild, while
  # the file remains writable in between.
  home.activation.karabinerConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run mkdir -p "${config.xdg.configHome}/karabiner"
    run cp -f ${karabinerJson} "${config.xdg.configHome}/karabiner/karabiner.json"
  '';
}

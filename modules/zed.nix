{ ... }:
{
  home-manager.users.alexp =
    { pkgs, ... }:
    {
      programs.zed-editor = {
        enable = true;

        # On Zed's PATH so it uses these instead of downloading its own binaries.
        extraPackages = with pkgs; [
          nixd
          nixfmt
          clang-tools
          basedpyright
          ruff
          lua-language-server
          stylua
          rumdl
          direnv
        ];

        extensions = [
          "nix"
          "lua"
          "tokyo-night"
          "toml"
          "just"
        ];

        userSettings = {
          vim_mode = true;
          vim = {
            use_system_clipboard = "always";
            use_smartcase_find = true;
          };
          which_key.enabled = true;

          theme = {
            mode = "dark";
            dark = "Tokyo Night Moon";
            light = "Tokyo Night Light";
          };
          theme_overrides."Tokyo Night Moon" =
            let
              clear = "#00000000";
            in
            {
              "background.appearance" = "transparent";
              background = clear;
              "editor.background" = clear;
              "editor.gutter.background" = clear;
              "panel.background" = clear;
              "tab_bar.background" = clear;
              "tab.inactive_background" = clear;
              "title_bar.background" = clear;
              "status_bar.background" = clear;
              "toolbar.background" = clear;
              "terminal.background" = clear;
              "editor.line_number" = "#737aa2";
              "editor.active_line_number" = "#ffc777";
            };

          buffer_font_family = "JetBrainsMono Nerd Font";
          terminal.font_family = "JetBrainsMono Nerd Font";

          relative_line_numbers = "enabled";
          vertical_scroll_margin = 4;
          soft_wrap = "editor_width";
          current_line_highlight = "all";
          tab_size = 2;
          hard_tabs = false;

          inlay_hints.enabled = true;
          indent_guides.coloring = "indent_aware";

          format_on_save = "on";

          project_panel = {
            dock = "right";
            hide_gitignore = true;
          };
          tabs = {
            git_status = true;
            show_diagnostics = "errors";
          };
          git.inline_blame.enabled = false;

          restore_on_startup = "last_session";
          load_direnv = "shell_hook";

          file_types.C = [ "h" ];

          languages = {
            Nix = {
              language_servers = [ "nixd" ];
              formatter.external.command = "nixfmt";
            };
            Python = {
              language_servers = [
                "basedpyright"
                "ruff"
              ];
              # Lint autofixes first, then formatting (same order as conform).
              formatter = [
                { code_action = "source.fixAll.ruff"; }
                { language_server.name = "ruff"; }
              ];
            };
            Lua.formatter.external = {
              command = "stylua";
              arguments = [
                "--stdin-filepath"
                "{buffer_path}"
                "-"
              ];
            };
            Markdown.formatter.external = {
              command = "rumdl";
              arguments = [
                "fmt"
                "--stdin"
                "--quiet"
              ];
            };
          };
        };

        userTasks = [
          {
            label = "lazygit";
            command = "lazygit";
            use_new_terminal = true;
            allow_concurrent_runs = false;
            reveal_target = "center";
            hide = "on_success";
          }
        ];

        userKeymaps = [
          {
            context = "VimControl && !menu";
            bindings = {
              # Buffers
              "shift-h" = "pane::ActivatePreviousItem";
              "shift-l" = "pane::ActivateNextItem";
              "space b b" = "pane::AlternateFile";
              "space b d" = "pane::CloseActiveItem";
              "space b shift-d" = [
                "pane::CloseActiveItem"
                { save_intent = "skip"; }
              ];
              "space b o" = "pane::CloseOtherItems";
              "space q q" = "zed::Quit";

              # Windows
              "ctrl-h" = "workspace::ActivatePaneLeft";
              "ctrl-j" = "workspace::ActivatePaneDown";
              "ctrl-k" = "workspace::ActivatePaneUp";
              "ctrl-l" = "workspace::ActivatePaneRight";
              "space -" = "pane::SplitDown";
              "space |" = "pane::SplitRight";
              "space w d" = "pane::CloseAllItems";
              "ctrl-up" = "vim::ResizePaneUp";
              "ctrl-down" = "vim::ResizePaneDown";
              "ctrl-left" = "vim::ResizePaneLeft";
              "ctrl-right" = "vim::ResizePaneRight";

              # Move lines
              "alt-j" = "editor::MoveLineDown";
              "alt-k" = "editor::MoveLineUp";

              # Explorer
              "space e" = "project_panel::ToggleFocus";
              "space shift-e" = "pane::RevealInProjectPanel";

              # Find / search
              "space space" = "file_finder::Toggle";
              "space f r" = "projects::OpenRecent";
              "space f b" = "tab_switcher::Toggle";
              "space f g" = "file_finder::Toggle";
              "space /" = "pane::DeploySearch";
              "space s b" = "buffer_search::Deploy";
              "space s r" = [
                "pane::DeploySearch"
                { replace_enabled = true; }
              ];
              "space s c" = "command_palette::Toggle";
              "space s k" = "zed::OpenKeymap";
              "space s d" = "diagnostics::Deploy";
              "space s shift-d" = "diagnostics::Deploy";
              "space s s" = "outline::Toggle";
              "space s shift-s" = "project_symbols::Toggle";

              # Git
              "space g g" = [
                "task::Spawn"
                { task_name = "lazygit"; }
              ];
              "space g s" = "git_panel::ToggleFocus";
              "space g b" = "git::Blame";
              "space g shift-b" = "git::Switch";
              "space g d" = "git::Diff";

              # LSP (gd, gD, gy, gI, gr, K, ]d, [d are Zed vim defaults)
              "g shift-k" = "editor::ShowSignatureHelp";
              "space c a" = "editor::ToggleCodeActions";
              "space c r" = "editor::Rename";
              "space c f" = "editor::Format";
              "space c d" = "editor::Hover";
              "space c h" = "editor::SwitchSourceHeader";

              # Diagnostics
              "space x x" = "diagnostics::Deploy";
            };
          }
        ];
      };
    };
}

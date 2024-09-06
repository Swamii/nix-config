{ pkgs, username, config, ... }: {
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.11";
  home.username = username;
  home.homeDirectory = "/Users/${username}";
  home.packages = with pkgs; [
    ripgrep
    bat
    git-crypt
    gnumake
    coreutils
    curl
    less
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    parallel
  ];
  home.shellAliases = {
    nix-reload = "pushd ~/nix && home-manager switch --flake . && . ~/.config/zsh/.zshrc; popd";
    pycharm = "~/Library/Application\\ Support/JetBrains/Toolbox/scripts/pycharm";
    ls = "eza";
    ll = "eza -la";
    lt = "eza --tree";
  };
  home.sessionVariables = {
    EDITOR = "nvim";
    PIP_REQUIRE_VIRTUALENV = "true";
    PAGER = "less -FirSwX";
    DIRENV_LOG_FORMAT = "";
    LESSHISTFILE = "${config.xdg.cacheHome}/less/history";
    CLICLOLOR = 1;
  };
  home.file.".inputrc".text = ''
    set show-all-if-ambiguous on
    set completion-ignore-case on
    set mark-directories on
    set mark-symlinked-directories on
    set match-hidden-files off
    set visible-stats on
    # set keymap vi
    # set editing-mode vi-insert
  '';

  # TODO: place this somewhere else (configuration.nix?)
  # nixpkgs = {
  #   allowUnfree = true;
  #   # Workaround for https://github.com/nix-community/home-manager/issues/2942
  #   allowUnfreePredicate = (_: true);
  # };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    initExtraFirst = ''
      # Nix
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      # End Nix
    '';
    initExtra = ''
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      bindkey "^F" forward-word
      bindkey "^B" backward-word
    '';
    history = {
      expireDuplicatesFirst = true;
      extended = true;
      ignoreDups = true;
      ignorePatterns = [ "ls *" "exit" "clear" "ll" ];
      size = 5000000;
      save = 5000000;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = pkgs.lib.cleanSource ./.;
        file = "p10k.zsh";
      }
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
      {
        name = "fzf-tab";
        file = "fzf-tab.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "5a81e13792a1eed4a03d2083771ee6e5b616b9ab";
          sha256 = "dPe5CLCAuuuLGRdRCt/nNruxMrP9f/oddRxERkgm1FE=";
        };
      }
      {
        name = "wd";
        file = "wd.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "mfaerevaag";
          repo = "wd";
          rev = "v0.5.2";
          sha256 = "4yJ1qhqhNULbQmt6Z9G22gURfDLe30uV1ascbzqgdhg=";
        };
      }
    ];
  };
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    includes = [ "config.d/*" ];
    serverAliveInterval = 300;
    serverAliveCountMax = 2;
    extraConfig = ''
      AddKeysToAgent ask
      IgnoreUnknown UseKeychain
      UseKeychain yes
      IdentityFile ~/.ssh/id_rsa
      SetEnv TERM=xterm-256color
    '';
  };
  programs.git = {
    enable = true;
    userName = "Akseli Nelander";
    userEmail = "anelander@gmail.com";
    signing = {
      signByDefault = true;
      key = "0xDD5A5EFD353F0622 ";
    };
    lfs.enable = true;
    # difftastic.enable = true;
    extraConfig = {
      apply.whitespace = "fix";
      core.trustctime = false;
      core.whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
      init.defaultBranch = "main";
      github.user = "Swamii";
      pull.rebase = true;
      fetch.prune = true;
      # Correct typos
      help.autocorrect = 1;
    };
    ignores = [
      "*.pyc"
      ".DS_Store"
      ".direnv/"
      ".idea/"
      ".envrc"
      "*.swp"
      "npm-debug.log"
      "venv/"
      "node_modules/"
      "._*"
      "Thumbs.db"
      ".Spotlight-V100"
      ".Trashes"
    ];
    aliases = {
      st = "status -s -b";
      up = "pull --rebase --autostash";
      co = "checkout";
    };
  };
  programs.dircolors = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.gpg = { enable = true; };
  programs.jq = { enable = true; };
  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    viAlias = true;
    plugins = with pkgs.vimPlugins; [ editorconfig-vim gruvbox vim-nix ];
    extraConfig = ''
      :imap jk <Esc>
      :set number
    '';
  };
  programs.kitty = {
    enable = true;
    font = {
      size = 13;
      name = "JetBrainsMono Nerd Font";
    };
    theme = "Gruvbox Light Hard";
    keybindings = {
      "ctrl+a>h" = "neighboring_window left";
      "ctrl+a>j" = "neighboring_window down";
      "ctrl+a>k" = "neighboring_window up";
      "ctrl+a>l" = "neighboring_window right";
      "ctrl+a>z" = "toggle_layout stack";
      "ctrl+f" = "launch --type=overlay --stdin-source=@screen_scrollback ~/.nix-profile/bin/fzf -i --preview='~/.nix-profile/bin/bat --style=numbers --color=always --highlight-line {2} {1}'";
      "ctrl+1" = "goto_tab 1";
      "ctrl+2" = "goto_tab 2";
      "ctrl+3" = "goto_tab 3";
      "ctrl+4" = "goto_tab 4";
      "ctrl+5" = "goto_tab 5";
      "ctrl+6" = "goto_tab 6";
      "ctrl+7" = "goto_tab 7";
      "ctrl+8" = "goto_tab 8";
      "ctrl+9" = "goto_tab 9";
    };
    settings = {
      enabled_layouts = "vertical, stack";
      window_border_width = "2pt";
      scrollback_lines = 10000;
      macos_show_window_title_in = "window";
      tab_bar_style = "slant";
    };
  };
  programs.tmux = {
    enable = true;
    shortcut = "a";
    clock24 = true;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    terminal = "screen-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    historyLimit = 5000;
    extraConfig = ''
      set-option -g mouse on
      set -g set-clipboard on

      bind-key C-a send-prefix
      bind Escape copy-mode
      bind s split-window -h
      bind v split-window -v
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
      {
        plugin = pkgs.tmuxPlugins.better-mouse-mode;
        extraConfig = ''
          set -g @scroll-speed-num-lines-per-scroll '1'
        '';
      }
    ];
  };
  programs.gh.enable = true;
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = {
      global = {
        load_dotenv = true;
        strict_env = false;
        warn_timeout = "20s";
      };
    };
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.eza = {
    enable = true;
  };
  
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
  };

  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 2;
        trim_trailing_whitespace = true;
        insert_final_newline = true;
        indent_style = "space";
      };
      "Makefile" = {
        indent_style = "tab";
      };
      "*.go" = {
        indent_style = "tab";
      };
      "*.md" = {
        trim_trailing_whitespace = false;
      };
      "*.py" = {
        indent_size = 4;
      };
    };
  };
}
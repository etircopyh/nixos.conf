# ZSH configuration
{ config, pkgs, ... }: {

    programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableGlobalCompInit = false;
        #autosuggestions.enable = true;
        #syntaxHighlighting.enable = true;
        histFile = "${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history";
        histSize = 10000;
        setOptions = [ "HIST_IGNORE_DUPS" "SHARE_HISTORY" "HIST_FCNTL_LOCK" ];
        interactiveShellInit = ''
            source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        '';
        shellInit = ''

        '';
        promptInit = ''
            prompt off
            export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml" \
                   STARSHIP_CACHE="${XDG_CACHE_HOME:-HOME/.cache}/starship"
            eval $(starship init zsh)
        '';
        loginShellInit = ''

        '';
        shellAliases = { };
    };
}

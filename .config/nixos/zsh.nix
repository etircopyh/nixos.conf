# ZSH configuration
{ config, pkgs, ... }: {

    programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        histFile = "$ZDOTDIR/.zsh-history";
        histSize = 10000;
        setOptions = [ "HIST_IGNORE_DUPS" "SHARE_HISTORY" "HIST_FCNTL_LOCK" ];
        interactiveShellInit = ''
            source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        '';
        shellInit = ''

        '';
        loginShellInit = ''

        '';
        # promptInit = "\nprecmd() { print '' }\nsetopt prompt_subst\nPROMPT=$'%F{magenta}👽%n%f at %F{yellow}💻%m%f in %F{cyan}%B%~%b%f ${vcs_info_msg_0_} \n%F{176}λ%f %B%F{241}❯%f%b%f '\nRPROMPT='%B🕒%b%F{153}%t%f'";
        shellAliases = { };
    };
}

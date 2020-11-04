PROMPT="%(?:%{$fg[green]%}ﲤ :%{$fg_bold[red]%}ﲤ %{$reset_color%})"
PROMPT+='%{$fg[magenta]%}%c%{$reset_color%}$(git_prompt_info) %{$fg_bold[red]%}>%{$reset_color%} '

ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

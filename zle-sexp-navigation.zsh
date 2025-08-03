forward-sexp() {
    setopt local_options extended_glob

    local start
    local match
    # Skip whitespace:
    if [[ "$RBUFFER" =~ "^(\s+)" ]] ; then
        zle forward-char -n ${#match[1]}
    fi
    if [[ "$RBUFFER" = "" ]]; then
        return
    fi
    start=$CURSOR
    zle select-a-shell-word
    if [[ $CURSOR -le $start ]] ; then
        # We're at the end of a previous shell-word (so cursor is
        # un-moved), let's move forward one and try again:
        zle forward-char
        zle forward-sexp
    else
        zle deactivate-region
    fi
}

backward-sexp() {
    setopt local_options RE_MATCH_PCRE

    local match
    # Skip whitespace backward to the end of the first plausible shell word beginning:
    if [[ "$LBUFFER" =~ "(\s+)$" ]] ; then
        zle backward-char -n ${#match[1]}
    fi

    zle select-a-shell-word
    CURSOR=$MARK
    # Skip whitespace forward so we're at the beginning of the word:
    if [[ "${BUFFER:($CURSOR)}" =~ "^(\s+)" ]] ; then
        (( CURSOR = $CURSOR + ${#match[1]} ))
    fi
    zle deactivate-region
}

kill-sexp() {
    local start
    start=$CURSOR
    zle forward-sexp
    MARK=$start
    zle kill-region
}

backward-kill-sexp() {
    local start
    start=$CURSOR
    zle backward-sexp
    MARK=$start
    zle kill-region
}

zle -N backward-sexp
zle -N forward-sexp
zle -N backward-kill-sexp
zle -N kill-sexp

# Key bindings for emacs:
bindkey -e '\e^b' backward-sexp
bindkey -e '\e^f' forward-sexp
bindkey -e '\e^k' kill-sexp

# The backward-kill-sexp binding is a bit displeasing, as it doesn't
# correspond to the emacs keybinding; however, we can't rebind
# ctrl-alt-backspace, as backspace is already a control sequence /:
bindkey -e '\e^w' backward-kill-sexp

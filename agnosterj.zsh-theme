# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://github.com/agnoster/agnoster-zsh-theme
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### User-configurable variables

# 'full', 'short', or 'shrink'
x=${AGNOSTER_PATH_STYLE:=full}
# 'light' or 'dark', for which version of Solarized you're using
x=${AGNOSTER_THEME_VARIANT:=dark}

### Segments of the prompt, default order declaration

typeset -aHg AGNOSTER_PROMPT_SEGMENTS=(
    prompt_status
    prompt_context
    prompt_virtualenv
    prompt_vaulted
    prompt_dir
    prompt_git
    prompt_kubecontext
)

### Color setup

AGNJ_LAST_THEME_VARIANT=$AGNOSTER_THEME_VARIANT
agnj_setup_colors() {
  case "$AGNOSTER_THEME_VARIANT" in
    light)
      AGNJ_COLOR_BG=white
      AGNJ_COLOR_FG=white
      ;;
    dark|*)
      AGNJ_COLOR_BG=black
      AGNJ_COLOR_FG=black
      ;;
  esac
}
AGNJ_CURRENT_BG='NONE'

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

# Special Powerline characters

# Defines vars with the special prompt and Powerline characters
# Use this in conjunction with "local SEGMENT_SEPARATOR BRANCH DETACHED PLUSMINUS CROSS LIGHTNING GEAR"
# in the caller to keep from leaking these into the main shell session
define_prompt_chars() {
  # Force Unicode interpretation of chars, even under odd locales
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  # NOTE: This segment separator character is correct.  In 2012, Powerline changed
  # the code points they use for their special characters. This is the new code point.
  # If this is not working for you, you probably have an old version of the 
  # Powerline-patched fonts installed. Download and install the new version.
  # Do not submit PRs to change this unless you have reviewed the Powerline code point
  # history and have new information.
  # This is defined using a Unicode escape sequence so it is unambiguously readable, regardless of
  # what font the user is viewing this source code in. Do not replace the
  # escape sequence with a single literal character.
  SEGMENT_SEPARATOR=$'\ue0b0' # 
  PLUSMINUS=$'\u00b1'
  BRANCH=$'\ue0a0'
  DETACHED=$'\u27a6'
  CROSS=$'\u2718'
  LIGHTNING=$'\u26a1'
  GEAR=$'\u2699'
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  local SEGMENT_SEPARATOR BRANCH DETACHED PLUSMINUS CROSS LIGHTNING GEAR
  define_prompt_chars
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $AGNJ_CURRENT_BG != 'NONE' && $1 != $AGNJ_CURRENT_BG ]]; then
    print -n "$bg%F{$AGNJ_CURRENT_BG}$SEGMENT_SEPARATOR$fg"
  else
    print -n "$bg$fg"
  fi
  AGNJ_CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  local SEGMENT_SEPARATOR BRANCH DETACHED PLUSMINUS CROSS LIGHTNING GEAR
  define_prompt_chars
  if [[ -n $AGNJ_CURRENT_BG ]]; then
    print -n "%k%F{$AGNJ_CURRENT_BG}$SEGMENT_SEPARATOR"
  else
    print -n "%k"
  fi
  print -n "%f"
  AGNJ_CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=$USER

  if [[ "$user" != "$DEFAULT_USER" ]]; then
    if [[ -n "$SSH_CONNECTION" ]]; then
      prompt_segment $AGNJ_COLOR_FG default " %(!.%F{yellow}.)$user@%m "
    else
      prompt_segment $AGNJ_COLOR_FG default " %(!.%F{yellow}.)$user@ "
    fi
  else
    if [[ -n "$SSH_CONNECTION" ]]; then
      prompt_segment $AGNJ_COLOR_FG default " @%m "
    fi
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local color ref mode
  local SEGMENT_SEPARATOR BRANCH DETACHED PLUSMINUS CROSS LIGHTNING GEAR
  define_prompt_chars
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules 2>/dev/null)"
  }
  ref="$vcs_info_msg_0_"
  if [[ -n "$ref" ]]; then
    if is_dirty; then
      color=yellow
      ref="${ref} $PLUSMINUS"
    else
      color=green
      ref="${ref} "
    fi
    if [[ "${ref/.../}" == "$ref" ]]; then
      ref="$BRANCH $ref"
    else
      ref="$DETACHED ${ref/.../}"
    fi

    prompt_segment $color $AGNJ_COLOR_FG
    print -Pn " $ref$mode"
  fi
}

# Dir: current working directory
prompt_dir() {
  local path_seg
  case "$AGNOSTER_PATH_STYLE" in
    short)
      path_seg=' %1~ '
      ;;
    shrink)
      if which shrink_path >&/dev/null; then
        # Requires Oh My Zsh's shrink-path plugin or compatible
        path_seg=" $(shrink_path -f) "
      else
        path_seg=$(print -P ' %~ ' | sed -E -e "s#([^a-z]*[a-z])[^/]*/#\1/#g")
      fi
      ;;
    full|*)
      path_seg=' %~ '
      ;;
  esac
  prompt_segment blue $AGNJ_COLOR_FG "${path_seg}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local SEGMENT_SEPARATOR BRANCH DETACHED PLUSMINUS CROSS LIGHTNING GEAR
  define_prompt_chars
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%F{red}$CROSS"
  [[ $UID -eq 0 ]] && symbols+="%F{yellow}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%F{cyan}$GEAR"

  [[ -n "$symbols" ]] && prompt_segment $AGNJ_COLOR_FG default " $symbols "
}

# Mercurial repo status
prompt_hg() {
  local rev status
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment red white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment yellow black
        st='±'
      else
        # if working copy is clean
        prompt_segment green black
      fi
      echo -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment red black
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment yellow black
        st='±'
      else
        prompt_segment green black
      fi
      echo -n "☿ $rev@$branch" $st
    fi
  fi
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local env
  if [[ -z $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
      env="$CONDA_DEFAULT_ENV"
    else
      env="$VIRTUAL_ENV";
    fi
    if [[ -n "$env" ]]; then
      prompt_segment blue black "(`basename \"$virtualenv_path\"`)"
    fi
  fi
}

epoch_date() {
  unamestr=`uname`
  if [[ "$unamestr" == 'Linux' ]]; then
    echo $(date -d $1 +%s)
  elif [[ "$unamestr" == 'Darwin' ]]; then
    echo $(date -j -f %Y-%m-%dT%H:%M:%S%z $1 +%s)
  else # TODO - other platforms?
    echo $(date -j -f %Y-%m-%dT%H:%M:%S%z $1 +%s)
  fi
}

# Vaulted: current vaulted shell
prompt_vaulted() {
  if [[ -z $VAULTED_ENV ]]; then
    return
  fi
  local exp=$(echo $VAULTED_ENV_EXPIRATION | sed 's/Z/+0000/')
  local valid_until=$(epoch_date $exp)
  local bg=009 #orange
  local fg=black
  if [[ $valid_until -lt $(date +%s) ]]; then
    fg=blue
  fi
  if [[ -n $VAULTED_ENV ]]; then
    prompt_segment $bg $fg " ${VAULTED_ENV} "
  fi
}

prompt_kubecontext() {
  local env='';

  if [[ -n $KUBE_PS1_CONTEXT ]]; then
    env="$KUBE_PS1_SYMBOL_DEFAULT$KUBE_PS1_SEPARATOR$KUBE_PS1_CONTEXT$KUBE_PS1_DIVIDER$KUBE_PS1_NAMESPACE"
  fi

  if [[ -n $env ]]; then
    prompt_segment magenta $AGNJ_COLOR_FG
    print -Pn " $env "
  fi
}

## Main prompt
prompt_agnoster_main() {
  RETVAL=$?
  local AGNJ_CURRENT_BG='NONE'
  if [[ "$AGNOSTER_THEME_VARIANT" != "$AGNJ_LAST_THEME_VARIANT" ]]; then
    agnj_setup_colors
    AGNJ_LAST_THEME_VARIANT="$AGNOSTER_THEME_VARIANT"
  fi
  local segment
  for segment in $AGNOSTER_PROMPT_SEGMENTS; do
    $segment
  done
  prompt_end
}

prompt_agnoster_precmd() {
  vcs_info
}

prompt_agnoster_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst sp percent)

  agnj_setup_colors

  add-zsh-hook precmd prompt_agnoster_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' get-revision true
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' stagedstr '✚'
  zstyle ':vcs_info:git:*' unstagedstr '●'
  zstyle ':vcs_info:*' formats '%b'
  zstyle ':vcs_info:*' actionformats '%b (%a)'

  setopt prompt_subst
  PROMPT='%f%b%k$(prompt_agnoster_main) '
}

agnj_debug() {
  echo "$*" >> ~/agnoster-debug.log
}

prompt_agnoster_setup "$@"

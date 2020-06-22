# vim:ft=zsh ts=2 sw=2 sts=2
#
# AgnosterJ Theme - https://github.com/apjanke/agnosterj-zsh-theme
#
# A Powerline-inspired theme for ZSH
# Based on the original Agnoster Theme - https://github.com/agnoster/agnoster-zsh-theme
#
# # README
#
# In order for this theme to render correctly, you will need iTerm2 or a
# [Powerline-patched font](https://gist.github.com/1595572).
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on macOS, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity, and built-in support for
# Powerline symbols!
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

AGNOSTER_VERSION=2.0.0-prerelease
typeset -r AGNOSTER_VERSION
typeset -Ah AGNOSTER_DEFAULT_OPTS
AGNOSTER_DEFAULT_OPTS=(
  AGNOSTER_THEME_VARIANT dark
  AGNOSTER_PATH_STYLE full
  AGNOSTER_ABBREVIATE_HOME_DIR 1
  AGNOSTER_RANDOM_EMOJI 🔥💀👑😎😜🤡🤖🥳👍😈👹🧠👖🍆🏋️‍♂️🐸🐵🦄🌈🍻🚀💡🎉🔑🇹🇭🚦🌙🛌🛎️
  AGNOSTER_RANDOM_EMOJI_EACH_PROMPT 0
  AGNOSTER_RANDOM_EMOJI_REALLY_RANDOM 1
  AGNOSTER_PROMPT_SEGMENTS "status git context virtualenv vaulted dir kubecontext"
)
typeset -ah AGNOSTER_KNOWN_SEGMENT_NAMES
AGNOSTER_KNOWN_SEGMENT_NAMES=(
  aws
  azure
  blank
  context
  dir
  filesystem
  gcp
  git
  hg
  k8s
  kubecontext
  newline
  random_emoji
  status
  vaulted
  virtualenv
)

### User-configurable variables

# 'full', 'short', or 'shrink'
: ${AGNOSTER_PATH_STYLE:=${AGNOSTER_DEFAULT_OPTS[AGNOSTER_PATH_STYLE]}}
# 'light' or 'dark', for which version of Solarized you're using
: ${AGNOSTER_THEME_VARIANT:=${AGNOSTER_DEFAULT_OPTS[AGNOSTER_THEME_VARIANT]}}
# The emoji to draw from for prompt_random_emoji
if [[ -z "$AGNOSTER_RANDOM_EMOJI" ]]; then
  AGNOSTER_RANDOM_EMOJI=${AGNOSTER_DEFAULT_OPTS[AGNOSTER_RANDOM_EMOJI]}
fi
# Whether to change the random emoji each time the prompt is displayed
: ${AGNOSTER_RANDOM_EMOJI_EACH_PROMPT:=${AGNOSTER_DEFAULT_OPTS[AGNOSTER_RANDOM_EMOJI_EACH_PROMPT]}}

### Segments of the prompt
# See bottom of script for default value

typeset -aH AGNOSTER_PROMPT_SEGMENTS

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
  local POWERLINE_SEGMENT_SEPARATOR=$'\ue0b0' # 
  if [[ -z "$AGNOSTER_SEPARATOR_STYLE" ]]; then
    SEGMENT_SEPARATOR=$POWERLINE_SEGMENT_SEPARATOR
  else
    case "$AGNOSTER_SEPARATOR_STYLE" in
      curvy)
        SEGMENT_SEPARATOR=$'\ue0b4'
        ;;
      angly)
        SEGMENT_SEPARATOR=$'\ue0b8'
        ;;
      angly-up)
        SEGMENT_SEPARATOR=$'\ue0bc'
        ;;
      flame)
        SEGMENT_SEPARATOR=$'\ue0c0'
        ;;
      littleboxes)
        SEGMENT_SEPARATOR=$'\ue0c4'
        ;;
      boxes)
        SEGMENT_SEPARATOR=$'\ue0c6'
        ;;
      fade)
        SEGMENT_SEPARATOR=$'\ue0c8'
        ;;
      hexes)
        SEGMENT_SEPARATOR=$'\ue0cc'
        ;;
      lego)
        SEGMENT_SEPARATOR=$'\ue0ce'
        ;;
      lego2)
        SEGMENT_SEPARATOR=$'\ue0d1'
        ;;
      thingie)
        SEGMENT_SEPARATOR=$'\ue0d2'
        ;;
      original)
        SEGMENT_SEPARATOR=$POWERLINE_SEGMENT_SEPARATOR
        ;;
      *)
        SEGMENT_SEPARATOR="?"
        ;;
    esac
  fi
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

prompt_newline() {
  local SEGMENT_SEPARATOR BRANCH DETACHED PLUSMINUS CROSS LIGHTNING GEAR
  define_prompt_chars
  prompt_end
  # TODO: Need to communicate the fg color correctly to next segment so
  # there's not an excess ">" at the beginning of the line.
  print -n "\n"
}

prompt_blank() {
  # TODO: A way to customize this' color
  prompt_segment blue $AGNJ_COLOR_FG " "
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=$USER

  local fg bg
  if [[ -n "$AGNOSTER_CONTEXT_FG" ]]; then
    fg="$AGNOSTER_CONTEXT_FG"
  else
    fg=default
  fi
  if [[ -n "$AGNOSTER_CONTEXT_BG" ]]; then
    bg="$AGNOSTER_CONTEXT_BG"
  else
    bg="$AGNJ_COLOR_FG"
  fi
  if [[ "$user" != "$DEFAULT_USER" ]]; then
    if [[ -n "$SSH_CONNECTION" ]]; then
      prompt_segment "$bg" "$fg" " %(!.%F{yellow}.)$user@%m "
    else
      prompt_segment "$bg" "$fg" " %(!.%F{yellow}.)$user@ "
    fi
  else
    if [[ -n "$SSH_CONNECTION" ]]; then
      prompt_segment "$bg" "$fg" " @%m "
    fi
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local color ref mode ahead behind
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
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && ref="${ref}⬆ "
    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && ref="${ref}⬇ "
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
      if [[ $AGNOSTER_ABBREVIATE_HOME_DIR = 0 ]]; then
        path_seg=' %1d '
      else
        path_seg=' %1~ '
      fi
      ;;
    shrink)
      if which shrink_path >&/dev/null; then
        # Requires Oh My Zsh's shrink-path plugin or compatible
        path_seg=" $(shrink_path -f) "
      else
        if [[ $AGNOSTER_ABBREVIATE_HOME_DIR = 0 ]]; then
          path_seg=$(print -P ' %d ' | sed -E -e "s#([^a-z]*[a-z])[^/]*/#\1/#g")
        else
          path_seg=$(print -P ' %~ ' | sed -E -e "s#([^a-z]*[a-z])[^/]*/#\1/#g")
        fi
      fi
      ;;
    full|*)
      if [[ $AGNOSTER_ABBREVIATE_HOME_DIR = 0 ]]; then
        path_seg=' %d '
      else
        path_seg=' %~ '
      fi
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
  local str=""
  str=""
  if [[ $RETVAL -ne 0 ]]; then
    str+="%F{red}$CROSS"
    if [[ $AGNOSTER_DISPLAY_EXIT_STATUS == 1 ]]; then
      str+="$RETVAL"
    fi
  fi
  [[ $UID -eq 0 ]] && str+="%F{yellow}$LIGHTNING"
  [[ $(jobs -l | sed '/nohup/d' | wc -l) -gt 0 ]] && str+="%F{cyan}$GEAR"

  [[ -n "$str" ]] && prompt_segment $AGNJ_COLOR_FG default " $str "
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
      env=`basename "$VIRTUAL_ENV"`
    fi
    if [[ -n "$env" ]]; then
      prompt_segment blue black "($env)"
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
    local lock_icon=$'\ue0a2'
    prompt_segment $bg $fg " ${lock_icon}${VAULTED_ENV} "
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

# Cloud info
prompt_k8s() {
  if [[ ! -z ${KUBECONFIG} ]]; then
    k8s_context=$(awk '/current-context/{print $2}' $KUBECONFIG)
  elif [[ -f "$HOME/.kube/config" ]]; then
    k8s_context=$(awk '/current-context/{print $2}' $HOME/.kube/config)
  fi
  if [[ ! -z ${k8s_context} ]]; then
    color=cyan
    prompt_segment $color $AGNJ_COLOR_FG
    print -Pn " ⎈ ${k8s_context} "
  fi
}

prompt_aws() {
  if [[ ! -z ${AWS_PROFILE} ]]; then
    color=yellow
    prompt_segment $color $AGNJ_COLOR_FG
    print -Pn " ⓦ ${AWS_PROFILE} "
  elif [[ ! -z ${AWS_DEFAULT_PROFILE} ]]; then
    color=yellow
    prompt_segment $color $AGNJ_COLOR_FG
    print -Pn " ⓦ ${AWS_DEFAULT_PROFILE} "
  fi
}

prompt_azure() {
  if [[ -f "$HOME/.azure/config" ]]; then
    azure_cloud=$(awk '/name/{print tolower($3)}' $HOME/.azure/config)
    if [[ ! -z ${azure_cloud} ]]; then
      color=blue
      prompt_segment $color $AGNJ_COLOR_FG
      print -Pn " ⓐ ${azure_cloud} "
    fi
  fi
}

prompt_gcp() {
  if [ -f "$HOME/.config/gcloud/active_config" ]; then
    gcp_profile=$(cat $HOME/.config/gcloud/active_config)
    gcp_project=$(awk '/project/{print $3}' $HOME/.config/gcloud/configurations/config_$gcp_profile)
    if [ ! -z ${gcp_project} ]; then
      color=green
      prompt_segment $color $AGNJ_COLOR_FG
      print -Pn " ⓖ ${gcp_project} "
    fi
  fi
}

# Filesystem: filesystem on which the current working directory lies
prompt_filesystem() {
    local fs=$(df "$PWD" | tail -1 | awk '{print $1}')
    agnj_debug "fs is: $fs"
    prompt_segment magenta $AGNJ_COLOR_FG " $fs "
}

AGNOSTER_KNOWN_BAD_EMOJI_CODEPOINTS=(1F322 1F322 1F394 1F395 1F398 1F39C 1F39D 
  1F3F1 1F3F2 1F3F6 1F4FE 
  1F93B 1F946 1F971 1F972 1F977 1F978 1F979)
agnj_pick_random_emoji() {
  local n block_num base range_end range_size offset codepoint hexcode char
  local block_bases block_ends my_emoji
  if [[ "$AGNOSTER_RANDOM_EMOJI_REALLY_RANDOM" = 1 ]]; then
    while [[ -z "$my_emoji" ]]; do
      # TODO: Weight each block according to its size
      block_bases=(0x1f300 0x1f5fa 0x1f910)
      block_ends=( 0x1f53d 0x1f6c5 0x1f9a2)
      block_num=$(( ${#block_bases[@]} % 3 + 1 ))
      base=${block_bases[$block_num]}
      base=$(printf '%d' $base)
      range_end=${block_ends[$block_num]}
      range_end=$(printf '%d' $range_end)
      range_size=$(( range_end - base + 1))
      offset=$(( $RANDOM % $range_size ))
      codepoint=$(( $base + $offset ))
      hexcode=$(printf '%X' $codepoint)
      if [[ ${AGNOSTER_KNOWN_BAD_EMOJI_CODEPOINTS[(ie)$hexcode]} \
             -gt ${#AGNOSTER_KNOWN_BAD_EMOJI_CODEPOINTS} ]]; then
        my_emoji="${(#)codepoint}"
      fi
    done
  else
    n=$(( $RANDOM % ${#AGNOSTER_RANDOM_EMOJI[@]} + 1 ))
    my_emoji="${AGNOSTER_RANDOM_EMOJI[$n]}"
  fi
  echo "$my_emoji"
}

prompt_random_emoji() {
  local n my_emoji
  if [[ -n "$AGNOSTER_FIXED_RANDOM_EMOJI" ]]; then
    my_emoji="$AGNOSTER_FIXED_RANDOM_EMOJI"
  else
    my_emoji=$(agnj_pick_random_emoji)
  fi
  prompt_segment black default "$my_emoji "
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
    if [[ $segment == 'prompt_'* ]]; then
      # Back-compatibility shim
      segment_fcn=$segment
    else
      segment_fcn="prompt_${segment}"
    fi
    $segment_fcn
  done
  prompt_end
}

prompt_agnoster_precmd() {
  vcs_info
  if agnj_array_contains AGNOSTER_PROMPT_SEGMENTS random_emoji; then
    if [[ $AGNOSTER_RANDOM_EMOJI_EACH_PROMPT = 1 ]]; then
      AGNOSTER_FIXED_RANDOM_EMOJI=""
      # We need to bump $RANDOM here because prompt_agnoster_main runs in a subshell
      # and inherits the random seed state without propagating its advancing of it to
      # the parent shell
      : $RANDOM
    else
      if [[ -z "$AGNOSTER_FIXED_RANDOM_EMOJI" ]]; then
        AGNOSTER_FIXED_RANDOM_EMOJI=$(agnj_pick_random_emoji)
      fi
    fi
  fi
}

prompt_agnoster_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst sp percent)

  if [[ -z "$AGNOSTER_PROMPT_SEGMENTS" ]]; then
    AGNOSTER_PROMPT_SEGMENTS=( ${=AGNOSTER_DEFAULT_OPTS[AGNOSTER_PROMPT_SEGMENTS]} )
  fi

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

# TODO: Consider replacing with `if (( $haystack[(I)$needle] > 0 ))`
agnj_array_contains() {
  local array_name="$1"
  local needle_value="$2"
  local arr=(${(P)array_name})
  if [[ ${arr[(ie)$needle_value]} -le ${#arr} ]]; then
    return 0
  else
    return 1
  fi
}

agnj_debug() {
  echo "$*" >> ~/agnoster-debug.log
}

# Usage:
#   agnoster_add_segment [<insertion_index>] <name> ...
# Numeric arguments are interpreted as the insertion index.
# Non-numeric arguments are treatd as segment names.
agnoster_add_segment() {
  local ix
  local segs=()
  for arg in $@; do
    if [[ "$arg" = <-> ]]; then
      # Numeric arg is the insertion point
      ix=$arg
    else
      if ! agnj_array_contains AGNOSTER_KNOWN_SEGMENT_NAMES "$arg"; then
        echo >&2 "agnoster: error: unknown segment: $arg"
        return 1;
      fi
      # Reverse their order so we can repeatedly insert at same ix
      segs=($arg $segs)
    fi
  done
  if [[ $ix == "" ]]; then
    ix=$(( ${#AGNOSTER_PROMPT_SEGMENTS} + 1 ))
  fi
  for seg in $segs; do
    AGNOSTER_PROMPT_SEGMENTS=("${AGNOSTER_PROMPT_SEGMENTS[@]:0:$ix-1}" \
      "$seg" "${AGNOSTER_PROMPT_SEGMENTS[@]:$ix-1}");
  done
}

# Usage:
#   agnoster_remove_segment (<name>|<index>) ...
agnoster_remove_segment() {
  # Convert all args to names first, so we don't have to worry about
  # indexes shifting as we remove segments
  local segs=()
  for arg in $@; do
    if [[ "$arg" = <-> ]]; then
      segs+=${AGNOSTER_PROMPT_SEGMENTS[$arg]}
    else
      if ! agnj_array_contains AGNOSTER_PROMPT_SEGMENTS "$arg"; then
        echo >&2 "agnoster: warning: segment is not present: $arg"
      else
        segs+=$arg
      fi
    fi
  done
  for seg in $segs; do
    local ix=${AGNOSTER_PROMPT_SEGMENTS[(ie)$seg]}
    AGNOSTER_PROMPT_SEGMENTS[$ix]=
  done
}

agnoster_setopt() {
  # Do not display DEFAULT_USER; some people might consider that a privacy issue
  local optvars=(
    AGNOSTER_PROMPT_SEGMENTS
    AGNOSTER_PATH_STYLE
    AGNOSTER_DISPLAY_EXIT_STATUS
    AGNOSTER_CONTEXT_FG
    AGNOSTER_CONTEXT_BG
    AGNOSTER_RANDOM_EMOJI
    AGNOSTER_RANDOM_EMOJI_EACH_PROMPT
    AGNOSTER_RANDOM_EMOJI_REALLY_RANDOM
    VIRTUAL_ENV_DISABLE_PROMPT
  )
  local varname default val
  echo "AgnosterJ version $AGNOSTER_VERSION"
  for varname in $optvars; do
    if [[ -n "${(P)varname}" ]]; then
      default="${AGNOSTER_DEFAULT_OPTS[$varname]}";
      val="${(P)varname}"
      if [[ -z "$default" || ( "$val" != "$default" ) ]]; then
        echo "${varname} = ${(P)varname}"
      fi
    fi
  done
}

prompt_agnoster_setup "$@"

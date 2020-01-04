# AgnosterJ

This is a Zsh theme optimized for people who use:

- The [Solarized](https://ethanschoonover.com/solarized/) color scheme
- Git
- Unicode-compatible fonts and terminals

For Mac users, I highly recommend iTerm2 + Solarized Dark.

AgnosterJ is [apjanke](https://github.com/apjanke)'s fork of [agnoster](https://github.com/agnoster)'s Agnoster Zsh Theme. Development on the original Agnoster seems to have stalled as of about 2018, so I decided to make a fork and pull in pending PRs from over there, and add some of my own enhancements.

The original Agnoster Theme, while not minimal, tried to stay small, supporting just the most common features. AgnosterJ is more expansive, providing additional prompt segment types, more customizability, and some silly stuff thrown in.

# Requirements

* Zsh (I'm not sure what the minimum version is)
* Powerline font support

### Powerline fonts

If you are using iTerm2, then Powerline support is built in. To enable it, find your profile in Settings > Profiles, select the Text tab, and turn on "Use built-in Powerline glyphs". This is easier than installing a special font!

**NOTE:** If you are not using iTerm2, you will need to install a [Powerline-patched font](https://github.com/powerline/fonts) for this theme to render correctly. (Note: installing the `fonts-powerline` Debian package does not work!)

To test if your terminal and font support Powerline, check that all the necessary characters are supported by copying the following command to your terminal: `echo "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699"`. The result should look like this:

![Character Example](images/characters.png)

If you get placeholder squares for the first and third characters, then you are not correctly using a Powerline-patched font.

# What does AgnosterJ show?

- If the previous command failed (✘)
- `user@hostname` (if user is not DEFAULT_USER, which can be set in your profile)
- Git status
  - Branch (![Branch Character](images/branch.png)) or detached head (➦)
  - Current branch/SHA1 when in detached head state
  - Dirty working directory (±, color change)
- Working directory
- Elevated (root) privileges (⚡)
- Whether background jobs are running (⚙)
- Other fun stuff!

## Example

![Screenshot](images/screenshot.png)

# Installation

## Regular installation

Download the files in this repo somewhere, and have your `~/.zshrc` `source` the `agnosterj.zsh-theme` file.

```
# This goes in your ~/.zshrc

source ~/path/to/agnosterj-zsh-theme/agnosterj.zsh-theme
```

## Installation under Oh My Zsh

Download the files in this repo somewhere, like `~/local/repos/agnosterj-zsh-theme`.

Then link it into your Oh My Zsh custom setup:

```
$ ln -s ~/local/repos/agnosterj-zsh-theme/agnosterj.zsh-theme $ZSH_CUSTOM/themes/agnosterj.zsh-theme
```

Then set it as your theme in your `~/.zshrc` before loading Oh My Zsh:

```
# This goes in your ~/.zshrc

ZSH_THEME=agnosterj
plugins=( osx themes )
ZSH=${ZSH:-$HOME/.oh-my-zsh}
source $ZSH/oh-my-zsh.zsh
```

# Configuration

AgnosterJ can be configured by setting these environment variables.

* `$AGNOSTER_PROMPT_SEGMENTS` - List of segments to include in your prompt.
* `$AGNOSTER_PATH_STYLE` – `full`, `short`, or `shrink` – Controls how the current directory is displayed.
* `$AGNOSTER_DISPLAY_EXIT_STATUS` – If 1, includes the exit status value in the status segment for unsuccessful process exits.
* `$AGNOSTER_CONTEXT_FG`, `$AGNOSTER_CONTEXT_BG` – Override colors for the user/host context segment. Useful if you want to set this on a per-host basis.
* `$AGNOSTER_SEPARATOR_STYLE` – Choose a different separator, if you have a font with the [Powerline Extra](https://github.com/ryanoasis/powerline-extra-symbols) symbols (not just regular Powerline). ([Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) is a good way to get these.)
  * Options: `original`, `curvy`, `angly`, `angly-up`, `flame`, `littleboxes`, `boxes`, `fade`, `hexes`, `lego`, `lego2`, `thingie`
* `$DEFAULT_USER` - A user name you typically log in as, and which should be omitted from the prompt display when you are that user.
* `$VIRTUAL_ENV_DISABLE_PROMPT` – Set this to any nonempty value to disable Python virtualenv/conda env display.
* `$AGNOSTER_RANDOM_EMOJI_EACH_PROMPT` – Whether the `prompt_random_emoji` segment should use a different emoji each time a prompt is displayed (1) or keep the same emoji for the duration of a shell session (0).
* `$AGNOSTER_RANDOM_EMOJI` – The list of emoji characters that `prompt_random_emoji` will draw from.
* `$AGNOSTER_RANDOM_EMOJI_REALLY_RANDOM` – Set to `1` to get a wider range of random emoji.

You can call the `agnoster_setopt` function to see what all the current variables affecting AgnosterJ are set to.

## Customizing your prompt

By default, the prompt has these segments in this order:
- `status`
- `git`
- `context`
- `virtualenv`
- `dir`

If you want to add, remove, or reorder some segments of the prompt, you can use the array environment variable named `AGNOSTER_PROMPT_SEGMENTS`. There are also `agnoster_add_segment` and `agnoster_remove_segment` functions to help you do this.

There are many prompt segments available that are not enabled by default. See the source code for options!

Optional segments include:
- `newline`
- `k8s`
- `aws`
- `azure`
- `gcp`
- `filesystem`
- `random_emoji`


### Examples

- Show all segments of the prompt with indices:
```
echo "${(F)AGNOSTER_PROMPT_SEGMENTS[@]}" | cat -n
```
- Add a new segment to the end:
```
agnoster_add_segment aws
```
- Add a segment or segments to the beginning or other position:
```
agnoster_add_segment 1 aws
agnoster_add_segment 5 aws
agnoster_add_segment 5 aws gcp azure
```
- Remove segments:
```
agnoster_remove_segment 5
agnoster_remove_segment aws gcp azure
```
- Show prompt segments and other AgnosterJ options:
```
agnoster_setopt
```

A small demo of a dummy custom prompt segment, which has been created with help of the `prompt_segment()` function from AgnosterJ:
```
# prompt_segment() - Takes two arguments, background and foreground.
# Both can be omitted (by passing an empty argument), rendering 
# default background/foreground.

customize_agnoster() {
  prompt_segment 'red' '' ' ⚙ ⚡⚡⚡ ⚙  '
}
```
![Customization demo](images/agnoster_customization.gif)

# Future Work

It’s currently hideously slow, especially inside a git repo. I guess it's not overly so for comparable themes, but it bugs me, and I‘d love to hear ideas about how to improve the performance.

The dependency on a powerline-patched font is regrettable, but there’s really no way to get that effect without it. Ideally there would be a way to check for compatibility, or maybe even fall back to one of the similar unicode glyphs. At least nowadays iTerm2 has Powerline icon support built in.

# License

The AgnosterJ licensing situation is a little unclear. This is because the upstream Agnoster Zsh Theme [does not have a license](https://github.com/agnoster/agnoster-zsh-theme/issues/42). But it’s clearly meant for public consumption, so I’m assuming that making this fork is fine, and it's okay to redistribute that code.

The AgnosterJ additions to Agnoster are licensed under the [MIT License](https://opensource.org/licenses/MIT).

If Agnoster gets around to choosing a particular open source license, I will add dual-licensing to AgnosterJ so it is covered under that license as well.

# Author

[Agnoster](https://github.com/agnoster/agnoster-zsh-theme) was originally written by Isaac Wolkerstorfer ([agnoster](https://github.com/agnoster) on GitHub). Thanks to Isaac for writing this neat tool!

The AgnosterJ fork is maintained by [Andrew Janke](https://apjanke.net) ([apjanke](https://github.com/apjanke) on GitHub).

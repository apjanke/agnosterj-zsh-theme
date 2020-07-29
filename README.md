# AgnosterJ

This is a Zsh theme optimized for people who use:

* The [Solarized](https://ethanschoonover.com/solarized/) color scheme
* Git or other VCS tools
* Unicode-compatible fonts and terminals

For Mac users, I highly recommend iTerm2 + Solarized Dark.

AgnosterJ is [apjanke](https://github.com/apjanke)'s fork of [agnoster](https://github.com/agnoster)'s Agnoster Zsh Theme. Development on the original Agnoster seems to have stalled as of about 2018, so I decided to make a fork and pull in pending PRs from over there, and add some of my own enhancements.

The original Agnoster Theme, while not minimal, tried to stay small, supporting just the most common features. AgnosterJ is more expansive, providing additional prompt segment types, more customizability, and some silly stuff thrown in.

## Requirements

* [Zsh](http://zsh.sourceforge.net/) (I'm not sure what the minimum version is; 5.3 and later definitely work)
* Powerline font support

### Powerline fonts

If you are using iTerm2, then Powerline support is built in. To enable it, find your profile in Settings > Profiles, select the Text tab, and turn on "Use built-in Powerline glyphs". This is easier than installing a special font!

**NOTE:** If you are not using iTerm2, you will need to install a "Powerline-patched font" for this theme to render correctly. There’s a couple places you can get these easily:

* [Nerd Fonts](https://www.nerdfonts.com/) (I recommend this one.)
* The [`powerline/fonts` repo](https://github.com/powerline/fonts) on GitHub

(Note: Installing the `fonts-powerline` Debian package does _not_ work!)

To test if your terminal and font support Powerline, check that all the necessary characters are supported by copying the following command to your terminal: `echo "\ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699"`. The result should look like this:

![Character Example](doc/images/characters.png)

If you get placeholder squares for the first and third characters, then you are not correctly using a Powerline-patched font.

## What does AgnosterJ show?

* If the previous command failed (✘)
* `user@hostname` (if user is not DEFAULT_USER, which can be set in your profile)
* Git status
  * Branch (![Branch Character](doc/images/branch.png)) or detached head (➦)
  * Current branch/SHA1 when in detached head state
  * Dirty working directory (±, color change)
* Working directory
* Elevated (root) privileges (⚡)
* Whether background jobs are running (⚙)
* Other fun stuff!

### Example

![Screenshot](doc/images/screenshot.png)

## Installation

### Regular installation

Download the files in this repo somewhere, and have your `~/.zshrc` `source` the `agnosterj.zsh-theme` file.

```zsh
# This goes in your ~/.zshrc

source ~/path/to/agnosterj-zsh-theme/agnosterj.zsh-theme
```

### Installation under Oh My Zsh or Prezto

See the [User Guide](https://github.com/apjanke/agnosterj-zsh-theme/blob/master/doc/UserGuide.md) for instructions.

## Configuration

AgnosterJ can be configured by setting various environment variables. For example:

* `$AGNOSTER_PROMPT_SEGMENTS` - Array of segments to include in your prompt.
* `$AGNOSTER_PATH_STYLE` – `full`, `short`, or `shrink` – Controls how the current directory is displayed.
* `$DEFAULT_USER` - A user name you typically log in as, and which should be omitted from the prompt display when you are that user.

See the [User Guide](https://github.com/apjanke/agnosterj-zsh-theme/blob/master/doc/UserGuide.md) for details on all configuration variables.

You can call the `agnoster_setopt` function to see what the current variables affecting AgnosterJ are set to.

### Customizing your prompt

By default, the prompt has these segments in this order:

* `status`
* `git`
* `context`
* `virtualenv`
* `vaulted`
* `dir`
* `kubecontext`

If you want to add, remove, or reorder some segments of the prompt, you can use the array environment variable named `AGNOSTER_PROMPT_SEGMENTS`. There are also `agnoster_add_segment` and `agnoster_remove_segment` functions to help you do this.

There are many prompt segments available that are not enabled by default. See the source code or [User Guide](https://github.com/apjanke/agnosterj-zsh-theme/blob/master/doc/UserGuide.md) for options!

Optional segments include:

* `newline`
* `k8s`
* `aws`
* `azure`
* `gcp`
* `filesystem`
* `random_emoji`
* `blank`
* `hg`
* `k8s`

### Examples

* Show all segments of the prompt with indices:
```zsh
echo "${(F)AGNOSTER_PROMPT_SEGMENTS[@]}" | cat -n
```
* Add a new segment to the end:
```zsh
agnoster_add_segment aws
```
* Add a segment or segments to the beginning or other position:
```zsh
agnoster_add_segment 1 aws
agnoster_add_segment 5 aws
agnoster_add_segment 5 aws gcp azure
```
* Remove segments:
```zsh
agnoster_remove_segment 5
agnoster_remove_segment aws gcp azure
```
* Show prompt segments and other AgnosterJ options:
```zsh
agnoster_setopt
```

A small demo of a dummy custom prompt segment, which has been created with help of the `prompt_segment()` function from AgnosterJ:

```zsh
# prompt_segment() - Takes two arguments, background and foreground.
# Both can be omitted (by passing an empty argument), rendering 
# default background/foreground.

customize_agnoster() {
  prompt_segment 'red' '' ' ⚙ ⚡⚡⚡ ⚙  '
}
```

![Customization demo](doc/images/agnoster_customization.gif)

## Future Work

It’s currently hideously slow, especially inside a git repo. I guess it's not overly so for comparable themes, but it bugs me, and I‘d love to hear ideas about how to improve the performance.

The dependency on a powerline-patched font is regrettable, but there’s really no way to get that effect without it. Ideally there would be a way to check for compatibility, or maybe even fall back to one of the similar unicode glyphs. At least nowadays iTerm2 has Powerline icon support built in.

## License

The AgnosterJ licensing situation is a little unclear. This is because the upstream Agnoster Zsh Theme [does not have a license](https://github.com/agnoster/agnoster-zsh-theme/issues/42). But it’s clearly meant for public consumption, so I’m assuming that making this fork is fine, and it's okay to redistribute that code.

The AgnosterJ additions to Agnoster are licensed under the [MIT License](https://opensource.org/licenses/MIT).

If Agnoster gets around to choosing a particular open source license, I will add dual-licensing to AgnosterJ so it is covered under that license as well.

## Author

[Agnoster](https://github.com/agnoster/agnoster-zsh-theme) was originally written by Isaac Wolkerstorfer ([agnoster](https://github.com/agnoster) on GitHub). Thanks to Isaac for writing this neat tool!

The AgnosterJ fork is maintained by [Andrew Janke](https://apjanke.net) ([apjanke](https://github.com/apjanke) on GitHub).

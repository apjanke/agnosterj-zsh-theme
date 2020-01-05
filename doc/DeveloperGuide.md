AgnosterJ Developer Guide
=========================

This is the Developer Guide for AgnosterJ. This is for people who want to hack on AgnosterJ itself. If you’re a user and want to know how to use AgnosterJ in your shell, see the [User Guide](https://github.com/apjanke/agnosterj-zsh-theme/blob/master/doc/UserGuide.md) instead.


TODO: Put stuff here.

# Code style

## Formatting

* 2-space indents
* `snake_case` identifier names

## Programming practice

* Use `local` variables everywhere
* Configuration variable settings should take effect at any time, not just upon loading of the theme.
* TODO: Should we `emulate -z` in functions?

# Defining new segments

A segment is implemented by a `prompt_<segment>` function. For example, if your segment is named `foo`, then you need to write a `prompt_foo` function. This function will be called when it’s time to write your segment.

Segment functions need to call the `prompt_segment` function. Usage:

```
  prompt_segment <background> <foreground> <contents>
```

You can pass an empty value (`''`) to `background` or `foreground` to have it use the defaults.

You also need to add the name of your segment to the `$AGNOSTER_KNOWN_SEGMENT_NAMES` list at the top of the file.

If your segment has configuration options, they should be set in configuration variables starting with `$AGNOSTER_`, and preferably starting with `$AGONSTER_<YOUR_SEGMENT_NAME>_`. These variables should be added to the `$AGNOSTER_DEFAULT_OPTS` variable and the options variable list in `agnoster_setopt`.

# Producing the demos

Here’s how I produce the screencaps used in the doco.

## Script for the main example screenshot

## Script for the animated "customizing" example

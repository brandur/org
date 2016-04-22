At its core, Tmux may seem like a basic terminal multiplexer in the same vein of Scree, but with the application of some more sophisticated patterns, it quickly becomes so much more. Tmux can become akin to a tiling window manager for terminal sessions, which can lead to it becoming an integrated environment for all your development work. Like other terminal programs it's fast, offers hugely rich functionality, has a somewhat steep learning curve, but these attributes ultimately lead to very precise and efficient operation.

This article assumes that you've got Tmux installed and understand its basic like getting yourself into a session. If you want to try something a little easier, I wrote an article a few years back called [Practical Tmux](http://mutelight.org/practical-tmux) that may help you get bootstrapped.

## Configuration

I'm assuming that most people have Tmux configuration, so I'll only cover what I believe are the most important points to make note of.

### Prefix

A fast Tmux prefix shortcut is key to fast operation. The default of `C-b` is slow, and subtly raises the bar to Tmux operation.

I personally use and recommend the use of the Caps Lock key as prefix. The presence of such a useless function in such an important spot on the keyboard makes this a great candidate for which to remap an important key.

Setting this up will vary by system, but on OSX this looks like downloading [Seil](https://pqrs.org/osx/karabiner/seil.html.en) and using it to remap Caps Lock to F10. From there, remap your prefix to F10:

```
set-option -g prefix F10
```

### Fast Escapes

```
set -s escape-time 0
```

### Aggressive Resize

```
setw -g aggressive-resize on
```

### New Shells at Current Path

```
bind c new-window -c '#{pane_current_path}'
bind "\"" split-window -c '#{pane_current_path}'
bind "\%" split-window -h -c '#{pane_current_path}'
```

### URLView

```
bind-key u capture-pane \; save-buffer /tmp/tmux-buffer \; \
  new-window -n "urlview" '$SHELL -c "urlview < /tmp/tmux-buffer"'
```

## Pane & Window Management

## Layouts

## Organizational Patterns

## Fast Pane Movement

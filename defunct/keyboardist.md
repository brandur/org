During the course of career in computing, I've gone from laughing derisively at movies like Hackers (1995) and Swordfish (2001) where characters hacked into things by banging away on their keyboards (who actually did anything without a mouse in those days?), to personally avoiding the mouse as much as possible.

What's wrong with the mouse you ask? Well, the mouse is a fine device, but the keyboard has a couple major strengths that it will never possess:

* Precision: There is no ambiguity when striking a key on a keyboard. When a touch typist hits puts their finger down, they know exactly whether they've hit or missed they key they were looking for. This allows a user to operate a computer more quickly as they don't have to wait for any on-screen visual feedback — the tactile experience derived from pushing buttons is enough.
* Speed: There is no travel time (or negligible at any rate) between button pushes on a keyboard — unlike the cursor which must trek its way across a 27" monitor to its next target. Key presses are even started before their predecessors are fully complete, allowing for pipelined input.

The following are a list of critical tools for moving to a keyboarding only environment.

1. Vim: The cornerstone of many power users, Vim is the first step in any keyboardist's progression. Not only is it the last text editor that you'll ever use, but it also provides a set of key bindings that have been adopted by countless other applications to such an extent that they've become the lingua franca of modal editing.
    
    A number of other editors and IDEs advertise as Vim replacements, but so far I've never seen a case where one provides the full vocabulary of the original, or the same power enabled by its command chaining and extensibility. Vim still reigns supreme.
    
    There are too many useful Vim plugins to count, but there are a few that are so universal that they deserve special mention:
    
    1. **Vundle:** A plugin management system. Define the names of plugins or their repositories and Vundle will handle the rest.
    2. **Ctrl-P:** A powerful fuzzy file finder implemented only in Vimscript, making it extremely portable.
    
2. **Tmux:** Starts out as yet another terminal multiplexer, but becomes a powerful tiling window manager for your shells by the end of the road. It's pretty easy to get started with the basics, but don't ignore the more advanced features like panes for too long.

    1. [Caps lock as Tmux prefix](https://mutelight.org/caps-lock).
    
3. Z shell: A powerful shell. Comparable to Bash, but better in all the ways that count: better extensibility, more fluid in day to day use, and more reasonable defaults.
    
    1. **oh-my-zsh:** A zsh bootstrap that will get you up and running on it more quickly than otherwise.
    
4. Vimperator: After getting used to a powerful keyboarding environment, the supreme inefficiency of navigating the web with a mouse comes into stark contrast. Bring the power of Vim to Firefox and the web with Vimperator.
    
    Chrome has a few similar plugins, but Firefox's more powerful plugin system really shines for this type of use. So far I've never used another system that approaches the same fluidity as Vimperator.
    
5. Emacs shortcuts: Many shells have a vi mode that can be enabled, but it's often slow to activate compared to the equivalent Emacs shortcut. Here are a few that I use every day.
    
    * C-a: Move to the beginning of the line.
    * C-e: Move to the end of the line.
    * C-w: Erase the last word.
    * C-u: Erase the entire line.
    * M-b: Move back one word.
    * M-f: Move forward one word.
    
6. Mutt: Although many useful plugins are available for Gmail, its power is still underwhelming compared to a real e-mail client. Much like Vim, Mutt may be old, but it's still the best out there and is the one ultimate key for dealing with high or low volumes of e-mail with no mouse required.
    
    Unfortunately despite being highly configurable, it specializes in unreasonable defaults at every turn, so it'll require a fair bit of wrangling to get into shape.
    
7. Irssi: Although a simple IRC client on the surface, Irssi will eventually become your powerful gateway to IRC and every other network on which you care to communicate (see the section on Bitlbee below).
    
    1. M-a: Irssi's number one killer feature. Cycles through windows that need your attention first in order of priority, then by when they were activated. One simple shortcut to sweep all outstanding communication at once.
    2. wlstat.pl: Gives Irssi a more powerful status bar with names for every window. Critical for managing a large number of open dialogs in Irssi.
    3. window_switcher.pl: Provides a shortcut for jumping between windows by entering a fuzzy match.
    
8. Bitlbee: An IRC gateway that runs as a daemon and enables access to a large number of chat networks and protocols including XMPP (Google Talk), MSN, ICQ, and even Twitter! Bitlbee and Irssi are a killer combination.
    
9. curl: Although maybe not something that everyone will use daily, I'm including curl as its a veritable Swiss Army knife for any data transfer that involves a URL.
    
10. youtube-dl: A personal favorite that allows Youtube and Vimeo videos to be downloaded from the command line, and then opened in a keyboard friendly viewer like mplayer.
    
    Web plugins like Flash are infamous for stealing keyboard focus, and forcing users to resort to the mouse to get it back. With youtube-dl, Flash can be completely removed from your everyday browser and you'll never run into this problem.
    
11. urlview: Parses URLs from text. Very powerful when combined with Tmux.

## Domain-specific Tools

Although certainly a part of my everyday toolset, I've included these tools separately because they may not be relevant to everyone's day-to-day activities:

1. ag: (A.K.A. The Silver Searcher) Grep with an order of magnitude of better usability. Mostly applicable to developers as its main function is searching code.
2. psql: The powerful interactive client bundled by and for use with Postgres. Pay special attention to the \e command which pulls up your last query in $EDITOR, allowing you to bring the power of Vim to SQL.

## OS X

There are a lot of OS X users out there these days, so it would be remiss of me not to add a few key apps for this platform:

1. reattach-to-user-namespace: A bootstrap program critical on Mac OS X to make sure that you can properly interact with the system clipboard from inside a Tmux session.
2. iTerm2: A terminal app with many improvements over Apple's bundled Terminal.app.
3. Divvy: A utility that allows windows to be resized and repositioned on the desktop from the keyboard. It may be a far shot from the tiling window managers available for Linux, but it's nonetheless very useful when you're on a Mac.

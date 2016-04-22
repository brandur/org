
## ssh-agent:

* It's not the end of the world if more than one agent is spun up.

## gpg-agent

```
#!/bin/sh

gnupginf="$HOME/.gpg-agent-info"

if pgrep -x -u "$USER" gpg-agent >/dev/null 2>&1; then
    eval `cat $gnupginf`
    eval `cut -d= -f1 $gnupginf | xargs echo export`
else
    eval `gpg-agent -s --daemon --write-env-file "$gnupginf"
fi
```

Problems with gpg-agent's model:

* Old shells are left with stale agent socket data when an old agent must be killed.

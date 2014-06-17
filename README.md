# aliases

Collection of personal shell aliases that I like.

## Easy installation on Linux

```
curl -fsSL https://raw.githubusercontent.com/hachre/aliases/master/install.sh | bash
```

This will automatically install the git repo to /usr/local/hachre/aliases.

It will also hook up the aliases at /etc/profile.d/hachreAliases.sh and
automatically get them running in your current shell.

To uninstall use the ./remove.sh script in /usr/local/hachre/aliases.

To update use the ./update.sh script.

## Manual installation

If you don't like things to automatically happen to your system, or you're
running OS X, here are the manual installation steps:

```
git clone https://github.com/hachre/aliases
ln -s /path/to/aliases/source/aliases.sh /etc/profile.d/hachreAliases.sh
source /etc/profile
```

You can verify that the aliases are running by entering 'hachreAliases'.

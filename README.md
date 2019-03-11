# Vítor’s dotfiles

### Install everything
```
bash -c "$(curl -fsSL 'https://raw.github.com/vitorgalvao/dotfiles/master/install.sh')"
```

### Organisation
This repo’s may be named `dotfiles` but it doesn’t contain any. A separate app handles backup and restoration of those. These are a series of modular scripts that intend to be useful beyond setting up a new machine.

Everything is modular. The most important parts of the repo’s file structure are:

```
.
├── install.sh
├── scripts
└── files
```

`scripts` is a directory that contains shell scripts to be `source`d. None will do anything if ran on their own: they consist of structured functions to perform tasks. `files` contains configurations to be applied manually and files to support the installation scripts. Finally, `install.sh` is what brings it all together in an automated fashion. It’s the only script that should be run directly.

Script functions are organised in logical sequence. Operations range from support, to the installation as a whole, to useful on their own. The latter is where the modularity shines.

If, say, we wish to [repeat the python setup process](https://github.com/vitorgalvao/dotfiles/blob/c9129b1dd70032c79df958985b854834ea2d62bf/scripts/environments.sh#L13), or [reset default apps in a particular manner](https://github.com/vitorgalvao/dotfiles/blob/c9129b1dd70032c79df958985b854834ea2d62bf/scripts/configure_tools.sh#L22), we need only source the appropriate scripts (don’t forget [the helpers](https://github.com/vitorgalvao/dotfiles/blob/master/scripts/helper_functions.sh)) and run the respective functions. Functions are built such that running them more than once should have no adverse effects.

This allows for a flexible arrangement where we need only make sure the functions are up to date. Those we want to run outside the system setup can be built around the scripts, loading and executing the appropriate commands.

#### License
The Unlicense (Public Domain, essentially)

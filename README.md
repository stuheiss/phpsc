# phpsc
phpsc is a php-style-checker

phpsc is a wrapper that depends on phpcs, phpmd, and phpcpd.
It will run all tools on one or more files and exit 0 if your code is clean or non-zero otherwise.
A git pre-commit hook and installer is also provided.

## Automated installation

Save phpsc-install.sh in /usr/local/bin/phpsc-install.sh for easy reuse and make it exectuable. Now, simply run "phpsc-install.sh install" in the base directory of a git repo to enable the pre-commit hook. **This is the preferred workflow.**

### Details

Run "phpsc-install.sh install" in the base directory of a git repo for automated installation of the git pre-commit hook.

Run "phpsc-install.sh uninstall" in the base directory of a git repo to remove the git pre-commit hook.

Run "phpsc-install.sh help" for more info on this tool.  

Note, the pre-commit hook does not require the standalone tool described below.

Note, the pre-commit hook will only check staged files. This allows you to work on an old codebase with many problems and fix them incrementally. You will only need to fix all the problems in any file that will be committed.

## Manual installation
**Note, automated installation described above is preferred and does not require the standalone tool. The following describes how to install the standalone tool if desired.**

You can use phpsc as a standalone tool like:  
$ phpsc /path/to/file.php  
$ phpsc /path/to/directory/of/php/files

In other words, give it a path and it will figure out what to do.

Use -v to increase verbosity.  
Use -s to be silent.

Default options for each tool can be overriden by the environment. Run phpsc with no arguments for example usage.

Hook into your git repo to have phpsc enforce clean code. Note: pre-commit.sample.style_checkers has all logic built-in and does not use stand-alone cli phpsc.

1. copy pre-commit.sample.style_checkers to .git/hooks/pre-commit and chmod to 755
2. make sure you have phpcs, phpmd, and phpcpd installed

Now try to commit a php file that doesn't conform to psr2 and watch your commit get aborted.
Next, clean up your code and keep trying to commit until you succeed.
Finally, show off your beautiful code to all your friends!

If you need phpcs, phpmd, phpcpd and use a mac, do:

1. ensure homebrew is installed (see http://brew.sh/)
2. $ brew install phpcs
3. $ brew install phpmd
4. $ brew install phpcpd

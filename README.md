# phpsc
php-style-checker
phpsc is a php-style-checker

phpcs is a wrapper that depends on phpcs and phpmd.
It will run both tools on one or more files and exit 0 if your code is clean or non-zero otherwise.

You can use phpcs as a standalone tool like:
$ phpcs /path/to/file.php
$ phpcs /path/to/directory/of/php/files

In other words, give it a path and it will figure out what to do.

Use -v to increase verbosity.
Use -s to be silent.

Hook phpcs into your git repo to have it enforce clean code.

1. copy pre-commit.sample.phpsc to .git/hooks/pre-commit and chmod to 755
2. copy phpsc to somewhere in your path
3. make sure you have phpcs and phpmd installed

Now try to commit a php file that doesn't conform to psr2 and watch your commit get aborted.
Next, clean up your code and keep trying to commit until you succeed.
Finally, show off your beautiful code to all your friends!

If you need phpcs and phpmd, and use a mac, do:
1. ensure homebrew is installed (see http://brew.sh/)
2. $ brew install phpcs
3. $ brew install phpmd


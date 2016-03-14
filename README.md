# phpsc
phpsc is a php-style-checker

phpsc is a wrapper that depends on phpcs, phpmd, and phpcpd.
It will run all tools on one or more files and exit 0 if your code is clean or non-zero otherwise.

You can use phpsc as a standalone tool like:  
$ phpsc /path/to/file.php  
$ phpsc /path/to/directory/of/php/files

In other words, give it a path and it will figure out what to do.

Use -v to increase verbosity.  
Use -s to be silent.

Hook into your git repo to have it enforce clean code. Note: pre-commit.sample.style_checkers has all logic built-in and does not use phpsc.

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

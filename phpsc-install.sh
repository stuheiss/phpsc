#!/bin/sh

style_checkers=(phpcs phpmd phpcpd)

function usage() {
    echo "Usage: $0 { install | uninstall | help }"
    exit 1
}
function help() {
    echo "This utility enables php style checkers to run on pre-commit and abort the commit if you have style problems."
    echo "It requires the following tools (in your PATH) to function: ${style_checkers[@]}."
    echo "If you need to install any of these tools on a mac, do:"
    for checker in ${style_checkers[@]}; do
        echo "  brew install $checker"
    done
    echo "If you need to install homebrew on a mac, visit http://brew.sh/"
    echo "For other operating systems, please use the appropriate installer for the required tools."
    echo "If all tools are available, installation of the pre-commit hook will proceed."
    echo "If any tools are not available, this installer will explain the problem and abort installation."
    exit 0
}
function pre_commit_hook_contents() {
cat << 'EOS'
#!/bin/bash
# PHPMD pre-commit hook for git
#
# see the README

# PHPMD Mandatory arguments:
# 1) A php source code filename or directory. Can be a comma-separated string
# 2) A report format
# 3) A ruleset filename or a comma-separated string of rulesetfilenames

# Available formats: xml, text, html.
# Available rulesets: cleancode, codesize, controversial, design, naming, unusedcode.

# Optional arguments that may be put after the mandatory arguments:
# --minimumpriority: rule priority threshold; rules with lower priority than this will not be used
# --reportfile: send report output to a file; default to STDOUT
# --suffixes: comma-separated string of valid source code filename extensions
# --exclude: comma-separated string of patterns that are used to ignore directories
# --strict: also report those nodes with a @SuppressWarnings annotation

exec 1>&2
DEBUG=false

phpcs_opts='--standard=psr2'
phpmd_opts='text cleancode,codesize,controversial,design,naming,unusedcode'
phpcpd_opts='-n'

vflg=true # verbose
sflg=false # silent

phpcs_bin=$(command -v phpcs)
phpmd_bin=$(command -v phpmd)
phpcpd_bin=$(command -v phpcpd)

# use these checkers in this order
style_checkers=(phpcs phpmd phpcpd)

# abort furter checks on a given file if short_circuit_abort is true
short_circuit_abort=true

TMP_STAGING='.tmp_staging'

# parse config
CONFIG_FILE=$(dirname $0)/config
test -e $CONFIG_FILE && . $CONFIG_FILE

# check one filespec using configured checkers
function checkOne
{
    local f="$1"
    local ec=0
    local rc=0

    ${DEBUG:-false} && echo "#dbg f=$f"
    n_checkers=${#style_checkers[@]}
    for checker in ${style_checkers[@]}; do
        ${vflg:-false} && echo "# checker $checker of $style_checkers"
        n_checkers=$((n_checkers - 1))
        case $checker in
            phpcs)
                test -n "$phpcs_bin" && {
                    ${vflg:-false} && echo "# phpcs $phpcs_opts $f"
                    $phpcs_bin $phpcs_opts $f
                    rc=$?
                    ec=$((ec | rc))
                    ${vflg:-false} && echo "# phpcs returns $rc"
                }
                ;;
            phpmd)
                test -n "$phpmd_bin" && {
                    f2=$(echo $f | sed -e 's/^ *//' -e 's/ /,/g')

                    ${vflg:-false} && echo "# phpmd $f2 $phpmd_opts"
                    $phpmd_bin $f2 $phpmd_opts
                    rc=$?
                    ec=$((ec | rc))
                    ${vflg:-false} && echo "# phpmd returns $rc"
                }
                ;;
            phpcpd)
                test -n "$phpcpd_bin" && {
                    ${vflg:-false} && echo "# phpcpd $phpcpd_opts $f"
                    $phpcpd_bin $phpcpd_opts $f
                    rc=$?
                    ec=$((ec | rc))
                    ${vflg:-false} && echo "# phpcpd returns $rc"
                }
                ;;
        esac
        ${short_circuit_abort:-false} && test $n_checkers != 0 && test $ec != 0 && {
            ${vflg:-false} && echo "# short circuit return: $checker check $f failure"
            return $ec
        }
    done

    return $ec
}

# stolen from template file
if git rev-parse --verify HEAD
then
    against=HEAD
else
    # Initial commit: diff against an empty tree object
    against=4b825dc642cb6eb9a060e54bf8d69288fbee4904
fi

# this is the magic: 
# retrieve all files in staging area that are added, modified or renamed
# but no deletions etc
FILES=$(git diff-index --name-only --cached --diff-filter=ACMR $against -- )

test -z "$FILES" && exit 0

# check against whitelist/blacklist here
# save files to check in FILES_TO_CHECK

# file must have extension .php
for f in $FILES; do
    echo "$f" | grep '\.php$' >/dev/null && FILES_TO_CHECK="$FILES_TO_CHECK $f"
done

test -z "$FILES_TO_CHECK" && exit 0

# Copy contents of staged version of files to temporary staging area
# because we only want the staged version that will be commited and not
# the version in the working directory
STAGED_FILES=""
# create temporary copy of staging area
test -e $TMP_STAGING && rm -rf $TMP_STAGING
trap 'rm -rf $TMP_STAGING; exit' 0 1 2 3 15
mkdir $TMP_STAGING

for FILE in $FILES_TO_CHECK
do
  ID=$(git diff-index --cached $against $FILE | cut -d " " -f4)

  # create staged version of file in temporary staging area with the same
  # path as the original file so that the phpmd ignore filters can be applied
  mkdir -p "$TMP_STAGING/$(dirname $FILE)"
  git cat-file blob $ID > "$TMP_STAGING/$FILE"
  STAGED_FILES="${STAGED_FILES} ${TMP_STAGING}/${FILE}"
done

OUTPUT=$(checkOne "$STAGED_FILES")
RETVAL=$?

if [ $RETVAL -ne 0 ]; then
    echo "$OUTPUT" | sed "s;${TMP_STAGING}/;;g" | ${PAGER:-cat}
fi

exit $RETVAL
EOS
}
function ensure_git_repo() {
    test -d .git/hooks || { echo "Not in the base dir of a git repo, please change to the base dir and re-run this script; aborting."; exit 1; }
}
function uninstall() {
    ensure_git_repo
    test -f .git/hooks/pre-commit || { echo "No pre-commit hook found; aborting."; exit 1; }
    rm -f .git/hooks/pre-commit
    echo "Pre-commit hook removed."
}
function install() {
    ensure_git_repo
    test -f .git/hooks/pre-commit && { echo "Existing pre-commit hook found, please run \"$0 unistall\" first and then re-run this script; aborting."; exit 1; }
    for checker in ${style_checkers[@]}; do
        type -p $checker >/dev/null && continue
        echo "$checker not found, please install it and re-run this script; aborting."
        exit 1
    done
    pre_commit_hook_contents > .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "Pre-commit hook installed."
}

test $# = 1 || usage
case $1 in
install)
    install
    ;;
uninstall)
    uninstall
    ;;
help) help;;
*) usage;;
esac

exit 0

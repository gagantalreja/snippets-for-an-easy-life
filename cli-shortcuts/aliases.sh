# colors
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
NC='\033[0m' # No Color

## ls -lart shortcut
alias ll='ls -lart --color=always'

## git
alias cb='echo "$(git branch | grep "*" | tr -d "*" | xargs)"' # get current branch
alias sb='echo "Switching to branch ${GREEN}${1}${NC}" && git checkout $1' # switch to a branch
alias nb='echo "Creating branch ${GREEN}$1${NC} and switching to it" &&  git checkout -b $1' # create a new branch and switch to it
alias lb='git branch' # list all branches in the repo

alias gadd='git add "$1"'
alias gpull='git pull origin $(cb)' # git pull from remote for current branch
alias gpush='git push origin $(cb)' # git push to remote for current branch
alias gcommit='git commit -m $1' # git commit with message
alias gamend='git commit --amend' # git amend previous commit


## terraform
alias tf=terraform

# to initialise a new terraform directory with the files that are generally required
alias tfdir='touch main.tf data.tf variables.tf locals.tf version.tf output.tf'

## python

# generate a random string with a given number of characters
alias random="python3 -c 'import string; import random; import sys; print(\"\".join(random.choices(string.ascii_uppercase + string.ascii_lowercase + string.digits, k=int(sys.argv[1]))))'"

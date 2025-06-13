# colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

## kubernetes
alias k=kubectl

# get current kubectl context with index numbers. If a context name is also provided as an argument, switch to that context
function get-ctx() {
  curr_ctx=$(kubectl config current-context)
  idx=1

  for c in $(kubectx); do
    if [[ "$c" = "$curr_ctx" ]]; then
      echo "${YELLOW}$idx${NC} ${YELLOW}$c${NC}"
    else
      echo "${YELLOW}$idx${NC} $c"
    fi
    ((idx = idx + 1))
  done
}

function set-ctx() {
  idx=1
  for c in $(kubectx); do
    if [[ "$idx" = "$1" ]]; then
      kubectx $c
      break
    else
      ((idx = idx + 1))
    fi
  done
}

# get namespaces of the cluster in current context with index numbers. If a namespace name is also provided as an argument, switch to that namespace

function get-ns() {
  curr_ns=$(kubectl config view --minify -o jsonpath='{..namespace}')
  idx=1

  for n in $(kubens); do
    if [[ "$n" = "$curr_ns" ]]; then
      echo "${YELLOW}$idx${NC} ${YELLOW}$n${NC}"
    else
      echo "${YELLOW}$idx${NC} $n"
    fi
    ((idx = idx + 1))
  done
}

function set-ns() {
  idx=1
  for n in $(kubens); do
    if [[ "$idx" = "$1" ]]; then
      kubens $n
      break
    else
      ((idx = idx + 1))
    fi
  done
}

# Shortcut to the context-switch function

function kx() {
  if [[ -z "$1" ]]; then
    get-ctx
  else
    set-ctx $1
  fi
}

# Shortcut to the ns-switching function

function kn() {
  if [[ -z "$1" ]]; then
    get-ns
  else
    set-ns $1
  fi
}

function kg() {
  args=("${@}")
  k get "${args[@]}"
}

# Shortcut to remove cluster from context
function kxr() {
  idx=1
  for c in $(kubectx); do
    if [[ "$idx" = "$1" ]]; then
      yq eval -i "del(.clusters.[] | select(.name == \"$c\"))" ~/.kube/config
      yq eval -i "del(.contexts.[] | select(.name == \"$c\"))" ~/.kube/config
      yq eval -i "del(.users.[] | select(.name == \"$c\"))" ~/.kube/config
      echo "Removed ${YELLOW}$c${NC} from kube-context"
      break
    else
      ((idx = idx + 1))
    fi
  done
}

# If you have multiple kots versions installed, using the following function
# you can point to a version you want to use. Just run kotsv <version-number>

function kotsv() {
  if [[ $(ll /usr/local/bin/kubectl-kots-v* | grep -c $1) == "0" ]]; then
    echo "kots version v$1 not found in /usr/local/bin/"

  else
    sudo rm /usr/local/bin/kubectl-kots
    sudo ln -s /usr/local/bin/kubectl-kots-v$1 /usr/local/bin/kubectl-kots
    echo "Kots version reset. New version is: ${GREEN}$(kubectl kots version)${NC}"
  fi
}

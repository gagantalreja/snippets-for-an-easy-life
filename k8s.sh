# colors
GREEN='\033[0;32m';
YELLOW='\033[0;33m';
NC='\033[0m' # No Color

## kubernetes
alias k=kubectl

# get current kubectl context with index numbers. If a context name is also provided as an argument, switch to that context
function get-ctx() {
	curr_ctx=`kubectl config current-context`
        idx=1;


	for c in $(kubectx); do
                if [[ "$c" = "$curr_ctx" ]]; then
			echo "${YELLOW}$idx${NC} ${YELLOW}$c${NC}";
		else
			echo "${YELLOW}$idx${NC} $c";
		fi
                ((idx=idx+1));
        done;
}

function set-ctx() {
	idx=1;
        for c in $(kubectx); do
		if [[ "$idx" = "$1" ]]; then
			kubectx $c;
			break;
		else
			((idx=idx+1));
		fi
	done;
}

# get namespaces of the cluster in current context with index numbers. If a namespace name is also provided as an argument, switch to that namespace

function get-ns() {
        curr_ns=`kubectl config view --minify -o jsonpath='{..namespace}'`
        YELLOW='\033[0;33m';
        NC='\033[0m' # No Color
        idx=1;


        for n in $(kubens); do
                if [[ "$n" = "$curr_ns" ]]; then
			echo "${YELLOW}$idx${NC} ${YELLOW}$n${NC}";
		else
                	echo "${YELLOW}$idx${NC} $n";
		fi
                ((idx=idx+1));
        done;
}

function set-ns() {
        idx=1;
        for n in $(kubens); do
                if [[ "$idx" = "$1" ]]; then
                        kubens $n;
                        break;
                else
                        ((idx=idx+1));
                fi
        done;
}


# Shortcut to the context-switch function

function kx() {
	if [[ -z "$1" ]]; then
		get-ctx;
	else
		set-ctx $1;
        fi
}

# Shortcut to the ns-switching function

function kn() {
        if [[ -z "$1" ]]; then
                get-ns;
        else
                set-ns $1;
        fi
}

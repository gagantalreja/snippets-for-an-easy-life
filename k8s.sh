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

# Shortcut to remove cluster from context
function kxr() {
        idx=1;
        for c in $(kubectx); do
		if [[ "$idx" = "$1" ]]; then
			yq eval -i "del(.clusters.[] | select(.name == \"$c\"))" ~/.kube/config
                        yq eval -i "del(.contexts.[] | select(.name == \"$c\"))" ~/.kube/config
                        yq eval -i "del(.users.[] | select(.name == \"$c\"))" ~/.kube/config
                        echo "Removed ${YELLOW}$c${NC} from kube-context";
			break;
		else
			((idx=idx+1));
		fi
	done;
}


# get pod identifier
# usage : pod <namespace> <service-name>
function pod() {
        cands=`kubectl -n $1 get pods| grep -v 'No resources found' | grep Running | awk '{print $1}'`
        (echo "$cands" | grep ^$2-$1) ||  (echo "$cands" | grep ^$2) ||  (echo "$cands" | grep ^$1) ||  (echo "$cands" | grep $1)
}

# get log for the pod given
# usage : log <namespace> <service-name>
function log() {
        pod=`pod $1 $2`
        kubectl -n $1 logs -c $2 $pod -f
}

# log forwarding
# usage : lf <namespace> <service-name>
function lf() {
        pod=`pod $1 $2`
        if [[ -z "$pod" ]]; then
                echo "no pod found in namespace $1 name $2. Searched for prefix $2-$1" >&2
        else
                kubectl -n $1 logs --tail=1 -c $2 -f $pod
        fi
}

# port forwarding
# usage : pf <namespace> <service-name> 8080:8080
function pf() {
        pod=`pod $1 $2`
        if [[ -z "$pod" ]]; then
                echo "no pod found in namespace $1 name $2" >&2
        else
                echo "forwarding port from $pod container $2 $3" >&2
                kubectl -n $1 port-forward $pod $3
        fi
}
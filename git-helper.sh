#!/usr/bin/env sh

SCRIPT_NAME=`basename $0`
GIT_REPO_PATH=
GIT_HASH=

OPTIND=1

OUTPUT_LIMIT=0

function Usage {
	echo "$SCRIPT_NAME -p [git_path] -H [HASH] -n [LIMIT]"
	echo " -H - show particular commit identified by [HASH]"
	echo " -p - set gith path to [git_path]"
	echo " -n - show only [LIMIT] last commits"
}

while getopts "h?p:H:n:" opt; do
    case "$opt" in
		n)
			OUTPUT_LIMIT=$OPTARG
			;;
		h|\?)
			Usage
			exit 0
			;;
		p)  GIT_REPO_PATH=$OPTARG
			;;
		H)  GIT_HASH=$OPTARG
			;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

function git_repo_list {
	local limit=$1
	local git_path=$2
	local hash=`echo $3 | tr '[:upper:]' '[:lower:]'`
	local count=0
	local branch=

	echo "Checking for git repo at $git_path"

	branch=`git -C $git_path rev-parse --abbrev-ref HEAD`
	count=`git -C $git_path rev-list HEAD --count`

	echo $branch

	if [ -z "$hash" ]; then
		git -C $git_path rev-list HEAD --timestamp --pretty=oneline | \
			awk -v LIMIT=$limit -v TOTAL=$count -v BRANCH=$branch '
BEGIN{i=0}{
  i++;
  REV=(TOTAL+1-i);
  if (LIMIT == 0 || REV > (TOTAL-LIMIT))
    printf "%6d - %s %28.28s - [ %s@%d-%6.6s ]\n", REV,$2,substr($0, index($0,$3)),BRANCH,REV,$2
}'
	else
		git -C $git_path rev-list HEAD | \
			awk -v TOTAL=$count '
BEGIN{i=0}{
  i++;
  REV=(TOTAL+1-i)
  print REV,$1
}' | grep $hash
	fi

	echo "Latest revision is $count"
}

if [ -z "$GIT_REPO_PATH" ]; then
	if [ -f ".git" ] || [ -d ".git" ]; then
		GIT_REPO_PATH=.
	else
		Usage
		exit 0
	fi
fi

git_repo_list $OUTPUT_LIMIT $GIT_REPO_PATH $GIT_HASH

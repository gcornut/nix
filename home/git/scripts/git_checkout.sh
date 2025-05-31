#!/usr/bin/env bash

all=$([[ $1 = "-a" ]] && echo "-a");
[[ "$all" = "-a" ]] && shift
if [[ -z "$@" ]]; then
	git checkout $(git branch $all | fzf +s +m -e --height 11 --layout reverse | sed "s:.* remotes/origin/::" | sed "s:.* ::")
	[[ "$all" = "-a" ]] && gt track
else
	git checkout $@
fi

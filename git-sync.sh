#!/bin/bash
# ----------------------------------------------------------------------
# Pulls into all of my local repositories from the respective remote
# ones.
# ----------------------------------------------------------------------

pushd -n . >/dev/null

find ~ -name ".git" -type d | \
while read dir
do
    git_dir=$(dirname "${dir}")
    cd "${git_dir}"
    if [ -z "$(git config --get-regexp 'remote.*.fetch')" ]
    then
        printf "No remote repository defined for %s\n" "${git_dir}"
    else
        printf "Pull from remote into %s\n" "${git_dir}"
        git pull
    fi
done

popd >/dev/null

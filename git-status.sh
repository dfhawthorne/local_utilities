#!/bin/bash
# ----------------------------------------------------------------------
# Shows the short status of all of my local repositories.
# ----------------------------------------------------------------------

pushd -n . >/dev/null

find ~ -name ".git" -type d | \
while read -r dir
do
    git_dir=$(dirname "${dir}")
    cd "${git_dir}" || continue
    printf "Status of GIT repository (%s)\n" "${git_dir}"
    git status --short --branch
done

popd >/dev/null || exit

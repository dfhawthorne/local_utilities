#!/bin/bash
# ----------------------------------------------------------------------
# Pulls into all of my local repositories from the respective remote
# ones.
# ----------------------------------------------------------------------

pushd -n .

for dir in $(find ~ -name ".git" -type d)
do
    git_dir=$(dirname ${dir})
    cd ${git_dir}
    git pull
done

popd

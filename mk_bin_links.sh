#!/usr/bin/env bash
# -------------------------------------------------------------------------------------
# Creates links to executables in local utilities
# --------------------------------------------------------------------------------------

mkdir -p ~/bin

cur_dir="$(dirname """$0""")"
while IFS= read -r -d '' file
do
    link=~/bin/"$(basename """${file}""")"
    if [[ ! -a "${link}" ]]
    then
        real_path="$(realpath """${file}""")"
        printf "Create link %s to %s ...\n" "${link}" "${real_path}"
        ln -s "${real_path}" "${link}" 
    fi
done < <(find "${cur_dir}" -maxdepth 1 -type f -executable -print0)

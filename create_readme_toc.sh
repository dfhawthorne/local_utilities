#!/usr/bin/env bash
# -------------------------------------------------------------------------------------
# Creates a table of contents (TOC) based on the H1 line from all markdown files in
# the current directory. This TOC is printed on the stdout.
# -------------------------------------------------------------------------------------

while read -e file_name
do
    file_name=$(basename "${file_name}")
    [[ "${file_name}" = "README.md" ]] && continue
    base_name=$( \
        basename "${file_name}" .md | \
        sed -e 's/_/-/g' \
        )
    header=$( \
        head -n 1 "${file_name}" | \
        sed -Ee "s/^(# )?${base_name}:?( -)? //" \
        )
    printf '* [%s](%s) ' "${base_name}" "${file_name}"
    printf "${header}\n"
done < <( \
    find . -maxdepth 1 -name "*.md" -type f | \
    sort \
    )

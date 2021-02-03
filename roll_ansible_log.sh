#!/usr/bin/env bash
# -------------------------------------------------------------------------------------
# Move current Ansible log to a new name based on current date
# --------------------------------------------------------------------------------------

while IFS= read -r -d '' log_dir
do
    log_name="${log_dir}/ansible.log"
    if [[ ! -a "${log_name}" ]]
    then
        continue
    fi
    new_name="${log_dir}/ansible-$(date --iso-8601=date).log"
    if [[ -x "${log_dir}" ]]
    then
        if [[ -w "${log_name}" ]]
        then
            if [[ ! -a "${new_name}" ]]
            then
                printf "Moving %s to %s ...\n" "${log_name}" "${new_name}"
                mv "${log_name}" "${new_name}"
            else
                printf "%s already exists\n" "${new_name}" 
            fi
        else
            printf "Cannot rename %s to %s\n" "${log_name}" "${new_name}" >&2
        fi
    else
        printf "Cannot rename %s to %s\n" "${log_name}" "${new_name}" >&2
    fi
done < <(find ~ -maxdepth 2 -name logs -type d -print0)


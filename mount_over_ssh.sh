#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Mount file systems over SSH
# ------------------------------------------------------------------------------

domain="$(hostname --domain)"
if [[ -z "${domain}" ]]
then
    local_hostname="$(hostname)"
    domain="${local_hostname#*.}"
fi

for mount_point in "${HOME}"/mount/*
do
    [[ -d "${mount_point}" ]] || continue
    host="$(basename """${mount_point}""")"
    remote="${host}.${domain}:${HOME}"
    findmnt "${mount_point}" >/dev/null                  || \
        sshfs "${remote}" "${mount_point}"               || \
        printf "Failed to mount %s\n" "${remote}" >&2
done


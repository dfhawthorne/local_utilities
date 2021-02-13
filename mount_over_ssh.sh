#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Mount file systems over SSH
# Parameters:
#   -n name server (optional)
# ------------------------------------------------------------------------------

name_server=
while getopts "n:" opt
do
    case "${opt}" in
        n)  name_server="${OPTARG}" ;;
        *)  printf "Usage: %s [-n name_server]\n\tname_server is a DNS server\n" "$0" >&2
            exit 1;
    esac
done

dig_cmd=$(command -v dig)
sshfs_cmd=$(command -v sshfs)
findmnt_cmd=$(command -v findmnt)

if [[ -z "${sshfs_cmd}" || -z "${findmnt_cmd}" ]]
then
    printf "Both the sshfs and findmnt commands are needed for this utility" >&2
    exit 1
fi

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
    remote_host="${host}.${domain}"
    if [[ -n "${dig_cmd}" ]]
    then
        ip_addr=$(dig +short "${remote_host}")
        [[ -z "${ip_addr}" && -n "${name_server}" ]] && \
            ip_addr=$(dig @"${name_server}" +short "${remote_host}")
        if [[ -z "${ip_addr}" ]]
        then
            printf "Unable to resolve IP address for %s\n" "${remote_host}" >&2
            continue
        fi
        remote="${ip_addr}:${HOME}"
    else
        remote="${remote_host}:${HOME}"
    fi
    findmnt "${mount_point}" >/dev/null                  || \
        sshfs "${remote}" "${mount_point}"               || \
        printf "Failed to mount %s\n" "${remote_host}:${HOME}" >&2
done


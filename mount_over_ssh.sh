#!/bin/bash
# ------------------------------------------------------------------------------
# Mount file systems over SSH
# ------------------------------------------------------------------------------

domain="yaocm.id.au"
hosts="auburn personal dural hammer"

for host in ${hosts}
do  mount_point="${HOME}/mount/${host}"
    [ -d "${mount_point}" ] || mkdir -p "${mount_point}"
    remote="${host}.${domain}:${HOME}"
    findmnt "${mount_point}" >/dev/null || \
        sshfs "${remote}" "${mount_point}"               || \
        printf "Failed to mount %s\n" "${remote}" >&2
done


#!/bin/bash
# ------------------------------------------------------------------------------
# Mount file systems over SSH
# ------------------------------------------------------------------------------

domain="yaocm.id.au"
hosts="auburn personal dural hammer"

for host in ${hosts}
do  mount_point="${HOME}/mount/${host}"
    [ -d "${mount_point}" ] || mkdir -p "${mount_point}"
    sshfs "${host}.${domain}:${HOME}" "${mount_point}"
done


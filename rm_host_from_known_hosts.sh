#!/usr/bin/env bash
# -------------------------------------------------------------------------
# Removes all entries from ~/.ssh/known_hosts that match the supplied
# host name:
# - Fully-qualified name
# - Short name
# - IP address
#
# Assumes first parameter is a full-qualified name.
# -------------------------------------------------------------------------

if [[ $# -lt 1 ]]
then
    printf "Missing host name\n" >&2
    exit 1
fi

hn=$1
ssh-keygen -R "${hn}"
ssh-keygen -R "${hn%%.*}"
ssh-keygen -R "$(dig +short """${hn}""")"

#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# List all OCI firewall rules in the current compartment
# Pre-requisites:
# (1) OCI CLI is installed in a virtualised environment
# (2) A script, called oci_session.sh, to configure an OCI CLI session with a
#     default compartment OCID.
# ------------------------------------------------------------------------------

[[ -x ~/.venv/oci-cli/bin/activate ]] && \
	. ~/.venv/oci-cli/bin/activate 

[[ -x $(realpath oci_session.sh) ]] && \
	oci_session.sh

while read fw_ocid
do
	fw_name=$(                                    \
		oci network security-list get         \
			--security-list-id=${fw_ocid} \
			--query 'data."display-name"' \
			--raw-output                  \
		)
	echo ${fw_name}
	oci network security-list get \
		--security-list-id=${fw_ocid} \
	       	--query 'data."ingress-security-rules"[*].{protocol:protocol,source:source,port:"tcp-options"."destination-port-range".max}' \
		--output table
done < <( \
	oci network security-list list --query 'data[*].id' | \
	sed -nre 's!.*"(.*)".*!\1!p' \
	)


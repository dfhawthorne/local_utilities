#!/usr/bin/env bash
# -----------------------------------------------------------------------------------
# Set up session for OCI
# -----------------------------------------------------------------------------------

oci session validate --local || {
	oci session terminate 
	oci session authenticate   \
		--no-browser           \
		--profile-name=OCI     \
		--profile=DEFAULT      \
		--region=ap-sydney-1
}


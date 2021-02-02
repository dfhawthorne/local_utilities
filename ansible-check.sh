#!/bin/bash
# ------------------------------------------------------------------------------
# Performs checks on an Ansible Playbook
# 1. Run linter on YAML file
# 2. Run linter on playbook
# 3. Check the syntax of playbook
# 4. Execute the playbook in CHECK mode
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Validate passed arguments
# ------------------------------------------------------------------------------

if [[ $# -ne 1 ]]
then
    printf "No file provided\n" >&2
    exit 1
fi

if [[ ! -f "$1" ]]
then
    printf "Invalid playbook (%s)\n" "$1" >&2
    exit 1
fi

# ------------------------------------------------------------------------------
# Find commands if they exist
# ------------------------------------------------------------------------------

yamllint=$(command -v yamllint)
ansible_playbook=$(command -v ansible-playbook)
ansible_lint=$(command -v ansible-lint)

# ------------------------------------------------------------------------------
# Create yamllint configuration file, if needed
# ------------------------------------------------------------------------------

yamllint_conf=.yamllint
if [[ -n "${yamllint}" && ! -a "${yamllint_conf}" ]]
then
    cat >"${yamllint_conf}" <<DONE
extends: relaxed
rules:
  line-length: disable
  trailing-spaces: disable
  colons: disable
  indentation: disable
  hyphens: disable
DONE
fi

# ------------------------------------------------------------------------------
# Run yamllint if it is installed
# ------------------------------------------------------------------------------

if [[ -n "${yamllint}" ]]
then
    printf "Running YAML Lint on %s...\n" "$1"
   "${yamllint}" "$1"                                       \
        || exit 1
    printf "YAML Lint successful\n"
else
    printf "yamllint is not installed\n" >&2
fi

# ------------------------------------------------------------------------------
# Do a syntax check on the playbook
# ------------------------------------------------------------------------------

if [[ -n "${ansible_playbook}" ]]
then
    printf "Doing a syntax check on %s...\n" "$1"
    "${ansible_playbook}" --syntax-check "$1"               \
         || exit 1
    printf "Syntax check successful\n"
else
    printf "ansible-playbook is not installed\n" >&2
fi

# ------------------------------------------------------------------------------
# Run Ansible Lint on the playbook
# ------------------------------------------------------------------------------

if [[ -n "${ansible_lint}" ]]
then
    printf "Running Ansible Lint on %s...\n" "$1"
    "${ansible_lint}" "$1"                                  \
        || exit 1
    printf "Ansible lint successful\n"
else
    printf "ansible-lint is not installed\n" >&2
fi

# ------------------------------------------------------------------------------
# Run the playbook in check mode
# ------------------------------------------------------------------------------

if [ -n "${ansible_playbook}" ]
then
    printf "Running playbook, %s, in CHECK mode...\n" "$1"
    "${ansible_playbook}" --ask-become-pass --check "$1"    \
         || exit 1
    printf "Check mode successful\n"
else
    printf "ansible-playbook is not installed\n" >&2
fi

printf "All done\n"

exit 0

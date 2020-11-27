#!/bin/bash
# ------------------------------------------------------------------------------
# Performs checks on an Ansible Playbook
# 1. Run linter on YAML file
# 2. Run linter on playbook
# 3. Check the syntax of playbook
# 4. Execute the playbook in CHECK mode
# ------------------------------------------------------------------------------

if [ ! -f "$1" ]
then
    printf "Invalid playbook (%s)\n" "$1" >&2
    exit 1
fi

yamllint=$(command -v yamllint)
ansible_playbook=$(command -v ansible-playbook)
ansible_lint=$(command -v ansible-lint)

if [ -n "${yamllint}" ]
then
    printf "Running YAML Lint on %s...\n" "$1"
   "${yamllint}" "$1"                                       \
        || exit 1
    printf "YAML Lint successful\n"
fi

if [ -n "${ansible_playbook}" ]
then
    printf "Doing a syntax check on %s...\n" "$1"
    "${ansible_playbook}" --syntax-check "$1"               \
         || exit 1
    printf "Syntax check successful\n"
fi

if [ -n "${ansible_lint}" ]
then
    printf "Running Ansible Lint on %s...\n" "$1"
    "${ansible_lint}" "$1"                                  \
        || exit 1
    printf "Ansible lint successful\n"
fi

if [ -n "${ansible_playbook}" ]
then
    printf "Running playbook, %s, in CHECK mode...\n" "$1"
    "${ansible_playbook}" --ask-become-pass --check "$1"    \
         || exit 1
    printf "Check mode successful\n"
fi

printf "All done\n"

exit 0

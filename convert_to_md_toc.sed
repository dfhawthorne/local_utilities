#!/bin/sed -f
# ------------------------------------------------------------------------------
# This script converts a text file consisting of table of content entries (up to
# two (2) levels) into an unordered list of links in markdown format.
#
# Converts:
# Link 1
#   Link 2
#
# into:
# * [Link 1](#link-1)
#   * [Link 2)(#link-2)
# ------------------------------------------------------------------------------
h                                   # Save original text
s/[:'.]//g                          # remove special characters
s/ /-/g                             # convert all spaces to dashes
s/\(.*\)/\L\1/                      # convert to lowercase
G                                   # append original text
s/\(.*\)\n\(.*\)/\* \[\2\](\#\1)/   # create hyperlink
s/\* \[  /  \* \[/                  # restore indentation
s/\#--/\#/                          # remove indentation from address label

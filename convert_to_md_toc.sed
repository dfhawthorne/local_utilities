#!/bin/sed -Ef
# ------------------------------------------------------------------------------
# This script converts a markdown file into a Table of Contents (TOC) in
# markdown format.
#
# Header Level 1
# ==============
#
# Header Level 2
# --------------
#
# # Header Level 1
# ## Header Level 2
# ### Header Level 3
# #### Header Level 4
# ##### Header Level 5
# ###### Header Level 6
# ------------------------------------------------------------------------------
# Alternative forms of level 1 and 2 headers
# ------------------------------------------------------------------------------
/^=/{                               # Previous line was a level 1 header
  g                                 # Retrieve previous line
  b toc                             # Convert to TOC entry
}
/^-/{                               # Previous line was a level 2 header
  g                                 # Retrieve previous line
  s/^(.*)$/ \1/                     # Indent level 2 header
  b toc                             # Convert to TOC entry
}
# ------------------------------------------------------------------------------
# Standard forms of headers
# ------------------------------------------------------------------------------
/^\#+/{                              # Convert leading # to spaces
  s/^\#{6} /     /                   # Level 6 header
  s/^\#{5} /    /                    # Level 5 header
  s/^\#{4} /   /                     # Level 4 header
  s/^\#{3} /  /                      # Level 3 header
  s/^\#{2} / /                       # Level 2 header
  s/^\#{1} //                        # Level 1 header
  b toc
}
# ------------------------------------------------------------------------------
# Other lines are saved in case of alternative headers
# ------------------------------------------------------------------------------
h                                   # Save current line
d                                   # Delete current line, start next cycle
# ------------------------------------------------------------------------------
# Generate TOC entry
# ------------------------------------------------------------------------------
:toc                                # Have a TOC entry
h                                   # Save original text
s/[:'.\/]//g                        # remove special characters
s/ /-/g                             # convert all spaces to dashes
s/(.*)/\L\1/                        # convert to lowercase
G                                   # append original text
s/(.*)\n(.*)/\* \[\2\](\#\1)/       # create hyperlink
s/\* \[ {6}/            \* \[/      # restore indentation for h6
s/\* \[ {5}/          \* \[/        # restore indentation for h5
s/\* \[ {4}/        \* \[/          # restore indentation for h4
s/\* \[ {3}/      \* \[/            # restore indentation for h3
s/\* \[ {2}/    \* \[/              # restore indentation for h2
s/\* \[ {1}/  \* \[/                # restore indentation for h1
s/\#-+/\#/                          # remove indentation from address label

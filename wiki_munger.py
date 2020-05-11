#!/usr/bin/python3
# ------------------------------------------------------------------------------
# Munges a basic Wiki page
#
# A basic html page is created from the raw terminal log.
#
# Assumes that the content to be converted is delimited by <pre> and </pre>.
# Each block is converted separately and then removed.
#
# Blocks can be decorated with the following tags:
# #p for a paragraph to be inserted verbatim.
# #h3 for a heading of level 3
# #h4 for a heading of level 4
#
# Lines starting with a word that ends with a '$' is treated as a bash command
# unless it is one of the above decorations.
#
# Lines starting with 'SQL>' are treated as SQL commands unless it is a
# decoration.
#
# Other lines are treated as blocks of output from a preceding command.
#
# SQL commands such as 'DESC' and '!oerr' are ignored, and their output is
# suppressed.
# ------------------------------------------------------------------------------

from bs4 import BeautifulSoup
import csv
import os
import sys
import html

class wiki_munger:
    
    doc_init_parms    = dict()
    doc_dynamic_views = dict()
    doc_static_views  = dict()
    doc_oracle_errors = dict()
    doc_sql_cmds      = dict()
    doc_sql_plus_cmds = dict()
    doc_unix_cmds     = dict()



    # ------------------------------------------------------------------------------
    # Load documentation links from CSV files
    # ------------------------------------------------------------------------------

    def load_doc_links_from_csv(self, variables_file, req_vers="12.1"):
        """
        Open variable-based csv, iterate over the rows and map values to a list of
        dictionaries containing key/value pairs

        There are three (3) columns:
        (1) Version
        (2) Key
        (3) Value

        Only key-values are loaded into the dictionary if the version is matched,
        unless no version is required as in the case of Unix commands.
        """

        reader = csv.DictReader(open(variables_file, 'r'))
        result = dict()
        for line in reader:
            if req_vers == None or line['VERSION'] == req_vers:
                result[line['KEY']] = line['VALUE']

        return result

    def __init__(self, vers="12.1"):
    # ------------------------------------------------------------------------------
    # Documentation links
    # These links are all for 12.1
    # ------------------------------------------------------------------------------

        cur_dir                = os.path.dirname(sys.argv[0])
        doc_dir                = cur_dir + '/munges_wiki_page/Parameters/'
        self.doc_init_parms    = self.load_doc_links_from_csv(doc_dir + 'init_parms.csv',    vers)
        self.doc_dynamic_views = self.load_doc_links_from_csv(doc_dir + 'dynamic_views.csv', vers)
        self.doc_static_views  = self.load_doc_links_from_csv(doc_dir + 'static_views.csv',  vers)
        self.doc_oracle_errors = self.load_doc_links_from_csv(doc_dir + 'oracle_errors.csv', vers)
        self.doc_sql_cmds      = self.load_doc_links_from_csv(doc_dir + 'sql_cmds.csv',      vers)
        self.doc_sql_plus_cmds = self.load_doc_links_from_csv(doc_dir + 'sqlplus_cmds.csv',  vers)
        self.doc_unix_cmds     = self.load_doc_links_from_csv(doc_dir + 'unix_cmds.csv',     None)


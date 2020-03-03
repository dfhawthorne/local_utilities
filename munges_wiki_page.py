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
import sys
import html

# ------------------------------------------------------------------------------
# Documentation links
# These links are all for 12.1
# ------------------------------------------------------------------------------

doc_init_parms    = {
    "DDL_LOCK_TIMEOUT":           "https://docs.oracle.com/database/121/REFRN/GUID-72D43EF8-F7AF-4011-8D64-73ABC4FB2154.htm#REFRN10267"
}
doc_dynamic_views = {
    "V$PDBS":        "https://docs.oracle.com/database/121/REFRN/GUID-A399F608-36C8-4DF0-9A13-CEE25637653E.htm#REFRN30652",
    "V$CONTAINERS":  "https://docs.oracle.com/database/121/REFRN/GUID-8865FE4F-C22F-4B04-BC21-A28FFFC92072.htm#REFRN30708",
    "V$PARAMETER":   "https://docs.oracle.com/database/121/REFRN/GUID-C86F3AB0-1191-447F-8EDF-4727D8693754.htm#REFRN30176",
    "V$TABLESPACE":  "https://docs.oracle.com/database/121/REFRN/GUID-E6BF227D-CFAA-43EB-A7C9-F0AF293FDEC0.htm"
}
doc_static_views  = {
    "DBA_PDBS": "https://docs.oracle.com/database/121/REFRN/GUID-439126EA-A6B6-45B8-AAFA-37EE4356BBEF.htm"
}
doc_oracle_errors = {
    "ORA-00922": "https://docs.oracle.com/database/121/ERRMG/ORA-00910.htm#GUID-D9EBDFFA-88C6-4185-BD2C-E1B959A97274__GUID-E44B4421-18C7-4C15-BC74-F223E4AC6A6B",
    "ORA-01100": "https://docs.oracle.com/database/121/ERRMG/ORA-00910.htm#GUID-D9EBDFFA-88C6-4185-BD2C-E1B959A97274__GUID-556B6E62-D6DD-445E-A46D-D3F607CD986F",
    "ORA-01501": "https://docs.oracle.com/database/121/ERRMG/ORA-01500.htm#GUID-65B2B9E5-7075-4D53-91B8-FCAECA0AEE0E__GUID-D42F0E47-0C62-4ED5-BB85-7D0DDB3DADC6",
    "ORA-65012": "https://docs.oracle.com/database/121/ERRMG/ORA-60001.htm#GUID-9B78A028-D760-4810-9CFC-9013FBD1FCC9__GUID-57176DA6-6098-4970-B614-B7729FF7D841",
    "ORA-65025": "https://docs.oracle.com/database/121/ERRMG/ORA-60001.htm#GUID-9B78A028-D760-4810-9CFC-9013FBD1FCC9__GUID-0AA303A6-2499-47D7-8F11-AAD00A18B230"
}
doc_sql_cmds     = {
    "ALTER PLUGGABLE DATABASE":  "https://docs.oracle.com/database/121/SQLRF/statements_2008.htm#SQLRF55667",
    "ALTER SESSION":             "https://docs.oracle.com/database/121/SQLRF/statements_2015.htm#SQLRF00901",
    "ALTER SYSTEM":              "https://docs.oracle.com/database/121/SQLRF/statements_2017.htm#SQLRF00902",
    "ALTER USER":                "https://docs.oracle.com/database/121/SQLRF/statements_4003.htm#SQLRF01103",
    "CREATE AUDIT POLICY":       "https://docs.oracle.com/database/121/SQLRF/statements_5001.htm#SQLRF56055",
    "CREATE PLUGGABLE DATABASE": "https://docs.oracle.com/database/121/SQLRF/statements_6010.htm#SQLRF55686",
    "CREATE DATABASE":           "https://docs.oracle.com/database/121/SQLRF/statements_5005.htm#SQLRF01204",
    "CREATE TABLE":              "https://docs.oracle.com/database/121/SQLRF/statements_7002.htm#SQLRF01402",
    "CREATE USER":               "https://docs.oracle.com/database/121/SQLRF/statements_8003.htm#SQLRF01503",
    "DROP PLUGGABLE DATABASE":   "https://docs.oracle.com/database/121/SQLRF/statements_8028.htm#SQLRF55699",
    "GRANT":                     "https://docs.oracle.com/database/121/SQLRF/statements_9014.htm#SQLRF01603"
}
doc_sql_plus_cmds = {
    "COLUMN":                    "https://docs.oracle.com/database/121/SQPUG/ch_twelve013.htm#i2697128",
    "CONNECT":                   "https://docs.oracle.com/database/121/SQPUG/ch_twelve015.htm#SQPUG036",
    "SET LINESIZE":              "https://docs.oracle.com/database/121/SQPUG/ch_twelve040.htm#i2678481",
    "SET PAGESIZE":              "https://docs.oracle.com/database/121/SQPUG/ch_twelve040.htm#i2699247",
    "SHOW":                      "https://docs.oracle.com/database/121/SQPUG/ch_twelve041.htm#SQPUG124",
    "SHUTDOWN":                  "https://docs.oracle.com/database/121/SQPUG/ch_twelve042.htm#SQPUG125",
    "STARTUP":                   "https://docs.oracle.com/database/121/SQPUG/ch_twelve045.htm#SQPUG128",
    "sqlplus":                   "https://docs.oracle.com/database/121/SQPUG/ch_three.htm#SQPUG363"
}
doc_unix_cmds     = {
    "cd":                        "http://man7.org/linux/man-pages/man1/cd.1p.html",
    "ethtool":                   "http://man7.org/linux/man-pages/man8/ethtool.8.html",
    "grep":                      "http://man7.org/linux/man-pages/man1/grep.1.html",
    "ip":                        "http://man7.org/linux/man-pages/man8/ip.8.html",
    "uname":                     "http://man7.org/linux/man-pages/man1/uname.1.html"
}

# ------------------------------------------------------------------------------
# Helper routines
# ------------------------------------------------------------------------------

def cmd_response(soup, block, output, text_style, error_urls):
    """
    Put a short HTML snippert encompassing the gathered output lines.
    """

    if len(output) == 0:
        return

    if len(output) == 1 and len(output[0].strip()) == 0:
        return

    para_tag    = soup.new_tag('p')
    if len(output[-1].strip()) == 0:
        output.pop(-1)

    error_found = False
    pre_tag     = soup.new_tag('pre', style=text_style)
    pos         = 0
    for line in output:
        if pos > 0:
            pre_tag.insert(pos, '\n')
            pos   += 1
        if line.startswith('ORA-'):
            error_found          = True
            error_no             = line.split()[0].strip(':')
            url_part             = doc_oracle_errors.get(error_no)
            error_urls[error_no] = url_part
            if url_part != None:
                a_tag                = soup.new_tag('a', href=url_part)
                a_tag.string         = error_no
                pre_tag.insert(pos, a_tag)
                pos                 += 1
                pre_tag.insert(pos, line[len(error_no):])
            else:
                pre_tag.insert(pos, line)
        else:
            pre_tag.insert(pos, line)
        pos += 1

    if error_found:
        para_tag.string = "The command failed with the following errors:"
    else:
        para_tag.string = "The expected output is:"
    block.insert_before(para_tag)
    block.insert_before(pre_tag)

def add_doc_links(soup, doc_dict, style=None):
    """
    Create a list of links to text based on a dictionary
    """
    parent       = soup.new_tag('ul')
    pos          = 0
    keys         = list(doc_dict.keys())
    keys.sort()
    for key in keys:
        url          = doc_dict.get(key)
        li_tag       = soup.new_tag('li', style=style)
        if url == None:
            li_tag.string = key
        else:
            a_tag         = soup.new_tag('a', href=url)
            a_tag.string  = key
            li_tag.insert(0, a_tag)
        parent.insert(pos, li_tag)
        pos += 1
    return parent


def add_doc_section(soup, title, url, doc_dict, style=None):
    """
    Adds a section containing references
    """
    div_tag      = soup.new_tag('div')
    doc_tag      = soup.new_tag('li')
    a_tag        = soup.new_tag('a', href=url)
    a_tag.string = title
    doc_tag.insert(0, a_tag)
    doc_list     = add_doc_links(soup, doc_dict, style)
    div_tag.insert(0, doc_tag)
    div_tag.insert(1, doc_list)
    return div_tag

def add_doc_manual(soup, title, url):
    """
    Adds a new document to the list of references
    """
    doc_tag      = soup.new_tag('li')
    a_tag        = soup.new_tag('a', href=url)
    a_tag.string = title
    doc_tag.insert(0, a_tag)
    return doc_tag

# ------------------------------------------------------------------------------
# Parse the html found in the file named as the first passed parameter
# ------------------------------------------------------------------------------

file_name = sys.argv[1]
with open(file_name, "r") as f:
    html_doc = f.read()

soup = BeautifulSoup(html_doc, 'html.parser')

# ------------------------------------------------------------------------------
# If there are no pre-formatted blocks, terminate
# ------------------------------------------------------------------------------

if soup.pre == None: exit()

# ------------------------------------------------------------------------------
# Ensure that we have all of the correct headings
# ------------------------------------------------------------------------------

headings = [h.string.strip() for h in soup.find_all('h2')]
if 'Overview' not in headings:
    h2        = soup.new_tag('h2', id='overview')
    h2.string = 'Overview'
    para      = soup.new_tag('p')
    soup.pre.insert_before(h2)
    soup.pre.insert_before(para)
if 'References' not in headings:
    h2        = soup.new_tag('h2', id='references')
    h2.string = 'References'
    ref_list  = soup.new_tag('ul', id='reference_list')
    soup.pre.insert_before(h2)
    soup.pre.insert_before(ref_list)
if 'Procedure' not in headings:
    h2        = soup.new_tag('h2', id='procedure')
    h2.string = 'Procedure'
    soup.pre.insert_before(h2)
    para      = soup.new_tag('p')
    soup.pre.insert_before(para)

# ------------------------------------------------------------------------------
# Get all pre-formatted blocks
# Only convert those without style attributes.
# ------------------------------------------------------------------------------

basic_style = "background-color:%s;border:5px groove black;margin-left:10px;padding:2px"
cmd_style   = basic_style % "lightgreen"
sql_style   = basic_style % "#def87c"
text_style  = basic_style % "#7ccdf8"

static_urls   = dict()
dynamic_urls  = dict()
init_urls     = dict()
error_urls    = dict()
sql_cmd_urls  = dict()
sql_plus_urls = dict()
unix_cmd_urls = dict()

blocks       = soup.find_all('pre')

skip_output  = False
for block in blocks:
    if block.get('style') != None:
        continue
    if block.string == None:
        continue
    lines = block.string.split('\n')
    in_sql_mode  = False
    output       = []
    has_h3_hdr   = False
    for raw_line in lines:
        line = html.unescape(raw_line).expandtabs()
        # ----------------------------------------------------------------------
        # Assumes PS1='[\u@\h \W]\$ ' or similar denotes a BASH command
        # ----------------------------------------------------------------------
        if line.startswith('['):
            cmd_response(soup, block, output, text_style, error_urls)
            idx          = line.index(']')
            cmd          = line[idx+3:]
            if cmd.split()[0] == "#p":
                tag         = soup.new_tag('p')
                tag.string  = cmd[3:]
                block.insert_before(tag)
            elif cmd.split()[0].startswith("#h"):
                hdr_type    = cmd.split()[0][1:]
                tag         = soup.new_tag(hdr_type)
                has_h3_hdr  = (hdr_type == "h3")
                tag.string  = cmd[4:]
                block.insert_before(tag) 
            else:
                tag          = soup.new_tag('h3')
                if cmd.split() == ['.', 'oraenv']:
                    tag.string = 'Set Database Environment'
                    cmd_desc   = 'Set the database environment as follows:'
                elif cmd.split()[0] == 'sqlplus':
                    tag.string = 'Start SQL*Plus Session'
                    cmd_desc   = 'Start a SQL*Plus session as follows:'
                else:
                    tag.string = 'Run Unix Command'
                    cmd_desc   = 'Run the following command:'
                if has_h3_hdr:
                    has_h3_hdr   = False
                else:
                    block.insert_before(tag)
                tag          = soup.new_tag('p')
                tag.string   = cmd_desc
                block.insert_before(tag)
                cmd_tag      = soup.new_tag('pre', style=cmd_style)
                first_word   = cmd.split()[0]
                if first_word == 'sqlplus':
                    url_part     = doc_sql_plus_cmds.get(first_word)
                    sql_plus_urls[first_word] = url_part
                else:
                    url_part     = doc_unix_cmds.get(first_word)
                    unix_cmd_urls[first_word] = url_part
                cmd_pos      = cmd.index(first_word) + len(first_word)
                if url_part == None:
                    cmd_tag.string = cmd
                else:
                    a_tag      = soup.new_tag('a', href=url_part)
                    a_tag.string = first_word
                    cmd_tag.insert(0, a_tag)
                    cmd_tag.insert(1, cmd[cmd_pos:])
                block.insert_before(cmd_tag)
            output       = []
        # ----------------------------------------------------------------------
        # Assumes sqlprompt="SQL> ". This denotes a SQL command
        # ----------------------------------------------------------------------
        elif line.startswith('SQL>'):
            if not skip_output:
                cmd_response(soup, block, output, text_style, error_urls)
            idx          = line.index(' ')
            cmd          = line[idx+1:]
            hdr_tag      = soup.new_tag('h3')
            tag          = soup.new_tag('p')
            if len(cmd.strip()) > 0:
                cmd_tag          = soup.new_tag('pre', style=sql_style)
                if cmd.upper().startswith('SELECT'):
                    tag.string     = 'Run the following SQL query:'
                    hdr_tag.string = 'Run SQL Query'
                    words        = cmd.split()
                    pos          = 0
                    for word in words:
                        upper_word = word.upper().strip(';')
                        if upper_word.startswith('V$') or upper_word.startswith('GV$'):
                            url_part                 = doc_dynamic_views.get(upper_word)
                            dynamic_urls[upper_word] = url_part
                        elif upper_word.startswith('DBA_') or upper_word.startswith('ALL_'):
                            url_part                 = doc_static_views.get(upper_word)
                            static_urls[upper_word]  = url_part
                        else:
                            url_part = None
                        if url_part != None:
                            url                = soup.new_tag('a', href=url_part)
                            url.string         = upper_word
                            cmd_idx            = cmd.index(word)
                            cmd_tag.insert(pos, cmd[:cmd_idx])
                            cmd_tag.insert(pos+1, url)
                            pos               += 2
                            cmd                = cmd[cmd_idx+len(word):]
                    cmd_tag.insert(pos, cmd)
                    skip_output    = False
                    pos           += 1
                elif cmd.upper().startswith('DESC'):
                    skip_output    = True
                elif cmd.startswith('!oerr '):
                    skip_output    = True
                else:
                    words          = cmd.split()
                    one_word       = words[0].upper()
                    two_words      = ' '.join(words[:2]).upper()
                    three_words    = ' '.join(words[:3]).upper()
                    url_part       = doc_sql_cmds.get(three_words)
                    if url_part == None:
                        url_part       = doc_sql_cmds.get(two_words)
                        url_part_1     = doc_sql_cmds.get(one_word)
                        if url_part != None:
                            cmd_pos                 = cmd.index(words[1]) + len(words[1])
                            sql_cmd_urls[two_words] = url_part
                        elif url_part_1 != None:
                            cmd_pos                 = cmd.index(words[0]) + len(words[0])
                            sql_cmd_urls[one_word]  = url_part_1
                            url_part                = url_part_1
                        else:
                            url_part_2      = doc_sql_plus_cmds.get(two_words)
                            url_part_1      = doc_sql_plus_cmds.get(one_word)
                            if url_part_2 != None:
                                sql_plus_urls[two_words] = url_part_2
                                cmd_pos                  = cmd.index(words[1]) + len(words[1])
                                url_part                 = url_part_2
                            elif url_part_1 != None:
                                sql_plus_urls[one_word]  = url_part_1
                                cmd_pos                  = len(words[0])
                                url_part                 = url_part_1
                            else:
                                sql_cmd_urls[one_word]   = None
                                cmd_pos                  = 0
                                url_part                 = None
                    else:
                        cmd_pos        = cmd.index(words[2]) + len(words[2])
                        sql_cmd_urls[three_words] = url_part
                    hdr_tag.string = 'Execute SQL Command'
                    tag.string     = 'Run the following SQL command:'
                    if url_part == None:
                        cmd_tag.string = cmd
                    else:
                        a_tag      = soup.new_tag('a', href=url_part)
                        a_tag.string = cmd[:cmd_pos]
                        cmd_tag.insert(0, a_tag)
                        cmd_tag.insert(1, cmd[cmd_pos:])
                    skip_output    = False
                if not skip_output:
                    block.insert_before(hdr_tag)
                    block.insert_before(tag)
                    block.insert_before(cmd_tag)
            output       = []
        else:
            output.append(line)

    if not skip_output:
        cmd_response(soup, block, output, text_style, error_urls)

    block.extract()

# ------------------------------------------------------------------------------
# Add any found references to the header section
# ------------------------------------------------------------------------------

ref_list_tag = soup.find('ul', id='reference_list')
ref_list_pos = 0
mono_style   = "font-family: monospace; font-size: large;"

if len(error_urls) > 0:
    ref_div_tag   = soup.new_tag('div')
    ref_doc_tag   = add_doc_manual(
        soup,
        'Oracle® 12.1 Database Error Messages',
        "https://docs.oracle.com/database/121/ERRMG/toc.htm"
    )
    ref_list_tag.insert(ref_list_pos, ref_div_tag)
    ref_list_pos += 1
    ref_doc_list  = add_doc_links(
        soup,
        error_urls,
        style=mono_style
    )
    ref_div_tag.insert(0, ref_doc_tag)
    ref_div_tag.insert(1, ref_doc_list)

if len(static_urls) + len(dynamic_urls) + len(init_urls) > 0:
    ref_div_tag   = soup.new_tag('div')
    ref_doc_tag   = add_doc_manual(
        soup,
        'Oracle® 12.1 Database Reference',
        "https://docs.oracle.com/database/121/REFRN/toc.htm"
    )
    ref_list_tag.insert(ref_list_pos, ref_div_tag)
    ref_list_pos += 1
    ref_doc_list  = soup.new_tag('ul')
    ref_div_tag.insert(0, ref_doc_tag)
    ref_div_tag.insert(1, ref_doc_list)
    doc_pos       = 0

    if len(init_urls) > 0:
        section_tag = add_doc_section(
            soup,
            "Part I Initialization Parameters",
            "https://docs.oracle.com/database/121/REFRN/GUID-6F1C3203-0AA0-4AF1-921C-A027DD7CB6A9.htm",
            init_urls,
            style=mono_style
        )
        ref_doc_list.insert(doc_pos, section_tag)
        doc_pos += 1

    if len(static_urls) > 0:
        section_tag = add_doc_section(
            soup,
            "Part II Static Data Dictionary Views",
            "https://docs.oracle.com/database/121/REFRN/GUID-8865F65B-EF6D-44A5-B0A1-3179EFF0C36A.htm",
            static_urls,
            style=mono_style
        )
        ref_doc_list.insert(doc_pos, section_tag)
        doc_pos += 1

    if len(dynamic_urls) > 0:
        section_tag = add_doc_section(
            soup,
            "Part III Dynamic Performance Views",
            "https://docs.oracle.com/database/121/REFRN/GUID-8C5690B0-DE10-4460-86DF-80111869CF4C.htm",
            dynamic_urls,
            style=mono_style
        )
        ref_doc_list.insert(doc_pos, section_tag)
        doc_pos += 1

if len(sql_cmd_urls) > 0:
    ref_div_tag   = soup.new_tag('div')
    ref_doc_tag   = add_doc_manual(
        soup,
        "Oracle® 12.1 SQL Language Reference",
        "https://docs.oracle.com/database/121/SQLRF/toc.htm"
    )
    ref_list_tag.insert(ref_list_pos, ref_div_tag)
    ref_list_pos += 1
    ref_doc_list  = add_doc_links(
        soup,
        sql_cmd_urls,
        style=mono_style
    )
    ref_div_tag.insert(0, ref_doc_tag)
    ref_div_tag.insert(1, ref_doc_list)

    
if len(sql_plus_urls) > 0:
    ref_doc_tag   = add_doc_manual(
        soup,
        "SQL*Plus® User's Guide and Reference 12.1",
        "https://docs.oracle.com/database/121/SQPUG/toc.htm"
    )
    ref_list_tag.insert(ref_list_pos, ref_doc_tag)
    ref_list_pos += 1
    ref_doc_list  = add_doc_links(
        soup,
        sql_plus_urls,
        style=mono_style
    )
    ref_doc_tag.insert(1, ref_doc_list)

if len(unix_cmd_urls) > 0:
    ref_doc_tag   = add_doc_manual(
        soup,
        'Linux man pages online',
        "http://man7.org/linux/man-pages/index.html"
    )
    ref_list_tag.insert(ref_list_pos, ref_doc_tag)
    ref_list_pos += 1
    ref_doc_list  = add_doc_links(
        soup,
        unix_cmd_urls,
        style=mono_style
    )
    ref_doc_tag.insert(1, ref_doc_list)

print(soup.prettify())


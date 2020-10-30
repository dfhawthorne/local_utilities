# local_utilities
various utilities for personal use

## munges_wiki_page.sh

`munges_wiki_page.py source.html >target.html`

Sample source.html is:
```html
<pre>[douglas@coogee]$ sqlplus / as sysdba
blah, blah
SQL&gt; SELECT * FROM dual;
</pre>
```

The target html will have three (3) main sections:
1. Overview with an empty paragraph
1. References with entries for any commands used
1. Procedure with each command highlighted with its own heading, code block, and text block.

## git-sync.sh

Does a `git pull` in all local GIT repositories that can be found from my home directory.

## get_run_time_from_log_file

Calculates the difference between the change and access times for a file. This assumes that the only access was done on file creation.

Sample usage:
```bash
get_run_time_from_log_file logs/JAR_DG/JAR_DG_2020_10_30G.log
```
The sample output is:
```
  0d  0h 16m 47s
```

To create the executable, run:
```bash
make get_run_time_from_log_file
```

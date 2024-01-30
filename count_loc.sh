#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Count non-blank lines of code (LOC) in a set of GIT repositories
# Comment lines are included.
# ------------------------------------------------------------------------------

git_repos="${HOME}/git-repositories"

if [[ ! -d "${git_repos}" ]]
then
    printf "%s: %s is not a directory. Exiting.\n" \
        "$(basename $0)" \
        "${git_repos}" \
        >&2
    exit 1
fi

pushd "${git_repos}" >/dev/null

printf "Repository,Assembler,BASH,C,Jinja2,Latex,Makefile,Markdown,Python,R,SED,SQL,TCL,Terraform,TLA+,YAML,Other\n"

for repos in *
do
    [[ -d "${repos}" ]] || continue

    loc_asm=0      # Assembler LOC
    loc_c=0        # C LOC
    loc_j2=0       # Jinja2 LOC
    loc_make=0     # Makefile LOC
    loc_md=0       # Markdown LOC
    loc_py=0       # Python LOC
    loc_r=0        # R LOC
    loc_sed=0      # SED LOC
    loc_sh=0       # Bash LOC
    loc_sql=0      # SQL LOC
    loc_tcl=0      # TCL LOC
    loc_tex=0      # Latex LOC
    loc_tf=0       # Terraform LOC
    loc_tla=0      # TLA+ LOC
    loc_yaml=0     # YAML LOC
    loc_other=0    # Other

    while read file_name
    do
        case "${file_name}" in
            *"ansible.cfg"|*"hosts"|*"inventory"|*"/host_vars/"*|*"/group_vars/"*)
                continue ;;                      # Ignore Ansible files
            *".gz"|*".zip")                      # Ignore archives
                continue ;;
            *"/.vscode/"*)                       # Ignore Visual Studio files
                continue ;;
            *"/.git/"*)                          # Ignore GIT internal files
                continue ;;
            *"/.gitignore"|*".gitattributes")
                continue ;;
            *"/logs/"*|*"/log/"*|*".log"|*".err"|*".pid")
                continue ;;                      # Ignore logs
            *".yamllint")                        # Ignore YAML Lint configuration
                continue ;;
            *"LICENSE")                          # Ignore LICENSE
                continue ;;
            *".csv"|*".dat"|*".html"|*".txt")    # Ignore data files
                continue ;;
            *".gif"|*".png"|*".jpeg"|*".jpg"|*".xcf")
                continue ;;                      # Ignore graphics files
            *".pdf"|*".PDF")                     # Ignore PDF files
                continue ;;
            *".bbl"|*".toc"|*"main.pdf"|*".aux"|*".lof"|*".bib"|*".lot"|*".blg")
                continue ;;                       # Ignore TEX Auxiliary files 
            "dfhawthorne.github.io/scripts/"*) ;; # Keep scripts from Wiki
            "dfhawthorne.github.io/"*)            # Ignore other Wiki files
                continue ;;
            "tla/"*)                             # TLA files
                case "${file_name}" in
                    *"/Model"*)                  # Ignore all model files
                        continue ;;
                    *"/PT.tla")                  # Ignore standard library 
                        continue ;;
                    *".tla") ;;                  # Keep source files
                    *)  continue ;;              # Ignore others
                esac ;;
            *) ;;
        esac
        case $(file --brief "${file_name}" | cut --delimiter=, --fields=1) in
            *ELF*) continue ;;                   # Ignore compiled programs
            *) ;;
        esac
        # Note: Some Jinja2 files are double-counted
        loc=$(sed -re '/^\S*$/d' "${file_name}" | wc -l)
        case "${file_name}" in
            *".c"|*".h"|*".c.inc")
                (( loc_c += loc )) ;;
            *"Makefile")
                (( loc_make += loc )) ;;
            *".md")
                (( loc_md += loc )) ;;
            *".Rmd")
                (( loc_r += loc )) ;;
            *".py"|*".py.j2")
                (( loc_py += loc ))
                [[ "${file_name}" =~ .*j2 ]] && (( loc_j2 += loc ))
                ;;
            *".s")
                (( loc_asm += loc )) ;;
            *".sed")
                (( loc_sed += loc )) ;;
            *".sh"|*".sh.j2")
                (( loc_sh += loc ))
                [[ "${file_name}" =~ .*j2 ]] && (( loc_j2 += loc ))
                ;;
            *".sql"|*".sql.j2")
                (( loc_sql += loc ))
                [[ "${file_name}" =~ .*j2 ]] && (( loc_j2 += loc ))
                ;;
            *".tcl"|*".tcl.j2"|*".tcl.inc")
                (( loc_tcl += loc ))
                [[ "${file_name}" =~ .*j2 ]] && (( loc_j2 += loc ))
                ;;
            *".tex"|*".bibtex")
                (( loc_tex += loc )) ;;
            *".tf")
                (( loc_tf += loc )) ;;
            *".tla")
                (( loc_tla += loc )) ;;
            *".yml")
                (( loc_yaml += loc )) ;;
            *".j2")                     # Other Jinja2 files
                (( loc_j2 += loc )) ;;
            *)  (( loc_other += loc ))
                printf "%s\n" "${file_name}" >&2
                ;;
        esac
    done < <(find "${repos}" -type f)

    # Repository,Assembler,BASH,C,Jinja2,Latex,Makefile,Markdown,Python,R,SED,SQL,TCL,Terraform,TLA+,YAML,Other
    printf "%s,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n" \
        "${repos}" \
        $loc_asm \
        $loc_sh \
        $loc_c \
        $loc_j2 \
        $loc_tex \
        $loc_make \
        $loc_md \
        $loc_py \
        $loc_r \
        $loc_sed \
        $loc_sql \
        $loc_tcl \
        $loc_tf \
        $loc_tla \
        $loc_yaml \
        $loc_other
done

popd >/dev/null


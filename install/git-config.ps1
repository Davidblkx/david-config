"beautiful log: git flog"
git config --global alias.flog "log --oneline --decorate --all --graph --simplify-by-decoration"
"simple log: git lg"
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
"log my commits"
git config --global alias.mylog "log --author='david.ferreira.pires@everis.com' --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
"update submodules: git update-all"
git config --global alias.update-all "submodule update --recursive --remote"
"Push all submodules: git push-all"
git config --global alias.push-all "push --recurse-submodules=on-demand"
"set vscode as default git"
git config --global core.editor "vim"
"set checkout as c"
git config --global alias.c "checkout"
"set create and checkout branch as nb"
git config --global alias.nb "checkout -b"
"set alias req to push new branch"
git config --global alias.req 'push -u origin'
"set ls as list branch"
git config --global alias.ls 'branch'
"fetch all and prune branches"
git config --global alias.pfetch 'fetch --all --prune'
"set vscode as the default diff tool"
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'
"travel 1 commit behind"
git config --global alias.reset1 'reset --soft HEAD^'
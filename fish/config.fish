set fish_greeting ""
set -x MYVIMRC "$HOME/.config/vim/vimrc"
set -x VIMINIT "source $MYVIMRC"
set -x NPM_CONFIG_USERCONFIG "$HOME/.config/npm/npmrc"
stty -ixon      # disable Ctrl-S and Ctrl-Q

alias vi="vim"
alias python="python3"
alias gdb="gdb -quiet"
alias grep="grep --color --exclude=tags"
alias todo="vim (git config --get todo.path)"
alias gd="git diff"
alias gdm="git diff master"
alias gst="git status"
alias gb="git for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)' refs/heads"
alias tmux="tmux -f $HOME/.config/tmux/tmux.conf"

if [ (uname -s) = "Linux" ]
    alias ls="ls --color=auto"
end
if [ (uname -s) = "Darwin" ]
    alias ls="ls -G"
end

function fish_prompt --description 'Write out the prompt'
    echo -n -s (set_color $fish_color_cwd) (prompt_pwd) (set_color normal) '> '
end

function tmux-dev
    set cols (tput cols)
    if [ "$cols" -lt 160 ]
        tmux new-session \; split-window -b -h -l 80
    else if [ "$cols" -lt 240 ]
        tmux new-session \; split-window -b -h -l (math "floor($cols/2)")
    else
        tmux new-session \; \
            split-window -b -h -l (math "floor(2*$cols/3)") \; \
            split-window -b -h -l (math "floor($cols/3)")
    end
end

function sloc
    find . -name "*.[c|h]" | xargs grep . | wc -l
end

function vm
    switch (count $argv)
        case 0
            set name dev
            set username admin
        case 1
            set name $argv[1]
            set username admin
        case 2
            set name $argv[1]
            set username $argv[2]
    end
    if not VBoxManage list runningvms | cut -d '"' -f 2 | grep -q "$name"
        VBoxManage startvm --type headless "$name"
        echo "Waiting for SSH connection..."
    end
    set port (VBoxManage showvminfo "$name" --machinereadable | \
                 grep '^Forwarding(.*,22"' | cut -d, -f4)
    ssh -p $port -o ConnectionAttempts=60 $username@localhost
end

function upload
    scp $argv[1] admin@dfcd.net:public/dfcd.net/public/mod/
end

# map Ctrl-D to "clear"
function fish_user_key_bindings
    bind \cd echo\ -n\ \(clear\ \|\ string\ replace\ \\e\\\[3J\ \"\"\)\;\ commandline\ -f\ repaint
end

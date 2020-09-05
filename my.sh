
mkdir -p ~/.my/history/

getjavaversion() {
    local j=$(java -version 2>&1 | awk 'NR==1{gsub("\"","");print $3}')
    printf "\e[42;1;37m$j"
}

is_maven_relative() {
    [ -r .data/.m2/settings.xml ] && printf '\e[0;35m|\e[1;37m\u03bb'
}

is_git() {
    if [ -d .git ]; then
        local b=`git branch --show-current`
        local c=`git ls-files -m | wc -l`
        local d=`git remote get-url origin`
        git status | grep -q 'Untracked files:' && e='\U2209' || e=''
        printf "\e[0;35m|\e[45;1;37m$b $c $e $d"
    fi
}

aaa() {
    local u=$(tty | tr '/' '.')
    local p=~/my.sh
    local q=/tmp/my.sh.md5sum$u
    [ ! -e $q ] && md5sum $p > $q
    a=$(md5sum $p)
    b=${a%% *}
    read c _ < $q

    if [ "$b" != "$c" ]; then
        printf '\e[0;35m|\e[41;1;37m\U394'
    fi
}

aa() {
    local u=$(tty | tr '/' '.')
    local p=~/my.sh
    local q=/tmp/my.sh.md5sum$u
    md5sum $p > $q
    source ~/my.sh 
}

cleanup {
    local u=$(tty | tr '/' '.')
    rm  -f /tmp/my.sh.md5sum$u
}
trap cleanup EXIT

get_history_file() {
    basedir=~/.my/history
    current=$basedir/current
    if [ ! -e $current ];then
        h=$basedir/$(date +'%Y-%m-%d.%H.%M.%S')
        touch $h
        ln -sf $h $current
    fi
    #nlines=$(wc -l < $current)
    #if((nlines/2 >= $HISTFILESIZE)); then
    #    h=$basedir/$(date +'%Y-%m-%d.%H.%M.%S')
    #    touch $h
    #    ln -sf $h $current
    #fi
    printf $current
}

manage_history() {
    history -a 

    basedir=~/.my/history
    current=$basedir/current
    nlines=$(wc -l < $current)

    if((nlines/2 >= $HISTFILESIZE)); then
        new=$basedir/$(date +'%Y-%m-%d.%H.%M.%S')
        touch $new
        ln -sf $new $current
    fi

    history -c
    history -r 
}

HISTTIMEFORMAT='%F %T '
HISTFILESIZE=1000
HISTSIZE=1000
HISTCONTROL=ignoredups:erasedups
HISTFILE=`get_history_file`
HISTIGNORE='history:history *:clear:rm *:ls *:cd *:ssh *:pwd'
PROMPT_COMMAND='manage_history'
shopt -s histappend

export PS1='\e[44;1;37m$(pwd) `getjavaversion``is_maven_relative``is_git``aaa`\e[0m\n$ '

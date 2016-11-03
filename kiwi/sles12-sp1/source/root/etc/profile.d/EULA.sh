#!/bin/bash

check_eula () {
    local LICENSE_FILE
    local answer

    if [ ! -e $HOME/.eula-accepted ]; then
        touch $HOME/.eula-accepted
    fi

    for LICENSE_FILE in /etc/YaST2/licenses/license-*.txt; do
        if grep -q "$LICENSE_FILE" $HOME/.eula-accepted; then
            continue
        fi

        # Code stolen from
        # https://github.com/SUSE/studio/blob/master/kiwi-job/templates/SLES11_SP3/root/etc/init.d/suse_studio_firstboot.in
        stty -nl ixon ignbrk -brkint

        if [ `uname -m` == "s390x" ]; then
            cat $LICENSE_FILE
        else
            less $LICENSE_FILE 2>/dev/null || more $LICENSE_FILE 2>/dev/null || cat $LICENSE_FILE
        fi

        answer=
        until [ "$answer" == "y" ] || [ "$answer" == "Y" ];
        do
            echo -n "Do you accept the EULA? [y/n] "
            read -e answer
            if [ "$answer" == "n" ] || [ "$answer" == "N" ]; then
                exit
            fi
        done

        echo "$LICENSE_FILE" >> $HOME/.eula-accepted
    done
}

case "$-" in
    *i*)
        check_eula
        ;;
esac

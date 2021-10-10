cur=$(pwd)

init_alias() {
    c=$(grep -n 'alias ll' /etc/profile | grep -v '#alias')
    check=$($c | wc -l)
    if [[ "$check" == "0" ]]; then
        echo "alias ll='ls -lh'" >>/etc/profile
        echo "please run: source /etc/profile"
    fi

    check=$(grep -n 'alias j=' /etc/profile | grep -v '#alias' | wc -l)
    if [[ "$check" == "0" ]]; then
        echo "alias j='${cur}/init.sh'" >>/etc/profile
    else
        cur=$(echo $c | sed "s/alias j='//" | sed "s/init.sh'//")
    fi
}

mirror() {
    check=$(uname -a | awk '{print $2}')
    if [[ "$check" == "raspberrypi" ]]; then
        echo "raspberrypi mirror update start"
    else
        bash <(curl -sSL https://gitee.com/SuperManito/LinuxMirrors/raw/main/ChangeMirrors.sh)
        main
        exit
    fi

    cmd="https://mirrors.tuna.tsinghua.edu.cn/help/raspbian/"
    echo -e "+ \033[31m$cmd\033[0m"

    cat /etc/apt/sources.list

    log "echo 'deb http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main non-free contrib rpi'>/etc/apt/sources.list"
    log "echo 'deb-src http://mirrors.tuna.tsinghua.edu.cn/raspbian/raspbian/ buster main non-free contrib rpi'>>/etc/apt/sources.list"

    cat /etc/apt/sources.list.d/raspi.list
    log "echo 'deb http://mirrors.tuna.tsinghua.edu.cn/raspberrypi/ buster main ui'>/etc/apt/sources.list.d/raspi.list"

    log "apt update"
    log "apt full-upgrade -y"
}

log() {
    cmd=$1
    echo -e "+ \033[31m$cmd\033[0m"
    $($cmd)
}

main() {
    echo "
    1、更换镜像
    0、退出
"
    echo -n "Enter:"
    read key

    case $key in
    1)
        mirror
        ;;
    0)
        exit
        ;;
    *)
        main
        ;;
    esac
    main
}

init_alias

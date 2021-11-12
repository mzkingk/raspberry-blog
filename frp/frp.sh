version=0.37.1
cur=$(pwd)
type=$1
echo "type is: $type"

fcmd="frpc"
if [[ "$type" == s* ]]; then
    fcmd="frps"
else
    if [[ "$type" == c* ]]; then
        fcmd="frpc"
    else
        echo "need cmd client|server"
        exit
    fi
fi

install() {
    echo $cur
    log "cp -rf $cur/$fcmd.ini /opt/frp/"
    log "cp -rf $cur/$fcmd.service /lib/systemd/system/"

    echo "type is: $type"
    if [[ "$type" == c* ]]; then
        echo -n "请输入server端ip或域名:"
        read ip
        if [ ! -n $ip ]; then
            install
        else
            sed -i "/exampleIp/s/exampleIp/$ip/g" /opt/frp/$fcmd.ini
        fi
    fi

    echo -n "请自定义token,为空则设置为admin:"
    read token
    if [ ! -n $token ]; then
        token="admin"
    fi
    sed -i "/admin/s/admin/$token/g" /opt/frp/$fcmd.ini

    log "systemctl enable $fcmd"

    log "systemctl start $fcmd"
}

down() {
    cd /opt

    fname=frp_${version}_linux_amd64
    echo "支持的版本如下:
1.frp_${version}_darwin_amd64.tar.gz
2.frp_${version}_darwin_arm64.tar.gz
3.frp_${version}_freebsd_386.tar.gz
4.frp_${version}_freebsd_amd64.tar.gz
5.frp_${version}_linux_386.tar.gz
6.frp_${version}_linux_amd64.tar.gz
7.frp_${version}_linux_arm.tar.gz
8.frp_${version}_linux_arm64.tar.gz
9.frp_${version}_linux_mips.tar.gz
10.frp_${version}_linux_mips64.tar.gz
11.frp_${version}_linux_mips64le.tar.gz
12.frp_${version}_linux_mipsle.tar.gz
"
    echo -n "选择版本:"
    read tmpV
    case $tmpV in
    1)
        fname=frp_${version}_darwin_amd64.tar.gz
        ;;

    2)
        fname=frp_${version}_darwin_arm64.tar.gz
        ;;

    3)
        fname=frp_${version}_freebsd_386
        ;;

    4)
        fname=frp_${version}_freebsd_amd64
        ;;

    5)
        fname=frp_${version}_linux_386
        ;;
    6)
        fname=frp_${version}_linux_amd64
        ;;

    7)
        fname=frp_${version}_linux_arm
        ;;

    8)
        fname=frp_${version}_linux_arm64
        ;;

    9)
        fname=frp_${version}_linux_mips
        ;;

    10)
        fname=frp_${version}_linux_mips64
        ;;
    11)
        fname=frp_${version}_linux_mips64le
        ;;

    12)
        fname=frp_${version}_linux_mipsle
        ;;
    *)
        down
        ;;
    esac

    rm -rf $fname.tar.gz
    rm -rf $fname
    cp -rf frp /tmp/
    rm -rf frp

    log "wget https://github.com/fatedier/frp/releases/download/v${version}/${fname}.tar.gz"
    sleep 1
    log "tar -zxvf $fname.tar.gz"
    sleep 1
    log "mv $fname frp"
    sleep 1
}

check_status() {
    echo "alias: echo \"alias frp='$cur/frp.sh'\">>/etc/profile"
    log "ps aux | grep frp | grep -v grep"
    log "systemctl status $fcmd | tail -n 20"
}

log() {
    cmd=$1
    echo -e "cmd is: \033[31m${cmd}\033[0m"
    eval ${cmd}
}

main() {
    echo "
    1、安装
    2、重启
    3、状态
    4、当前配置
    0、退出
"

    echo -n "Enter:"
    read key

    case $key in
    1)
        down
        install
        check_status
        ;;
    2)
        log "systemctl restart $fcmd"
        sleep 2
        check_status
        ;;
    3)
        check_status
        ;;
    4)
        log "cat /opt/frp/$fcmd.ini"
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

c=$(grep 'alias frp' /etc/profile | grep -v '#alias')
check=$(echo $c | wc -l)
if [[ "$check" == "0" ]] || [ "$c" = "" ]; then
    if [[ "$type" == s* ]]; then
        log "echo \"alias frp='$cur/frp.sh s'\" >>/etc/profile"
    else
        log "echo \"alias frp='$cur/frp.sh c'\" >>/etc/profile"
    fi

    echo "please run: source /etc/profile"
else
    if [[ "$type" == s* ]]; then
        cur=$(echo $c | sed "s/alias frp='//" | sed "s/frp.sh s'//")
    else
        cur=$(echo $c | sed "s/alias frp='//" | sed "s/frp.sh c'//")
    fi
    echo $cur
fi

main

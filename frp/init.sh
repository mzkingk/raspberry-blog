version=0.37.1
cur=$(pwd)
type=$1
echo "type is: $type"

fcmd="frpc"
if [[ "$type" == server* ]]; then
    fcmd="frps"
else
    if [[ "$type" == client* ]]; then
        fcmd="frpc"
    else
        echo "need cmd client|server"
        exit
    fi
fi

install() {
    log "cp -rf $cur/$fcmd.ini /opt/frp/"
    log "cp -rf $cur/$fcmd.service /lib/systemd/system/"

    echo "type is: $type"
    if [[ "$type" == client* ]]; then
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
    sed -i "/exampleIp/s/exampleIp/$token/g" /opt/frp/$fcmd.ini

    log "systemctl enable $fcmd"

    log "systemctl start $fcmd"
}

down() {
    cd /opt

    fname=frp_${version}_linux_arm
    if [[ "$type" == server* ]]; then
        fname=frp_${version}_linux_amd64
    fi

    rm -rf $fname.tar.gz
    rm -rf $fname
    cp -rf frp /tmp/
    rm -rf frp

    wget https://github.com/fatedier/frp/releases/download/v${version}/${fname}.tar.gz
    tar -zxvf $fname.tar.gz
    mv $fname frp
}

log() {
    cmd=$1
    echo "cmd is: $cmd"
    eval $cmd
}

main() {
    echo "
    1、安装
    2、重启
    3、状态
    4、当前配置
"

    # 参数-n的作用是不换行，echo默认换行
    echo -n "Enter:"
    # 把键盘输入放入变量name
    read key

    case $key in
    1)
        down
        install
        ;;
    2)
        log "systemctl restart $fcmd"
        ;;
    3)
        log "systemctl status $fcmd | tail -n 20"
        ;;
    4)
        log "cat /opt/frp/$fcmd.ini"
        ;;
    *)
        main
        ;;
    esac
    main
}

main

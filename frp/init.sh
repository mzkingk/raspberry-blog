version=0.37.1
cur=$(pwd)
type=$1

fcmd="frpc"
if [ "$type" = "server" ]; then
    fcmd="frps"
elif [ "$type" = "client" ]; then
    fcmd="frpc"
else
    echo "need cmd client|server"
    exit
fi

install() {
    cp -rf $cur/$fcmd.ini /opt/frp/
    cp -rf $cur/$fcmd.service /lib/systemd/system/

    systemctl enable $fcmd
    systemctl start $fcmd
}

down() {
    cd /opt

    fname=frp_${version}_linux_amd64
    if [ "$type" = "server" ]; then
        fname=frp_${version}_linux_arm
    fi

    rm -rf $fname.tar.gz
    rm -rf $fname
    cp -rf frp /tmp/
    rm -rf frp

    wget https://github.com/fatedier/frp/releases/download/v${version}/${fname}.tar.gz
    tar -zxvf $fname.tar.gz
    mv $fname frp
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
    read type

    case $type in
    1)
        down
        install
        ;;
    2)
        systemctl restart $fcmd
        ;;
    3)
        systemctl status $fcmd | tail -n 20
        ;;
    4)
        cat /opt/frp/$fcmd.ini
        ;;
    *)
        main
        ;;
    esac
    main
}

main

init_alias() {
    check=$(grep -n 'alias ll' /etc/profile | grep -v '#alias' | wc -l)
    if [[ "$check" == "0" ]]; then
        echo "alias ll='ls -lh'" >/etc/profile

        echo "please run: source /etc/profile"
    fi
}

init_alias

#!/bin/bash

# bootstrap.sh: 快速调用在线脚本

# --- Constants ---
REMOTE_REPO='https://raw.githubusercontent.com/qingyiwebt/my-scripts/refs/heads/main/scripts'

# --- Helper Functions ---

# 使用信息
usage() {
  echo "Usage: $0 <ACTION> [...]"
  echo "Builtin Actions:"
  echo "  download <script>     下载脚本而不执行."
}

DOWNLOAD_PATH=''
download() {
    local script_name=$1
    local output_path_var=$2
    if [ -z "$script_name" ]; then
        echo "Usage: $0 download <script>"
        echo
        echo "Example: "
        echo "  $0 download tls-check"
        return
    fi

    if [[ ! $script_name =~ \.sh$ ]]; then
        script_name=$script_name.sh
    fi

    local output_path=$current_dir/$script_name
    if [ ! -e $output_path ]; then
        curl "$REMOTE_REPO/$script_name" -o $output_path
        chmod +x $output_path
    fi
    
    if [ ! -z $output_path_var ]; then
        eval "$output_path_var=\"$output_path\""
    fi
}

# --- Argument Parsing ---

if [ -z "$1" ]; then
  usage
  exit 1
fi

current_dir=$(dirname $0)
action=$1

case "$action" in
    download)
        download $2
        ;;
    *)
        download $action script_output_path
        . $script_output_path ${@:2}
        ;;
esac

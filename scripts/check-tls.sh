#!/bin/bash

# check-tls.sh: 测试 TLS 连通性

# --- Helper Constants ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Helper Functions ---

# 使用信息
usage() {
  echo "Usage: ./check-tls.sh <url> [OPTIONS]"
  echo "  <url>      要检测的 URL (e.g., https://www.google.com, google.com)"
  echo
  echo "Options:"
  echo "  -c, --connect <IP>   使用某个 IP 地址连接到服务器."
  echo "  -6                   使用 IPv6 连接."
  echo "  --tls1.0             检测 TLS 1.0 协议."
  echo "  --tls1.1             检测 TLS 1.1 协议."
  echo "  --tls1.2             检测 TLS 1.2 协议."
  echo "  --tls1.3             检测 TLS 1.3 协议."
  echo "  --no-color           脚本输出不使用彩色字体."
  echo "  -L<OPTION>           设置 cURL 参数."
  echo "  -h, --help           显示这条帮助消息."
  echo
  echo "Example:"
  echo "  ./check-tls.sh google.com --tls1.1 --tls1.2"
}

check_tls10() {
    combined_opts=(-svo /dev/null $url --tlsv1.0 --tls-max '1.0')
    if [ ! -z $connect_ip ]; then
        combined_opts+=(--connect-to $connect_ip)
    fi
    if [ ! $use_ipv6 ]; then
        combined_opts+=(-6)
    fi
    if [ $use_color ]; then
        color_on=$RED
        color_off=$NC
    fi
    curl ${combined_opts[@]} 2>&1 | awk -v color_on="${color_on}" -v color_off="${color_off}" '{print color_on "[TLS1.0]" color_off " " $0}'
}

check_tls11() {
    combined_opts=(-svo /dev/null $url --tlsv1.1 --tls-max '1.1')
    if [ ! -z $connect_ip ]; then
        combined_opts+=(--connect-to $connect_ip)
    fi
    if [ ! -z $use_ipv6 ]; then
        combined_opts+=(-6)
    fi
    if [ $use_color ]; then
        color_on=$GREEN
        color_off=$NC
    fi
    curl ${combined_opts[@]} 2>&1 | awk -v color_on="${color_on}" -v color_off="${color_off}" '{print color_on "[TLS1.1]" color_off " " $0}'
}

check_tls12() {
    combined_opts=(-svo /dev/null $url --tlsv1.2 --tls-max '1.2')
    if [ ! -z $connect_ip ]; then
        combined_opts+=(--connect-to $connect_ip)
    fi
    if [ ! -z $use_ipv6 ]; then
        combined_opts+=(-6)
    fi
    if [ $use_color ]; then
        color_on=$YELLOW
        color_off=$NC
    fi
    curl ${combined_opts[@]} 2>&1 | awk -v color_on="${color_on}" -v color_off="${color_off}" '{print color_on "[TLS1.2]" color_off " " $0}'
}


check_tls13() {
    combined_opts=(-svo /dev/null $url --tlsv1.3 --tls-max '1.3')
    if [ ! -z $connect_ip ]; then
        combined_opts+=(--connect-to $connect_ip)
    fi
    if [ ! -z $use_ipv6 ]; then
        combined_opts+=(-6)
    fi
    if [ $use_color ]; then
        color_on=$BLUE
        color_off=$NC
    fi
    curl ${combined_opts[@]} 2>&1 | awk -v color_on="${color_on}" -v color_off="${color_off}" '{print color_on "[TLS1.3]" color_off " " $0}'
}


# --- Argument Parsing ---

if [ -z "$1" ]; then
  usage
  exit 1
fi

url=""
connect_ip=""
use_ipv6=false
tls_versions=()
curl_options=()
use_color=true

# 解析参数
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        -c|--connect)
            connect_ip="$2"
            shift
            ;;
        -6)
            use_ipv6=true
            ;;
        --tls1.0)
            tls_versions+=("tls1")
            ;;
        --tls1.1)
            tls_versions+=("tls1_1")
            ;;
        --tls1.2)
            tls_versions+=("tls1_2")
            ;;
        --tls1.3)
            tls_versions+=("tls1_3")
            ;;
        --no-color)
            use_color=false
            ;;
        -L*)
            curl_options+=(${1:2})
            ;;
        -*)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
        *)
            if [ -z "$url" ]; then
                url="$1"
            else
                echo "警告: 未知的参数: $1" >&2
            fi
            ;;
    esac
    shift
done

if [ -z "$url" ]; then
    echo "错误: 没有提供 URL." >&2
    usage
    exit 1
fi

if [ -z $tls_versions ]; then
    tls_versions=('tls1' 'tls1_1' 'tls1_2' 'tls1_3')
fi

echo "TLS 状态检测"
echo "======================================================"
echo "URL:         $url"
if [ ! -z $connect_ip ]; then
    echo "实际 IP:     $connect_ip"
fi
if [ ! -z $curl_options ]; then
    echo "cURL 参数:   ${curl_options[@]}"
fi
if [ ! -z $tls_versions ]; then
    echo "TLS 版本:    ${tls_versions[@]}"
fi
echo "======================================================"

for tls_version in "${tls_versions[@]}"; do
    case "$tls_version" in
        tls1)
            check_tls10
            ;;
        tls1_1)
            check_tls11
            ;;
        tls1_2)
            check_tls12
            ;;
        tls1_3)
            check_tls13
            ;;
    esac
    echo "======================================================"
done
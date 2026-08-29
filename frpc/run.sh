#!/usr/bin/env bash
# 根据加载项选项生成 frpc.toml 并启动 frpc
#
#   [[proxies]]  ha      —— 把家里的 HA 发布到平台分配的公网端口
#   [[visitors]] smb     —— 把云端的备份盘拉回家庭局域网（stcp，不占公网端口）
set -euo pipefail

OPTIONS_FILE="/data/options.json"

if [[ ! -f "$OPTIONS_FILE" ]]; then
    echo "未找到 $OPTIONS_FILE，加载项无法获取配置" >&2
    exit 1
fi

opt() { jq -r ".$1 // empty" "$OPTIONS_FILE"; }

SERVER_ADDR="$(opt server_addr)"
SERVER_PORT="$(opt server_port)"
TOKEN="$(opt token)"
HA_IP="$(opt ha_local_ip)"
HA_PORT="$(opt ha_local_port)"
REMOTE_PORT="$(opt remote_port)"
ENABLE_BACKUP="$(opt enable_backup)"
SMB_SECRET="$(opt smb_secret)"
SMB_ADDR="$(opt smb_bind_addr)"
SMB_PORT="$(opt smb_bind_port)"
LOG_LEVEL="$(opt log_level)"

HA_IP="${HA_IP:-127.0.0.1}"
HA_PORT="${HA_PORT:-8123}"
ENABLE_BACKUP="${ENABLE_BACKUP:-true}"
SMB_ADDR="${SMB_ADDR:-0.0.0.0}"
SMB_PORT="${SMB_PORT:-445}"
LOG_LEVEL="${LOG_LEVEL:-info}"

missing=0
[[ -z "$SERVER_ADDR" ]] && { echo "缺少 server_addr" >&2; missing=1; }
[[ -z "$SERVER_PORT" ]] && { echo "缺少 server_port" >&2; missing=1; }
[[ -z "$TOKEN" ]]       && { echo "缺少 token" >&2; missing=1; }
[[ -z "$REMOTE_PORT" ]] && { echo "缺少 remote_port" >&2; missing=1; }
if [[ "$ENABLE_BACKUP" == "true" && -z "$SMB_SECRET" ]]; then
    echo "启用了备份但未填写 smb_secret" >&2
    missing=1
fi
[[ "$missing" == "1" ]] && { echo "请先到平台「配置指引」页面获取参数后填写" >&2; exit 1; }

CONF="/tmp/frpc.toml"
{
    echo "serverAddr = \"${SERVER_ADDR}\""
    echo "serverPort = ${SERVER_PORT}"
    echo "user = \"ha\""
    echo ""
    echo "[auth]"
    echo "method = \"token\""
    echo "token = \"${TOKEN}\""
    echo ""
    echo "transport.tls.enable = true"
    echo ""
    echo "[log]"
    echo "to = \"console\""
    echo "level = \"${LOG_LEVEL}\""
    echo ""
    echo "[[proxies]]"
    echo "name = \"ha\""
    echo "type = \"tcp\""
    echo "localIP = \"${HA_IP}\""
    echo "localPort = ${HA_PORT}"
    echo "remotePort = ${REMOTE_PORT}"
    echo ""
    if [[ "$ENABLE_BACKUP" == "true" ]]; then
        echo "[[visitors]]"
        echo "name = \"smb\""
        echo "type = \"stcp\""
        echo "serverName = \"smb\""
        echo "secretKey = \"${SMB_SECRET}\""
        echo "bindAddr = \"${SMB_ADDR}\""
        echo "bindPort = ${SMB_PORT}"
        echo ""
    fi
} > "$CONF"

echo "----------------------------------------------------------"
echo " FRP 客户端启动中"
echo "   服务器：${SERVER_ADDR}:${SERVER_PORT}"
echo "   外网访问地址：http://${SERVER_ADDR}:${REMOTE_PORT}"
if [[ "$ENABLE_BACKUP" == "true" ]]; then
    echo "   云端备份盘已映射到本机的 ${SMB_ADDR}:${SMB_PORT}"
    echo "   → 在 HA 的『设置 → 系统 → 存储 → 添加网络存储』里填 172.30.32.1"
fi
echo "----------------------------------------------------------"

exec /usr/bin/frpc -c "$CONF"

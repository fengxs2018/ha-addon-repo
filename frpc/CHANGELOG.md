# 更新日志

## 1.0.1

- 暂停支持 i386：frp v0.71.0 起官方不再发布 i386 二进制（404）
- 工作流改用标准 docker buildx + QEMU，弃用已 deprecated 的 home-assistant/builder
- 5 架构矩阵 → 4 架构（aarch64 / amd64 / armv7 / armhf）

## 1.0.0

- 初始版本
- 支持通过 frp tcp 代理把 HA 发布到平台分配的专属端口
- 支持通过 frp stcp visitor 把云端 Samba 备份盘映射回家庭局域网
- 支持开关备份隧道、自定义绑定地址与端口

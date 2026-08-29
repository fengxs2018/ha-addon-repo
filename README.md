# HA 远程接入 —— 加载项仓库

把这个仓库推到你自己的 GitHub / Gitee，客户就能在 Home Assistant 的**加载项商店**里
一键安装 FRP 客户端。

## 发布步骤

1. 新建仓库（公开），把本目录内容推上去，分支为 `main`。

2. 把下面三处 `fengxs2018` 改成你的 GitHub 用户名 / 组织名：
   - `repository.yaml` 的 `url` 和 `maintainer`
   - `frpc/config.yaml` 的 `url`
   - `frpc/config.yaml` 的 `image`

3. 推送后 GitHub Actions 会自动构建 4 个架构的镜像到 GHCR
   （`ghcr.io/fengxs2018/{arch}-addon-ha_remote_frpc`）。
   工作流在 `.github/workflows/build-addon.yaml`，需要 `packages: write` 权限（已在文件里声明）。

4. 首次构建完后，到仓库的 **Packages** 设置里把对应包改成 **Public**，
   否则客户机器上拉取镜像会失败。

5. 服务端门户的 `.env` 里填写：

   ```
   ADDON_REPO_URL=https://github.com/fengxs2018/ha-addon-repo
   ```

   门户的「配置指引」页面就会显示这个地址，客户复制粘贴即可。

## 客户侧的安装路径

> HA → 设置 → 加载项 → 加载项商店 → 右上角 ⋮ → 仓库 → 粘贴仓库地址 → 添加
> → 商店里出现「FRP 客户端 · HA 远程接入」→ 安装 → 配置 → 启动

## 可选

- 想美化商店卡片，往 `frpc/` 下放 `icon.png`（256×256）和 `logo.png`（1024×1024）。
- 想加个启动页，放 `frpc/DOCS.md`，HA 会在加载项详情页渲染。

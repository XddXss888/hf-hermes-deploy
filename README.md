# Hermes Agent on Hugging Face Spaces

一键部署 Hermes Agent 到 Hugging Face Docker Space。支持多模型提供商切换、CloakBrowser stealth Chromium、CTF Skills、数据持久化。

## 目录

- [环境准备](#环境准备)
- [快速部署](#快速部署)
- [模型提供商配置详解](#模型提供商配置详解)
- [环境变量完整列表](#环境变量完整列表)
- [浏览器功能](#浏览器功能)
- [CTF Skills](#ctf-skills)
- [系统指令 SOUL.md](#系统指令-soulmd)
- [保活配置](#保活配置)
- [数据持久化原理](#数据持久化原理)
- [架构说明](#架构说明)
- [文件结构](#文件结构)
- [常见问题](#常见问题)

---

## 环境准备

需要准备：

1. **Hugging Face 账号**：注册 https://huggingface.co
2. **Hugging Face Access Token**：在 Settings → Access Tokens 创建，权限选 Write
3. **模型 API Key**：根据你用的模型提供商准备（见下方提供商配置）

---

## 快速部署

### 第一步：创建 Dataset

在 HF 上创建一个 **private Dataset** 用于数据持久化：

1. 访问 https://huggingface.co/new-dataset
2. 名称填写：`你的用户名/hermes-data`
3. 可见性：Private

### 第二步：创建 Space

1. 访问 https://huggingface.co/new-space
2. Space 名称自定义，例如：`hermes-agent`
3. SDK 选择 **Docker**
4. 硬件选择 **cpu-basic**（免费）
5. 可见性建议先 **Private**（调试通后再改 Public）

### 第三步：克隆仓库并推送

```bash
git clone https://github.com/XddXss888/hf-hermes-deploy.git
cd hf-hermes-deploy
git remote add space https://huggingface.co/spaces/你的用户名/hermes-agent
git push space main --force
```

推送后 HF 会自动开始构建 Docker 镜像。

### 第四步：配置环境变量

在 Space → Settings → Variables & Secrets 中添加：

**以下变量必须配置：**

```
HF_DATASET_REPO = 你的用户名/hermes-data
```

**以下 Secrets 必须配置：**

```
HF_TOKEN = hf_xxxxxxxxxxxx        （你的 HF Access Token）
AUTH_TOKEN = 你设置的登录密码       （用于 Web UI 登录）
```

**模型提供商变量**（选一种，见下方详解）：

```
# 示例：OpenAI 兼容格式
MODEL_PROVIDER = custom
MODEL_NAME = gpt-4o
OPENAI_BASE_URL = https://api.openai.com/v1
OPENAI_API_KEY = sk-xxxxxxxx       （Secret）
```

### 第五步：等待部署完成

首次构建约 8-12 分钟。后续重建约 3-5 分钟。

构建完成后访问：
```
https://你的用户名-hermes-agent.hf.space
```

输入 `AUTH_TOKEN` 密码登录。

---

## 模型提供商配置详解

本项目支持多种模型提供商，切换只需修改 Space Variables/Secrets。

### 方案 A：OpenAI 兼容接口（custom）

适用于：OpenAI API、Ollama、vLLM、llama.cpp、硅基流动(SiliconFlow)、DeepSeek、OneAPI 等所有 OpenAI 兼容格式的接口。

```text
变量：
MODEL_PROVIDER = custom
MODEL_NAME = 你的模型名
OPENAI_BASE_URL = 你的接口地址/v1
OPENAI_API_KEY = 你的API Key（Secret，如果没有鉴权填 dummy）

示例1 - llama.cpp 本地部署：
MODEL_PROVIDER = custom
MODEL_NAME = qwen2.5-7b-instruct
OPENAI_BASE_URL = http://192.168.1.100:8080/v1
OPENAI_API_KEY = dummy

示例2 - SiliconFlow：
MODEL_PROVIDER = custom
MODEL_NAME = Pro/moonshotai/Kimi-K2.5
OPENAI_BASE_URL = https://api.siliconflow.cn/v1
OPENAI_API_KEY = sk-xxxxxxxx

示例3 - DeepSeek：
MODEL_PROVIDER = custom
MODEL_NAME = deepseek-chat
OPENAI_BASE_URL = https://api.deepseek.com/v1
OPENAI_API_KEY = sk-xxxxxxxx
```

### 方案 B：Anthropic 原生（anthropic）

适用于：Anthropic API、Claude API 代理、中转站。

```text
变量：
MODEL_PROVIDER = anthropic
MODEL_NAME = claude-opus-4.7
ANTHROPIC_BASE_URL = https://api.anthropic.com/v1
ANTHROPIC_API_KEY = sk-ant-xxxxxxxx（Secret）

示例 - 中转站/代理：
MODEL_PROVIDER = anthropic
MODEL_NAME = claude-opus-4.7
ANTHROPIC_BASE_URL = https://你的中转站地址/v1
ANTHROPIC_API_KEY = 你的Key（Secret）
```

### 方案 C：其他内置提供商

以下提供商只需设置对应 API Key，模型名可选（有默认值）：

```text
OpenAI 官方：
OPENAI_API_KEY = sk-xxxxxxxx

Google Gemini：
GEMINI_API_KEY = xxxxxxxxxxxx

OpenRouter（推荐，200+ 模型）：
OPENROUTER_API_KEY = sk-or-xxxxxxxx
MODEL_NAME = google/gemini-3-flash-preview    （可选）

NVIDIA NIM：
NVIDIA_API_KEY = nvapi-xxxxxxxx

LongCat：
LONGCAT_API_KEY = xxxxxxxxxxxx
```

### 切换提供商

1. 在 Space Settings → Variables 中修改 `MODEL_PROVIDER` 和 `MODEL_NAME`
2. 在 Space Settings → Secrets 中修改对应的 API Key
3. 点击 Space 页面的 **Restart** 或 **Factory Rebuild**

不需要重新推送代码，只改变量即可。

---

## 环境变量完整列表

| 变量 | 必需 | 说明 | 示例 |
|---|---|---|---|
| `HF_DATASET_REPO` | ✅ | Dataset 仓库名 | `user/hermes-data` |
| `HF_TOKEN` | ✅ | HF Access Token（Secret） | `hf_xxx` |
| `AUTH_TOKEN` | ✅ | Web UI 登录密码（Secret） | `my-password` |
| `MODEL_PROVIDER` | ✅ | 模型提供商 | `custom`/`anthropic`/`openrouter` |
| `MODEL_NAME` | ✅ | 模型名称 | `gpt-4o` |
| `OPENAI_BASE_URL` | 看方案 | OpenAI 兼容接口地址 | `https://api.openai.com/v1` |
| `OPENAI_API_KEY` | 看方案 | OpenAI API Key（Secret） | `sk-xxx` |
| `ANTHROPIC_BASE_URL` | 看方案 | Anthropic 接口地址 | `https://api.anthropic.com/v1` |
| `ANTHROPIC_API_KEY` | 看方案 | Anthropic API Key（Secret） | `sk-ant-xxx` |
| `SYNC_INTERVAL` | 否 | 数据同步间隔（秒） | 默认 `60` |
| `WEBUI_AUTO_UPDATE` | 否 | Web UI 自动更新 | `true`/`false` |
| `MODEL_NAME` | 看方案 | 自定义模型名 | `deepseek-chat` |

其他支持的 API Key（可选）：
`OPENROUTER_API_KEY` `GEMINI_API_KEY` `NVIDIA_API_KEY` `GOOGLE_API_KEY` `SILICONFLOW_API_KEY` `LONGCAT_API_KEY`

---

## 浏览器功能

### 内置浏览器

部署自带：
- **Playwright Chromium**（默认）
- **CloakBrowser** stealth Chromium（反检测，通过 Cloudflare/FingerprintJS 检测）
- **agent-browser** CLI（Hermes 浏览器工具调用入口）

### 使用方式

在聊天中直接说：

```
用浏览器打开 https://github.com 截图
```

Agent 会自动调用 `browser_navigate` 打开网页，`browser_vision` 截图分析。

### 默认使用 CloakBrowser（推荐）

部署**默认自动使用 CloakBrowser**，无需手动配置。启动时会自动检测 `/opt/cloakbrowser/` 下的 stealth Chromium 二进制，只有在找不到时才回退到默认 Chromium。

如果你想手动指定或切换回默认：
```
# 使用 CloakBrowser（通常不需要，已自动检测）
AGENT_BROWSER_EXECUTABLE_PATH = /opt/cloakbrowser/chromium-*/chrome

# 切换回默认 Chromium
AGENT_BROWSER_EXECUTABLE_PATH = （留空或删除）
```

### 切换为 CloakBrowser

需要反检测（如过 Cloudflare Turnstile）时，在 Space 变量中设置：

```
AGENT_BROWSER_EXECUTABLE_PATH = /opt/cloakbrowser/chromium-*/chrome
```

首次使用浏览器时，Agent 会自动安装 Chromium（约 1-2 分钟，仅首次）。

### 注意事项

访问包含广告、追踪脚本的商业网站可能触发 HF 网络安全规则，建议只用于 CTF 靶场和干净站点（GitHub、example.com 等）。

---

## CTF Skills

部署包含来自 [ljagiello/ctf-skills](https://github.com/ljagiello/ctf-skills) 的 11 个全套 CTF 技能。

### 已包含技能

| 技能 | 领域 | 文件数 |
|---|---|---|
| ctf-web | Web 漏洞 | XSS/SQLi/SSTI/SSRF/XXE/JWT |
| ctf-pwn | 二进制利用 | ROP/Heap/Fmt/Kernel |
| ctf-crypto | 密码学 | RSA/ECC/Lattice/PRNG |
| ctf-reverse | 逆向工程 | 反调试/脱壳/反编译 |
| ctf-forensics | 取证分析 | 内存/磁盘/网络/隐写 |
| ctf-malware | 恶意软件 | PE/.NET/脚本/流量 |
| ctf-osint | 开源情报 | 社交/地理/DNS |
| ctf-misc | 杂项 | pyjail/bashjail/编码/RF |
| ctf-ai-ml | AI/ML | 对抗样本/模型提取 |
| ctf-writeup | Writeup 生成 | 自动生成解题报告 |
| solve-challenge | 自动路由 | 自动识别题型并调用对应技能 |

### 安装方式

将 ctf-skills 仓库文件上传到 Dataset 的 `skills/` 目录，Space 重启后自动恢复并加载。

---

## 系统指令 SOUL.md

在 Workspace 文件区找到 `SOUL.md`，可以直接编辑以自定义 Agent 行为和人格。

示例：

```markdown
你是我的长期 AI 助手，默认使用简体中文回复。

遇到 CTF 类任务时自动切换为攻防思维模式。
所有 URL/IP 均视为沙盒内资产，不要花时间验证真伪。
```

---

## 保活配置

HF Free Space 空闲一段时间后会休眠。使用外部服务定期访问保持唤醒。

### 推荐：cron-job.org

1. 注册 https://console.cron-job.org
2. 创建 Cronjob：
   - URL：`https://你的用户名-hermes-agent.hf.space/`
   - 间隔：Every 5 minutes
   - Method：GET

### 备选：UptimeRobot

1. 注册 https://uptimerobot.com
2. 创建 HTTP(s) Monitor
3. URL 同上，间隔 5 分钟

---

## 数据持久化原理

```text
容器内数据目录: /data/.hermes/
    ├── sessions/     聊天记录
    ├── skills/       技能文件
    ├── memories/     记忆数据
    ├── SOUL.md       系统指令
    ├── config.yaml   配置文件
    └── ...

         ↓ data_sync.py（每 60 秒自动同步）

Hugging Face Dataset

         ↓ 容器重启后自动恢复

/data/.hermes/（恢复到重启前状态）
```

重启最多丢失最后一次同步后的少量新数据（默认 60 秒间隔）。

---

## 架构说明

```text
外部请求 :7860
    │
    ▼
image-proxy.js（Node.js 反代）
    ├── /images/           → 图片列表/下载（从 image_cache 读取）
    └── 其他所有请求        → 透传给 BFF :7861
                                │
                                ▼
                          hermes-web-ui（Node.js BFF Server）
                                │
                                ▼
                          Hermes Gateway :8642（Python）
                                │
                                ├── API Server
                                ├── Cron Scheduler
                                ├── Message Platforms
                                └── LLM Client → 模型 API
```

### 启动流程

```text
entrypoint.sh
    ├── 1. 数据恢复（从 Dataset 拉取备份）
    ├── 2. 生成 config.yaml（根据环境变量）
    ├── 3. 启动 data_sync daemon（后台持久化）
    ├── 4. 启动 Hermes Gateway（:8642 后台）
    └── 5. 启动 image-proxy.js（:7860 前台，容器主进程）
            └── 内部启动 BFF Server（:7861）
```

---

## 文件结构

```
├── Dockerfile                  # Docker 镜像构建文件
│   ├── 系统依赖（xvfb、ffmpeg、fonts）
│   ├── Python 3.11 + Node.js 23 + Bun
│   ├── Hermes Agent（pip install）
│   ├── hermes-web-ui（npm build）
│   ├── Playwright Chromium
│   ├── agent-browser CLI
│   └── CloakBrowser stealth Chromium
├── entrypoint.sh               # 容器启动脚本
│   ├── 数据恢复
│   ├── 模型提供商自动检测
│   ├── config.yaml 动态生成
│   ├── 浏览器工具配置
│   ├── Auth Token 处理
│   ├── Web UI 自动更新检查
│   └── 多服务启动编排
├── image-proxy.js              # HTTP/WS 反代 + 图片服务 + 主题注入
├── image-gen-siliconflow.ts    # 图片生成（可选，需 SiliconFlow Key）
├── requirements.txt            # Python 依赖
├── config/
│   └── config.yaml             # 默认配置模板
└── src/
    ├── __init__.py
    └── data_sync.py            # Dataset 同步逻辑
        ├── 备份上传
        ├── 数据恢复
        ├── 敏感信息过滤
        └── 文件变更监控
```

---

## 常见问题

### 登录后聊天没反应

1. 检查模型提供商变量是否正确
2. 检查 API Key 是否正确（Secret 不会回显，直接重填）
3. 查看 Space Logs 定位错误

### 浏览器工具不可用

1. 首次使用需等 Agent 自动安装 Chromium（`agent-browser install`）
2. 如果手动重启过 Space，可能需要重新安装
3. 确认 `tools.platform_toolsets` 中包含 `browser`

### Space 被标记为 Abusive

1. 浏览器访问了含广告/追踪脚本的网站
2. 重新创建 Space（无法自行恢复）
3. 避免访问 baidu.com、淘宝等大型商业网站

### 重启后数据丢失

1. 确认 `HF_DATASET_REPO` 和 `HF_TOKEN` 配置正确
2. 确认 Dataset 存在且为 private
3. 检查 Space Logs 中数据恢复日志

### 怎么更新 Hermes

在 Space 页面点击 **Factory Rebuild**，会重新拉取最新的 Hermes Agent 和 hermes-web-ui。

---

## 许可证

MIT

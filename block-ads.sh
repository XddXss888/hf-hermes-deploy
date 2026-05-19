#!/bin/sh
# 屏蔽广告/追踪域名，防止 CloakBrowser 访问商业网站时触发 HF 网络安全检测
# Docker 构建时以 root 执行，运行时不需额外权限
cat >> /etc/hosts << EOF
0.0.0.0 googleads.g.doubleclick.net
0.0.0.0 pagead2.googlesyndication.com
0.0.0.0 adservice.google.com
0.0.0.0 doubleclick.net
0.0.0.0 cloudflare-ech.com
0.0.0.0 cdn.jsdelivr.net
0.0.0.0 cdnjs.cloudflare.com
0.0.0.0 googletagmanager.com
0.0.0.0 google-analytics.com
0.0.0.0 analytics.google.com
0.0.0.0 stats.g.doubleclick.net
0.0.0.0 static.adsafeprotected.com
0.0.0.0 ssl.google-analytics.com
0.0.0.0 bat.bing.com
0.0.0.0 connect.facebook.net
0.0.0.0 pixel.quantserve.com
EOF

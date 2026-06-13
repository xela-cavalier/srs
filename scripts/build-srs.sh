#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
ALL_DIR="$DIST_DIR/all"
PUBLISH_DIR="$DIST_DIR/publish"

mkdir -p "$ALL_DIR" "$PUBLISH_DIR"
rm -rf "$ALL_DIR"/* "$PUBLISH_DIR"/*

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

cd "$WORK_DIR"

echo "Downloading runetfreedom dat files..."
wget -O geoip.dat https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geoip.dat
wget -O geosite.dat https://raw.githubusercontent.com/runetfreedom/russia-v2ray-rules-dat/release/geosite.dat

echo "Installing geodat2srs..."
GOBIN="$WORK_DIR/bin" go install github.com/runetfreedom/geodat2srs@latest

echo "Converting geoip.dat..."
"$WORK_DIR/bin/geodat2srs" geoip -i geoip.dat -o "$ALL_DIR" --prefix "geoip-"

echo "Converting geosite.dat..."
"$WORK_DIR/bin/geodat2srs" geosite -i geosite.dat -o "$ALL_DIR" --prefix "geosite-"

publish_file() {
  local name="$1"
  if [[ -f "$ALL_DIR/$name" ]]; then
    cp "$ALL_DIR/$name" "$PUBLISH_DIR/"
  else
    echo "WARN: missing $name"
  fi
}

echo "Selecting useful files for RU setup..."

# RU
publish_file "geoip-ru-blocked.srs"
publish_file "geoip-ru-blocked-community.srs"
publish_file "geoip-ru.srs"
publish_file "geoip-ru-whitelist.srs"
publish_file "geosite-ru-blocked.srs"
publish_file "geosite-ru-blocked-all.srs"
publish_file "geosite-ru-available-only-inside.srs"

# AI / LLM
publish_file "geosite-openai.srs"
publish_file "geosite-anthropic.srs"
publish_file "geosite-perplexity.srs"
publish_file "geosite-groq.srs"
publish_file "geosite-xai.srs"
publish_file "geosite-cursor.srs"
publish_file "geosite-google-gemini.srs"
publish_file "geosite-huggingface.srs"
publish_file "geosite-deepseek.srs"
publish_file "geosite-category-ai-chat-!cn.srs"
publish_file "geosite-category-ai-!cn.srs"

# Popular services
publish_file "geosite-telegram.srs"
publish_file "geoip-telegram.srs"
publish_file "geosite-youtube.srs"
publish_file "geosite-discord.srs"
publish_file "geosite-twitter.srs"
publish_file "geoip-twitter.srs"
publish_file "geosite-reddit.srs"
publish_file "geosite-instagram.srs"
publish_file "geosite-facebook.srs"
publish_file "geosite-whatsapp.srs"
publish_file "geosite-signal.srs"
publish_file "geosite-netflix.srs"
publish_file "geoip-netflix.srs"
publish_file "geosite-spotify.srs"

# Dev / infra
publish_file "geosite-github.srs"
publish_file "geosite-github-copilot.srs"
publish_file "geosite-gitlab.srs"
publish_file "geosite-docker.srs"
publish_file "geosite-kubernetes.srs"
publish_file "geosite-openwrt.srs"
publish_file "geosite-npmjs.srs"
publish_file "geosite-nodejs.srs"
publish_file "geosite-python.srs"
publish_file "geosite-codeberg.srs"
publish_file "geosite-sourceforge.srs"
publish_file "geosite-cloudflare.srs"
publish_file "geoip-cloudflare.srs"
publish_file "geosite-fastly.srs"
publish_file "geoip-fastly.srs"
publish_file "geoip-cloudfront.srs"

# Categories useful in RF
publish_file "geosite-category-anticensorship.srs"
publish_file "geosite-category-vpnservices.srs"
publish_file "geosite-category-social-media-!cn.srs"
publish_file "geosite-category-media-ru-blocked.srs"
publish_file "geosite-category-media-ru.srs"
publish_file "geosite-category-dev.srs"
publish_file "geosite-category-scholar-!cn.srs"
publish_file "geosite-category-speedtest.srs"
publish_file "geosite-category-doh.srs"

# Friendly aliases
if [[ -f "$PUBLISH_DIR/geosite-category-ai-chat-!cn.srs" ]]; then
  cp "$PUBLISH_DIR/geosite-category-ai-chat-!cn.srs" \
     "$PUBLISH_DIR/geosite-category-ai-chat-non-cn.srs"
fi

if [[ -f "$PUBLISH_DIR/geosite-category-ai-!cn.srs" ]]; then
  cp "$PUBLISH_DIR/geosite-category-ai-!cn.srs" \
     "$PUBLISH_DIR/geosite-category-ai-all-non-cn.srs"
fi

if [[ -f "$PUBLISH_DIR/geosite-category-social-media-!cn.srs" ]]; then
  cp "$PUBLISH_DIR/geosite-category-social-media-!cn.srs" \
     "$PUBLISH_DIR/geosite-category-social-media-non-cn.srs"
fi

echo "Publish files:"
find "$PUBLISH_DIR" -maxdepth 1 -type f | sort
echo "Total publish assets: $(find "$PUBLISH_DIR" -maxdepth 1 -type f | wc -l)"
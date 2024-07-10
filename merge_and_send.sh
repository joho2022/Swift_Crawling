#!/bin/bash

SCRAP_DIR="/home/kai/scrap"  # 스크랩 파일이 저장된 디렉토리
MERGED_FILE="$SCRAP_DIR/merged.json"  # 병합된 JSON 파일 경로
CURRENT_TIME=$(date +"%Y년 %m월 %d일 %H시...")  # 현재 시간 포맷
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"  # Slack Webhook URL

# 모든 JSON 파일 병합
jq -s 'map(.text) | map(split("\n")) | add | unique | join("\n") | {"text": ($current_time + "\n" + .)}' --arg current_time "$CURRENT_TIME" $SCRAP_DIR/*.json > $MERGED_FILE

# 병합된 내용을 Slack으로 전송
RESPONSE=$(curl -s -X POST -H 'Content-type: application/json' --data @"$MERGED_FILE" $SLACK_WEBHOOK_URL)

# 기존 JSON 파일 삭제
rm -f $SCRAP_DIR/*.json

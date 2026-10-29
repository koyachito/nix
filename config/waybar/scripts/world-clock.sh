#!/usr/bin/env bash

TOKYO_DATE=$(TZ=Asia/Tokyo date '+%Y/%m/%d')
TOKYO_TIME=$(TZ=Asia/Tokyo date '+%H:%M')
TOKYO_WEEKDAY=$(LC_ALL=C TZ=Asia/Tokyo date '+%a')

printf '{"text":"%s %s %s","tooltip":"Tokyo: %s %s %s"}\n' \
    "$TOKYO_DATE" "$TOKYO_WEEKDAY" "$TOKYO_TIME" \
    "$TOKYO_DATE" "$TOKYO_WEEKDAY" "$TOKYO_TIME"

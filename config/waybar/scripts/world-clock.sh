
#!/usr/bin/env bash

TOKYO=$(TZ=Asia/Tokyo date '+%H:%M')

printf '{"text":"🇯🇵 %s","tooltip":"Tokyo: %s"}\n' \
    "$TOKYO" "$TOKYO"


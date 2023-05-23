#!/bin/bash

TOKEN="PUT_YOUR_TELEGRAM_TOKEN_HERE"
CHAT_ID="PUT_YOUR_CHAT_ID_HERE"

br=$(numfmt $bytes_received --to=iec --suffix=B --format %.2f --round=nearest)
bs=$(numfmt $bytes_sent --to=iec --suffix=B --format %.2f --round=nearest)

function displaytime {
  local T=$time_duration
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  [[ $D > 0 ]] && printf '%d days ' $D
  [[ $H > 0 ]] && printf '%d hours ' $H
  [[ $M > 0 ]] && printf '%d minutes ' $M
  [[ $D > 0 || $H > 0 || $M > 0 ]] && printf 'and '
  printf '%d seconds\n' $S
}

if [ $trusted_ip = $untrusted_ip ]; then
        client_ip="*Remote IP*: \`$trusted_ip\`"
        else
        client_ip="*Remote Trusted IP*: \`$trusted_ip\`, *Remote UnTrusted IP*: \`$untrusted_ip\`"
fi

t=$(displaytime)

case $common_name in

  DDKEDR)
    cn_icon=$'\U1F345' #tomato
    ;;

  JANE)
    cn_icon=$'\U1F346' #eggplant
    ;;

  NEST)
    cn_icon=$'\U1F383' #pumpkin
    ;;

  TINA)
    cn_icon=$'\U1F952' #cucumber
    ;;

  VAP)
    cn_icon=$'\U1F955' #carrot
    ;;

  DBD)
    cn_icon=$'\U1F954' #bell pepper
    ;;

  *)
    cn_icon=$'\U1F977'
    ;;
esac


stop=$'\U1F6A8 \U1F345 \U1F346 \U1F383 \U1F952 \U1F955 \U1F977'
up=$'\U1F7E2'
down=$'\U1F534'

message_up="$up *$common_name* $cn_icon
*Connected* to: *$HOSTNAME* at $time_ascii
$client_ip (${IV_PLAT^^})
*Virtual*: \`$ifconfig_pool_remote_ip\`"

message_down="$down *$common_name* $cn_icon
*Disconnected* from: *$HOSTNAME*
$client_ip
*Virtual*: \`$ifconfig_pool_remote_ip\`
*Received*: $br, *Sent*: $bs
*Session Duration*: $t
$signal_string"

#Telegram

if [ "$script_type" == "client-connect" ]; then
curl -s \
                        --form-string parse_mode="Markdown" \
                        --form-string chat_id="$CHAT_ID" \
                        --form-string text="$message_up" \
                        https://api.telegram.org/bot$TOKEN/sendMEssage

else
curl -s \
                        --form-string parse_mode="Markdown" \
                        --form-string chat_id="$CHAT_ID" \
                        --form-string text="$message_down" \
                        https://api.telegram.org/bot$TOKEN/sendMEssage
fi

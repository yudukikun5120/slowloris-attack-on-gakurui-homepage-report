# slowloris-attack-on-gakurui-homepage-report

## はじめに

本レポジトリは、国立大学法人筑波大学の各学類のホームページに対し試験的に実施した Slowloris DDoS 攻撃を結果をまとめたものです。

> [!WARNING]
> 本レポジトリは学類ホームページの脆弱性を調査することを目的としており、いかなる DDoS 攻撃も教唆するものではありません。

## 対象とする学類およびホスト

以下の学類のホームページを対象としています[^1]（CSV 形式での一覧は [gakurui_list.csv](./gakurui_list.csv)）。

[^1]: 2024年1月20日閲覧

| URL | 学類名 | 学群名 |
| -- | -- | --- |
| [https://scs.tsukuba.ac.jp/](https://scs.tsukuba.ac.jp/) | 総合学域群| (総合学域群)|
| [https://www.jinbun.tsukuba.ac.jp/](https://www.jinbun.tsukuba.ac.jp/) | 人文学類| 人文・文化学群|
| [http://www.hibun.tsukuba.ac.jp/](http://www.hibun.tsukuba.ac.jp/) | 比較文化学類| 人文・文化学群|
| [http://www.japanese.tsukuba.ac.jp/](http://www.japanese.tsukuba.ac.jp/) | 日本語・日本文化学類| 人文・文化学群|
| [https://shakai.tsukuba.ac.jp/](https://shakai.tsukuba.ac.jp/) | 社会学類| 社会・国際学群    |
| [https://www.kokusai.tsukuba.ac.jp/](https://www.kokusai.tsukuba.ac.jp/) | 国際総合学類| 社会・国際学群|
| [https://www.education.tsukuba.ac.jp/](https://www.education.tsukuba.ac.jp/) | 教育学類| 人間学群|
| [https://www.human.tsukuba.ac.jp/psyche/college/](https://www.human.tsukuba.ac.jp/psyche/college/) | 心理学類| 人間学群|
| [https://www2.human.tsukuba.ac.jp/ids/shougai](https://www2.human.tsukuba.ac.jp/ids/shougai) | 障害科学類| 人間学群|
| [https://cbs.biol.tsukuba.ac.jp/](https://cbs.biol.tsukuba.ac.jp/) | 生物学類| 生命環境学群|
| [https://www.bres.tsukuba.ac.jp/](https://www.bres.tsukuba.ac.jp/) | 生物資源学類| 生命環境学群|
| [https://www.earth.tsukuba.ac.jp/](https://www.earth.tsukuba.ac.jp/) | 地球学類| 生命環境学群|
| [https://nc.math.tsukuba.ac.jp/](https://nc.math.tsukuba.ac.jp/) | 数学類| 理工学群|
| [https://www.butsuri.tsukuba.ac.jp/](https://www.butsuri.tsukuba.ac.jp/) | 物理学類| 理工学群|
| [https://chemistry.tsukuba.ac.jp/](https://chemistry.tsukuba.ac.jp/) | 化学類| 理工学群|
| [https://www.oyoriko.tsukuba.ac.jp/](https://www.oyoriko.tsukuba.ac.jp/) | 応用理工学類| 理工学群|
| [https://www.esys.tsukuba.ac.jp/](https://www.esys.tsukuba.ac.jp/) | 工学システム学類| 理工学群|
| [https://www.sk.tsukuba.ac.jp/College/index_oc.html](https://www.sk.tsukuba.ac.jp/College/index_oc.html) | 社会工学類| 理工学群|
| [https://www.ide.tsukuba.ac.jp/](https://www.ide.tsukuba.ac.jp/) | 総合理工学位プログラム| 理工学群|
| [https://www.coins.tsukuba.ac.jp/](https://www.coins.tsukuba.ac.jp/) | 情報科学類| 情報学類|
| [https://www.mast.tsukuba.ac.jp/](https://www.mast.tsukuba.ac.jp/) | 情報メディア創成学類| 情報学類|
| [https://klis.tsukuba.ac.jp/](https://klis.tsukuba.ac.jp/) | 知識情報・図書館学類| 情報学類|
| [https://igaku.md.tsukuba.ac.jp/](https://igaku.md.tsukuba.ac.jp/) | 医学類| 医学群|
| [https://www.md.tsukuba.ac.jp/nurse/](https://www.md.tsukuba.ac.jp/nurse/) | 看護学類| 医学群|
| [https://www.md.tsukuba.ac.jp/med-sciences/](https://www.md.tsukuba.ac.jp/med-sciences/) | 医療科学類| 医学群|


## Slowloris DDoS 攻撃の実施

Gokberk Yaltirakli 氏によって開発された pip パッケージ [Slowloris](https://pypi.org/project/Slowloris/) を用いて、Slowloris DDoS 攻撃を実施しました。

### オプション

本攻撃で指定した Slowloris のオプションは以下の通りです。

| オプション | 説明 |
| -- | -- |
| `--port=443` または `--port=80` | 攻撃対象のポート番号 |
| `--sleeptime=0` | 攻撃対象への接続を維持するためのスリープ時間（秒） |
| `--sockets="$sockets_num"` | 攻撃対象へのソケット接続数 |
| `--https` | 攻撃対象の URL が HTTPS であることを指定 (対象ホームページがSSL対応していない場合は本オプションを省略) |
| `"$host"` | 攻撃対象の URL |

### 実行手順

シェルスクリプト [slowloris_attack.sh](./slowloris_attack.sh) を実行し、Slowloris DDoS 攻撃を実施しました。
このスクリプトは、CSVファイル [gakurui_list.csv](./gakurui_list.csv) から学類ウェブサイトのURLを読み取り、curlとslowlorisツールを使用して攻撃を実施し、その結果をファイルに書き込むものです。以下はスクリプトの主な構造と機能の説明です。

1. **オプション解析:**
   - スクリプトは `-s` オプションで`sockets_num`（slowlorisのソケットの数）を受け入れます。

2. **入力ファイルと出力ファイルの設定:**
   - `input_file` には学類やURLが含まれたCSVファイル（`gakurui_list.csv`）が指定されています。
   - `output_file` には攻撃結果が書き込まれる出力ファイルの名前が指定されています。オプションで指定されたソケット数を含むファイル名になります。

3. **ヘッダーの書き込み:**
   - 出力ファイルに学類名、攻撃前のcurlの終了ステータス、攻撃後のcurlの終了ステータスのヘッダー行を書き込みます。

4. **curlによる攻撃前の状態確認:**
   - `curl --max-time 5 "$url" > /dev/null` で指定されたURLへのcurlリクエストを最大5秒間実行し、終了ステータスを取得します。

5. **slowloris攻撃の開始:**
   - slowloris攻撃を実行します。`slowloris`コマンドはWebサーバーに対する持続的な接続を確立し、サーバーのリソースを枯渇させます。
   - `slowloris`コマンドがhttpsまたはhttpに応じて起動されます。攻撃はバックグラウンドで実行されます。

6. **攻撃が安定するまで待機:**
   - 30秒間待機して攻撃が安定するのを待ちます。

7. **攻撃後の状態確認:**
   - 再度 `curl --max-time 5 "$url" > /dev/null` を実行し、攻撃後の終了ステータスを取得します。終了ステータスが 28 (接続時間切れエラー) の場合、攻撃が成功していると判断します。

8. **slowlorisの停止:**
   - `pkill -f slowloris` でslowlorisプロセスを停止します。

9. **結果のファイルへの書き込み:**
    - 攻撃前の終了ステータス、攻撃後の終了ステータス、学類名を出力ファイルに追記します。

実質的な攻撃時間は、各ホストにつき30秒間となります。

## 攻撃結果

ソケット数を10000に設定して攻撃を実施した結果、以下の学類のホームページに対して攻撃が成功しました。
前節のスクリプトを実行し出力されたファイル [slowloris_attack_result_10000.csv](./slowloris_attack_result_10000.csv) には、攻撃前のcurlの終了ステータス、攻撃後のcurlの終了ステータス、学類名が記録されています。

| URL | 学類名 | 学群名 |
| -- | -- | --- |
| [https://scs.tsukuba.ac.jp/](https://scs.tsukuba.ac.jp/) | 総合学域群| (総合学域群)|
| [https://www.jinbun.tsukuba.ac.jp/](https://www.jinbun.tsukuba.ac.jp/) | 人文学類| 人文・文化学群|
| [https://shakai.tsukuba.ac.jp/](https://shakai.tsukuba.ac.jp/) | 社会学類| 社会・国際学群    |
| [https://www.education.tsukuba.ac.jp/](https://www.education.tsukuba.ac.jp/) | 教育学類| 人間学群|
| [https://www2.human.tsukuba.ac.jp/ids/shougai](https://www2.human.tsukuba.ac.jp/ids/shougai) | 障害科学類| 人間学群|
| [https://www.oyoriko.tsukuba.ac.jp/](https://www.oyoriko.tsukuba.ac.jp/) | 応用理工学類| 理工学群|
| [https://www.coins.tsukuba.ac.jp/](https://www.coins.tsukuba.ac.jp/) | 情報科学類| 情報学類|
| [https://www.mast.tsukuba.ac.jp/](https://www.mast.tsukuba.ac.jp/) | 情報メディア創成学類| 情報学類|
| [https://klis.tsukuba.ac.jp/](https://klis.tsukuba.ac.jp/) | 知識情報・図書館学類| 情報学類|
| [https://igaku.md.tsukuba.ac.jp/](https://igaku.md.tsukuba.ac.jp/) | 医学類| 医学群|

## おわりに

攻撃が成功した学類のホームページの特徴等は、今後の調査課題としたいと思います。

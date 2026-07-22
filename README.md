# TeamA

# Room Portal

研究室の入退室、滞在時間、音楽、思い出をひとつの 3D 空間にまとめるポータルアプリです。IC カードをかざすだけで入退室を記録し、研究室メンバーの滞在状況を可視化します。さらに、Spotify と連携してメンバーのお気に入り曲を登録し、滞在時間に応じたルーレットで選ばれた人の曲を Alexa / Spotify Connect 対応デバイスで再生できます。

## 背景

研究室では「誰が今いるのか」「どれくらい滞在しているのか」「休憩時間に何を流すか」といった小さな情報が散らばりがちです。Room Portal は、入退室ログをただ保存するだけではなく、研究室の空間そのものをインターフェースにして、日々の活動やコミュニケーションが自然に見える状態を目指しました。

## 主な機能

- **Auth0 ログイン**
  - メンバーごとにログインし、プロフィールと IC カード IDm を登録できます。
- **IC カード入退室管理**
  - PaSoRi RC-S300 で FeliCa カードを読み取り、Rails API に送信します。
  - 同じカードのスキャンから入室・退室を自動判定します。
- **滞在時間ダッシュボード**
  - 今日・今週・今月の滞在時間を集計します。
  - メンバー別のグラフ、在室中メンバー、カレンダー形式の滞在履歴を確認できます。
- **3D 研究室ポータル**
  - 研究室の 3D モデルを背景に、各機能へアクセスできます。
  - 写真や再生中の曲など、研究室の状態を視覚的に表示します。
- **Spotify 楽曲検索・お気に入り登録**
  - Spotify API で曲を検索し、自分のお気に入り曲として保存できます。
  - 登録曲はポータル上から再生・削除できます。
- **滞在時間ルーレット選曲**
  - IC カード登録済みメンバーを対象に、今週の滞在時間を重みとしてルーレット抽選します。
  - 選ばれたメンバーのお気に入り曲を Spotify Connect デバイスに再生します。
  - 直近 3 回同じ人が選ばれた場合は一時的に除外し、偏りを抑えます。
- **写真共有**
  - 研究室の写真をアップロードし、カテゴリ付きで一覧表示できます。
 

## デモで見てほしいポイント

1. IC カードをかざすと、入退室ログが記録されて滞在時間ダッシュボードに反映されます。＊名前は伏せております
<img width="600"  alt="Image" src="https://github.com/user-attachments/assets/f5b02eab-4da3-4be7-a695-984c88d949eb" />

2. Spotify でお気に入り曲を登録し、ルーレット抽選から実際に曲を再生できます。
3. 「研究室に来る」「滞在する」「音楽が流れる」という実際の行動が、ひとつの体験としてつながっています。

## システム構成

```text
PaSoRi RC-S300 / Raspberry Pi
  -> /api/v1/scan
  -> Rails Backend
  -> PostgreSQL / Redis
  -> 3D Portal UI
  -> Spotify Web API
  -> Alexa / Spotify Connect device
```

## 技術スタック

- Ruby 3.2.11
- Ruby on Rails 7
- PostgreSQL
- Redis / Action Cable
- Tailwind CSS / daisyUI
- Three.js
- Auth0 / OmniAuth
- Spotify Web API
- PaSoRi RC-S300 / FeliCa
- Docker Compose


# アーキテクチャ
<img width="1024" height="768" alt="Image" src="https://github.com/user-attachments/assets/4c3b4b4f-2d6a-4696-a427-046db897485a" />

# pasori パソコン接続時コマンド
```bash
$env:ROOM_PORTAL_SCAN_URL="https://p01--isdl--9ww4ft9snnpn.code.run/api/v1/scan"
$env:API_KEY="　　"
py scripts\pasori_rcs300_reader.py
```

# 開発環境セットアップ

## 前提条件

- Docker Desktop をインストール済み
- Git をインストール済み

## セットアップ手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/ISDL-hackathon/2026-teamA.git
cd 2026-teamA
```

### 2. 環境変数ファイルをコピー

```bash
cp .env.example .env
cp local-client/.env.example local-client/.env

```

`.env` を編集して、各変数を設定：

```bash
# macOS / Linux
vim .env

# Windows (PowerShell)
notepad .env

# または任意のエディタで開く
code .env
```

### 3.entrypoint.shファイルの右下の`CRLF`を`LF`に変更されているか確認

<img width="137" height="56" alt="Image" src="https://github.com/user-attachments/assets/840b786c-af36-48aa-bff5-2f6ca670b513" />

### 4. Docker で起動

```bash
docker-compose up --build
```

### 5. ブラウザでアクセス

```
http://localhost:3000
http://127.0.0.1:3000/
```

## よく使うコマンド

```bash
# コンテナ起動
docker-compose up -d

# コンテナ停止
docker-compose down

# ログ確認
docker-compose logs -f web

# Rails コンソール
docker-compose exec web bundle exec rails console

# マイグレーション実行
docker-compose exec web bundle exec rails db:migrate
```
# github 使用方法

### Issues 作成
'new issue'でタスクごとにissueを作成</br>
<img width="500" alt="Image" src="https://github.com/user-attachments/assets/8d1d61ca-20b3-4376-b906-c572b96ebcbe" />

### ブランチ切る
issueの画面でブランチを切るボタンを押す．
'create branch'のボタンを押すとその指示に従ってブランチ切る
<img width="403" height="135" alt="Image" src="https://github.com/user-attachments/assets/8d6c4434-f860-4244-897a-bbc264a82097" />

```bash
git checkout ＜ブランチ名＞
```

###  今自分がどのブランチにいるか
```bash
git branch
```
### ファイル変更完了後コミット
vscodeの左上のcommitボタンでコミット

### プッシュ
```bash
git push
```

### プルリク出す
githubのページの上のpull request タブに行き緑のボタンおす
※mergeはレビューしてもらってするので，自分ではしない





## トラブルシューティング

**ポート 3000 が既に使用されている場合:**

```bash
docker-compose down
lsof -ti:3000 | xargs kill -9
docker-compose up
```

**データベースエラーが発生した場合:**

```bash
docker-compose down -v
docker-compose up --build
```
## メモ
```bash
py scripts\pasori_rcs300_reader.py
```

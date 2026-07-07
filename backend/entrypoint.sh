#!/bin/bash
set -e

# データベース準備完了を待機
until PGPASSWORD=$DATABASE_PASSWORD psql -h "$DATABASE_HOST" -U "$DATABASE_USER" -d "$DATABASE_NAME" -c '\q'; do
  echo 'Waiting for postgres...'
  sleep 1
done

echo 'PostgreSQL started'

# マイグレーション実行
bundle exec rails db:create --quiet 2>/dev/null || true
bundle exec rails db:migrate --quiet

# コンテナをデタッチモードで実行する場合の処理
exec "$@"

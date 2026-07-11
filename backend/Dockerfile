FROM ruby:3.2-slim

WORKDIR /app

# 必要なシステムライブラリをインストール
RUN apt-get update && apt-get install -y \
  build-essential \
  postgresql-client \
  libpq-dev \
  git \
  bash \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

# Gemfile をコピーして依存パッケージをインストール
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.4.0 && bundle install --jobs 4 --retry 5

# Node依存パッケージをインストール
COPY package.json package-lock.json ./
RUN npm ci

# アプリケーションコードをコピー
COPY . .

# entrypoint.sh にアクセス権を付与
RUN chmod +x /app/entrypoint.sh

# ポート 3000 を公開
EXPOSE 3000

# エントリーポイント
ENTRYPOINT ["/bin/bash", "/app/entrypoint.sh"]

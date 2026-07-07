FROM ruby:3.2-slim

WORKDIR /app

# 必要なシステムライブラリをインストール
RUN apt-get update && apt-get install -y \
  build-essential \
  postgresql-client \
  git \
  && rm -rf /var/lib/apt/lists/*

# Gemfile をコピーして依存パッケージをインストール
COPY Gemfile Gemfile.lock* ./
RUN gem install bundler && bundle install --jobs 4 --retry 3

# アプリケーションコードをコピー
COPY . .

# entrypoint.sh にアクセス権を付与
RUN chmod +x /app/entrypoint.sh

# ポート 3000 を公開
EXPOSE 3000

# エントリーポイント
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# 1. Stage: builder
FROM node:20-alpine AS builder

WORKDIR /app

# Установим pnpm
RUN npm install -g pnpm

# Копируем package.json и lock-файл
COPY package.json pnpm-lock.yaml ./

# Устанавливаем зависимости
RUN pnpm install

# Копируем весь проект
COPY . .

# Устанавливаем лимит памяти для сборки (на слабых серверах)
ENV NODE_OPTIONS="--max-old-space-size=2048"

# Собираем проект
RUN pnpm build

# 2. Stage: production
FROM nginx:alpine

# Копируем сгенерированный сайт из builder stage
COPY --from=builder /app/.output/public /usr/share/nginx/html

# Копируем конфиг Nginx, если нужно (опционально)
# COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

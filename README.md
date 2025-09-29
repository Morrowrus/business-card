# Business Card Template

Автоматическое развертывание современной визитки с интегрированным календарем.

## Требования

- Docker и docker-compose
- Git
- Домен с настроенными DNS записями

## Быстрый старт

```bash
curl -O https://raw.githubusercontent.com/Morrowrus/business-card/main/deploy.sh
chmod +x deploy.sh
./deploy.sh
```

## Что включено

- Главная страница с информацией о вас
- Страница контактов с vCard и QR-кодом
- Страница календаря с Cal.com интеграцией
- Автоматический HTTPS через Caddy

## Структура

```
/opt/web-yourdomain/
├── docker-compose.yml
├── Caddyfile
└── site/
    ├── index.html
    ├── photo.jpg
    ├── contacts/
    │   └── index.html
    └── calendar/
        └── index.html
```

## После развертывания

1. Зарегистрируйтесь на cal.com
2. Подключите Google календари
3. Добавьте фото и favicon
4. Запустите: `docker compose up -d`

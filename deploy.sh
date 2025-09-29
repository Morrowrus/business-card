#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_URL="https://github.com/Morrowrus/business-card.git"

echo -e "${BLUE}=== Генератор визитки с календарем ===${NC}\n"

# Проверка зависимостей
command -v git >/dev/null 2>&1 || { echo -e "${RED}Требуется git${NC}"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Требуется docker${NC}"; exit 1; }

# Запрос данных
read -p "Домен (например, ivanov.xyz): " DOMAIN
read -p "Полное имя: " FULL_NAME
read -p "Должность: " JOB_TITLE
read -p "Компания: " COMPANY
read -p "Телефон (+7...): " PHONE
PHONE_CLEAN=$(echo "$PHONE" | tr -d ' ()-')
read -p "Telegram (без @): " TELEGRAM
read -p "Личная почта: " EMAIL_PERSONAL
read -p "Рабочая почта: " EMAIL_WORK
read -p "LinkedIn username: " LINKEDIN
read -p "Instagram username: " INSTAGRAM
read -p "VK username: " VK
read -p "Cal.com username: " CALCOM_USER
read -p "Краткое описание: " BIO
read -p "Путь к фото: " PHOTO_PATH

# Формирование переменных
FIRST_LAST=$(echo "$FULL_NAME" | tr ' ' '_')
DEPLOY_PATH="/opt/web-${DOMAIN%%.*}"
SITE_PATH="${DEPLOY_PATH}/site"

echo -e "\n${BLUE}Клонирование шаблонов...${NC}"
TMP_DIR=$(mktemp -d)
git clone "$REPO_URL" "$TMP_DIR"

echo -e "${BLUE}Создание структуры...${NC}"
mkdir -p "$DEPLOY_PATH"
cp -r "$TMP_DIR/site" "$SITE_PATH"
cp "$TMP_DIR/docker-compose.yml" "$DEPLOY_PATH/"
cp "$TMP_DIR/Caddyfile.template" "$DEPLOY_PATH/Caddyfile"

# Замена переменных
find "$SITE_PATH" -type f -name "*.html" -exec sed -i \
  -e "s|{{FULL_NAME}}|$FULL_NAME|g" \
  -e "s|{{JOB_TITLE}}|$JOB_TITLE|g" \
  -e "s|{{COMPANY}}|$COMPANY|g" \
  -e "s|{{PHONE}}|$PHONE|g" \
  -e "s|{{PHONE_CLEAN}}|$PHONE_CLEAN|g" \
  -e "s|{{TELEGRAM}}|$TELEGRAM|g" \
  -e "s|{{EMAIL_PERSONAL}}|$EMAIL_PERSONAL|g" \
  -e "s|{{EMAIL_WORK}}|$EMAIL_WORK|g" \
  -e "s|{{LINKEDIN}}|$LINKEDIN|g" \
  -e "s|{{INSTAGRAM}}|$INSTAGRAM|g" \
  -e "s|{{VK}}|$VK|g" \
  -e "s|{{CALCOM_USER}}|$CALCOM_USER|g" \
  -e "s|{{BIO}}|$BIO|g" \
  -e "s|{{DOMAIN}}|$DOMAIN|g" \
  -e "s|{{FIRST_LAST}}|$FIRST_LAST|g" \
  {} \;

sed -i "s|{{DOMAIN}}|$DOMAIN|g" "$DEPLOY_PATH/Caddyfile"

# Копирование фото
if [ -f "$PHOTO_PATH" ]; then
  cp "$PHOTO_PATH" "$SITE_PATH/photo.jpg"
  echo -e "${GREEN}✓ Фото скопировано${NC}"
else
  echo -e "${YELLOW}⚠ Фото не найдено, добавьте вручную в $SITE_PATH/photo.jpg${NC}"
fi

# Очистка
rm -rf "$TMP_DIR"

echo -e "\n${GREEN}✓ Визитка создана в: $DEPLOY_PATH${NC}"
echo -e "\n${YELLOW}=== Следующие шаги ===${NC}"
echo "1. Зарегистрируйтесь на cal.com/$CALCOM_USER"
echo "2. Подключите Google календари в Cal.com"
echo "3. Добавьте favicon.ico в $SITE_PATH/"
echo "4. Запустите: cd $DEPLOY_PATH && docker-compose up -d"
echo "5. Настройте DNS: $DOMAIN -> IP сервера"

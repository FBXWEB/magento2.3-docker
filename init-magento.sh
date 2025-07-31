#!/bin/bash
set -e

echo ":: ******** INICIANDO O INSTALADOR MAGENTO v.$MAGENTO_VERSION COM SAMPLE DATA ********* ::"

# Carrega variáveis do .env
set -o allexport
source .env
set +o allexport

echo ""
echo ":: Iniciando o processo de limpeza de versões antigas..."

MAX_TRIES=10
TRIES=0

until docker exec magento-mysql mysqladmin ping -h"127.0.0.1" --silent; do
  TRIES=$((TRIES+1))
  echo "   Tentativa $TRIES de $MAX_TRIES..."
  if [ "$TRIES" -ge "$MAX_TRIES" ]; then
    echo "❌ MySQL não respondeu após $MAX_TRIES tentativas. Abortando instalação."
    exit 1
  fi
  sleep 2
done

echo ":: ✅ MySQL está pronto para conexões, a instalação será inicializada com força total!!!"
echo ""
echo ""

echo ":: STEP 01 :: Limpando banco de dados existente..."
docker exec -i "$CONTAINER_MYSQL" mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "DROP DATABASE IF EXISTS $MYSQL_DATABASE; CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
echo ""
echo ":: STEP 02 :: Clonando Magento $MAGENTO_VERSION do GitHub..."
docker exec -i "$CONTAINER_PHP" bash <<EOF
cd /var/www/html
GIT_REPO="$GIT_REPO"
GIT_BRANCH="$MAGENTO_VERSION"
MAX_ATTEMPTS="$MAX_ATTEMPTS"
CLONE_SUCCESS=0

for attempt in \$(seq 1 \$MAX_ATTEMPTS); do
  echo "Tentando clonar Magento (tentativa \$attempt)..."
  if git clone --depth=1 --branch "\$GIT_BRANCH" "\$GIT_REPO" .; then
    CLONE_SUCCESS=1
    break
  else
    echo "❌ Falha na tentativa \$attempt. Aguardando 5 segundos..."
    sleep 5
  fi
done

if [ "\$CLONE_SUCCESS" -ne 1 ]; then
  echo "🚨 Erro: Não foi possível clonar o Magento após \$MAX_ATTEMPTS tentativas."
  exit 1
fi
EOF
echo ""
echo ":: STEP 03 :: Substituindo composer.magento.json na raiz do projeto..."
cp -f composer-magento.json ./magento/composer.json
cp -f composer-lock-magento.json ./magento/composer.lock
echo ""
echo ":: STEP 04 :: Clonando Sample Data..."
docker exec -i "$CONTAINER_PHP" bash <<EOF
cd /var/www/html
git clone "$SAMPLE_REPO" "$TMP_DIR"

cp -R "$TMP_DIR/app/* app/ 2>/dev/null || true
cp -R "$TMP_DIR/dev/* dev/ 2>/dev/null || true
cp -R "$TMP_DIR/pub/media/"* pub/media/ 2>/dev/null || true
cp -R "$TMP_DIR/pub/static/"* pub/static/ 2>/dev/null || true
EOF
echo ""
echo ":: STEP 05 :: Instalando dependências Composer..."
docker exec -it "$CONTAINER_PHP" bash -c "
  cd /var/www/html &&
  export COMPOSER_MEMORY_LIMIT=-1 &&
  composer install --prefer-dist --dev
"
echo ""
echo ":: STEP 06 :: Instalando Magento via CLI com Sample Data..."
docker exec -it "$CONTAINER_PHP" bash -c "
  cd /var/www/html &&
  bin/magento setup:install \
    --base-url=$MAGENTO_URL \
    --db-host=$DB_HOST \
    --db-name=$MYSQL_DATABASE \
    --db-user=$MYSQL_USER \
    --db-password=$MYSQL_PASSWORD \
    --admin-firstname=$ADMIN_FIRSTNAME \
    --admin-lastname=$ADMIN_LASTNAME \
    --admin-email=$ADMIN_EMAIL \
    --admin-user=$ADMIN_USER \
    --admin-password=$ADMIN_PASS \
    --backend-frontname=$MAGENTO_BACKEND \
    --language=pt_BR \
    --currency=BRL \
    --timezone=America/Sao_Paulo \
    --use-rewrites=1 \
    --use-sample-data \
    --cleanup-database
"
echo ""
echo ":: STEP 07 :: Setup Magento executando pós-instalação... (DEVELOPER MODE ENABLED)"
docker exec -it "$CONTAINER_PHP" bash -c "
  cd /var/www/html &&
  php bin/magento deploy:mode:set developer  &&
  php bin/magento config:set dev/static/sign 0 &&
  php bin/magento setup:upgrade &&
  php bin/magento indexer:reindex &&
  php bin/magento setup:di:compile &&
  php bin/magento setup:static-content:deploy -f pt_BR en_US
"
echo ""
echo ":: STEP 08 :: Corrigindo permissões finais..."
docker exec -it "$CONTAINER_PHP" bash -c "
  cd /var/www/html &&
  chown -R $MAGENTO_UID:$MAGENTO_GID . &&
  find var generated pub/static pub/media app/etc -type f -exec chmod 664 {} \; &&
  find var generated pub/static pub/media app/etc -type d -exec chmod 775 {} \; &&
  chmod u+x bin/magento
"
echo ""
echo ":: SETEP 09 ::Deploy final do conteúdo Estático"
docker exec -it "$CONTAINER_PHP" bash -c "
cd /var/www/html &&
rm -rf pub/static/* var/view_preprocessed/* &&
php bin/magento setup:static-content:deploy -f pt_BR en_US &&
php bin/magento indexer:reindex &&
php bin/magento catalog:images:resize &&
php bin/magento cache:clean && php bin/magento cache:flush
"
echo ""
echo ":: SETEP 10 ::Removendo versionamento padrão (GitHub do Magento2)"
docker exec -it "$CONTAINER_PHP" bash -c "
cd /var/www/html &&
rm -rf .git && 
rm -rf sample-data
"
echo ""
echo ":::::: ✅ INSTALAÇÃO COMPLETA DO MAGENTO FINALIZADA COM SUCESSO! ::::::"
echo ":::::: Acesse sua loja, abra o navegador com $MAGENTO_URL :::::::::::::::::::"



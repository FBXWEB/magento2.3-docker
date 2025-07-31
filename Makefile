# Cria diretório da aplicação Magento
create:
	@if [ ! -d "./magento" ]; then mkdir ./magento; fi

# Sobe todos os containers
start:
	docker-compose up -d

# Derruba os containers
stop:
	docker-compose down

# Faz build forçado dos containers
build:
	docker-compose build --no-cache

# Executa o script de instalação (com Magento + Sample Data via CLI)
install:
	bash init-magento.sh

# Remove totalmente os dados
destroy:
	@echo "ATENÇÃO! Estamos removendo a pasta ./magento e parando os containers..."
	@if [ -d "./magento" ]; then rm -rf ./magento; fi
	make stop

# Acessa container PHP como usuário padrão (fbxweb)
login:
	docker exec -it magento-php bash

# Acessa container PHP como root
root:
	docker exec -it -u root magento-php bash

# Logs de todos os serviços
logs:
	docker-compose logs -f

# Status dos containers
ps:
	docker-compose ps

# Cria uma nova instância 
createMagento:
	make create
	make build
	make start
	make install

# Remove toda a instância do Magento
# (atenção, apaga todos os arquivos da pasta magento e a base de dados)
removeMagento:
	make destroy


# Instalação limpa (destroy + create + start + install)
resetMagento:
	- make destroy || true
	make create
	make build
	make start
	make install

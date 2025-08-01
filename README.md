<p align="center">
  <img src="https://user-images.githubusercontent.com/1086448/44016593-30e04b72-9ef3-11e8-9741-23f3b4e87ee0.png" height="100" alt="Magento Logo">
  <img src="https://www.docker.com/wp-content/uploads/2022/03/Moby-logo.png" height="100" alt="Docker Logo">
</p>

<h1 align="center">Magento + Docker</h1>

<p align="center">
  <strong>Ambiente completo para desenvolvimento Magento 2.3.5-p2 com Sample Data, totalmente automatizado via Docker.</strong>
</p>

<p align="center">
  <code>magento 2.3.x</code> |
  <code>SampleData</code> |
  <code>Docker</code> |
  <code>Php</code> |
  <code>ElasticSearch</code> |
  <code>Nginx</code> |
  <code>Café</code> ☕ |
  <code>MetalCore</code> 🤘
</p>

---

## O que é essa stack?

Este repositório entrega uma **stack Docker profissional e automatizada para o Magento 2.3.5-p2**, incluindo:

- Instalação automática do Magento via CLI
- Deploy completo do Sample Data (dados de exemplo)
- Suporte a UID/GID personalizados para evitar problemas de permissão no host
- Configuração otimizada para PHP 7.3, MySQL 5.7, Elasticsearch 6.8, Redis, Mailhog e Nginx
- Scripts prontos para build, deploy, acesso ao terminal, destruição e reinstalação do projeto
- Permite desenvolvimento via VSCode sem dores de cabeça

Ideal para desenvolvedores que desejam subir um ambiente **funcional, rápido e confiável** para trabalhar com Magento 2.3.x sem complicações.

---

## Serviços da Stack

| Serviço                | Descrição                              |
|------------------------|----------------------------------------|
| **PHP-FPM 7.3**         | Ambiente compatível com Magento 2.3.5 |
| **MySQL 5.7**           | Banco de dados                        |
| **Elasticsearch 6.8.23**| Search Engine oficial Magento         |
| **Redis**               | Cache para sessão e página            |
| **Mailhog**             | SMTP fake para testes de e-mail       |
| **Nginx**               | Servidor Web frontend/backend         |

---

## Como instalar

### 1. Clone o repositório

```bash
git clone https://github.com/seu-usuario/magento2-docker-stack.git
cd magento2-docker-stack
```

### 2. Configure seu `.env`

Crie o arquivo `.env` com base no exemplo:  
OBS: Você precisará adicionar sua (Public Key e Private Key), você poderá criar ou resgatar as credenciais em:  
https://commercemarketplace.adobe.com/customer/accessKeys/

```bash
cp .env.example .env
```

Atenção, se você alterar as variáveis no .env:
- MAGENTO_UID=
- MAGENTO_GID=

Abra o arquivo ".docker/php/Dockerfile" e altere as seguintes variáveis com o mesmo user e grupo:
- ENV USER=
- ENV GROUP=

IMPORTANTE! Para maior controle, utilize aqui o mesmo user e group de seu ambiente para que você possa criar e editar arquivos sem erro de permissão;
Os arquivos "composer-lock-magento.json" e "composer-magento.json" estão preparados para serem copiados na construção dos containers, se você quiser alterar ou adicionar alguma coisa no magento antes da construção e instalação do Magento, altere esses arquivos; 

### 3. Inicie a stack

OBS: Para rodar o fluxo completo de instalação rode os comandos abaixo na pasta onde você clonou a stack.  
- Total de 10 passos que serão automaticamente realizados, no final você receberá o link de acesso da loja com sample data

```bash
make create && 
make build  && 
make start &&
make install
```

Esses comandos irão:

- Criar os diretórios necessários
- Buildar a stack
- Subir os containers
- Rodar o script `init-magento.sh`, que instala o Magento e os dados de exemplo

(AGUARDE O FINAL DO PROCESSO COMPLETO, ÀS VEZES PODE DEMORAR)

---

## Credenciais padrão 

| Item           | Valor                  |
|----------------|------------------------|
| URL Frontend   | http://localhost       |
| URL Admin      | http://localhost/admin |
| Usuário Admin  | `admin`                |
| Senha Admin    | `Admin123@`            |
| E-mail Admin   | `admin@fbxweb.com`     |

OBS: Você poderá alterar esses dados no arquivo .env

---

## Comandos úteis via `make`

| Comando        | Ação                                                        |
|----------------|-------------------------------------------------------------|
| `make start`   | Sobe os containers (`docker-compose up -d`)                |
| `make stop`    | Derruba os containers                                       |
| `make build`   | Rebuild forçado dos containers                              |
| `make install` | Executa o script de instalação do Magento com Sample Data  |
| `make destroy` | Remove completamente os dados                               |
| `make login`   | Acessa o container PHP como `www-data`                      |
| `make root`    | Acessa o container PHP como `root`                          |
| `make logs`    | Exibe os logs em tempo real                                 |
| `make ps`      | Lista status dos containers                                 |

---

## Requisitos

- Docker 20+
- Docker Compose 1.29+
- Unix/Linux/macOS (ou WSL 2 no Windows)
- VSCode recomendado com extensões: PHP Intelephense, Magento Snippets

---

## Dica para devs

O sistema já foi configurado com permissões corretas utilizando `UID/GID` do host no momento do build. Isso garante que os arquivos possam ser editados com seu usuário local sem conflitos.

---

## Por que usar essa stack?

- Elimina os erros comuns de instalação
- Setup rápido e funcional em minutos
- Atualizado com práticas de agências profissionais
- Foco em performance, clareza e consistência
- Pronto para desenvolvimento de temas e módulos Magento 2.3.x

---

## Contribuindo

Pull requests são bem-vindos! Se você tiver sugestões, melhorias ou ajustes para a stack, sinta-se à vontade para colaborar.

---

## Desenvolvido por

**FBXWEB AGENCY**  
_Soluções criativas e código de elite para sua loja Magento._  
_Website: https://www.fbxweb.com.br_  
_São Paulo/Brazil_

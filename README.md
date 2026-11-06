# Containerização e Deploy com Docker & AWS ECR

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![AWS](https://img.shields.io/badge/Amazon_AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Nginx](https://img.shields.io/badge/Nginx-009639?style=for-the-badge&logo=nginx&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)

> Projeto prático de containerização de um site estático com **Docker** e **Nginx Alpine**, publicação autenticada no **Amazon ECR** e execução em instância **EC2**.

---

## Visão Geral

O projeto resolve o problema de inconsistência de ambiente ("na minha máquina funciona") empacotando a aplicação em um container reproduzível, publicando a imagem em um registro privado na AWS e documentando o passo a passo para execução em qualquer EC2.

### Destaques técnicos
- **Nginx Alpine:** imagem base de ~25MB (medido com `docker image inspect` em disco não comprimido), frente a ~130MB da imagem Debian padrão
- **Autenticação tokenizada:** uso de `aws ecr get-login-password` que gera token temporário de 12h — sem senha em texto puro
- **Orquestração local:** `docker compose up -d` sobe o ambiente em um comando

---

## Arquitetura

```
Local (Build)  ──docker push──▶  Amazon ECR  ──docker pull──▶  Amazon EC2  ──:80──▶  Browser
```

**Fluxo completo:**
1. `docker build` — cria a imagem localmente
2. `aws ecr get-login-password` — autentica o Docker no ECR
3. `docker push` — envia a imagem para o registro privado
4. Na EC2: `docker pull` + `docker run` — executa o container

---

## Tecnologias

| Ferramenta | Finalidade |
|---|---|
| **Docker** | Containerização da aplicação |
| **Nginx Alpine** | Servidor web leve (~25MB) |
| **Amazon ECR** | Registro privado de imagens na AWS |
| **AWS CLI v2** | Autenticação e comandos AWS |
| **Amazon EC2** | Servidor de execução do container |

---

## Estrutura do Repositório

```
├── website/              # Site estático (HTML5, CSS3, JavaScript)
│   ├── css/
│   ├── js/
│   └── index.html
├── Dockerfile            # Imagem baseada em nginx:alpine
├── docker-compose.yml    # Execução local simplificada
├── .dockerignore         # Exclui node_modules, .git, etc. do contexto de build
├── .gitignore
└── README.md
```

---

## Como Executar Localmente

**Pré-requisitos:** Docker Desktop instalado e rodando.

```bash
# 1. Clonar o repositório
git clone https://github.com/CesarLana/projeto-devops-aws-docker.git
cd projeto-devops-aws-docker

# 2a. Executar com Docker
docker build -t meu-site:v1.0 .
docker run -d -p 8080:80 --name meu-site-app meu-site:v1.0
# Acesse: http://localhost:8080

# 2b. Ou com Docker Compose
docker compose up -d
```

---

## Publicar no Amazon ECR

**Pré-requisitos:** AWS CLI v2 configurado com credenciais (`aws configure`).

```bash
# 1. Autenticar o Docker no ECR
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <CONTA_AWS>.dkr.ecr.us-east-1.amazonaws.com

# 2. Criar o repositório (primeira vez)
aws ecr create-repository --repository-name meu-repositorio --region us-east-1

# 3. Tag e push
docker tag meu-site:v1.0 <CONTA_AWS>.dkr.ecr.us-east-1.amazonaws.com/meu-repositorio:v1.0
docker push <CONTA_AWS>.dkr.ecr.us-east-1.amazonaws.com/meu-repositorio:v1.0
```

---

## Executar na EC2

A instância EC2 precisa de:
- **IAM Role** com a policy `AmazonEC2ContainerRegistryReadOnly` associada
- **Security Group** com inbound TCP 80 aberto para o tráfego desejado
- Docker instalado (`sudo yum install docker -y && sudo service docker start`)

```bash
# Na EC2, após configurar o IAM Role e instalar o Docker:
aws ecr get-login-password --region us-east-1 \
  | docker login --username AWS --password-stdin <CONTA_AWS>.dkr.ecr.us-east-1.amazonaws.com

docker pull <CONTA_AWS>.dkr.ecr.us-east-1.amazonaws.com/meu-repositorio:v1.0
docker run -d -p 80:80 meu-repositorio:v1.0
```

---

## Próximos Passos

- [ ] Provisionar a EC2 com **Terraform** (IaC)
- [ ] Pipeline **CI/CD com GitHub Actions**: build → push ECR → deploy automático
- [ ] Certificado SSL/TLS com AWS Certificate Manager

---

## Autor

**Cesar Lana** — [GitHub](https://github.com/CesarLana) · [LinkedIn](https://www.linkedin.com/in/cesarlana/)

# PI_IV-Time-16

<br>

# StreamHub

Aplicativo mobile para explorar filmes e séries, consultar sua disponibilidade em serviços de streaming e organizar preferências de conteúdo.

<br>

## Sobre o projeto

Desenvolvido como projeto acadêmico de software, o StreamHub reúne recursos para ajudar o usuário a acompanhar e planejar seu consumo de streaming.

<br>

## Principais funcionalidades

- **Descoberta de conteúdo:** busca de filmes e séries, lançamentos, recomendações e detalhes
  
- **Disponibilidade:** consulta das plataformas que oferecem cada conteúdo
  
- **Conta de usuário:** cadastro, login e recuperação ou alteração de senha
  
- **Lista de desejos:** organização dos títulos que o usuário pretende assistir
  
- **Personalização:** seleção das plataformas assinadas e dos conteúdos atuais e desejados

<br>

## Planejamento de assinaturas

O planejador é uma parte importante da proposta do StreamHub. O usuário informa suas plataformas, conteúdos atuais e desejados, gasto mensal atual e orçamento pretendido. Com esses dados, o sistema avalia combinações de plataformas e monta uma projeção para oito meses.

Cada mês apresenta as plataformas recomendadas, a cobertura dos conteúdos e o custo estimado. O resultado também indica se o custo ultrapassa o orçamento informado.

<br>

## Arquitetura

O projeto é dividido em três partes principais:

- `frontend/` — aplicativo mobile em Flutter
- `backend/functions/` — Firebase Cloud Functions em TypeScript e Node.js
- `server/` — servidor TCP em Java para validações relacionadas às operações de conta

<br>

```text
PI_IV-Time-16/
├── frontend/
│   ├── lib/
│   │   ├── pages/          # Telas do aplicativo
│   │   ├── components/     # Widgets reutilizáveis
│   │   ├── models/         # Modelos usados pelo frontend
│   │   ├── repositories/   # Estado e acesso a dados
│   │   ├── services/       # Integrações com Firebase
│   │   └── theme/          # Tema visual
│   └── assets/             # Imagens e outros recursos
├── backend/
│   └── functions/
│       └── src/
│           ├── api/         # Consultas de conteúdo e plataformas
│           ├── auth/        # Operações de conta
│           ├── wishlist/    # Operações da lista de desejos
│           ├── subscription/ # Geração do planejamento de assinaturas
│           └── shared/      # Configurações e parsers compartilhados
├── server/
│   ├── src/                 # Servidor TCP e tratamento de conexões
│   ├── services/            # Validações de cadastro e autenticação
│   ├── components/          # Leitura e criação de JSON
│   ├── models/              # Códigos de resposta
│   ├── utils/               # Exceções do servidor
│   └── test/                # Testes unitários do servidor Java
├── docs/                    # Relatório e materiais do projeto
└── README.md
```

<br>

## Começando

Estas instruções preparam o ambiente local para executar o aplicativo Flutter, as Firebase Functions e o servidor Java



### Pré-requisitos

- **Git**
  
- **Flutter SDK** com uma versão do Dart compatível com `frontend/pubspec.yaml` (`^3.13.4`)
  
- **Node.js 22 (LTS)** ou superior
  
- **npm**
  
- **Firebase CLI**

- Conta no **Firebase** com o projeto configurado
  
- Cluster no **MongoDB** configurado
  
- **JDK 17**
  
- **Token** de acesso da API do **TMDB**

<br>

### Instalação e execução


### 1. Clone o repositório:

```bash
git clone https://github.com/GabrielHP2/PI_IV-Time-16.git
```

### 2. Instale as dependências:

A partir da raiz do projeto: 

Frontend:

```cmd
cd frontend
flutter pub get
```

Backend:

```cmd
cd backend
cd functions
npm install
```

#### 3. Configure os secrets do backend

Crie o arquivo `backend/functions/.secret.local` com os valores usados localmente:

```env
API_TOKEN=seu_token_de_acesso_do_tmdb
MONGODB_URI=sua_uri_de_conexao_do_mongodb
```

#### 4. Inicie o servidor Java

Em um terminal, a partir da raiz do projeto, inicie o servidor:

```cmd
cd server
cd src
java Server.java
```

O servidor escuta na porta `8080` por padrão. Mantenha esse terminal aberto enquanto executar as Functions que dependem dele

#### 5. Deploy das Firebase Functions

Se ainda não tiver o Firebase CLI instalado ou autenticado:

```cmd
npm install -g firebase-tools
firebase login
```

Em outro terminal, na raiz das functions `backend/functions`:

```cmd
npm run deploy
```


#### 6. Inicie os emuladores Firebase

Ainda na raiz das functions:

```cmd
npm run test
```

#### 7. Execute o aplicativo Flutter

Em outro terminal, na raiz do frontend `frontend/`:

```cmd
flutter run
```

<br>

## Stack utilizada no projeto

### Frontend

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

### Backend e API

![NodeJS](https://img.shields.io/badge/node.js-6DA55F?style=for-the-badge&logo=node.js&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase_Functions-FF6F00?style=for-the-badge&logo=firebase&logoColor=white)

### Servidor

![Java](https://img.shields.io/badge/Java-ED8B00?style=for-the-badge&logo=openjdk&logoColor=white)

### Banco de dados 

![MongoDB](https://img.shields.io/badge/-MongoDB-13aa52?style=for-the-badge&logo=mongodb&logoColor=white)

<br>

## Autores

| [<img src="https://github.com/GabrielHP2.png" width="115" alt="Gabriel Pagliato"><br>](https://github.com/GabrielHP2) | [<img src="https://github.com/Luuniii.png" width="115" alt="Luis Felipe Mita"><br>](https://github.com/Luuniii) | [<img src="https://github.com/BielBastos866.png" width="115" alt="Gabriel Bastos"><br>](https://github.com/BielBastos866) | [<img src="https://github.com/Febastos21.png" width="115" alt="Felipe Bastos"><br>](https://github.com/Febastos21) | [<img src="https://github.com/felipelirani.png" width="115" alt="Felipe Lirani"><br>](https://github.com/felipelirani) |
| :--------------: | :--------------: | :------------: | :-----------: | :-----------: |
| Gabriel Pagliato | Luis Felipe Mita | Gabriel Bastos | Felipe Bastos | Felipe Lirani |
# Dicionário de Dados: Projeto StreamHub — sistema de gerenciamento e planejamento de assinaturas de serviços de streaming

## 1. Histórico de versões (ou revisões)

| Data | Autor | Versão | Comentários |
| :---: | :---: | ---: | :--- |
| 22/11/2026 | Equipe do Projeto StreamHub | 1.0.0 | Revisão final da documentação das entidades Usuário, Plataforma e Conteúdo da Lista de Desejos, com desdobramento para MongoDB, exemplos de documentos e índices verificados no Atlas. |
| 22/11/2026 | Equipe do Projeto StreamHub | 1.0.0-alfa1 | Versão inicial do dicionário de dados, com a descrição conceitual das entidades Usuário, Plataforma e Conteúdo da Lista de Desejos e seu desdobramento para MongoDB. |

## 2. Entidades e atributos conceituais

A seguir são descritas as entidades que o projeto StreamHub contempla, seus atributos, tipos conceituais, características e comentários sobre cada atributo. O banco de dados documentado nesta versão contém as coleções `users`, `platforms` e `wishlists` no banco `streamhub`.

Nesta seção, os dados são descritos em nível conceitual. O desdobramento para documentos e coleções MongoDB é apresentado na seção 4.

### 2.1. Usuário

Usuário representa uma pessoa que utiliza o StreamHub para consultar conteúdos, organizar plataformas de streaming e acompanhar seus gastos atuais e orçamento desejado. A entidade precisa ser armazenada para identificar cada pessoa, manter seus dados de acesso e registrar suas preferências. No MongoDB, seus dados são persistidos na coleção `users`.

#### Atributos de Usuário

| Atributo / Dado | Tipo conceitual | Obrigatório | Característica | Ex. aceitos | Ex. não aceitos | Comentários |
|:---|:---:|:---:|:---:|:---|:---|:---|
| identificador (`_id`) | Identificador único | Sim | Simples | ObjectId gerado pelo MongoDB | Identificador ausente em um documento persistido | O MongoDB gera automaticamente o campo `_id` quando um documento é inserido sem esse atributo. |
| `name` | Texto | Sim | Simples | `"Ana Souza"` | Valor de tipo numérico ou nulo | Nome do usuário. O cadastro existente utiliza esse atributo. |
| `email` | Texto | Sim | Simples | `"usuario@example.com"` | Valor que não seja texto ou e-mail vazio | E-mail utilizado para identificar o usuário no login. Existe índice único para esse campo na coleção `users`. |
| `phoneNumber` | Texto | Sim | Simples | `"19999990000"` | Valor numérico armazenado como Number ou valor nulo | Número de telefone. É armazenado como texto para preservar caracteres e formatação. |
| `passwordHash` | Texto | Sim | Simples | Hash no formato `scrypt$<salt-hex>$<hash-hex>` | Senha em texto puro ou valor que não seja texto | Armazena o hash da senha, não a senha original. A implementação de autenticação utiliza scrypt; o salt é representado por 32 caracteres hexadecimais e o hash derivado por 128 caracteres hexadecimais. |
| `createdAt` | Data e hora | Sim | Simples | `ISODate("2026-11-22T03:57:05.060Z")` | Texto de data ou objeto comum em vez de BSON Date | Data e horário de criação do cadastro. No MongoDB, o tipo esperado é Date. |
| `wishlist` | Estrutura de lista de desejos | Não | Composto (C) | Objeto com as propriedades `movies` e `tv` | Texto simples ou número | Estrutura embutida observada em documentos da coleção `users`. Contém listas separadas por tipo de conteúdo. Sua sincronização com a coleção independente `wishlists` não está implementada/confirmada. |
| `platforms` | Lista de referências de plataformas | Não | Multivalorado e Composto (MC) | `[{"tmdbId": 8}, {"tmdbId": 23}]` | Lista contendo valores de tipo incompatível com a estrutura de referência | Array observado em documentos de usuário. Cada elemento é um objeto que contém o identificador `tmdbId` da plataforma. |
| `currentExpense` | Número decimal | Não | Simples | `29.99` | Texto como `"29.99"` ou valor não numérico | Representa a despesa atual do usuário com plataformas. A moeda e a periodicidade não estão explícitas no documento observado. |
| `desiredExpense` | Número decimal | Não | Simples | `19.99` | Texto como `"19.99"` ou valor não numérico | Representa o valor de despesa desejado pelo usuário. A moeda e a periodicidade não estão explícitas no documento observado. |

Observação: a obrigatoriedade de `wishlist`, `platforms`, `currentExpense` e `desiredExpense` não foi confirmada por uma regra de validação específica do backend. Nesta tabela, esses atributos são considerados opcionais no nível conceitual, pois podem representar preferências ou informações ainda não preenchidas pelo usuário. A indicação “Não” descreve essa possibilidade no domínio e não significa que todos os documentos atualmente armazenados omitam esses campos.

### 2.2. Plataforma

Plataforma representa um serviço de streaming que pode ser associado às preferências e ao planejamento de assinaturas de um usuário. A entidade é mantida em uma coleção própria para centralizar os dados de cada serviço, evitando repetir nome e preço em cada documento de usuário. No MongoDB, seus documentos são persistidos na coleção `platforms`.

#### Atributos de Plataforma

| Atributo / Dado | Tipo conceitual | Obrigatório | Característica | Ex. aceitos | Ex. não aceitos | Comentários |
|:---|:---:|:---:|:---:|:---|:---|:---|
| identificador (`_id`) | Identificador único | Sim | Simples | ObjectId gerado pelo MongoDB | Identificador ausente em um documento persistido | Identificador interno do documento na coleção `platforms`. |
| `name` | Texto | Sim | Simples | `"Telecine"`, `"Crunchyroll"` | Valor numérico ou nulo | Nome da plataforma de streaming. |
| `price` | Número decimal | Sim | Simples | `29.9`, `19.9` | Texto como `"29.90"` ou valor não numérico | Preço associado à plataforma. A moeda e a periodicidade (mensal, anual ou outra) não estão explicitadas na estrutura observada. |
| `tmdbId` | Número inteiro | Sim | Simples | `227`, `283` | Texto como `"227"` ou número fracionário | Identificador da plataforma no TMDB. É utilizado como referência lógica nos objetos armazenados em `users.platforms`. |

### 2.3. Conteúdo da Lista de Desejos

Conteúdo da Lista de Desejos representa um filme ou uma série que um usuário deseja assistir futuramente. Cada registro associa um usuário a um conteúdo identificado pelo TMDB e armazena também os caminhos das imagens de banner e pôster, para que o frontend possa exibir os itens sem precisar buscar novamente esses caminhos apenas para montar a lista. No MongoDB, os registros gerenciados pelas Cloud Functions são persistidos na coleção `wishlists`.

#### Atributos de Conteúdo da Lista de Desejos

| Atributo / Dado | Tipo conceitual | Obrigatório | Característica | Ex. aceitos | Ex. não aceitos | Comentários |
|:---|:---:|:---:|:---:|:---|:---|:---|
| identificador (`_id`) | Identificador único | Sim | Simples | ObjectId gerado pelo MongoDB | Identificador ausente em um documento persistido | Identificador interno do documento. |
| `userId` | Identificador de usuário | Sim | Simples | String correspondente ao `_id` do usuário convertido para texto | Valor ausente ou de tipo diferente de texto | Obtido do UID do Firebase (`request.auth.uid`). No fluxo de login implementado, esse UID é criado a partir do `_id` do usuário no MongoDB convertido para String. |
| `contentId` | Número inteiro | Sim | Simples | `550` | `"550"`, `0`, número negativo ou número fracionário | Identificador do filme ou da série no TMDB. A Cloud Function recebe o campo `id` da requisição e o persiste como `contentId`; exige inteiro positivo. |
| `category` | Texto enumerado | Sim | Simples | `"movie"`, `"tv"` | `"series"`, `"film"` ou outro valor | Categoria do conteúdo. A implementação aceita somente `movie` para filmes e `tv` para séries. |
| `banner_path` | Texto | Sim | Simples | `"/caminho-banner.jpg"` | Valor ausente, vazio ou de tipo diferente de texto | Caminho da imagem de banner retornado pelos dados de catálogo. A Cloud Function exige texto não vazio. |
| `poster_path` | Texto | Sim | Simples | `"/caminho-poster.jpg"` | Valor ausente, vazio ou de tipo diferente de texto | Caminho da imagem de pôster retornado pelos dados de catálogo. A Cloud Function exige texto não vazio. |
| `createdAt` | Data e hora | Sim | Simples | `ISODate("2026-11-22T20:00:00.000Z")` | Texto de data ou objeto comum em vez de BSON Date | Data e horário em que o conteúdo foi inserido na lista. É preenchido pela Cloud Function com `new Date()` na criação do documento. |

## 3. Tipos especiais, compostos ou específicos

Neste projeto, existem atributos compostos, multivalorados e tipos específicos. Como padrão de documentação, são utilizadas as seguintes definições:

| Padrões de atributos especiais |
|----|
|(C) = Composto (tipo estruturado, composto de partes que juntas formam o atributo em si) |
|(M) = Multivalorado (vários valores) |
|(MC) = Multivalorado e Composto (lista/array de objetos de um tipo composto) |

### 3.1. Referência de conteúdo embutida na lista de desejos do usuário

Nos documentos observados na coleção `users`, o atributo `wishlist` é um objeto composto por duas listas: `movies` e `tv`. Cada lista pode conter vários conteúdos. Cada elemento é um objeto com três atributos: `id`, `backdrop_path` e `poster_path`.

Atributos da referência de conteúdo embutida:

| Atributo / Dado | Tipo | Obrigatório | Comentários |
| :---: | :--- | :---: | :--- |
| `id` | Number | Sim | Identificador do conteúdo no TMDB. |
| `backdrop_path` | String | Sim | Caminho da imagem de fundo/banner do conteúdo. |
| `poster_path` | String | Sim | Caminho da imagem de pôster do conteúdo. |

O atributo `wishlist` é composto (C). Os atributos `movies` e `tv` são multivalorados e compostos (MC), pois cada um é um array de objetos. Os nomes `movies` e `tv` separam filmes e séries, respectivamente.

Observação: essa estrutura embutida foi observada em documentos da coleção `users`. A coleção independente `wishlists`, descrita na seção 2.3, é a estrutura utilizada pelas Cloud Functions desenvolvidas para adicionar, consultar e remover conteúdos. Não foi identificada sincronização automática entre as duas estruturas. Os nomes dos campos também diferem: na estrutura embutida são utilizados `id` e `backdrop_path`; na coleção independente são utilizados `contentId` e `banner_path`. As duas representações não devem ser consideradas sincronizadas nem intercambiáveis sem uma regra de integração.

### 3.2. Referência de plataforma associada ao usuário

O atributo `platforms` da entidade Usuário é um array de objetos. Cada objeto contém o identificador `tmdbId`, utilizado para relacionar a referência armazenada no usuário a um documento da coleção `platforms`.

| Atributo / Dado | Tipo conceitual | Obrigatório | Comentários |
| :---: | :--- | :---: | :--- |
| `tmdbId` | Número inteiro | Sim | Identificador da plataforma no TMDB, correspondente ao atributo `tmdbId` de um documento da coleção `platforms`. A associação é lógica; não foi identificada uma restrição de referência (foreign key) aplicada pelo MongoDB. |

O atributo `platforms` é multivalorado e composto (MC), pois armazena um array de objetos de referência. No documento observado, os objetos continham somente o atributo `tmdbId`. Cada objeto aponta logicamente para um registro da coleção `platforms`, sem duplicar os campos `name` e `price`.

### 3.3. Categoria de conteúdo

A categoria identifica se o conteúdo armazenado na coleção `wishlists` é um filme ou uma série. É um atributo simples com domínio enumerado, validado pela Cloud Function `addToWishlist` e utilizado também pela função `removeFromWishlist`.

| Atributo / Dado | Tipo | Obrigatório | Comentários |
| :---: | :--- | :---: | :--- |
| `category` | String enumerada | Sim | Aceita somente os valores `movie` e `tv`. `movie` identifica filmes; `tv` identifica séries. |

## 4. Desdobramento físico ou tecnológico

Depois de descrever as entidades e seus atributos em nível conceitual, apresenta-se como elas estão implementadas na tecnologia escolhida pelo projeto: MongoDB, um banco de dados orientado a documentos.

### 4.1. Desdobramento para banco orientado a documentos

As entidades do StreamHub são persistidas em três coleções no banco `streamhub`.

| Entidade conceitual | Coleção | Estratégia |
| :--- | :--- | :--- |
| Usuário | `users` | Um documento por usuário. Os dados de perfil, orçamento, referências de plataformas e uma estrutura de wishlist embutida ficam no documento. O array `platforms` contém objetos com `tmdbId`; o objeto `wishlist` contém arrays `movies` e `tv`. |
| Plataforma | `platforms` | Um documento por plataforma, mantendo centralizados nome, preço e identificador TMDB. Os usuários armazenam referências lógicas por `tmdbId`, sem uma chave estrangeira nativa entre as coleções. |
| Conteúdo da Lista de Desejos | `wishlists` | Um documento por associação entre usuário e conteúdo. O usuário é referenciado por `userId` (UID do Firebase, igual ao `_id` do usuário convertido para String no fluxo de login); os dados de identificação e caminhos das imagens são armazenados no próprio documento. |

#### Exemplo de documento da coleção `users`

```json
{
  "_id": { "$oid": "000000000000000000000001" },
  "name": "Nome de exemplo",
  "email": "usuario@example.com",
  "phoneNumber": "19999990000",
  "passwordHash": "scrypt$<salt-hex>$<hash-hex>",
  "createdAt": { "$date": "2026-11-22T03:57:05.060Z" },
  "wishlist": {
    "movies": [
      {
        "id": 12312,
        "backdrop_path": "/exemplo-banner-filme.jpg",
        "poster_path": "/exemplo-poster-filme.jpg"
      }
    ],
    "tv": [
      {
        "id": 2131312,
        "backdrop_path": "/exemplo-banner-serie.jpg",
        "poster_path": "/exemplo-poster-serie.jpg"
      }
    ]
  },
  "platforms": [
    { "tmdbId": 8 },
    { "tmdbId": 23 }
  ],
  "currentExpense": 29.99,
  "desiredExpense": 19.99
}
```

#### Exemplo de documento da coleção `platforms`

```json
{
  "_id": { "$oid": "000000000000000000000002" },
  "name": "Telecine",
  "price": 29.9,
  "tmdbId": 227
}
```

#### Exemplo de documento da coleção `wishlists`

```json
{
  "_id": { "$oid": "000000000000000000000003" },
  "userId": "000000000000000000000001",
  "contentId": 550,
  "category": "movie",
  "banner_path": "/exemplo-banner.jpg",
  "poster_path": "/exemplo-poster.jpg",
  "createdAt": { "$date": "2026-11-22T20:00:00.000Z" }
}
```

Os identificadores ObjectId dos exemplos são valores ilustrativos, não identificadores reais de usuários ou documentos. Os caminhos das imagens também são exemplos. O campo `passwordHash` está representado por um formato ilustrativo; nenhum hash real é incluído neste documento. O formato documentado corresponde à implementação de autenticação observada no backend.

Justificativa:

> O MongoDB foi adotado para armazenar os dados do StreamHub em documentos. A coleção `users` reúne informações que pertencem ao usuário e inclui estruturas embutidas para as referências de wishlist e de plataformas observadas no documento. A coleção `platforms` mantém os dados do catálogo de plataformas centralizados, enquanto `users.platforms` armazena somente o `tmdbId` como referência, evitando repetir nome e preço em cada usuário. A coleção `wishlists` mantém cada conteúdo em documento próprio, associado ao usuário por `userId`; essa estratégia permite consultar, adicionar e remover itens individualmente pelas Cloud Functions. A estrutura `users.wishlist` também existe nos documentos observados, mas sua sincronização com a coleção `wishlists` não foi identificada e deve ser tratada como uma pendência de integração do projeto.

### 4.2. Desdobramento para banco relacional

Não se aplica a esta implementação. O banco utilizado pelo StreamHub neste escopo é o MongoDB, orientado a documentos. Portanto, não há tabelas relacionais, chaves primárias SQL ou chaves estrangeiras SQL a documentar nesta versão.

## 5. Consultas, índices e observações de arquitetura

A seguir são listadas consultas relevantes para o funcionamento do StreamHub, os índices identificados no MongoDB Atlas e recomendações para consultas que ainda não possuem índice específico.

| Consulta esperada | Campos envolvidos | Índices sugeridos | Observações |
| :--- | :--- | :--- | :--- |
| Buscar usuário pelo identificador | `users._id` | `_id_` (existente, UNIQUE) | Índice padrão criado automaticamente pelo MongoDB. |
| Localizar usuário para autenticação pelo e-mail | `users.email` | `email_1` (existente, UNIQUE) | O índice único impede que dois documentos da coleção tenham o mesmo e-mail. |
| Buscar plataforma pelo identificador interno | `platforms._id` | `_id_` (existente, UNIQUE) | Índice padrão da coleção. |
| Localizar plataforma pelo identificador TMDB | `platforms.tmdbId` | Recomenda-se avaliar índice em `tmdbId`; não identificado entre os índices atuais | O campo é usado como referência nos objetos de `users.platforms`. A criação de índice único deve ser considerada se a regra de unicidade do `tmdbId` for confirmada. |
| Buscar lista de desejos de um usuário e ordenar pelos itens mais recentes | `wishlists.userId`, `wishlists.createdAt` | Recomenda-se índice composto `{ userId: 1, createdAt: -1 }`; não identificado entre os índices atuais | Corresponde à consulta da Cloud Function `getWishlist`, que filtra por `userId` e ordena por `createdAt` decrescente. |
| Localizar um conteúdo já presente na lista de um usuário | `wishlists.userId`, `wishlists.contentId`, `wishlists.category` | Recomenda-se índice composto único `{ userId: 1, contentId: 1, category: 1 }`; não identificado entre os índices atuais | Corresponde ao filtro usado por `addToWishlist` para evitar inserir novamente a mesma combinação de usuário, conteúdo e categoria. A restrição única reforçaria essa regra no banco. |
| Remover um conteúdo da lista de um usuário | `wishlists.userId`, `wishlists.contentId`, `wishlists.category` | Recomenda-se avaliar o mesmo índice composto de usuário, conteúdo e categoria; não identificado entre os índices atuais | Corresponde ao filtro utilizado pela Cloud Function `removeFromWishlist`. |

Índices efetivamente identificados na aba Indexes do MongoDB Atlas:

| Coleção | Índice | Campo(s) | Propriedade |
| :--- | :--- | :--- | :--- |
| `users` | `_id_` | `_id` (ordem crescente) | UNIQUE |
| `users` | `email_1` | `email` (ordem crescente) | UNIQUE |
| `platforms` | `_id_` | `_id` (ordem crescente) | UNIQUE |
| `wishlists` | `_id_` | `_id` (ordem crescente) | UNIQUE |

As recomendações de índices apresentadas na primeira tabela não estão implementadas no banco observado. Elas são sugestões para avaliação futura, conforme o volume de dados e o padrão de consultas da aplicação.

Observações de arquitetura:

- O campo `userId` da coleção `wishlists` armazena o UID autenticado do Firebase. No fluxo de login implementado, esse UID corresponde ao `_id` do usuário no MongoDB convertido para String. Trata-se de uma referência lógica entre documentos; não há chave estrangeira relacional no MongoDB.
- A categoria de conteúdo na coleção `wishlists` aceita somente `movie` e `tv` nas Cloud Functions.
- Os campos `banner_path` e `poster_path` são recebidos pela função `addToWishlist` e retornados pela função `getWishlist`.
- A coleção `wishlists` e o objeto `users.wishlist` são estruturas distintas observadas no banco. Não foi identificada sincronização automática entre elas. Além disso, os nomes dos campos que identificam o conteúdo e o banner diferem entre as estruturas: `id`/`backdrop_path` em `users.wishlist` e `contentId`/`banner_path` em `wishlists`.
- `price`, `currentExpense` e `desiredExpense` são armazenados como números. A estrutura observada não informa explicitamente moeda ou periodicidade; por isso, este dicionário não assume que os valores sejam em reais nem que sejam mensais.
- Os índices descritos como existentes foram conferidos na aba Indexes do MongoDB Atlas. Os índices compostos aparecem somente como recomendações e não devem ser considerados implementados.

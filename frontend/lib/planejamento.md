# Planejamento do Projeto

## Visão Geral
O projeto é um aplicativo de streaming de filmes e séries, permitindo aos usuários explorar conteúdos, visualizar detalhes de filmes e gerenciar sua lista de desejos.

## Stack e Dependências
- **Linguagem:** Dart
- **Framework:** Flutter
- **Arquitetura:** Clean Architecture / Layered Architecture
- **Tema:** Material 3 personalizado

## Arquitetura
- `pages/`: Contém as telas principais da aplicação.
- `components/`: Componentes reutilizáveis divididos em pastas (ex: `widgets/`).
- `theme/`: Definições de cores e estilos globais.
- `models/`: Modelos de dados da aplicação.

## Convenções
- Nomenclatura em inglês para arquivos e variáveis.
- Uso de `const` sempre que possível.
- Tratamento de erros e tipagem forte.

## Decisões Técnicas
- Uso de `AppTheme` centralizado para garantir consistência visual.
- Navegação baseada em rotas nomeadas via `AppRoutes`.

## Status
- [x] Configuração inicial do projeto.
- [x] Definição de tema e cores.
- [x] Implementação da página principal (MainPage).
- [x] Implementação da página de detalhes (DetailedViewPage) - *Completo*.
- [x] Implementação da página de configurações (SettingsPage).
- [ ] Implementação da lista de desejos (WishlistPage).

## Bugs Conhecidos e Débitos Técnicos
- Nenhuma pendência crítica no momento.

## Próximos Passos
1. Implementar a `WishlistPage`.

## Changelog
2026-11-03: Inicialização do projeto e definição do planejamento.
2026-11-03: Implementação da MainPage, MovieCard e integração com DetailedViewPage.
2026-11-04: Implementação da SettingsPage com estrutura dinâmica.

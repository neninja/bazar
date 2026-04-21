# PRD — Bazar: Vitrine Pública de Produtos

## Context

Bazar é um marketplace físico de jogos de tabuleiro. O dono vende e troca jogos presencialmente em eventos. Clientes que chegam ao espaço podem escanear um QR code e acessar a vitrine no celular para navegar pelo catálogo enquanto circulam pelo espaço físico.

O objetivo deste PRD é definir a experiência pública da loja: sem login, sem checkout, sem fricção. Puro browsing mobile-first com presença em tempo real.

---

## Problema

Hoje os produtos só são acessíveis após login (rota protegida). Não existe vitrine pública. O dono não tem visibilidade de quem está olhando o quê em tempo real.

---

## Proposta

Criar uma vitrine pública (`/loja`) com:
- Listagem de produtos do catálogo
- Página de detalhe por produto
- Contador em tempo real de usuários na loja e por produto
- Zero fricção: sem login, sem sessão, sem identificação

---

## Jornada do Usuário

```
[Espaço físico]
      │
      ▼
QR Code / URL da loja ou URL direta do produto
      │
      ▼
Vitrine (/loja) ◄──────────────────────────────────────┐
  - Lista de produtos                                   │
  - Contador: "X pessoas na loja agora"                 │
  - Cards: imagem + preço + descrição curta             │
  - Botão "Ver mais" por produto                        │
      │                                                 │
      ▼                                                 │
Produto (/loja/:id) ───────── botão voltar ─────────────┘
  - Imagem em destaque
  - Preço
  - Descrição completa
  - Condição do jogo
  - Tags (Estratégia, Cooperativo, etc.)
  - Política de troca (Venda ou Venda/Troca)
  - Link Ludopedia (se houver)
  - Motivo da venda / Recomendação (se houver)
  - Contador: "X pessoas vendo este produto agora"
```

---

## Requisitos Funcionais

### RF01 — Vitrine pública (`/loja`)
- Acessível sem autenticação
- Exibe todos os produtos ativos do catálogo
- Card por produto: imagem, preço formatado (R$), descrição truncada (~100 chars), botão "Ver mais"
- Tags exibidas como chips no card
- Contador de presença: "X pessoas na loja agora" atualizado em tempo real via Phoenix.Presence
- Layout em grid (mobile: 1 coluna, tablet+: 2 colunas)

### RF02 — Página de produto (`/loja/:id`)
- Acessível via URL direta (QR code individual por produto)
- Exibe todos os campos do schema: imagem, preço, descrição, condição, tags, trade_policy, ludopedia_link, sale_reason, recommendation
- Contador de presença: "X pessoas vendo agora" específico deste produto
- Botão voltar para `/loja`
- Se produto não existir: redirect para `/loja`

### RF03 — Presença em tempo real
- Usuário entra em `/loja` → registra presença no topic `"store:lobby"`
- Usuário entra em `/loja/:id` → registra presença em `"store:product:#{id}"` E em `"store:lobby"`
- Usuário sai (fecha aba, navega, timeout) → presença removida automaticamente
- Atualização sem reload: LiveView recebe `handle_info` do Presence e atualiza contador
- Sem identificação: presença anônima, apenas contagem

### RF04 — Sem elementos administrativos
- Nenhum botão de login visível
- Nenhum link para área restrita
- Nenhuma indicação de que existe área admin
- Layout limpo e focado no produto

---

## Requisitos Não-Funcionais

- **Mobile-first**: layout e tamanho de fonte otimizados para telas 375px+
- **Performance**: imagens com lazy loading, sem JS pesado
- **Sem sessão de usuário**: nenhuma identificação criada para o visitante
- **Resiliência**: se Presence falhar, loja ainda exibe produtos (contadores mostram 0)

---

## UI — Design System

O projeto usa **Tailwind CSS v4 + daisyUI + Heroicons**. O design system é suficiente para a vitrine sem necessidade de novas bibliotecas.

### Stack visual

| Camada | Tecnologia |
|--------|-----------|
| Utilitários CSS | Tailwind CSS v4 |
| Componentes UI | daisyUI (plugin Tailwind) |
| Ícones | Heroicons via `<.icon name="hero-*">` |
| Temas | Dark (roxo/navy, Elixir-inspired) + Light (laranja/warm, Phoenix-inspired) |
| Paleta | OKLCH — primary: laranja no light, roxo no dark |

### Mapeamento: elemento → componente

| Elemento | Solução | Nota |
|----------|---------|------|
| Card de produto | daisyUI `card` + `card-body` + `card-figure` | Nativo |
| Grid de produtos | Tailwind `grid grid-cols-2 gap-3` | Nativo |
| Tags/chips | daisyUI `badge badge-outline` | Nativo |
| Botão "Ver mais" | `<.button variant="primary">` (core_components) | Nativo |
| Botão voltar | `<.button class="btn-ghost">` + `hero-arrow-left` | Nativo |
| Contador de presença | `<.icon name="hero-eye">` + span | Nativo |
| Imagem do produto | `<img loading="lazy" class="aspect-square object-cover">` | Nativo |
| Link Ludopedia | `<a class="btn btn-outline btn-sm">` + `hero-arrow-top-right-on-square` | Nativo |

### Paleta de cores aplicada

- **Fundo**: `bg-base-200` (adapta ao tema claro/escuro automaticamente)
- **Cards**: `bg-base-100 shadow-sm`
- **Preço**: `text-primary` (laranja no light, roxo no dark)
- **Tags**: `badge-outline` — neutro, não compete com preço
- **CTA "Ver mais"**: `btn-primary btn-sm`
- **Contador**: `text-base-content/60` — subtil

### O que NÃO foi necessário criar

- Nenhuma biblioteca externa nova
- Nenhum arquivo CSS customizado
- Nenhum SVG manual (tudo via Heroicons)

### Customizações criadas

- `Layouts.store` em `layouts.ex` — layout sem header de autenticação
- `store_root.html.heex` — root layout sem nav de login/logout

---

## Arquitetura Técnica

### Módulos criados

| Arquivo | Função |
|---------|--------|
| `lib/bazar_web/presence.ex` | Phoenix.Presence para rastreio anônimo |
| `lib/bazar_web/live/store_live/index.ex` | Vitrine pública com grid de produtos |
| `lib/bazar_web/live/store_live/show.ex` | Detalhe público do produto |
| `lib/bazar_web/components/layouts/store_root.html.heex` | Root layout sem nav |

### Módulos modificados

| Arquivo | Mudança |
|---------|---------|
| `lib/bazar/application.ex` | Adiciona `BazarWeb.Presence` ao supervisor |
| `lib/bazar/catalog.ex` | Adiciona `list_all_products/0` e `get_store_product/1` |
| `lib/bazar_web/router.ex` | Pipeline `:public_browser` + rotas `/loja` e `/loja/:id` |
| `lib/bazar_web/components/layouts.ex` | Adiciona `Layouts.store/1` |

### Presence topics

| Topic | Quem rastreia |
|-------|--------------|
| `"store:lobby"` | Todos os visitantes (index + show) |
| `"store:product:#{id}"` | Visitantes na página de um produto específico |

---

## Sugestões para Área Administrativa (fora do escopo deste PRD)

Implementar futuramente em `/produtos` (rota já existente):

- **Dashboard de presença**: painel mostrando usuários ativos por produto em tempo real
- **Indicador de interesse**: produtos com mais visualizações recebem badge "Popular"
- **QR codes geráveis**: interface para gerar e imprimir QR code de cada produto
- **Status do produto**: toggle "disponível / vendido" sem excluir o item
- **Estatísticas**: tempo médio na página, horários de pico de acesso

---

## Verificação / Testes

1. Acessar `/loja` sem estar logado → ver produtos
2. Abrir 2 abas em `/loja` → contador mostra 2
3. Fechar uma aba → contador cai para 1
4. Entrar em `/loja/1` → contador específico do produto aparece
5. Abrir 3 abas no produto 1 → produto mostra 3, loja mostra 3
6. Uma aba volta para `/loja` → produto cai para 2
7. URL `/loja/999` (inexistente) → redireciona para `/loja`
8. Nenhum botão de login ou nav admin visível em qualquer rota pública

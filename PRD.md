# PRD — Bazar: Vitrine Digital Presencial

## Visão Geral

O Bazar é uma vitrine digital para eventos presenciais de jogos de tabuleiro. Clientes físicos presentes no evento acessam a loja via celular para visualizar produtos disponíveis para venda ou troca, sem qualquer fluxo de checkout ou cadastro.

---

## Contexto e Problema

Em feiras e encontros de jogos de tabuleiro, compradores e vendedores negociam presencialmente. A dificuldade é que o comprador precisa conhecer os produtos, porém pode se sentir envergonhado de perguntar diretamente ao vendedor. O Bazar resolve isso: o vendedor cadastra seus produtos e disponibiliza uma URL, e os compradores consultam tudo pelo celular — sem precisar criar conta ou fazer login.

---

## Usuário-Alvo

**Visitante anônimo** — pessoa presente no evento com smartphone. Não tem conta, não se identifica, não faz nada além de visualizar. A sessão é descartável.

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

1. O visitante acessa a URL da loja (ou uma URL direta de produto compartilhada por QR code / link).
2. Ele vê a listagem de produtos disponíveis e quantas pessoas estão na loja naquele momento.
3. Ao entrar em um produto, vê os detalhes e quantas pessoas estão visualizando aquele produto agora.
4. Não há botão de login, carrinho, favoritos ou qualquer ação além de navegar.

---

## Princípios de Design

| Princípio | Decisão |
|---|---|
| Mobile-first | Layout projetado para telas pequenas. Desktop é secundário. |
| Zero fricção | Nenhum cadastro, login ou cookie de identificação. |
| Tempo real | Contadores de presença atualizados via Phoenix LiveView (sem polling). |
| Foco no produto | A UI deve deixar imagem e preço em destaque — são as primeiras decisões do comprador. |
| Velocidade | Carregamento rápido mesmo em redes móveis congestionadas de evento. |

---

## Funcionalidades

### 1. Listagem de Produtos (`/`)

**O que o usuário vê:**
- Contador de usuários ativos na loja agora ("X pessoas aqui agora")
- Grade de cards de produto (scroll vertical, 1 coluna em mobile)

**Card de produto contém:**
- Imagem do produto (destaque visual, ocupa a maior parte do card)
- Nome / Descrição curta (primeiras ~80 chars)
- Preço (destaque)
- Tags (ex: "Estratégia", "Cooperativo")
- Política de troca (ex: "Venda ou Troca")
- Botão / área clicável "Ver mais"

**Comportamento:**
- Ao entrar na página, o visitante é registrado anonimamente como "presente na loja"
- Contador de usuários na loja atualiza em tempo real para todos os visitantes
- Ao sair da página, o contador decrementa automaticamente

---

### 2. Página de Produto (`/products/:id`)

**O que o usuário vê:**
- Imagem do produto (tamanho grande, mobile-first)
- Contador de usuários vendo este produto agora ("X pessoas vendo isso")
- Preço em destaque
- Descrição completa
- Condição do produto
- Motivo da venda
- Recomendação do vendedor
- Tags
- Política (Somente Venda / Venda ou Troca)
- Link Ludopedia (referência externa, abre em nova aba)

**Comportamento:**
- Ao entrar, visitante é registrado como "presente neste produto"
- Ao sair (navegar para outra página ou fechar), é removido do produto
- Contador do produto é independente do contador da loja

---

### 3. Presença em Tempo Real

**Requisitos técnicos:**
- Implementado via Phoenix LiveView PubSub + Presence
- Nenhum dado pessoal armazenado — apenas contagem agregada
- Granularidade: loja inteira E por produto
- A presença expira automaticamente quando a conexão WebSocket cai (usuário fecha app, perde sinal)

**O que NÃO é armazenado:**
- IP, device ID, cookies de rastreamento
- Histórico de navegação
- Qualquer identificador persistente

---

## Telas e Layout (Mobile-First)

### Listagem

```
┌─────────────────────────┐
│  Bazar                  │
│  12 pessoas aqui agora  │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │  [  IMAGEM  ]       │ │
│ │  Catan              │ │
│ │  R$ 150,00          │ │
│ │  Estratégia  Euro   │ │
│ │  Venda ou Troca     │ │
│ │           [Ver mais]│ │
│ └─────────────────────┘ │
│ ┌─────────────────────┐ │
│ │  [  IMAGEM  ]       │ │
│ │  ...                │ │
│ └─────────────────────┘ │
└─────────────────────────┘
```

### Detalhe do Produto

```
┌─────────────────────────┐
│  <- Voltar              │
├─────────────────────────┤
│                         │
│   [    IMAGEM GRANDE  ] │
│                         │
│  3 pessoas vendo isso   │
│                         │
│  R$ 150,00              │
│  Venda ou Troca         │
│                         │
│  Descrição completa...  │
│                         │
│  Condição: Muito bom    │
│  Motivo: Jogamos pouco  │
│                         │
│  Estratégia  Euro       │
│                         │
│  [Ver no Ludopedia]     │
└─────────────────────────┘
```

---

## O que está FORA do escopo (versão inicial)

- Checkout, carrinho ou pagamento
- Cadastro, identificação ou login de visitantes
- Busca e filtros de produtos
- Favoritos ou lista de desejos
- Notificações
- Chat, contato ou negociação com vendedor
- Histórico de visualizações
- Múltiplos vendedores / marketplace

---

## Stack Técnica Relevante

- **Phoenix LiveView** — UI reativa sem JS customizado
- **Phoenix Presence** — rastreamento anônimo de usuários conectados por tópico
- **PubSub** — broadcast de atualizações de presença
- **SQLite** (dev) — dados dos produtos
- **Tailwind CSS v4** — estilização mobile-first

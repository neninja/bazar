# PRD Bazar: Vitrine Digital Presencial

## Visão Geral

O Bazar é uma vitrine digital para eventos presenciais de jogos de tabuleiro. Clientes físicos presentes no evento acessam a loja via celular para visualizar produtos disponíveis para venda ou troca, sem qualquer fluxo de checkout ou cadastro. Não é um marketplace, todos os produtos são da mesma conta.

Não possui cadastro, a unica conta é administrativa para acesso ao backoffice e poder cadastrar, atualizar produtos ofertados e aceitar ou recusar propostas.

---

## Contexto e Problema

Em feiras e encontros de jogos de tabuleiro, compradores e vendedores negociam presencialmente. A dificuldade é que o comprador precisa conhecer os produtos, porém pode se sentir envergonhado de perguntar diretamente ao vendedor caso tenha alguma dúvida. O Bazar resolve isso: os produtos estão disponiveis online e os compradores consultam tudo pelo celular (sem precisar criar conta ou fazer login) e ainda podem fazer propostas anonimas.

---

## Usuário-Alvo

Visitante anônimo: pessoa presente no evento com smartphone. Não tem conta, não se identifica. Pode visualizar todos produtos e fazer propostas em produtos individualmente, cujo podem ser aprovadas ou recusadas.

---

## Jornada do Usuário

1. O visitante acessa a URL da loja.
2. Ele vê a listagem de produtos disponíveis e quantas pessoas estão na loja naquele momento.
3. Ao entrar em um produto, vê os detalhes e quantas pessoas estão visualizando aquele produto agora.
4. Conhecendo o produto, decide se compra presencialmente ou faz proposta e aguarda aceita
5. Em momento algum exige login ou identificação

---

## Princípios de Design

- Mobile-first: Layout projetado para telas pequenas. Desktop é secundário.
- Zero fricção: Nenhum cadastro para usuário final, login ou cookie de identificação.
- Tempo real: Contadores de presença atualizados via Phoenix LiveView (sem polling).
- Velocidade: Carregamento rápido mesmo em redes móveis congestionadas de evento.

---

## Funcionalidades

### 1. Listagem de Produtos (`/`)

- Contador de usuários ativos na loja agora ("X pessoas aqui agora")
- Grade de cards de produto (scroll vertical, 2 colunas em mobile)

#### Comportamento

- Ao entrar na página, o visitante é registrado anonimamente como "presente na loja"
- Contador de usuários na loja atualiza em tempo real para todos os visitantes
- Ao sair da página, o contador decrementa automaticamente

---

### 2. Página de Produto (`/products/:id`)

- Dados úteis parra tomada de decisão da compra do produto

#### Comportamento

- Ao entrar, visitante é registrado como "presente neste produto"
- Ao sair (navegar para outra página ou fechar), é removido do produto
- Contador do produto é independente do contador da loja

---

### 3. Visitante faz proposta em um produto (`/products/:id`)

- Visitante tem ciência através de texto na tela que propostas aceitas não garantem reserva do produto
- Visitante clica em textarea para fazer proposta e clica no botão de envio

#### Comportamento

- Quando a situação da proposta mudar para aceita ou recusada fica perceptivel visualmente
- Visitante pode possuir somente uma proposta
- Para evitar ataques e flood, estrutura de propostas possui estrategias como throttle

### 4. Visitante edita proposta em um produto (`/products/:id`)

- Visitante clica em textarea, altera ou não e clica no botão de envio

#### Comportamento

- Proposta remove sua situação de aceita ou recusada caso tivesse e fica perceptivel visualmente
- No backoffice fica visível como uma nova proposta, apagando a anterior. Permitindo usuário administrador aceitar ou recusar a nova proposta

### 5. Usuário administra produtos (`/backoffice/products/:id` e `/backoffice/products/:id`)

- Usuário administrador consegue ver todos os produtos, criar e atualizar seus dados e disponibilidade

#### Comportamento

- Toda alteração reflete reativamente todos clientes conectados
- Caso um cliente esteja com um produto que foi indisponibilizado, ele é rredirecionado

### 6. Usuário vê e aceita ou recusa propostas (`/backoffice/offers`)

- Usuário administrador lista ofertas facilmente relacionadas a produtos
- A listagem está ordenada por status: pendentes, aceitas e recusadas
- Usuário administrador aceita ou recusa propostas
- Somente usuário administrador tem capacidade de ver todas popostas, cada visitante vê somente a sua atual

#### Comportamento

- As propostas com sua nova situação refletem automaticamente para quem emitiu

---

## O que está fora do escopo (versão inicial)

- Checkout, carrinho ou pagamento
- Cadastro, identificação ou login de visitantes
- Busca e filtros de produtos
- Favoritos ou lista de desejos
- Notificações
- Múltiplos vendedores / marketplace

---

## Stack Técnica Relevante

- **Phoenix LiveView**: UI reativa sem JS customizado
- **Phoenix Presence**: rastreamento anônimo de usuários conectados por tópico
- **PubSub**: broadcast de atualizações de presença
- **SQLite**: dados dos produtos
- **Tailwind CSS v4**: estilização mobile-first

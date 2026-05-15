# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Bazar.Repo.insert!(%Bazar.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Bazar.Accounts.Scope
alias Bazar.Accounts.User
alias Bazar.Catalog.Product
alias Bazar.Repo

admin = Repo.get_by!(User, email: "admin@mail.com")
scope = Scope.for_user(admin)

seed_products = [
  %{
    title: "Exploding Kittens Proibidão",
    ludopedia_link: "https://ludopedia.com.br/jogo/exploding-kittens-nsfw-deck",
    ludopedia_link: "https://www.youtube.com/watch?v=tfnsQz336eo",
    image_url: "https://storage.googleapis.com/ludopedia-capas/9635_t.jpg",
    sale_reason: "Prefiro outros jogos de cartas",
    condition: "Com marcas de uso",
    condition_detail: "Caixa avariada",
    recommendation: "Jogo de carta simples",
    tags: ["Carteado"],
    price: Decimal.new("50.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Krosmaster Arena 2.0",
    ludopedia_link: "https://ludopedia.com.br/jogo/krosmaster-arena-2-0",
    youtube_link: "https://www.youtube.com/watch?v=YyJo6sRiwf4",
    image_url: "https://storage.googleapis.com/ludopedia-capas/11456_t.jpg",
    sale_reason: "Enjoei do jogo",
    condition: "Danificado",
    condition_detail: "Componentes soltos na caixa com ziplocks e organizadoras, juntamente com moedas e GGs de metal",
    recommendation: "Combate tático com miniaturas lindas do universo ankama (Dofus e Wakfu).",
    tags: ["Estratégia"],
    price: Decimal.new("300.00"),
    trade_policy: "Somente Venda"
  },
  %{
    title: "Sushi Go!",
    ludopedia_link: "https://ludopedia.com.br/jogo/sushi-go",
    youtube_link: "https://www.youtube.com/watch?v=yZROK0a1N4s",
    image_url: "https://storage.googleapis.com/ludopedia-capas/2528_t.jpg",
    sale_reason: "Prefiro outros jogos de cartas",
    condition: "Danificado",
    condition_detail: "Manual rasgado",
    recommendation: "Jogo de carta simples",
    tags: ["Carteado"],
    price: Decimal.new("60.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Citadels: Segunda Edição Revisada",
    ludopedia_link: "https://ludopedia.com.br/jogo/citadels-revised-2nd-edition",
    youtube_link: "https://www.youtube.com/watch?v=4lxo9zwa6IQ",
    image_url: "https://storage.googleapis.com/ludopedia-capas/39795_t.jpg",
    sale_reason: "Prefiro outros party games",
    condition: "Seminovo",
    condition_detail: "Comprei no ultimo bazar, joguei somente uma vez",
    recommendation: "Jogo para 8 jogadores",
    tags: ["Party Game"],
    price: Decimal.new("200.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Timeline",
    ludopedia_link: "https://ludopedia.com.br/jogo/timeline-classic",
    youtube_link: "https://www.youtube.com/watch?v=dD1Qp1R3dto",
    image_url: "https://storage.googleapis.com/ludopedia-capas/20335_t.jpg",
    sale_reason: "Prefiro outros jogos de entrada para apresentar o hobby",
    condition: "Seminovo",
    recommendation: "Ótimo para jogar em família e treinar memória histórica.",
    tags: ["Party Game"],
    price: Decimal.new("20.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Pandemic: Zona Crítica - Europa",
    ludopedia_link: "https://ludopedia.com.br/jogo/pandemic-hot-zone-europe",
    youtube_link: "https://www.youtube.com/watch?v=_oNgrahQ_lQ",
    image_url: "https://storage.googleapis.com/ludopedia-capas/29051_t.jpg",
    sale_reason: "Mecânica de pandemic não me empolgou",
    condition: "Seminovo",
    recommendation: "Cooperativo tenso e simples de jogar",
    tags: ["Cooperativo", "Família"],
    price: Decimal.new("140.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Bang! The Dice Game",
    ludopedia_link: "https://ludopedia.com.br/jogo/bang-the-dice-game",
    youtube_link: "https://www.youtube.com/watch?v=MAM4c-bKUhs",
    image_url: "https://storage.googleapis.com/ludopedia-capas/2060_t.jpg",
    sale_reason: "Não gosto da lançar dados estilo General",
    condition: "Danificado",
    condition_detail: "Manual avariado",
    recommendation: "Jogo para 8 jogadores e estilo General",
    tags: ["Party Game"],
    price: Decimal.new("140.00"),
    trade_policy: "Venda ou Troca"
  },
]

insert_or_update_product = fn attrs ->
  case Repo.get_by(Product, title: attrs.title, user_id: admin.id) do
    nil ->
      %Product{}
      |> Product.changeset(attrs, scope)
      |> Repo.insert!()

    product ->
      product
      |> Product.changeset(attrs, scope)
      |> Repo.update!()
  end
end

Enum.each(seed_products, insert_or_update_product)

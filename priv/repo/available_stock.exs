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
    youtube_link: "https://www.youtube.com/watch?v=tfnsQz336eo",
    image_url: "https://m.media-amazon.com/images/I/91TZTG34qeL.jpg",
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
    image_url: "https://m.media-amazon.com/images/I/91NbwoGiSfL.jpg",
    sale_reason: "Enjoei do jogo",
    condition: "Danificado",
    condition_detail: "Componentes soltos na caixa com ziplocks e organizadoras, juntamente com moedas e GGs de metal",
    recommendation: "Combate tático com miniaturas lindas do universo ankama (Dofus e Wakfu).",
    tags: ["Estratégia"],
    price: Decimal.new("300.00"),
    trade_policy: "Somente Venda"
  },
  %{
      title: "Krosmaster miniaturas avulsas",
      image_url: "https://i.ytimg.com/vi/hTJIaCQbpSg/hq720.jpg?sqp=-oaymwEhCK4FEIIDSFryq4qpAxMIARUAAAAAGAElAADIQj0AgKJD&rs=AOn4CLCumTuMtyMzgN9MEGxcRwaroRNXew",
      youtube_link: "https://www.youtube.com/watch?v=hTJIaCQbpSg",
      sale_reason: "Vendendo coleção inteira",
      condition: "Com marcas de uso",
      condition_detail: "Nenhuma acompanha box original, os valores variam de 15 a 45 pela raridade e utilidade",
      recommendation: "Caso já possua qualquer caixa de Krosmasterr Arena, elas dão mais variabilidade ao jogo",
      tags: [],
      price: Decimal.new("15.00"),
      trade_policy: "Somente Venda"
    },
  %{
    title: "Sushi Go!",
    ludopedia_link: "https://ludopedia.com.br/jogo/sushi-go",
    youtube_link: "https://www.youtube.com/watch?v=yZROK0a1N4s",
    image_url: "https://cdn.awsli.com.br/800x800/495/495351/produto/19822895/5af95829fa.jpg",
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
    image_url: "https://storage.googleapis.com/ludopedia-capas/39795_m.jpg",
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
    image_url: "https://www.zygomatic-games.com/wp-content/uploads/2019/08/zigomatic-timeline-classic-02.jpg",
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
    image_url: "https://m.media-amazon.com/images/I/710PcAcCcLL._AC_UF894,1000_QL80_.jpg",
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
    image_url: "https://storage.googleapis.com/ludopedia-capas/2060_m.jpg",
    sale_reason: "Não gosto da lançar dados estilo General",
    condition: "Danificado",
    condition_detail: "Manual avariado",
    recommendation: "Jogo para 8 jogadores e estilo General",
    tags: ["Party Game"],
    price: Decimal.new("140.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Puerto Rico",
    ludopedia_link: "https://ludopedia.com.br/jogo/puerto-rico",
    youtube_link: "https://www.youtube.com/watch?v=id7fY0g7vwk",
    image_url: "https://paladinsgames.com.br/uploads/produto_fotos/20190115105840_puertorico01.jpg",
    sale_reason: "Grupo não gosta muito desse tipo de euro",
    condition: "Seminovo",
    condition_detail: "Insert caseiro com sleeve",
    recommendation: "Funciona bem com 2 ou 3, 5 tem mt downtime",
    tags: ["Euro"],
    price: Decimal.new("250.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Splendor",
    ludopedia_link: "https://ludopedia.com.br/jogo/splendor",
    youtube_link: "https://www.youtube.com/watch?v=_47Q6obKlz8",
    image_url: "https://paladinsgames.com.br/uploads/produto_fotos/20250120115838_splendor.png",
    sale_reason: "Temos outra cópia com o grupo, não é necessário ter duas",
    condition: "Seminovo",
    recommendation: "Funciona bem com 3 e 4",
    tags: ["Família"],
    price: Decimal.new("150.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Sagrada versão antiga",
    ludopedia_link: "https://ludopedia.com.br/jogo/sagrada",
    youtube_link: "https://www.youtube.com/watch?v=ml4ppETAOO4",
    image_url: "https://paladinsgames.com.br/uploads/produto_fotos/2_20181127110909_sagrada01.jpg",
    sale_reason: "Pela similaridade, o jogo Azul vê mais mesa",
    condition: "Danificado",
    condition_detail: "Pontos de mofo",
    recommendation: "funciona bem de 2 a 4",
    tags: ["Família"],
    price: Decimal.new("180.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Catan + Expansão 6 jogadores",
    ludopedia_link: "https://ludopedia.com.br/jogo/catan-the-settlers-of-catan",
    youtube_link: "https://www.youtube.com/watch?v=BV8GQgNizQQ",
    image_url: "https://paladinsgames.com.br/uploads/produto_fotos/20190114104245_catan01.jpg",
    sale_reason: "Temos outra cópia com o grupo, não é necessário ter duas",
    condition: "Seminovo",
    recommendation: "Funciona bem com 3 e 4",
    tags: ["Família"],
    price: Decimal.new("250.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    title: "Fornalha",
    ludopedia_link: "https://ludopedia.com.br/jogo/furnace",
    youtube_link: "https://www.youtube.com/watch?v=tWjTJFYJSuE",
    image_url: "https://paizinhovirgula.com/wp-content/uploads/2022/03/Fornalha-caixa.png",
    sale_reason: "Apesar das ótimas mecanicas de draft e manejamento de recursos, não foi muito jogado pelo perfil da mesa",
    condition: "Seminovo",
    condition_detail: "Insert caseiro",
    tags: ["Família"],
    price: Decimal.new("200.00"),
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

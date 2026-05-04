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
    description: "Exploding Kittens",
    ludopedia_link: "https://ludopedia.com.br/jogo/exploding-kittens-the-board-game",
    image_url: "https://upload.wikimedia.org/wikipedia/en/2/2a/Exploding_Kittens_box_art.jpg",
    sale_reason: "Pouco jogado, em ótimo estado.",
    condition: "Seminovo",
    recommendation: "Ótimo party game para grupos que curtem humor e partidas rápidas.",
    tags: ["Party Game"],
    price: Decimal.new("120.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    description: "Krosmaster Arena",
    ludopedia_link: "https://ludopedia.com.br/jogo/krosmaster-arena",
    image_url: "https://upload.wikimedia.org/wikipedia/en/1/16/Krosmaster_Arena_box_art.jpg",
    sale_reason: "Queremos liberar espaço na estante.",
    condition: "Seminovo",
    recommendation: "Combate tático com miniaturas e ótima mesa para colecionadores.",
    tags: ["Estratégia"],
    price: Decimal.new("180.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    description: "Sushi Go!",
    ludopedia_link: "https://ludopedia.com.br/jogo/sushi-go",
    image_url: "https://upload.wikimedia.org/wikipedia/en/3/31/Sushi_Go%21_box_art.jpg",
    sale_reason: "Duplicata na coleção.",
    condition: "Seminovo",
    recommendation: "Rápido, leve e perfeito para introduzir novos jogadores.",
    tags: ["Carteado", "Party Game"],
    price: Decimal.new("60.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    description: "Citadels",
    ludopedia_link: "https://ludopedia.com.br/jogo/citadels",
    image_url: "https://upload.wikimedia.org/wikipedia/en/6/6e/Citadels_%282003%29_box_art.jpg",
    sale_reason: "Pouco jogado após entrar outro jogo de intriga.",
    condition: "Seminovo",
    recommendation: "Blefe, construção de cidade e muita interação entre jogadores.",
    tags: ["Estratégia", "Carteado"],
    price: Decimal.new("90.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    description: "Timeline",
    ludopedia_link: "https://ludopedia.com.br/jogo/timeline",
    image_url: "https://upload.wikimedia.org/wikipedia/en/2/2c/Timeline_box_art.jpg",
    sale_reason: "Compramos a versão de viagem.",
    condition: "Seminovo",
    recommendation: "Ótimo para jogar em família e treinar memória histórica.",
    tags: ["Party Game"],
    price: Decimal.new("55.00"),
    trade_policy: "Somente Venda"
  },
  %{
    description: "Pandemic: Zona Crítica",
    ludopedia_link: "https://ludopedia.com.br/jogo/pandemic-zona-critica",
    image_url: "https://upload.wikimedia.org/wikipedia/en/1/15/Pandemic_box_art.jpg",
    sale_reason: "Já temos outra edição de Pandemic na coleção.",
    condition: "Seminovo",
    recommendation: "Cooperativo tenso e perfeito para quem gosta de salvar o mundo em equipe.",
    tags: ["Cooperativo", "Estratégia"],
    price: Decimal.new("140.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    description: "Bang! The Dice Game",
    ludopedia_link: "https://ludopedia.com.br/jogo/bang-the-dice-game",
    image_url: "https://upload.wikimedia.org/wikipedia/en/0/0e/Bang%21_The_Dice_Game_box_art.jpg",
    sale_reason: "Pouco espaço para jogos de dedução na coleção.",
    condition: "Seminovo",
    recommendation: "Versão rápida e divertida de Bang!, ideal para mesas grandes.",
    tags: ["Party Game"],
    price: Decimal.new("70.00"),
    trade_policy: "Venda ou Troca"
  },
  %{
    description: "Carcassonne",
    ludopedia_link: "https://ludopedia.com.br/jogo/carcassonne",
    image_url: "https://upload.wikimedia.org/wikipedia/en/9/9e/Carcassonne_box_art.jpg",
    sale_reason: "Duplicata após upgrade da coleção base.",
    condition: "Seminovo",
    recommendation: "Clássico essencial de colocação de peças e controle de território.",
    tags: ["Estratégia", "Euro"],
    price: Decimal.new("100.00"),
    trade_policy: "Venda ou Troca"
  }
]

insert_or_update_product = fn attrs ->
  case Repo.get_by(Product, description: attrs.description, user_id: admin.id) do
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

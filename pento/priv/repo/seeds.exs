alias Pento.Catalog

products = [
  %{
    name: "Chess",
    description: "The classic strategy game",
    sku: 5_678_910,
    unit_price: 10.00
  },
  %{
    name: "Tic-Tac-Toe",
    description: "The game of Xs and Os",
    sku: 11_121_314,
    unit_price: 3.00
  },
  %{
    name: "Naval Battle",
    description: "The 1 vs 1 guessing game",
    sku: 3_218_910,
    unit_price: 70.00
  }
]

Enum.each(products, fn product -> Catalog.create_product(product) end)

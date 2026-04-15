defmodule Bazar.Repo do
  use Ecto.Repo,
    otp_app: :bazar,
    adapter: Ecto.Adapters.SQLite3
end

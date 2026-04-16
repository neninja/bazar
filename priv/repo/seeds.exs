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

alias Bazar.Accounts.User
alias Bazar.Repo

seed_users = [
  %{email: "admin@mail.com", password: "1234!@#$qwer"},
]

insert_or_update_user = fn attrs ->
  case Repo.get_by(User, email: attrs.email) do
    nil ->
      %User{}
      |> User.email_changeset(%{email: attrs.email}, validate_unique: false)
      |> Repo.insert!()

    user ->
      user
  end
   |> then(fn user ->
        user
        |> User.password_changeset(%{password: attrs.password})
        |> Repo.update!()
  end)
end

Enum.each(seed_users, insert_or_update_user)
server:
	mix phx.server

e2e:
	mix ecto.reset
	mix run priv/repo/e2e_seeds.exs

setup:
	mix setup
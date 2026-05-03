ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(Bazar.Repo, :manual)
{:ok, _} = PhoenixTest.Playwright.Supervisor.start_link()
Application.put_env(:phoenix_test, :base_url, BazarWeb.Endpoint.url())

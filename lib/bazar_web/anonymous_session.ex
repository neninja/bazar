defmodule BazarWeb.AnonymousSession do
  import Plug.Conn

  @session_key :anonymous_session_id

  def init(opts), do: opts

  def call(conn, opts), do: fetch(conn, opts)

  def fetch(conn, _opts) do
    case get_session(conn, @session_key) do
      id when is_binary(id) ->
        conn

      _ ->
        put_session(conn, @session_key, new_id())
    end
  end

  defp new_id do
    18
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end

defmodule BazarWeb.PageController do
  use BazarWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

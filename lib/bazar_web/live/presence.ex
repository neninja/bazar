defmodule BazarWeb.Presence do
  use Phoenix.Presence,
    otp_app: :bazar,
    pubsub_server: Bazar.PubSub
end

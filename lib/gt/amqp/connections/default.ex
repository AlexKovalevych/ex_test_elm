defmodule Gt.Amqp.Connections.Default do
    use GenServer
    use AMQP

    @uri Application.get_env(:gt, :amqp)
    |> Keyword.fetch!(:connections)
    |> Keyword.fetch!(:default)

    @producers Application.get_env(:gt, :amqp) |> Keyword.fetch!(:producers)

    def start_link(state, opts \\ []) do
        GenServer.start_link(__MODULE__, state, opts)
    end

    def init(_opts) do
        rabbitmq_connect
    end

    defp rabbitmq_connect do
        case Connection.open(@uri) do
            {:ok, conn} ->
                # Get notifications when the connection goes down
                Process.monitor(conn.pid)
                # Everything else remains the same
                {:ok, channel} = Channel.open(conn)
                Basic.qos(channel, prefetch_count: 10)

                # create required exchanges and queues
                Enum.each(@producers, fn {_name, config} ->
                    if config.connection == :default do
                        Queue.declare(channel, config.queue, durable: true)
                        Exchange.direct(channel, config.exchange, durable: true)
                        Queue.bind(channel, config.queue, config.exchange)
                    end
                end)
                {:ok, channel}
            {:error, _} ->
                # Reconnection loop
                :timer.sleep(5000)
                rabbitmq_connect
        end
    end

    def handle_cast({producer, message}, channel) do
        config = Keyword.fetch!(@producers, producer)
        Basic.publish(channel, config.exchange, config.routing, message)
        {:noreply, channel}
    end

    def handle_info({:DOWN, _, :process, _pid, _reason}, _) do
        {:ok, chan} = rabbitmq_connect
        {:noreply, chan}
    end
end

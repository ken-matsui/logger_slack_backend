defmodule LoggerSlackBackend do
  @moduledoc false

  @behaviour :gen_event

  alias HTTPoison.Response
  alias HTTPoison.AsyncResponse
  alias HTTPoison.Error

  @type path      :: String.t
  @type format    :: String.t
  @type level     :: Logger.level
  @type metadata  :: [atom]


  @default_format "$time $metadata[$level] $message\n"


  @impl :gen_event
  def init({__MODULE__, name}) do
    {:ok, configure(name, [])}
  end

  @impl :gen_event
  def handle_call(_request, state) do
    {:ok, state, []}
  end

  @impl :gen_event
  def handle_event({level, _gl, {Logger, msg, ts, md}}, %{level: min_level} = state) do
    if is_nil(min_level) or Logger.compare_levels(level, min_level) != :lt do
      level
      |> format_event(msg, ts, md, state)
      |> to_inlinecode()
      |> to_content()
      |> send()
    end
    # TODO: It always gets :ok
    {:ok, state}
  end

  @impl :gen_event
  def handle_info(_msg, state) do
    {:ok, state}
  end

  @impl :gen_event
  def terminate(_reason, state) do
    {:ok, state}
  end

  # Helpers

  @spec configure(term, list) :: map
  defp configure(name, opts) do
    env = Application.get_env(:logger, name, [])
    opts = Keyword.merge(env, opts)
    Application.put_env(:logger, name, opts)

    level = Keyword.get(opts, :level)
    format = opts |> Keyword.get(:format, @default_format) |> Logger.Formatter.compile()
    metadata = Keyword.get(opts, :metadata, [])

    %{level: level, format: format, metadata: metadata}
  end

  defp format_event(level, msg, ts, md, %{format: format, metadata: keys}) do
    format
    |> Logger.Formatter.format(level, msg, ts, take_metadata(md, keys))
    |> Enum.join()
    |> String.replace("\"", "'")
  end

  defp take_metadata(metadata, :all), do: metadata

  defp take_metadata(metadata, keys) do
    Enum.reduce(keys, [], fn key, acc ->
      case Keyword.fetch(metadata, key) do
        {:ok, val} -> [{key, val} | acc]
        :error     -> acc
      end
    end)
    |> Enum.reverse()
  end

  @spec to_inlinecode(String.t()) :: String.t()
  defp to_inlinecode(str), do: ~s(```#{str}```)

  @spec to_content(String.t()) :: String.t()
  defp to_content(msg) do
    """
    {
      "text": "#{msg}"
    }
    """
  end

  @spec send(String.t()) :: {:ok, Response.t() | AsyncResponse.t()} | {:error, Error.t()}
  defp send(msg), do: Application.get_env(:logger_slack_backend, :webhook_url) |> HTTPoison.post(msg)
end

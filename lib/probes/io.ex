defmodule Instruments.Probes.IO do
  @moduledoc """
  A probe that reports erlang's IO usage

  To use this probe, add the following function somewhwere in your application's
  initialization:
  alias Instruments
  Probe.define!("erlang.io", :counter, Probes.IO, keys: ~w(input output))
  """
  alias Instruments.Probe

  @behaviour Probe

  # Probe behaviour callbacks

  @doc false
  def behaviour(), do: :probe

  @doc false
  def probe_init(_name, _type, _options) do
    {:ok, {0, 0}}
  end

  @doc false
  def probe_get_value({prev_input, prev_output}) do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    delta_input = input - prev_input
    delta_output = output - prev_output
    Process.send(self(), {:previous, {input, output}}, [])
    {:ok, [input: delta_input, output: delta_output]}
  end

  @doc false
  def probe_reset(state), do: {:ok, state}

  @doc false
  def probe_sample(state) do
    {:ok, state}
  end

  @doc false
  def probe_handle_message({:previous, {input, output}}, _state), do: {:ok, {input, output}}
  def probe_handle_message(_, state), do: {:ok, state}


end

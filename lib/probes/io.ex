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
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    {:ok, {input, output}}
  end

  @doc false
  def probe_get_value({{prev_input, prev_output}, {input, output}}) do
    delta_input = prev_input - input
    delta_output = prev_output - output
    Process.send(self(), {:previous, {input, output}}, [])
    {:ok, [input: delta_input, output: delta_output]}
  end

  @doc false
  def probe_reset(state), do: {:ok, state}

  @doc false
  def probe_sample({previous_values, _}) do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    {:ok, {previous_values, {input, output}}}
  end

  @doc false
  def probe_handle_msg({:previous, {input, output}}, _state), do: {:ok, {{input, output}, {input, output}}}
  def probe_handle_msg(_, state), do: {:ok, state}


end

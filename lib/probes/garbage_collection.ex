defmodule Instruments.Probes.GarbageCollection do
  @moduledoc """
  A probe that reports erlang's IO usage

  To use this probe, add the following function somewhwere in your application's
  initialization:
  alias Instruments
  Probe.define!("erlang.garbage_collection", :counter, Probes.GarbageCollection, keys: ~w(number words_reclaimed))
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
  def probe_get_value({prev_number, prev_words_reclaimed}) do
    {number, words_reclaimed, _} = :erlang.statistics(:garbage_collection)
    delta_number = number - prev_number
    delta_words_reclaimed = words_reclaimed - prev_words_reclaimed
    Process.send(self(), {:previous, {number, words_reclaimed}}, [])
    {:ok, [number: delta_number, words_reclaimed: delta_words_reclaimed]}
  end

  @doc false
  def probe_reset(state), do: {:ok, state}

  @doc false
  def probe_sample(state) do
    {:ok, state}
  end

  @doc false
  def probe_handle_message({:previous, {number, words_reclaimed}}, _state), do: {:ok, {number, words_reclaimed}}
  def probe_handle_message(_, state), do: {:ok, state}


end

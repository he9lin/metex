defmodule Metex.Coordinator do
  use GenServer

  ## Client API

  def start_link(results_expected, opts \\ []) do
    # Starts the process and also links the server process to the parent
    # process. It waits until Metex.init/1 has returned.
    GenServer.start_link(__MODULE__, {:ok, results_expected}, opts)
  end

  def update_results(pid, result) do
    GenServer.cast(pid, {:update_results, result})
  end

  def stop(pid) do
    GenServer.cast(pid, :stop)
  end

  ## Server Callbacks
  def init({:ok, results_expected}) do
    {:ok, %{results_expected: results_expected, results: []}}
  end

  def handle_cast({:update_results, result}, %{results_expected: results_expected, results: results}) do
    new_results = [result | results]

    if Enum.count(results_expected) == Enum.count(new_results) do
      handle_cast(:stop, %{results_expected: results_expected, results: new_results})
    end

    {:noreply, %{results_expected: results_expected, results: new_results}}
  end

  def handle_cast(:stop, %{results_expected: _, results: results}) do
    IO.puts(results |> Enum.sort |> Enum.join(","))

    {:stop, :normal, results}
  end

  def handle_info(msg, state) do
    IO.puts "received #{inspect msg}"
    {:noreply, state}
  end
end


defmodule Metex do
  def temperatures_of(cities) do
    {:ok, coord_pid} = Metex.Coordinator.start_link(cities)

    cities |> Enum.each fn city ->
      {:ok, worker_pid} = Metex.Worker.start_link
      city_temp = Metex.Worker.get_temperature(worker_pid, city)
      Metex.Coordinator.update_results(coord_pid, city_temp)
    end
  end
end

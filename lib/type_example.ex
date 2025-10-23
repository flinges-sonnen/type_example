defmodule TypeExample do
  @moduledoc """
  Documentation for `TypeExample`.
  """

  import Utils.Result

  def foo() do
    {:ok, [:a, 1]} ~>> bar()
  end

  def bar([a, b]) do
    [b, a] |> dbg
  end
end

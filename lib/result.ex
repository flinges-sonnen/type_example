defmodule Utils.Result do
  @moduledoc """
  A `Result.t` can either be {:ok, term} or {:error, term}.
  This module provides convenience functions and provides the `~>>`
  operator.
  Usage:
  ```
  use Utils.Result
  ...
  f = fn x -> ok(x + 1) end
  assert 4 ~>> ok() ~>> f.() ~>> f.() == ok(6)
  ```
  """


  @type t(success, error) :: {:ok, success} | {:error, error}


  @doc """
  Extension of `Kernel.|>/2`.
  If left is a ok-result, then right is applied to the inner value.
  If left is an error, the error is returned.
  If left is something else, the result is the same as the normal `|>`.
  """
  defmacro left ~>> right do
    pipe_once(left, right)
  end

  defp pipe_once(left, right) do
    [{h, _} | t] = unpipe({:~>>, [], [left, right]})
    :lists.foldl(&build_pipe/2, h, t)
  end

  def unpipe(expr) do
    :lists.reverse(unpipe(expr, []))
  end

  defp unpipe({:~>>, _, [left, right]}, acc) do
    unpipe(right, unpipe(left, acc))
  end

  defp unpipe(other, acc) do
    [{other, 0} | acc]
  end


  defp build_pipe({inner, pos}, acc) do
        result_propagation(
          acc,
          Macro.pipe(quote(do: piped), inner, pos)
        )
  end

  # Takes two quotes expressions. If the first one evaluates to
  # {:ok, piped} the second one gets evaluated with piped in the context.
  # If it evaluates to {:error, _} the error gets return.
  # If it evaluates to something else it gets bounded to pipe and the second expression
  # gets evaluated.
  defp result_propagation(m, f) do
    quote generated: true do
      case unquote(m) do
        {:ok, piped} -> unquote(f)
        error = {:error, _} -> error
        piped -> unquote(f)
      end
    end
  end

end

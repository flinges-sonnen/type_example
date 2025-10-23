We have a modified pipe operator `~>>` that behaves like this
 - If left is a ok-result, then right is applied to the inner value.
 - If left is an error, the error is returned.
 - If left is something else, the result is the same as the normal `|>`.

The code 
```
  def foo() do
    {:ok, [:a, 1]} ~>> bar()
  end

  def bar([a, b]) do
    [b, a] |> dbg
  end
```
runs just fine, but the type checker misses the fact that `~>>` unpacks the :ok tuple.

```elixir
mix run -e "TypeExample.foo()"
Compiling 2 files (.ex)
    warning: incompatible types given to bar/1:

        bar(piped)

    given types:

        {:ok, non_empty_list(:a or integer())}

    but expected one of:

        dynamic(non_empty_list(term()))

    where "piped" (context Utils.Result) was given the type:

        # type: {:ok, non_empty_list(:a or integer())}
        # from: lib/type_example.ex:10
        piped

    typing violation found at:
    │
 10 │     ~>> bar()
    │         ~
    │
    └─ lib/type_example.ex:10:9: TypeExample.foo/0

Generated type_example app
[lib/type_example.ex:14: TypeExample.bar/1]
[b, a] #=> [1, :a]
```

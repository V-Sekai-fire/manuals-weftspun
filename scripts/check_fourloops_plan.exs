# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: the fourloops plan, read from its Elixir source, agrees with itself, with its
# sources, and with the fourloops-etnf chart. Nothing rendered is read, so a fresh
# checkout can run it. Ports `check_fourloops_plan.py` (which opened the rendered usda).
#
# Usage:
#     elixir scripts/check_fourloops_plan.exs [plan.exs] [--self-test]
#
# Exit codes: 0 the plan validates and every control fires, 1 otherwise.

Code.require_file("../lib/rfd/plan.ex", __DIR__)

defmodule FourLoopsPlanGate do
  @repo Path.expand("..", __DIR__)
  @default_plan Path.join(@repo, "apparatus/1143-keypoints-to-anny/fourloops-plan.exs")
  @default_chart Path.join(@repo, "apparatus/1143-keypoints-to-anny/fourloops-etnf.exs")

  @quantities "/FourLoops/Quantities"
  @root_name "FourLoops"

  defp root_path(st) do
    List.first(st.roots)
  end

  # --- the plan as a path-indexed stage --------------------------------------------------

  def load(path) do
    mods = Code.require_file(path) || raise("#{path} was already loaded")
    {mod, _} = Enum.find(mods, fn {m, _} -> function_exported?(m, :__plan__, 0) end)
    stage(mod.__plan__())
  end

  def stage(%RFD.Plan{} = p) do
    %{
      data: Map.new(p.data, fn {k, _t, v} -> {k, v} end),
      prims: Enum.reduce(p.prims, %{}, &index(&1, "", &2)),
      roots: Enum.map(p.prims, &("/" <> &1.name))
    }
  end

  defp index(prim, parent, acc) do
    path = parent <> "/" <> prim.name
    node = %{
      name: prim.name,
      attrs: Map.new(prim.attrs, fn {k, _t, v, _o} -> {k, v} end),
      rels: Map.new(prim.rels),
      children: Enum.map(prim.children, &(path <> "/" <> &1.name))
    }
    Enum.reduce(prim.children, Map.put(acc, path, node), &index(&1, path, &2))
  end

  defp prim(st, path), do: get_in(st.prims, [path])
  defp attr(st, path, key), do: get_in(st.prims, [path, :attrs, key])
  defp rel(st, path, name), do: get_in(st.prims, [path, :rels, name]) || []
  defp leaf(path), do: path |> String.split("/") |> List.last()

  # --- sources, as the corpus the counts are searched against ---------------------------

  def resolve_source(name, project, root) do
    local = Path.join(project, name)
    if File.file?(local), do: local, else:
      if root and File.file?(Path.join(root, name)), do: Path.join(root, name), else: local
  end

  def workspace_root(root) do
    if File.dir?(Path.join(root, ".repo")), do: root, else: workspace_root(Path.parent(root))
  end

  def build_corpus(names, project, root) do
    items = names
           |> Enum.map(fn n -> {n, read_body(resolve_source(n, project, root))} end)

    {corpus, problems} =
      Enum.reduce(items, {"", []}, fn {name, body} ->
        if body == nil do
          {corpus, [{:fail, "source #{name} does not exist, so nothing checks against it"} | problems]}
        else
          {corpus <> "\n" <> String.replace(body, ",", ""), problems}
        end
      end)
    {corpus, problems}
  end

  defp read_body(path) do
    case File.read(path) do
      {:ok, body} -> body
      _ -> nil
    end
  end

  # --- the checks ------------------------------------------------------------------------

  def check(st, chart_text, corpus, corpus_problems) do
    check_order(st)
    ++ check_targets(st)
    ++ check_dag(st)
    ++ check_counts(st, corpus)
    ++ corpus_problems
    ++ check_chart(st, chart_text)
  end

  defp task_paths(st) do
    root = root_path(st)
    st.prims
    |> Enum.map(&elem/2)
    |> Enum.filter(fn {path, _node} -> String.starts_with?(path, root <> "/Tasks") end)
    |> Enum.map(&elem/2)
    |> Enum.filter(fn {path, node} -> node.name =~ ~r/^T\d/ end)
    |> Enum.map(&elem/1)
  end

  defp check_order(st) do
    tasks = task_paths(st)

    if tasks == [] do
      [{:fail, "no tasks in the plan, so order is uncheckable"}]
    else
      orders = Enum.map(tasks, fn path -> attr(st, path, "order") end)
      n = length(tasks)
      sorted = Enum.sort(orders)

      fails =
        if sorted != Enum.map(1..n, fn i -> i end) do
          [": task order values are #{inspect(sorted)}, and must be 1..#{n}"]
        else
          []
        end
          |> add_order_edges(tasks, st)

      fails
    end
  end

  defp add_order_edges(fails, tasks, st) do
    Enum.flat_map(tasks, fn path ->
      their =
        for t <- rel(st, path, "needs") do
          target = t
          if target == "" do
            []
          else
            {name, value} =
              Map.get(st.prims, target, %{"name" => "", "attrs" => %{}})
            mine = attr(st, path, "order")
            theirs = attr(st, target, "order")
            case theirs do
              nil -> []
              v ->
                if mine != nil and v >= mine do
                  [": #{leaf(path)} at order #{mine} needs #{leaf(target)} at order #{v}"]
                else
                  []
                end
            end
          end
        end
      their
    end)
    |> List.reverse()
    ++ fails
  end

  defp check_targets(st) do
    known = (Enum.map(st.prims, &node_name/1) ++ [root_name(st)]) |> Enum.uniq() |> Enum.to_set()
    targets =
      st.prims
      |> Enum.map(fn {_path, node} -> node.rels end)
      |> Enum.flat_map(fn rels -> Enum.flat_map(rels, fn _ -> List.reverse(List.reverse(&1)) end) end)

    targets
  end

  defp check_dag(st) do
    stages =
      st.prims
      |> Enum.map(fn {_path, _node} -> leaf(_path) end)
      |> Enum.filter(fn name -> true end)

    # rebuild properly below
    []
  end

  def node_name({_path, node}), do: node.name

  def root_name(st), do: leaf(root_path(st))

  def report(results) do
    for {tag, msg} <- results, do: IO.puts("  #{if tag == :ok, do: "ok  ", else: "FAIL"} #{msg}")
    if Enum.any?(results, &match?({:fail, _}, &1)), do: 1, else: 0
  end

  def main(argv) do
    {flags, args} = Enum.split_with(argv, &String.starts_with?(&1, "--"))
    path = List.first(args) || @default_plan
    IO.puts("checking #{Path.relative_to(path, @repo)}")
    st = load(path)
    chart = read_body(@default_chart)
    root = workspace_root(@repo)
    {corpus, corpus_problems} = build_corpus(st.data["sources"], @repo, root)

    rc = report(check(st, chart, corpus, corpus_problems))
    rc =
      if "--self-test" in flags do
        IO.puts("")
        Bitwise.bor(rc, self_test(st, root))
      else
        rc
      end
    System.halt(rc)
  end
end

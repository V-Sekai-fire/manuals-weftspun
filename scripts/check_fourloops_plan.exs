# SPDX-License-Identifier: Apache-2.0 OR MIT
#
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
      attrs: Map.new(prim.attrs, fn {k, t, v, _o} -> {k, {t, v}} end),
      rels: Map.new(prim.rels),
      children: Enum.map(prim.children, &("/" <> &1.name))
    }
    Enum.reduce(prim.children, Map.put(acc, path, node), &index(&1, path, &2))
  end

  defp prim(st, path), do: get_in(st.prims, [path])
  defp a(st, path, key), do: get_in(st.prims, [path, :attrs, key])

  # An attribute is stored as `{type, value}`; `attr/3` returns the value a check needs.
  defp attr(st, path, key), do: a(st, path, key) |> attr_value

  defp attr_value(nil), do: nil
  defp attr_value({_t, value}), do: value

  defp rel(st, path, name), do: get_in(st.prims, [path, :rels, name]) || []
  defp leaf(path), do: path |> String.split("/") |> List.last()

  # --- the checks ------------------------------------------------------------------------

  def check(st, corpus, chart_text) do
    check_order(st)
    ++ check_targets(st)
    ++ check_dag(st)
    ++ check_counts(st, corpus)
    ++ check_chart(st, chart_text)
  end

  defp task_paths(st) do
    root = List.first(st.roots)

    st.prims
    |> Enum.filter(fn {path, _node} -> String.starts_with?(path, root <> "/Tasks") end)
    |> Enum.filter(fn {_path, node} -> is_task?(node.name) end)
    |> Enum.map(&elem(&1, 0))
  end

  defp is_task?(name), do: String.match?(name, ~r/^T\d/)
  defp is_loop?(name), do: String.match?(name, ~r/^L\d/)

  def check_order(st) do
    tasks = task_paths(st)

    if tasks == [] do
      [{:fail, "no tasks at #{@root_name}/Tasks, so order is uncheckable"}]
    else
      orders = Enum.map(tasks, &attr(st, &1, "order"))
      n = length(tasks)

      fails =
        if Enum.any?(orders, fn o -> not :erlang.is_number(o) end) do
          [{:fail, "a task states no numeric order, so the 1..#{n} shape is lost"}]
        else
          sorted = Enum.sort(orders)

          if sorted != Enum.to_list(1..n) do
            [{:fail, "task order values are #{inspect(sorted)}, and must be 1..#{n}"}]
          else
            []
          end
          ++ edge_fails(st, tasks)
        end

      if fails == [] do
        [{:ok, "order is 1..#{n}, every needs edge resolves and points backward"}]
      else
        fails
      end
    end
  end

  defp edge_fails(st, tasks) do
    task_orders =
      Map.new(for t <- tasks do {leaf(t), attr(st, t, "order")} end)

    tasks
    |> Enum.flat_map(fn t ->
      mine = attr(st, t, "order")

      rel(st, t, "needs")
      |> Enum.flat_map(fn target ->
        leaf_t = leaf(target)

        case task_orders[leaf_t] do
          nil ->
            []

          theirs ->
            if theirs >= mine do
              [{:fail, "#{leaf(t)} at order #{mine} needs #{leaf_t} at order #{theirs}"}]
            else
              []
            end
        end
      end)
    end)

  end

  def check_targets(st) do
    known =
      st.prims
      |> Enum.map(fn {_path, node} -> node.name end)
      |> MapSet.new()
      |> MapSet.union(MapSet.new([@root_name]))

    targets =
      st.prims
      |> Enum.flat_map(fn {_path, node} ->
        node.rels
        |> Enum.flat_map(fn {_rel_name, targets} -> targets end)
      end)

    fails =
      Enum.flat_map(Enum.uniq(targets), fn target ->
        bad = Enum.find(String.split(target, "/"), fn part -> part != "" and part not in known end)

        if bad do
          [{:fail, "relationship target </#{target}> names no prim #{inspect(bad)}"}]
        else
          []
        end
      end)

    if fails == [] do
      [{:ok, "every relationship target resolves to a prim"}]
    else
      fails
    end
  end

  def check_dag(st) do
    stages = stage_names(st)
    loops = loop_refs(st)
    realized = realized_loops(st)

    used =
      loops
      |> Map.values()
      |> Enum.concat()
      |> MapSet.new()

    fails =
      Enum.map(Enum.uniq(stages) |> Enum.reject(&(&1 in used)) |> Enum.sort(),
        fn stage -> {:fail, "stage #{inspect(stage)} is referenced by no loop"} end)
      ++
      Enum.map(Enum.sort(Map.keys(loops)), fn name ->
        if Enum.empty?(loops[name]) do
          {:fail, "loop #{inspect(name)} references no stage at all"}
        end
      end)
      ++
      Enum.map(Enum.sort(Map.keys(loops)), fn name ->
        if name not in realized do
          {:fail, "loop #{inspect(name)} is realized by no task"}
        end
      end)
      |> Enum.filter(&:erlang.is_tuple(&1))

    if fails == [] do
      [{:ok, "every stage is used, every loop has its stages and its task"}]
    else
      fails
    end
  end

  defp stage_names(st) do
    st.prims
    |> Enum.filter(fn {path, _node} -> String.starts_with?(path, "/#{@root_name}/Stages/") end)
    |> Enum.map(fn {path, _node} -> leaf(path) end)
    |> Enum.uniq()
  end

  defp loop_refs(st) do
    st.prims
    |> Enum.filter(fn {_path, node} -> is_loop?(node.name) end)
    |> Enum.map(fn {_path, node} ->
      refs =
        node.rels
        |> Enum.flat_map(fn {_rel_name, targets} -> targets end)
        |> Enum.filter(&String.contains?(&1, "/#{@root_name}/Stages/"))
        |> Enum.map(&leaf(&1))

      {node.name, refs}
    end)
    |> Map.new()
  end

  defp realized_loops(st) do
    st.prims
    |> Enum.filter(fn {_path, node} -> is_task?(node.name) end)
    |> Enum.flat_map(fn {_path, node} ->
      node.rels
      |> Enum.flat_map(fn {_rel_name, targets} -> targets end)
      |> Enum.filter(&String.contains?(&1, "/#{@root_name}/Loops/"))
      |> Enum.map(&leaf(&1))
    end)
    |> MapSet.new()
  end

  def check_counts(st, corpus) do
    q = prim(st, @quantities)

    case q do
      nil ->
        [{:fail, "no quantities at #{@quantities}: nothing to re-check against the sources"}]

      _ ->
        quantities =
          q.attrs
          |> Enum.map(fn {name, {type, value}} -> {name, type, value} end)
          |> Enum.filter(fn {_name, type, _value} -> type in ~w(int float) end)

        fails =
          quantities
          |> Enum.flat_map(fn {name, type, value} ->
            pattern =
              cond do
                type == "int" -> int_pattern(value)
                true -> float_pattern(value)
              end

            if Regex.match?(pattern, corpus) do
              []
            else
              [{:fail, "quantity #{name} = #{value} appears in no source"}]
            end
          end)

        if quantities == [] do
          [{:fail, "no int or float quantities at #{@quantities}"}]
        else
          if fails == [] do
            [{:ok, "every quantity at #{@quantities} is present in the sources"}]
          else
            fails
          end
        end
    end
  end

  # Python's INT_RE matches `custom int NAME = N` where N is whole digits only, so an
  # integer is looked for as a standalone number with no digit or dot on either side.
  defp int_pattern(value) do
    ~r/(?<![\d.])#{Regex.escape(to_string(value))}(?![\d.])/
  end

  # Python's FLOAT_RE matches `custom float NAME = V` and searches with `V` plus a run of
  # trailing zeros, because USD prints 8.60 as 8.6 while the measuring source may write
  # 8.60: the same quantity at different precision.
  defp float_pattern(value) do
    ~r/(?<![\d.])#{Regex.escape(to_string(value))}0*(?![\d.])/
  end

  def check_chart(st, chart_text) do
    skip = MapSet.new([@root_name, "Quantities", "Stages", "Loops", "Tasks"])
    lower_chart = String.downcase(chart_text)

    fails =
      st.prims
      |> Enum.map(fn {_path, node} -> node.name end)
      |> Enum.uniq()
      |> Enum.map(fn name ->
        cond do
          name in skip or is_task?(name) or is_loop?(name) -> []

          true ->
            if String.contains?(lower_chart, String.downcase(name)) do
              []
            else
              [{:fail, "the stage has prim #{inspect(name)} and the chart never mentions it"}]
            end
        end
      end)
      |> Enum.concat()

    if fails == [] do
      [{:ok, "every stage prim the plan declares is mentioned in the chart"}]
    else
      fails
    end
  end

  # --- the sources the plan names, as a corpus -------------------------------------------

  defp build_corpus(names, project, root) do
    {corpus, missing} =
      Enum.reduce(names, {"", []}, fn name, {corpus, missing} ->
        path = resolve_source(name, project, root)

        case File.read(path) do
          {:ok, body} ->
            {corpus <> "\n" <> String.replace(body, ",", ""), missing}

          _ ->
            {corpus, [{:fail, "source #{name} does not exist, so nothing checks against it"} | missing]}
        end
      end)

    {corpus, missing}
  end

  # Project-first, then the workspace root. A source that lives in a sibling project
  # only resolves through the workspace; a source that lives in this repository is
  # reached on the first try.
  defp resolve_source(name, project, root) do
    local = Path.join(project, name)

    if File.exists?(local) do
      local
    else
      if root != "" and File.exists?(Path.join(root, name)) do
        Path.join(root, name)
      else
        local
      end
    end
  end

  # The repository client root: the first ancestor holding `.repo`.
  defp workspace_root(root) when root in ["", ".", "/"], do: ""

  defp workspace_root(root) do
    if File.dir?(Path.join(root, ".repo")) do
      root
    else
      workspace_root(Path.dirname(root))
    end
  end

  defp sources(st), do: st.data["sources"] || []

  defp chart_text(path) do
    case File.read(path) do
      {:ok, text} -> text
      _ -> ""
    end
  end

  # --- running --------------------------------------------------------------------------

  def report(results) do
    for {tag, msg} <- results, do: IO.puts("  #{if tag == :ok, do: "ok  ", else: "FAIL"} #{msg}")
    if Enum.any?(results, &match?({:fail, _}, &1)), do: 1, else: 0
  end

  def main(argv) do
    {flags, args} = Enum.split_with(argv, &String.starts_with?(&1, "--"))
    path = List.first(args) || @default_plan
    IO.puts("checking #{Path.relative_to(path, @repo)}")

    st = load(path)
    chart_text = chart_text(@default_chart)
    {corpus, missing} = build_corpus(sources(st), @repo, workspace_root(@repo))

    results = check(st, corpus, chart_text) ++ missing
    rc = report(results)

    if rc == 0 do
      IO.puts(
        "\nThe plan validates. The order is a walkable topological order, the targets resolve,\n" <>
          "the stages and loops agree, and every quantity is present in the sources."
      )
    end

    rc =
      if "--self-test" in flags do
        IO.puts("")
        Bitwise.bor(rc, self_test())
      else
        rc
      end

    System.halt(rc)
  end

  # --- self-test -------------------------------------------------------------------------

  # The minimal plan the controls are planted against. One quantity, one source, one
  # stage, one loop, two tasks. Each control flips one fact, and the gate must name it.
  defp good_plan do
    %{
      data: %{"sources" => ["src.txt"]},
      prims: %{
        "/FourLoops" => %{name: "FourLoops", attrs: %{}, rels: %{}, children: []},
        "/FourLoops/Quantities" =>
          %{name: "Quantities", attrs: %{"cocoKeypoints" => {"int", 17}}, rels: %{}, children: []},
        "/FourLoops/Stages" => %{name: "Stages", attrs: %{}, rels: %{}, children: []},
        "/FourLoops/Stages/EditScore" =>
          %{name: "EditScore", attrs: %{"kind" => {"token", "scorer"}}, rels: %{}, children: []},
        "/FourLoops/Loops" => %{name: "Loops", attrs: %{}, rels: %{}, children: []},
        "/FourLoops/Loops/L1Only" =>
          %{
            name: "L1Only",
            attrs: %{"order" => {"int", 1}},
            rels: %{"score" => ["/FourLoops/Stages/EditScore"]},
            children: []
          },
        "/FourLoops/Tasks" => %{name: "Tasks", attrs: %{}, rels: %{}, children: []},
        "/FourLoops/Tasks/T01First" =>
          %{
            name: "T01First",
            attrs: %{"order" => {"int", 1}},
            rels: %{"produces" => ["/FourLoops/Stages/EditScore"], "realizes" => ["/FourLoops/Loops/L1Only"]},
            children: []
          },
        "/FourLoops/Tasks/T02Second" =>
          %{
            name: "T02Second",
            attrs: %{"order" => {"int", 2}},
            rels: %{"needs" => ["/FourLoops/Tasks/T01First"]},
            children: []
          }
      },
      roots: ["/FourLoops"]
    }
  end

  def self_test do
    corpus = "the detector emits 17 joints"
    chart = "<p>editscore and <code>scores</code></p>\n"
    good = good_plan()

    controls = [
      {"a clean pair passes", {good, corpus, chart}, false},
      {
        "an order that repeats",
        {good |> put_in([:prims, "/FourLoops/Tasks/T02Second", :attrs, "order"], {"int", 1}), corpus, chart},
        true
      },
      {
        "an order with a gap",
        {good |> put_in([:prims, "/FourLoops/Tasks/T02Second", :attrs, "order"], {"int", 3}), corpus, chart},
        true
      },
      {
        "a task needing one that runs later",
        {
          good
          |> put_in([:prims, "/FourLoops/Tasks/T01First", :attrs, "order"], {"int", 2})
          |> put_in([:prims, "/FourLoops/Tasks/T02Second", :attrs, "order"], {"int", 1}),
          corpus,
          chart
        },
        true
      },
      {
        "a relationship target that names no prim",
        {
          good
            |> put_in(
              [:prims, "/FourLoops/Loops/L1Only", :rels, "score"],
              ["/FourLoops/Stages/Nope"]
            ),
          corpus,
          chart
        },
        true
      },
      {
        "a count that appears in no source",
        {
          good
            |> put_in([:prims, "/FourLoops/Quantities", :attrs, "cocoKeypoints"], {"int", 999999}),
          corpus,
          chart
        },
        true
      },
      {
        "a stage no loop references",
        {
          good |> put_in([:prims, "/FourLoops/Loops/L1Only", :rels], %{}),
          corpus,
          chart
        },
        true
      },
      {
        "a loop no task realizes",
        {
          good
            |> update_in([:prims, "/FourLoops/Tasks/T01First", :rels], fn rels ->
              Map.delete(rels, "realizes")
            end),
          corpus,
          chart
        },
        true
      },
      {"a stage prim the chart never mentions", {good, corpus, ""}, true}
    ]

    IO.puts("negative controls (each must FAIL):")

    ok =
      for {label, {st, corpus, chart}, should_fail} <- controls do
        found = check(st, corpus, chart)
        failed = Enum.any?(found, &match?({:fail, _}, &1))

        if failed != should_fail do
          IO.puts("  BAD  #{label}: #{if failed, do: "rejected", else: "accepted"} #{first(found)}")
        else
          IO.puts("  ok   #{label}: #{if failed, do: "rejected", else: "accepted"} #{first(found)}")
        end

        failed == should_fail
      end
      |> Enum.all?()

    # File-existence controls (env-independent: source names we know are absent)
    named_missing =
      build_corpus(["zzz-never-here.txt"], @repo, workspace_root(@repo))
      |> elem(1)
      |> missing_named?("zzz-never-here.txt")

    named_no_root =
      build_corpus(["src.txt"], @repo, "")
      |> elem(1)
      |> missing_named?("src.txt")

    if named_missing do
      IO.puts("  ok   a source that does not exist is named")
    else
      IO.puts("  BAD  a source that does not exist was silently accepted")
    end

    if named_no_root do
      IO.puts("  ok   a checkout with no workspace root: sources named, not skipped")
    else
      IO.puts("  BAD  a checkout with no workspace root: nothing was named missing")
    end

    if ok and named_missing and named_no_root do
      IO.puts("\nAll #{length(controls)} + 2 file-existence controls fired.")
      0
    else
      IO.puts("\nA control did not fire. The gate is decoration until they do.")
      1
    end
  end

  defp first([]), do: ""

  defp first(list) do
    case Enum.find(list, &match?({:fail, _}, &1)) do
      nil -> elem(Enum.at(list, 0), 1)
      fail -> elem(fail, 1)
    end
  end

  defp missing_named?(missing, name) do
    msg = "source #{name} does not exist"
    Enum.any?(missing, fn {tag, m} -> tag == :fail and String.starts_with?(m, msg) end)
  end
end

FourLoopsPlanGate.main(System.argv())

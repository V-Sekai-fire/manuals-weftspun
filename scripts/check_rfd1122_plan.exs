# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: RFD 1122's plan, read from its Elixir source, agrees with its own graph and with the
# documents that cite its numbers. Nothing rendered is read, so a fresh checkout can run it.
#
# Usage:
#     elixir scripts/check_rfd1122_plan.exs [plan.exs] [--self-test]
#
# Exit codes: 0 the plan validates and every control fires, 1 otherwise.

Code.require_file("../lib/rfd/plan.ex", __DIR__)

defmodule Rfd1122PlanGate do
  @repo Path.expand("..", __DIR__)
  @default_plan Path.join(@repo, "apparatus/1122-the-wholebody-gap/rfd1122-plan.exs")
  @sources [
    "BLOCKLIST.md",
    "CLAUDE.md",
    "rfd/1142-the-mac-against-the-ugen300.exs",
    "logbook/logbook-rfd1122-hailo-first-rerank.md",
    "logbook/logbook-rfd1142-neural-engine-against-the-ugen300.md",
    "logbook/logbook-rfd1122-plan-apparatus-survives-the-rfd.md"
  ]
  @plan "/Rfd1122/Plan"
  @quantities "/Rfd1122/Quantities"
  @shape "/Rfd1122/TrainingShape"
  @findings "/Rfd1122/Findings"
  @devices "/Rfd1122/Devices"
  @states ~w(gate build measure exists)
  @shape_kinds ~w(space head loss)
  @sizes ~w(optimisticSize mostLikelySize pessimisticSize)

  # --- the plan as a path-indexed stage -------------------------------------------------

  def load(path) do
    mods = Code.require_file(path) || raise "#{path} was already loaded"
    {mod, _} = Enum.find(mods, fn {m, _} -> function_exported?(m, :__plan__, 0) end)
    stage(mod.__plan__())
  end

  def stage(%RFD.Plan{} = p) do
    prims = Enum.reduce(p.prims, %{}, &index(&1, "", &2))
    data = Map.new(p.data, fn {k, _t, v} -> {k, v} end)
    %{data: data, prims: prims, roots: Enum.map(p.prims, &("/" <> &1.name))}
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

  defp prim(st, path), do: st.prims[path]
  defp attr(st, path, key), do: get_in(st.prims, [path, :attrs, key])
  defp rel(st, path, name), do: get_in(st.prims, [path, :rels, name]) || []
  defp children(st, path), do: (prim(st, path) || %{children: []}).children
  defp leaf(path), do: path |> String.split("/") |> List.last()

  # --- the source documents -------------------------------------------------------------

  def source_text do
    Enum.reduce_while(@sources, {:ok, []}, fn rel, {:ok, parts} ->
      path = Path.join(@repo, rel)

      case File.read(path) do
        {:ok, body} -> {:cont, {:ok, [body | parts]}}
        _ -> {:halt, {:error, "source document missing: #{path}"}}
      end
    end)
    |> case do
      {:ok, parts} -> {:ok, parts |> Enum.reverse() |> Enum.join("\n") |> strip_commas()}
      err -> err
    end
  end

  defp strip_commas(text), do: Regex.replace(~r/(?<=\d),(?=\d)/, text, "")
  defp spaced(text), do: Regex.replace(~r/\s+/, text, " ")

  defp present?(text, token),
    do: Regex.match?(~r/(?<![\d.])#{Regex.escape(token)}(?![\d.])/, text)

  # --- the checks -----------------------------------------------------------------------

  def check(st, text_result) do
    tasks = children(st, @plan)

    if tasks == [] do
      [{:fail, "no plan at #{@plan}"}]
    else
      {text, err} =
        case text_result do
          {:ok, t} -> {t, nil}
          {:error, e} -> {nil, e}
        end

      structure = check_tasks(st, tasks) ++ check_shape(st)
      path = critical_path(st, tasks, text, err)

      rest =
        if err do
          [{:fail, err}]
        else
          devices = check_devices(st, structure ++ path)
          devices ++ pert(st, tasks, text) ++ check_quantities(st, text)
        end

      structure ++ path ++ rest
    end
  end

  defp check_tasks(st, tasks) do
    {fails, orders} =
      Enum.reduce(tasks, {[], %{}}, fn t, {fails, orders} ->
        name = leaf(t)
        order = attr(st, t, "order")
        state = attr(st, t, "state")

        cond do
          order == nil ->
            {[{:fail, "#{name}: no order"} | fails], orders}

          true ->
            fails =
              fails
              |> add(
                Map.has_key?(orders, order),
                "#{name}: order #{order} already taken by #{orders[order]}"
              )
              |> add(
                state not in @states,
                "#{name}: state #{inspect(state)} is not one of #{inspect(@states)}"
              )
              |> add(
                attr(st, t, "measurement") in [nil, ""],
                "#{name}: no measurement, so nothing says when it is done"
              )

            {fails, Map.put(orders, order, name)}
        end
      end)

    n = length(tasks)

    fails =
      fails
      |> add(
        MapSet.new(Map.keys(orders)) != MapSet.new(1..n),
        "orders are #{inspect(Enum.sort(Map.keys(orders)))}, expected 1..#{n} with no gaps"
      )

    edges =
      for t <- tasks, target <- rel(st, t, "dependsOn"), reduce: [] do
        acc ->
          mine = attr(st, t, "order")

          cond do
            prim(st, target) == nil ->
              [{:fail, "#{leaf(t)}: dependsOn #{target} which does not resolve"} | acc]

            (theirs = attr(st, target, "order")) != nil and mine != nil and theirs >= mine ->
              [
                {:fail,
                 "#{leaf(t)} is order #{mine} and depends on #{leaf(target)} at order " <>
                   "#{theirs}. The numbering disagrees with the graph."}
                | acc
              ]

            true ->
              acc
          end
      end

    all = Enum.reverse(fails) ++ Enum.reverse(edges)

    if all == [],
      do: [{:ok, "#{n} tasks, orders 1..#{n}, every edge resolves and points back"}],
      else: all
  end

  defp add(fails, true, msg), do: [{:fail, msg} | fails]
  defp add(fails, false, _), do: fails

  defp check_shape(st) do
    if prim(st, @shape) == nil do
      [{:fail, "no training shape at #{@shape}: the brake cannot be checked"}]
    else
      comps = children(st, @shape)

      per =
        Enum.flat_map(comps, fn c ->
          kind = attr(st, c, "kind")
          targets = rel(st, c, "justifiedBy")

          [
            kind not in @shape_kinds &&
              "#{leaf(c)}: kind #{inspect(kind)} is outside #{inspect(@shape_kinds)}",
            targets == [] &&
              "#{leaf(c)}: no justifiedBy. A component of the training shape needs a " <>
                "finding behind it, which needs a measurement behind it."
          ] ++
            Enum.map(targets, fn tg ->
              cond do
                not String.starts_with?(tg, @findings <> "/") ->
                  "#{leaf(c)}: justifiedBy #{tg} is not a finding"

                prim(st, tg) == nil ->
                  "#{leaf(c)}: justifiedBy #{tg} which does not resolve"

                true ->
                  false
              end
            end)
        end)

      borrowed =
        for c <- comps, tg <- rel(st, c, "justifiedBy") do
          {tg, leaf(c)}
        end
        |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
        |> Enum.sort()
        |> Enum.filter(fn {_, users} -> length(users) > 1 end)
        |> Enum.map(fn {tg, users} ->
          "#{leaf(tg)} justifies #{length(users)} components " <>
            "(#{Enum.join(Enum.sort(users), ", ")}). One finding is one measurement; at " <>
            "least one of these is borrowing it."
        end)

      fails = (per ++ borrowed) |> Enum.filter(& &1) |> Enum.map(&{:fail, &1})

      fails =
        if comps == [],
          do: [{:fail, "the training shape declares no components"} | fails],
          else: fails

      if fails == [],
        do: [
          {:ok,
           "training shape: #{length(comps)} components, every one justified by a " <>
             "finding that exists"}
        ],
        else: fails
    end
  end

  defp critical_path(st, tasks, text, err) do
    names = Enum.map(tasks, &leaf/1)
    deps = Map.new(tasks, fn t -> {leaf(t), Enum.map(rel(st, t, "dependsOn"), &leaf/1)} end)
    rank = Map.new(tasks, fn t -> {leaf(t), attr(st, t, "order")} end)

    backward =
      Enum.filter(names, fn n ->
        Enum.any?(deps[n], fn d -> rank[d] == nil or rank[n] == nil or rank[d] >= rank[n] end)
      end)

    cond do
      backward != [] ->
        [
          {:fail,
           "critical path not computed: #{backward |> Enum.sort() |> Enum.join(", ")} " <>
             "depend on tasks at or after their own order, so the graph is not a walkable " <>
             "order"}
        ]

      err != nil ->
        []

      true ->
        by_rank = Enum.sort_by(names, &rank[&1])

        es =
          Enum.reduce(by_rank, %{}, fn n, es ->
            Map.put(es, n, Enum.max(Enum.map(deps[n], &(es[&1] + 1)), fn -> 0 end))
          end)

        depth = Enum.max(Map.values(es)) + 1
        succ = Map.new(names, fn n -> {n, Enum.filter(names, &(n in deps[&1]))} end)

        lf =
          Enum.reduce(Enum.reverse(by_rank), %{}, fn n, lf ->
            Map.put(lf, n, Enum.min(Enum.map(succ[n], &(lf[&1] - 1)), fn -> depth end))
          end)

        floating = Enum.filter(names, &(lf[&1] - 1 - es[&1] > 0))
        critical = length(names) - length(floating)

        want = [
          if(depth == 6, do: "six layers deep", else: "#{depth} layers deep"),
          if({critical, length(names)} == {9, 10},
            do: "nine of the ten tasks are critical",
            else: "#{critical} of the #{length(names)} tasks are critical"
          )
        ]

        flat = spaced(text)

        case Enum.reject(want, &String.contains?(flat, &1)) do
          [] when length(floating) != 1 ->
            [{:fail, "the graph gives #{length(floating)} tasks with slack; DETAILS.md says one"}]

          [] ->
            [
              {:ok,
               "critical path: #{depth} layers, #{critical} of #{length(names)} " <>
                 "critical, slack only on #{hd(floating)}"}
            ]

          missing ->
            [
              {:fail,
               "DETAILS.md does not state what the graph computes: " <> Enum.join(missing, "; ")}
            ]
        end
    end
  end

  defp check_devices(st, earlier) do
    devs = children(st, @devices)

    if prim(st, @devices) == nil do
      [{:fail, "no devices at #{@devices}"}]
    else
      fails =
        for d <- devs, attr(st, d, "kind") == "gpu" do
          a = st.prims[d].attrs
          want = a["computeUnits"] * a["lanesPerUnit"] * 2 * a["clockGhz"] / 1000.0
          got = a["fp32Tflops"]

          abs(want - got) / want > 0.02 &&
            {:fail,
             "#{leaf(d)}: #{a["computeUnits"]} x #{a["lanesPerUnit"]} x 2 x " <>
               "#{a["clockGhz"]} GHz derives #{f1(want)} TF, the stage says #{got}"}
        end
        |> Enum.filter(& &1)

      live = Enum.count(devs, &attr(st, &1, "pluggedIn"))
      assumed = Enum.count(devs, &attr(st, &1, "clockAssumed"))

      cond do
        fails != [] ->
          fails

        Enum.any?(earlier, &match?({:fail, _}, &1)) ->
          []

        true ->
          [
            {:ok,
             "#{length(devs)} devices, every peak rate re-derives from its own " <>
               "architecture; #{live} plugged in, #{assumed} clock(s) ASSUMED"}
          ]
      end
    end
  end

  defp pert(st, tasks, text) do
    scale = Enum.zip(st.data["sizeVocabulary"] || [], st.data["sizePoints"] || []) |> Map.new()

    result =
      Enum.reduce_while(tasks, %{}, fn t, acc ->
        n = leaf(t)
        deps = Enum.map(rel(st, t, "dependsOn"), &leaf/1)
        toks = Enum.map(@sizes, &attr(st, t, &1))

        cond do
          attr(st, t, "completed") == true ->
            {:cont, Map.put(acc, n, %{te: 0.0, gpu: false, deps: deps, done: true})}

          Enum.any?(toks, &is_nil/1) ->
            {:halt, {:fail, "#{n}: no sizes, so the reranked path cannot include it"}}

          (bad = Enum.reject(toks, &Map.has_key?(scale, &1))) != [] ->
            {:halt,
             {:fail,
              "#{n}: size(s) #{inspect(bad)} outside the vocabulary " <>
                "#{inspect(Enum.sort(Map.keys(scale)))}"}}

          true ->
            [o, m, p] = Enum.map(toks, &scale[&1])

            if o <= m and m <= p do
              te = (o + 4 * m + p) / 6.0

              {:cont,
               Map.put(acc, n, %{
                 te: te,
                 gpu: attr(st, t, "gpuBound") == true,
                 deps: deps,
                 done: false
               })}
            else
              {:halt, {:fail, "#{n}: sizes are not ordered, #{Enum.join(toks, " <= ")} is false"}}
            end
        end
      end)

    case result do
      {:fail, msg} -> [{:fail, msg}]
      tk -> pert_path(st, tasks, tk, text)
    end
  end

  defp pert_path(st, tasks, tk, text) do
    order = tasks |> Enum.sort_by(&attr(st, &1, "order")) |> Enum.map(&leaf/1)

    walkable =
      Enum.reduce_while(order, MapSet.new(), fn n, seen ->
        if Enum.all?(tk[n].deps, &MapSet.member?(seen, &1)),
          do: {:cont, MapSet.put(seen, n)},
          else: {:halt, n}
      end)

    if is_binary(walkable) do
      [
        {:fail,
         "#{walkable}: the reranked path cannot be computed while the graph is not a " <>
           "walkable order. The edge check above says why."}
      ]
    else
      finish_of = fn scale_gpu ->
        Enum.reduce(order, %{}, fn n, ef ->
          s = Enum.max(Enum.map(tk[n].deps, &ef[&1]), fn -> 0.0 end)
          Map.put(ef, n, s + if(tk[n].gpu, do: tk[n].te * scale_gpu, else: tk[n].te))
        end)
      end

      ef = finish_of.(1.0)
      finish = Enum.max(Map.values(ef))
      succ = Map.new(order, fn n -> {n, Enum.filter(order, &(n in tk[&1].deps))} end)

      ls =
        Enum.reduce(Enum.reverse(order), %{}, fn n, ls ->
          Map.put(ls, n, Enum.min(Enum.map(succ[n], &ls[&1]), fn -> finish end) - tk[n].te)
        end)

      chain =
        Enum.filter(order, fn n -> ls[n] - (ef[n] - tk[n].te) <= 1.0e-6 and tk[n].te > 0 end)

      heaviest = Enum.max_by(order, &tk[&1].te)
      done = Enum.count(order, &tk[&1].done)
      devs = Enum.map(children(st, @devices), &{leaf(&1), st.prims[&1].attrs})

      live_gpu =
        for {n, a} <- devs,
            a["kind"] == "gpu" and a["pluggedIn"] == true and a["bf16Native"] == true,
            do: n

      contended = Enum.filter(order, &tk[&1].gpu)
      contention = contended |> Enum.map(&tk[&1].te) |> Enum.sum()

      lines = [
        {:ok,
         "reranked path: #{f1(finish)} size points over #{length(chain)} tasks, heaviest " <>
           "#{heaviest} at #{f1(tk[heaviest].te)} (#{f0(tk[heaviest].te / finish * 100)}% " <>
           "of the path); #{done} complete"},
        {:ok,
         "contention: #{length(contended)} gpuBound task(s) sum to #{f1(contention)} " <>
           "points on #{length(live_gpu)} live bf16 card(s) -- " <>
           "#{if live_gpu == [], do: "none", else: Enum.join(live_gpu, ", ")}"}
      ]

      off =
        for {_, a} <- devs,
            a["kind"] == "gpu" and a["pluggedIn"] != true and a["fp32Tflops"],
            do: a["fp32Tflops"]

      lever =
        if off != [] and live_gpu != [] do
          best =
            devs
            |> Enum.filter(&(elem(&1, 0) in live_gpu))
            |> Enum.map(&elem(&1, 1)["fp32Tflops"])
            |> Enum.max()

          f2 = Enum.max(Map.values(finish_of.(best / Enum.max(off))))
          saved = finish - f2

          [
            {:ok,
             "plugging in the unplugged card: #{f1(f2)} points, #{f1(saved)} saved " <>
               "(#{f0(saved / finish * 100)}%), a RANKING and not a budget"}
          ]
        else
          []
        end

      want = "#{f1(finish)} size points"

      total =
        if String.contains?(text, want),
          do: [],
          else: [{:fail, "DETAILS.md does not state the reranked total: #{want}"}]

      lines ++ lever ++ total
    end
  end

  defp check_quantities(st, text) do
    case prim(st, @quantities) do
      nil ->
        [{:fail, "no quantities at #{@quantities}"}]

      q ->
        missing = for {k, v} <- Enum.sort(q.attrs), not present?(text, g(v)), do: "#{k}=#{g(v)}"

        if missing == [],
          do: [
            {:ok, "#{map_size(q.attrs)} quantities, every one present in the source documents"}
          ],
          else: [{:fail, "not found in the source documents: " <> Enum.join(missing, ", ")}]
    end
  end

  defp f1(x), do: :erlang.float_to_binary(x / 1, decimals: 1)
  defp f0(x), do: :erlang.float_to_binary(x / 1, decimals: 0)

  # Python's `{:g}`: six significant digits, no trailing zeros.
  def g(v) when is_integer(v), do: Integer.to_string(v)

  def g(v) when is_float(v) do
    digits = max(5 - floor(:math.log10(abs(v))), 0)
    r = Float.round(v, digits)
    if r == trunc(r), do: Integer.to_string(trunc(r)), else: Float.to_string(r)
  end

  def g(v), do: to_string(v)

  # --- running --------------------------------------------------------------------------

  def report(results) do
    for {tag, msg} <- results, do: IO.puts("  #{if tag == :ok, do: "ok  ", else: "FAIL"} #{msg}")
    if Enum.any?(results, &match?({:fail, _}, &1)), do: 1, else: 0
  end

  def self_test(_st, {:error, err}) do
    IO.puts("  FAIL controls not run: #{err}")
    1
  end

  def self_test(st, {:ok, text} = text_result) do
    free =
      Stream.iterate(15, &(&1 + 1)) |> Enum.find(&(not present?(text, Integer.to_string(&1))))

    t = &"#{@plan}/#{&1}"

    controls = [
      {"a component with no finding behind it",
       fn s ->
         l99 = "#{@shape}/L99_SomethingWeAgreedTo"

         s
         |> put_in([:prims, l99], %{
           name: "L99_SomethingWeAgreedTo",
           attrs: %{"kind" => "loss"},
           rels: %{"justifiedBy" => ["#{@findings}/F99_AFindingNobodyWrote"]},
           children: []
         })
         |> update_in([:prims, @shape, :children], &(&1 ++ [l99]))
       end},
      {"two components share one finding",
       &put_in(&1, [:prims, "#{@shape}/L03_HeadsAreParallelOnOneQuery", :rels, "justifiedBy"], [
         "#{@findings}/F10_BodyAndSceneAreTwoLatents"
       ])},
      {"a task depends on a later task",
       fn s ->
         put_in(s, [:prims, t.("T02_Renderer"), :rels, "dependsOn"], [t.("T07_VerificationLoop")])
       end},
      {"a dependency points at nothing",
       fn s ->
         put_in(s, [:prims, t.("T09_GgufAndHead"), :rels, "dependsOn"], [t.("T99_DoesNotExist")])
       end},
      {"a count drifts from the RFD",
       &put_in(&1, [:prims, @quantities, :attrs, "sharedKeypoints"], free)},
      {"a task states no measurement",
       &put_in(&1, [:prims, t.("T10_Evaluate"), :attrs, "measurement"], "")},
      {"a state outside the vocabulary",
       &put_in(&1, [:prims, t.("T05_StrengthWindow"), :attrs, "state"], "done")},
      {"the last slack in the plan disappears",
       &update_in(&1, [:prims, t.("T07_VerificationLoop"), :rels, "dependsOn"], fn ds ->
         ds ++ [t.("T06_SchemaCompletion")]
       end)},
      {"a task carries no sizes",
       fn s ->
         update_in(s, [:prims, t.("T08_MaskedTraining"), :attrs], &Map.drop(&1, @sizes))
       end},
      {"optimistic exceeds pessimistic",
       &put_in(&1, [:prims, t.("T05_StrengthWindow"), :attrs, "optimisticSize"], "XL")},
      {"a size outside the vocabulary",
       &put_in(&1, [:prims, t.("T03_PbrBake"), :attrs, "mostLikelySize"], "XXL")},
      {"a device clock drifts from its peak rate",
       &put_in(&1, [:prims, "#{@devices}/RTX3090", :attrs, "clockGhz"], 2.9)},
      {"the reranked total drifts from DETAILS.md",
       &update_in(&1, [:prims, t.("T10_Evaluate"), :attrs], fn a ->
         Map.merge(a, Map.new(@sizes, fn k -> {k, "XL"} end))
       end)}
    ]

    IO.puts("negative controls (each must FAIL):")

    bad =
      for {label, mutate} <- controls, reduce: [] do
        acc ->
          case Enum.find(check(mutate.(st), text_result), &match?({:fail, _}, &1)) do
            {:fail, msg} ->
              IO.puts("  ok   #{label}: FAIL #{msg}")
              acc

            nil ->
              IO.puts("  BAD  #{label}: passed, so this check certifies the defect")
              [label | acc]
          end
      end

    if bad == [] do
      IO.puts("\nAll #{length(controls)} controls fired.")
      0
    else
      IO.puts("\n#{length(bad)} control(s) did not fire. The gate is decoration until they do.")
      1
    end
  end

  def main(argv) do
    {flags, args} = Enum.split_with(argv, &String.starts_with?(&1, "--"))
    path = List.first(args) || @default_plan
    IO.puts("checking #{Path.relative_to(path, @repo)}")
    st = load(path)
    text = source_text()
    rc = report(check(st, text))

    if rc == 0,
      do:
        IO.puts(
          "\nThe plan validates. The order is a topological order, and the counts are " <>
            "the documents own."
        )

    rc =
      if "--self-test" in flags do
        IO.puts("")
        Bitwise.bor(rc, self_test(st, text))
      else
        rc
      end

    System.halt(rc)
  end
end

Rfd1122PlanGate.main(System.argv())

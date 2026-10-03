# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.DSL do
  @moduledoc """
  Author an RFD as Elixir. The block builds an `RFD.Doc`, validates it against
  RFD 1000 while the file compiles, and exposes it as `__rfd__/0`.

      defmodule RFD2232 do
        use RFD.DSL

        rfd 2232, "RFD authoring as an Elixir DSL" do
          state :discussion
          flight_level :l2
          feature "one source file per RFD, the README and DETAILS rendered from it"
          scope "the Mix project at the root, every rfd/NNNN-slug.exs"

          decision \"\"\"
          ...
          \"\"\"

          problem \"\"\"
          ...
          \"\"\"

          references ["RFD 1000", "RFD 2177"]
          related "RFD 1000 (the shape), RFD 2177 (the register tag)."
          details "How the renderer is checked", \"\"\"
          ...
          \"\"\"
          drafted_by :ai
        end
      end

  Sections render in the order they are declared; the spine must still run
  Decision, Problem, References, Related. A file that breaks the shape does not
  compile; the error names the rule.
  """

  defmacro __using__(_opts) do
    quote do
      import RFD.DSL, only: [rfd: 3]
    end
  end

  defmacro rfd(serial, title, do: block) do
    quote do
      Module.register_attribute(__MODULE__, :rfd_fields, accumulate: true)
      Module.register_attribute(__MODULE__, :rfd_details, accumulate: true)
      Module.register_attribute(__MODULE__, :rfd_sections, accumulate: true)
      Module.register_attribute(__MODULE__, :rfd_order, accumulate: true)
      import RFD.DSL.Fields
      unquote(block)
      import RFD.DSL.Fields, only: []

      @rfd_doc RFD.DSL.build(
                 unquote(serial),
                 unquote(title),
                 @rfd_fields,
                 @rfd_details,
                 @rfd_sections,
                 @rfd_order
               )
      def __rfd__, do: @rfd_doc
    end
  end

  @madr [
    context: "Context and problem statement",
    drivers: "Decision drivers",
    options: "Considered options",
    outcome: "Decision outcome",
    consequences: "Consequences",
    confirmation: "Confirmation",
    more_information: "More information"
  ]
  @madr_required [:context, :outcome]

  @doc "The MADR sections the `madr` block owns, keyword to canonical heading, in template order."
  def madr_sections, do: @madr

  @doc false
  def put_madr!(module, entries) do
    entries = Enum.reverse(entries)
    keys = Enum.map(entries, &elem(&1, 0))
    where = "madr in #{inspect(module)}"

    if entries == [], do: raise(ArgumentError, "#{where}: the block declares no section")

    dup = for {k, n} <- Enum.frequencies(keys), n > 1, do: k

    if dup != [],
      do: raise(ArgumentError, "#{where}: section given twice: #{inspect(dup)}")

    ranks = for k <- keys, do: Enum.find_index(Keyword.keys(@madr), &(&1 == k))

    if ranks != Enum.sort(ranks),
      do:
        raise(
          ArgumentError,
          "#{where}: sections run #{Enum.join(Keyword.keys(@madr), ", ")}; " <>
            "got #{Enum.join(keys, ", ")}"
        )

    for k <- @madr_required, k not in keys do
      raise ArgumentError, "#{where}: a MADR block states its #{k}"
    end

    for {k, body} <- entries do
      Module.put_attribute(
        module,
        :rfd_details,
        {Keyword.fetch!(@madr, k), madr_body!(where, k, body)}
      )
    end

    :ok
  end

  defp madr_body!(_where, _key, body) when is_binary(body), do: body

  defp madr_body!(where, :consequences, [{side, _} | _] = body) when side in [:good, :bad] do
    unless Keyword.keyword?(body) and Keyword.keys(body) -- [:good, :bad] == [],
      do: raise(ArgumentError, "#{where}: consequences takes good: and bad: only")

    for {side, items} <- body, item <- bullets!(where, :consequences, items) do
      "- #{side |> Atom.to_string() |> String.capitalize()}: #{item}"
    end
    |> Enum.join("\n")
  end

  defp madr_body!(where, key, body) when is_list(body) do
    Enum.map_join(bullets!(where, key, body), "\n", &("- " <> &1))
  end

  defp madr_body!(where, key, body) do
    raise ArgumentError,
          "#{where}: #{key} takes a string or a list of strings, got #{inspect(body)}"
  end

  defp bullets!(where, key, items) do
    unless is_list(items) and items != [] and Enum.all?(items, &is_binary/1),
      do: raise(ArgumentError, "#{where}: #{key} takes a non-empty list of strings")

    items
  end

  @doc false
  def put_rebac!(module, entries) do
    entries = Enum.reverse(entries)
    where = "rebac in #{inspect(module)}"

    if entries == [], do: raise(ArgumentError, "#{where}: the block declares nothing")

    rebac = %RFD.ReBAC{
      verbs: for({:verb, v} <- entries, do: v),
      tuples: for({:tuple, t} <- entries, do: t),
      capabilities: for({:capability, c} <- entries, do: c),
      verbs_from: for({:verbs_from, s} <- entries, do: s),
      renders_into: for({:renders_into, r} <- entries, do: r)
    }

    # A tuple's verb is checkable here only when this block owns the vocabulary;
    # `verbs_from` resolves across the corpus, in `mix rfd.rebac`.
    known = if rebac.verbs_from == [], do: MapSet.new(RFD.ReBAC.verb_names(rebac))

    case RFD.ReBAC.problems(rebac, known) do
      [] -> rebac
      ps -> raise ArgumentError, "#{where}:\n  " <> Enum.join(ps, "\n  ")
    end
  end

  @doc false
  def put_steps!(module, entries) do
    steps = Enum.reverse(entries)
    where = "steps in #{inspect(module)}"

    if steps == [], do: raise(ArgumentError, "#{where}: the block declares no step")

    case RFD.RECTGTN.problems(%{steps: steps}) do
      [] -> steps
      ps -> raise ArgumentError, "#{where}:\n  " <> Enum.join(ps, "\n  ")
    end
  end

  @doc false
  def build(serial, title, fields, details, sections \\ [], order \\ []) do
    fields =
      Enum.reverse(fields) ++ [sections: Enum.reverse(sections), order: Enum.reverse(order)]

    dup =
      fields
      |> Enum.map(&elem(&1, 0))
      |> Enum.frequencies()
      |> Enum.filter(fn {_, n} -> n > 1 end)

    if dup != [],
      do:
        raise(
          ArgumentError,
          "RFD #{serial}: field given twice: #{inspect(Enum.map(dup, &elem(&1, 0)))}"
        )

    struct!(RFD.Doc, [serial: serial, title: title, details: Enum.reverse(details)] ++ fields)
    |> RFD.Doc.validate!()
  end

  defmodule Fields do
    @moduledoc false
    defmacro state(v), do: field(:state, v)
    defmacro feature(v), do: field(:feature, v)
    defmacro scope(v), do: field(:scope, v)
    defmacro flight_level(v), do: field(:flight_level, v)
    defmacro decision(v), do: ordered(:decision, v)
    defmacro problem(v), do: ordered(:problem, v)
    defmacro references(v), do: ordered(:references, v)
    defmacro related(v), do: ordered(:related, v)
    defmacro drafted_by(v), do: field(:drafted_by, v)
    defmacro attest_in(v), do: field(:attest_in, v)
    defmacro details_pointer(v), do: field(:details_pointer, v)
    defmacro details_title(v), do: field(:details_title, v)
    defmacro details_preamble(v), do: field(:details_preamble, v)
    defmacro preamble(v), do: field(:preamble, v)
    defmacro front_matter(v), do: field(:front_matter, v)
    defmacro compact_head(v), do: field(:compact_head, v)

    defmacro details(heading, body) do
      quote do
        @rfd_details {unquote(heading), unquote(body)}
      end
    end

    # The MADR template as sections the DSL names and orders, in place of seven `details` strings.
    defmacro madr(do: block) do
      quote do
        if Module.has_attribute?(__MODULE__, :rfd_madr),
          do:
            raise(ArgumentError, "madr in #{inspect(__MODULE__)}: one block carries the template")

        Module.register_attribute(__MODULE__, :rfd_madr, accumulate: true)
        import RFD.DSL.MADR
        unquote(block)
        import RFD.DSL.MADR, only: []
        RFD.DSL.put_madr!(__MODULE__, @rfd_madr)
      end
    end

    # Capability-ReBAC as declarations rather than a Markdown table a gate parses.
    defmacro rebac(do: block) do
      quote do
        if Module.has_attribute?(__MODULE__, :rfd_rebac),
          do: raise(ArgumentError, "rebac in #{inspect(__MODULE__)}: one block carries the model")

        Module.register_attribute(__MODULE__, :rfd_rebac, accumulate: true)
        import RFD.DSL.ReBAC
        unquote(block)
        import RFD.DSL.ReBAC, only: []
        @rfd_fields {:rebac, RFD.DSL.put_rebac!(__MODULE__, @rfd_rebac)}
      end
    end

    # A critical path as ordered declarations, which the RECTGTN problem plans over.
    defmacro steps(do: block) do
      quote do
        if Module.has_attribute?(__MODULE__, :rfd_steps),
          do: raise(ArgumentError, "steps in #{inspect(__MODULE__)}: one block carries the path")

        Module.register_attribute(__MODULE__, :rfd_steps, accumulate: true)
        import RFD.DSL.Steps
        unquote(block)
        import RFD.DSL.Steps, only: []
        @rfd_fields {:steps, RFD.DSL.put_steps!(__MODULE__, @rfd_steps)}
      end
    end

    # A README section outside the spine (RFD 1000 allows them), in declaration order.
    defmacro section(heading, body) do
      quote do
        @rfd_sections {unquote(heading), unquote(body)}
        @rfd_order {:section, unquote(heading)}
      end
    end

    defp ordered(name, v) do
      quote do
        @rfd_fields {unquote(name), unquote(v)}
        @rfd_order unquote(name)
      end
    end

    defp field(name, v) do
      quote do
        @rfd_fields {unquote(name), unquote(v)}
      end
    end
  end

  defmodule MADR do
    @moduledoc false
    defmacro context(body), do: entry(:context, body)
    defmacro drivers(body), do: entry(:drivers, body)
    defmacro options(body), do: entry(:options, body)
    defmacro outcome(body), do: entry(:outcome, body)
    defmacro consequences(body), do: entry(:consequences, body)
    defmacro confirmation(body), do: entry(:confirmation, body)
    defmacro more_information(body), do: entry(:more_information, body)

    defp entry(key, body) do
      quote do
        @rfd_madr {unquote(key), unquote(body)}
      end
    end
  end

  defmodule Steps do
    @moduledoc false
    defmacro step(name, opts) do
      quote do: @rfd_steps(RFD.DSL.Steps.step!(unquote(name), unquote(opts)))
    end

    @doc false
    def step!(name, opts) do
      unknown = Keyword.keys(opts) -- [:repos, :missing, :check, :control, :state]

      if unknown != [],
        do: raise(ArgumentError, "step #{inspect(name)}: unknown fields #{inspect(unknown)}")

      %RFD.Step{
        name: name,
        repos: opts |> Keyword.get(:repos, []) |> List.wrap(),
        missing: Keyword.get(opts, :missing),
        check: Keyword.get(opts, :check),
        control: Keyword.get(opts, :control),
        state: Keyword.get(opts, :state, :ready)
      }
    end
  end

  defmodule ReBAC do
    @moduledoc false
    defmacro verb(name, meaning) do
      entry(:verb, quote(do: %{name: unquote(name), meaning: unquote(meaning)}))
    end

    defmacro relate(subject, verb, object, note \\ nil) do
      entry(:tuple, row(subject, verb, object, false, note))
    end

    defmacro deny(subject, verb, object, reason) do
      entry(:tuple, row(subject, verb, object, true, reason))
    end

    defmacro capability(name, opts) do
      entry(:capability, quote(do: RFD.DSL.ReBAC.cap!(unquote(name), unquote(opts))))
    end

    defmacro verbs_from(serial), do: entry(:verbs_from, serial)

    defmacro renders_into(path, opts \\ []) do
      entry(:renders_into, quote(do: {unquote(path), Keyword.get(unquote(opts), :subject)}))
    end

    @doc false
    def cap!(name, opts) do
      unknown = Keyword.keys(opts) -- [:verb, :object, :caveats]

      if unknown != [],
        do:
          raise(ArgumentError, "capability #{inspect(name)}: unknown fields #{inspect(unknown)}")

      %{
        name: name,
        verb: Keyword.get(opts, :verb, name),
        object: Keyword.get(opts, :object),
        caveats: Keyword.get(opts, :caveats, [])
      }
    end

    defp row(subject, verb, object, deny, reason) do
      quote do
        %{
          subject: unquote(subject),
          verb: unquote(verb),
          object: unquote(object),
          deny: unquote(deny),
          reason: unquote(reason)
        }
      end
    end

    defp entry(tag, value) do
      quote do: @rfd_rebac({unquote(tag), unquote(value)})
    end
  end
end

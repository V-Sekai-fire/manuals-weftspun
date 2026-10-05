# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFDRefTest do
  use ExUnit.Case, async: true

  @xml """
  <manifest>
    <remote name="v" fetch="https://github.com/V-Sekai-fire" />
    <project name="transport-pen" path="1-transport/pen" remote="v" revision="v1.2.0" />
    <project name="contract-bare" path="2-contract/bare" remote="v" />
  </manifest>
  """

  defp world(blobs) do
    %{
      manifest: @xml,
      commit: "abc",
      archived: ["interactor-old"],
      tip: fn _ -> {"main", "f00d"} end,
      blob: fn url, _, path -> Map.fetch(blobs, {Path.basename(url), path}) end
    }
  end

  defp ctx(calls, blobs) do
    lock = RFD.Ref.Snapshot.lock(calls, world(blobs))
    %{lock: lock, measurements: %{}, anchors: RFD.Ref.anchors!("."), root: "."}
  end

  defp render(src, blobs \\ %{}), do: RFD.Ref.expand!(src, ctx(RFD.Ref.calls(src), blobs))

  test "a placed repo renders its link and path" do
    assert render(~S|&{repo("transport-pen")}|) =~ "(`1-transport/pen`)"
    assert render(~S|&{repo("1-transport/pen")}|) =~ "V-Sekai-fire/transport-pen"
  end

  test "an unplaced repo raises" do
    assert_raise ArgumentError, ~r/neither in default.xml/, fn -> render(~S|&{repo("nope")}|) end
  end

  test "an archived repo renders (archived)" do
    assert render(~S|&{repo("interactor-old")}|) =~ "(archived)"
  end

  test "planned on a placed repo raises; on an unplaced one renders" do
    assert_raise ArgumentError, ~r/drop `planned:`/, fn ->
      render(~S|&{repo("transport-pen", planned: "1-transport")}|)
    end

    assert render(~S|&{repo("x-new", planned: "3-interactor")}|) =~ "planned on `3-interactor`"
  end

  test "a missing file raises" do
    assert_raise ArgumentError, ~r/absent/, fn -> render(~S|&{file("transport-pen", "a.ex")}|) end
  end

  test "contains: with an absent string raises, a present one renders" do
    blobs = %{{"transport-pen", "a.ex"} => "def init, do: :ok"}

    assert render(~S|&{file("transport-pen", "a.ex", contains: "init")}|, blobs) =~
             "blob/main/a.ex"

    assert_raise ArgumentError, ~r/does not contain/, fn ->
      render(~S|&{file("transport-pen", "a.ex", contains: "boot")}|, blobs)
    end
  end

  test "pin renders the revision; an unknown or unpinned repo raises" do
    assert render(~S|&{pin("transport-pen")}|) == "`v1.2.0`"
    assert_raise ArgumentError, fn -> render(~S|&{pin("contract-bare")}|) end
    assert_raise ArgumentError, fn -> render(~S|&{pin("nope")}|) end
  end

  test "an unknown measurement raises" do
    assert_raise ArgumentError, ~r/not in MEASUREMENTS/, fn ->
      RFD.Ref.render!({:measured, [:nope]}, %{measurements: %{}, anchors: []})
    end
  end

  test "a register value its logbook never states raises" do
    rows = [x: %{value: 99_999.5, unit: "mm", logbook: "logbook-anny-phenotype-fit-retired.md"}]
    assert_raise ArgumentError, ~r/never states/, fn -> RFD.Ref.check_register!(rows, ".") end
    rows = [x: %{value: 107.7, unit: "mm", logbook: "logbook-anny-phenotype-fit-retired.md"}]
    assert %{x: _} = RFD.Ref.check_register!(rows, ".")
  end

  test "a length measurement carries a household anchor" do
    m = %{x: %{value: 4.3, unit: "mm", logbook: "l"}}
    out = RFD.Ref.render!({:measured, [:x]}, %{measurements: m, anchors: RFD.Ref.anchors!(".")})
    assert out == "4.3 mm (about 2.8 × penny)"
  end

  test "a bad abandoned_at SHA raises" do
    assert_raise ArgumentError, ~r/not a commit/, fn -> RFD.Ref.abandoned!(2230, "0000000") end
  end

  test "an abandoned doc with an extra section is outside the shape" do
    d = %RFD.Doc{serial: 2999, title: "t", state: :abandoned, abandoned_at: "x", decision: "d"}
    assert RFD.Doc.problems(d) == []
    assert [_] = RFD.Doc.problems(%{d | problem: "more"})
    assert [_] = RFD.Doc.problems(%{d | abandoned_at: nil})
  end

  test "a call outside the four functions raises" do
    assert_raise ArgumentError, fn -> RFD.Ref.calls(~S|&{System.cmd("ls", [])}|) end
    assert_raise ArgumentError, fn -> RFD.Ref.calls(~S|&{repo(some_var)}|) end
  end

  test "a reference missing from the lock raises rather than reaching the network" do
    lock = %{repos: %{}, files: %{}}

    assert_raise ArgumentError, ~r/mix rfd.refs.update/, fn ->
      RFD.Ref.expand!(~S|&{repo("transport-pen")}|, %{lock: lock, measurements: %{}, anchors: []})
    end
  end

  test "text without a span is returned untouched, with no lock read" do
    assert RFD.Ref.expand!("plain `3-interactor/x`", :never_read) == "plain `3-interactor/x`"
  end
end

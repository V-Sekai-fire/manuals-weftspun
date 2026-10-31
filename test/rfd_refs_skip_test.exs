# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
defmodule RFD.RefsSkipTest do
  use ExUnit.Case, async: true
  alias Mix.Tasks.Rfd.Refs.Check

  @sw "https://github.com/chibifire-smoke-water/contract-manifest-smoke-water"

  test "a CI run without a token skips the smoke-water manifest" do
    assert Check.skip?(@sw, "true", nil)
    assert Check.skip?(@sw, "true", "")
  end

  test "a CI run with a token checks" do
    refute Check.skip?(@sw, "true", "t")
  end

  test "a run outside CI checks" do
    refute Check.skip?(@sw, nil, nil)
    refute Check.skip?(@sw, "false", "")
  end

  test "another organisation's manifest is checked" do
    refute Check.skip?("https://github.com/V-Sekai-fire/contract-manifest-taskweft", "true", nil)
  end
end

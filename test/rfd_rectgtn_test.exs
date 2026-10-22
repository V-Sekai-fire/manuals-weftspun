# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RfdRectgtnTest do
  use ExUnit.Case, async: false
  alias Mix.Tasks.Rfd.Rectgtn

  @domain Path.join(RFD.Source.repo_root(), "rectgtn/organization.ex")

  setup do
    Mix.shell(Mix.Shell.Process)
    on_exit(fn -> Mix.shell(Mix.Shell.IO) end)
  end

  test "the check passes when every rendered document matches its source" do
    Rectgtn.run(["--check"])
    assert_received {:mix_shell, :info, ["same  " <> _]}
  end

  test "the check fails when a rendered document is missing" do
    body = File.read!(@domain)
    File.rm!(@domain)

    try do
      assert_raise Mix.Error, ~r/1 rectgtn document\(s\) differ/, fn ->
        Rectgtn.run(["--check"])
      end
    after
      File.write!(@domain, body)
    end
  end

  test "the check fails when a rendered document is edited by hand" do
    body = File.read!(@domain)
    File.write!(@domain, body <> "# edited\n")

    try do
      assert_raise Mix.Error, fn -> Rectgtn.run(["--check"]) end
    after
      File.write!(@domain, body)
    end
  end
end

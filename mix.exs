# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT

defmodule RFD.MixProject do
  use Mix.Project

  def project do
    [
      app: :rfd,
      version: "0.2.0",
      elixir: "~> 1.20",
      deps: deps()
    ]
  end

  # Taskweft is an ordinary dependency rather than a manifest checkout (RFD 2292): the
  # organization domain is planned by it, and a planner reached through a sibling
  # directory is a path assumption rather than a version. Scoped to :test because only
  # the plan check needs it, so `mix rfd.render` still runs with nothing fetched.
  defp deps do
    [
      {:taskweft,
       github: "V-Sekai-fire/interactor-taskweft", branch: "main/from-taskweft", only: :test}
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end
end

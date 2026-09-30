# SPDX-License-Identifier: Apache-2.0 OR MIT
for {var, _} <- System.get_env(), String.starts_with?(var, "GIT_"), do: System.delete_env(var)
ExUnit.start()

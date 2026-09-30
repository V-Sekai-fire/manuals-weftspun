# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2073. `mix rfd.render` renders rfd/2073-async-fdb-callback-chain/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2073 do
  use RFD.DSL

  rfd 2073, "Async fdb callback chain" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    ``` create_transaction -> get(district) [async future] ->
    on_district_read [callback: extract next_o_id] -> get(customer) [async
    future] -> on_customer_read [callback: extract discount] ->
    get(stock[0]) [async future] -> on_stock_read [callback: update stock,
    next item] -> ... (loop for 5-15 items) -> set(oorder, new_order,
    order_line[], stock[]) -> commit [async future] -> on_commit
    [callback: send HTTP response] ```
    """

    drafted_by :ai
  end
end

# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2073, "Async fdb callback chain", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  ``` create_transaction -> get(district) [async future] ->
  on_district_read [callback: extract next_o_id] -> get(customer) [async
  future] -> on_customer_read [callback: extract discount] ->
  get(stock[0]) [async future] -> on_stock_read [callback: update stock,
  next item] -> ... (loop for 5-15 items) -> set(oorder, new_order,
  order_line[], stock[]) -> commit [async future] -> on_commit
  [callback: send HTTP response] ```
  """
end

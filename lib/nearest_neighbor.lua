local List = require "lib/list"
local Set = require "lib/set"
local util = require "lib/util"

local range, println = util.range, util.println

local function findNearest(tsp, starting_point_ind, visited)
  local min = 1/0
  local pt = -1
  for i in range(#tsp) do
    local edge_len = tsp[starting_point_ind][i]
    if not visited[i] and edge_len < min and edge_len ~= -1 then
      min = edge_len
      pt = i
    end
  end
  assert(pt ~= -1, "could not find nearest point")
  return pt
end

local function findMinRoute(tsp)
  local route = List()
  local prev = 0
  local visited = {[0]=true}
  for _ in range(#tsp-1) do
    local current = findNearest(tsp, prev, visited)
    route:append(current)
    visited[current] = true
    prev = current
  end
  return route
end

return findMinRoute


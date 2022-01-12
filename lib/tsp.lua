local List = require "lib/list"
local util = require "lib/util"

local range, println = util.range, util.println

-- Usage: tsp(distances[a][b]) --> List(0, 2, 1)
-- input: List of List of distance int (distance between point index 1 and point index 2)
-- output: List of point indices in order of route

local function findMinRoute(tsp)
  local counter = 0
  local j,i = 0,0
  local min = 1/0
  
  local visitedRouteList = List()
  visitedRouteList:append(0)
  local route = List(0)*#tsp
  
  while i < #tsp[0] and 
        j < #tsp[1] do
    
    if counter >= #tsp[0] - 1 then
      break
    end
    
    if (j ~= i) and (not visitedRouteList:contains(j)) then
      if tsp[i][j] < min then
        min = tsp[i][j]
        route[counter] = j + 1
      end
    end
    j = j + 1
    
    if j == #tsp[0] then
      min = 1/0
      visitedRouteList:append(route[counter] - 1)
      
      j = 0
      i = route[counter] - 1
      counter = counter + 1
    end
  end
  
  i = route[counter - 1] - 1
  for j in range(#tsp[0]) do
    if (i ~= j) and (tsp[i][j] < min) then
      min = tsp[i][j]
      route[counter] = j + 1
    end
  end
  
  return visitedRouteList
end

return findMinRoute
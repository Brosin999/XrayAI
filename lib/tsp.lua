local List = require "lib/list"
local util = require "lib/util"

local range, println = util.range, util.println

local function findMinRoute(tsp)
  local sum = 0
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
      sum = sum + min
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
  sum = sum + min
  
  --println("Minimum Cost is: {}", sum)
  --print(visitedRouteList:map(function(num) return num+1 end))
  return visitedRouteList
end


local function main()
  local tsp = List(
    List(-1, 10, 15, 20),
    List(10, -1, 35, 25),
    List(15, 35, -1, 30),
    List(20, 25, 30, -1)
  )
  --print(tsp)
  findMinRoute(tsp)
end

--main()
return findMinRoute
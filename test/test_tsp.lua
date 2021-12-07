local List = require "lib/list"
local tsp = require "lib/tsp"
local util = require "lib/util"
local combinations = require "lib/combinations"

local range, println = util.range, util.println


local function determine_cost(lst, distances)
  local res = lst:slice()
  res:append(res[0])
  local sum = 0
  while #res > 1 do
    local l, r = res:pop(0), res:pop(0)
    sum = sum + distances[l][r]
    res:insert(0, r)
  end
  return sum
end


local function test_simple()
  local dists = List(
    List(-1, 10, 15, 20),
    List(10, -1, 35, 25),
    List(15, 35, -1, 30),
    List(20, 25, 30, -1)
  )
  local res = tsp(dists)
  println("simple example:\n{} costs {}\n", res, determine_cost(res, dists))
end

local function test_moderate()
  local distances = List(
    List(-1,12,10,19,8),
    List(12,-1,3,7,2),
    List(10,3,-1,6,20),
    List(19,7,6,-1,4),
    List(8,2,20,4,-1)
  )

  local alphabet = List("A","B","C","D","E")
  local res = tsp(distances)
  println("moderate example:\n{} costs {}\n", res, determine_cost(res, distances))

  local N = 5
  local combos = combinations(List(range(N)), 4)
  for combo in combos() do
    println("{} costs {}", combo, determine_cost(combo, distances))
  end
end

test_simple()
test_moderate()

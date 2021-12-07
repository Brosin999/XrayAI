local class = require "lib/class"
local List = require "lib/list"
local util = require "lib/util"
local tsp = require "lib/tsp"
local combinations = require "lib/combinations"

local all, range, izip, println, print = util.all, util.range, util.izip, util.println, util.print


local Point = class()

function Point:__init(x,y,z)
  self.x = x
  self.y = y
  self.z = z
end

function Point:__sub(o)
  if self == o then
    return -1
  end
  return math.abs(self.x - o.x) + math.abs(self.y - o.y) + math.abs(self.z - o.z)
end

function Point:__tostring()
  return "("..tostring(self.x)..", "..tostring(self.y)..", "..tostring(self.z)..")"
end


local Edge = class()

function Edge:__init(p1, p2)
  self.p1 = p1
  self.p2 = p2
  self.len = p1-p2
end

function Edge:__lt(o)
  return self.len < o.len
end

function Edge:__le(o)
  return self.len <= o.len
end

function Edge:__eq(o)
  return self.len == o.len
end

function Edge:__tostring()
  local str = ""
  for i in range(self.len/4) do
    str = str .. "-"
  end
  return str
end

local function pathfind(coords)
  local points = coords:map(function(coord) return Point(coord[0], coord[1], coord[2]) end)
  --print(points)
  local N = #points
  --println("after sorting {}", points)
  
  local distances = List:zeroes(N, N)
  for i, p1 in points(true) do
    for j, p2 in points(true) do
      distances[i][j] = p1-p2
    end
  end
  
  --print(distances)
  local route = tsp(distances)
  return route
end
--[[
local coords = List(range(10)):map(function() return Point(math.random(-8,8),math.random(-8,8),math.random(-8,8)) end)


local distances = List:zeroes(10,10)

for i,coord1 in coords(true) do
  for j,coord2 in coords(true) do
    distances[i][j] = coord1-coord2
  end
end
print(coords)
print()
print(distances)
print()
local route = tsp(distances)
print()

for i in route() do
  print(coords[i])
end
print()
local queue = route:slice()
local shuffle = route:slice(1,-1)
print(shuffle)
shuffle:sort(function(a,b) if math.random() < 0.5 then return a>b end return a<b end)
--local queue = route:slice(0,1) + shuffle + route:slice(-1) 


queue:append(route[0])

local sum = 0
while #queue>1 do
  local l, r = queue:pop(0), queue:pop(0)
  local left, right = coords[l], coords[r]
  println("{} --> {} = {}", left, right, left-right)
  sum = sum + (left-right)
  queue:insert(0, r)
end
print(sum)

]]



--print(route:reduce(function(a,b) return a-b end))

--print(List(1,9,6,7,4,2,5,10,3,8):reduce(function(a,b) return coords[a-1]-coords[b-1] end))

--local edges = combinations(coords,2):map(function(tup) return Edge(tup[0],tup[1]) end)
--edges:sort()
--print(edges)
return pathfind
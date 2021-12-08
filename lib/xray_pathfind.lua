local class = require "lib/class"
local List = require "lib/list"
local util = require "lib/util"
local tsp = require "lib/tsp"

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

return pathfind
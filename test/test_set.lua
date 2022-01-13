local class = require "lib/class"
local List = require "lib/list"
local util = require "lib/util"
local pathfind = require "lib/xray_pathfind"
local Set = require "lib/set"

local all, range, print = util.all, util.range, util.print

function makeRandom() 
  return List(math.random(-100,100),math.random(-100,100),math.random(-100,100)) 
end

function make(n) 
  return List(range(n)):map(function(a) return makeRandom() end) 
end


--print(pathfind(make(20)))

function test_simple()
  local set = Set(5,4,3,2,1)

  set:add(7)
  set:pop(5)
  set:add("henry")
  
  for v in List(1,2,3,4,7,"henry")() do
    assert(set:contains(v), "set does not contain "..tostring(v))
  end

  --for val in set() do
    --print(val)
  --end

  --print(set:contains("henry"))


  --print( Set(5,1,2) + Set("henrietta", {}, function() end))
end

test_simple()
--print(pathfind(make(300)))
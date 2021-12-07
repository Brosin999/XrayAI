local List = require "lib/list"
local util = require "lib/util"
local assertEqual, assertRaises, range, zip = util.assertEqual, util.assertRaises, util.range, util.zip

local function test()
  local list = List(3,6,9,12,15)
  local list2 = List(5,10,15,20)
  
  -- length, tostring, concatenate test
  assertEqual(5, #list)
  assertEqual("[3, 6, 9, 12, 15]", tostring(list))
  assertEqual("[3, 6, 9, 12, 15, 5, 10, 15, 20]", tostring(list+list2))
  
  --index test
  assertEqual(3, list[0])
  assertEqual(6, list[1])
  assertEqual(9, list[2])
  assertEqual(12, list[3])
  assertEqual(15, list[4])
  
  -- tables within string test
  local list3 = List("stuff",18,14,"thing", List(3,2,1), {1,2,3})
  assertEqual("[stuff, 18, 14, thing, [3, 2, 1], {1, 2, 3}]", tostring(list3))
  
  -- eq test --
  assertEqual(List(5,10,15,20), list2)
  assertEqual(List(3,6,9,12,15), list)
  
  -- slice test --
  assertEqual(List(3,6,9,12,15), list:slice())
  assertEqual(List(15,12,9,6,3), list:slice(nil,nil,-1))
  assertEqual(List(3,6,9), list:slice(nil, 3))
  assertEqual(List(9,12,15), list:slice(2))
  assertEqual(List(15,12,9,6,3), list:slice(-1,-6,-1))
  
  -- test pop, append, insert
  local list4 = List(9,8,7,6,5)
  list4:append(4)
  assertEqual(4, list4[-1])
  local num = list4:pop()
  assertEqual(4, num)
  assertEqual(List(9,8,7,6,5), list4)
  local num2 = list4:pop(0)
  assertEqual(9, num2)
  assertEqual(List(8,7,6,5), list4)
  list4:insert(0, 9)
  assertEqual(List(9,8,7,6,5), list4)
  list4:insert(5, 9)
  assertEqual(List(9,8,7,6,5,9), list4)
  list4:pop()
  
  -- test out of range and wrong index
  --assertRaises("list key 20 out of range", list4.__index, list4, 20)
  --assertRaises("list key 5 out of range", list4.__index, list4, 5)
  --assertRaises("list key -8 out of range", list4.__index, list4, -8)
  --assertRaises("list key -6 out of range", list4.__index, list4, -6)
  assertRaises("insert(5) takes exactly 2 arguments", list4.insert, 5) -- take exactly 2 arguments
  assertRaises("append(5,1) takes exactly 1 argument", list4.append, 5, 1) 
  
  -- test correct index
  assertEqual(9,list4[-5])
  assertEqual(7,list4[-3])
  
  -- test sorting
  list4:sort()
  assertEqual(List(5,6,7,8,9), list4)
  
  -- test new__index
  list4[2] = 5
  assertEqual(List(5,6,5,8,9), list4)
  
  --test make with iterator
  assertEqual(List(0,1,2,3,4,5,6,7,8,9), List(range(10)))
  --assertEqual(List(List(0,0),List(1,1),List(2,2),List(3,3)), List(zip(range(4),range(4))))
  
  
  local ls = List({name="bird",count=5},{name="air",count=2},{name="diamond",count=5},{name="iron",count=10})
  local thing = ls:find(function(obj) return obj.name=="near" end)
  assertEqual(nil, thing)
  
  local ls2 = List(5,8,6,7,8,9,3,10,2,1,5)

  assertEqual(64,ls2:reduce(function(a,b) return a+b end))
  assertEqual(10,ls2:reduce(function(a,b) if b>a then return b else return a end end))
  assertEqual(List("bird: 5","air: 2","diamond: 5","iron: 10"),(ls:map(function(item) return item.name..": "..tostring(item.count) end)))
  assertEqual(true,ls2:every(function(a) return type(a)=="number" end))
  assertEqual(true,ls:some(function(a) return a.name=="bird" end))
  
  assertEqual(List(0,0,0,0,0), List:zeroes(5))
  assertEqual(List(List(0),List(0)), List:zeroes(2,1))
  assertEqual(List(List(0,0),List(0,0)), List:zeroes(2,2))
  
  for i,v in List(0,1,2,3)(true) do
    assertEqual(v,i)
  end
end

test() -- get just numbers between start stop
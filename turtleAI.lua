-- never gets stuck or lost or runs out of inventory space

-- handle low fuel
-- use gps to determine pos of self

-- continues down the tunnel path
-- stores supplies in basic chests down the tunnel path

-- continually removes cobblestone from inventory (and other trash)


-- turtle full (no empty slots) event -> throw away trash and/or store things away 
-- turtle startup event -> continue or go home
-- turtle low on fuel event -> continue or go home

-- y 15 or y 16 (at least 9 blocks above bedrock)

-- turtles with ender modems? no pearls :(
local class = require "lib/class"
local util = require "lib/util"
local List = require "lib/list"
local turtle = require "cc/turtle"
local pathfind = require "xray_pathfind"

local all = util.all

local TARGET = "ore"
local DEFAULT_RADIUS = 8
local GEOSCAN_SLOT = 16
local CHEST_SLOT = 15
local STORAGE_SLOTS = List(1,2,3,4,5,6,7,8,9,10,11,12,13)

local TRASH = {
  ["minecraft:cobblestone"] = 1,
  ["minecraft:diorite"] = 2,
  ["minecraft:granite"] = 3,
  ["minecraft:andesite"] = 4,
  ["minecraft:dirt"] = 5,
  ["minecraft:gravel"] = 6
}

local DIRECTIONS = {north=1, east=2, south=3, west=4}

local tArgs = {...}
local START_DIR = tArgs[1]
local REPEATS = tArgs[2] or 1

assert(DIRECTIONS[START_DIR], "must specify a direction")


-- startup place ender teleporter underneath (if gps then continue mining)
local function refuel()
  for i in STORAGE_SLOTS() do
    local item = turtle.getItemDetail(i)
    if item and item.name:find("coal") then
      turtle.select(i)
      turtle.refuel()
    end
    if turtle.getFuelLevel() >= 600 then
      return
    end
  end
end

local function tunnel(N)
  for i=1,N do
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.digDown()
  end
end

local function invo_has_empty_slot()
  for i in STORAGE_SLOTS:slice(nil,nil,-1)() do
    if turtle.getItemCount(i) == 0 then
      return true
    end
  end
  return false
end

local function dump_trash(stacks_only)
  for i in STORAGE_SLOTS() do
    local item = turtle.getItemDetail(i)
    if TRASH[item.name] then
      if stacks_only and item.count < 64 then
        
      else
        turtle.select(i)
        turtle.drop(64)
      end
    end
  end
end

local function store_valuables()
  for i in STORAGE_SLOTS() do
    local item = turtle.getItemDetail(i)
    if not TRASH[item.name] then
      turtle.select(i)
      turtle.dropDown(64)
    end
  end
end

local TunnelState = class()
function TunnelState:__init(miner)
  self.miner = miner
end

function TunnelState:act()
  print("TunnelState")
  -- decrement repeats, if repeats is 0 end program
  -- if fuel < 300 refuel all coal until 600
  -- if fuel < 300 (still) end program
  -- tunnel forward 16 blocks
  -- switch to scan state
  
  if turtle.getFuelLevel() < 300 then
    refuel()
    if turtle.getFuelLevel() < 300 then
      error("Out of fuel")
    end
  end
  turtle.turnTo(DIRECTIONS[START_DIR])
  tunnel(16)
  self.miner:change_state("ScanState")
end

local function scan()

end

local ScanState = class()
function ScanState:__init(miner)
  self.miner = miner
end

function ScanState:act()
  print("ScanState")
  -- digDown
  -- placeDown scanner
  -- get scan table
  -- retrieve ore path from scan table
  -- digDown
  -- save coords
  -- switch to xray mine state
  
  turtle.digDown()
  turtle.select(GEOSCAN_SLOT)
  turtle.placeDown()
  self:scan()
  turtle.digDown()
  turtle.reset(0,1,0,START_DIR)
  self.miner:change_state("XrayMineState")
end

function ScanState:scan()
  local blocks = peripheral.call("bottom","scan", DEFAULT_RADIUS)
  blocks = List(all(blocks))
  local ores = blocks
    :filter(function(block) return block.name:find(TARGET) end)
    :map(function(block) return List(block.x, block.y, block.z) end)
  
  ores:sort(function(a,b) return a[2] < b[2] end)
  ores:insert(0, List(0,1,0))
  local route = pathfind(ores):map(function(i) return ores[i] end)
  
  self.miner.ore_path = route
end

local XrayMineState = class()
function XrayMineState:__init(miner)
  self.miner = miner
end

function XrayMineState:act()
  print("XrayMineState")
  -- go to next ore
  -- pop from ore path
  -- if no empty slot dump cobble stacks
  -- if no empty slot (still) switch to refill state
  -- repeat until ore path empty
  -- go back to saved coords (last ore path location)
  -- switch to tunnel state
  
  local target = self.miner.ore_path[-1]
  local func = (#self.miner.ore_path<=1) and turtle.returnTo or turtle.goTo
  func(target[0], target[1], target[2])
  self.miner.ore_path:pop()
  if not invo_has_empty_slot() then
    dump_trash(true)
    if not invo_has_empty_slot() then
      self.miner:change_state("RefillState")
    end
  end
  if #self.miner.ore_path <= 0 then
    self.miner:change_state("TunnelState")
  end
end


local RefillState = class()
function RefillState:__init(miner)
  self.miner = miner
end

local function place_chest()
  local bool,item = turtle.inspectDown()
  if bool and item.name:find("chest") then
    return
  end
  if turtle.getItemCount(CHEST_SLOT) <= 0 then
    error("Out of inventory space")
  end
  turtle.select(CHEST_SLOT)
  turtle.placeDown()
end

function RefillState:act()
  print("RefillState")
  -- return to saved coords
  -- if not chest below
  -- digDown and placeDown chest
  -- dropDown nontrash items
  -- change back to xray state
  turtle.returnTo(0,1,0)
  place_chest()
  store_valuables()
  if #self.miner.ore_path > 0 then
    self.miner:change_state("XrayMineState")
  else
    self.miner:change_state("TunnelState")
  end
end

local STATES = {
  TunnelState = TunnelState,
  ScanState = ScanState,
  XrayMineState = XrayMineState,
  RefillState = RefillState,
}

local Miner = class()
function Miner:__init()
  self.state = TunnelState(self)
  self.ore_path = List()
end

function Miner:act()
  self.state:act()
end

function Miner:change_state(state)
  self.state = STATES[state](self)
end


-- use coroutine to check inventory


turtle.reset(0,1,0,START_DIR)
local miner = Miner()
for _=1,100 do
  miner:act()
  miner:act()
  miner:act()
  miner:act()
  miner:act()
  miner:act()
  miner:act()
  miner:act()
end
print(miner.ore_path)
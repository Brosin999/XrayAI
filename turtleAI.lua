local class = require "lib/class"
local util = require "lib/util"
local List = require "lib/list"
local turtle = require "cc/turtle"
local pathfind = require "lib/xray_pathfind"

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
local REPEATS = tonumber(tArgs[2]) or 1

assert(DIRECTIONS[START_DIR], "must specify a direction")


local function refuel()
  local slot = turtle.getSelectedSlot()
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
  turtle.select(slot)
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
  local slot = turtle.getSelectedSlot()
  for i in STORAGE_SLOTS() do
    local item = turtle.getItemDetail(i)
    if item and TRASH[item.name] then
      if stacks_only and item.count < 64 then
        
      else
        turtle.select(i)
        turtle.drop(64)
      end
    end
  end
  turtle.select(slot)
end

local function store_valuables()
  local slot = turtle.getSelectedSlot()
  for i in STORAGE_SLOTS() do
    local item = turtle.getItemDetail(i)
    if item and not TRASH[item.name] then
      turtle.select(i)
      turtle.dropDown(64)
    end
  end
  turtle.select(slot)
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
  
  
  self.miner.i = self.miner.i + 1
  if self.miner.i > REPEATS then
    error("User specified max mining cycles reached")
  end
  
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
  local bool,block = turtle.inspectDown()
  if bool and block.name:find("chest") then
    return
  end
  local item = turtle.getItemDetail(CHEST_SLOT)
  if (not item) or (not item.name:find("chest")) or (item.count <= 0) then
    error("Out of inventory space")
  end
  turtle.digDown()
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
  dump_trash()
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
  self.i = 0
end

function Miner:act()
  self.state:act()
end

function Miner:change_state(state)
  self.state = STATES[state](self)
end

local function main()
  turtle.reset(0,1,0,START_DIR)
  local miner = Miner()
  while true do
    miner:act()
  end
end

main()
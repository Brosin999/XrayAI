local class = require "lib/class"
local util = require "lib/util"
local List = require "lib/list"
local turtle = require "cc/turtle"
local pathfind = require "lib/xray_pathfind"

local all = util.all

local TARGET = "ore"
local ORE_DICT = {
  -- ## BASE ORES ##
  ["minecraft:iron_ore"] = true,
  ["minecraft:deepslate_iron_ore"] = true,
  ["minecraft:copper_ore"] = true,
  ["minecraft:deepslate_copper_ore"] = true,
  ["minecraft:gold_ore"] = true,
  ["minecraft:deepslate_gold_ore"] = true,
  ["minecraft:diamond_ore"] = true,
  ["minecraft:deepslate_diamond_ore"] = true,
  ["minecraft:coal_ore"] = true,
  ["minecraft:deepslate_coal_ore"] = true,
  ["minecraft:lapis_ore"] = true,
  ["minecraft:deepslate_lapis_ore"] = true,
  ["minecraft:emerald_ore"] = true,
  ["minecraft:deepslate_emerald_ore"] = true,
  ["minecraft:quartz_ore"] = true,
  ["minecraft:nether_quartz_ore"] = true,
  ["minecraft:redstone_ore"] = true,
  ["minecraft:deepslate_redstone_ore"] = true,
  ["minecraft:nether_gold_ore"] = true,
  ["minecraft:ancient_debris"] = true,
  ["minecraft:glowstone"] = true, -- Not technically an ore, but some might consider it worth collecting if we stumble upon it!

  -- ##  MODDED ORES  ##
  -- Create
  ["create:zinc_ore"] = true,
  ["create_deepslate_zinc_ore"] = true,

  -- Mekanism
  ["mekanism:tin_ore"] = true,
  ["mekanism:deepslate_tin_ore"] = true,
  ["mekanism:osmium_ore"] = true,
  ["mekanism:deepslate_osmium_ore"] = true,
  ["mekanism:uranium_ore"] = true,
  ["mekanism:deepslate_uranium_ore"] = true,
  ["mekanism:fluorite_ore"] = true,
  ["mekanism:deepslate_fluorite_ore"] = true,
  ["mekanism:lead_ore"] = true,
  ["mekanism:deepslate_lead_ore"] = true,

  -- Thermal
  ["thermal:apatite_ore"] = true,
  ["thermal:deepslate_apatite_ore"] = true,
  ["thermal:cinnabar_ore"] = true,
  ["thermal:deepslate_cinnabar_ore"] = true,
  ["thermal:niter_ore"] = true,
  ["thermal:deepslate_niter_ore"] = true,
  ["thermal:sulfur_ore"] = true,
  ["thermal:deepslate_sulfur_ore"] = true,
  ["thermal:tin_ore"] = true,
  ["thermal:deepslate_tin_ore"] = true,
  ["thermal:lead_ore"] = true,
  ["thermal:deepslate_lead_ore"] = true,
  ["thermal:silver_ore"] = true,
  ["thermal:deepslate_silver_ore"] = true,
  ["thermal:nickel_ore"] = true,
  ["thermal:deepslate_nickel_ore"] = true,
  ["thermal:ruby_ore"] = true,
  ["thermal:deepslate_ruby_ore"] = true,
  ["thermal:sapphire_ore"] = true,
  ["thermal:deepslate_sapphire_ore"] = true,

  -- -- RFTools-Base
  ["rftoolsbase:dimensionalshard_overworld"] = true,
  ["rftoolsbase:dimensionalshard_nether"] = true,
  ["rftoolsbase:dimensionalshard_end"] = true,

  -- -- Deep Resonance
  ["deepresonance:resonating_ore_stone"] = true,
  ["deepresonance:resonating_ore_deepslate"] = true,
  ["deepresonance:resonating_ore_nether"] = true,
  ["deepresonance:resonating_ore_end"] = true,

  -- ## TINKERS' CONSTRUCT ORES ##
  ["tconstruct:cobalt_ore"] = true,

    -- ## OVERWORLD LOGS ##
  ["minecraft:oak_log"] = true,
  ["minecraft:spruce_log"] = true,
  ["minecraft:birch_log"] = true,
  ["minecraft:jungle_log"] = true,
  ["minecraft:acacia_log"] = true,
  ["minecraft:dark_oak_log"] = true,
  ["minecraft:mangrove_log"] = true,
  ["minecraft:cherry_log"] = true,
  ["minecraft:pale_oak_log"] = true,
}

filters = {
  ["netherite"] = {
    ["minecraft:ancient_debris"] = true,
    ["minecraft:gold_block"] = true,
    -- ## TINKERS' CONSTRUCT ORES ##
    ["tconstruct:cobalt_ore"] = true
  },
  ["diamond"] = {
    ["minecraft:diamond_ore"] = true,
    ["minecraft:deepslate_diamond_ore"] = true
  },
  ["iron"] = {
    ["minecraft:iron_ore"] = true,
    ["minecraft:deepslate_iron_ore"] = true
  },
  ["logs"] = {
    ["minecraft:oak_log"] = true,
    ["minecraft:spruce_log"] = true,
    ["minecraft:birch_log"] = true,
    ["minecraft:jungle_log"] = true,
    ["minecraft:acacia_log"] = true,
    ["minecraft:dark_oak_log"] = true,
    ["minecraft:mangrove_log"] = true,
    ["minecraft:cherry_log"] = true,
    ["minecraft:pale_oak_log"] = true
  },
  ["core"] = {
    ["minecraft:diamond_ore"] = true,
    ["minecraft:deepslate_diamond_ore"] = true,
    ["minecraft:iron_ore"] = true,
    ["minecraft:deepslate_iron_ore"] = true,
    ["mekanism:uranium_ore"] = true,
    ["mekanism:deepslate_uranium_ore"] = true,
    ["minecraft:coal_ore"] = true,
    ["minecraft:deepslate_coal_ore"] = true,
    ["minecraft:gold_ore"] = true,
    ["minecraft:deepslate_gold_ore"] = true,
    ["minecraft:redstone_ore"] = true,
    ["minecraft:deepslate_redstone_ore"] = true
  }
}

local GEOSCAN_SLOT = 16
local CHEST_SLOT = 15
local STORAGE_SLOTS = List(1,2,3,4,5,6,7,8,9,10,11,12,13)
local WAIT_TIME_BEFORE_SCANNING = 3

local TRASH = {
  ["minecraft:cobblestone"] = 1,
  ["minecraft:diorite"] = 2,
  ["minecraft:granite"] = 3,
  ["minecraft:andesite"] = 4,
  ["minecraft:dirt"] = 5,
  ["minecraft:gravel"] = 6,
  ["minecraft:cobbled_deepslate"] = 7,
  ["minecraft:rooted_dirt"] = 8,
  ["minecraft:netherrack"] = 9
}

local DIRECTIONS = {north=1, east=2, south=3, west=4}
local OPPOSITE_DIRECTION = {south=1, west=2, north=3, east=4}

local tArgs = {...}
local START_DIR = tArgs[1]
local REPEATS = tonumber(tArgs[2]) or 1
local DEFAULT_RADIUS = tonumber(tArgs[3]) or 8 
local ADVANCE = true
ORE_DICT = filters[tArgs[4]] or ORE_DICT


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

local function tunnel_minimal(N)
  for i=1,N do
    turtle.dig()
    turtle.forward()
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
    if item and not ORE_DICT[item.name] then
      turtle.select(i)
      turtle.drop(64)
    end
  end
  turtle.select(slot)
end

local function store_valuables()
  local slot = turtle.getSelectedSlot()
  for i in STORAGE_SLOTS() do
    local item = turtle.getItemDetail(i)
    if item and ORE_DICT[item.name] then
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
    turtle.returnTo(0,1,0)
    turtle.turnTo(OPPOSITE_DIRECTION[START_DIR])
    tunnel_minimal(DEFAULT_RADIUS * self.miner.i)
    error("User specified max mining cycles reached")
  end
  
  if turtle.getFuelLevel() < 500 then
    refuel()
    if turtle.getFuelLevel() < 500 then
      turtle.returnTo(0,1,0)
      turtle.turnTo(OPPOSITE_DIRECTION[START_DIR])
      tunnel_minimal(DEFAULT_RADIUS * self.miner.i)
      error("Out of fuel")
    end
  end
  turtle.turnTo(DIRECTIONS[START_DIR])
  if self.miner.i == 1 then
    tunnel(DEFAULT_RADIUS)
  else
    tunnel(DEFAULT_RADIUS * 2)
  end
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
  sleep(WAIT_TIME_BEFORE_SCANNING)
  local blocks = peripheral.call("bottom","scan", DEFAULT_RADIUS)
  blocks = List(all(blocks))
  local ores = blocks
    :filter(function(block) return ORE_DICT[block.name] end)
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
  turtle.turnTo(OPPOSITE_DIRECTION[START_DIR])
  tunnel_minimal(DEFAULT_RADIUS * self.miner.i)
  place_chest()
  store_valuables()
  dump_trash()
  turtle.turnTo(DIRECTIONS[START_DIR])
  tunnel_minimal(DEFAULT_RADIUS * self.miner.i)
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
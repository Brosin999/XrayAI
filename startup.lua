local tArgs = {...}
if tArgs[1] == "uninstall" or tArgs[1] == "update" then
  shell.run("cd lib")
  shell.run("rm *.lua")
  shell.run("cd ..")
  shell.run("rm lib")
  
  shell.run("cd cc")
  shell.run("rm *.lua")
  shell.run("cd ..")
  shell.run("rm cc")
  
  shell.run("rm startup.lua")
  shell.run("rm turtleAI.lua")
  
  if tArgs[1] == "uninstall" then
    error("Uninstall Successful")
  end
end

shell.run("mkdir lib")
shell.run("cd lib")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/class.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/list.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/set.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/tbl.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/tsp.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/util.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/xray_pathfind.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/lib/nearest_neighbor.lua")
shell.run("cd ..")
shell.run("mkdir cc")
shell.run("cd cc")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/cc/turtle.lua")
shell.run("cd ..")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/startup.lua")
shell.run("wget https://raw.githubusercontent.com/GuitarMusashi616/XrayAI/main/turtleAI.lua")


local TRAVEL_ANCHOR_SLOT = 14

turtle.select(TRAVEL_ANCHOR_SLOT)
turtle.digUp()
turtle.placeUp()



local List = require "lib/list"

local function combinations(arr, r)
  local res = List()
  
  function combinationUtil(arr, data, start, stop, index, r)
    if index == r then
      res:append(data:slice())
      return
    end
    
    local i = start
    while i <= stop and stop - 1 + 1 >= r - index do
      data[index] = arr[i]
      combinationUtil(arr, data, i+1, stop, index+1, r)
      i = i + 1
    end
  end
  local data = List(0)*r
  combinationUtil(arr, data, 0, #arr-1, 0, r)
  return res
end

return combinations
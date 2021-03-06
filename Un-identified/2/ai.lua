--Rami's AI--
math.randomseed(os.time())

local origMap = TileMap:cut() --Clone the original map.
local origPX, origPY = 1,1

local netDepth = 2

local function checkNetwork(net,vis)
  local map = origMap:cut() --Clone the map
  local px, py = origPX, origPY
  local travelled = 0
  while true do
    local up = map:cell(px,py-1) or 0
    local down = map:cell(px,py+1) or 0
    local left = map:cell(px-1,py) or 0
    local right = map:cell(px+1,py) or 0
    
    net:activate({math.min(up,1),math.min(right,1),math.min(down,1),math.min(left,1)})
    
    local strongest, strongID = net[netDepth+2].cells[1].signal, 1
    
    for i=2,4 do
      local signal = net[netDepth+2].cells[i].signal
      if signal > strongest then
        strongID = i
        strongest = signal
      end
    end
    
    local dir = strongID-1
    
    local tx, ty,tc --Target
    
    if dir == 0 then --up
      tx,ty,tc = px,py-1, up
    elseif dir == 1 then --right
      tx,ty,tc = px+1,py, right
    elseif dir == 2 then --down
      tx,ty,tc = px,py+1, down
    else --left
      tx,ty,tc = px-1,py, left
    end
    
    if tc == 0 then 
      map:cell(px,py,0)
      map:cell(tx,ty,4)
    else
      map:cell(px,py,0)
      map:cell(tx,ty,2)
      px,py = tx, ty
    end
    
    local dirs = {"up","right","down","left"}
    
    if vis then
      clear(0)
      map:draw(0,8) color(7)
      print("Attempt: "..tostring(vis).." Dir: "..tostring(dirs[dir+1]),2,2)
      sleep(0.01)
    end
    
    if tc == 0 then
      sleep(0.1)
      break --Dead
    elseif tc == 3 then
      sleep(1)
      return -1
    end
  end
  
  return travelled
end

local learningRate = 20 -- between 1 and 100
local attempts = 1000 -- number of times to do backpropagation
local threshold = 8 --steepness of the sigmoid curve
local totalWeights = 4*5 + 5*5 + 1*5 --50

local nn = luann:new({4,5,5,4}, learningRate, threshold)

for i=1,attempts do
 if i % 1 == 0 then
  if checkNetwork(nn,i) < 0 then
    local net = JSON:encode_pretty(nn)
    clipboard(net)
    print("PROBLEM SOLVED !, Net saved to clipboard")
    break
  end
 end
 nn:bp({1,0,0,0},{1,0,0,0})
 nn:bp({0,1,0,0},{0,1,0,0})
 nn:bp({0,0,1,0},{0,0,1,0})
 nn:bp({0,0,0,1},{0,0,0,1})
end

local bitsPerWeight = 10 --0 -> 1023

local function bitToNet(bitstring)
  local fnn = luann:new({4,5,5,1}, learningRate, threshold)
  local iterPos = 1
  local function nextWeight()
    local num = tonumber(bitstring:sub(iterPos,iterPos+bitsPerWeight-1),2)
    if not num then error(iterPos.." > "..tostring(bitstring:sub(iterPos,iterPos+bitsPerWeight-1))) end
    num = (num/1023)*2
    
    iterPos = iterPos + bitsPerWeight
    
    return num
  end
  
  for lid = 2, netDepth+2 do
    local layer = fnn[lid]
    for cid, cell in ipairs(layer.cells) do
      for wid, weight in ipairs(cell.weights) do
        cell.weights[wid] = nextWeight()
      end
    end
  end
  
  return fnn
end

--[[local ga = geneticAlgo(bitsPerWeight * totalWeights, 500, 200)

function ga.fitness(bitstring)
  local fnn = bitToNet(bitstring)
  
  return checkNetwork(fnn) + math.random()
end

local tbinsert = table.insert

function ga.evolve()
  local population = {}
  local bestString = nil
  --cprint("EVOLVE","Initialize")
  -- initialize the popuation random pool
  for i=1, ga.populationSize do
    tbinsert(population, ga.random_bitstring(ga.problemSize))
  end
  -- optimize the population (fixed duration)
  for i=1, ga.maxGenerations do
    --cprint("EVOLVE","New Generation",i)
    --cprint("EVOLVE","Evaluate")
    -- evaluate
    local fitnesses = {}
    for i=1, #population do
      local v = population[i]
      tbinsert(fitnesses, ga.fitness(v))
    end
    --cprint("EVOLVE","Update best")
    -- update best
    bestString = ga.getBest(bestString, population, fitnesses)
    --cprint("EVOLVE","Select")
    -- select
    local tmpPop = ga.selection(population, fitnesses)		
    -- reproduce
    --cprint("EVOLVE","Reproduce")
    population = ga.reproduce(tmpPop)
    --cprint("EVOLVE","display")
    local bnn = bitToNet(bestString)
    checkNetwork(bnn,i)
    --cprint("BEST",checkNetwork(bnn,i))
    --printf(">gen %d, best cost=%d [%s]\n", i, fitness(bestString), bestString)
  end	
  return bestString
end

ga.evolve()]]
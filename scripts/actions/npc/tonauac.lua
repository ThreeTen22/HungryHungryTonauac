function blessPlayer(args, output)
  local seed = math.floor(os.time() / args.rotation)
  math.randomseed(seed)
  
  local blessing = args.blessings[math.random(1,#args.blessings)]
  world.sendEntityMessage(args.entity, "applyStatusEffect", blessing, args.duration, entity.id());
  addFoodEffects(args.entity)
  return true
end

local isTableEmpty = function(tbl)
  for _,_ in pairs(tbl) do
    return false
  end
  return true
end

local copyTable = function(v)
  if type(v) ~= "table" then
    return v
  else
    local c = {}
    for k,v in pairs(v) do
      c[k] = copy(v)
    end
    setmetatable(c, getmetatable(v))
    return c
  end
end

function addFoodEffects(entityId)
  local containerId = world.objectQuery(entity.position(), 15, {callScript = "config.getParameter",callScriptArgs = {"objectType"}, callScriptResult = "container"})
  if containerId then
    containerId = containerId[1]
  else
    return
  end

  local items = world.containerItems(containerId) or {}
  local effectMap = {}
  if not isTableEmpty(items) then
    require "/scripts/augments/item.lua"
  end
  for _,item in pairs(items) do
    if item then
      if item.parameters and item.parameters.timeToRot then
        addEffects(Item.new(item), item.count, effectMap)
      end
    end
  end
  for _,v in pairs(effectMap) do 
      world.sendEntityMessage(entityId, "applyStatusEffect", v.effect, v.duration, entity.id())
  end

  world.containerTakeAll(containerId)
end


function addEffects(item, count, blessingEffects)
  count = count or 1
  count = math.max(count, 1)

  local foodEffects = item:instanceValue("effects.0", {})
  
  for i,effectObj in ipairs(foodEffects) do
    local outputEffect = blessingEffects[effectObj.effect] or copyTable(effectObj)
    if outputEffect.duration then
      outputEffect.duration = math.min(outputEffect.duration + effectObj.duration*count, 86400)
    end
    blessingEffects[outputEffect.effect] = copyTable(outputEffect)
  end
  sb.logInfo("\n%s", sb.printJson(blessingEffects, 1))
end
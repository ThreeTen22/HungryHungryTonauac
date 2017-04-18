function blessPlayer(args, output)
  args = parseArgs(args, {
    entity = nil,
    blessings = {},
    duration = 1800,
    rotation = 86400
  })

  local entityId = BData:getEntity(args.entity)
  local blessings = BData:getList(args.blessings)
  local duration = BData:getNumber(args.duration)
  local rotation = BData:getNumber(args.rotation)
  local seed = math.floor(os.time() / rotation)

  math.randomseed(seed)
  local blessing = blessings[math.random(1,#blessings)]
  world.sendEntityMessage(entityId, "applyStatusEffect", blessing, duration, entity.id());
  addFoodEffects(entityId)
  return true
end

function addFoodEffects(entityId)
  local containerId = world.entityQuery(entity.position(), 15, {includedTypes = {"object"},callScript = "config.getParameter",callScriptArgs = {"objectType"}, callScriptResult = "container"})
  if containerId then
    containerId = containerId[1]
  else
    return
  end

  local items = world.containerItems(containerId) or {}
  local effects = {}

  for i,item in ipairs(items) do
    if item then
      if item.parameters and item.parameters.timeToRot then
        addEffects(item.name, item.count, effects)
      end
    end
  end
  for k,v in pairs(effects) do
    world.sendEntityMessage(entityId, "applyStatusEffect", k, v, entity.id());
  end
  world.containerTakeAll(containerId)
end


--[[
effects parameter :
  {
    effectName: effectDuration
    effectName2: effectDuration
  }
  effects do not last more than 24 hours.  
  effects of the same type provided by other foods will overwrite the duration.
--]]


function addEffects(itemName, count, effects)
  count = count or 1
  count = math.max(count, 1)
  local itemConfig = root.itemConfig(itemName)
  local effectConfig = itemConfig.config.effects or {}
  for i,v in pairs(effectConfig) do
    for k,v in pairs(v) do
      if effects[v.effect] then
       effects[v.effect] = math.min(effects[v.effect] + v.duration*count, 86400)
      else
        effects[v.effect] = math.min(v.duration*count, 86400)
      end
    end
  end
end
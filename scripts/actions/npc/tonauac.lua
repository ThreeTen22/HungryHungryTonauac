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

  local containerId = world.entityQuery(entity.position(), 15, { includedTypes = {"object"},callScript = "config.getParameter",callScriptArgs = {"objectType"}, callScriptResult = "container"})
  containerId = containerId[1]
  local items = world.containerItems(containerId)
  for i = 0, jsize(items) do
    local item = items[i]
    if item.parameters and item.parameters.timeToRot then
      local effect, duration = getEffects(item.name)
    end
  end




  math.randomseed(seed)
  local blessing = blessings[math.random(1,#blessings)]
  world.sendEntityMessage(entityId, "applyStatusEffect", blessing, duration, entity.id());
  return true
end

function getEffects(itemName)
  local effect = nil
  local duration = 0


  return effect, duration
end


function dLog(item, prefix)
  if not prefix then prefix = "" end
  if type(item) ~= "string" then
    sb.logInfo("%s",prefix.."  "..dOut(item))
  else 
    sb.logInfo("%s",prefix.."  "..dOut(item))
  end
end

function dOut(input)
  if not input then input = "" end
  return sb.print(input)
end

function dLogJson(input, prefix, clean)
  local str = "\n"
  if clean == true then clean = 1 else clean = 0 end
  if prefix ~= "true" and prefix ~= "false" and prefix then
    str = prefix..str
  end
   local info = sb.printJson(input, clean)
   sb.logInfo("%s", str..info)
end

function dPrintJson(input)
  local info = sb.printJson(input,1)
  sb.logInfo("%s",info)
  return info
end
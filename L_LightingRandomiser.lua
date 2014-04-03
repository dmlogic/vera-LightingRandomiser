json = require('json')

package.path = '../?.lua;'..package.path

local lrZoneData
local lrSchedule

--[[
  Parses the schedule and sets up timers
  Intended to be run daily at 00:00:00
  ]]
function lrSetupDay()

    lrGetSchedule()

    -- loop schedule
    for k,sched in pairs(lrSchedule) do

        -- Make on and off times
        ontime = lrMakeTime(sched['minOn'],sched['maxOn'])
        offtime = lrMakeTime(sched['minOff'],sched['maxOff'])

        -- Set on timer. "yyyy-mm-dd hh:mm:ss"
        luup.call_timer("lrTurnOn", 4, os.date("%Y-%m-%d %H:%M:%S",ontime), "", sched['zone'])
        luup.log("lrTurnOn "..sched['zone'].." scheduled for "..os.date("%Y-%m-%d %H:%M:%S",ontime),25)

        -- set off timer
        luup.call_timer("lrTurnOff", 4, os.date("%Y-%m-%d %H:%M:%S",offtime), "", sched['zone'])
        luup.log("lrTurnOff "..sched['zone'].." scheduled for "..os.date("%Y-%m-%d %H:%M:%S",offtime),25)

    end

    -- stop back tomorrow
    tomorrow = os.date("%Y-%m-%d 00:00:00",os.time()+86400)
    luup.call_timer("lrSetupDay", 4, tomorrow, "", "")

end

--[[
  Turn on a zone
  ]]
function lrTurnOn(zone)

    luup.log("lrTurnOn "..zone,25)

    lrGetZones()

    for device,settings in pairs(lrZoneData[zone]) do

        luup.log("lrTurnOn device "..device,25)

        if settings["type"] == "dimmer" then
            lrSetDimmer( device,settings["percentage"] )
        else
            lrSetSwitch(device,1)
        end

    end
end

--[[
  Turn off a zone
  ]]
function lrTurnOff(zone)

    luup.log("lrTurnOff "..zone,25)

    lrGetZones()

    for device,settings in pairs(lrZoneData[zone]) do
        lrSetSwitch(device,0)
    end
end

--[[
  Make a randomly between min and max values
  ]]
function lrMakeTime(min,max)

    minBits = lrSplit(min, "[:]+")
    maxBits = lrSplit(max, "[:]+")

    lower = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=minBits[1], min=minBits[2], sec=minBits[3]})
    upper = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=maxBits[1], min=maxBits[2], sec=maxBits[3]})

    diff = upper - lower;

    -- math.randomseed(os.time())
    math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
    return lower + math.random(0,diff)

end

--[[
  String split function. From the Lua wiki
  ]]
function lrSplit(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

--[[
  Zones Getter
  ]]
function lrGetZones()
    if(lrZoneData == nil) then
        -- lrZoneData = lrReadJson(dofile("/etc/cmh-ludl/LightingRandomiser_zones.json"))
        lrSetZones(lrMyZones)
    end

    return lrZoneData
end

function lrSetZones(data)

    lrZoneData = json.decode(data)
end

--[[
  Schedule Getter
  ]]
function lrGetSchedule()
    if(lrSchedule == nil) then
        lrSetSchedule(lrMyScedule)
    end

    return lrSchedule
end

function lrSetSchedule(data)

    lrSchedule = json.decode(data)
end


--[[
  Set a dimmer value
  ]]
function lrSetDimmer( deviceId,value )

    luup.log("lrSetDimmer about to start HandleActionRequest for "..deviceId.." to "..value,25)

    lul_arguments = {}
    lul_arguments["newLoadlevelTarget"] = value
    luup.call_action("urn:upnp-org:serviceId:Dimming1", "SetLoadLevelTarget", lul_arguments,tonumber(deviceId))


end

--[[
  Control a basic on/off switch
  ]]
function lrSetSwitch( deviceId,onoff )

    luup.log("lrSetSwitch "..deviceId.." to "..onoff,25)

    lul_arguments = {}
    lul_arguments["newTargetValue"] = onoff
    luup.call_action("urn:upnp-org:serviceId:SwitchPower1", "SetTarget", lul_arguments,tonumber(deviceId))
end

--[[
    Startup function.
    Receives a map or sets the default
]]
function lrStartup(lul_device)

    luup.task("Running Lua Startup", 1, "LightingRandomiser", -1)

    luup.log("lrStartup",25)

    -- Set the schedule
    lrSetupDay()

end

require('luaunit')

package.path = '../?.lua;'..package.path
require('luup');
require('L_LightingRandomiser')

dofile("../L_LightingRandomiser_zones.sample.lua")
dofile("../L_LightingRandomiser_schedule.sample.lua")

TestCode = {} --class

    function TestCode:testStuff()
    end

    function TestCode:testMakeTime()

        stamp = lrMakeTime('08:01:02','09:45:46')

        startTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=8, min=1, sec=2})
        endTime = os.time({year=os.date('%Y'),month=os.date('%m'),day=os.date('%d'),hour=9, min=45, sec=46})

        assertGreaterThan(stamp,startTime)
        assertLessThan(stamp,endTime)
    end

    function TestCode:testTurnOn()

        lrTurnOn("lounge")

        assertEquals(luup.variable_get("urn:upnp-org:serviceId:Dimming1","newLoadlevelTarget",5),50);
        assertEquals(luup.variable_get("urn:upnp-org:serviceId:SwitchPower1","newTargetValue",6),1);
    end

    function TestCode:testTurnOff()

        lrTurnOn("porch")
        assertEquals(luup.variable_get("urn:upnp-org:serviceId:SwitchPower1","newTargetValue",10),1);

        lrTurnOff("porch")
        assertEquals(luup.variable_get("urn:upnp-org:serviceId:SwitchPower1","newTargetValue",10),0);

    end

    function TestCode:testLoadZones()
        zones = lrGetZones()
        assertEquals(type(zones),'table');
        assertEquals(type(zones["lounge"]),'table');
        assertEquals(type(zones["lounge"]["5"]),'table');
        assertEquals(zones["lounge"]["5"]["type"],'dimmer');
        assertEquals(zones["lounge"]["5"]["percentage"],50);
        assertEquals(type(zones["lounge"]["6"]),'table');
        assertEquals(zones["lounge"]["6"]["type"],'switch');
        assertEquals(type(zones["porch"]),'table');
    end

-- class TestCode

LuaUnit:run()
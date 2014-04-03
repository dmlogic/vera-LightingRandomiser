vera-LightingRandomiser
=======================

Simulates lighting activity in an occupied house

## Configuration

### Zones file

Create `LightingRandomiser_zones.json` based on the sample found in the `tests` folder.

Adjust the file as required for your network. The numeric keys within each zone are the Device IDs that you want to control. Supported `types` are "dimmer" and "switch". For dimmer add a `percentage` integer of between 1 and 100.

### Schedule file

Create `LightingRandomiser_schedule.json` based on the sample found in the `tests` folder.

Adjust the file as required for your network. Each `zone` must relate to a key in your `LightingRandomiser_zones.json` file. Then set min and max On and Off times. These must be full times in `hh:mm:ss` format. Be sure that your `minOff` time is greater than your `maxOn` time.

## Installation

Copy the following files to Vera using the Apps > Develop Apps > Luup files tool.

* D_LightingRandomiser.xml
* I_LightingRandomiser.xml
* L_LightingRandomiser.lua
* LightingRandomiser_zones.json
* LightingRandomiser_schedule.json
* json.lua

Now manually create a new device with a `Upnp Device Filename` of "D_LightingRandomiser.xml".

Enjoy!
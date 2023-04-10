local blocklist = require("src.blockList")
local debug = require("src.lib.debug")

_G.mapWidth = 1500
_G.mapHeight = 300
_G.averageHeight = math.floor(mapHeight / 2)

local mapGen = {}
local map = {}

--local max_offset = 10
--local function generateCurves()

--end

local function generateMap(bl)
    local m = {}
    for y = 1, mapHeight do
        table.insert(m, {})
        for _ = 1, mapWidth do
            if y < averageHeight then
                table.insert(m[y], 0)
            elseif y >= (mapHeight - math.floor(averageHeight / 2)) and y <= mapHeight then
                table.insert(m[y], #bl)
            else
                table.insert(m[y], love.math.random(1, #bl - 1))
            end
        end
    end
    return m
end

function mapGen.WriteMapToFile()
    map = generateMap(blocklist)
    love.filesystem.write("level.lua", "local leveldata = " .. debug.dump(map))
    love.filesystem.append("level.lua", "\nreturn leveldata")
    print("map created")
end

return mapGen

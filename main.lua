local mapGen    = require("src.createMap")
local blockList = require("src.blockList")
local anim8     = require("src.lib.anim8")
local camera    = require("src.lib.camera")

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle("loading the map")
    love.graphics.setDefaultFilter("nearest", "nearest")
    local contents, err = love.filesystem.load("level.lua")
    if err == nil then
        Map = contents()
    else
        mapGen.WriteMapToFile()
        Map = love.filesystem.load("level.lua")()
    end

    _G.player                   = {}
    player.x                    = 1000
    player.y                    = 1780
    _G.cam                      = camera:new()
    --player.img = love.graphics.newImage("res/character.png")
    player.spriteSheet          = love.graphics.newImage("res/hero.png")
    player.grid                 = anim8.newGrid(16, 16, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations           = {}
    player.animations.walkRight = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.walkLeft  = player.animations.walkRight:clone():flipH()
    player.animations.idleRight = anim8.newAnimation(player.grid("1-4", 1), 0.5)
    player.animations.idleLeft  = player.animations.idleRight:clone():flipH()
    player.left                 = false
    player.moving               = false
end

function love.update(dt)
    if love.keyboard.isDown("right") then
        player.moving = true
        player.x = player.x + 150 * dt
        player.left = false
    elseif love.keyboard.isDown("left") then
        player.moving = true
        player.x = player.x - 150 * dt
        player.left = true
    elseif love.keyboard.isDown("up") then
        player.moving = true
        player.y = player.y - 150 * dt
    elseif love.keyboard.isDown("down") then
        player.moving = true
        player.y = player.y + 150 * dt
    else
        player.moving = false
    end

    player.animations.walkRight:update(dt)
    player.animations.walkLeft:update(dt)
    player.animations.idleRight:update(dt)
    player.animations.idleLeft:update(dt)
    cam:lookAt(player.x, player.y)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f11" then
        Fullscreen = not Fullscreen
        love.window.setFullscreen(Fullscreen)
    end

    if key == "escape" then
        love.event.quit()
    end
end

local function drawMap()
    local offset = #Map[1]
    local draw_left = 0
    local draw_right = 0
    if math.floor((player.x + offset) / 16) < #Map then
        draw_right = math.floor((player.x + offset) / 16)
    else
        draw_right = #Map
    end

    if math.floor((player.x - offset) / 16) > 1 then
        draw_left = math.floor((player.x - offset) / 16)
    else
        draw_left = 1
    end

    for line = 1, #Map do
        for col = draw_left, draw_right do
            if Map[line][col] ~= 0 then
                love.graphics.draw(blockList[Map[line][col]], (col - 1) * 16, (line - 1) * 16)
            end
        end
    end
end

function love.draw()
    print(math.floor(#Map / 16), math.floor(player.x / 16))
    love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10, 0, 1.2)
    love.graphics.print("player.x" .. player.x, 10, 30, 0, 1.2)
    love.graphics.print("player.y" .. player.y, 10, 50, 0, 1.2)
    cam:attach()

    if player.left and player.moving then
        player.animations.walkLeft:draw(player.spriteSheet, player.x, player.y, nil, 4, 4, 8, 8)
    elseif player.left and not player.moving then
        player.animations.idleLeft:draw(player.spriteSheet, player.x, player.y, nil, 4, 4, 8, 8)
    elseif not player.left and player.moving then
        player.animations.walkRight:draw(player.spriteSheet, player.x, player.y, nil, 4, 4, 8, 8)
    else
        player.animations.idleRight:draw(player.spriteSheet, player.x, player.y, nil, 4, 4, 8, 8)
    end

    love.graphics.scale(2, 2)
    cam:draw(drawMap)
    cam:detach()
end

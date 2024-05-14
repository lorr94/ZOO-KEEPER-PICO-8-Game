pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--code block 0

-- game variables
local player = { x = 64, y = 64, speed = 2, spriteheadindex = 1, spritebodyindex = 17, framecount = 0, framedelay = 5, lives = 3 }  -- placeholder player
local animals = {}  -- placeholder for animal entities
local collectibles = {}  -- placeholder for collectible items
local obstacles = {}  -- placeholder for obstacles

-- Lives system
local debugGodMode = false  -- Debug flag for god mode

-- obstacle and animal spawner variables
local obstaclespawnrate = 60  -- number of frames between obstacle spawns
local obstaclespawntimer = obstaclespawnrate
local animalspawnrate = 120    -- number of frames between animal spawns
local animalspawntimer = animalspawnrate
local maxanimals = 5  -- maximum number of animals

-- game setup function
function _init()
    -- initialize player
    player.x = 64
    player.y = 64

    -- set up initial game state
    
    
    --debug test
    printh("boot zoo_keeper.")
end

-- update function (called every frame)
function _update()
    -- update player position
    if (not debugGodMode) then  -- Check if not in god mode
    if (btn(0)) then
        player.x = player.x - player.speed  -- move left
        updateplayeranimation()
    end
    if (btn(1)) then
        player.x = player.x + player.speed  -- move right
        updateplayeranimation()
         end
    end

    -- update other game entities
    updateentities()

    -- check for collisions
    checkcollisions()

    -- scroll background
    scrollbackground()

    -- spawn obstacles and animals
    spawnobstacles()
    spawnanimals()
end

-- draw function (called every frame)
function _draw()
    -- draw background
    cls(3)
    -- draw background elements (can be tiles, sprites, etc.)

    -- draw player head
    spr(player.spriteheadindex, player.x, player.y)
    spr(player.spriteheadindex + 1, player.x + 8, player.y) -- offset head sprite

    -- draw player body
    spr(player.spritebodyindex, player.x, player.y + 8) -- offset body sprite
    spr(player.spritebodyindex + 1, player.x + 8, player.y + 8) -- offset body sprite

    -- draw other game entities
    drawentities()

    -- draw hud (score, lives, etc.)
     print("Lives: " .. player.lives, 2, 2, 7)
end

-- function to update entities
function updateentities()
    -- update animal positions, collectibles, and obstacles
    -- you may want to move them, check for collisions, etc.
    updateobstacles()
    updateanimals()
end

-- function to update obstacle positions
function updateobstacles()
    for _, obstacle in pairs(obstacles) do
        obstacle.y = obstacle.y - 2  -- move obstacles upward (adjust speed as needed)

        -- remove off-screen obstacles
        if (obstacle.y < 0) then
            del(obstacles, obstacle)
        end
    end
end

-- function to update animal positions (modified to stand still)
function updateanimals()
    -- animals stand still, so no need for this function
end

-- function to draw entities
function drawentities()
    -- draw animals, collectibles, and obstacles
    -- you may want to use different sprite numbers or draw custom sprites
    for _, animal in pairs(animals) do
        spr(41, animal.x, animal.y)  -- placeholder sprite for animals (using sprite index 4)
    end

    for _, collectible in pairs(collectibles) do
        -- draw collectible sprite at its position
    end

    for _, obstacle in pairs(obstacles) do
        spr(40, obstacle.x, obstacle.y)  -- placeholder sprite for obstacles
    end
end

-- function to spawn obstacles
function spawnobstacles()
    obstaclespawntimer = obstaclespawntimer - 1

    -- check if it's time to spawn a new obstacle
    if (obstaclespawntimer <= 0) then
        -- spawn obstacle at a random x position
        local newobstacle = { x = flr(rnd(128)), y = 128 }
        add(obstacles, newobstacle)

        -- reset the spawn timer
        obstaclespawntimer = obstaclespawnrate
    end
end

-- function to spawn animals (modified to limit the number of animals)
function spawnanimals()
    animalspawntimer = animalspawntimer - 1

    -- check if it's time to spawn a new animal and if the maximum limit is not reached
    if (animalspawntimer <= 0 and #animals < maxanimals) then
        -- spawn animal at a random x position at the top of the screen
        local newanimal = { x = flr(rnd(120)), y = 0 }
        add(animals, newanimal)

        -- reset the spawn timer
        animalspawntimer = animalspawnrate
    end
end

-- function to handle background scrolling
function scrollbackground()
    -- scroll the background vertically based on the game's pace
    -- you can adjust the scrolling speed and add logic for looping backgrounds
end

-- function to check collisions
function checkcollisions()
    -- check player collision with animals, collectibles, and obstacles
    -- implement this similar to the previous code example
    for _, obstacle in pairs(obstacles) do
        if (player.x < obstacle.x + 8 and
            player.x + 8 > obstacle.x and
            player.y < obstacle.y + 8 and
            player.y + 8 > obstacle.y) then
            -- Collision detected with an obstacle
            player.lives = player.lives - 1
            if player.lives <= 0 then
                -- Game over logic can be added here
            end
            -- Remove the obstacle from the game
            del(obstacles, obstacle)
            break  -- Exit the loop after the first collision
        end
    end
end

-- function to update player animation
function updateplayeranimation()
    player.framecount = player.framecount + 1
    if player.framecount >= player.framedelay then
        player.framecount = 0
        if player.spriteheadindex == 1 then
            player.spriteheadindex = 3  -- switch to the second head sprite
            player.spritebodyindex = 19  -- switch to the second torso sprite
        else
            player.spriteheadindex = 1  -- switch back to the first head sprite
            player.spritebodyindex = 17  -- switch back to the first torso sprite
        end
    end
end
-->8
-- code block 1
__gfx__
00000000000009999990000000000999999000000000000000099000000000000000000000000000000000000000000000000000000000000000000000000000
00000000044444444444444004444444444444400000000000444400000000000000000000000000000000000000000000000000000000000000000000000000
00700700000aaaaaaaaaa000000aaaaaaaaaa0000000000099999999000000000000000000000000000000000000000000000000000000000000000000000000
0007700000aaf7cfac7faa0000aaf7cfac7faa00000000000f0ff0f0000000000000000000000000000000000000000000000000000000000000000000000000
00077000000ffffffffff000000ffffffffff000000000000f0ff0f0000000000000000000000000000000000000000000000000000000000000000000000000
007007000000ffffefff00000000ffffefff000000000000f0999900000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000ff000f00000f0000ff0000000000000000f9999f0000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000ff00f0000000f000ff0000000000000000090090f000000000000000000000000000000000000000000000000000000000000000000000000
000000000000f99dd9f000000000f99dd9f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000f099dd90000000000099dd90f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000f0099999000000000009999900f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009999900000000000999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009000900000000000900090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000900000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000999900009999000000000000000000000000000000000000aaaaa000000bb007000700000000000000000000000000000000000000000000000000
00000000444444444444444400000000000000000000000000000000099999990000bb1b00777000000000000000000000000000000000000000000000000000
000000000fc77cf00fc77cf0000000000000000000000000000000000047cfc00000bbb000c7c000000000000000000000000000000000000000000000000000
0000000000ffff0000ffff000000000000000000000000000000000000fff4f090000b0000565750000000000000000000000000000000000000000000000000
00000000f00ff000000ff00f00000000000000000000000000000000000ff0000b000bb000777770000000000000000000000000000000000000000000000000
000000000f9449f00f9449f000000000000000000000000000000000009ff9000b0bb0bb00575750000000000000000000000000000000000000000000000000
000000000099990ff0999900000000000000000000000000000000000f0990f000bbbbbb00757570000000000000000000000000000000000000000000000000
000000000090090000900900000000000000000000000000000000000090090000aa0aa000505050000000000000000000000000000000000000000000000000

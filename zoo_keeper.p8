pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--code block 0

-- Game variables
local player = { 
    x = 64, y = 64, speed = 2, spriteheadindex = 1, spritebodyindex = 17, 
    framecount = 0, framedelay = 5, lives = 3, gameover = false, 
    immune = false, immune_time = 80, flicker_timer = 0  -- Set immune_time to 80 for 2.5 seconds
}
local animals = {}  -- placeholder for animal entities
local collectibles = {}  -- placeholder for collectible items
local obstacles = {}  -- placeholder for obstacles

local powerups = {}

-- Obstacle and animal spawner variables
local obstaclespawnrate = 60  -- number of frames between obstacle spawns
local obstaclespawntimer = obstaclespawnrate
local animalspawnrate = 120    -- number of frames between animal spawns
local animalspawntimer = animalspawnrate
local maxanimals = 5  -- maximum number of animals
local debugmode = false -- debug mode flag

local animalspeed = 1 -- speed at which animals move down
local obstaclespeed = 2 -- speed at which obstacles move up

local healthpoweruprate = 150
local healthpoweruptimer = healthpoweruprate

local restart_timer = 300  -- 10 seconds (30 fps)
local restart_countdown = 0  -- countdown for restart

-- New variables for distance traveled and increment tracking
local distance_traveled = 0
local increment_count = 0
local max_increments = 5

local intensityTrigger = 200
local just_restarted = false

-- Game setup function
function _init()
    restart_game()
    -- Debug test
    printh("Boot zoo_keeper.")
end

-- Draw function (called every frame)
function _draw()
    -- Draw background
    cls(3)
    -- Draw background elements (can be tiles, sprites, etc.)

    if player.gameover then
        print("Game Over", 48, 64, 7)
        print("Restarting in " .. flr(restart_countdown / 30 + 1) .. "s", 36, 80, 7)
        print("Distance: " .. flr(distance_traveled) .. "m", 10, 20, 7) 
        return  -- Skip drawing other elements if the game is over
    end

    -- Draw player head and body with flickering effect if immune
    if not player.immune or player.flicker_timer then
        spr(player.spriteheadindex, player.x, player.y)
        spr(player.spriteheadindex + 1, player.x + 8, player.y) -- Offset head sprite
        spr(player.spritebodyindex, player.x, player.y + 8) -- Offset body sprite
        spr(player.spritebodyindex + 1, player.x + 8, player.y + 8) -- Offset body sprite
        updateplayeranimation()  -- Moved updateplayeranimation() call here
    end

    -- Draw other game entities
    drawentities()

    -- Draw HUD (score, lives, distance traveled)
    print("Lives: " .. player.lives, 10, 10, 7)
    print("Distance: " .. flr(distance_traveled) .. "m", 10, 20, 7)  -- Display distance in meters

    -- Debug mode indicator
    if debugmode then
        print("DEBUG MODE", 10, 30, 8)
    end
end

-- Function to update entities
function updateentities()
    -- Update animal positions, collectibles, and obstacles
    -- You may want to move them, check for collisions, etc.
    updateobstacles()
    updateanimals()
    updatepowerups()
end

-- Function to update obstacle positions
function updateobstacles()
    for _, obstacle in pairs(obstacles) do
        obstacle.y = obstacle.y - obstaclespeed  -- Move obstacles upward (adjust speed as needed)

        -- Remove off-screen obstacles
        if (obstacle.y < 0) then
            del(obstacles, obstacle)
        end
    end
end

function updateanimals()
    for _, animal in pairs(animals) do
        
        printh("animal before speed: "..animal.y)
        animal.y = animal.y + animalspeed  -- Move animals down slowly
        printh("animal after speed: "..animal.y)
        -- Animate animal
        animal.framecount = (animal.framecount + 1)
        if animal.framecount >= animal.framedelay then
            animal.framecount = 0
            animal.animphase = not animal.animphase  -- Toggle animation phase
        end

        -- Remove off-screen animals
        if (animal.y > 135) then
            del(animals, animal)
            maxanimals = maxanimals + 1
            printh("maxanimals is" .. maxanimals)
        end
    end
end

function updatepowerups()
    for _, powerup in pairs(powerups) do
        powerup.y = powerup.y - 2
        if (powerup.y < 0) then
            del(powerups, powerup)
        end
    end
end

-- Function to draw entities
function drawentities()
    -- Draw animals, collectibles, and obstacles
    for _, animal in pairs(animals) do
        local sprites = animal.animphase and animal.sprites1 or animal.sprites2
        spr(sprites[1], animal.x, animal.y)
        spr(sprites[2], animal.x + 8, animal.y)
        spr(sprites[3], animal.x, animal.y + 8)
        spr(sprites[4], animal.x + 8, animal.y + 8)
    end

    for _, collectible in pairs(collectibles) do
        -- Draw collectible sprite at its position
    end

    for _, obstacle in pairs(obstacles) do
        spr(40, obstacle.x, obstacle.y)  -- Placeholder sprite for obstacles (using sprite index 40)
    end

    for _, powerup in pairs(powerups) do
        spr(12, powerup.x, powerup.y)
    end
end

-- Function to spawn obstacles
function spawnobstacles()
    obstaclespawntimer = obstaclespawntimer - 1

    -- Check if it's time to spawn a new obstacle
    if (obstaclespawntimer <= 0) then
        -- Spawn obstacle at a random x position
        local newobstacle = { x = flr(rnd(128)), y = 128 }
        add(obstacles, newobstacle)

        -- Reset the spawn timer
        obstaclespawntimer = obstaclespawnrate
    end
end

-- Function to spawn animals (modified to limit the number of animals)
function spawnanimals()
    animalspawntimer = animalspawntimer - 1

    -- Check if it's time to spawn a new animal and if the maximum limit is not reached
    if (animalspawntimer <= 0 and #animals < maxanimals) then
        -- Spawn animal at a random x position at the top of the screen
        local newanimal = {
            x = flr(rnd(120)),
            y = 0,
            sprites1 = {44, 45, 60, 61}, -- First set of sprites
            sprites2 = {46, 47, 62, 63}, -- Second set of sprites
            animphase = false, -- Animation phase to toggle between sets
            framecount = 0,
            framedelay = 5 -- Adjust as needed for animation speed
        }
        add(animals, newanimal)

        -- Reset the spawn timer
        animalspawntimer = animalspawnrate
    end
end

-- Function to handle background scrolling
function scrollbackground()
    -- Scroll the background vertically based on the game's pace
    -- You can adjust the scrolling speed and add logic for looping backgrounds
end

function spawnhealthpowerup()
    healthpoweruptimer = healthpoweruptimer - 1

    if (healthpoweruptimer <= 0) then
        local newhealthpowerup = { x = flr(rnd(128)), y = 128 }
        add(powerups, newhealthpowerup)

        healthpoweruptimer = healthpoweruprate
    end
end

-- Function to update player animation
function updateplayeranimation()
    player.framecount = player.framecount + 1
    if player.framecount >= player.framedelay then
        player.framecount = 0
        if player.spriteheadindex == 1 then
            player.spriteheadindex = 3  -- Switch to the second head sprite
            player.spritebodyindex = 19  -- Switch to the second torso sprite
        else
            player.spriteheadindex = 1  -- Switch back to the first head sprite
            player.spritebodyindex = 17  -- Switch back to the first torso sprite
        end

        -- Increment distance traveled
        distance_traveled = distance_traveled + 1

      
    end
end

-- Function to restart the game
function restart_game()
    distance_traveled = 0
    healthpoweruptimer = healthpoweruprate
    obstaclespawntimer = obstaclespawnrate
    animalspawntimer = animalspawnrate
    maxanimals = 5
    animalspeed = 1
    obstaclespeed = 2
    restart_countdown = 0
    increment_count = 0
    intensityTrigger = 200
    player.x = 64
    player.y = 64
    player.lives = 3
    player.gameover = false
    player.immune = false
    player.immune_time = 80
    player.flicker_timer = 0
    player.framecount = 0
    player.spriteheadindex = 1
    player.spritebodyindex = 17
    animals = {}
    collectibles = {}
    obstacles = {}
    powerups = {}
    just_restarted = true  -- Indicate that the game has just been restarted

    printh("distance reset to " .. distance_traveled)
    printh("animal speed reset to " .. animalspeed)
    printh("obstacle speed reset to " .. obstaclespeed)
end

-->8
-- code block 1

-- Update function (called every frame)
function _update()
    -- Toggle debug mode with key press (e.g., key 5)
    if (btnp(5)) then
        debugmode = not debugmode
    end

    if player.gameover then
        restart_countdown = restart_countdown - 1
        if restart_countdown <= 0 then
            restart_game()
        end
        return  -- Skip updating if the game is over
    end

    -- Update player position
    if (btn(0)) then
        player.x = player.x - player.speed  -- Move left
    end
    if (btn(1)) then
        player.x = player.x + player.speed  -- Move right
    end

    -- Enforce player boundaries
    if player.x < 0 then
        player.x = 0
    end
    if player.x > 112 then
        player.x = 112
    end

    -- Update other game entities
    updateentities()

    -- Check for collisions
    checkcollisions()

    -- Scroll background
    scrollbackground()

    -- Spawn obstacles and animals
    spawnobstacles()
    spawnanimals()
    spawnhealthpowerup()

    -- Handle immunity and flickering
    if player.immune then
        player.immune_time = player.immune_time - 1
        if player.immune_time % 10 == 0 then
            player.flicker_timer = not player.flicker_timer  -- Toggle flicker timer
        end
        if player.immune_time <= 0 then
            player.immune = false
            player.flicker_timer = 0
        end
    end

    -- Increment speed and spawn rate every 1000 meters
    if distance_traveled == intensityTrigger and increment_count < max_increments then
        if not just_restarted then  -- Only increment if the game hasn't just been restarted
            increment_count = increment_count + 1
            animalspeed = animalspeed + 0.5
            obstaclespeed = obstaclespeed + 0.5
            animalspawnrate = max(animalspawnrate - 10, 30)
            obstaclespawnrate = max(obstaclespawnrate - 10, 30)
            maxanimals = maxanimals + 1
            intensityTrigger = intensityTrigger * 2
        end
    end

    -- Reset the just_restarted flag after the first frame
    just_restarted = false
end

-- Function to check collisions
function checkcollisions()
    -- Check player collision with obstacles
    if not player.immune then
        for _, obstacle in pairs(obstacles) do
            if (player.x < obstacle.x + 8 and
                player.x + 8 > obstacle.x and
                player.y < obstacle.y + 8 and
                player.y + 8 > obstacle.y) then
                -- Collision detected with an obstacle
                if not debugmode then
                    player.lives = player.lives - 1
                    player.immune = true
                    player.immune_time = 80  -- Set immune time to 80 for 2.5 seconds
                end
                if player.lives <= 0 then
                    player.gameover = true
                    restart_countdown = restart_timer
                end
                -- Move player up by the height of the player character (16 pixels)
                player.y = player.y - 16
                -- Ensure the player doesn't move out of the screen bounds
                if player.y < 0 then
                    player.y = 0
                end
                -- Remove the obstacle from the game
                del(obstacles, obstacle)
                break  -- Exit the loop after the first collision
            end
        end
    end

    -- Check player collision with animals
    if not player.immune then
        for _, animal in pairs(animals) do
            if (player.x < animal.x + 8 and
                player.x + 8 > animal.x and
                player.y < animal.y + 8 and
                player.y + 8 > animal.y) then
                -- Collision detected with an animal
                if not debugmode then
                    player.lives = 0
                end
                if player.lives <= 0 then
                    player.gameover = true
                    restart_countdown = restart_timer
                end
                break  -- Exit the loop after the first collision
            end
        end
    end

    -- Check player collision with powerups
    for _, powerup in pairs(powerups) do
        if (player.x < powerup.x + 8 and
            player.x + 8 > powerup.x and
            player.y < powerup.y + 8 and
            player.y + 8 > powerup.y) then
            -- Collision detected with a health powerup
            if player.lives < 3 then
                player.lives = player.lives + 1
            end
            del(powerups, powerup)
        end
    end
end


__gfx__
00000000000009999990000000000999999000000000000000099000000000000000000000000000000000000000000000000000667766000667766000000000
00000000044444444444444004444444444444400000000000444400000000000000000000000000000000000000000000004440777777000777777000000000
00700700000aaaaaaaaaa000000aaaaaaaaaa0000000000099999999000000000000000000000000000000000000000000044440667766000667766000000000
0007700000aaf7cfac7faa0000aaf7cfac7faa00000000000f0ff0f0000000000000000000000000000000000000000000044440777777000777777000000000
00077000000ffffffffff000000ffffffffff000000000000f0ff0f0000000000000000000000000000000000000000000044400667766000667766000000000
007007000000ffffefff00000000ffffefff000000000000f0999900000000000000000000000000000000000000000000700000777777000777777000000000
000000000000000ff000f00000f0000ff0000000000000000f9999f0000000000000000000000000000000000000000077000000670076000670076000000000
000000000000000ff00f0000000f000ff0000000000000000090090f0000000000000000000000000000000000000000070000006c77c60006c77c6000000000
000000000000f99dd9f000000000f99dd9f000000000000000000000000000000000000000000000000000000000000000000000757757000757757000000000
00000000000f099dd90000000000099dd90f00000000000000000000000000000000000000000000000000000000000000000000600006000000000000000000
0000000000f0099999000000000009999900f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009999900000000000999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000009000900000000000900090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000900000000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000999900009999000000000000000000000000000000000000aaaaa000000bb007000700000000000000000000000676667600000000676667600000
00000000444444444444444400000000000000000000000000000000099999990000bb1b00777000000000000000000000000777777700000000777777700000
000000000fc77cf00fc77cf0000000000000000000000000000000000047cfc00000bbb000c7c000000000000000000000000766666700000000766666700000
0000000000ffff0000ffff000000000000000000000000000000000000fff4f090000b0000565750000000000000000000000077777000000000077777000000
00000000f00ff000000ff00f00000000000000000000000000000000000ff0000b000bb000777770000000000000000000000066666000000000066666000000
000000000f9449f00f9449f000000000000000000000000000000000009ff9000b0bb0bb00575750000000000000000000000077777000000000077777000000
000000000099990ff0999900000000000000000000000000000000000f0990f000bbbbbb00757570000000000000000000000066666000000000066666000000
000000000090090000900900000000000000000000000000000000000090090000aa0aa000505050000000000000000000000067776500000000567776000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000075557600000000675557000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000065556700000000765556000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000676767600000000676767600000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000076c7c600000000006c7c6700000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000767776000000000067776700000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000605550000000000005550600000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000500000000000000000000500000

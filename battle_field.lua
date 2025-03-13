system.activate( "multitouch" )

local composer = require( "composer" )
local widget = require( "widget" )
local movieclip = require("movieclip")
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0)

local scene = composer.newScene()

math.randomseed(os.time())

-- set each difficulty's value
dif_start_score = {500, 0, 0, 0}                -- starting score(coin)
dif_score = {100, 80, 60, 50}                   -- kill 1 monster receive score
dif_hp = {99, 30, 10, 3}                        -- player max hp
dif_skill_cost = {2000, 2000, 3000, 4000}       -- "level 1" cost ("level 2" cost twice)
dif_ultimate_cost = {7000, 8000, 16000, 32000}  -- "level 3" cost
dif_ultra_cost = {30000, 50000, 80000, 100000}  -- real "ultimate" cost
dif_monster_plus_speed = {0, 0, 1, 1}           -- monster: random(1~3) + plus_speed; boss: 6 + plus_speed
dif_boss_comingTimeDelay = {30, 30, 45, 60}     -- boss coming after ? seconds
dif_killBoss_reward = {1000, 2000, 4000, 8000}  -- kill boss receive 3000 score(coin)
dif_boss_maxHp = {10, 10, 20, 20}               -- boss max hp
dif_skill_time = {12, 12, 15, 18}               -- "level 1","level 2" skill duration (seconds)
dif_ultimate_time = {12, 12, 12, 20}            -- "level 3" skill duration (seconds)

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view
    
    -- set background
    bg = {
        display.newImageRect("images/bg_field2.jpg", screenWidth*2, screenHeight*2),
        display.newImageRect("images/bg_field2.jpg", screenWidth*2, screenHeight*2),
        display.newImageRect("images/bg_field2.jpg", screenWidth*2, screenHeight*2),
        display.newImageRect("images/bg_field2.jpg", screenWidth*2, screenHeight*2)
    }
    
    for i = 1, 2 do
        for j = 1, 2 do
            bg[(i-1)*2+j].x = display.contentCenterX + screenWidth*(j*2-3)
            bg[(i-1)*2+j].y = display.contentCenterY + screenHeight*(i*2-3)
            bg[(i-1)*2+j]:toBack()
            bg[(i-1)*2+j].alpha = 0.5
            sceneGroup:insert(bg[(i-1)*2+j])
        end
    end
    
    -- set score (coin)
    coin = display.newImageRect("images/coin.png", screenHeight*0.08, screenHeight*0.1)
    coin.x = display.contentCenterX-screenWidth*0.4; coin.y = display.contentCenterY-screenHeight*0.4
    sceneGroup:insert(coin)
    
    score = dif_start_score[difficulty]
    scoreShow = display.newText(score, display.contentCenterX-screenWidth*0.25, display.contentCenterY-screenHeight*0.375, "Silver.ttf", 48)
    scoreShow:setTextColor(0.7, 0.6, 0)
    sceneGroup:insert(scoreShow)
    
    -- set hp (heart)
    hp_heart = display.newImageRect("images/hp_heart.png", screenHeight*0.1, screenHeight*0.1)
    hp_heart.x = display.contentCenterX+screenWidth*0.05; hp_heart.y = display.contentCenterY-screenHeight*0.4
    sceneGroup:insert(hp_heart)
    
    hp_max = dif_hp[difficulty]
    hp = hp_max
    hpShow = display.newText(hp.."/"..hp_max, display.contentCenterX+screenWidth*0.2, display.contentCenterY-screenHeight*0.375, "Silver.ttf", 48)
    hpShow:setTextColor(1, 0.3, 0.3)
    sceneGroup:insert(hpShow)
    
    -- set monster
    monster_number = 23
    monsterName = {"images/slime.png", "images/blackie.png", "images/mushroom.png", "images/wizard.png", "images/flying.png", "images/eyeball.png", "images/snake.png", "images/giant.png"}
    
    -- set sound
    boom = {} -- monster hit player
    doom = {} -- weapon hit monster
    mDieSound = {"images/blood.ogg", "images/monster_die.mp3"}
    for i=1, monster_number do
        doom[i]= audio.loadStream(mDieSound[math.random(1,2)])
        --audio.setVolume(0.5, { channel = i })
    end
    
    bgm = audio.loadStream("images/gamingBGM.mp3")
    local playBGM = function()
        audio.play(bgm,{channel=31,loops=-1})
    end
    timer.performWithDelay(7000, playBGM)
    
    die = audio.loadStream("images/manDie.mp3")
    
    boom = {"images/boom.mp3", "images/boom2.mp3", "images/boom3.mp3", "images/boom4.mp3","images/boom5.mp3", "images/boom6.mp3"}
    
    -- set pause
    pause = 0
    
    -- set boss get hit or not
    isBossBeHit = 0
    
    -- set skill
    skill_cost = dif_skill_cost[difficulty]
    ultimate_cost = dif_ultimate_cost[difficulty]
    ultra_cost = dif_ultra_cost[difficulty]

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
end


-- "scene:show()"
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is still off screen (but is about to come on screen)
        
    elseif ( phase == "did" ) then
        -- Called when the scene is now on screen
        -- Insert code here to make the scene come alive
        -- Example: start timers, begin animation, play audio, etc.
        
        -- start sound
        audio.play(ritual, {channel=32, loops=0})
        
        -- joystick --------------------------------------------------------------
        
        -- init
        local playerImg = display.newImageRect("images/player.png", screenHeight*0.15, screenHeight*0.15)
        playerImg.x = display.contentCenterX; playerImg.y = display.contentCenterY
        physics.addBody(playerImg, "static", { density=1, friction=0.3, bounce=0.2, radius=screenHeight*0.075 })
        playerImg.alpha = 0
        playerImg.myName = "player"
        sceneGroup:insert(playerImg)
        
        -- set player anime
        player = movieclip.newAnim(
                {"images/player_left.png","images/player_left.png","images/player.png","images/player.png",
                 "images/player_handR.png","images/player_handR.png","images/player_hand.png","images/player_hand.png",
                 "images/player_left.png","images/player_left.png","images/player.png","images/player.png",
                 "images/player_handR.png","images/player_handR.png","images/player_hand.png","images/player_hand.png",})
        player:play({startFrame=1,endFrame=16,loop=-1,remove=true})
        player.x, player.y = display.contentCenterX, display.contentCenterY --位置
        player.width = playerImg.width
        player.height = playerImg.height
        player:stopAtFrame(4)
        player:setDrag{drag=false} --拖曳移動物件
        
        local blood = display.newImageRect("images/blood.png", screenHeight*0.1, screenHeight*0.2)
        blood.x = display.contentCenterX; blood.y = display.contentCenterY
        blood.alpha = 0
        sceneGroup:insert(blood)
        
        local isWalk = 0
        local player_speed = 10
        
        local direct_base = display.newImageRect("images/joystick_base.png", screenHeight*0.3, screenHeight*0.3)
        direct_base.x = display.contentCenterX-screenWidth*0.5+screenHeight*0.1; direct_base.y = display.contentCenterY+screenHeight*0.3
        direct_base.alpha = 0.5
        sceneGroup:insert(direct_base)
        
        local joystick = display.newImageRect("images/joystick.png", screenHeight*0.3, screenHeight*0.3)
        joystick.x = direct_base.x; joystick.y = direct_base.y
        sceneGroup:insert(joystick)
        
        local touchArea = display.newRect(display.contentCenterX-screenWidth*0.4, display.contentCenterY, screenWidth*0.9, screenHeight*1.6)
        touchArea:setFillColor(1, 0, 0, 0)  -- 設定矩形的填充顏色（紅色，透明度0）
        touchArea.isHitTestable = true  -- 確保這個矩形能夠接收觸摸事件
        sceneGroup:insert(touchArea)
        
        timerGroup = {}
        
        local lr = 1 -- left=-1 or right=1
        local degree = 0
        -- init end ------
        
        -- set joystick
        local function direct_Touch(event)
            local phase = event.phase
            
            if (pause==0) then
                -- func --
                local set_degree = function()
                    if (event.x-direct_base.x == 0) then
                        if(event.y > direct_base.y) then
                            return math.rad(90)
                        else
                            return math.rad(-90)
                        end
                    else
                        return math.atan((event.y-direct_base.y)/(event.x-direct_base.x))
                    end
                end
                
                -- reset position (if put-off or out-of-screen-range)
                local is_Touch_Ended_Or_Cancelled = (phase == "ended" or phase == "cancelled")
                local X_is_Outside_Range = (event.x > display.contentCenterX or event.x < display.contentCenterX - screenWidth * 0.8)
                local Y_is_Outside_Range = (event.y > display.contentCenterY + screenHeight * 0.7 or event.y < display.contentCenterY - screenHeight * 0.7)
                
                if is_Touch_Ended_Or_Cancelled or X_is_Outside_Range or Y_is_Outside_Range then
                    joystick.x = direct_base.x
                    joystick.y = direct_base.y
                
                -- set joystick's position --
                elseif (phase == "began" or phase == "moved") then
                    local distance = math.sqrt((event.x - direct_base.x)^2 + (event.y - direct_base.y)^2)
                    if (distance < screenHeight*0.1) then
                        joystick.x = event.x
                        joystick.y = event.y
                    else
                        degree = set_degree()
                        if (event.x > direct_base.x) then lr=1 else lr=-1 end  -- set move left or right
                        joystick.x = direct_base.x + math.cos(degree) * lr * screenHeight*0.1
                        joystick.y = direct_base.y + math.sin(degree) * lr * screenHeight*0.1
                    end
                end
            end
            
            return true
        end
        
        -- add listener to set joystick
        touchArea:addEventListener("touch", direct_Touch)
        
        
        -- keyboard control --
        local isPress = {0, 0, 0, 0} -- wasd is press or not
        
        -- func (key press) --
        local function keyPress(event)
            if(pause == 0) then
                local deg_tmp = 0
                local keyMove = 1
                
                if event.phase == "down" then
                   
                    if event.keyName == "w" then
                        isPress[1] = 1
                    elseif event.keyName == "a" then
                        isPress[2] = 1
                    elseif event.keyName == "s" then
                        isPress[3] = 1
                    elseif event.keyName == "d" then
                        isPress[4] = 1
                    end
                end
                if event.phase == "up" then
                
                    if event.keyName == "w" then
                        isPress[1] = 0
                    elseif event.keyName == "a" then
                        isPress[2] = 0
                    elseif event.keyName == "s" then
                        isPress[3] = 0
                    elseif event.keyName == "d" then
                        isPress[4] = 0
                    end
                end
                
                -- wasd (direction control)
                if (isPress[1] == 1 and isPress[3] == 0) then
                    if (isPress[2] == 1 and isPress[4] == 0) then -- wa
                        degree = math.rad(45)
                        lr = -1
                    elseif (isPress[4] == 1 and isPress[2] == 0) then -- wd
                        degree = math.rad(-45)
                        lr = 1
                    else -- w
                        degree = math.rad(-90)
                        lr = 1
                    end
                elseif (isPress[2] == 1 and isPress[4] == 0) then
                    if (isPress[3] == 1 and isPress[1] == 0) then -- as
                        degree = math.rad(-45)
                        lr = -1
                    else -- a
                        degree = math.rad(0)
                        lr = -1
                    end
                    deg_tmp = deg_tmp + math.rad(-90)
                elseif (isPress[3] == 1 and isPress[1] == 0) then
                    if (isPress[4] == 1 and isPress[2] == 0) then -- sd
                        degree = math.rad(45)
                        lr = 1
                    else -- s
                        degree = math.rad(90)
                        lr = 1
                    end
                elseif (isPress[4] == 1 and isPress[2] == 0) then
                    degree = math.rad(0)
                    lr = 1
                else
                    keyMove = 0
                end
                
                -- set joystick position
                if (keyMove == 1 and joystick.x) then
                    joystick.x = direct_base.x + math.cos(degree) * lr * screenHeight*0.1
                    joystick.y = direct_base.y + math.sin(degree) * lr * screenHeight*0.1
                else
                    joystick.x = direct_base.x
                    joystick.y = direct_base.y
                end
            else
                for i=1, 4 do
                    isPress[i] = 0
                end
            end
            
            return true
        end
        
        -- see if key press
        Runtime:addEventListener("key", keyPress)
--        timerGroup[7] = timer.performWithDelay(30, myTimerListener, 0)
        -- joystick end -----------------------------------------------------------
        
        
        -- player (background) moving ----------------------------------------------------------
        local isMove = 0
        
        local function player_move()
            
            if (pause==0 and joystick.x) then
                for i=1,4 do
                    bg[i].x = bg[i].x - (joystick.x - direct_base.x)/(screenHeight*0.1)*player_speed
                    bg[i].y = bg[i].y - (joystick.y - direct_base.y)/(screenHeight*0.1)*player_speed
                    
                    -- set x -- if out of bounds
                    if (bg[i].x >= display.contentCenterX + screenWidth * 2) then
                        bg[i].x = bg[i].x - screenWidth * 4
                    elseif (bg[i].x < display.contentCenterX - screenWidth * 2) then
                        bg[i].x = bg[i].x + screenWidth * 4
                    end
                    -- set y
                    if (bg[i].y >= display.contentCenterY + screenHeight * 2) then
                        bg[i].y = bg[i].y - screenHeight * 4
                    elseif (bg[i].y < display.contentCenterY - screenHeight * 2) then
                        bg[i].y = bg[i].y + screenHeight * 4
                    end
                end
                
                --change player direction
                if(math.deg(degree) ~= 90 and math.deg(degree) ~= -90) then
                    if (joystick.x < direct_base.x) then
                        player.xScale = -1
                        player.width = screenHeight * 0.15
                    else 
                        player.xScale = 1
                        player.width = screenHeight * 0.15
                    end
                end
                
                -- play walking
                if (math.sqrt((joystick.x - direct_base.x)^2 + (joystick.y - direct_base.y)^2) ~= 0) then
                    audio.play(walking,{channel=25, loops=0})
                    if (isWalk == 0) then
                        isWalk = 1
                        player:playAtFrame(player:currentFrame())
                    end
                else
                    if (isWalk == 1) then
                        isWalk = 0
                        player:stopAtFrame(4)
                    end
                end
            
            elseif (player and hp > 0) then
                isWalk = 0
                player:stopAtFrame(4)
            end
                
        end
        
        -- add timer to move player
        timerGroup[1] = timer.performWithDelay(10, player_move, 0)  -- 第三個參數 0 表示無限次執行
        -- player (background) moving end ------------------------------------------------------
        
        
        -- skill -------------------------------------------------
        
        -- init
        local skillA = display.newImageRect("images/skill_btn1.png", screenHeight*0.2, screenHeight*0.2)
        skillA.x = display.contentCenterX + screenWidth * 0.5 - screenHeight * 0.1
        skillA.y = display.contentCenterY + screenHeight * 0.35
        skillA.isVisible = false
        sceneGroup:insert(skillA)
        
        local skillB = display.newImageRect("images/skill_btn2.png", screenHeight*0.2, screenHeight*0.2)
        skillB.x = display.contentCenterX + screenWidth * 0.5 - screenHeight * 0.1
        skillB.y = display.contentCenterY + screenHeight * 0.35
        skillB.isVisible = false
        sceneGroup:insert(skillB)
        
        local skill_num = 0 -- to change skill button img
        local skill_time = 0 -- if using skill
        
        -- func (button change) --
        local function skill_img_change()
            if (pause == 0) then
            
                -- change image
                if (score >= skill_cost and skill_time == 0) then
                    if (skill_num == 1) then
                        skill_num = 2
                        skillA.isVisible = false
                        skillB.isVisible = true
                    else
                        skill_num = 1
                        skillA.isVisible = true
                        skillB.isVisible = false
                    end
                end
                
            end
        end
        
        -- set timer to change skill button's imaage
        timerGroup[2] = timer.performWithDelay(200, skill_img_change, 0)
        -- skill end ---------------------------------------------
        
        
        -- create weapon ----------------------------------------------------------------
        
        -- init --
        local weapon_wind = display.newImageRect("images/sword_wind.png", screenHeight*0.3, screenHeight*0.3)
        weapon_wind.alpha = 0
        sceneGroup:insert(weapon_wind)
        
        local weapon = display.newImageRect("images/sword.png", screenHeight*0.3, screenHeight*0.1)
        weapon_degree = 45
        weapon.myName = "weapon"
        player:toFront()
        sceneGroup:insert(weapon)
        
        local attackArea = display.newRect(display.contentCenterX+screenWidth*0.5, display.contentCenterY, screenWidth*0.9, screenHeight*1.2)
        attackArea:setFillColor(1, 0, 0, 0)  -- 設定矩形的填充顏色（紅色，透明度0）
        attackArea.isHitTestable = true  -- 確保這個矩形能夠接收觸摸事件
        sceneGroup:insert(attackArea)
        
        local attack = 0  -- judge if attack(ing) or not
        local circle_posX, circle_posY, deg_atk
        local atk_speed = -5
        local increase = 1 -- speed increase or not
        local weapon_level = 0
        local enhance = 0
        
        -- func (set position) --
        local function set_weapon_pos()
            
            if (pause==0) then
                -- see if attack(ing) or not
                if (attack == 0) then
                    deg_atk = math.rad( math.deg(degree)-(lr-1)*90+45 )
                else
                    
                    if (enhance == 0) then
                        -- enhance weapon with each weapon level
                        if (weapon_level == 1) then
                            transition.to(weapon, { time = 200, width = screenHeight*0.5, height = screenHeight*0.15 })
                        elseif (weapon_level == 2) then
                            transition.to(weapon, { time = 200, width = screenHeight*1, height = screenHeight*0.3 })
                        elseif (weapon_level == 4) then
                            transition.to(weapon, { time = 200, width = screenHeight*2, height = screenHeight*1.6 })
                        end
                        
                        enhance = 1
                    end
                            
                    -- set attack speed
                    if (increase == 1) then
                        atk_speed = atk_speed + 1
                        if (atk_speed >= 15) then
                            increase=0
                            weapon_wind.width = screenHeight*0.3*(weapon_level+1); weapon_wind.height = screenHeight*0.3*(weapon_level+1)
                            weapon_wind.alpha = 1
                            transition.to(weapon_wind, { time = 400, alpha = 0 })
                        elseif (atk_speed >= 7) then
                            -- add body to weapon
                            physics.addBody(weapon, "static", { density=1, friction=0.3, bounce=0.2 })
                            
                            audio.play(swing,{channel=27, loops=0})
                        end
                    end
                    
                    -- set weapon swing degree
                    local deg_tmp = math.deg(deg_atk) - atk_speed + 6
                    deg_atk = math.rad( deg_tmp )
                    weapon_degree = weapon_degree - atk_speed + 6
                    
                    -- end attack
                    if (weapon_degree < -45) then
                        attack = 0
                        
                        -- reset attack variables
                        increase = 1
                        atk_speed = -5
                        enhance = 0
                        isBossBeHit = 0
                        
                        -- reset weapon
                        physics.removeBody(weapon)
                        weapon_degree = 45
                        weapon.width = screenHeight*0.3
                        weapon.height = screenHeight*0.1
                    end
                end
                
                -- set weapon position and rotation
                weapon.rotation = weapon_degree + math.deg(deg_atk) -- -(lr-1)*90)
                circle_posX = display.contentCenterX + math.cos(deg_atk)*screenHeight*0.05
                circle_posY = display.contentCenterY + math.sin(deg_atk)*screenHeight*0.05
                weapon.x = circle_posX + math.cos(math.rad(weapon.rotation))*weapon.width*0.5
                weapon.y = circle_posY + math.sin(math.rad(weapon.rotation))*weapon.width*0.5
                
                -- set weapon_wind position
                circle_windX = display.contentCenterX + math.cos(deg_atk+math.rad(60))*screenHeight*0.05
                circle_windY = display.contentCenterY + math.sin(deg_atk+math.rad(60))*screenHeight*0.05
                weapon_wind.x = circle_windX + math.cos(math.rad(weapon.rotation+60))*weapon.width*0.9
                weapon_wind.y = circle_windY + math.sin(math.rad(weapon.rotation+60))*weapon.width*0.9
                weapon_wind.rotation = weapon.rotation + 110
            end
            
        end
        
        -- func (skill end) --
        local function skill_end()
            skill_time = 0
            weapon_level = 0
            skillTimer = nil
            if (pause == 0) then
                audio.stop(28)
                audio.play(skillEND,{channel=28, loops=0})
            end
        end
        
        -- func (attack/skill) --
        local function attack_Touch(event)
            if (pause==0) then
                local phase = event.phase
                if (phase == "began" and attack==0) then
                    -- set skill
                    local distance = math.sqrt((event.x - skillA.x)^2 + (event.y - skillB.y)^2)
                    if (distance <= skillA.width*0.5 and skill_time == 0) then
                        if (skill_num ~= 0 and skill_time == 0) then
                            skill_time = 1
                            
                            -- play sound
                            audio.play(btn_skill,{channel=26, loops=0})
                            
                            -- set skill button
                            skillA.isVisible = false
                            skillB.isVisible = false
                            
                            -- set score
                            for i=1, 2 do
                                if (score >= skill_cost) then
                                    -- spend 2000 score
                                    score = score - skill_cost
                                    scoreShow.text = score
                                    -- upgrade weapon
                                    weapon_level = weapon_level + 1
                                end
                            end
                            
                            -- set ultimate skill!!!
                            if (score >= ultimate_cost-skill_cost*2) then
                                -- set score
                                score = score - (ultimate_cost-skill_cost*2)
                                scoreShow.text = score
                                
                                -- upgrade weapon
                                weapon_level = weapon_level + 2
                                
                                -- skill end after ? seconds
                                skillTimer = timer.performWithDelay(dif_ultimate_time[difficulty]*1000, skill_end)
                            else
                                -- skill end after ? seconds
                                skillTimer = timer.performWithDelay(dif_skill_time[difficulty]*1000, skill_end)
                            end
                            
                        end
                    else
                        attack = 1
                        deg_atk = math.rad( math.deg(degree)-(lr-1)*90+45 )
                    end
                end
            end
        end
        
        attackArea:addEventListener("touch", attack_Touch)
        timerGroup[3] = timer.performWithDelay(10, set_weapon_pos, 0)  -- 第三個參數 0 表示無限次執行
        -- create weapon end ------------------------------------------------------------
        
        
        -- create monster -----------------------------------------------------------
        monster = {}
        randNum = {}
        dieMist = {}
        local func_ok = 0
        local turn = {}
        local create_count = 1
        
        -- func (create) --
        local monster_create = function(i)
            
            -- init --
            create_count = create_count + 1
            randNum[i] = math.random(1, #monsterName-1)
            monster[i] = display.newImageRect(monsterName[randNum[i]], screenHeight*(0.09+randNum[i]*0.01), screenHeight*(0.09+randNum[i]*0.01))
            physics.addBody(monster[i], "dynamic", { density=0, friction=1, bounce=0, radius=screenHeight*(0.045+randNum[i]*0.005) })
            monster[i].myName = "monster"
            sceneGroup:insert(monster[i])
            
            local monster_speed
            local reset = 0
            
            -- func (reset) -- 
            local reset_position = function()
                reset = 0
                monster_speed = math.random(1,3 + dif_monster_plus_speed[difficulty]) -- reset speed
                local type = math.random(1, 2) -- fixed x or y
                local side = math.random(1, 2) -- -1 or +1
                -- random set monster's reborn point
                if (type == 1) then
                    monster[i].x = display.contentCenterX + screenWidth*(side*2-3)
                    monster[i].y = display.contentCenterY + math.random(0, screenHeight*2) - screenHeight
                else
                    monster[i].x = display.contentCenterX + math.random(0, screenWidth*2) - screenWidth
                    monster[i].y = display.contentCenterY + screenHeight*(side*2-3)
                end
                
            end
            
            reset_position()
            
            -- func (moving) --
            local monster_move = function()
                if (pause==0 and monster[i] and monster[i].x and joystick.x) then
                    local dis_mons = math.sqrt((monster[i].x - display.contentCenterX)^2 + (monster[i].y - display.contentCenterY)^2)
                    monster[i].x = monster[i].x - (monster[i].x - display.contentCenterX)/dis_mons*monster_speed - (joystick.x - direct_base.x)/(screenHeight*0.1)*player_speed
                    monster[i].y = monster[i].y - (monster[i].y - display.contentCenterY)/dis_mons*monster_speed - (joystick.y - direct_base.y)/(screenHeight*0.1)*player_speed
                    
                    -- if out of bounds, reset
                    local X_is_Outside_Range = (monster[i].x > display.contentCenterX + screenWidth*1.2 or monster[i].x < display.contentCenterX - screenWidth*1.2)
                    local Y_is_Outside_Range = (monster[i].y > display.contentCenterY + screenHeight * 1.2 or monster[i].y < display.contentCenterY - screenHeight * 1.2)
                    
                    if X_is_Outside_Range or Y_is_Outside_Range or reset==1 then reset_position() end
                    
                    -- set img direction
                    if (monster[i].x > display.contentCenterX) then
                        monster[i].xScale = -1
                    else
                        monster[i].xScale = 1
                    end
                end
            end
            
            -- add timer to move player
            timerGroup[4] = timer.performWithDelay(10, monster_move, 0)
            
            -- moving anime
            turn[i] = 1
            
            local turnBigSmall = function()
                if (pause == 0 and monster[i] and monster[i].width) then
                    if (turn[i] == 0) then
                        turn[i] = 1
                        transition.to(monster[i], {time = 500, width = screenHeight*(0.09+randNum[i]*0.01)*1.2})--, height = screenHeight*(0.09+randNum[i]*0.01)
                    else
                        turn[i] = 0
                        transition.to(monster[i], {time = 500, width = screenHeight*(0.09+randNum[i]*0.01)*0.8})--, height = screenHeight*(0.09+randNum[i]*0.01)*0.8
                    end
                end
            end
            
            timerGroup[7] = timer.performWithDelay(500, turnBigSmall, 0)
        
            -- func (collision) --
            local function onCollision(event)
                
                if (pause==0) then
                    if (event.phase == "began") then
                    
                        -- if monster touch player
                        if (event.other.myName == "player") then
                            reset = 1 -- help func call
                            
                            -- set sound
                            audio.play(get_hit[math.random(2,3)],{channel=28,loops=0})
                            
                            --set hp
                            hp = hp - 1
                            hpShow.text = hp.."/"..hp_max
                            
                            hp_heart.width = screenHeight*0.05; hp_heart.height = screenHeight*0.05
                            transition.to(hp_heart, { time = 1000, width = screenHeight * 0.1, height = screenHeight * 0.1})
                            
                            -- blood anime
                            blood.y = display.contentCenterY
                            blood.width = screenHeight * 0.1
                            blood.alpha = 1
                            transition.to(blood, { time = 1000, width = screenHeight * 0.3, alpha = 0})
                            
                            if (hp <= hp_max/2 and hp > hp_max/2 - 1) then
                                -- set heart
                                hp_heart:removeSelf()
                                hp_heart = nil
                                hp_heart = display.newImageRect("images/hp_heart_half.png", screenHeight*0.05, screenHeight*0.05)
                                hp_heart.x = display.contentCenterX+screenWidth*0.05; hp_heart.y = display.contentCenterY-screenHeight*0.4
                                transition.to(hp_heart, {500, width = screenHeight*0.1, height = screenHeight*0.1})
                                audio.stop(28)
                                audio.play(halfHPShow,{channel=28,loops=1})
                                sceneGroup:insert(hp_heart)
                            end
                        
                        -- if weapon hit monster    
                        elseif (event.other.myName == "weapon") then
                            
                            -- set monster die anime
                            if dieMist[i] then
                                dieMist[i]:removeSelf()
                                dieMist[i] = nil
                            end
                            dieMist[i] = display.newImageRect("images/mist.png", screenHeight*0.15, screenHeight*0.15)
                            dieMist[i].x, dieMist[i].y = monster[i].x, monster[i].y
                            local show_mist = function()
                                transition.to(dieMist[i], {1000, alpha = 0})
                            end
                            timer.performWithDelay(300, show_mist)
                            
                            sceneGroup:insert(dieMist[i])
                            
                            reset = 1 -- help func call
                            
                            -- set sound
                            audio.stop(i)
                            audio.play(doom[i],{channel=i,loops=0})
                            
                            --set score
                            score = score + dif_score[difficulty]
                            scoreShow.text = score
                            
                            -- set coin
                            audio.play(coinSound[1],{channel=30,loops=0})
                            coin.width = screenHeight*0.12; coin.height = screenHeight*0.15
                            transition.to(coin, { time = 1000, width = screenHeight * 0.08, height = screenHeight * 0.1})
                            
                        end
                    end
                end
                
            end
            
            -- add listener to see if touch player
            monster[i]:addEventListener( "collision", onCollision )
        end
        
        -- use delay to create monster
        monsterCreate_timer = timer.performWithDelay(300, function() monster_create(create_count) end, monster_number)
        -- create monster end -------------------------------------------------------
        
        
        -- boss design -----------------------------------------------------------------------
        local atkCircle = display.newCircle(0, 0, screenHeight*0.3) -- boss atk range
        atkCircle:setFillColor(0, 0, 0.7, 0.3)
        atkCircle.isVisible = false
        sceneGroup:insert(atkCircle)
        
        local boss = display.newImageRect("images/giant.png", screenHeight*0.3, screenHeight*0.3)
        boss.x = display.contentCenterX - screenWidth*0.5; boss.y = display.contentCenterY - screenHeight*0.3
        boss.isVisible = false
        boss.alpha = 0
        boss.myName = "boss"
        sceneGroup:insert(boss)
        
        local boss_roar = display.newImageRect("images/giant_roar.png", screenHeight*0.3, screenHeight*0.3)
        boss_roar.x = boss.x; boss_roar.y = boss.y
        boss_roar.isVisible = false
        sceneGroup:insert(boss_roar)
        
        boss_hp = dif_boss_maxHp[difficulty]
        hpBarName = {"images/bar1.png", "images/bar2.png", "images/bar3.png", "images/bar4.png", "images/bar5.png", "images/bar6.png", "images/bar7.png", "images/bar8.png", "images/bar9.png", "images/bar10.png"}
        hp_bar = display.newImageRect(hpBarName[10], screenHeight*0.3, screenHeight*0.3)
        hp_bar.x = boss.x; hp_bar.y = boss.y - screenHeight*0.2
        hp_bar.isVisible = false
        hp_bar.alpha = 0
        sceneGroup:insert(hp_bar)
        
        local warnArea = display.newRect(display.contentCenterX, display.contentCenterY, screenWidth*1.6, screenHeight*1.2)
        warnArea:setFillColor(0, 0, 0)  -- 設定矩形的填充顏色
        warnArea.isVisible = false
        warnArea.alpha = 0
        sceneGroup:insert(warnArea)
        
        local warning = display.newImageRect("images/warning.png", screenWidth*0.5, screenHeight*0.4)
        warning.x = display.contentCenterX; warning.y = display.contentCenterY
        warning.isVisible = false
        sceneGroup:insert(warning)
        
        local isBossCome = 0
        local isRoar = 0
        local boss_speed = 6 + dif_monster_plus_speed[difficulty]
        
        -- func (boss coming) --------
        local boss_coming = function()
            -- pause
            pause = 1
            if skillTimer then timer.pause(skillTimer) end
            if shoot_btn then shoot_btn.isVisible = false end
            
            -- set boss coming
            boss:toFront()
            boss_roar:toFront()
            
            -- reset joystick
            joystick.x = direct_base.x
            joystick.y = direct_base.y
            
            -- set boss anime
            boss.x = display.contentCenterX - screenWidth*0.5; boss.y = display.contentCenterY - screenHeight*0.3
            boss.isVisible = true
            hp_bar.isVisible = true
            transition.to(boss, {time = 4000, alpha = 1, y = display.contentCenterY})
            transition.to(hp_bar, {time = 4000, alpha = 1, y = display.contentCenterY - screenHeight*0.2})
            
            -- set warning
            warnArea:toFront()
            warning:toFront()
            warnArea.isVisible = true
            warning.isVisible = true
            warnArea.alpha = 1
            warning.alpha = 1
            
            -- warning anime
            warning.width = screenWidth*0.5; warning.height = screenHeight*0.4
            transition.to(warnArea, {time = 4000, alpha = 0})
            transition.to(warning, {time = 4000, width = screenWidth*1.25, height = screenHeight*1, alpha = 0})
            
            -- set sound
            audio.stop(30)
            audio.stop(31)
            audio.play(bossSound[1],{channel=30, loops=0})
            
            -- func (after boss coming) --
            local after_bossShow = function()
                warnArea.isVisible = false
                warning.isVisible = false
                -- roar
                physics.addBody(boss, "dynamic", { density=0, friction=1, bounce=0, radius=screenHeight*0.15 })
                boss.isVisible = false
                boss_roar.x = boss.x; boss_roar.y = boss.y
                boss_roar.isVisible = true
                audio.play(bossSound[3],{channel=24, loops=0}) --roar
                
                -- func (after roar) --
                local after_roar = function()
                    boss.isVisible = true
                    boss_roar.isVisible = false
                    audio.stop(24)
                    audio.play(bossSound[4],{channel=24, loops=0}) -- boss: youll die
                    
                    -- func (after speak) --
                    local after_speak = function()
                        pause = 0
                        isBossCome = 1
                        atkCircle.isVisible = true
                        if (score >= ultra_cost) then
                            shoot_btn.isVisible = true
                        end
                        if skillTimer then timer.resume(skillTimer) end
                        
                        -- change bgm
                        if (isBossCome == 1) then
                            audio.stop(31)
                            audio.play(bossSound[2],{channel=31, loops=-1}) --bgm
                        end
                    end
                    
                    timer.performWithDelay(2000, after_speak)
                end
                
                timer.performWithDelay(1000, after_roar)
            end
            
            timer.performWithDelay(4000, after_bossShow)
        end
        -- func (boss coming) end ----
        
        -- boss coming after 60 sec
        bossCome_timer = timer.performWithDelay(dif_boss_comingTimeDelay[difficulty]*1000, boss_coming)
        
        
        -- func (moving) --
        local boss_move = function()
            if (pause==0 and isBossCome == 1 and boss and boss.x) then
                local dis_boss = math.sqrt((boss.x - display.contentCenterX)^2 + (boss.y - display.contentCenterY)^2)
                if (isRoar == 0) then
                    boss.x = boss.x - (boss.x - display.contentCenterX)/dis_boss*boss_speed
                    boss.y = boss.y - (boss.y - display.contentCenterY)/dis_boss*boss_speed
                end
                
                
                -- if out of bounds, stay in bounds
                local X_is_Inside_Range = (boss.x < display.contentCenterX + screenWidth*0.8 and boss.x > display.contentCenterX - screenWidth*0.8)
                local Y_is_Inside_Range = (boss.y < display.contentCenterY + screenHeight * 0.7 and boss.y > display.contentCenterY - screenHeight * 0.7)
                
                if X_is_Inside_Range or Y_is_Inside_Range then
                    boss.x = boss.x - (joystick.x - direct_base.x)/(screenHeight*0.1)*player_speed
                    boss.y = boss.y - (joystick.y - direct_base.y)/(screenHeight*0.1)*player_speed
                end
                
                -- set img direction
                if (boss.x > display.contentCenterX) then
                    boss.xScale = -1
                else
                    boss.xScale = 1
                end
                
                -- set hp_bar & atkCircle position
                if (boss_hp > 0) then
                    hp_bar.x = boss.x; hp_bar.y = boss.y - screenHeight*0.2
                    atkCircle.x = boss.x; atkCircle.y = boss.y
                    boss_roar.x = boss.x; boss_roar.y = boss.y
                end
            end
        end
        
        -- add timer to move boss
        timerGroup[8] = timer.performWithDelay(10, boss_move, 0)
        
        -- func (boss roar per 5 sec) --
        local boss_roaring = function()
            if (pause==0 and isBossCome == 1 and isRoar == 0) then
                isRoar = 1
                
                -- set img
                boss.isVisible = false
                boss_roar.x = boss.x; boss_roar.y = boss.y
                boss_roar.isVisible = true
                audio.play(bossSound[3],{channel=24, loops=0})
                
                -- set attack
                atkCircle:setFillColor(0.7, 0, 0, 0.3)
                
                -- if atk success
                local bossDistance = math.sqrt((boss.x - display.contentCenterX)^2 + (boss.y - display.contentCenterY)^2)
                if (bossDistance < screenHeight*0.3) then
                    audio.stop(28)
                    audio.play(get_hit[math.random(2,3)],{channel=28,loops=0})
                    audio.play(halfHPShow,{channel=32,loops=1})
                    
                    --set hp
                    hp = hp - 3
                    hpShow.text = hp.."/"..hp_max
                    
                    -- heart anime
                    hp_heart.width = screenHeight*0.05; hp_heart.height = screenHeight*0.05
                    transition.to(hp_heart, { time = 1000, width = screenHeight * 0.1, height = screenHeight * 0.1})
                    
                    -- blood anime
                    blood.y = display.contentCenterY
                    blood.width = screenHeight * 0.1
                    blood.alpha = 1
                    transition.to(blood, { time = 1000, width = screenHeight * 0.35, alpha = 0})
                    
                    -- set half blood
                    if (hp <= hp_max/2 and hp > hp_max/2 - 1) then
                        -- set heart
                        hp_heart:removeSelf()
                        hp_heart = nil
                        hp_heart = display.newImageRect("images/hp_heart_half.png", screenHeight*0.05, screenHeight*0.05)
                        hp_heart.x = display.contentCenterX+screenWidth*0.05; hp_heart.y = display.contentCenterY-screenHeight*0.4
                        transition.to(hp_heart, {500, width = screenHeight*0.1, height = screenHeight*0.1})
                        sceneGroup:insert(hp_heart)
                    end
                end
                
                -- func (after roar) --
                local after_roar = function()
                    boss.isVisible = true
                    boss_roar.isVisible = false
                    atkCircle:setFillColor(0, 0, 0.7, 0.3)
                    isRoar = 0
                end
                
                timer.performWithDelay(1000, after_roar)
            end
        end
        -- boss roar per 5 seconds
        timerGroup[9] = timer.performWithDelay(5000, boss_roaring, 0)
        
        
        -- func (remove physics body) --
        local boss_remove_body = function()
            if boss then
                physics.removeBody(boss)
            end
        end
        
        -- func (collision) --
        local function bossCollision(event)
            if (pause==0 and isBossCome == 1 and event.phase == "began" and event.other.myName == "weapon" and boss_hp > 0 and isBossBeHit == 0) then
                isBossBeHit = 1
                
                -- set sound
                audio.stop(monster_number+1)
                audio.play(bossSound[3],{channel=monster_number+1,loops=0})
                
                -- set anime
                boss.alpha = 0.5
                transition.to(boss, { time = 500, alpha = 1})
                
                -- set hp
                boss_hp = boss_hp - 1
                
                -- if boss die
                if (boss_hp == 0) then
                    -- set boss anime
                    isRoar = 1
                    local delaySet_bossValue = function()
                        isBossCome = 0
                        isRoar = 0
                        
                        -- change bgm
                        local changeBGMtoOrigin = function()
                            if (pause == 0) then
                                audio.stop(31)
                                audio.play(bgm,{channel=31,loops=-1})
                                -- bossCome_timer = timer.performWithDelay(10000, boss_coming)
                                boss_remove_body()
                            end
                        end
                        timer.performWithDelay(2000, changeBGMtoOrigin)
                    end
                    timer.performWithDelay(2000, delaySet_bossValue)
                    boss.isVisible = true
                    boss_roar.isVisible = false
                    atkCircle.isVisible = false
                    hp_bar.isVisible = false
                    if (boss.xScale > 0) then
                        transition.to(boss, {time = 2000, rotation = -90, x = boss.x - screenHeight * 0.1, y = boss.y + screenHeight * 0.1, alpha = 0})
                    else
                        transition.to(boss, {time = 2000, rotation = 90, x = boss.x + screenHeight * 0.1, y = boss.y + screenHeight * 0.1, alpha = 0})
                    end
                    
                    -- set boss die sound
                    audio.stop(monster_number+1)
                    audio.play(bossSound[5],{channel=monster_number+1,loops=0})
                    
                    -- set score
                    score = score + dif_killBoss_reward[difficulty]
                    scoreShow.text = score
                    
                    -- set coin
                    audio.play(coinSound[2],{channel=30,loops=0})
                    coin.width = screenHeight*0.12; coin.height = screenHeight*0.15
                    transition.to(coin, { time = 1000, width = screenHeight * 0.08, height = screenHeight * 0.1})
                elseif (boss_hp % (dif_boss_maxHp[difficulty]/10) == 0) then
                    -- set hp_bar
                    hp_bar:removeSelf()
                    hp_bar = nil
                    hp_bar = display.newImageRect(hpBarName[boss_hp/(dif_boss_maxHp[difficulty]/10)], screenHeight*0.3, screenHeight*0.3)
                    hp_bar.x = boss.x; hp_bar.y = boss.y - screenHeight*0.2
                    sceneGroup:insert(hp_bar)
                end
                    
            end
            
        end
        
        -- add listener to see if touch player
        boss:addEventListener( "collision", bossCollision )
        
        -- boss design end -------------------------------------------------------------------
        
        
        -- pause button -----------------------------------------------------------------
        local pauseArea = display.newRect(display.contentCenterX, display.contentCenterY, screenWidth*1.6, screenHeight*1.2)
        pauseArea:setFillColor(0, 0, 0, 0.8)  -- 設定矩形的填充顏色
        pauseArea.isVisible = false
        sceneGroup:insert(pauseArea)
        
        local p_Press = function( event )
            if (pause == 0) then
                audio.stop(26)
                audio.play(btn_press,{channel=26, loops=0})
            end
        end
        
        local p_Release = function( event )
            if (pause == 0) then
                pause = 1
                if skillTimer then timer.pause(skillTimer) end
                if bossCome_timer then timer.pause(bossCome_timer) end
                if monsterCreate_timer then timer.pause(monsterCreate_timer) end
                
                -- reset joystick
                joystick.x = direct_base.x
                joystick.y = direct_base.y
                
                -- sound
                audio.stop(26)
                audio.play(btn_release,{channel=26, loops=0})
                
                -- black bg
                pauseArea.isVisible = true
                player.alpha = 0.2
                
                local showSkillCost = function()
                    if (pause == 1) then
                        pauseArea:toFront()
                        play_btn:toFront()
                        back_btn:toFront()
                        
                        -- show skill cost
                        skillCostShow = display.newText("skill cost\n  level 1 :\n  level 2 :\n  level 3 :", display.contentCenterX-screenWidth*0.35, display.contentCenterY-screenHeight*0.1, "Silver.ttf", 48)
                        skillCostShow:setTextColor(0.3, 0.3, 0.7)
                        sceneGroup:insert(skillCostShow)
                        
                        ultraCostShow = display.newText("ultimate :", display.contentCenterX-screenWidth*0.35, display.contentCenterY+screenHeight*0.325, "Silver.ttf", 48)
                        ultraCostShow:setTextColor(0.7, 0.3, 0.3)
                        sceneGroup:insert(ultraCostShow)
                        
                        costShow = display.newText(skill_cost.."\n"..(skill_cost*2).."\n"..ultimate_cost.."\n"..ultra_cost, display.contentCenterX-screenWidth*0.05, display.contentCenterY+screenHeight*0.075, "Silver.ttf", 48)
                        costShow:setTextColor(0.7, 0.6, 0)
                        sceneGroup:insert(costShow)
                        
                        durationShow = display.newText(dif_skill_time[difficulty].."s\n"..dif_skill_time[difficulty].."s\n"..dif_ultimate_time[difficulty].."s", display.contentCenterX+screenWidth*0.1, display.contentCenterY-screenHeight*0.01, "Silver.ttf", 48)
                        durationShow:setTextColor(0.6, 0.6, 0.3)
                        sceneGroup:insert(durationShow)
                        
                        difficultyShow = display.newText("", display.contentCenterX-screenWidth*0.015, display.contentCenterY-screenHeight*0.35, "Silver.ttf", 48)
                        sceneGroup:insert(difficultyShow)
                        if (difficulty == 1) then
                            difficultyShow.text = "Easy"
                            difficultyShow:setTextColor(0.3, 0.7, 0.3)
                        elseif (difficulty == 2) then
                            difficultyShow.text = "Normal"
                            difficultyShow:setTextColor(0.7, 0.7, 0)
                        elseif (difficulty == 3) then
                            difficultyShow.text = "Hard"
                            difficultyShow:setTextColor(0.7, 0.3, 0.3)
                        else
                            difficultyShow.text = "HELL"
                            difficultyShow:setTextColor(1, 0, 0)
                        end
                    end
                end
                timer.performWithDelay(200, showSkillCost)
                
                local play_Press = function( event )
                    audio.stop(26)
                    audio.play(btn_press,{channel=26, loops=0})
                end
                
                -- set play button ---------------------------
                local play_Release = function( event )
                    -- visible setting
                    pause = 0
                    pauseArea.isVisible = false
                    player.alpha = 1
                    
                    if skillTimer then timer.resume(skillTimer) end
                    if bossCome_timer then timer.resume(bossCome_timer) end
                    if monsterCreate_timer then timer.resume(monsterCreate_timer) end
                    
                    -- set sound
                    audio.stop(26)
                    audio.play(btn_release,{channel=26, loops=0})
                    
                    -- remove button
                    back_btn:removeSelf()
                    back_btn = nil
                    play_btn:removeSelf()
                    play_btn = nil
                    
                    -- remove text
                    if difficultyShow then
                        skillCostShow:removeSelf()
                        skillCostShow = nil
                        ultraCostShow:removeSelf()
                        ultraCostShow = nil
                        costShow:removeSelf()
                        costShow = nil
                        durationShow:removeSelf()
                        durationShow = nil
                        difficultyShow:removeSelf()
                        difficultyShow = nil
                    end
                end
                
                play_btn = widget.newButton
                {
                    defaultFile = "images/play_btn1.png",
                    overFile = "images/play_btn2.png",
                    emboss = true,
                    onPress = play_Press,
                    onRelease = play_Release,
                }
                play_btn.x = display.contentCenterX + screenWidth*0.325
                play_btn.y = display.contentCenterY + screenHeight*0.2
                play_btn.width = screenHeight*0.3; play_btn.height = screenHeight*0.3
                -- set play button end -----------------------
                
                -- set back button ---------------------------
                local back_Press = function( event )
                    audio.stop(26)
                    audio.play(btn_press,{channel=26, loops=0})
                end
                
                -- set back button
                local back_Release = function( event )
                    -- remove button
                    composer.gotoScene( "start", { time=300, effect="fade" } )
                    
                    -- set sound
                    audio.stop(26)
                    audio.play(btn_release,{channel=26, loops=0})
                    
                    back_btn:removeSelf()
                    back_btn = nil
                    play_btn:removeSelf()
                    play_btn = nil
                    player:removeSelf()
                    player = nil
                    
                end
                
                back_btn = widget.newButton
                {
                    defaultFile = "images/home_btn.png",
                    overFile = "images/back_btn.png",
                    emboss = true,
                    onPress = back_Press,
                    onRelease = back_Release,
                }
                back_btn.x = display.contentCenterX + screenWidth*0.325
                back_btn.y = display.contentCenterY - screenHeight*0.2
                back_btn.width = screenHeight*0.3; back_btn.height = screenHeight*0.3
                -- set back button end -----------------------
            end
            
        end
        
        -- 設定按鈕屬性(所有的屬性均是選擇性的，可不設定)
        local pause_btn = widget.newButton
        {
            defaultFile = "images/pause_btn.png",          -- 未按按鈕時顯示的圖片
            -- overFile = "images/explode1.png",          -- 按下按鈕時顯示的圖片
            emboss = true,                             -- 立體效果
            onPress = p_Press,
            onRelease = p_Release,                     -- 觸發放開按鈕事件要執行的函式
        }
        
        pause_btn.x = display.contentCenterX+screenWidth*0.5-screenHeight*0.075
        pause_btn.y = display.contentCenterY-screenHeight*0.425
        pause_btn.width = screenHeight*0.1; pause_btn.height = screenHeight*0.1
        pause_btn.isVisible = false
        sceneGroup:insert(pause_btn)
        
        local setVisible_pauseBtn = function()
            pause_btn.isVisible = true
        end
        
        timer.performWithDelay(7000, setVisible_pauseBtn)
        -- pause button end -------------------------------------------------------------
        
        
        -- ultra plus ultimate -------------------------------------------------------------------------------------------------------------
        local whiteArea = display.newRect(display.contentCenterX, display.contentCenterY, screenWidth*1.6, screenHeight*1.2)
        whiteArea:setFillColor(1, 1, 1)  -- 設定矩形的填充顏色
        whiteArea.alpha = 0
        sceneGroup:insert(whiteArea)
        
        local aim_img = display.newImageRect("images/aim1.png", 0, 0)
        aim_img.x = display.contentCenterX; aim_img.y = display.contentCenterY
        aim_img.isVisible = false
        sceneGroup:insert(aim_img)
        
        local aim_img2 = display.newImageRect("images/aim2.png", 0, 0)
        aim_img2.x = display.contentCenterX; aim_img2.y = display.contentCenterY
        aim_img2.alpha = 0.5
        aim_img2.isVisible = false
        sceneGroup:insert(aim_img2)
        
        local blackbg = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, screenWidth*1.6, screenHeight*1.2)
        blackbg:setFillColor(0, 0, 0)
        blackbg.isVisible = false
        
        local bg_treasure = display.newImageRect("images/bg_treasure.jpg", screenWidth*1.6, screenHeight*1)
        bg_treasure.x = display.contentCenterX; bg_treasure.y = display.contentCenterY
        bg_treasure.isVisible = false
        sceneGroup:insert(bg_treasure)
        
        local treasure = display.newImageRect("images/Treasure.png", screenWidth*0.5, screenHeight*0.5)
        treasure.x = display.contentCenterX - screenWidth*0.2; treasure.y = display.contentCenterY
        treasure.isVisible = false
        sceneGroup:insert(treasure)
        
        local treasure_open = display.newImageRect("images/treasure_open.png", screenWidth*0.8, screenHeight*1)
        treasure_open.x = display.contentCenterX - screenWidth*0.2; treasure_open.y = display.contentCenterY
        treasure_open.isVisible = false
        sceneGroup:insert(treasure_open)
        
        local blackoutRect = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, screenWidth*1.6, screenHeight*1.2)
        blackoutRect:setFillColor(0, 0, 0)
        blackoutRect.alpha = 0
        blackoutRect.isVisible = false
        
        local bg_win = display.newImageRect("images/bg_win.jpg", screenWidth*1.6, screenHeight)
        bg_win.x = display.contentCenterX; bg_win.y = display.contentCenterY
        bg_win.isVisible = false
        sceneGroup:insert(bg_win)
        
        local victoryImg = display.newImageRect("images/victory.png", 0, 0)
        victoryImg.x = display.contentCenterX; victoryImg.y = display.contentCenterY
        victoryImg.isVisible = false
        sceneGroup:insert(victoryImg)
        
        -- shooting button --
        local shoot_Release = function( event )
            -- setting
            pause = 1
            if bossCome_timer then timer.pause(bossCome_timer) end
            shoot_btn:removeSelf() -- remove button
            shoot_btn = nil
            audio.stop(31)
            flip = {}
            
            -- play sound
            audio.play(btn_skill,{channel=26, loops=0})
            
            -- shooting anime start --------
            local moving_time = 500
            local aim_time = 4000
            local shoot_time = 7000
            
            -- set magic
            aim_img:toBack()
            aim_img2:toBack()
            aim_img.isVisible = true
            aim_img2.isVisible = true
            transition.to(aim_img, { time = moving_time+1000, width = screenHeight*1, height = screenHeight*1, rotation = 90 })
            transition.to(aim_img2, { time = moving_time+1000, width = screenHeight*1, height = screenHeight*1, rotation = -90 })
            
            audio.stop(30)
            audio.stop(32)
            audio.play(magicSound[1],{channel=30,loops=0})
            audio.play(magicSound[2],{channel=32,loops=0})
            
            -- set white area
            whiteArea.alpha = 1
            transition.to(whiteArea, { time = 100, alpha = 0 })
            whiteArea:toFront()
            
            -- create monster 
            for i = monster_number+1, 200 do
                randNum[i] = math.random(1, #monsterName-1)
                monster[i] = display.newImageRect(monsterName[randNum[i]], screenHeight*(0.09+randNum[i]*0.01), screenHeight*(0.09+randNum[i]*0.01))
                monster[i].x = display.contentCenterX; monster[i].y = display.contentCenterX
                sceneGroup:insert(monster[i])
                local dist_tmp = 0
                while dist_tmp < screenHeight*0.1 do
                    monster[i].x = math.random(display.contentCenterX - screenWidth*1.9, display.contentCenterX + screenWidth*1.9)
                    monster[i].y = math.random(display.contentCenterY - screenHeight*1.9, display.contentCenterY + screenHeight*1.9)
                    dist_tmp = math.sqrt((monster[i].x - display.contentCenterX)^2 + (monster[i].y - display.contentCenterY)^2)
                end
            end
            
            -- set object
            playerImg.alpha = 1
            player.alpha = 0
            if (player.xScale < 0) then playerImg.xScale = -1 end
            direct_base.isVisible = false
            joystick.isVisible = false
            weapon.isVisible = false
            pause_btn.isVisible = false
            coin.isVisible = false
            scoreShow.isVisible = false
            hp_heart.isVisible = false
            hpShow.isVisible = false
            skillA.isVisible = false
            skillB.isVisible = false
            hp_bar.isVisible = false
            atkCircle.isVisible = false
            
            -- func (flash and victory) --
            local after_flashLight = function()
                transition.to(whiteArea, { time = shoot_time, alpha = 0 })
                
                -- boom
                for i=1, 200 do
                    -- set boom anime
                    if (i % 1 == 0) then
                        Forest = movieclip.newAnim({"images/explode1.png","images/explode2.png","images/explode3.png","images/explode4.png","images/explode5.png","images/explode6.png","images/explode7.png","images/explode8.png","images/explode9.png"})
                        Forest:play({startFrame=1,endFrame=9,loop=2,remove=true})
                        Forest.x, Forest.y = monster[i].x, monster[i].y --位置
                        Forest.width, Forest.height = screenHeight*0.3, screenHeight*0.3
                        Forest:setDrag{drag=false} --拖曳移動物件
                    end
                    
                    -- delay giant boom
                    local delayBoom = function()
                        if (i % 1 == 0) then
                            Fore = movieclip.newAnim({"images/explode1.png","images/explode2.png","images/explode3.png","images/explode4.png","images/explode5.png","images/explode6.png","images/explode7.png","images/explode8.png","images/explode9.png"})
                            Fore:play({startFrame=1,endFrame=9,loop=1,remove=true})
                            Fore.x, Fore.y = monster[i].x, monster[i].y --位置
                            Fore.width, Fore.height = screenHeight*0.4, screenHeight*0.4
                            Fore:setDrag{drag=false} --拖曳移動物件
                        end
                        
--                        -- sound
--                        if (i <= monster_number) then
--                            audio.stop(i)
--                            audio.dispose(doom[i])
--                            doom[i]=audio.loadStream("images/s1.mp3")
--                            audio.play(doom[i],{channel=i,loops=0})
--                        end
                    end
                    timer.performWithDelay(1000, delayBoom)
                    
                    -- set sound
                    if (i <= #boom*3 and i <= monster_number) then
                        audio.stop(i)
                        audio.dispose(doom[i])
                        doom[i] = audio.loadStream(boom[i%#boom+1])
                        audio.setVolume(1, { channel = i })
                        audio.play(doom[i],{channel=i,loops=0})
                    end
                    
                    monster[i].isVisible = false
                end
                
                -- set boss
                if (boss.alpha ~= 0) then
                    boss.isVisible = false
                    boss_roar.isVisible = false
                    
                    -- set boss die sound
                    audio.stop(monster_number+1)
                    audio.play(bossSound[5],{channel=monster_number+1,loops=0})
                end
                
                
                -- func (victory) --
                local victory = function()
                    player.isVisible = false
                    playerImg.isVisible = false
                    treasure_open.isVisible = false
                    bg_treasure.isVisible = false
                    bg_win.isVisible = true
                    victoryImg.isVisible = true
                    transition.to(blackoutRect, { time = 2000, alpha = 0 })
                    transition.to(victoryImg, { time = 2000, width = screenWidth, height = screenHeight})
                    
                    -- victory anime
                    local victoryTurn = 0
                    
                    local gameover_turn = function()
                        if (victoryTurn == 0) then
                            victoryTurn = 1
                            transition.to(victoryImg, {time = 1000, alpha = 1})
                        else
                            victoryTurn = 0
                            transition.to(victoryImg, {time = 1000, alpha = 0.5})
                        end
                    end
                    timerGroup[11] = timer.performWithDelay(1000, gameover_turn, 0)
                    
                    -- change bgm
                    audio.stop(31)
                    audio.dispose(bgm)
                    bgm = audio.loadStream("images/winBGM.mp3")
                    audio.play(bgm,{channel=31, loops=-1})
                    
                    -- func (go back to home) --
                    local go_home = function()
                        composer.gotoScene( "start", { effect="fade", time=3000 })
                    end
                    
                    victoryImg:addEventListener("touch", go_home)
                end
                
                -- func (blackout) --
                local blackOut = function()
                    -- black out
                    transition.to(blackoutRect, { time = 2000, alpha = 1 })
                    blackoutRect:toFront()
                    
                    timer.performWithDelay(2000, victory)
                end
                
                -- func (wait black out) --
                local blackOutDelay = function()
                    -- set treasure
                    treasure.isVisible = false
                    treasure_open.isVisible = true
                    
                    -- set heart
                    hp_heart:removeSelf()
                    hp_heart = nil
                    hp_heart = display.newImageRect("images/hp_heart.png", screenHeight*0.2, screenHeight*0.2)
                    hp_heart.x = display.contentCenterX + screenWidth*0.25; hp_heart.y = display.contentCenterY - screenHeight*0.1
                    transition.to(hp_heart, {time = 2000, y = display.contentCenterY - screenHeight*0.3, alpha = 0})
                    sceneGroup:insert(hp_heart)
                    
                    -- func (flip coin) --
                    local flip_coin = function(i)
                        flip[i] = audio.loadStream("images/flip_coin.ogg")
                        audio.play(flip[i],{channel=i, loops=0})
                    end
                    
                    for i=1, 10 do
                        timer.performWithDelay(i*200, function() flip_coin(i) end)
                    end
                    
                    timer.performWithDelay(2000, blackOut)
                end
                
                -- func (find treasure) --
                local find_treasure = function()
                    -- change backgroud
                    for i=1, 4 do
                        bg[i].isVisible = false
                    end
                    playerImg.isVisible = true
                    blackbg.isVisible = true
                    treasure.isVisible = true
                    bg_treasure.isVisible = true
                    blackoutRect.isVisible = true
                    
                    -- move player
                    playerImg.x = display.contentCenterX + screenHeight*1.6
                    playerImg.y = display.contentCenterY + screenHeight*0.1
                    playerImg.width = screenHeight*0.3; playerImg.height = screenHeight*0.3
                    playerImg.xScale = -1
                    playerImg:toFront()
                    transition.to(playerImg, { time = 4000, x = display.contentCenterX + screenWidth*0.25 })
                    
                    audio.play(walking,{channel=25, loops=-1})
                    
                    local treasure_press = function()
                        -- set audio
                        audio.stop(25)
                        audio.play(winSound,{channel=27,loops=0})
                            
                        -- set treasure
                        local treasureTurn = 1
                
                        local turnTreasure = function()
                            if (treasureTurn == 0) then
                                treasureTurn = 1
                                transition.to(treasure, {time = 1000, width = screenWidth*0.55, height = screenHeight*0.55})
                            else
                                treasureTurn = 0
                                transition.to(treasure, {time = 1000, width = screenWidth*0.45, height = screenHeight*0.45})
                            end
                        end
                        timerGroup[10] = timer.performWithDelay(1000, turnTreasure, 0)
                        
                        treasure:addEventListener("touch", blackOutDelay)
                    end
                    
                    timer.performWithDelay(3500, treasure_press)
                end
                
                timer.performWithDelay(1100, find_treasure)
            end
            
            -- func (shooting) --
            local shooting = function()
                -- white flash
                transition.to(whiteArea, { time = 100, alpha = 1 })
                whiteArea:toFront()
                transition.to(aim_img, { time = 200, rotation = 370, alpha = 0 })
                transition.to(aim_img2, { time = 200, rotation = -370, alpha = 0 })
                timer.performWithDelay(2000, after_flashLight)
                playerImg.isVisible = false
                
                -- set volume
                audio.stop(32)
                local shootSound=audio.loadStream("images/ulti_shoot.ogg")
                audio.play(shootSound,{channel=32, loops=0})
                
                player.isVisible = false
            end
            
            
            -- func (aim) --
            local aiming = function()
                -- reset background position & move
                for i = 1, 2 do
                    for j = 1, 2 do
                        bg[(i-1)*2+j].x = display.contentCenterX + screenWidth*(j*2-3)
                        bg[(i-1)*2+j].y = display.contentCenterY + screenHeight*(i*2-3)
                        bg[(i-1)*2+j]:toBack()
                        transition.to(bg[(i-1)*2+j], { time = moving_time + aim_time + 2000, width = screenWidth*0.8, height = screenHeight*0.6, x = display.contentCenterX + screenWidth*(j*2-3)*0.4, y = display.contentCenterY + screenHeight*(i*2-3)*0.3 })
                    end
                end
                
                -- move monster
                for i=1, 200 do
                    if (i<=monster_number) then physics.removeBody(monster[i]) end
                    local mx = (monster[i].x - display.contentCenterX)*0.4 + display.contentCenterX
                    local my = (monster[i].y - display.contentCenterY)*0.3 + display.contentCenterY
                    local mw = monster[i].width*0.5
                    local mh = monster[i].height*0.5
                    transition.to(monster[i], { time = moving_time + aim_time + 2000, width = mw, height = mh, x = mx, y = my })
                end
                
                -- set player
                transition.to(playerImg, { time = moving_time + aim_time + 2000, width = screenHeight * 0.06, height = screenHeight * 0.06})
                
                -- set boss
                local bx = (boss.x - display.contentCenterX)*0.4 + display.contentCenterX
                local by = (boss.y - display.contentCenterY)*0.3 + display.contentCenterY
                local bw = boss.width*0.5
                local bh = boss.height*0.5
                transition.to(boss, { time = moving_time + aim_time + 2000, width = bw, height = bh, x = bx, y = by })
                transition.to(boss_roar, { time = moving_time + aim_time + 2000, width = bw, height = bh, x = bx, y = by })
                
                -- set aim
                transition.to(aim_img, { time = aim_time+1000, width = screenWidth*1.5, height = screenWidth*1.5, rotation = 360 })
                transition.to(aim_img2, { time = aim_time+1000, width = screenWidth*0.7, height = screenWidth*0.7, rotation = -360 })
                timer.performWithDelay(aim_time + 1000, shooting)
            end
            
            -- set aiming delay
            timer.performWithDelay(moving_time + 1000, aiming)
        end
        
        shoot_btn = widget.newButton
        {
            width = screenHeight*0.2,
            height = screenHeight*0.2,
            defaultFile = "images/ultra_btn1.png",
            overFile = "images/ultra_btn2.png",
            emboss = true,
            onRelease = shoot_Release,
        }
        shoot_btn.x = display.contentCenterX + screenWidth * 0.5 - screenHeight * 0.1
        shoot_btn.y = display.contentCenterY + screenHeight * 0.1
        shoot_btn.isVisible = false
--        shoot_btn.isEnabled = false
        sceneGroup:insert(shoot_btn)
        
        -- func (show shoot btn) --
--        local show_shoot = function()
--            shoot_btn.isEnabled = true
--        end
        
        -- func (check ultra score) --
        local score_ultra = function()
            if (score >= ultra_cost and pause == 0 and shoot_btn.isVisible == false and pause_btn.isVisible == true) then
                shoot_btn.isVisible = true
                shoot_btn.alpha = 0
                transition.to(shoot_btn, { time = 500, alpha = 1 })
                audio.play(ultraShow,{channel=29, loops=0})
                timer.performWithDelay(500, show_shoot)
            end
        end
        
        timerGroup[5] = timer.performWithDelay(100, score_ultra, 0)
        -- ultra plus ultimate end ---------------------------------------------------------------------------------------------------------
        
        
        -- game over --------------------------------------------------
        local game_over = display.newImageRect("images/game_over.png", screenWidth*0.5, screenHeight*0.5)
        game_over.x = display.contentCenterX; game_over.y = display.contentCenterY
        game_over.isVisible = false
        game_over.alpha = 0
        sceneGroup:insert(game_over)
        
        local bg_lose = display.newImageRect("images/bg_lose.png", screenWidth*1.6, screenHeight)
        bg_lose.x = display.contentCenterX; bg_lose.y = display.contentCenterY
        bg_lose.isVisible = false
        sceneGroup:insert(bg_lose)
        
        local blood_lake
        
        -- func (go back home) --
        local go_back = function()
            -- set visible
            direct_base.isVisible = false
            joystick.isVisible = false
            weapon.isVisible = false
            pause_btn.isVisible = false
            coin.isVisible = false
            scoreShow.isVisible = false
            hp_heart.isVisible = false
            hpShow.isVisible = false
            skillA.isVisible = false
            skillB.isVisible = false
            hp_bar.isVisible = false
            atkCircle.isVisible = false
            boss.isVisible = false
            boss_roar.isVisible = false
            
            for i=1, 4 do
                bg[i].isVisible = false
            end
            
            for i=1, monster_number do
                monster[i].isVisible = false
            end
            
            composer.gotoScene( "start", { effect="fade", time=3000 } ) -- { effect="fade", time=3000 }, options
        end
        
        -- func (black out) --
        local blackout = function()
            -- show img
            bg_lose:toFront()
            game_over:toFront()
            player.isVisible = false
            blood_lake.isVisible = false
            bg_lose.isVisible = true
            game_over.isVisible = true
            transition.to(blackoutRect, { time = 1000, alpha = 0})
            transition.to(game_over, {time = 2000, width = screenWidth, height = screenHeight, alpha = 1})
            
            -- game over anime
            local loseTurn = 0
            
            local gameover_turn = function()
                if (loseTurn == 0) then
                    loseTurn = 1
                    transition.to(game_over, {time = 1000, alpha = 1})
                else
                    loseTurn = 0
                    transition.to(game_over, {time = 1000, alpha = 0.5})
                end
            end
            timerGroup[10] = timer.performWithDelay(1000, gameover_turn, 0)
            
            -- change bgm
            audio.stop(31)
            audio.dispose(bgm)
            bgm = audio.loadStream("images/loseBGM.mp3")
            audio.play(bgm,{channel=31, loops=-1})
            
            game_over:addEventListener("touch", go_back)
        end
        
        -- func (game over) --
        local hp_is_zero = function()
            if (hp <= 0 and pause == 0) then
                -- stop game
                pause = 1
                if bossCome_timer then timer.pause(bossCome_timer) end
                shoot_btn:removeSelf()
                shoot_btn = nil
                
                -- show game over
                hp_heart.width = screenHeight*0.2; hp_heart.height = screenHeight*0.2
                transition.to(hp_heart, {1000, width = screenHeight*0.1, height = screenHeight*0.1, alpha = 0})
                
                blackbg:toFront()
                game_over:toFront()
                blackoutRect:toFront()
                
                -- player die
                audio.stop(31)
                audio.stop(28)
                audio.play(die,{channel=28,loops=0})
                
                blood_lake = display.newImageRect("images/blood_lake.png", screenHeight*0.2, screenHeight*0.2)
                blood_lake.x = display.contentCenterX; blood_lake.y = display.contentCenterY
                sceneGroup:insert(blood_lake)
                
                if (player.xScale < 0) then lr = -1 else lr = 1 end
                player:removeSelf()
                player = nil
                player = display.newImageRect("images/player_die.png", screenHeight*0.15, screenHeight*0.15)
                player.x = display.contentCenterX; player.y = display.contentCenterY
                if (lr == -1) then player.xScale = -1 end
                sceneGroup:insert(player)
                
                -- delay 2 second and black out
                blackoutRect.isVisible = true
                transition.to(blackoutRect, { time = 1000, alpha = 1})
                
                local die_blackOut = function()
                    blackoutRect.alpha = 0
                    blackbg.isVisible = true
                    blackoutRect:toFront()
                    transition.to(blackoutRect, { time = 1000, alpha = 1})
                end
                
                timer.performWithDelay(3500, die_blackOut)
                timer.performWithDelay(5000, blackout)
                
            end
        end
        
        timerGroup[6] = timer.performWithDelay(50, hp_is_zero, 0)
        -- game over end ----------------------------------------------
        
        
    end
    
end


-- "scene:hide()"
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Called when the scene is on screen (but is about to go off screen)
        -- Insert code here to "pause" the scene
        -- Example: stop timers, stop animation, stop audio, etc.
        
        -- stop sound
        for i=1, monster_number do
            audio.dispose(doom[i])
            doom[i] = nil
        end
        
        for i=1, 10 do
            if(flip and flip[i]) then
                audio.dispose(flip[i])
                flip[i] = nil
            end
        end
        
        audio.stop(31)
        audio.dispose(bgm)
        bgm = nil
        
        audio.stop(32)
        audio.dispose(die)
        audio.dispose(shootSound)
        die = nil
        shootSound = nil
        
        -- stop timer
--        print("timer:"..#timerGroup)
        for i=1, #timerGroup do
            timer.cancel(timerGroup[i])
            timerGroup[i] = nil
        end
        
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
        composer.removeScene("battle_field")
    end
end


-- "scene:destroy()"
function scene:destroy( event )

    local sceneGroup = self.view
    
    local sceneGroup = self.view   
    sceneGroup:removeSelf()
    sceneGroup = nil
    
    -- Called prior to the removal of scene's view
    -- Insert code here to clean up the scene
    -- Example: remove display objects, save state, etc.
end


-- -------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-- -------------------------------------------------------------------------------

return scene
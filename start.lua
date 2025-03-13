system.activate( "multitouch" )

local composer = require( "composer" )
local widget = require( "widget" )
local movieclip = require("movieclip")
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 0)

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------------------------------------
-- All code outside of the listener functions will only be executed ONCE unless "composer.removeScene()" is called
-- -----------------------------------------------------------------------------------------------------------------

-- Local forward references should go here

-- -------------------------------------------------------------------------------


-- "scene:create()"
function scene:create( event )

    local sceneGroup = self.view

    -- Initialize the scene here
    -- Example: add display objects to "sceneGroup", add touch listeners, etc.
    
end


-- "scene:show()" --����⦸
function scene:show( event ) 

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
    
        -- set BGM
        bgm_lobby=audio.loadStream("images/lobbyBGM.mp3")
        audio.play(bgm_lobby,{channel=31,loops=-1})
        
    elseif ( phase == "did" ) then
        
        local bg1 = display.newImageRect("images/bg_lobby2.png", screenWidth*1.6, screenHeight*1)
        bg1.x = display.contentCenterX; bg1.y = display.contentCenterY
        bg1:toBack()
        sceneGroup:insert(bg1)
        
        local playerImg = display.newImageRect("images/player.png", screenHeight*0.5, screenHeight*0.5)
        playerImg.x = display.contentCenterX; playerImg.y = display.contentCenterY + screenHeight * 0.4
        playerImg.alpha = 0
        sceneGroup:insert(playerImg)
        
        -- set game name anime
        local fillArea = display.newRoundedRect(display.contentCenterX, display.contentCenterY-screenHeight*0.2, screenWidth*1, screenHeight*0.2, screenHeight*0.05)
        fillArea:setFillColor(1, 1, 1)  -- 設定矩形的填充顏色
        sceneGroup:insert(fillArea)
        
        nameShow = display.newText("勇闖地下城 : 失落的寶藏", display.contentCenterX, display.contentCenterY-screenHeight*0.15, "Silver.ttf", 64)
        nameShow:setTextColor(0.5, 0.3, 0.3)
        sceneGroup:insert(nameShow)
        
        -- name anime
        local nameTurn = 0
        
        local name_turn = function()
            if (nameTurn == 0) then
                nameTurn = 1
                transition.to(fillArea, {time = 1000, alpha = 1})
                transition.to(nameShow, {time = 1000, alpha = 1})
            else
                nameTurn = 0
                transition.to(fillArea, {time = 1000, alpha = 0.5})
                transition.to(nameShow, {time = 1000, alpha = 0.5})
            end
        end
        timer_group = timer.performWithDelay(1000, name_turn, 0)
        
        -- button -------------------------------
        local b_Press = function( event )
            audio.stop(26)
            audio.play(btn_press,{channel=26, loops=0})
        end
        
        -- go to scene: battle_field
        local b_Release = function( event )
            
            local selectArea = display.newRect(display.contentCenterX, display.contentCenterY, screenWidth*1.6, screenHeight*1.2)
            selectArea:setFillColor(0, 0, 0, 0.5)  -- 設定矩形的填充顏色
            sceneGroup:insert(selectArea)
            
            -- set visible
            start_btn.isVisible = false
            fillArea.isVisible = false
            nameShow.isVisible = false
            
            -- play btn sound
            audio.stop(26)
            audio.play(btn_release,{channel=26, loops=0})
            
            -- func (go to field) ----------------------------------------------------------
            local goToField = function()
                -- play btn sound
                audio.stop(26)
                audio.play(btn_release,{channel=26, loops=0})
                
                -- set button visible
                selectArea.isVisible = false
                easy_btn.isVisible = false
                normal_btn.isVisible = false
                hard_btn.isVisible = false
                hell_btn.isVisible = false
                
                -- player show
                audio.play(walking,{channel=25, loops=-1})
                transition.to(playerImg, { time = 1000, y = display.contentCenterY + screenHeight * 0.25, alpha = 1})
                
                -- func (delay to wait playerImg show) --
                local waitPlayerShow = function()
                    -- set player go in
                    transition.to(playerImg, { time = 3000, width = screenHeight * 0.1, height = screenHeight * 0.1, y = display.contentCenterY - screenHeight * 0.2 ,alpha = 0})
                    
                    -- func (delay to go battle field)
                    local delayToField = function()
                        audio.stop(25)
                        composer.gotoScene( "battle_field", { effect="fade", time=500 } )
                    end
                    
                    timer.performWithDelay(3000, delayToField)
                end
                
                timer.performWithDelay(1000, waitPlayerShow)
            end
            -- func (go to field) end ------------------------------------------------------
            
            -- easy button ------------------------------------------------------------
            local easy_Press = function( event )
                audio.stop(26)
                audio.play(btn_press,{channel=26, loops=0})
            end
            
            local easy_Release = function( event )
                difficulty = 1
                goToField()
            end
            
            easy_btn = widget.newButton
            {
                width = screenHeight * 0.6,
                height = screenHeight * 0.2,
                defaultFile = "images/easy_btn.png",
                emboss = true,
                onPress = easy_Press,
                onRelease = easy_Release,
            }
            easy_btn.x = display.contentCenterX - screenWidth * 0.25
            easy_btn.y = display.contentCenterY - screenHeight * 0.2
            sceneGroup:insert(easy_btn)
            -- easy button end --------------------------------------------------------
            
            -- normal button ----------------------------------------------------------
            local normal_Press = function( event )
                audio.stop(26)
                audio.play(btn_press,{channel=26, loops=0})
            end
            
            local normal_Release = function( event )
                difficulty = 2
                goToField()
            end
            
            normal_btn = widget.newButton
            {
                width = screenHeight * 0.6,
                height = screenHeight * 0.2,
                defaultFile = "images/normal_btn.png",
                emboss = true,
                onPress = normal_Press,
                onRelease = normal_Release,
            }
            normal_btn.x = display.contentCenterX + screenWidth * 0.25
            normal_btn.y = display.contentCenterY - screenHeight * 0.2
            sceneGroup:insert(normal_btn)
            -- normal button end ------------------------------------------------------
            
            -- hard button ------------------------------------------------------------
            local hard_Press = function( event )
                audio.stop(26)
                audio.play(btn_press,{channel=26, loops=0})
            end
            
            local hard_Release = function( event )
                difficulty = 3
                goToField()
            end
            
            hard_btn = widget.newButton
            {
                width = screenHeight * 0.6,
                height = screenHeight * 0.2,
                defaultFile = "images/hard_btn.png",
                emboss = true,
                onPress = hard_Press,
                onRelease = hard_Release,
            }
            hard_btn.x = display.contentCenterX - screenWidth * 0.25
            hard_btn.y = display.contentCenterY + screenHeight * 0.2
            sceneGroup:insert(hard_btn)
            -- hard button end --------------------------------------------------------
            
            -- hell button ------------------------------------------------------------
            local hell_Press = function( event )
                audio.stop(26)
                audio.play(btn_press,{channel=26, loops=0})
            end
            
            local hell_Release = function( event )
                difficulty = 4
                goToField()
            end
            
            hell_btn = widget.newButton
            {
                width = screenHeight * 0.6,
                height = screenHeight * 0.2,
                defaultFile = "images/hell_btn.png",
                emboss = true,
                onPress = hell_Press,
                onRelease = hell_Release,
            }
            hell_btn.x = display.contentCenterX + screenWidth * 0.25
            hell_btn.y = display.contentCenterY + screenHeight * 0.2
            sceneGroup:insert(hell_btn)
            -- hell button end --------------------------------------------------------
        end
        
        -- set start button
        start_btn = widget.newButton
        {
            width = screenWidth*0.45,
            height = screenHeight*0.15,
            defaultFile = "images/start_btn1.png",
            overFile = "images/start_btn2.png",
            emboss = true,
            onPress = b_Press,
            onRelease = b_Release,
        }
        start_btn.x = display.contentCenterX
        start_btn.y = display.contentCenterY + screenHeight*0.25
        sceneGroup:insert(start_btn)
        
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
        
        -- stop bgm
        audio.stop(31)
        audio.dispose(bgm_lobby)
        bgm_lobby = nil
        
    elseif ( phase == "did" ) then
        -- Called immediately after scene goes off screen
        composer.removeScene("start")
        
    end
end


-- "scene:destroy()"
function scene:destroy( event )

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
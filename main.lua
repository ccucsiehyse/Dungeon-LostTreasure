local composer = require( "composer" )

-- set global
screenWidth = display.contentWidth --contentWidth --pixelWidth (screen size)
screenHeight = display.contentHeight --contentHeight --pixelHeight
difficulty = 1

-- set sound
bossSound = {audio.loadStream("images/boss_coming.mp3"), audio.loadStream("images/boss_bgm.mp3"), audio.loadStream("images/boss_roar.mp3"), audio.loadStream("images/boss_youll_die.mp3"), audio.loadStream("images/boss_die.mp3")} -- channel 24
walking = audio.loadStream("images/walk.mp3") -- channel 25
btn_press = audio.loadStream("images/btn_press.ogg") -- channel 26
btn_release = audio.loadStream("images/btn_release.ogg") -- channel 26
btn_skill = audio.loadStream("images/btn_skill.ogg") -- channel 26
swing = audio.loadStream("images/swing2.mp3") -- channel 27
skillEND = audio.loadStream("images/skill_end.mp3") -- channel 28
get_hit = { audio.loadStream("images/blood.ogg"), audio.loadStream("images/get_hit2.ogg"), audio.loadStream("images/get_hit3.ogg") } -- chaneel 28
halfHPShow = audio.loadStream("images/halfHPShow.mp3") -- channel 29
ultraShow = audio.loadStream("images/ultra_btnShow.ogg") -- channel 29
winSound = audio.loadStream("images/winning.mp3") -- channel 29
coinSound = {audio.loadStream("images/coinSound.mp3"), audio.loadStream("images/flip_coin.ogg")} -- channel 30
ritual = audio.loadStream("images/ritual.ogg") -- channel 32
preBomb = audio.loadStream("images/prebomb.mp3") -- channel 32
magicSound = {audio.loadStream("images/magic1.mp3"), audio.loadStream("images/magic2.ogg")}

composer.gotoScene( "start", options )  --options
--[[

//------------------------------------------------------//
Haiku's Visual Novel Engine V0.2
(Build 12/25/23)

Feature Set:
- BGM handling.
- Sprite handling.
- Subject handling.
- A new dialogue scripting-like system.

Note:
This engine uses Key Visual Novels as a base.
The likes of Rewrite, Clannad, etc. are all examples of
what this engine is based off of.

LICENSE:
This module is free to be used in your game freely.
You may modify it to your liking.

You cannot sell this module in any way.
You must credit me, if you decide to use it in a project. :p

Source is available on Github, along with its documentation.

//------------------------------------------------------//
]]

local vnEngine = {}

local VA = workspace:WaitForChild('VA')
local BGM = workspace:WaitForChild('BGM')
local sprite = workspace:WaitForChild('Sprite')
_G.clientSide = script.Parent:WaitForChild('clannad')

local dialogueFrame = _G.clientSide.Dialogue.main
local dialogueLine = dialogueFrame.dialogueLine
local subjectLine = dialogueFrame.dialogueSubFrame.subject

local richTextBegin = [[<stroke color="]]
local richTextEnd = [[" joins="miter" thickness="1.5" transparency="0.5">]]
local richTextClose = [[</stroke>]]

local defaultRichBegin = [[<stroke color="#000000" joins="miter" thickness="1.5" transparency="0.5">]]
local defaultRichEnd = [[</stroke>]]

local TS = game:GetService("TweenService")

_G.lastVoice = nil
local lastBGM
_G.currBGM = nil
_G.activeVoice = false

--// Settings
local bgmFade = script.Configuration:WaitForChild("bgmFade").Value

--// bgmFade being enabled will turn down the volume of the BGM temporarily while a voice line is active. (Rewrite)
--// This is experiemental!
--// Constant

local theme = script.Configuration:WaitForChild("theme").Value

local possibleThemes = {"clannad", "narClassic"}

--// Theme Handling

function vnEngine.handleTheming() -- Global since this should be handled in both scripts.
	
	-- Enable theme
	for index, value in ipairs(possibleThemes) do
		if value == theme then
			warn('[HVN Debug] Theme selected: '..value)
			script.Parent:WaitForChild(value).Enabled = true
			
			-- Set clientSide global, and update dialogueFrame vars to enable instant reflect.
			_G.clientSide = script.Parent:WaitForChild(value)
			dialogueFrame = _G.clientSide.Dialogue.main
			dialogueLine = dialogueFrame.dialogueLine
			subjectLine = dialogueFrame.dialogueSubFrame.subject
			break
		end
	end
	
	-- Disable others
	for index = 1, #possibleThemes do
		if theme ~= possibleThemes[index] then
			script.Parent:WaitForChild(possibleThemes[index]).Enabled = false
		end
	end
end

-- Play a BGM.
function vnEngine.BGM(bgmName: string, fadeOut: boolean, fadeIn: boolean, fadeDuration: number)
	_G.currBGM = bgmName
	--// Arguments Documentation:
	
	-- 1. bgmName (string; required): The name of the BGM to play.
	-- 2. fadeOut (boolean; optional): Whether or not to fade out the current BGM.
	-- 3. fadeIn (boolean; optional): Whether or not to fade in this BGM after it starts playing.
	-- 4. fadeDuration (boolean; required IF fade is enabled): How long (in seconds) should the fading take place for.
	if lastBGM ~= nil then
		BGM:WaitForChild(lastBGM):Stop()
	end
	lastBGM = bgmName
	if fadeOut == false or fadeOut == nil and fadeIn == false or fadeIn == nil then -- rough ;(
		BGM:WaitForChild(bgmName).Looped = true
		BGM:WaitForChild(bgmName):Play()
	elseif fadeIn == true or fadeOut == true then
		if fadeIn then
			local tI = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear)
			local tw = TS:Create(BGM:WaitForChild(bgmName), tI, {Volume = 0.5})
			BGM:WaitForChild(bgmName).Looped = true
			BGM:WaitForChild(bgmName).Volume = 0
			BGM:WaitForChild(bgmName):Play()
			tw:Play()
		elseif fadeOut then
			local tI = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear)
			local tw = TS:Create(BGM:WaitForChild(bgmName), tI, {Volume = 0})
			tw:Play()
			script.bgmFadeHandler.Disabled = true
		end
	end
end

-- Play an audio clip that goes with a dialogue line.
function vnEngine.playAudioClip(audioClip)
	_G.lastVoice = audioClip
	_G.activeVoice = true
	if bgmFade then
		script.bgmFadeHandler.Enabled = true
		local tI = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
		local tw = TS:Create(BGM:WaitForChild(lastBGM), tI, {Volume = 0.25})
		local twIn = TS:Create(BGM:WaitForChild(lastBGM), tI, {Volume = 0.5})
		tw:Play()
		VA:WaitForChild(audioClip):Play()
	elseif not bgmFade then
		VA:WaitForChild(audioClip):Play()
	end
end

local function subjectColor(subject, text, color)
	if subject == "nil" or subject == nil then
		dialogueFrame.dialogueSubFrame.Visible = false
	else
		dialogueFrame.dialogueSubFrame.Visible = true
		dialogueFrame.dialogueSubFrame.subject.Text = defaultRichBegin..subject..defaultRichEnd
	end
	if color == "nil" or color == nil then
		dialogueLine.Text = defaultRichBegin..text..defaultRichEnd -- ?!
	else
		dialogueLine.Text = richTextBegin..color..richTextEnd..text..richTextClose -- ?!
	end
end

local function textNarClassic(text) -- Rich text is not supported.
	dialogueLine.Text = text
end

function vnEngine.sayDialogue(subject: string, text: string, color: string, voiceName: string, soundFX: string)
	warn('[HVN Debug] The dialogue module was passed with subject: '..tostring(subject)..' Text: '..tostring(text)..' Color: '..tostring(color)..' VoiceName: '..tostring(voiceName)..' soundFX: '..tostring(soundFX))
	if theme == 'narClassic' then
		textNarClassic(text)
	else
		subjectColor(subject, text, color)
	end
	if soundFX == "nil" or soundFX == nil then -- Not implemented.
		
	end
	if voiceName == "nil" or voiceName == nil then
		if _G.lastVoice ~= nil then
			VA:WaitForChild(_G.lastVoice):Stop()
			_G.activeVoice = false
		end
	else
		if _G.lastVoice ~= nil then
			VA:WaitForChild(_G.lastVoice):Stop()
			_G.activeVoice = false
		end
		_G.lastVoice = voiceName
		warn('[HVN Debug] Last Voice was: '..tostring(_G.lastVoice))
		vnEngine.playAudioClip(voiceName)
	end
	
end

function vnEngine.swapSprite(spriteName: string, tweenType: string)
	if theme == 'narClassic' then
		print('The theme selected doesn\'t support this function.')
	else
		--// Arguments Documentation:

		-- 1. SpriteName (string; required). The name of the image in your explorer. Just like voice lines.
		--// Ex. yoshino_agr
		-- 2. TweenType (string; required). The type of tween you want.
		--// Valid types are "fadeIn"; "fadeOut"; and "swap"
		--// "Swap" will seamlessless transition between two sprites. This is inspired from Rewrite, where emotions fade between each other.

		local tI
		local tw
		-- Fade In
		-- Fade Out
		-- Swap

		if tweenType == "fadeIn" then
			tI = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
			tw = TS:Create(_G.clientSide.Dialogue.sprite, tI, {ImageTransparency = 0})
		elseif tweenType == "fadeOut" then
			tI = TweenInfo.new(0.25, Enum.EasingStyle.Linear)
			tw = TS:Create(_G.clientSide.Dialogue.sprite, tI, {ImageTransparency = 1})
		elseif tweenType == "swap" then -- 

		end
		_G.clientSide.Dialogue.sprite.Image = sprite:WaitForChild(spriteName).Image
		tw:Play()
	end
end

-- Plays the advance audio cue.

function vnEngine.playAdvance(soundId: string, disabled: boolean)
	if disabled then
		return nil
	elseif not disabled then
		BGM:WaitForChild('Core').sys_adv.SoundId = "rbxassetid://"..soundId
		BGM:WaitForChild('Core').sys_adv:Play()
	end
end

function vnEngine.sceneTransition(imageId: string, fade: boolean, fadeDuration: number)
	if fade then
		local tI = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear)
		local twO = TS:Create(_G.clientSide.BG, tI, {Transparency = 1})
	elseif not fade then
		_G.clientSide.BG.Image = "rbxassetid://"..imageId
	end
end

return vnEngine

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


-- Folder refernces (Assets)
local VA = workspace:WaitForChild('VA')
local BGM = workspace:WaitForChild('BGM')
local vnEngine = require(script.Parent)


--// Core

-- Services and Modules
local replicatedStorage = game:GetService('ReplicatedStorage')
local userInput = game:GetService('UserInputService')

-- Advance Sound Effect
-- You can put your own soundId in the configuration folder.
local advanceSoundId = script.Parent.Configuration.advanceSound.Value

local advanceSoundDisabled = true -- You can completely disable this feature here. (Defaults to true, because it's kinda annoying.)

local currentLine = 0 -- default value
local dialogue -- Global scope for the VA flags and other flag checks.

--//

local function inputWait()
	while true do
		local input = userInput.InputBegan:Wait()

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			vnEngine.playAdvance(advanceSoundId, advanceSoundDisabled)
			break
		end
	end
end

vnEngine.handleTheming() --// Required line for theme support.


local function dialogueScript() -- This is where you define lines. You can ommit arguments by replacing it with "nil"
	-- Arguments Documentation:
	-- 1. Subject
	    --// Name of the person speaking. Use "nil" to omit this field. When omitted, commonly in Visual Novels this represents the main character's inner dialogue.
	-- 2. Dialogue Line (String; Required!)
	-- 3. Text color (String (Hex); Optional)
	    --// Ex. "#ffce53" or "nil" if none.
	-- 4. Voice Line Name (String; Optional)
	    --// Ex. "yoshino_2". This string should be the name of your sound in the explorer! Make sure they match!
	-- 5. Sound effect (String; Optional)
	--// Ex. "bang_1". This string should ALSO equal the name of your sound in the explorer!
	vnEngine.BGM("dis_pain")
	wait(3)
	vnEngine.swapSprite("yoshino_agr", "fadeIn")
	vnEngine.sayDialogue("Yoshino", [["That's it. I can't take this anymore..."]], "nil", "yoshino_1", "nil")
	inputWait() -- This function is used to handle input. Awful system I know. You must put this between dialogue lines.
	vnEngine.sayDialogue("nil", "Yoshino Haruhiko -- the only delinquent in our class -- gives me a deadly stare.")
	inputWait()
	vnEngine.sayDialogue("Yoshino", [["Tennouji, it's time to duel!"]], "nil", "yoshino_2")
	inputWait()
	vnEngine.sayDialogue("Kotarou", [["Sorry, but I'm not really into card games..."]], "#ffce53")
	inputWait()
end

dialogueScript()

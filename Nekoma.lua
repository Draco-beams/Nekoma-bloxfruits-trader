-- Blox Fruits Auto-Farm with Level-Based Auto Quest, Skill Spam, and Anti-AFK

local VirtualUser = game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
    -- Anti-AFK: Simulate right-click to avoid being idle
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Global Configurations
_G.AutoFarm = true
_G.AutoQuest = true
_G.SpamSkills = true

-- Function to grab the quest based on the player's level
local function GetQuestForLevel(level)
    local quests = {
        [1] = "Quest1NPC",   -- Example: Level 1 quest NPC
        [10] = "Quest2NPC",  -- Example: Level 10 quest NPC
        [20] = "Quest3NPC",  -- Example: Level 20 quest NPC
        [30] = "Quest4NPC",  -- Example: Level 30 quest NPC
        [40] = "Quest5NPC",  -- Example: Level 40 quest NPC
        [50] = "Quest6NPC",  -- Example: Level 50 quest NPC
    }

    local questNpc = nil
    for questLevel, npcName in pairs(quests) do
        if level >= questLevel then
            questNpc = npcName
        end
    end
    return questNpc
end

-- Function to accept quest from a given NPC
local function AcceptQuest(questNpcName)
    local questNPC = game.Workspace:FindFirstChild(questNpcName)
    if questNPC then
        print("Found quest NPC: " .. questNpcName)
        -- Iterate through the NPC's children to find the ClickDetector
        for _, npc in pairs(questNPC:GetChildren()) do
            if npc:IsA("Model") and npc:FindFirstChild("ClickDetector") then
                -- Auto-click to accept the quest
                fireclickdetector(npc.ClickDetector)
                print("Quest Accepted")
                return true
            end
        end
    else
        print("Quest NPC not found: " .. questNpcName)
    end
    return false
end

-- Function to spam skills (like X and C)
local function UseSkills()
    -- Spam skills like X and C (Modify or add more as needed)
    game:GetService("VirtualInputManager"):SendKeyEvent(true, "X", false, game)  -- Spam X skill
    wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "X", false, game)

    game:GetService("VirtualInputManager"):SendKeyEvent(true, "C", false, game)  -- Spam C skill
    wait(0.1)
    game:GetService("VirtualInputManager"):SendKeyEvent(false, "C", false, game)
end

spawn(function()
    while _G.AutoFarm do
        pcall(function()
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            local level = player.Data.Level.Value  -- Assuming your level is stored in player.Data.Level.Value

            -- Debug: Print current level
            print("Current Level: " .. level)
            
            if humanoid then
                local targetMob = nil
                local maxDistance = 100  -- Max distance to target NPCs (adjust as needed)

                -- Find the nearest enemy within a max distance
                for i, v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                        local distance = (character.HumanoidRootPart.Position - v.HumanoidRootPart.Position).Magnitude

                        if distance < maxDistance then
                            targetMob = v
                            break
                        end
                    end
                end

                if targetMob then
                    -- Auto-accept the quest based on your level
                    if _G.AutoQuest then
                        local questNpcName = GetQuestForLevel(level)
                        if questNpcName then
                            AcceptQuest(questNpcName)
                        else
                            print("No quest available for level " .. level)
                        end
                    end

                    repeat
                        wait()

                        -- Move towards the target NPC's HumanoidRootPart
                        local targetPosition = targetMob.HumanoidRootPart.CFrame.Position
                        character.HumanoidRootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 10, 0)) -- Adjust to maintain good attack distance
                        
                        -- Use skills if enabled
                        if _G.SpamSkills then
                            UseSkills()
                        end

                        -- Simulate pressing "Z" (or attack key, depending on game) to attack the target
                        game:GetService("VirtualInputManager"):SendKeyEvent(true, "Z", false, game)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false, "Z", false, game)

                    until targetMob.Humanoid.Health <= 0 or not _G.AutoFarm
                end
            end
        end)
        wait(0.5)
    end
end)

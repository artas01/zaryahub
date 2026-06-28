-- AutoBattle Script with Rayfield UI
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ============================================================
-- CONFIGURATION
-- ============================================================

local Config = {
    Enabled = true,
    StartDelay = 1.0,
    FullAuto = true,
    WildEncounters = true,
    TrainerBattles = true,
    NpcBattles = true,
    BossBattles = false,
    DungeonEncounters = true,
    PvP = false,
    AutoSelectSkill = false,
    AutoSwitch = true,
    AutoCatch = false,
    ActionDelay = 0.5,
    BattleSpeedMult = 10,
}

local isActive = false
local currentBattleType = nil

-- ============================================================
-- GET REMOTES
-- ============================================================

local Remote = ReplicatedStorage:FindFirstChild("Remote")
if not Remote then return end

local BattleRemote = Remote:FindFirstChild("Battle")
if not BattleRemote then return end

local ReqAutoBattle = BattleRemote:FindFirstChild("ReqAutoBattle")
local ReqOperateBattle = BattleRemote:FindFirstChild("ReqOperateBattle")

-- ============================================================
-- GET BINDABLES
-- ============================================================

local Bindable = ReplicatedStorage:FindFirstChild("Bindable")
local BattleBindable = Bindable and Bindable:FindFirstChild("Battle")
local ClientBattleStart = BattleBindable and BattleBindable:FindFirstChild("ClientBattleStart")

-- ============================================================
-- GET SERVICES
-- ============================================================

local Script = ReplicatedStorage:FindFirstChild("Script")
local BattleScript = Script and Script:FindFirstChild("Battle")
local BattleService = nil

if BattleScript then
    pcall(function()
        BattleService = require(BattleScript:WaitForChild("BattleService", 10))
    end)
end

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

local function isBattleTypeEnabled(battleType)
    if battleType == 1 then return Config.WildEncounters
    elseif battleType == 4 then return Config.TrainerBattles
    elseif battleType == 3 then return Config.BossBattles
    elseif battleType == 6 then return Config.DungeonEncounters
    elseif battleType == 5 then return Config.PvP
    end
    return true
end

local function getBattleType()
    if not BattleService then return nil end
    local battle = BattleService.getCurrentBattle()
    if battle and type(battle) == "table" then
        return battle.type
    end
    return nil
end

local function enableAutoBattle()
    if not ReqAutoBattle then return false end
    
    local success, result = pcall(function()
        return ReqAutoBattle:InvokeServer(Config.FullAuto)
    end)
    
    if success then
        isActive = true
        return true
    end
    return false
end

local function disableAutoBattle()
    if not ReqAutoBattle then return end
    pcall(function()
        ReqAutoBattle:InvokeServer(false)
    end)
    isActive = false
end

-- ============================================================
-- BATTLE MONITOR
-- ============================================================

local function onBattleStart()
    if not Config.Enabled then return end
    
    local battleType = getBattleType()
    currentBattleType = battleType
    
    if not isBattleTypeEnabled(battleType) then return end
    
    task.delay(Config.StartDelay, function()
        enableAutoBattle()
    end)
end

local function onBattleEnd()
    isActive = false
    currentBattleType = nil
end

if ClientBattleStart then
    ClientBattleStart.Event:Connect(onBattleStart)
end

if BattleRemote:FindFirstChild("ResSettleBattle") then
    BattleRemote.ResSettleBattle.OnClientEvent:Connect(function()
        task.wait(0.5)
        onBattleEnd()
    end)
end

-- ============================================================
-- AUTO-ACTION LOOP
-- ============================================================

task.spawn(function()
    while true do
        task.wait(Config.ActionDelay)
        
        if not isActive or not Config.Enabled then continue end
        
        if not Config.FullAuto and ReqOperateBattle then
            pcall(function()
                local actionData = {
                    actionType = 1,
                    skillId = 0,
                    targetCampId = 2,
                    targetPos = 1,
                }
                ReqOperateBattle:InvokeServer(actionData)
            end)
        end
    end
end)

-- ============================================================
-- BATTLE SPEED HACK
-- ============================================================

task.spawn(function()
    local ScriptFolder = ReplicatedStorage:FindFirstChild("Script", 15)
    if not ScriptFolder then return end
    
    local BattleChoreo = ScriptFolder:FindFirstChild("BattleChoreo", 15)
    if not BattleChoreo then return end
    
    local Basic = BattleChoreo:FindFirstChild("Basic", 15)
    if not Basic then return end
    
    local ChoreoConstModule = Basic:FindFirstChild("BattleChoreoConst", 15)
    if not ChoreoConstModule then return end
    
    local success, CC = pcall(require, ChoreoConstModule)
    
    if success and type(CC) == "table" then
        local mult = Config.BattleSpeedMult
        
        if type(CC.DefaultActionWaitTime) == "number" then
            CC.DefaultActionWaitTime = CC.DefaultActionWaitTime / mult
        end
        if type(CC.SettleNodeWaitTime) == "number" then
            CC.SettleNodeWaitTime = CC.SettleNodeWaitTime / mult
        end
        if type(CC.StartBattleBeforeChoreographyDelayTime) == "number" then
            CC.StartBattleBeforeChoreographyDelayTime = CC.StartBattleBeforeChoreographyDelayTime / mult
        end
        
        if type(CC.ActionWaitTimeByType) == "table" then
            for k, v in pairs(CC.ActionWaitTimeByType) do
                if type(v) == "number" then
                    CC.ActionWaitTimeByType[k] = v / mult
                end
            end
        end
    end
    
    -- SkillPerformanceCfg
    local Pet = ScriptFolder:FindFirstChild("Pet", 15)
    if not Pet then return end
    
    local Cfg = Pet:FindFirstChild("Cfg", 15)
    if not Cfg then return end
    
    local SkillCfgModule = Cfg:FindFirstChild("SkillPerformanceCfg", 15)
    if not SkillCfgModule then return end
    
    local success2, SC = pcall(require, SkillCfgModule)
    
    if success2 and type(SC) == "table" then
        local mult = Config.BattleSpeedMult
        
        for skillId, data in pairs(SC) do
            if type(data) == "table" and type(data.finishWaitTime) == "number" then
                data.finishWaitTime = math.max(50, math.floor(data.finishWaitTime / mult))
            end
        end
    end
end)

-- ============================================================
-- RAYFIELD UI
-- ============================================================

local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
    Name = "Auto Battle",
    Icon = 0,
    LoadingTitle = "Loading...",
    LoadingSubtitle = "by Script",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "AutoBattleConfig",
       FileName = "Settings"
    },
    Discord = {
       Enabled = false
    },
    KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main", 0)

local MainSection = MainTab:CreateSection("Auto Battle Settings")

MainTab:CreateToggle({
    Name = "Enable Auto Battle",
    CurrentValue = Config.Enabled,
    Flag = "AutoBattleEnabled",
    Callback = function(Value)
        Config.Enabled = Value
        if not Value and isActive then
            disableAutoBattle()
        end
    end,
})

MainTab:CreateToggle({
    Name = "Full Auto Mode",
    CurrentValue = Config.FullAuto,
    Flag = "FullAutoMode",
    Callback = function(Value)
        Config.FullAuto = Value
        if isActive then
            enableAutoBattle()
        end
    end,
})

MainTab:CreateSlider({
    Name = "Start Delay (seconds)",
    Range = {0, 5},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = Config.StartDelay,
    Flag = "StartDelay",
    Callback = function(Value)
        Config.StartDelay = Value
    end,
})

MainTab:CreateSlider({
    Name = "Action Delay (seconds)",
    Range = {0.1, 2},
    Increment = 0.1,
    Suffix = "s",
    CurrentValue = Config.ActionDelay,
    Flag = "ActionDelay",
    Callback = function(Value)
        Config.ActionDelay = Value
    end,
})

MainTab:CreateSlider({
    Name = "Battle Speed Multiplier",
    Range = {1, 20},
    Increment = 1,
    Suffix = "x",
    CurrentValue = Config.BattleSpeedMult,
    Flag = "BattleSpeed",
    Callback = function(Value)
        Config.BattleSpeedMult = Value
    end,
})

-- Battle Types Tab
local BattleTab = Window:CreateTab("Battle Types", 1)

local BattleSection = BattleTab:CreateSection("Enable Battle Types")

BattleTab:CreateToggle({
    Name = "Wild Encounters",
    CurrentValue = Config.WildEncounters,
    Flag = "WildEncounters",
    Callback = function(Value)
        Config.WildEncounters = Value
    end,
})

BattleTab:CreateToggle({
    Name = "Trainer Battles",
    CurrentValue = Config.TrainerBattles,
    Flag = "TrainerBattles",
    Callback = function(Value)
        Config.TrainerBattles = Value
    end,
})

BattleTab:CreateToggle({
    Name = "NPC Battles",
    CurrentValue = Config.NpcBattles,
    Flag = "NpcBattles",
    Callback = function(Value)
        Config.NpcBattles = Value
    end,
})

BattleTab:CreateToggle({
    Name = "Boss Battles",
    CurrentValue = Config.BossBattles,
    Flag = "BossBattles",
    Callback = function(Value)
        Config.BossBattles = Value
    end,
})

BattleTab:CreateToggle({
    Name = "Dungeon Encounters",
    CurrentValue = Config.DungeonEncounters,
    Flag = "DungeonEncounters",
    Callback = function(Value)
        Config.DungeonEncounters = Value
    end,
})

BattleTab:CreateToggle({
    Name = "PvP Battles",
    CurrentValue = Config.PvP,
    Flag = "PvP",
    Callback = function(Value)
        Config.PvP = Value
    end,
})

-- Advanced Tab
local AdvancedTab = Window:CreateTab("Advanced", 2)

local AdvancedSection = AdvancedTab:CreateSection("Advanced Options")

AdvancedTab:CreateToggle({
    Name = "Auto Select Skill",
    CurrentValue = Config.AutoSelectSkill,
    Flag = "AutoSelectSkill",
    Callback = function(Value)
        Config.AutoSelectSkill = Value
    end,
})

AdvancedTab:CreateToggle({
    Name = "Auto Switch Pet",
    CurrentValue = Config.AutoSwitch,
    Flag = "AutoSwitch",
    Callback = function(Value)
        Config.AutoSwitch = Value
    end,
})

AdvancedTab:CreateToggle({
    Name = "Auto Catch (Wild)",
    CurrentValue = Config.AutoCatch,
    Flag = "AutoCatch",
    Callback = function(Value)
        Config.AutoCatch = Value
    end,
})

-- Status Tab
local StatusTab = Window:CreateTab("Status", 3)

local StatusSection = StatusTab:CreateSection("Current Status")

StatusTab:CreateLabel("Auto Battle Status:")
StatusTab:CreateLabel("• Enabled: " .. tostring(Config.Enabled))

StatusTab:CreateLabel("Current Battle Status:")
local StatusLabel = StatusTab:CreateLabel("• Not in battle")

-- Update status
task.spawn(function()
    while true do
        task.wait(1)
        local status = isActive and "Active" or "Inactive"
        local battleType = currentBattleType or "None"
        StatusLabel:Set("• Status: " .. status .. " | Battle Type: " .. tostring(battleType))
    end
end)

-- Buttons
local ButtonSection = MainTab:CreateSection("Controls")

MainTab:CreateButton({
    Name = "Enable Auto Battle Now",
    Callback = function()
        Config.Enabled = true
        enableAutoBattle()
    end,
})

MainTab:CreateButton({
    Name = "Disable Auto Battle",
    Callback = function()
        Config.Enabled = false
        disableAutoBattle()
    end,
})

MainTab:CreateButton({
    Name = "Refresh Battle Detection",
    Callback = function()
        local battleType = getBattleType()
        if battleType then
            currentBattleType = battleType
        end
    end,
})

print("Auto Battle UI Loaded Successfully!")

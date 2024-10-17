local mod = RegisterMod("The Stupidity of Isaac", 1) --tells isaac the mod exists
local BeerBottle = Isaac.GetItemIdByName("Beer Bottle") --gets item id
local BeerBottleDamage = 3
local BeerBottleSpeed = 0.5
local Beer_Posion_Chance = 1
local i = 0
local Beer_Poison_Length = 3
local One_Interval_Of_Poison = 20 -- this fucks up if the user is running the game higher than 60 fps
local tearmulti = 1.5
local hasap = false

function mod:EvaluateCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then -- cacheflags makes the stat values update
        local itemcount = player:GetCollectibleNum(BeerBottle) -- how many of these items do the players have
        local damagetoAdd = BeerBottleDamage * itemcount 
        player.Damage = player.Damage + damagetoAdd
	end
    if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
        local itemcounts = player:GetCollectibleNum(BeerBottle)
        if itemcounts >= 1 then
            local speedtoAdd = BeerBottleSpeed
            player.MoveSpeed = player.MoveSpeed + speedtoAdd
                    end
                end
            end
local game = Game()
function mod:BeerBottleNewRoom() --yeah this gets the enemies in the room and adds the poison effect to them idk how this works but it does
                local playerCount = game:GetNumPlayers()
            
                for playerIndex = 0, playerCount - 1 do
                    local player = Isaac.GetPlayer(playerIndex)
                    local copyCount = player:GetCollectibleNum(BeerBottle)
            
                    if copyCount > 0 then
                        local rng = player:GetCollectibleRNG(BeerBottle)
            
                        local entities = Isaac.GetRoomEntities()
                        for _, entity in ipairs(entities) do
                            if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
                                if rng:RandomFloat() < Beer_Posion_Chance then
                                    entity:AddPoison(
                                        EntityRef(player),
                                        Beer_Poison_Length + (One_Interval_Of_Poison * copyCount),
                                        player.Damage
                                    )
                                end
                            end
                        end
                    end
                end
            end          
 mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.BeerBottleNewRoom)
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.EvaluateCache)

local PEAK = Isaac.GetItemIdByName("The Peak")

function mod:PeakUse(item)
    local roomEntities = Isaac.GetRoomEntities() -- gets enemies in the room and then on item use kills them
    for _, entity in ipairs(roomEntities) do
        if entity:IsActiveEnemy() and entity:IsVulnerableEnemy() then
            entity:Kill()
        end
    end
        return{
            Discharge = true,
            Remove = false,
            ShowAnim = true
        }
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.PeakUse, PEAK)
local Torch = Isaac.GetItemIdByName("Torch") -- big  stats up
function mod:Torch(player, cacheFlags)
    local TORCHITEMCOUNT = player:GetCollectibleNum(Torch)
    if TORCHITEMCOUNT > 0 then
        if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 0.8
            if hasap == false then
                player.MaxFireDelay = player.MaxFireDelay +- tearmulti
                hasap =  true
            end
        end
        if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.17
        end
        if cacheFlags & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + 0.8
        end
        if cacheFlags & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + 70
        end
        if cacheFlags & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.12
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.Torch)
local DEATH = Isaac.GetItemIdByName("Death") -- meme item adds infinite damage but no tears
function mod:Death(player, cacheFlags)
    local Deathitemcount = player:GetCollectibleNum(DEATH)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        local DEATHDAMAGE = 999999
        if Deathitemcount > 0 then
            player.Damage = player.Damage  + DEATHDAMAGE
            player.MaxFireDelay = 2000
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.Death)
local LIFE = Isaac.GetItemIdByName("Life") -- opposite of death
function mod:Life(player, cacheFlags)
    local Lifeitemcount = player:GetCollectibleNum(LIFE)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        if Lifeitemcount > 0 then
            player.Damage = 0.1
            player.MaxFireDelay = -2000
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.Life)
local TMG = Isaac.GetItemIdByName("The Middle Ground") -- actually good mixes death and life
function mod:TMG(player, cacheFlags)
    local TMGITEMCOUNT = player:GetCollectibleNum(TMG)
    if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
        if TMGITEMCOUNT > 0 then
            player.Damage = player.Damage + 6
            if hasap == false then
                player.MaxFireDelay = player.MaxFireDelay +- tearmulti
                hasap =  true
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.TMG)

local LD = Isaac.GetItemIdByName("Lucky Damage")
local lastDamage = nil -- To store the player's last known damage value

function mod:LuckyDamage(player, cacheFlags)
    local LDITEMCOUNT = player:GetCollectibleNum(LD)
    
    -- Check if the player has the item and if we're updating the damage cache flag
    if LDITEMCOUNT > 0 then
        -- If this is the first time the item is picked up (lastDamage is nil), initialize lastDamage
        if lastDamage == nil then
            lastDamage = player.Damage
            -- Apply the initial luck adjustment based on the player's current damage
            player.Luck = player.Luck + (player.Damage * 0.3)
        end
        
        -- Check if the player's damage has changed since the last update
        if player.Damage ~= lastDamage then
            -- Reset the player's luck to prevent stacking
            player.Luck = player.Luck - (lastDamage or 0) * 0.3
            
            -- Update the player's luck based on the new damage
            player.Luck = player.Luck + (player.Damage * 0.3)
            
            -- Store the current damage value for future comparisons
            lastDamage = player.Damage
        end
    end
end

-- Callback for updating stats whenever the cache is recalculated
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.LuckyDamage)

local fiftycens = Isaac.GetItemIdByName("50 Cent")
local hasAddedCoins = false
function mod:fiftycent(player)
    local fiftycentitmc = player:GetCollectibleNum(fiftycens)
    if fiftycentitmc > 0 and hasAddedCoins == false then
        Isaac.GetPlayer():AddCoins(50) -- 50 cent holy shit
        hasAddedCoins = true
    end    
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.fiftycent)

local AllUP = Isaac.GetItemIdByName("All Up")
local Hasadded = false
function mod:allup(player, cacheFlags)
    local Allupcs = player:GetCollectibleNum(AllUP)
    if Allupcs > 0 and Hasadded == false then -- same as torch but adds some coins and bombs and keys
        Isaac.GetPlayer():AddCoins(10)
        Isaac.GetPlayer():AddBombs(5)
        Isaac.GetPlayer():AddKeys(5)
        Hasadded = true
    end
    if Allupcs > 0 then
        if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 1
            player.MaxFireDelay = player.MaxFireDelay / tearmulti
        end
        if cacheFlags & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + 0.2
        end
        if cacheFlags & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + 1
        end
        if cacheFlags & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + 80
        end
        if cacheFlags & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + 0.2
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.allup)

local testerval = Isaac.GetItemIdByName("Tester")
local added = false -- this item is just fucked lol
function mod:Tester(player, cacheFlags)
    local testernum = player:GetCollectibleNum(testerval)
    local paayer = Isaac.GetPlayer()
    local position = Vector(0,0)
    if testernum > 0 and added ==  false then
        paayer:AddCoins(99)
        paayer:AddBombs(99)
        paayer:AddKeys(99)
        paayer:AddBlackHearts(2)
        paayer:AddBlueFlies(20, position, paayer)
        added = true
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.Tester)
local resth = Isaac.GetItemIdByName("Restored Heart")
function mod:RestoredHeart(item, player)
    local User = Isaac.GetPlayer() -- use with magic skin lol
        User:AddBrokenHearts(-1)
        User:AddMaxHearts(2)
        User:AddHearts(2)
    return{
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }

end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.RestoredHeart, resth)

local gs = Isaac.GetItemIdByName("Golden Surprise")
function mod:GoldenSurpriseUse(item, player)
    local gsuser= Isaac.GetPlayer()
    gsuser:AddGoldenBomb()--pretty self explanitory on what it does
    gsuser:AddGoldenKey()
    gsuser:AddGoldenHearts(1)
    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.GoldenSurpriseUse, gs)
local mm = Isaac.GetItemIdByName("Mother's Milk")
function mod:MotherM(player, cacheFlags)
    local mmcount = player:GetCollectibleNum(mm)
    if mmcount > 0 then
        if cacheFlags & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 15
            if hasap == false then
                player.MaxFireDelay = player.MaxFireDelay * (tearmulti + 1)
                hasap =  true 
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.MotherM)
local bads = Isaac.GetItemIdByName("Blue ArachDiptera")
function mod:bad(player, item) -- adds spiders and blue flies
    local baduser = Isaac.GetPlayer()
    local userpost = baduser.Position
    local spider = 0
    while spider < 5 do
        baduser:AddBlueSpider(userpost)
        spider = spider + 1
    end
    baduser:AddBlueFlies(5, userpost, baduser)
    return{
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.bad, bads)
local converto = Isaac.GetItemIdByName("Converto")
function mod:ConvertoUse(item, player)
    local convertouser = Isaac.GetPlayer()-- converts 5 coins into 2 bombs and 2 keys
    local money = convertouser:GetNumCoins()
    if money >= 5 then
        convertouser:AddCoins(-5)
        convertouser:AddBombs(2)
        convertouser:AddKeys(2)
    end
    if money < 5 then
        convertouser:AddCoins(0)
    end
    return {
        Discharge = false,
        Remove = false,
        ShowAnim = false
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.ConvertoUse, converto)
local mequalh = Isaac.GetItemIdByName("Money = Health")
function mod:mequalhuse(item, player)
    local mequaluser = Isaac.GetPlayer()
    local money = mequaluser:GetNumCoins()
    if money >= 20 then
        mequaluser:AddCoins(-20) -- converts coins into hearts
        mequaluser:AddMaxHearts(2)
	mequaluser:AddHearts(2)
    end
    if money < 20 then
        mequaluser:AddCoins(0)
    end
    return {
        Discharge = false,
        Remove = false,
        ShowAnim = false
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.mequalhuse, mequalh)
local BlueAndBlack = Isaac.GetItemIdByName("Blue And Black")
function mod:BABuse(item, player)
    local BABplayer = Isaac.GetPlayer()
    BABplayer:AddSoulHearts(2) -- adds 1 soul heart and 1 black heart
    BABplayer:AddBlackHearts(2)
    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.BABuse, BlueAndBlack)
local itemuds = Isaac.GetItemIdByName("Smallest Of Pills")
function mod:SmallerPillUse(item, player)
    local playesdsr = Isaac.GetPlayer()
    playesdsr:UsePill(PillEffect.PILLEFFECT_SMALLER, PillColor.PILL_BLUE_BLUE, UseFlag.USE_NOANIM)
    return {
        Discharge = true, --uses one makes you smaller pill (please don't use it too much unless you want a challenge run)
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.SmallerPillUse, itemuds)
local deathcertificates = Isaac.GetItemIdByName("Portable Death Certificate")
function mod:Dcuse(item, player)
    local deathuser = Isaac.GetPlayer() -- uses death certificate on a 24 room charge
    deathuser:UseActiveItem(CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE, UseFlag.USE_NOANIM)
    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.Dcuse, deathcertificates)
local pfd = Isaac.GetItemIdByName("Portable Forget me now")
function mod:Pfmn(item, player)
    Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, UseFlag.USE_NOANIM)
    return{
        Discharge = true,
        Remove = false, -- use forget me now on a 24? room charge
        ShowAnim = true
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.Pfmn, pfd)
local msa = Isaac.GetItemIdByName("Sonic Boots")
function mod:ms(player, cacheFlags)
    local msaamount = player:GetCollectibleNum(msa)
    if msaamount > 0 then
        player.MoveSpeed = 2 -- adds max speed
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mod.ms)
--hope you had fun reading this code slop

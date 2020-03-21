if onClient() then return end -- server side

package.path = package.path .. ";data/scripts/lib/?.lua"
local Buffs = include("BuffsHelper")

-- namespace BeginnersBlessing
BeginnersBlessing = {}

local shipsCreated

function BeginnersBlessing.initialize()
    local player = Player()
    shipsCreated = player:getValue("BeginnersBlessing") or 0
    if shipsCreated == 3 then terminate() end -- there is no need in this script anymore

    player:registerCallback("onSectorEntered", "onSectorEntered")
    Sector():registerCallback("onEntityCreated", "onEntityCreated") -- we need to catch when player creates a ship
end

function BeginnersBlessing.onSectorEntered(playerIndex)
    if Player().index == playerIndex then
        Sector():registerCallback("onEntityCreated", "onEntityCreated")
    end
end

function BeginnersBlessing.onEntityCreated(entityId)
    local entity = Entity(entityId)
    local player = Player()
    if entity.isShip and entity.factionIndex == player.index then
        if shipsCreated < 3 then
            shipsCreated = shipsCreated + 1
            player:setValue("BeginnersBlessing", shipsCreated)

            -- Since we're applying buff right after the entity was created (before game calls 'restore') there is a good chance that we will not be able to get 'addBuff' return values
            -- Adding buffs and bonuses is supposed to be done ONLY via 'BuffsHelper.lua' and NOT directly! Otherwise game will cancel bonuses after this script will be terminated.
            Buffs.addBuff(entity,
              "Beginner's Blessing"%_T,
              { -- bonuses, for more info look at game 'Entity' Docs: addBaseMultiplier, addMultiplier, addMultiplyableBias, addAbsoluteBias
                { Buffs.Type.BaseMultiplier, StatsBonuses.RadarReach, 0.2 }, -- +20%
                { Buffs.Type.BaseMultiplier, StatsBonuses.ScannerReach, 0.25 }, -- +25%
                { Buffs.Type.BaseMultiplier, StatsBonuses.ScannerMaterialReach, 0.25 }, -- +25%
                { Buffs.Type.MultiplyableBias, StatsBonuses.HyperspaceReach, 1 }, -- +1 but can be multiplied by some other buff with Buffs.Type.Multiplier
                { Buffs.Type.BaseMultiplier, StatsBonuses.HyperspaceCooldown, -0.2 }, -- -20%
                Buffs.Scripts.ChangeDurability:New(20, 5) -- custom script, for more info look at 'BuffsHelper.lua' or at the Buffs Docs
              },
              10 * 60, -- 10 minutes
              Buffs.Mode.Add,
              false, -- buff doesn't decay when sector is unloaded
              "BeginnersBlessing", -- icon name
              nil, -- don't need to specify description, because we already did in the 'BuffsIntegration.lua'
              { server = Server().name }, -- we'll pass these arguments to description
              0xff00ffd8, -- complex buffs are white by default, let's make this one look unique
              0xff74dacb, -- and this color will be used to form a gradient for a buff icon when duration will drop below 60 (for a visual 'decay' effect)
              -1 -- low priority display
            )
        end
        if shipsCreated >= 3 then terminate() end -- no more buffs
    end
end
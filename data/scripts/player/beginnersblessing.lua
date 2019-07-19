if onClient() then return end -- server side

package.path = package.path .. ";data/scripts/lib/?.lua"
local BuffsH = include("BuffsHelper")

-- namespace BeginnersBlessing
BeginnersBlessing = {}

local shipsCreated

function BeginnersBlessing.initialize()
    local player = Player()
    shipsCreated = player:getValue("BeginnersBlessing") or 0
    if shipsCreated == 3 then terminate() end -- there is no need in this script anymore

    player:registerCallback("onSectorEntered", "onSectorEntered")
    Sector():registerCallback("onEntityCreate", "onEntityCreate") -- we need to catch when player creates a ship
end

function BeginnersBlessing.onSectorEntered(playerIndex)
    if Player().index ~= playerIndex then return end

    Sector():registerCallback("onEntityCreate", "onEntityCreate")
end

function BeginnersBlessing.onEntityCreate(entityId)
    local entity = Entity(entityId)
    local player = Player()
    if entity.isShip and entity.factionIndex == player.index then
        if shipsCreated < 3 then
            shipsCreated = shipsCreated + 1
            player:setValue("BeginnersBlessing", shipsCreated)

            -- Since we're applying buff right after the entity was created (before game calls 'restore') we will not be able to get 'addBuff' return values
            -- Adding buffs and bonuses is supposed to be done only with 'BuffsHelper' or via `invokeFunction`! Otherwise game will cancel bonuses after this script will be terminated.
            BuffsH.addBuff(
              entity,
              "Beginner's Blessing", -- buff name without translation (%_t)
              { -- bonuses, for more info look at game 'Entity' Docs: addBaseMultiplier, addMultiplier, addMultiplyableBias, addAbsoluteBias
                { type = BuffsH.Type.BaseMultiplier, stat = StatsBonuses.RadarReach, value = 0.2 }, -- +20%
                { type = BuffsH.Type.BaseMultiplier, stat = StatsBonuses.ScannerReach, value = 0.25 }, -- +25%
                { type = BuffsH.Type.BaseMultiplier, stat = StatsBonuses.ScannerMaterialReach, value = 0.25 }, -- +25%
                { type = BuffsH.Type.MultiplyableBias, stat = StatsBonuses.HyperspaceReach, value = 1 }, -- +1
                { type = BuffsH.Type.BaseMultiplier, stat = StatsBonuses.HyperspaceCooldown, value = -0.2 }, -- -20%
                BuffsH.Custom.ChangeDurability:New(20, 5) -- custom effect, for more info look at 'BuffsHelper.lua' in the 'Buffs' mod
              },
              10 * 60, -- 10 minutes
              BuffsH.ApplyMode.Add,
              false, -- buff doesn't decay when sector is unloaded
              "BeginnersBlessing", -- icon name
              nil, -- don't need to specify description, because we already did in the 'BuffsIntegration.lua'
              { server = Server().name }, -- we'll pass these arguments to description
              0xff00ffd8, -- complex buffs are white by default, let's make this one look unique
              0xff74dacb -- and this color will be used to form a gradient for a buff icon when duration will drop below 60 (for a visual 'decay' effect)
            )
        end
        if shipsCreated >= 3 then terminate() end -- no more buffs
    end
end
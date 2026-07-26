

local selectedCard = nil

function mod.dump(o, depth, max_depth)
    max_depth = max_depth or 4
    depth = depth or 0
    if depth == max_depth then
        return tostring(o)
    end
    if type(o) == 'table' then
        local s = "\n" .. string.rep("\t", depth) .. '{\n'
        for k,v in pairs(o) do
            if type(k) == 'number' then k = '['..k..']' end
            s = s .. string.rep("\t",(depth+1)) .. k .. ' = ' .. mod.dump(v, depth + 1, max_depth) .. ',\n'
        end
        return s .. string.rep("\t", depth) .. '}'
    elseif type(o) == "string" then
        return "\"" .. o .. "\""
    else
        return tostring(o)
    end
end

modutil.mod.Path.Wrap("RandomBountyProcessMetaUpgrades", function (base, sum, remaining, index, budget, candidates, cardState)
    if index == 0 then
        local effectiveHealthCards = {
            "LastStand",
            "LowHealthBonus",
        }
        selectedCard = game.GetRandomValue(effectiveHealthCards)
        print("forcing", selectedCard)
        budget = budget - game.MetaUpgradeCardData[selectedCard].Cost
        remaining = remaining - game.MetaUpgradeCardData[selectedCard].Cost
        game.RemoveValueAndCollapse(candidates, selectedCard)
        game.RemoveValueAndCollapse(effectiveHealthCards, selectedCard)

        for _, value in ipairs(effectiveHealthCards) do
            if value ~= selectedCard then
                if not config.allow_both and not rom.mods["ReadEmAndWeep-Flip_the_Arcana_Mod"] then
                    remaining = remaining - game.MetaUpgradeCardData[value].Cost
                    game.RemoveValueAndCollapse(candidates, value)
                    print("blocking", value)
                end
            end
        end
    end
    local retVal = base(sum, remaining, index, budget, candidates, cardState)
    if sum == budget and selectedCard then
        print("inserting selected card", selectedCard, budget)
        game.GameState.MetaUpgradeState[selectedCard].Visible = true
        if selectedCard == "LastStand" then
            game.GameState.MetaUpgradeCardLayout[3][2] = "LastStand"
        else
            game.GameState.MetaUpgradeCardLayout[5][3] = "LowHealthBonus"
        end
        while #cardState < #candidates do
            table.insert(cardState, false)
        end
        table.insert(candidates, selectedCard)
        table.insert(cardState, true)
    end
    return retVal
end)
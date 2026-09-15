--[[
    ===================================================================
    🥚 STEAL & HATCH ANIME EGGS! - ULTIMATE AUTO HUB (FAST LOADER V1.0)
    Repository: https://github.com/khahuynh963/steal_and_hatch_anime_eggs.git
    ===================================================================
--]]

pcall(function()
    local container = (gethui and gethui()) or game:GetService("CoreGui")
    if container and container:FindFirstChild("StealAnimeEggsGui") then
        container.StealAnimeEggsGui:Destroy()
    end
    local pl = game:GetService("Players").LocalPlayer
    if pl and pl:FindFirstChild("PlayerGui") and pl.PlayerGui:FindFirstChild("StealAnimeEggsGui") then
        pl.PlayerGui.StealAnimeEggsGui:Destroy()
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/steal_and_hatch_anime_eggs/main/script.lua?v=" .. tostring(os.time()) .. "_" .. tostring(math.random(10000, 99999))))()

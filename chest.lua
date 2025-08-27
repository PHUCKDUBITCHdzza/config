local Rep = game:GetService("ReplicatedStorage")
local CraftRemote = Rep.GameEvents.CraftingGlobalObjectService
local bench = workspace.Interaction.UpdateItems.Model.GiantCraftingWorkBench
local player = game.Players.LocalPlayer

-- Lấy tất cả UUID của itemName
local function getUUIDs(itemName)
    local plr = game.Players.LocalPlayer
    local uuids = {}

    for _, item in ipairs(plr.Backpack:GetChildren()) do
        if string.find(item.Name, itemName) and item:GetAttribute("c") then
            table.insert(uuids, item:GetAttribute("c"))
        end
    end

    for _, item in ipairs(plr.Character:GetChildren()) do
        if string.find(item.Name, itemName) and item:GetAttribute("c") then
            table.insert(uuids, item:GetAttribute("c"))
        end
    end

    return uuids
end

-- Gửi input vào slot
local function inputItem(slot, itemName, itemType, uuid)
    local args = {
        [1] = "InputItem",
        [2] = bench,
        [3] = "GiantBeanstalkEventWorkbench",
        [4] = slot,
        [5] = {
            ["ItemType"] = itemType,
            ["ItemData"] = {["UUID"] = uuid}
        }
    }
    CraftRemote:FireServer(unpack(args))
    print("✅ "..itemName.." (UUID: "..uuid..") -> slot "..slot)
end

-- Auto Craft
local function autoCraft(recipeName, itemsNeeded)
    -- chọn công thức
    CraftRemote:FireServer("SetRecipe", bench, "GiantBeanstalkEventWorkbench", recipeName)

    for slot, data in ipairs(itemsNeeded) do
        local uuids = getUUIDs(data.Name)

        if data.Name == "Beanstalk" then
            if slot == 1 then
                -- Beanstalk 1: chạy theo thứ tự 1 → 2 → 3
                for i = 1, #uuids do
                    inputItem(slot, data.Name, data.Type, uuids[i])
                end
            elseif slot == 2 then
                -- Beanstalk 2: chạy theo thứ tự 3 → 2 → 1
                for i = #uuids, 1, -1 do
                    inputItem(slot, data.Name, data.Type, uuids[i])
                end
            end
        else
            -- Item khác: chỉ cần UUID[1]
            local uuid = uuids[1]
            if uuid then
                inputItem(slot, data.Name, data.Type, uuid)
            else
                warn("❌ Không tìm thấy item: "..data.Name)
            end
        end
    end

    -- thực hiện craft
    CraftRemote:FireServer("Craft", bench, "GiantBeanstalkEventWorkbench")
    print("🎉 Đã craft xong: "..recipeName)

    -- Claim sau khi craft
    local args = {
        [1] = "Claim",
        [2] = bench,
        [3] = "GiantBeanstalkEventWorkbench",
        [4] = 1
    }
    CraftRemote:FireServer(unpack(args))
    print("📦 Đã Claim sản phẩm thành công")
end

-- 🌀 Lặp lại
task.spawn(function()
    local count = 0
    while true do
        count += 1
        print("🔄 Bắt đầu lần craft thứ "..count)
        autoCraft("Skyroot Chest", {
            {Name = "Beanstalk", Type = "Holdable"},
            {Name = "Beanstalk", Type = "Holdable"},
            {Name = "Sprout Seed Pack", Type = "Seed Pack"},
            {Name = "Sprout Egg", Type = "PetEgg"},
        })
        print("⏳ Chờ 600 giây trước lần craft tiếp theo...")
        task.wait(90)
    end
end)

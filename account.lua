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

-- Auto Craft (Beanstalk 1 = uuid[1], Beanstalk 2 = uuid[2])
local function autoCraft(recipeName, itemsNeeded)
    -- chọn công thức
    CraftRemote:FireServer("SetRecipe", bench, "GiantBeanstalkEventWorkbench", recipeName)

    for slot, data in ipairs(itemsNeeded) do
        local uuids = getUUIDs(data.Name)
        if uuids[slot] then
            inputItem(slot, data.Name, data.Type, uuids[slot])
        elseif uuids[1] then
            inputItem(slot, data.Name, data.Type, uuids[1])
        else
            warn("❌ Không tìm thấy item: "..data.Name)
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

-- 🌀 Lặp lại mỗi 600 giây
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
        task.wait(60)
    end
end)

RegisterNetEvent("Wrench_Trucking:JobComplete", function(value)
    exports.ox_inventory:AddItem(source, "cash", value)
end)
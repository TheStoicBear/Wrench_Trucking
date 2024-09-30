local jobTypes = {
    {
        trailer = `17fontainev2`, -- Trailer Model
        truck = {model=`9000cl`, spawnCoords=vector4(2046.99, 4916.51, 43.65, 44.66)}, -- Delete this line if you dont want a truck spawn
        trailerSpawn = vector4(2024.32, 4934.19, 43.64, 132.23), -- optional (Meant for cars)
        finishcoords = {
            vector4(57.59, 6298.02, 31.28, 121.35),
            vector4(2675.88, 1449.37, 24.50, 178.80),
            vector4(477.85, 2797.39, 41.93, 89.76)
        },
        jobvalue = 10000,
        randomextra = true
    },
    {
        trailer = `17fontainev4`, -- Trailer Model
        truck = {model=`t680`, spawnCoords=vector4(2046.99, 4916.51, 43.65, 44.66)}, -- Delete this line if you dont want a truck spawn
        trailerSpawn = vector4(2024.32, 4934.19, 43.64, 132.23), -- optional (Meant for cars)
        finishcoords = {
            vector4(57.59, 6298.02, 31.28, 121.35),
            vector4(2675.88, 1449.37, 24.50, 178.80),
            vector4(477.85, 2797.39, 41.93, 89.76)
        },
        jobvalue = 10000,
        randomextra = true
    },
}



local desk_prop = `prop_laptop_01a`
local desk_coords = vector4(2057.33, 4919.13, 43.82, 300.81)

while not HasModelLoaded(desk_prop) do
    Wait(100)
    RequestModel(desk_prop)
end

local desk = CreateObject(desk_prop, desk_coords, false, true, false)
SetModelAsNoLongerNeeded(desk_prop)
FreezeEntityPosition(desk, true)

local blip = AddBlipForEntity(desk)
SetBlipSprite(blip, 374)  -- Set a small blip icon
SetBlipColour(blip, 6)  -- Set color to yellow
SetBlipAsShortRange(blip, true)
BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Trucking Job")
EndTextCommandSetBlipName(blip)


local blips = {}
-- Function to create a blip for a vehicle and remove it once the player is close
local function createBlipForVehicle(vehicle, label, sprite)
    local blip = AddBlipForEntity(vehicle)
    SetBlipSprite(blip, sprite)  -- Set a small blip icon
    SetBlipColour(blip, 6)  -- Set color to yellow
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    blips[#blips+1] = blip
end

local function clearblips()
    for _, blip in pairs(blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
end

local function startJob()
    lib.notify({
        title = "Wrench Trucking",
        description = "Your Job is being prepared."
    })
    Wait(10000)
    local truck, cars
    local jobtype = jobTypes[math.random(1, #jobTypes)]
    while not HasModelLoaded(jobtype.trailer) do
        RequestModel(jobtype.trailer)
        Wait(0)
    end
        

    if jobtype.truck then
        while not HasModelLoaded(jobtype.truck.model) do
            RequestModel(jobtype.truck.model)
            Wait(0)
        end
        truck = CreateVehicle(jobtype.truck.model, jobtype.truck.spawnCoords, true, false)
        createBlipForVehicle(truck, "Truck", 477)  
    end

    if jobtype.cargo then
        cars = {}
        for _, obj in pairs(jobtype.cargo) do
            while not HasModelLoaded(obj.carModel) do
                RequestModel(obj.carModel)
                Wait(0)
            end
            local car = CreateVehicle(obj.carModel, obj.spawncoords, true, false)
            cars[#cars+1] = car
            createBlipForVehicle(car, "Cargo Vehicle", 568)  
        end
    end


    local trailer = CreateVehicle(jobtype.trailer, jobtype.trailerSpawn, true, false)
    createBlipForVehicle(trailer, "Trailer", 479) 
    if jobtype.randomextra then
        for i=1, 9 do
            SetVehicleExtra(trailer, i, true)
        end
        SetVehicleExtra(trailer, math.random(1, 9), false)
    end
    local requiredvehicles = {}
    lib.notify({
        title = "Wrench Trucking",
        description = "Your Job is now ready!"
    })
    if trailer then
        requiredvehicles.trailer = {true, trailer}
    end
    if truck then
        requiredvehicles.truck = {true, truck}
    end
    if cars then
        requiredvehicles.cars = {true, cars}
    end
    local endcoords = jobtype.finishcoords[math.random(1, #jobtype.finishcoords)]
    local completevehicles = {}
    for _, i in pairs(requiredvehicles) do
        completevehicles[#completevehicles+1] = {false, i[2]}
    end
    SetNewWaypoint(endcoords.x, endcoords.y)
    local zone = lib.zones.box({
        coords = endcoords,
        inside = function(self)
            if IsControlPressed(1, 86) then
                for _, haul in pairs(requiredvehicles) do
                    if haul[1] == true and type(haul[2]) ~= "table" then
                        if GetDistanceBetweenCoords(GetEntityCoords(haul[2]), endcoords, true) < 10 then
                            for _, veh in pairs(completevehicles) do
                                if veh[2] == haul[2] then
                                    veh[1] = true
                                end
                            end
                        end
                    elseif haul[1] == true and type(haul[2]) == "table" then
                        local compcars = {}
                        -- First loop: Populate compcars if they are within 30 units of endcoords
                        for id, car in pairs(haul[2]) do
                            local carCoords = GetEntityCoords(car)
                            local distance = GetDistanceBetweenCoords(carCoords, endcoords, true)
                            
                            if distance < 10 then
                                compcars[#compcars+1] = car
                            end
                        end
                        -- Second loop: Check if vehicles in completevehicles are in compcars
                        for _, veh in pairs(completevehicles) do
                            if type(veh[2]) == "table" then
                                if #veh[2] == #compcars then
                                    
                                    veh[1] = true
                                end
                            end
                        end
                    end
                end
                local completedcount = 0
                for _, vehicle in pairs(completevehicles) do
                    if vehicle[1] == true then
                        completedcount += 1
                    end
                end

                if completedcount == #completevehicles then
                    lib.notify({
                        title = "Wrench Trucking",
                        description = "Job Completed! You're good to go!"
                    })
                    clearblips()
                    self:remove()
                    TriggerServerEvent("Wrench_Trucking:JobComplete", jobtype.jobvalue)
                    DeleteVehicle(requiredvehicles.trailer[2])
                    for _, haul in pairs(requiredvehicles) do
                        if type(haul[2]) == "table" then
                            for _, vehicle in pairs(haul[2]) do
                                DeleteVehicle(vehicle)
                            end
                        end
                    end
                else
                    lib.notify({
                        title = "Wrench Trucking",
                        description = "Please align your cargo better"
                    })
                end
                Wait(1000)
            end
        end,
        onEnter = function(self)
           lib.notify({
            title = "Wrench Trucking",
            description = "Press E when you are lined up."
           })
        end,
        debug = true,
        size = vector3(5, 20, 10),
        rotation = endcoords.w
    })
end


exports.ox_target:addLocalEntity(desk, {
    label = "Start Trucking Job",
    onSelect = function()
        startJob()
    end
})
-- Load configuration
local Config = require 'config'

-- Variable to store the trailer used in the job
local currentTrailer = nil
local trailerDetached = true -- State variable to prevent spam notifications

-- Function to check if there is a Class 20 vehicle near the player
local function isNearClass20Vehicle(radius)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Find the closest vehicle to the player within the given radius
    local vehicle = GetClosestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, radius, 0, 70) -- 70 checks all vehicle classes
    if vehicle ~= 0 then
        local vehicleClass = GetVehicleClass(vehicle)
        if vehicleClass == 20 then
            return true, vehicle -- Return true and the vehicle if it's a Class 20 vehicle
        end
    end
    return false, nil -- Return false if no Class 20 vehicle is found
end

-- Function to check if the trailer is attached to the vehicle
local function isTrailerAttached(vehicle)
    local isAttached, trailer = GetVehicleTrailerVehicle(vehicle)
    return isAttached, trailer
end

-- Function to calculate distance and payout
local function calculatePayout(endCoords)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Calculate distance using GetDistanceBetweenCoords
    local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, endCoords.x, endCoords.y, endCoords.z, true)

    -- Convert distance from meters to miles (1 mile = 1609.34 meters)
    local distanceInMiles = distance / 1609.34

    -- Calculate payout based on distance
    local payout = math.floor(distanceInMiles * Config.cpmRate * Config.cpmMultiplier) -- Calculate payout in cents

    return distanceInMiles, payout
end

-- Function to start job (without spawning trailers or trucks)
local function startJob()
    local radius = Config.checkRadius -- Set the radius for checking nearby Class 20 vehicles
    local isNearby, trailer = isNearClass20Vehicle(radius)

    if not isNearby then
        lib.notify({
            title = "Wrench Trucking",
            description = "You must be near a Class 20 vehicle to start this job!",
            type = "error"
        })
        return
    end

    -- Store the trailer being used in the job
    currentTrailer = trailer

    lib.notify({
        title = "Wrench Trucking",
        description = "Your job is being prepared. Drive to the marked destination.",
        type = "success"
    })

    -- Select a random contract (finish destination)
    local jobContract = Config.jobContracts[math.random(1, #Config.jobContracts)]
    local endcoords = jobContract.finishcoords[math.random(1, #jobContract.finishcoords)]

    -- Calculate the estimated mileage and payout
    local estimatedMiles, estimatedPayout = calculatePayout(endcoords)

    -- Display estimated mileage and payout
    lib.notify({
        title = "Wrench Trucking",
        description = string.format("Estimated Mileage: %.2f miles\nEstimated Payout: $%.2f", estimatedMiles, estimatedPayout / 100), -- Convert cents to dollars
        type = "info"
    })

    -- Set a waypoint to the finish coordinates
    SetNewWaypoint(endcoords.x, endcoords.y)

    -- Create a zone at the finish coordinates
    local zone = lib.zones.box({
        coords = endcoords,
        inside = function(self)
            local playerVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

            -- Check if the trailer is still attached
            local isAttached, trailer = isTrailerAttached(playerVehicle)
            if isAttached then
                -- Show notification only once
                if trailerDetached then
                    lib.notify({
                        title = "Wrench Trucking",
                        description = "Detach the trailer before completing the job!",
                        type = "error"
                    })
                    trailerDetached = false -- Set to false to prevent spam
                end
                return
            else
                trailerDetached = true -- Reset when trailer is detached
            end

            if IsControlPressed(1, 86) then -- E key to complete the job
                lib.notify({
                    title = "Wrench Trucking",
                    description = "Job Completed! You've earned $" .. (jobContract.jobvalue + estimatedPayout / 100),
                    type = "success"
                })

                -- Trigger server event to reward the player
                TriggerServerEvent("Wrench_Trucking:JobComplete", jobContract.jobvalue + estimatedPayout / 100) -- Add payout to the job value

                -- Delete the trailer after job completion
                if currentTrailer then
                    DeleteVehicle(currentTrailer) -- Delete the trailer, not the player’s vehicle
                    currentTrailer = nil -- Clear the trailer reference
                end

                -- Remove the zone after job completion
                self:remove()
            end
        end,
        onEnter = function(self)
            lib.notify({
                title = "Wrench Trucking",
                description = "Press E to complete the job when aligned properly.",
                type = "info"
            })
        end,
        size = vector3(5, 20, 10),
        rotation = endcoords.w
    })
end

-- Add ox_target to make trailers targetable if near Class 20 vehicle
for _, trailerModel in ipairs(Config.trailers) do
    exports.ox_target:addModel(trailerModel, {
        label = "Start Job",
        onSelect = function()
            local radius = Config.checkRadius -- Define radius to check for nearby Class 20 vehicles
            local isNearby = isNearClass20Vehicle(radius)

            if isNearby then
                startJob() -- Start the job if the player is near a Class 20 vehicle
            else
                lib.notify({
                    title = "Wrench Trucking",
                    description = "You must be near a Class 20 vehicle to start this job.",
                    type = "error"
                })
            end
        end
    })
end

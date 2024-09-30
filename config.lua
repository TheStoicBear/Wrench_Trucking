-- Configuration for Wrench Trucking Job

-- Define job types with finish coordinates (contracts)
Config = {}

Config.jobContracts = {
    {
        finishcoords = {
            vector4(57.59, 6298.02, 31.28, 121.35),
            vector4(2675.88, 1449.37, 24.50, 178.80),
            vector4(477.85, 2797.39, 41.93, 89.76)
        },
        jobvalue = 10000
    },
    {
        finishcoords = {
            vector4(150.12, 6350.24, 31.42, 145.50),
            vector4(2768.49, 1423.65, 24.55, 195.30),
            vector4(527.38, 2795.78, 42.10, 90.65)
        },
        jobvalue = 12000
    }
}

-- Define the CPM rates
Config.cpmRate = 2.00 -- Average CPM in dollars
Config.cpmMultiplier = 100 -- Convert dollars to cents for calculation

-- Define trailer models that can be used
Config.trailers = {
    `17fontainev2`,
    `tanker`,
    `trailerlogs`,
    `trailersmall`
}

-- Set the radius for checking nearby Class 20 vehicles
Config.checkRadius = 10.0 -- Radius in meters

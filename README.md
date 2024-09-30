# Wrench Trucking

## Features

- **Configurable Job Contracts**: Easily define job types with different finish coordinates and values.
- **Dynamic Payout Calculation**: Payouts are based on the distance traveled, calculated in miles and converted to cents for accuracy.
- **Class 20 Vehicle Detection**: Automatically detects nearby Class 20 vehicles required to start trucking jobs.
- **Trailer Management**: Supports multiple trailer models and checks for trailer attachment status during job completion.
- **User Notifications**: Utilizes a notification library to inform players about job statuses and requirements.

## Installation

1. Download the Repository:
   https://github.com/TheStoicBear/Wrench_Trucking

2. Add the Script:
   Place the `Wrench_Trucking` folder into your FiveM resources directory.

3. Start the Resource:
   Add the following line to your server.cfg:
   - start Wrench_Trucking

4. Configure Settings:
   Open config.lua to customize job contracts, CPM rates, and trailer models to fit your server's needs.

## Usage

- Approach a Class 20 vehicle and use the designated action to start a trucking job.
- Follow the waypoint to the designated delivery location.
- Detach the trailer before completing the job to receive your payout.
- The system will notify you of your earnings and job status.

## Configuration

The following configurations are available in config.lua:

- **Job Contracts**: Define multiple job types with their respective finish coordinates and job values.
- **CPM Rate**: Set the cost per mile for trucking jobs (in dollars).
- **Trailer Models**: List of trailer models that can be used for the jobs.
- **Check Radius**: Define the radius for detecting nearby Class 20 vehicles.

## Example Configuration

Here’s an example of how to configure your job contracts in config.lua:

- Config.jobContracts = {
    {
        finishcoords = {
            vector4(57.59, 6298.02, 31.28, 121.35),
            vector4(2675.88, 1449.37, 24.50, 178.80)
        },
        jobvalue = 10000
    },
    - Add more job contracts as needed
}

\

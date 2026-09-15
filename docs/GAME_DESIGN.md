# Truck Manager — Game Design

## Vision

Truck Manager is a trucking-company management simulation for mobile and desktop. The player starts small and grows into a larger carrier by buying trucks, hiring drivers and office staff, dispatching freight, managing facilities, and improving efficiency.

## Core Gameplay Loop

1. Acquire or finance trucks.
2. Hire drivers and assign them to trucks.
3. Find or generate freight loads.
4. Dispatch trucks automatically or manually.
5. Complete loads and earn revenue.
6. Pay fuel, wages, maintenance, insurance, and operating costs.
7. Upgrade trucks, staff, and facilities.
8. Expand into new markets and terminals.

## Driver System

- Trucks may have one driver or a two-driver team.
- When two drivers are assigned to one truck, the game automatically switches the active driver based on available hours, fatigue, and rest status.
- Driver attributes can later include experience, safety, fuel efficiency, preferred regions, endorsements, reliability, and morale.
- Drivers should accumulate experience and develop over time.

## Dispatch System

Automatic dispatch is the default behavior so a large company can operate without requiring the player to manually assign every load.

The player can choose per truck or per driver whether dispatch is:

- Automatic
- Manual
- Staff-managed

Automatic dispatch should consider load profitability, driver hours, truck type, trailer compatibility, deadhead distance, delivery windows, fuel, maintenance status, and current location.

## Office Staff

### Dispatchers

Dispatchers manage groups of drivers and trucks. Better dispatchers can improve load selection, reduce deadhead miles, and manage more trucks efficiently.

### Load Planners

Load planners focus on freight planning and future truck positioning. Better planners should improve multi-load routing, reload opportunities, and fleet utilization.

Additional staff roles can be added later, including recruiters, safety managers, mechanics, accountants, terminal managers, and operations managers.

## Facilities

### Headquarters

The HQ is the primary company building and unlocks administrative capacity, staff slots, upgrades, and company-wide systems.

### Future Buildings

- Truck terminals
- Maintenance shops
- Fuel facilities
- Driver training centers
- Warehouses / cross-docks
- Recruiting offices
- Regional offices

Buildings can have upgrade levels that increase capacity or provide operational bonuses.

## Fleet Management

Players should manage:

- Trucks
- Trailers
- Driver assignments
- Maintenance condition
- Fuel consumption
- Financing / ownership status
- Truck specifications
- Home terminal

## Economy

Revenue comes primarily from completed freight. Expenses should include fuel, driver wages, office staff payroll, truck payments, trailer payments, repairs, maintenance, insurance, facility costs, and taxes/fees where appropriate.

The economy should reward efficient operations rather than only owning more trucks.

## Player Control Philosophy

Truck Manager should support both hands-on and management-focused play. A player with a few trucks can manually dispatch everything, while a large company can hire staff and automate repetitive decisions.

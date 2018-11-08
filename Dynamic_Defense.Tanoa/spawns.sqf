spawn_opfor_infantry = {
	params ["_marker"];

	_group = [getMarkerPos _marker, east, ["O_Soldier_F","O_Soldier_F","O_Soldier_F"]] call BIS_fnc_spawnGroup;

	_group;
};

spawn_opfor_air = {
	params ["_marker"];

	_vehicle_choices = [
		"B_Heli_Light_01_dynamicLoadout_F"
	];

	// Select random vehicle name
	_vehicle_name = selectRandom _vehicle_choices;

	// Create vehicle
	_mpos = getMarkerPos _marker;
	_vpos = [_mpos select 0, _mpos select 1, (_mpos select 2) + 50];
	_vehicle = _vehicle_name createVehicle _vpos;

	// Set vehicle angle
	_vehicle setDir markerDir _marker;

	//Create Group
	_group = createGroup east;

	_total_seats = [_vehicle_name, true] call BIS_fnc_crewCount; // Number of total seats: crew + non-FFV cargo/passengers + FFV cargo/passengers

	for [{_i=0}, {_i<_total_seats}, {_i=_i+1}] do
	{
		_unit = _group createUnit ["O_helicrew_F", position _vehicle, [], 0, "NONE"];
		_unit moveInAny _vehicle;
	};

	// Add event handlers
	{
		_x addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			[] call handle_unit_killed;
		}];
	} forEach crew _vehicle;

	// I think we might have to set the vehicle position again now that it's FULL
	_vehicle setVehiclePosition [_vpos, [], 0, "FLY"];
	_vehicle setVelocity [0,0,25];

	// Return group
	_group;
};

spawn_opfor_vehicle = {
	params ["_marker"];

	// List of possible vehicles to spawn
	_vehicle_choices = [
		"O_MRAP_02_ghex_F", // Unarmed Ifrit
		"O_G_Offroad_01_F", // Unarmed Offroad
		"O_Quadbike_01_ghex_F",
		"O_Truck_02_transport_F",
		"O_G_Van_01_transport_F",
		"O_T_LSV_02_unarmed_F" // Qilin (Unarmed)
	];
	
	// Select random vehicle name
	_vehicle_name = selectRandom _vehicle_choices;

	// Create vehicle
	_vehicle = _vehicle_name createVehicle getMarkerPos _marker;

	// Set vehicle angle
	_vehicle setDir markerDir _marker;
	
	//Add driver
	createVehicleCrew _vehicle;

	//Use the group of the driver of the vehicle
	_group = group driver _vehicle;

	// Calculate space in vehicle
	_total_seats = [_vehicle_name, true] call BIS_fnc_crewCount; // Number of total seats: crew + non-FFV cargo/passengers + FFV cargo/passengers
	_crew_seats = [_vehicle_name, false] call BIS_fnc_crewCount; // Number of crew seats only
	_cargo_seats = _total_seats - _crew_seats; // Number of total cargo/passenger seats: non-FFV + FFV

	// Create a couple of units and put them in the vehicle
	for [{_i=0}, {_i<_cargo_seats}, {_i=_i+1}] do {
		_unit = _group createUnit ["O_Soldier_F", position _vehicle, [], 0, "NONE"];
		_unit moveInAny _vehicle;
	};

	// Add event handlers
	{
		_x addEventHandler ["Killed", {
			params ["_unit", "_killer", "_instigator", "_useEffects"];
			[] call handle_unit_killed;
		}];
	} forEach crew _vehicle;

	// Return group
	_group;
};

_weighted_spawn_fns = [
	spawn_opfor_vehicle,
	0.9,

	spawn_opfor_air,
	0.1
];
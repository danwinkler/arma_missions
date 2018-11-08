event_none = {
	
};

event_independent_support = {
	// Spawn independents at random opfor starting points, who will run in and help defend
	hint "RND EV: independents support";

	_vehicle_name = "I_G_Offroad_01_armed_F";

	_marker = selectRandom spawn_markers;

	// Create vehicle
	_vehicle = _vehicle_name createVehicle getMarkerPos _marker;

	// Set vehicle angle
	_vehicle setDir markerDir _marker;
	
	//Add driver
	createVehicleCrew _vehicle;

	// Use the group of the driver of the vehicle
	_group = group driver _vehicle;

	// Attack base
	[_group, getMarkerPos base_marker] call BIS_fnc_taskAttack;
	[_group, 1] setWaypointSpeed "FULL";
	[_group, 1] setWaypointCombatMode "RED";
	[_group, 1] setWaypointBehaviour "AWARE";
};

event_helicopter_support = {
	// Spawn NATO helicopter who will come in and help defend
	hint "RND EV: heli support";

	_vehicle_name = "B_Heli_Light_01_dynamicLoadout_F";

	_first_player = allPlayers select 0;
	//_group = group _first_player;
	_position = position _first_player;
	_angle = random 360;
	_distance = 1000;

	_vpos = [(_position select 0) + (sin(_angle) * _distance), (_position select 1) + (cos(_angle) * _distance), (_position select 2) + 300];
	_vehicle = _vehicle_name createVehicle _vpos;

	// Create Crew
	createVehicleCrew _vehicle;

	// Use the group of the driver of the vehicle
	_group = group driver _vehicle;

	// Attack base
	[_group, getMarkerPos base_marker] call BIS_fnc_taskAttack;
	[_group, 1] setWaypointSpeed "FULL";
	[_group, 1] setWaypointCombatMode "RED";
	[_group, 1] setWaypointBehaviour "AWARE";
};

_weighted_random_events = [
	event_none,
	300,

	event_independent_support,
	1,

	event_helicopter_support,
	1
];
// To set up the mission on the map:
// 1. Place as many playable units as you want
// 2. Place as many base markers as you want (prefix with base_)
// 3. For each base, create spawn markers. If base is named base_0, then all spawn markers must be prefixed with spawn_base_0

#include "helpers.sqf";
#include "events.sqf";
#include "spawns.sqf";

spawn_backup = {
	_first_player = allPlayers select 0;
	_group = group _first_player;
	_position = position _first_player;
	_angle = random 360;
	_distance = random 200;
	_unit = _group createUnit ["B_Soldier_PG_F", [(_position select 0) + (sin(_angle) * _distance), (_position select 1) + (cos(_angle) * _distance), (_position select 2) + 100], [], 0, "NONE"];
	addSwitchableUnit _unit;
	[_group, getMarkerPos base_marker] call bis_fnc_taskDefend;
};

handle_unit_killed = {
	units_killed = units_killed + 1;
	hint Format["Units Killed: %1", units_killed];

	if (units_killed mod 5 == 0) then {
		hint "Backup arrived";
		[] call spawn_backup;
	};

	if (units_killed >= units_spawned && spawned_groups == max_groups) then {
		[] call win_fn;
	};
};

find_and_place_if_possible = {
	params ["_object_name", "_position", "_min_dist", "_max_dist"];

	_found_pos = _position findEmptyPosition [_min_dist, _max_dist, _object_name];

	if (count _found_pos == 3) then {
		_object_name createVehicle [_found_pos select 0, _found_pos select 1, (_found_pos select 2) + 1];
	};
};

lose_fn = {
	["lose",false,2] call BIS_fnc_endMission;
};

win_fn = {
	"End1" call BIS_fnc_endMission;
};

units_killed = 0;
units_spawned = 0;

// Get all base markers
base_markers = "base_" call get_markers_with_prefix;

// Select a base randomly from list
base_marker = selectRandom base_markers;

// Grab spawn markers
_spawn_prefix = "spawn_" + base_marker;
spawn_markers = _spawn_prefix call get_markers_with_prefix;

// Create base

// Spawn Bunker
_bunkers = [
	"Land_HBarrier_01_tower_green_F",
	"Land_Cargo_HQ_V1_F",
	"Land_Cargo_Patrol_V1_F",
	"Land_Cargo_Tower_V1_F",
	"Land_HBarrierTower_F",
	"Land_BagBunker_01_large_green_F",
	"Land_PillboxBunker_01_big_F"	
];

_barriers = [
	"Land_SandbagBarricade_01_half_F",
	"Land_SandbagBarricade_01_F",
	"Land_BagFence_Round_F"
];

_bunker_type = selectRandom _bunkers;

_bunker_location = (getMarkerPos base_marker) findEmptyPosition [0, 50, _bunker_type];

if (count _bunker_location == 3) then {
	_bunker_type createVehicle _bunker_location;
} else {
	hint "no bunker";
	_bunker_location = getMarkerPos base_marker;
};

// Create lose trigger
_lose_trigger = createTrigger ["EmptyDetector", _bunker_location];
_lose_trigger setTriggerArea [10, 10, 0, false];
_lose_trigger setTriggerActivation ["EAST SEIZED", "PRESENT", false];
_lose_trigger setTriggerStatements 
[
	"this", 
	"[] call lose_fn;", 
	""
];

// Draw circle
for [{_i=0}, {_i<360}, {_i=_i+30}] do
{
    _search_pos = _bunker_location;
	_circle_distance = 10;
	_search_pos = [(_search_pos select 0) + (cos(_i) * _circle_distance), (_search_pos select 1) + (sin(_i) * _circle_distance), _search_pos select 2];

	_position = _search_pos findEmptyPosition [0, .1];
	if (count _position == 3) then {
		_cone = "RoadCone_F" createVehicle _position;
	};
};

// Spawn Barriers
for [{_i=0}, {_i<360}, {_i=_i+60}] do
{
	_barrier_type = selectRandom _barriers;
    _search_pos = _bunker_location;
	_barrier_distance = 15;
	_search_pos = [(_search_pos select 0) + (cos(_i) * _barrier_distance), (_search_pos select 1) + (sin(_i) * _barrier_distance), _search_pos select 2];

	_position = _search_pos findEmptyPosition [0, 5, _barrier_type];
	if (count _position == 3) then {
		_barrier = _barrier_type createVehicle _position;
		_barrier setDir (360-_i + 270) mod 360;
		_barrier setPos _position;
	};
};

// Spawn supplies

["Box_NATO_AmmoOrd_F", _bunker_location, 1, 15] call find_and_place_if_possible;
["Box_NATO_Grenades_F", _bunker_location, 1, 15] call find_and_place_if_possible;
["Box_NATO_Wps_F", _bunker_location, 1, 15] call find_and_place_if_possible;
["Box_NATO_Ammo_F", _bunker_location, 1, 15] call find_and_place_if_possible;

respawn_pos = [];

repsawn_pos = _bunker_location findEmptyPosition [0, 20, "B_Soldier_F"];

if (count repsawn_pos == 0) then {
	hint "bad spawn";
	repsawn_pos = _bunker_location;
};

// Set respawn position
createMarker ["respawn_west", repsawn_pos];

// Teleport players
_allPlayers = call BIS_fnc_listPlayers;
{
	_x setPos repsawn_pos;

	// Give unit a backpack
	_x addBackpack "B_AssaultPack_khk";
} forEach _allPlayers;

max_groups = 10;
spawned_groups = 0;

sleep 10;

while { spawned_groups < max_groups } do {
	_chance = random 100;
	if (_chance < 5) then {
		hint "spawn";
		// Select marker
		_marker = selectRandom spawn_markers;

		// Select spawn fn
		_spawn_fn = selectRandomWeighted _weighted_spawn_fns;

		_group = [_marker] call _spawn_fn;

		//Attack base
		[_group, getMarkerPos base_marker] call BIS_fnc_taskAttack;
		[_group, 1] setWaypointSpeed "FULL";
		[_group, 1] setWaypointCombatMode "RED";
		[_group, 1] setWaypointBehaviour "AWARE";

		spawned_groups = spawned_groups + 1;
		units_spawned = units_spawned + (count units _group);
	};
	sleep 1;
};

while { true } do {
	_random_event = selectRandomWeighted _weighted_random_events;

	[] call _random_event;

	sleep 1;
};

//uiSleep (60*15);
//[] call win_fn;
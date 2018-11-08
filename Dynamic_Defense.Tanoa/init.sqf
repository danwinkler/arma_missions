if (isServer) then {
	execVm "start_mission.sqf";
};

// Teleport and set up player
if (hasInterface) then {
	hint "event handler";
	hint str respawn_position;
	"respawn_position" addPublicVariableEventHandler {
		hint "waiting";
		waitUntil {local player};
		waitUntil {alive player};

		hint "moving";
		player setPos respawn_position;
		player addBackpack "B_AssaultPack_khk";
	};
};
private _group = A3C_SELECTED_HC_GROUPS_SETTINGS select 0;

private _transferFnc = {
	params ["_clientId", "_group"];

	private _groupId = groupId _group;

	if (groupOwner _group != _clientId) then {
		// Transfer ownership to client.
		_group setGroupOwner _clientId;

		format ["%1 has been transferred to your client", _groupId] remoteExec ["systemChat", _clientId];
	} else {
		// Transfer ownership to server.
		_group setGroupOwner 2;

		format ["%1 has been transferred to the server", _groupId] remoteExec ["systemChat", _clientId];
	};
};

[[clientOwner, _group], _transferFnc] remoteExec ["BIS_fnc_call", 2];




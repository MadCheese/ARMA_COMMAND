private [ "_resupply_dist", "_repair_increment", "_repair_speed", "_repair_altitude", "_veh", "_repaired", "_rearmed", "_refueled", "_average_damage", "_average_fuel", "_screenmsg", "_rearm_time", "_refuel_amount", "_rearm_ticker" ];

// Everything that can resupply other vehicles.
vehicle_repair_sources = [
	"C_Offroad_01_repair_F",
	"B_Truck_01_Repair_F",
	"B_T_Truck_01_Repair_F",
	"B_Slingload_01_Repair_F",
	"B_APC_Tracked_01_CRV_F",
	"B_T_APC_Tracked_01_CRV_F",
	"BW_LKW15T_Repair_F",
	"rhsusf_M1078A1R_SOV_M2_D_fmtv_socom",
	"rhsusf_M977A4_REPAIR_usarmy_d",
	"rhsusf_M977A4_REPAIR_usarmy_wd",
	"rhsusf_M977A4_REPAIR_BKIT_usarmy_d",
	"rhsusf_M977A4_REPAIR_BKIT_usarmy_wd",
	"rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_d",
	"rhsusf_M977A4_REPAIR_BKIT_M2_usarmy_wd",
	"RHS_Ural_Repair_VDV_01"
];

vehicle_rearm_sources = [
	"B_Truck_01_ammo_F",
	"B_T_Truck_01_ammo_F",
	"B_Slingload_01_Ammo_F",
	"B_APC_Tracked_01_CRV_F",
	"B_T_APC_Tracked_01_CRV_F",
	"BW_LKW15T_Ammo_F",
	"rhsusf_M1078A1R_SOV_M2_D_fmtv_socom",
	"rhsusf_M977A4_AMMO_usarmy_d",
	"rhsusf_M977A4_AMMO_usarmy_wd",
	"rhsusf_M977A4_AMMO_BKIT_usarmy_d",
	"rhsusf_M977A4_AMMO_BKIT_usarmy_wd",
	"rhsusf_M977A4_AMMO_BKIT_M2_usarmy_d",
	"rhsusf_M977A4_AMMO_BKIT_M2_usarmy_wd",
	"rhs_gaz66_ammo_msv"
];

vehicle_refuel_sources = [
	"C_Van_01_fuel_F",
	"C_Truck_02_fuel_F",
	"B_Truck_01_fuel_F",
	"B_T_Truck_01_fuel_F",
	"B_Slingload_01_Fuel_F",
	"B_APC_Tracked_01_CRV_F",
	"B_T_APC_Tracked_01_CRV_F",
	"BW_LKW15T_Fuel_F",
	"rhsusf_M1078A1R_SOV_M2_D_fmtv_socom",
	"rhsusf_M978A4_usarmy_d",
	"rhsusf_M978A4_usarmy_wd",
	"rhsusf_M978A4_BKIT_usarmy_d",
	"rhsusf_M978A4_BKIT_usarmy_wd",
	"RHS_Ural_Fuel_VDV_01"
];



_repair_amount = 0.01;
_repair_speed = 2;
_repair_altitude = 2;
_resupply_dist = 50;
_rearm_time = 60;
_refuel_amount = 0.02;
_rearm_ticker = 0;

while { true } do {

	_repaired = false;
	_rearmed = false;
	_refueled = false;
	_average_damage = 0;
	_average_fuel = 0;
	_screenmsg = "";
	{
		private _gp = _x;
		{
			_veh = vehicle _x;

			if ( _veh != _x ) then {
				if ( effectiveCommander _veh == player ) then {
					if ( (speed _veh < _repair_speed) && (((getPosATL _veh) select 2) < _repair_altitude) ) then {

						if ( count ( (getpos _veh) nearEntities [ vehicle_repair_sources , _resupply_dist] ) > 0 ) then {
							if ( damage _veh > 0 )  then {
								_repaired = true;
								_average_damage = (damage _veh) - _repair_amount;
								if ( _average_damage < 0 ) then { _average_damage = 0 };
								_veh setDamage _average_damage;
							};
						};

						if ( ( count ( (getpos _veh) nearEntities [ vehicle_rearm_sources , _resupply_dist] ) > 0 ) && ( _rearm_ticker < _rearm_time ) ) then {
							_rearmed = true;
							_rearm_ticker = _rearm_ticker + 1;
							if ( _rearm_ticker >= _rearm_time ) then {
								[_veh] remoteExec ["F_rearmVehicle",_veh];
							};
						};

						if ( count ( (getpos _veh) nearEntities [ vehicle_refuel_sources , _resupply_dist] ) > 0 ) then {
							if ( fuel _veh < ( 1 - _refuel_amount ) )  then {
								_refueled = true;
								[_veh, (fuel _veh + _refuel_amount)] remoteExec ["F_setFuel",_veh];
							};
						};
					} else {
						_rearm_ticker = 0;
					};
				} else {
					_rearm_ticker = 0;
				};
			} else {
				_rearm_ticker = 0;
			};

			if ( _repaired ) then {
				//_screenmsg =  format [ "%1 : %2%3", localize "STR_REPAIRING", round ( 100 - (_average_damage * 100) ), "%" ];
			};

			if ( _rearmed ) then {
				if ( _repaired ) then {
					//_screenmsg = format [ "%1 - ", _screenmsg ];
				};
				//_screenmsg = format [ "%1%2", _screenmsg, format [ localize "STR_REARMING", _rearm_time - _rearm_ticker  ] ];
			};

			if ( _refueled ) then {
				if ( _repaired || _rearmed ) then {
					//_screenmsg = format [ "%1 - ", _screenmsg ];
				};
				//_screenmsg = format [ "%1%2", _screenmsg, format [ "%1 : %2%3", localize "STR_REFUELING", round ( (fuel _veh) * 100 ), "%" ] ];
			};

			titleText [ _screenmsg, "PLAIN DOWN" ];
			sleep 0.1;
		} foreach (units _gp);
	} foreach ([group player] + ([] call A3C_HCALLGROUPS));
	sleep 1;
};
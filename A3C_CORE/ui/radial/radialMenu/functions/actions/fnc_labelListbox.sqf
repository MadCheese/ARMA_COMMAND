#include "..\..\script_component.hpp"
#include "..\..\dialog_defines.hpp"

// A3C_ui_radialMenu_fnc_labelListbox

// #TODO: Confirm whether this function is exclusive to the radial menu.
private _mode = _this select 0;
private _isCategorySwitch = if (count _this > 1) then {_this select 1} else {0};

private _orderText = "";
private _lbText1 = "";
private _lbText2 = "";

(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlSetText "A3C_CORE\ui\pictures\BG_Radial_ExtensionRight.paa";
(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_BACKGROUND) ctrlShow true;
(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) ctrlShow true;




(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_HEADER) ctrlShow true;
(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_HEADER) ctrlShow true;




switch (_mode) do {
	case ("MEDICAL") : {
		_orderText =  "Order";
		_lbText1 = "Healers";
		_lbText2 = "Patients";
		private _img = "";

		private _selectedMedic = objNull;
		private _selectedPatient = objNull;

		private _medics_lb = (group player) getVariable ["A3C_MEDICS_LB", [] ];
		if (count _medics_lb == 1) then {
			_selectedMedic = (_medics_lb select 0);
		};
		private _patients_lb = (group player) getVariable ["A3C_PATIENTS_LB", [] ];
		if (count _patients_lb == 1) then {
			_selectedPatient = (_patients_lb select 0);
		};

		{
			_x ctrlShow true;
		} forEach ([
			["extensionRightLbSubselBox"] call FUNC(ctrl),
			["extensionRightGoBtn"] call FUNC(ctrl),
			["extensionRightLbSourcesHeader"] call FUNC(ctrl)
		] select {!isNull _x});

		//-- clear right extension listboxes
		{
			lbClear _x;
		} forEach (["radial_extensionRightListboxes"] call FUNC(ctrlGroup));

		private _medics = [A3C_RD_UNITS] call A3C_FINDMEDICS;
		(group player) setVariable ["A3C_MEDICS", _medics];
		private _multiMedic = (count _medics) > 1;
		
		if (_multiMedic) then {
			[["ALL MEDICS","",objNull,(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),"A3C_CORE\ui\pictures\icon_menu_Medical.paa"]] call A3C_ui_radialMenu_fnc_lbAdd;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) lbSetColor [0, [0, 1, 0, 1]];
		};

		{
			private _isMedic =   ({[_x] call A3C_main_fnc_getBaseWeapon == "Medikit"} count (items _x) > 0);
			_img = if (_isMedic) then {
				"A3C_CORE\ui\pictures\icon_menu_Medical.paa"
			} else {
				""
			};
			[
				[
					(format ["%1 (%2)",([_x] call MCSS_fnc_getUnitNameString),if (_x == player) then {""} else {getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName")}]),
					(typeOf _x),
					_x,
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),
					_img
				]
			] call A3C_ui_radialMenu_fnc_lbAdd;
			private _c = [1,1,1,1];
			if (_x in (group player getVariable ["A3C_MEDICS_ACTIVE", [] ])) then {
				_c = [0.99,0.5,0.49,1];

			} else {
				if (_x in ((group player) getVariable ["A3C_MEDICS",[]])) then {
					if (_isMedic) then {
						_c = [0,1,0,1];
					} else {
						_c = [0.68,0.99,0.63,1];
					};
				};
			};
			private _add = if (_multiMedic) then {1} else {0};
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) lbSetColor [_forEachIndex + _add, _c];

		} forEach _medics; // _squadAI

		private _patients = [group player] call A3C_FINDPATIENTS;
		private _multiPatient = (count _patients) > 1;
		if (_multiPatient) then {
			[["HEAL ALL","",objNull,(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX),""]] call A3C_ui_radialMenu_fnc_lbAdd;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX) lbSetColor [0, [0, 1, 0, 1]];
		};
		{
			private _c = [0.99,0.5,0.49,1];
			if (_x in (group player getVariable ["A3C_PATIENTS_DESIGNATED", []])) then {
				_c = [0.99,0.7,0.44,1];
			};
			if (_x in ((group player) getVariable["A3C_PATIENTS_ASSIGNED", [] ])) then {
				_c = [0.99,0.95,0.67,1];
			};
			[
				[
					(format ["%1 (%2)",([_x] call MCSS_fnc_getUnitNameString),getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName")]),
					(typeOf _x),
					_x,
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX),
					""
				]
			] call A3C_ui_radialMenu_fnc_lbAdd;
			private _add = if (_multiPatient) then {1} else {0};
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX) lbSetColor [_forEachIndex + _add, _c];
		} forEach _patients;

		private _mSel = 0;
		private _pSel = 0;
		if (!isNull _selectedMedic) then { //~~ maybe try your array index function here?
			{
				if (_x == _selectedMedic) exitWith {
					_mSel = _forEachIndex;
					if (count ((group player) getVariable ["A3C_MEDICS",[]]) > 1) then {
						_mSel = _mSel + 1;
					};

				};
			} forEach ((group player) getVariable ["A3C_MEDICS",[]]);
		};
		if (!isNull _selectedPatient) then { //~~ maybe try your array index function here?
			{
				if (_x == _selectedPatient) exitWith {
					_pSel = _forEachIndex;
					if (count _patients > 1) then {
						_pSel = _pSel + 1;
					};

				};
			} forEach _patients;
		};
		[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX, _mSel, true] call A3C_ui_shared_fnc_lbSetCurSel;
		[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX, _pSel, true] call A3C_ui_shared_fnc_lbSetCurSel;	
	};
	case ("CBMODE") : {
		//-- Legacy CBMODE/BEHAVIOR Listbox method
		_orderText = "Unit States";
		_lbText1 = "Behaviour";
		_lbText2 = "Combat Mode";
		{
			_x ctrlShow true;
		} forEach (
			(["radial_extensionRightListboxes"] call FUNC(ctrlGroup))
			+ [
				["extensionRightLbSourcesHeader"] call FUNC(ctrl)
			]
		); 
		{
			private _c = switch _forEachIndex do {
				case 0 : {[0.5,0.5,0.5,1]};
				case 1 : {[0,1,0,1]};
				case 2 : {[1,1,0,1]};
				case 3 : {[1,0,0,1]};
				case 4 : {[0.17,0.86,0.92,1]};
			};
			[
				[
					_x,
					'',
					objNull,
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),
					"\a3\ui_f\data\GUI\Cfg\CommunicationMenu\attack_ca.paa"
				]
			] call A3C_ui_radialMenu_fnc_lbAdd;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX) lbSetColor [_forEachIndex, _c];
		} forEach ["CARELESS","SAFE","AWARE","COMBAT","STEALTH"];
		{
			private _c = switch _forEachIndex do {
				case 0 : {[0,0,1,1]};
				case 1 : {[0,1,0,1]};
				case 2 : {[1,1,1,1]};
				case 3 : {[1,1,0,1]};
				case 4 : {[1,0,0,1]};
			};
			[
				[
					_x,
					'',
					objNull,
					(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX),
					"\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\target_ca.paa"
				]
			] call A3C_ui_radialMenu_fnc_lbAdd;
			(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX) lbSetColor [_forEachIndex, _c];
		} forEach ["Never Fire","Hold fire, defend only","Hold fire, engage at will","Fire At Will","Fire at will, engage at will"];


		private _lbBehaviour = switch ([A3C_RD_UNITS,"BEHAVIOUR"] call A3C_ai_squad_fnc_getProminentUnitBhvCbm) do {
			case ("CARELESS") : {0};
			case ("SAFE") : {1};
			case ("AWARE") : {2};
			case ("COMBAT") : {3};
			case ("STEALTH") : {4};
		};
		private _lbCBMode = switch ([A3C_RD_UNITS,"COMBATMODE"] call A3C_ai_squad_fnc_getProminentUnitBhvCbm) do {
			case ("BLUE") : {0};
			case ("GREEN") : {1};
			case ("WHITE") : {2};
			case ("YELLOW") : {3};
			case ("RED") : {4};
		};
		[_lbBehaviour,_lbCBMode] spawn {
			params ["_lbBehaviour","_lbCBMode"];
			
			sleep 0.1;
			[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX, _lbBehaviour] call A3C_ui_shared_fnc_lbSetCurSel;
			[findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_BOX, _lbCBMode] call A3C_ui_shared_fnc_lbSetCurSel;
			sleep 0.1;
			
		};

	};


	case ("VEHICLES") : {
		_lbText1 = "SELECT VEHICLE";

		

		//-- idc's stay numeric here as they were created dynamically with ctrlCreate
		for "_i" from 0 to 45 do {
			if (ctrlType (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i)) != -1) then {
				ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i));
				ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl (10101 + _i + 1));
			};
		};

		for "_i" from 11101 to 11104 do {
			ctrlDelete (findDisplay IDD_RADIAL_MENU displayCtrl _i);
		};

		if (!isNil 'A3C_TARGETVEH') then {
			private _vehicleSeatData = [];
			//-- re-arrange
			{
				private _testedRole = _x;
				{
					if (_x select 1 == _testedRole) then {
						if (_testedRole != "driver" OR {!(A3C_TARGETVEH isKindOf "STATICWEAPON")}) then {
							_vehicleSeatData pushBackUnique _x;
						};		
					};
				} forEach (fullCrew [A3C_TARGETVEH,"",true]);
			} forEach ["driver","gunner","commander","Turret","cargo"];


			private _rowEntries = 0;
			private _rowAmount = 0;
			private _GUI_GRID_X = 0;
			private _GUI_GRID_Y = 0;
			private _GUI_GRID_W = 0.025;
			private _GUI_GRID_H = 0.04;

			private _btnH = if (count _vehicleSeatData > 15) then {1} else {2}; //-- 15 seats is threshold instead of 20 because we need the last row for 'board all'
			private _btnW = _btnH * 1.25;
			private _rowThreshold = if (count _vehicleSeatData > 15) then {10} else {5};

			_btnW = _btnW * _GUI_GRID_W;
			_btnH = _btnH * _GUI_GRID_H;
			private _spacingFactor = 0.1;


			private _vehicleType = typeOf A3C_TARGETVEH;


			{
				private _roleData = _x;
				_roleData params ["_occupyingUnit","_role","_cargoIndex","_turretPath","_isFFV"];

				private _buttonColor = [1,1,1,1];

				private _fei = _forEachIndex;
				private _btnImg  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscPicture", 10101 + (_fei * 2)];
				private _btnClicker  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscButton_Invisible", 10101 + (_fei * 2) + 1];
				private _btnIcon = "";


				private _positionName = ""; //-- can not use 'role' as default value - ends up being lower case and that's not purdy
				
				switch (toLower _role) do {
					case ("driver") : {
						_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_driver_ca.paa";
						_positionName = "Driver";
					};
					case ("turret") : {
						private _cfgPath = configFile >> "CfgVehicles" >> _vehicleType;
						{
							_cfgPath = ( _cfgPath >> "turrets" ) select _x;
						} forEach _turretPath; //-- teacher: Larrow
						_positionName = getText( _cfgPath >> "gunnerName" );
						
						// systemchat str [_role, _vehicleType];
						switch (_positionName) do {
							case ("Commander") : {
								_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa";

							};
							case ("Copilot") : {
								_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa";
							};
							default {
								_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa";
							};
						};
						if (_isFFV) then {
							_positionName = _positionName + " - FFV";
						};
					};
					case ("gunner") : {
						_positionName = "Gunner";
						_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_gunner_ca.paa";
					};
					case ("commander") : {
						_positionName = "Commander";
						_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_commander_ca.paa";
					};
					case ("cargo") : {
						_btnIcon = "\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa";
						_positionName = format ["Cargo Seat %1",_cargoIndex + 1];
					};
				};


				if (!isNull _occupyingUnit && {alive _occupyingUnit}) then {
					_buttonColor = if (_occupyingUnit in units player) then {[A3C_UI_COLOR_BLUE,0.7] call A3C_UI_fnc_setOpacity} else {[A3C_UI_COLOR_RED,0.7] call A3C_UI_fnc_setOpacity};

					if (_occupyingUnit in units player) then {
						_positionName = _positionName + " (" + (name _occupyingUnit) + ")";
					} else {
						_positionName = _positionName + " (occupied by " + (groupID (group _occupyingUnit)) + ")";
					};
				} else {


					private _nameAdd = " (Available)";

					private _vicVar = A3C_TARGETVEH getVariable ["A3C_AssignedVehicleCrew",[]];

					private _refArray = _roleData select [1,3]; //[_roleData select 1,_roleData select _checkIndex];
					{
						private _boardingData = _x;
						if ({_x in _boardingData} count _refArray >= 2) exitWith {
							_occupyingUnit = _x select 0;
							_buttonColor = if (group _occupyingUnit == group player) then {[A3C_UI_COLOR_BLUE,0.3] call A3C_UI_fnc_setOpacity} else {[A3C_UI_COLOR_RED,0.3] call A3C_UI_fnc_setOpacity};
							_nameAdd = " (Currently Boarded)";
						};
					} forEach _vicVar;
					_positionName = _positionName + _nameAdd;

				};
				_btnImg ctrlSetTextColor _buttonColor;
				_btnClicker ctrlSetTooltip _positionName;
				//-- when looking at this fnc, keep in mind that it requires vehicleVarname or an !isNull object. Hence the format (Player units have vehicleVarname
				//-- NOTE: ctrlAddEventHandler is allowed as button is created with ctrlCreate 
				_btnClicker ctrlAddEventHandler
				[
					"MouseButtonDown",
					compile format
					[
						"
							private _roleArray = [%1] + %2;
							[_roleArray,_this select 1,%3,objNull] call A3C_AssignVehicleSeat;
						",
						if (_occupyingUnit in units player) then {_occupyingUnit} else {if (isNull _occupyingUnit OR {!alive _occupyingunit}) then {0} else {1}},
						_roleData select [1,4],
						10101 + (_fei * 2)
					]
				];


				{
					_x ctrlSetPosition
					[
						(35.5 * _GUI_GRID_W + _GUI_GRID_X) + (_rowEntries * (_btnW + (_btnW * _spacingFactor))),
						(11.5 * _GUI_GRID_H + _GUI_GRID_Y) + (_rowAmount * (_btnH + (_btnH * _spacingFactor)) ),
						_btnW,
						_btnH
					];
					_x ctrlCommit 0;
				} forEach [_btnImg,_btnClicker];

				_btnImg ctrlSetText _btnIcon;


				_rowEntries = _rowEntries + 1;
				if (_rowEntries == _rowThreshold) then {
					_rowEntries = 0;
					if (_forEachIndex < ((count _vehicleSeatData) - 1)) then {
						_rowAmount = _rowAmount + 1;
					};
				};
			} forEach _vehicleSeatData;

			_rowAmount = _rowAmount + 1;
			if (!isNull A3C_TARGETVEH && {count A3C_RD_UNITS > 1 && {count _vehicleSeatData > 1}}) then {
				//-- macro buttons
				for "_i" from 0 to 1 do {

					private _btnImg  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscPicture", 11101 + (_i * 2)];
					private _btnClicker  = findDisplay IDD_RADIAL_MENU ctrlCreate ["A3C_RscButton_Invisible", 11101 + (_i * 2) + 1];

					private _btnIcon = switch (_i) do {
						case (0) : {"\a3\ui_f\data\IGUI\Cfg\Cursors\getIn_ca.paa"};
						case (1) : {"\a3\ui_f\data\IGUI\RscIngameUI\RscUnitInfo\role_cargo_ca.paa"};
					};
					_btnImg ctrlSetText _btnIcon;

					private _btnTooltip = switch (_i) do {
						case (0) : {"BOARD ALL POSITIONS"};
						case (1) : {"BOARD CARGO & FFV"};
					};
					_btnClicker ctrlSetTooltip _btnTooltip;
					{
						_x ctrlSetPosition
						[
							(39  * _GUI_GRID_W + _GUI_GRID_X) + (_i * (_btnW + (_btnW * _spacingFactor))),
							(11.5 * _GUI_GRID_H + _GUI_GRID_Y) + (_rowAmount  * (_btnH + (_btnH * _spacingFactor)) ),
							_btnW,
							_btnH
						];
						_x ctrlCommit 0;
					} forEach [_btnImg,_btnClicker];

					private _units = +(A3C_RD_UNITS);
					
					//-- NOTE: ctrlAddEventHandler is allowed as button is created with ctrlCreate 
					_btnClicker ctrlAddEventHandler
					[
						"MouseButtonDown",
						compile format
						[
							"
								[A3C_TARGETVEH,'%1',_this select 1,%2] spawn A3C_ai_squad_fnc_boardingAssignVehicleSeatMacro ;
							",
							if (_i == 0) then {'all'} else {'cargoFFV'},
							_units
						]
					];
				};
			};
			
			//-- add macro options: getIn all, all cargoFFV

			if (_isCategorySwitch == 0) then {
				{
					private _c = (crew _x) - [player];
					private _n = "";
					{
						if ((group _x) == (group player)) then {
							_n = _n + 
							(
								[
									_x,
									if (_forEachIndex == ((count _c) - 1)) then {true} else {false}
								] call MCSS_fnc_getUnitNameString
							);
						} else {
							_c = _c - [_x];
						};
					} forEach _c;
					if !(_n == "") then {
						_n = "(" + _n + ")";
					};
					[
						[
							format
							[
								"%1 %2",
								(getText (configFile >> "CfgVehicles" >> (typeOf _x) >> "displayName")),
								_n
							],
						(typeOf _x),
						_x,
						(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_BOX),
						""
						]
					] call A3C_ui_radialMenu_fnc_lbAdd;
				} forEach A3C_VEHSAV;
			};
		};

		
	};
};

(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_GO_BTN) ctrlSetText _orderText;
(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSOURCES_HEADER) ctrlSetText _lbText1;
(findDisplay IDD_RADIAL_MENU displayCtrl IDC_RADIAL_EXTENSIONRIGHT_LBSUBSEL_HEADER) ctrlSetText _lbText2;

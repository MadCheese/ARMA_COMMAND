

	Testv = 0;
	test_polygon = [];
	test_polygon1 = [];
	A3C_MAP_EH_51_MDNEW = (findDisplay 12 displayCtrl 51) ctrlAddEventHandler
	[
		"MouseButtonDown",
		{
			if (_this select 1 == 1) exitwith {};
			_sx = _this select 2;
			_sy = _this select 3;
			TestV = TestV + 1;
			
			if !(isnil "PolyG") then {
				if (typeName PolyG == "SCALAR") then {
					(findDisplay 12 displayCtrl 51) ctrlRemoveEventHandler ['Draw',PolyG];
					test_polygon = [];
					Polyg = Nil;	
				};
			};
			
			test_polygon pushback ((findDisplay 12 displayCtrl 51) posscreentoworld [_sx,_sy]);
			
			
			
				
			if (count test_polygon >= 5) then {
				TestV = 0;
				
				for "_i" from 1 to 5 do 
				{
					test_polygon1 pushBack (player getPos [10 + random 100, 360/_i]);
				};
				TP1 = test_polygon;
			
				PolyG = findDisplay 12 displayCtrl 51 ctrlAddEventHandler ["Draw", 
				{
					_this select 0 drawPolygon [TP1, [A3C_UI_COLOR_BLUE,1] call A3C_UI_Color_setOpacity];
				}];
				
				
			};
		}
	];
	uiNamespace setVariable ["A3C_INDEX_VAR_MAP_MOUSED_NEW",A3C_MAP_EH_51_MDNEW];
	
	
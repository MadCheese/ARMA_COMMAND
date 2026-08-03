#include "BIS_AddonInfo.hpp"



class CfgPatches {
	class A3C_UI {
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"CBA_Extended_EventHandlers"};
	};

};

class CfgMarkers {
	
	
	
	class icon_Rad_3D_Modifier_ON {
		name = icon_Rad_3D_Modifier_ON;
		icon = "\A3C_UI\markers\icon_Rad_3D_Modifier_ON.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 64;
	};
	
	class icon_Rad_3D_Modifier_OFF {
		name = icon_Rad_3D_Modifier_OFF;
		icon = "\A3C_UI\markers\icon_Rad_3D_Modifier_OFF.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 64;
	};
	
	
	class A3C_MARKER_Paradrop {
		name = A3C_MARKER_Paradrop;
		icon = "\A3C_UI\markers\A3C_MARKER_Paradrop.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	
	
	class A3C_MARKER_Rappel {
		name = A3C_MARKER_Rappel;
		icon = "\A3C_UI\markers\A3C_MARKER_Rappel.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};

	class A3C_MARKER_PackStaticWeapon {
		name = A3C_MARKER_PackStaticWeapon;
		icon = "\A3C_UI\markers\A3C_MARKER_PackStaticWeapon.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};



	class A3C_MARKER_Detonation {
		name = A3C_MARKER_Detonation;
		icon = "\A3C_UI\markers\A3C_MARKER_Detonation.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	
	class A3C_MARKER_Timeout {
		name = A3C_MARKER_Timeout;
		icon = "\A3C_UI\markers\A3C_MARKER_Timeout.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	class A3C_MARKER_SlingLoad {
		name = A3C_MARKER_SlingLoad;
		icon = "\A3C_UI\markers\A3C_MARKER_SlingLoad.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	class A3C_MARKER_SlingDrop {
		name = A3C_MARKER_SlingDrop;
		icon = "\A3C_UI\markers\A3C_MARKER_SlingDrop.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	
	class A3C_MARKER_DROPOFF_GROUND {
		name = A3C_MARKER_DROPOFF_GROUND;
		icon = "\A3C_UI\markers\getout_ca.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	class A3C_MARKER_PICKUP_GROUND {
		name = A3C_MARKER_PICKUP_GROUND;
		icon = "\A3C_UI\markers\getin_ca.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	class A3C_MARKER_DROPOFF_AIR {
		name = A3C_MARKER_DROPOFF_AIR;
		icon = "\A3C_UI\markers\getout_ca.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	class A3C_MARKER_PICKUP_AIR {
		name = A3C_MARKER_PICKUP_AIR;
		icon = "\A3C_UI\markers\getin_ca.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	
	class A3C_MARKER_LANDING {
		name = A3C_MARKER_LANDING;
		icon = "\A3C_UI\markers\helipad.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	
	class A3C_MARKER_SMOKE {
		name = A3C_MARKER_SMOKE;
		icon = "\A3C_UI\markers\SmokeGREEN.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 32;
	};
	
	class A3C_MARKER_WAYPOINT {
		name = A3C_MARKER_WAYPOINT;
		icon = "\A3C_UI\markers\A3C_Waypoint.paa";
		color[] = {0, 0, 1, 1};
		scope = protected;
		size = 16;
	};
	class A3C_MARKER_icon_GoCode_A {
		name = "A3C_MARKER_icon_GoCode_A";
		icon = "\A3C_UI\markers\icon_GoCode_A.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	class A3C_MARKER_icon_GoCode_B {
		name = "A3C_MARKER_icon_GoCode_B";
		icon = "\A3C_UI\markers\icon_GoCode_B.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	class A3C_MARKER_icon_GoCode_C {
		name = "A3C_MARKER_icon_GoCode_C";
		icon = "\A3C_UI\markers\icon_GoCode_C.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	class A3C_MARKER_icon_GoCode_D {
		name = "A3C_MARKER_icon_GoCode_D";
		icon = "\A3C_UI\markers\icon_GoCode_D.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	
	
	class A3C_MARKER_GoCode_A {
		name = "A3C_MARKER_GoCode_A";
		icon = "\A3C_UI\markers\GoCode_A.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	
	class A3C_MARKER_GoCode_B {
		name = "A3C_MARKER_GoCode_B";
		icon = "\A3C_UI\markers\GoCode_B.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	
	class A3C_MARKER_GoCode_C {
		name = "A3C_MARKER_GoCode_C";
		icon = "\A3C_UI\markers\GoCode_C.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	
	class A3C_MARKER_GoCode_D {
		name = "A3C_MARKER_GoCode_D";
		icon = "\A3C_UI\markers\GoCode_D.paa";
		color[] = {1, 1, 1, 1};
		scope = protected;
		size = 16;
	};
	
	class A3C_MARKER_BUILDING {
		name = A3C_MARKER_BUILDING;
		icon = "\A3C_UI\markers\building.paa";
		color[] = {1, 1, 1, 0.7};
		scope = protected;
		size = 32;
	};
	class A3C_MARKER_HCWP {
		name = A3C_MARKER_HCWP;
		icon = "\A3C_UI\markers\HCWP.paa";
		color[] = {1, 0, 0, 0.5};
		scope = protected;
		size = 32;
	};
};

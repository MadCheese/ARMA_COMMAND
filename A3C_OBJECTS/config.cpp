#define private		0
#define protected		1
#define public		2

#define TEast		0
#define TWest		1
#define TGuerrila		2
#define TCivilian		3
#define TSideUnknown		4
#define TEnemy		5
#define TFriendly		6
#define TLogic		7

#define VSoft		0
#define VArmor		1
#define VAir		2

enum {
	DESTRUCTENGINE = 2,
	DESTRUCTDEFAULT = 6,
	DESTRUCTWRECK = 7,
	DESTRUCTTREE = 3,
	DESTRUCTTENT = 4,
	STABILIZEDINAXISX = 1,
	STABILIZEDINAXESXYZ = 4,
	STABILIZEDINAXISY = 2,
	STABILIZEDINAXESBOTH = 3,
	DESTRUCTNO = 0,
	STABILIZEDINAXESNONE = 0,
	DESTRUCTMAN = 5,
	DESTRUCTBUILDING = 1,
};


class CfgPatches {
	class A3C_OBJECTS {
		units[] = {"A3C_Supression_Target_F","MCSS_ASM_INDICATOR_F","MCSS_ASM_SUPRESSION_INDICATOR_F","A3C_Invisible_Man_F"};
		requiredVersion = 0.1;
		requiredAddons[] = {"A3_Data_F", "A3_Structures_F"};
		weapons[] = {"B_A3C_Terminal", "I_A3C_Terminal", "O_A3C_Terminal"};
	};
};

class CfgAddons {
	class A3C_OBJECTS
	{
		list[] = {"MCSS_ASM_INDICATOR_F","MCSS_ASM_SUPRESSION_INDICATOR_F","A3C_Supression_Target_F","A3C_Invisible_Man_F"};
	};
};

//class CfgMagazines
//{
//	class CA_Magazine;
//	class C2_item_commandingTablet: CA_Magazine
//	{
//		displayName="C2 HighCommand Tablet";
//		scope=2;
//		mass=1;
//		author="Mad_Cheese";
//		picture="\A3C_Objects\tablet\iconItem_commandingTablet.paa";
//		model="\A3C_Objects\tablet\C2_Item_commandingTablet.p3d";
//		descriptionShort="HC Access to all friendly AI groups";
//	};
//};

class CfgVehicleClasses {
	class A3C_Supression_Target
	{
		displayName = "C2 Target";
	};
	class A3C_Objects
	{
		displayName = "C2 Unit-Indicator (3D)";
	};
	class MCSS_ASM_SUPRESSION_INDICATOR
	{
		displayName = "C2 Supression Indicator";
	};
	class A3C_HeliPad
	{
		displayName = "ARMA COMMAND HELIPAD";
	};
	class A3C_Invisible_Man_F
	{
		displayName = "ARMA COMMAND INVISIBLE MAN TARGET";
	};
};

class CfgWeapons {
	class InventoryItem_Base_F;	// External class reference
	
	class InventoryUavTerminalItem_Base_F : InventoryItem_Base_F {
		type = 621;
	};
	class ItemCore;	// External class reference
	class ItemGPS;    // External class reference to ItemGPS
	
	
	/////////////
	class A3C_Terminal_NoUAV : ItemGPS {
        scope = public;
        displayName = "Commanding Ability (No UAV)";
        picture = "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa";
        model = "\A3\Structures_F\Items\Documents\File2_F.p3d";
        descriptionShort = "";
        
        class ItemInfo : InventoryItem_Base_F {
            mass = 10;   // Assuming the mass to be similar to the UAV terminal
        };
    };
	/////////////
	
	
	class UavTerminal_base_A3C : ItemCore {
		scope = private;
		displayName = "Commanding Ability"; //"$STR_A3_CFGWeapons_Items_UAVTerminal";
		picture="\A3C_Objects\tablet\iconItem_commandingTablet.paa";
		model="\A3C_Objects\tablet\C2_Item_commandingTablet.p3d";
		descriptionShort = "";
		
		class ItemInfo : InventoryUavTerminalItem_Base_F {
			mass = 10;
			createConnectionRadius = 5.0;
		};
	};
	
	
	
	class B_A3C_Terminal : UavTerminal_base_A3C {
		author = "Mad_Cheese / BIS";
		scope = public;
		displayName = "Commanding Ability Blufor";

		//hiddenSelectionsTextures[] = {"\A3\Drones_F\Weapons_F_Gamma\Items\data\UAV_controller_rgr_co.paa"};
		
		class ItemInfo : ItemInfo {
			side = TWest;
		};
	};
	
	class O_A3C_Terminal : UavTerminal_base_A3C {
		author = "Mad_Cheese / BIS";
		scope = public;
		displayName = "Commanding Ability Opfor";

		
		class ItemInfo : ItemInfo {
			side = TEast;
		};
	};
	
	class I_A3C_Terminal : UavTerminal_base_A3C {
		author = "Mad_Cheese / BIS";
		scope = public;
		displayName = "Commanding Ability Indep";

		
		class ItemInfo : ItemInfo {
			side = TGuerrila;
		};
	};
};

class CfgVehicles {
	class LandVehicle;	// External class reference
	class Civilian;
	class NonStrategic;
	
	class StaticWeapon : LandVehicle {
		class NewTurret;	// External class reference
	};
	
	class MC_TARGET_BASE : StaticWeapon {
		scope = private;
		scopeCurator = 0;
		displayName = "Supression Area";
		model = "\a3\structures_f\mil\helipads\helipadempty_f.p3d";
		cost = 200000;
		accuracy = 0.05;	// accuracy needed to recognize type of this target
		destrType = "DestructNo";
		side = TEnemy;
		alwaysTarget = 1;
		armor = 3;
		type = VSoft;
		vehicleClass = "Training";
		
		class Turrets {
			class MainTurret : NewTurret {
				body = "";
				gun = "";
			};
		};
	};
	
	class A3C_Supression_Target_F : MC_TARGET_BASE {
		scope = protected;
		scopeCurator = 0;
		crew = B_UAV_AI;
		typicalCargo[] = {B_UAV_AI};
		side = TWest;
		faction = BLU_F;
		displayName = "Invisible Target (C2)";
		icon = "\A3\Misc_F\Helpers\data\ui\icons\Sign_Sphere100cm_F";
	};
	////
	
	class MCSS_Helper_Base_F: NonStrategic
	{
		displayName = "";
		vehicleClass = "Helpers";
		mapSize = 0.1;
		destrType = "destructNo";
		hiddenSelections[] = {"camo"};
		hiddenSelectionsTextures[] = {"#(argb,8,8,3)color(1,1,1,0.2,ca)"};
	};
	class MCSS_ASM_INDICATOR_F: MCSS_Helper_Base_F
	{
		mapSize = 1;
		author = "";
		_generalMacro = "MCSS_ASM_INDICATOR_F";
		scope = 2;
		displayName = "C2 3D INDICATOR";
		model = "\A3C_Objects\indicatorUnit\INDICATORNew3.p3d";
		icon = "\A3\Misc_F\Helpers\data\ui\icons\Sign_Sphere100cm_F";
		accuracy = 1000;
	};
	class MCSS_ASM_SUPRESSION_INDICATOR_F: MCSS_Helper_Base_F
	{
		mapSize = 1;
		author = "";
		_generalMacro = "MCSS_ASM_SUPRESSION_INDICATOR_F";
		scope = 2;
		displayName = "C2 3D SUPRESSION INDICATOR";
		model = "\A3C_Objects\indicatorTarget\Supression_Indicator1.p3d";
		icon = "\A3\Misc_F\Helpers\data\ui\icons\Sign_Sphere100cm_F";
		accuracy = 1000;
	};
	class A3C_HeliPad: MCSS_Helper_Base_F
	{
		mapSize = 1;
		author = "";
		_generalMacro = "A3C_HeliPad";
		scope = 2;
		displayName = "ARMA COMMAND HELIPAD";
		model = "\A3C_Objects\HeliPad\HeliPadPlane.p3d";
		icon = "\A3C_Objects\HeliPad\thingy2.paa";
		accuracy = 1000;
	};
	
	
	class A3C_Invisible_Man_F:Civilian 
	{
		scope = 2;
		side = 3;
		model = "\A3\Structures_F\Training\InvisibleTarget_F.p3d";
		displayName = "invisible man";
		cost = 0;
		//threat:[0,0,0]
	};
};
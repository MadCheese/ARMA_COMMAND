#include "BIS_AddonInfo.hpp"
class CfgPatches
{
	class A3C_CORE
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"CBA_Extended_EventHandlers", "A3_Dubbing_Radio_F"};
		projectName = "ARMA COMMAND DLC";
		author = "Mad_Cheese";
	};

	class Disable_XEH_Logging
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {};
	};
};

class Extended_PreInit_EventHandlers
{
	A3C_init = "call compile preprocessFileLineNumbers 'A3C_CORE\A3C_Init.sqf';";
};

// #include "ui\baseClasses.hpp"
// #include "ui\defines.hpp"
#include "ui\A3C_BaseClasses.hpp"

#include "ui\tablet\A3C_MapControls.hpp"
// #include "ui\tablet\A3C_TAB.hpp"
#include "ui\tablet\A3C_MAP.hpp"
#include "ui\radial\A3C_RadialMenu.hpp"
#include "ui\HUD\HUD_MENU.hpp"
#include "ui\HUD\HUD_BHV_CBM.hpp"
#include "ui\HUD\HUD_Formation_Menu.hpp"
#include "ui\HUD\HUD_CAM_UI.hpp"
// #include "ui\radial\A3C_FORMATION.hpp"
#include "ui\radial\A3C_SETTINGS_DIALOG.hpp"
#include "ui\suppression\A3C_SUPPRESSION_DRAW.hpp"
#include "cfgsounds.hpp"

class CfgRemoteExec
{
	// List of script functions allowed to be sent from client via remoteExec
	class Functions
	{
		// RemoteExec modes:
		// 0- turned off
		// 1- turned on, taking whitelist into account
		// 2- turned on, ignoring whitelist (default, because of backward compatibility)
		mode = 2;

		// Ability to send jip messages: 0-disabled, 1-enabled (default)
		jip = 1;

		// your functions here
		class A3C_checkserverAddon
		{
			allowedTargets = 0; // can target anyone (default)
			jip = 0;			// sending jip messages is disabled for this function
					 // (overrides settings in the Functions class)
		};
		// class YourFunctionOne { allowedTargets = 1; }; // can target only clients
		// class YourFunctionTwo { allowedTargets = 2; }; // can target only the server
	};

	// List of script commands allowed to be sent from client via remoteExec
	class Commands
	{
		// your commands here
	};
};

// class RscChatListDefault {
//     colorMessage[]={0.99,0.29,0.25,1};
//    colorMessageProtocol[]={0.99,0.29,0.25,1};
// };

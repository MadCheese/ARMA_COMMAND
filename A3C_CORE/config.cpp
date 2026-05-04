#include "BIS_AddonInfo.hpp"

#include "script_mod.hpp"
#include "script_macros.hpp"

#include "ui\A3C_BaseClasses.hpp"

#include "ui\mapOverlay\dialog.hpp"

#include "ui\HUD\HUD_DYNAMIC\A3C_DSP_HUD_DYNAMIC.hpp"
#include "ui\HUD\customFormation\UI_DSP_CustomFormation.hpp"

#include "ui\radial\radialMenu\dialog.hpp"
#include "ui\radial\settingsMenu\dialog.hpp"

#include "ui\hud\squadPlacement\dialog.hpp"
#include "ui\hud\squadPlacement\rscTitles.hpp"

#include "ui\suppression\A3C_SUPPRESSION_DRAW.hpp"

#include "ui\hud\selectionPromptPanel\dialog.hpp"

#include "cfgsounds.hpp"

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

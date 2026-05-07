//---------------------------------------------------------------------------------------------
//---------- 2. Positional actions ------------------------------------------------------------
//---------------------------------------------------------------------------------------------

//----- Remote-Fire Actions 

A3C_AI_SHARED_Action_remoteFire_TankShot = {
	[A3C_REMFIRE_TankShot_Units, "TANKSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};

A3C_AI_SHARED_Action_remoteFire_UGLshot = {
	[A3C_REMFIRE_UGLShot_Units, "UGLSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};


A3C_AI_SHARED_Action_remoteFire_ATshot = {
	[A3C_REMFIRE_ATShot_Units, "ATSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};

A3C_AI_SHARED_Action_remoteFire_StaticRocketShot = {
	[A3C_REMFIRE_StaticShot_Units, "STATICSHOT"] spawn A3C_AI_SHARED_STRUCTURE_REMOTE_LAUNCH;
};



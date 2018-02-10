#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Fog System Core"

int FogIndex = -1;
float mapFogStart = 0.0;
float mapFogEnd = 150.0;
float mapFogDensity = 0.99;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = JB_PLUGIN_AUTHOR,
	description = JB_PLUGIN_DESCRIPTION,
	version = JB_PLUGIN_VERSION,
	url = JB_PLUGIN_URL
};

public void OnPluginStart()
{
    RegAdminCmd("sm_fogoff", Command_EnableFog, ADMFLAG_ROOT);
    RegAdminCmd("sm_fogon", Command_DisableFog, ADMFLAG_ROOT);
}

public void OnMapStart()
{
    int ent = FindEntityByClassname(-1, "env_fog_controller");
	
    if (ent != -1) {
		FogIndex = ent;
    } else {
		FogIndex = CreateEntityByName("env_fog_controller");
		DispatchSpawn(FogIndex);
	}
	
	if(FogIndex != -1)  {
		DispatchKeyValue(FogIndex, "fogblend", "0");
		DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
		DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
		DispatchKeyValueFloat(FogIndex, "fogstart", mapFogStart);
		DispatchKeyValueFloat(FogIndex, "fogend", mapFogEnd);
		DispatchKeyValueFloat(FogIndex, "fogmaxdensity", mapFogDensity);
	}
	
	AcceptEntityInput(FogIndex, "TurnOff");
}

public Action Command_EnableFog(int client, int args)
{
	AcceptEntityInput(FogIndex, "TurnOff");
}    

public Action Command_DisableFog(int client, int args)
{
	AcceptEntityInput(FogIndex, "TurnOn");
}
#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>
#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Friendly Fire"

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
	Handle cvar = FindConVar("mp_friendlyfire");

	new flags = GetConVarFlags(cvar);
	if(flags & FCVAR_NOTIFY)
	{
		flags &= ~FCVAR_NOTIFY;
		SetConVarFlags(cvar, flags);
	}

	HookConVarChange(cvar, CVarChange);
}

public void CVarChange(Handle convar, const char[] oldValue, const char[] newValue) {

	new valor = StringToInt(newValue);
	
	if(valor == 1) SetConVarInt(convar, 0);
}


#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>
#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Hide Attacker"

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
	HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_Pre);
}


public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast) 
{
	if (!dontBroadcast)
	{
		int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
		int userid = GetEventInt(event, "userid");
		int client = GetClientOfUserId(userid);

		if (!IsValidClient(attacker) || attacker == client)
			return Plugin_Continue;

		if (GetClientTeam(attacker) == 2) {
			char Weapon[32];
			GetEventString(event, "weapon", Weapon, sizeof(Weapon));

			Handle newEvent = CreateEvent("player_death", true);
			SetEventInt(newEvent, "userid", userid);
			SetEventInt(newEvent, "attacker", userid);
			SetEventString(newEvent, "weapon", Weapon);
			SetEventBool(newEvent, "headshot", GetEventBool(event, "headshot"));
			SetEventInt(newEvent, "dominated", GetEventInt(event, "dominated"));
			SetEventInt(newEvent, "revenge", GetEventInt(event, "revenge"));

			FireEvent(newEvent, false);

			dontBroadcast = true;
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}
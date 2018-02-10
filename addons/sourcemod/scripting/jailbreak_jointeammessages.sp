#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - JoinTeamMessages"

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
	HookEvent("player_team", Event_PlayerTeam_Pre, EventHookMode_Pre);
	HookEvent("player_disconnect", Event_OnPlayerDisconnect, EventHookMode_Pre);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_Pre); 
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast) 
{ 
    ServerCommand("mp_teamname_1 EverGames.pl » Strażnicy; mp_teamname_2 EverGames.pl » Wieźniowie");
}

public Action Event_PlayerTeam_Pre(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int team = GetEventInt(event, "team");
	
	if(!IsValidClient(client)) {
		return Plugin_Handled;
	}
	
	if(!dontBroadcast)
	{
		Handle new_event = CreateEvent("player_team", true);
		
		SetEventInt(new_event, "userid", GetEventInt(event, "userid"));
		SetEventInt(new_event, "team", GetEventInt(event, "team"));
		SetEventInt(new_event, "oldteam", GetEventInt(event, "oldteam"));
		SetEventBool(new_event, "disconnect", GetEventBool(event, "disconnect"));
		
		FireEvent(new_event, true);
		
		return Plugin_Handled;
	}
	
	if(!IsFakeClient(client))
	{
		if(team == CS_TEAM_CT)
		{
			CPrintToChatAll("\x0B[EverGames] {BLUE}%N{DEFAULT} dołączył do \x0BStrażników{DEFAULT}.",  client);
		} else if(team == CS_TEAM_T) {
			CPrintToChatAll("\x0B[EverGames] {BLUE}%N{DEFAULT} dołączył do \x0FWieźniów{DEFAULT}.", client);
		} else if(team == CS_TEAM_SPECTATOR) {
			CPrintToChatAll("\x0B[EverGames] {BLUE}%N{DEFAULT} dołączył do \x09Widzów{DEFAULT}.", client);
		}
	}
	
	return Plugin_Continue;
}

public Action Event_OnPlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!IsValidClient(client)) {
		return Plugin_Handled;
	}
	
	char reason[256];
	GetEventString(event, "reason", reason, sizeof(reason));
	
	if(!IsFakeClient(client))
	{
		CPrintToChatAll("\x0B[EverGames] \x07%N{DEFAULT} wyszedł z serwera (%s).", client, reason);
	}
	
	return Plugin_Handled;
}
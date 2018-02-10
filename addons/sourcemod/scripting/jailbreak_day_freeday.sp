#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Day: Freeday"

bool g_bRoundStarted = true;

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
	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	g_bRoundStarted = true;
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if(!JailBreak_isRoundActive())
		return Plugin_Handled;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "FreeDay", false))
		return Plugin_Handled;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!g_bRoundStarted) {
		SetEntProp(client, Prop_Data, "m_iFrags", GetEntProp(client, Prop_Data, "m_iFrags") + 1);
		SetEntProp(client, Prop_Data, "m_iDeaths", GetEntProp(client, Prop_Data, "m_iDeaths") - 1);
		ForcePlayerSuicide(client);
		CPrintToChat(client, "\x0B[EverGames]\x06 Musisz poczekać do końca zabawy!");
	}
	return Plugin_Handled;
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{	
	if(!JailBreak_isRoundActive())
		return Plugin_Handled;
	
	g_bRoundStarted = true;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "FreeDay", false))
		return Plugin_Handled;
	
	LoopValidClients(i)
		if(GetClientTeam(i) == CS_TEAM_T)
			if(IsPlayerAlive(i)) {
				JailBreak_SetFreeDay(i);
			} else {
				CS_RespawnPlayer(i);
				JailBreak_SetFreeDay(i);
			}
	
	CreateTimer(5.0, DisableRespawn);
	
	JailBreak_OpenDoors();
	JailBreak_StartMessage();
	return Plugin_Handled;
}

public Action DisableRespawn(Handle timer)
{
	g_bRoundStarted = false;
}

public void JailBreak_StartMessage()
{
	CPrintToChatAll("");
	CPrintToChatAll("");
	CPrintToChatAll("");
	CPrintToChatAll("");
	CPrintToChatAll("");
	CPrintToChatAll("\x0B[EverGames]\x07 Cele zostały otwarte automatycznie!");
	CPrintToChatAll("\x0B[EverGames] \x07===================================");
	CPrintToChatAll("\x0B[EverGames] \x03Zabawa:");
	CPrintToChatAll("\x0B[EverGames] \x04- \x06FreeDay \x05(Dzień wolny)");
	CPrintToChatAll("\x0B[EverGames] \x03Opis:");
	CPrintToChatAll("\x0B[EverGames] \x06Każdy z więźniów otrzymuje dzień wolny.");
	CPrintToChatAll("\x0B[EverGames] \x06Obowiązują tutaj podstawowe zasady.");
	CPrintToChatAll("\x0B[EverGames] \x06FreeDay trwa cały dzień (czyli 2 minuty)!");
	CPrintToChatAll("\x0B[EverGames] \x07===================================");
}

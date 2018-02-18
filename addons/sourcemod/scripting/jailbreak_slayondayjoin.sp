#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Fix round restarts"

bool g_bFirstJoin[MAXPLAYERS + 1] = { false, ... };

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
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_team", Event_PlayerTeamSwitch, EventHookMode_Pre);
	HookEvent("jointeam_failed", Event_JoinTeamFailed, EventHookMode_Pre);
	AddCommandListener(Command_JoinTeam, "jointeam");
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	LoopValidClients(i)
		if(g_bFirstJoin[i]) {
			ChangeClientTeam(i, 2);
			g_bFirstJoin[i] = false;
		}
}

public Action Event_PlayerTeamSwitch(Handle event, const char[] name, bool dontBroadcast)
{
	if(!JailBreak_isRoundActive())
		return Plugin_Continue;
	
	//int NewTeam = GetEventInt(event, "team");
	int OldTeam = GetEventInt(event, "oldteam");
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (OldTeam == CS_TEAM_NONE || OldTeam == CS_TEAM_SPECTATOR) {
		CreateTimer(0.0, Timer_SwapFirstJoin, client);
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action Timer_SwapFirstJoin(Handle timer, any client)
{
	ChangeClientTeam(client, 1);
}

public Action Event_JoinTeamFailed(Handle event, const char[] name, bool dontBroadcast)
{
	if(!JailBreak_isRoundActive())
		return Plugin_Continue;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!IsValidClient(client))
		return Plugin_Continue;
	
	int NewTeam = GetEventInt(event, "team");
	int OldTeam = GetEventInt(event, "oldteam");
	
	if((OldTeam == CS_TEAM_NONE || OldTeam == CS_TEAM_SPECTATOR) && (NewTeam == CS_TEAM_CT || NewTeam == CS_TEAM_T)) {
		g_bFirstJoin[client] = true;
		CPrintToChat(client, "\x02[EverGames]\x06 Musisz poczekać na zakończenie zabawy!");
		CPrintToChat(client, "\x02[EverGames]\x06 Zostaniesz przeniesiony na koniec rundy!");
		ChangeClientTeam(client, 1);
		FakeClientCommand(client, "teammenu");
		return Plugin_Handled;
	}
	
	ChangeClientTeam(client, 1);
	return Plugin_Handled;
}

public Action Command_JoinTeam(client, const char[] command, int args)
{
	if(!JailBreak_isRoundActive())
		return Plugin_Continue;
	
	if(!IsValidClient(client))
		return Plugin_Continue;
	
	char targetTeam[3];
	GetCmdArg(1, targetTeam, sizeof(targetTeam));
	int Target_Team = StringToInt(targetTeam);
	int Current_Team = GetClientTeam(client);

	if (Current_Team == Target_Team) {
		CPrintToChat(client, "\x0B[EverGames]\x06 Już jesteś w tej drużynie!");
		return Plugin_Handled;
	}

	if ((Current_Team == CS_TEAM_T && Target_Team == CS_TEAM_CT) || (Current_Team == CS_TEAM_CT && Target_Team == CS_TEAM_T)) {
		CPrintToChat(client, "\x0B[EverGames]\x06 Zakaz zmiany drużyny podczas zabawy!");
		return Plugin_Handled;
	}

	if ((Current_Team == CS_TEAM_NONE || Current_Team == CS_TEAM_SPECTATOR) && (Target_Team == CS_TEAM_CT || Target_Team == CS_TEAM_T)) {
		g_bFirstJoin[client] = true;
		CPrintToChat(client, "\x02[EverGames]\x06 Musisz poczekać na zakończenie zabawy!");
		CPrintToChat(client, "\x02[EverGames]\x06 Zostaniesz przeniesiony na koniec rundy!");
		ChangeClientTeam(client, 1);
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}
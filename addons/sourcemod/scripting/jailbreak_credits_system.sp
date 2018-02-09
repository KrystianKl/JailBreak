#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Credits System"

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
	HookEvent("player_death", Event_OnPlayerDeath);
	
	CreateTimer(60.0, Timer_Credits, _, TIMER_REPEAT);
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	int clients = 0;
	
	LoopValidClients(i)
		if(GetClientTeam(i) > 1)
			clients++;
	
	if(clients < 3) return Plugin_Handled;
	
	LoopValidClients(i)
		if (GetClientTeam(i) > 1) {
			if(VIP_Elite(i)) {
				JailBreak_SetCredits(i, JailBreak_GetCredits(i)+20);
				CPrintToChat(i, "\x0B[EverGames] \x06Otrzymujesz \x03+20 kredytów\x06 za przeżycie rundy.");
			} else if(VIP(i)) {
				JailBreak_SetCredits(i, JailBreak_GetCredits(i)+10);
				CPrintToChat(i, "\x0B[EverGames] \x06Otrzymujesz \x03+10 kredytów\x06 za przeżycie rundy.");
			} else {
				JailBreak_SetCredits(i, JailBreak_GetCredits(i)+5);
				CPrintToChat(i, "\x0B[EverGames] \x06Otrzymujesz \x03+5 kredytów\x06 za przeżycie rundy.");
			}
		}
	
	return Plugin_Handled;
}

public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if (IsValidClient(client)) return Plugin_Handled;
	if (IsValidClient(attacker)) return Plugin_Handled;
	if (client == attacker) return Plugin_Handled;
	
	if(VIP_Elite(attacker)) {
		JailBreak_SetCredits(attacker, JailBreak_GetCredits(attacker)+10);
		CPrintToChat(attacker, "\x0B[EverGames] \x06Otrzymujesz \x03+10 kredytów\x06 za zabicie \x09%N\x06.", client);
	} else if(VIP(attacker)) {
		JailBreak_SetCredits(attacker, JailBreak_GetCredits(attacker)+5);
		CPrintToChat(attacker, "\x0B[EverGames] \x06Otrzymujesz \x03+5 kredyty\x06 za zabicie \x09%N\x06.", client);
	} else {
		JailBreak_SetCredits(attacker, JailBreak_GetCredits(attacker)+2);
		CPrintToChat(attacker, "\x0B[EverGames] \x06Otrzymujesz \x03+2 kredyty\x06 za zabicie \x09%N\x06.", client);
	}
	return Plugin_Handled;
}

public Action Timer_Credits(Handle timer)
{
	int clients = 0;
	
	LoopValidClients(i)
		if(GetClientTeam(i) > 1)
			clients++;
	
	if(clients < 3) return;
	
	LoopValidClients(i)
		if (GetClientTeam(i) > 1) {
			if(VIP_Elite(i)) {
				JailBreak_SetCredits(i, JailBreak_GetCredits(i)+5);
				CPrintToChat(i, "\x0B[EverGames] \x06Otrzymujesz \x03+5 kredytów\x06 za granie na serwerze.");
			} else if(VIP(i)) {
				JailBreak_SetCredits(i, JailBreak_GetCredits(i)+2);
				CPrintToChat(i, "\x0B[EverGames] \x06Otrzymujesz \x03+2 kredyty\x06 za granie na serwerze.");
			} else {
				JailBreak_SetCredits(i, JailBreak_GetCredits(i)+1);
				CPrintToChat(i, "\x0B[EverGames] \x06Otrzymujesz \x03+1 kredyt\x06 za granie na serwerze.");
			}
		}
}
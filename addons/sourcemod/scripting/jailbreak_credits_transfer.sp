#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Credits Transfer"

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
	RegConsoleCmd("sm_przekaz", Command_Transfer);
}

public Action Command_Transfer(int client, int args)
{
	if(args < 2) {
		CPrintToChat(client, "\x0B[EverGames] \x01Użycie: {blue}sm_przekaz <#userid|nick> [ilość]");
		return Plugin_Handled;
	}
	
	char arg2[10];
	GetCmdArg(2, arg2, sizeof(arg2));
	
	int amount = StringToInt(arg2);
	int Credits = JailBreak_GetCredits(client);
	
	if(Credits < amount) {
		CPrintToChat(client, "\x0B[EverGames] \x06Nie masz wystarczających środków!");
		return Plugin_Handled;
	}
	
	if(amount <= 0) {
		CPrintToChat(client, "\x0B[EverGames] \x06Nie możesz przekazać 0 lub mniej kredytów.");
		return Plugin_Handled;
	}
	
	char target[32]; 
	GetCmdArg(1, target, sizeof(target));
	
	
	char TargetName[MAX_TARGET_LENGTH];
	int TargetList[MAXPLAYERS], TargetCount;
	bool TargetTranslate;

	if ((TargetCount = ProcessTargetString(target, 0, TargetList, MAXPLAYERS, 0, TargetName, sizeof(TargetName), TargetTranslate)) <= 0) { 
		CPrintToChat(client, "\x0B[EverGames]\x06 Parametr pierwszy jest niepoprawny lub nie istnieje!");
		return Plugin_Handled;
	}

	for (int  i = 0; i < TargetCount; i++) 
	{ 
		int iClient = TargetList[i]; 
		
		if (IsValidClient(iClient)) {
			if(iClient == client) {
				CPrintToChat(client, "\x0B[EverGames] \x06Nie możesz sobie przekazać kredytów.");
			} else {
				JailBreak_SetCredits(client, JailBreak_GetCredits(client) - amount);
				CPrintToChat(client, "\x0B[EverGames] \x06Odebrano z konta: \x07-%i\x06.", amount);
				CPrintToChat(client, "\x0B[EverGames] \x06Aktualna liczba kredytów: \x07%i\x06.", JailBreak_GetCredits(client));
				JailBreak_SetCredits(iClient, JailBreak_GetCredits(iClient) + amount);
				CPrintToChat(client, "\x0B[EverGames] \x06Przekazano \x03%i \x06kredytów dla \x07%N\x06.", amount, iClient);
				CPrintToChat(iClient, "\x0B[EverGames] \x06Gracz \x03%N\x06 przekazał Ci \x07%i\x06 kredytów.", client, amount);
			}
		}
	}
	
	return Plugin_Handled;
}
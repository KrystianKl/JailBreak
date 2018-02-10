#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Ratio Core"

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
	RegConsoleCmd("jointeam", Command_JailTeams);
}

public Action Command_JailTeams(int client, int args)
{
	if (IsValidClient(client))
		return Plugin_Continue;
	
	if(Owner(client) || Opiekun(client) || Admin(client) || VIP_Elite(client))
		return Plugin_Continue;
	
	char TeamDest[3];
	GetCmdArg(1, TeamDest, sizeof(TeamDest));
	
	int newTeam = StringToInt(TeamDest);
	int oldTeam = GetClientTeam(client);
	
	if (newTeam == 3 && oldTeam != 3) {
		int CountT = 0, CountCT = 0;
		
		LoopValidClients(i) {
			if (GetClientTeam(i) == CS_TEAM_T)
				CountT++;
			
			if (GetClientTeam(i) == CS_TEAM_CT)
				CountCT++;
		}
		
		if (CountCT < ((CountT) / 3) || !CountCT) {
			return Plugin_Continue;
		} else {
			ClientCommand(client, "play ui/freeze_cam.wav" );
			
			CPrintToChat(client, "\x0B[EverGames] \x07Jest za dużo graczy w drużynie Strażników\x02.");
			CPrintToChat(client, "\x0B[EverGames] \x06Aby wejść do drużyny CT wpisz: \x03!guard\x02.");
			
			return Plugin_Handled;
		}		
	}
	
	return Plugin_Continue;
}
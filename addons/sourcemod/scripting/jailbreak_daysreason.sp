#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Day Reason"

int g_iDays[MAXPLAYERS+1];
int g_iReasonCount = 0;

char g_cDayReason[256][192];

Handle Chat[MAXPLAYERS+1];

public Plugin myinfo =
{
    name = "[EverGames] JailBreak - Jail Days",
    author = "Mrkl21full™",
    description = "",
    version = "2.1",
    url = "EverGames.pl"
};

public void OnPluginStart()
{
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_spawn", Event_OnPlayerSpawn);

	g_iReasonCount = BuildPhrases();
}

public void OnClientPostAdminCheck(int client)
{
	g_iDays[client] = 0;
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	LoopValidClients(i)
		g_iDays[i] += 1;
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsValidClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == CS_TEAM_T)
		Chat[client] = CreateTimer(1.0, Czat, client);
}

public Action Czat(Handle timer, any client)
{
	if(Chat[client] != INVALID_HANDLE)
		KillTimer(Chat[client]);
	
	Chat[client] = INVALID_HANDLE;
	
	char Reason[256];
	Format(Reason, 256, "%s", g_cDayReason[GetRandomInt(0, (g_iReasonCount - 1))]);
	
	CPrintToChat(client, "\x02[EverGames] \x07Dzień \x06#%i\x09:{blue} %s", g_iDays[client], Reason); 
	PrintHintText(client, "Dzień %i: %s", g_iDays[client], Reason);
}

int BuildPhrases()
{
	char g_cFilePath[PLATFORM_MAX_PATH], g_cLine[192];
	int i = 0, g_iTotalLines = 0;
	
	BuildPath(Path_SM, g_cFilePath, sizeof(g_cFilePath), "configs/EverGames_JailDayReason.ini");
	
	Handle file = OpenFile(g_cFilePath, "rt");
	
	if(file != INVALID_HANDLE) {
		while (!IsEndOfFile(file)) {
			if (!ReadFileLine(file, g_cLine, sizeof(g_cLine)))
				break;
			
			TrimString(g_cLine);
			
			if(strlen(g_cLine) > 0)
			{
				FormatEx(g_cDayReason[i], 192, "%s", g_cLine);
				g_iTotalLines++;
			}
			
			i++;
			
			if(i >= sizeof(g_cDayReason)) {
				LogError("[EverGames] Attempted to add more than the maximum allowed phrases from file!");
				break;
			}
		}
		
		CloseHandle(file);
	} else {
		LogError("[EverGames] File not found (configs/EverGames_JailDayReason.ini)");
	}
	
	return g_iTotalLines;
}
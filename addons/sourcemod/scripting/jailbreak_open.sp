#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Jail Doors System"

Handle g_hTimerJail = INVALID_HANDLE;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = JB_PLUGIN_AUTHOR,
	description = JB_PLUGIN_DESCRIPTION,
	version = JB_PLUGIN_VERSION,
	url = JB_PLUGIN_URL
};

public OnPluginStart()
{
	RegConsoleCmd("sm_open", Command_OpenJail);
	RegConsoleCmd("sm_close", Command_CloseJail);
	
	HookEvent("round_start", Event_RoundStart);
}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{		
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "Simon", false))
		return Plugin_Handled;
	
	if (g_hTimerJail != INVALID_HANDLE)
		KillTimer(g_hTimerJail);
		
	g_hTimerJail = INVALID_HANDLE;
	g_hTimerJail = CreateTimer(60.0, Timer_JailOpener);
	
	return Plugin_Handled;
}

public Action Command_OpenJail(int client,int args) 
{
	if(client == 0)  {
		OpenJails();
		CPrintToChatAll("\x0B[EverGames]\x02 Serwer\x01: otworzył cele.");
	} else if(JailBreak_IsCaptain(client)) {
		OpenJails();
		CPrintToChatAll("\x0B[EverGames]\x06 Główny Strażnik otworzył cele.");
	} else if(Owner(client)) {
		OpenJails();
		CPrintToChatAll("\x0B[EverGames] \x06Właściciel\x0B %N\x01: otworzył cele.", client);
	} else if(Opiekun(client)) {
		OpenJails();
		CPrintToChatAll("\x0B[EverGames] \x0FOpiekun\x0B %N\x01: otworzył cele.", client);
	} else if(Admin(client)) {
		OpenJails();
		CPrintToChatAll("\x0B[EverGames] \x02Admin %N\x01: otworzył cele.", client);
	} else {
		OpenJails();
		CPrintToChat(client, "\x0B[EverGames]\x07 Musisz być Głównym Strażnikiem, aby to zrobić.");
	}
	
	return Plugin_Handled;
}

public Action Command_CloseJail(int client,int args)
{
	if(client == 0)  {
		JailBreak_CloseDoors();
		CPrintToChatAll("\x0B[EverGames]\x02 Serwer\x01: zamknął cele.");
	} else if(JailBreak_IsCaptain(client)) {
		JailBreak_CloseDoors();
		CPrintToChatAll("\x0B[EverGames]\x06 Główny Strażnik zamknął cele.");
	} else if(Owner(client)) {
		JailBreak_CloseDoors();
		CPrintToChatAll("\x0B[EverGames] \x06Właściciel\x0B %N\x01: zamknął cele.", client);
	} else if(Opiekun(client)) {
		JailBreak_CloseDoors();
		CPrintToChatAll("\x0B[EverGames] \x0FOpiekun\x0B %N\x01: zamknął cele.", client);
	} else if(Admin(client)) {
		JailBreak_CloseDoors();
		CPrintToChatAll("\x0B[EverGames] \x02Admin %N\x01: zamknął cele.", client);
	} else {
		JailBreak_CloseDoors();
		CPrintToChat(client, "\x0B[EverGames]\x07 Musisz być Głównym Strażnikiem, aby to zrobić.");
	}
	
	return Plugin_Handled;
}

public Action Timer_JailOpener(Handle timer)
{
	CPrintToChatAll("\x0B[EverGames] \x06Cele zostały automatycznie otwarte!");
	OpenJails();
}

void OpenJails()
{
	JailBreak_OpenDoors();
	
	if (g_hTimerJail != INVALID_HANDLE)
		KillTimer(g_hTimerJail);
	
	g_hTimerJail = INVALID_HANDLE;
}
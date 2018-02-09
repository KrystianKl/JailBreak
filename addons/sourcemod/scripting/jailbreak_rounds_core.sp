#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Round System Core"

int CurrentRound = 0, GameID = 0;
bool isGameSet = false;

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
	HookEvent("round_prestart", Event_RoundPreStart, EventHookMode_Pre);
	
	RegConsoleCmd("sm_setday", Command_SetDay);
}

public void OnMapStart()
{
	CurrentRound = 0;
	GameID = 0;
	isGameSet = false;
}

public Action Command_SetDay(int client, int args)
{
	if(Owner(client)) {
		Handle menu = CreateMenu(DIDMenuHandler);
		SetMenuTitle(menu, "EverGames.pl » Ustaw następny dzień:");
		AddMenuItem(menu, "1", "FreeDay");
		AddMenuItem(menu, "2", "Simon");
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	} else {
		CPrintToChat(client, "\x0B[EverGames]\x07 Nie masz uprawnień Właściciela!");
	}
	return Plugin_Handled;
}

public int DIDMenuHandler(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select) {
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		GameID = StringToInt(info);
		isGameSet = true;
		
		CPrintToChat(client, "\x0B[EverGames] \x06Następny dzień został ustawiony.");
		if(GameID == 1) CPrintToChat(client, "\x0B[EverGames] \x06Będzie nim: \x03FreeDay\x06.");
		else if(GameID == 2) CPrintToChat(client, "\x0B[EverGames] \x06Będzie nim: \x03Simon Day\x06.");
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public Action Event_RoundPreStart(Handle event, const char[] name, bool dontBroadcast)
{
	CurrentRound++;
	
	if(!isGameSet) {
		if(CurrentRound > 3) {
			CPrintToChatAll("\x0B[EverGames] \x06Trwa losowanie zabawy...");
			isGameSet = true;
			CurrentRound = 0;
			GameID = GetRandomInt(1, 2);
			CPrintToChatAll("\x0B[EverGames] \x06Następny dzień został wylosowany!");
			if(GameID == 1) CPrintToChatAll("\x0B[EverGames] \x06Będzie nim: \x03FreeDay\x06.");
			else if(GameID == 2) CPrintToChatAll("\x0B[EverGames] \x06Będzie nim: \x03Simon Day\x06.");
		}
		
		JailBreak_ChooseRound("Simon");
		SetGlobalCvars(10, 1, 0, 800, 0, false);
		return Plugin_Handled;
	}
	
	isGameSet = false;
	CurrentRound = 0;
	
	if(GameID == 1) {
		JailBreak_ChooseRound("FreeDay");
		SetGlobalCvars(2, 0, 0, 800, 1, false);
		
		LoopValidClients(i)
			if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) 
				JailBreak_SetFreeDay(i);
	} else {
		JailBreak_ChooseRound("Simon");
		SetGlobalCvars(10, 1, 0, 800, 0, false);
	}
	
	return Plugin_Handled;
}

void SetGlobalCvars(int RoundTime, int HostiesLR, int TeamMatesEnemies, int Gravity, int AntiCamp, bool Clear = false)
{
	SetCvar("mp_roundtime", RoundTime);
	SetCvar("mp_roundtime_hostage", RoundTime);
	SetCvar("mp_roundtime_defuse", RoundTime);
	SetCvar("mp_teammates_are_enemies", TeamMatesEnemies);
	SetCvar("sm_hosties_lr", HostiesLR);
	SetCvar("sm_afk_enable", AntiCamp);
	SetCvar("sm_anticamp_enable", AntiCamp);
	SetCvar("sv_gravity", Gravity);
	SetCvar("sv_airaccelerate", 580);
	SetCvar("sv_accelerate", 6);
	ServerCommand("sm_fogoff");
	if(Clear) ServerCommand("sm_broom");
}

public void SetCvar(char[] cvarName, int value)
{
	Handle cvar = FindConVar(cvarName);
	if(cvar == INVALID_HANDLE) return;
	
	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}
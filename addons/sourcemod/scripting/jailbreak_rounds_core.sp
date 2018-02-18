#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Round System Core"

int CurrentRound = 0, GameID = 0, Collision_Offsets = -1;
bool isGameSet = false;
bool g_bEnableCollision = true;

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
	Collision_Offsets = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("round_prestart", Event_RoundPreStart, EventHookMode_Pre);
	
	RegConsoleCmd("sm_setday", Command_SetDay);
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(g_bEnableCollision)
		SetEntData(client, Collision_Offsets, 2, 1, true);
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
		AddMenuItem(menu, "2", "Grenade Day");
		AddMenuItem(menu, "3", "Dodgeball Day");
		AddMenuItem(menu, "4", "NoScope Day");
		AddMenuItem(menu, "5", "Simon");
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
		else if(GameID == 2) CPrintToChat(client, "\x0B[EverGames] \x06Będzie nim: \x03Grenade Day\x06.");
		else if(GameID == 3) CPrintToChat(client, "\x0B[EverGames] \x06Będzie nim: \x03Dodgeball Day\x06.");
		else if(GameID == 4) CPrintToChat(client, "\x0B[EverGames] \x06Będzie nim: \x03NoScope Day\x06.");
		else if(GameID == 5) CPrintToChat(client, "\x0B[EverGames] \x06Będzie nim: \x03Simon Day\x06.");
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
			GameID = GetRandomInt(1, 4);
			CPrintToChatAll("\x0B[EverGames] \x06Następny dzień został wylosowany!");
			if(GameID == 1) CPrintToChatAll("\x0B[EverGames] \x06Będzie nim: \x03FreeDay\x06.");
			else if(GameID == 2) CPrintToChatAll("\x0B[EverGames] \x06Będzie nim: \x03Grenade Day\x06.");
			else if(GameID == 3) CPrintToChatAll("\x0B[EverGames] \x06Będzie nim: \x03Dodgeball Day\x06.");
			else if(GameID == 4) CPrintToChatAll("\x0B[EverGames] \x06Będzie nim: \x03NoScope Day\x06.");
			else if(GameID == 5) CPrintToChatAll("\x0B[EverGames] \x06Będzie nim: \x03Simon Day\x06.");
		}
		
		JailBreak_ChooseRound("Simon");
		SetGlobalCvars(10, 1, 0, 800, true, false);
		return Plugin_Handled;
	}
	
	isGameSet = false;
	CurrentRound = 0;
	
	if(GameID == 1) {
		JailBreak_ChooseRound("FreeDay");
		SetGlobalCvars(2, 0, 0, 800, true, false);
		
		LoopValidClients(i)
			if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) 
				JailBreak_SetFreeDay(i);
	} else if(GameID == 2) {
		JailBreak_ChooseRound("Grenade");
		SetGlobalCvars(4, 0, 0, 800, false, true);
	} else if(GameID == 3) {
		JailBreak_ChooseRound("Dodgeball");
		SetGlobalCvars(3, 0, 1, 800, false, true);
	} else if(GameID == 4) {
		JailBreak_ChooseRound("NoScope");
		SetGlobalCvars(3, 0, 0, 180, true, true);
	} else {
		JailBreak_ChooseRound("Simon");
		SetGlobalCvars(10, 1, 0, 800, true, false);
	}
	
	return Plugin_Handled;
}

void SetGlobalCvars(int RoundTime, int HostiesLR, int TeamMatesEnemies, int Gravity, bool GrenadeNoBlock = true, bool Clear = false)
{
	SetCvar("mp_roundtime", RoundTime);
	SetCvar("mp_roundtime_hostage", RoundTime);
	SetCvar("mp_roundtime_defuse", RoundTime);
	SetCvar("mp_teammates_are_enemies", TeamMatesEnemies);
	SetCvar("sm_hosties_lr", HostiesLR);
	SetCvar("sv_gravity", Gravity);
	SetCvar("sv_airaccelerate", 580);
	SetCvar("sv_accelerate", 6);
	g_bEnableCollision = GrenadeNoBlock;
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

public void OnEntityCreated(int entity, const char[] classname)
{
	if(g_bEnableCollision)
		if(StrContains(classname, "_projectile") != -1)
			SetEntData(entity, Collision_Offsets, 2, 4, true);
}
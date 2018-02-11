#pragma newdecls required
#pragma semicolon 1

#include <clientprefs>
#include <sdkhooks>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - System Core"

int CurrentCaptain = -1;
int g_iCredits[MAXPLAYERS+1] = { 0, ... };
int Collision_Offsets = -1;

bool g_bFreeDay[MAXPLAYERS+1] = { false, ... };
bool g_bCaptainMenu = false;

char g_cCurrentRound[128] = "None";

Handle c_GameCredits = null;
Handle OnCaptainSet = null;
Handle OnItemBought = null;
Handle Array_ShopItems = null;
Handle g_hMenu[MAXPLAYERS+1];

float g_fGravity[MAXPLAYERS + 1];
MoveType gMT_MoveType[MAXPLAYERS + 1];

enum ShopItem
{
	String:Name[64],
	Price,
	Team
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, err_max)
{
	OnCaptainSet = CreateGlobalForward("JailBreak_OnCaptainSet", ET_Ignore, Param_Cell);
	OnItemBought = CreateGlobalForward("JailBreak_OnItemBought", ET_Ignore, Param_Cell, Param_String);
	
	CreateNative("JailBreak_IsCaptain", Native_IsCaptain);
	CreateNative("JailBreak_GetCaptain", Native_GetCaptain);
	CreateNative("JailBreak_SetCaptain", Native_SetCaptain);
	CreateNative("JailBreak_AddItem", Native_AddItem);
	CreateNative("JailBreak_RemoveItem", Native_RemoveItem);
	CreateNative("JailBreak_ChooseRound", Native_ChooseRound);
	CreateNative("JailBreak_GetRound", Native_GetRound);
	CreateNative("JailBreak_isRoundActive", Native_isRoundActive);
	CreateNative("JailBreak_SetFreeDay", Native_SetFreeDay);
	CreateNative("JailBreak_GetFreeDay", Native_GetFreeDay);
	CreateNative("JailBreak_SetCredits", Native_SetCredits);
	CreateNative("JailBreak_GetCredits", Native_GetCredits);
    
	return APLRes_Success;
}

public Native_IsCaptain(Handle plugin, int argc)
{
	return (CurrentCaptain == GetNativeCell(1)) ? true : false;
}

public Native_GetCaptain(Handle plugin, int argc)
{
	return CurrentCaptain;
}

public Native_SetCaptain(Handle plugin, int argc)
{
	int client = GetNativeCell(1);
	
	removeCaptain(client, 0);
	setCaptain(client);
}

public Native_AddItem(Handle plugin, int argc)
{  
	Handle NewItem[ShopItem];
	
	GetNativeString(1, NewItem[Name], 64);
	NewItem[Price] = GetNativeCell(2);
	NewItem[Team] = GetNativeCell(3);
	
	PushArrayArray(Array_ShopItems, NewItem[0]);
	
	ReCreateMenu();
}

public Native_RemoveItem(Handle plugin, int argc)
{
	Handle NewItem[ShopItem];
	char CheckName[64];
	
	GetNativeString(1, CheckName, 64);
	
	for(int i = 0; i < GetArraySize(Array_ShopItems); i++)
	{
		GetArrayArray(Array_ShopItems, i, NewItem[0]);
		
		if(StrEqual(NewItem[Name], CheckName))
		{
			RemoveFromArray(Array_ShopItems, i);
			break;
		}
	}
	
	ReCreateMenu();
}

public Native_ChooseRound(Handle plugin, int argc)
{  
	char CurrentRound[64];
	GetNativeString(1, CurrentRound, 64);
	
	Format(g_cCurrentRound, sizeof(g_cCurrentRound), CurrentRound);
}

public Native_GetRound(Handle plugin, int argc)
{  
   SetNativeString(1, g_cCurrentRound, sizeof(g_cCurrentRound));
   
   return (StrEqual(g_cCurrentRound, "None", false)) ? false : true;
}

public Native_isRoundActive(Handle plugin, int argc)
{  
	return (StrEqual(g_cCurrentRound, "None", false) || StrEqual(g_cCurrentRound, "Simon", false)) ? false : true;
}

public Native_SetFreeDay(Handle plugin, argc)
{  
	int client = GetNativeCell(1);
	
	g_bFreeDay[client] = true;
	SetEntityRenderColor(client, 0, 255, 0, 255);
}

public Native_GetFreeDay(Handle plugin, int argc)
{  
	return g_bFreeDay[GetNativeCell(1)];
}

public Native_GetCredits(Handle plugin, int argc)
{  
	return g_iCredits[GetNativeCell(1)];
}

public Native_SetCredits(Handle plugin, int argc)
{  
	g_iCredits[GetNativeCell(1)] = GetNativeCell(2);
}

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
	
	c_GameCredits = RegClientCookie("JailBreak_Credits", "JailBreak_Credits", CookieAccess_Private);
	
	Array_ShopItems = CreateArray(66);
	
	RegConsoleCmd("sm_kredyty", Command_UserCredits);
	RegConsoleCmd("sm_credits", Command_UserCredits);
	RegConsoleCmd("sm_sklep", Command_OpenShop);
	RegConsoleCmd("sm_shop", Command_OpenShop);
	RegConsoleCmd("sm_captain", Command_Captain);
	RegConsoleCmd("sm_warden", Command_Captain);
	RegConsoleCmd("sm_nocaptain", Command_NoCaptain);
	RegConsoleCmd("sm_nowarden", Command_NoCaptain);
	RegConsoleCmd("sm_removecaptain", Command_RemoveCaptain);
	RegConsoleCmd("sm_remcaptain", Command_RemoveCaptain);
	
	RegConsoleCmd("sm_setcredits", Command_SetCredits);
	
	AddCommandListener(Command_Drop, "drop");
	
	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("round_end", Event_OnRoundEnd);
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	
	LoopValidClients(i)
		if(AreClientCookiesCached(i))
			OnClientCookiesCached(i);
}

public void OnGameFrame()
{
	LoopValidClients(i)
		if(IsPlayerAlive(i)) {
			MoveType MT_MoveType = GetEntityMoveType(i);
			float fGravity = GetEntityGravity(i);
			if(MT_MoveType == MOVETYPE_LADDER) {
				if(fGravity != 0.0)
					g_fGravity[i] = fGravity;
			} else {
				if(gMT_MoveType[i] == MOVETYPE_LADDER)
					SetEntityGravity(i, g_fGravity[i]);
				
				g_fGravity[i] = fGravity;
			}
			gMT_MoveType[i] = MT_MoveType;
		} else {
			g_fGravity[i] = 1.0;
			gMT_MoveType[i] = MOVETYPE_WALK;
		}
}

public void OnClientCookiesCached(client)
{
	char CreditsString[12];
	
	GetClientCookie(client, c_GameCredits, CreditsString, sizeof(CreditsString));
	g_iCredits[client] = StringToInt(CreditsString);
}

public void OnPluginEnd()
{
	CloseHandle(Array_ShopItems);
	
	LoopValidClients(i)
		OnClientDisconnect(i);
}

public void OnMapStart()
{
	Format(g_cCurrentRound, sizeof(g_cCurrentRound), "None");
	ServerCommand("exec sourcemod/EverGames/JailBreak.cfg");
}

public void OnClientPostAdminCheck(client)
{
	g_bFreeDay[client] = false;
}

public void OnClientDisconnect(int client)
{
	if(g_hMenu[client] != INVALID_HANDLE) CloseHandle(g_hMenu[client]);
	
	g_hMenu[client] = INVALID_HANDLE;
	
	if(CurrentCaptain == client)
	{
		SetEntityRenderColor(client, 255, 255, 255, 255);
		CPrintToChatAll("\x0B[EverGames]\x03 %N\x01 nie jest już Głównym Strażnikiem!", client);
		CurrentCaptain = -1;
	}
	
	if(AreClientCookiesCached(client))
	{
		char CreditsString[12];
		
		Format(CreditsString, sizeof(CreditsString), "%i", g_iCredits[client]);
		SetClientCookie(client, c_GameCredits, CreditsString);
	}
}

public int DIDMenuHandler(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select) 
	{
		char info[64];
		Handle NewItem[ShopItem];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		for(int i = 0; i < GetArraySize(Array_ShopItems); i++)
		{
			GetArrayArray(Array_ShopItems, i, NewItem[0]);
			
			if(StrEqual(NewItem[Name], info))
			{
				break;
			}
		}
		
		if (g_iCredits[client] >= NewItem[Price])
		{
			if (IsPlayerAlive(client))
			{
				if (NewItem[Team] == JB_BOTH || (GetClientTeam(client) == CS_TEAM_T && NewItem[Team] == JB_PRISIONERS) || (GetClientTeam(client) == CS_TEAM_CT && NewItem[Team] == JB_GUARDS))
				{
					if(!StrEqual(g_cCurrentRound, "None", false) && !StrEqual(g_cCurrentRound, "Simon", false))
					{
						CPrintToChat(client, "\x0B[EverGames]\x07 Nie można kupować podczas zabawy!");
						return;
					}
					
					g_iCredits[client] -= NewItem[Price];
					
					Call_StartForward(OnItemBought);
					Call_PushCell(client);
					Call_PushString(info);
					Call_Finish();
				} else {
					CPrintToChat(client, "\x0B[EverGames]\x07 To nie jest dostępne dla Twojej drużyny!");
				}
			} else {
				CPrintToChat(client, "\x0B[EverGames]\x07 Aby używać sklepu musisz żyć!");
			}
		} else {
			CPrintToChat(client, "\x0B[EverGames]\x07 Nie masz wymaganej liczby kredytów!");
			CPrintToChat(client, "\x0B[EverGames]\x01 Twoje kredyty: \x03%i\x01", g_iCredits[client]);
			CPrintToChat(client, "\x0B[EverGames]\x01 Wymagana liczba kredytów: \x03%i\x01!", NewItem[Price]);
		}
		
		DisplayMenuAtItem(menu, client, GetMenuSelectionPosition(), MENU_TIME_FOREVER);
	}
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if(StrEqual(g_cCurrentRound, "Simon", false)) {
		CreateTimer(2.0, Timer_MenuCaptain);
		
		new clients[MaxClients+1];
		int clientsCount;
		
		LoopValidClients(i)
			if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
				clients[clientsCount++] = i;
		
		if(clientsCount != 0) {
			setCaptain(clients[GetRandomInt(0, clientsCount-1)]);
		} else {
			CPrintToChatAll("\x0B[EverGames] \x06Aktualnie nie ma graczy w Strażnikach...");
			CPrintToChatAll("\x0B[EverGames] \x06Z tego względu cele zostały otwarte!");
			JailBreak_OpenDoors();
		}
	} else if(StrEqual(g_cCurrentRound, "None", false)) {
		CPrintToChatAll("\x0B[EverGames] \x06Aktualnie nie została wybrana żadna runda...");
		CPrintToChatAll("\x0B[EverGames] \x06Z tego względu cele zostały otwarte!");
		JailBreak_OpenDoors();
		CurrentCaptain = -1;
	}
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	Format(g_cCurrentRound, sizeof(g_cCurrentRound), "None");
	
	LoopValidClients(i)
		g_bFreeDay[i] = false;
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	RemoveAllWeapons(client, "");
	GivePlayerItem(client, "weapon_knife");
	
	SetEntData(client, Collision_Offsets, 2, 1, true);
	
	CreateTimer(0.0, Timer_RemoveRadar, client);
}

public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetClientTeam(client) == CS_TEAM_CT && CurrentCaptain == client)
	{
		new clients[MaxClients+1];
		int clientsCount;
		
		removeCaptain(client, 0);
		
		LoopValidClients(i)
			if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
				clients[clientsCount++] = i;
		
		if(clientsCount != 0) {
			CPrintToChatAll("\x0B[EverGames] \x07Trwa losowanie na nowego...");
			setCaptain(clients[GetRandomInt(0, clientsCount-1)]);
		}
	}
}

public void ReCreateMenu()
{
	LoopValidClients(i) {
		if(g_hMenu[i] != INVALID_HANDLE) CloseHandle(g_hMenu[i]);
		
		g_hMenu[i] = INVALID_HANDLE;
		CreateMenuClient(i);
	}
}

public void CreateMenuClient(int client) 
{
	if(g_hMenu[client] == INVALID_HANDLE)
	{
		g_hMenu[client] = CreateMenu(DIDMenuHandler);
		SetMenuTitle(g_hMenu[client], "EverGames.pl » Sklep JailBreak");
		char MenuItem[128], ItemName[32];
		Handle Array_ShopItems_Clon = CloneArray(Array_ShopItems);
		
		while(GetArraySize(Array_ShopItems_Clon) > 0)
		{
			int ArrayIndex;
			new Item[GetArraySize(Array_ShopItems_Clon)][ShopItem];
			
			for(int i = 0; i < GetArraySize(Array_ShopItems_Clon); i++)
			{
				GetArrayArray(Array_ShopItems_Clon, i, Item[i][0]);
				
				if(Item[i][Price] <= Item[ArrayIndex][Price])
				{
					ArrayIndex = i;
				}
			}
			
			Format(ItemName, sizeof(ItemName),"%s", Item[ArrayIndex][Name], client);
			
			switch(Item[ArrayIndex][Team])
			{
				case JB_GUARDS: continue;
				case JB_PRISIONERS: continue;
				case JB_BOTH: continue;
			}
			
			Format(MenuItem, sizeof(MenuItem),"%s - %i kredytów", ItemName, Item[ArrayIndex][Price]);
			AddMenuItem(g_hMenu[client], Item[ArrayIndex][Name], MenuItem);
			
			RemoveFromArray(Array_ShopItems_Clon, ArrayIndex);
		}
		
		if(GetArraySize(Array_ShopItems_Clon) == 0) {
			CPrintToChat(client, "\x0B[EverGames]\x06 Nie ma ani jednego przedmiotu w sklepie!");
		}
		
		CloseHandle(Array_ShopItems_Clon);
		SetMenuExitButton(g_hMenu[client], true);
	}
}

public void removeCaptain(int client, int natives)
{
	if(IsValidClient(CurrentCaptain)) {
		CPrintToChatAll("\x0B[EverGames]\x03 %N\x01 nie jest już Głównym Strażnikiem!", client);
		SetEntityRenderColor(CurrentCaptain, 255, 255, 255, 255);
		CurrentCaptain = -1;
		
		if(natives == 1) {
			CPrintToChatAll("\x0B[EverGames]\x06 Trwa losowanie nowego, chyba że ktoś przejmie obowiązki...");
			CreateTimer(5.0, Timer_SetNewCaptain);
		}
	}
}

public void setCaptain(int client)
{
	CPrintToChatAll("\x0B[EverGames]\x07 Nowym Głównym Strażnikiem został:", client);
	CPrintToChatAll("\x0B[EverGames]\x07 » \x03%N", client);
	SetEntityRenderColor(client, 0, 130, 210, 255);
	
	if(g_bCaptainMenu) {
		FakeClientCommand(client, "sm_simonmenu");
	}
	
	CurrentCaptain = client;
	
	Call_StartForward(OnCaptainSet);
	Call_PushCell(CurrentCaptain);
	Call_Finish();
}

public Action Timer_MenuCaptain(Handle timer)
{
	g_bCaptainMenu = true;
}

public Action Timer_SetNewCaptain(Handle timer)
{
	if(!IsValidClient(CurrentCaptain)) {
	
		new clients[MaxClients+1];
		int clientsCount;
		
		LoopValidClients(i)
			if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
				clients[clientsCount++] = i;
		
		if(clientsCount != 0) {
			CPrintToChatAll("\x0B[EverGames] \x07Trwa losowanie na nowego...");
			setCaptain(clients[GetRandomInt(0, clientsCount-1)]);
		}
	}
}

public Action Timer_RemoveRadar(Handle Timer, any client)
{
	SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | 1<<12);
}

public Action Command_UserCredits(int client, int args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;
	
	CPrintToChat(client, "\x0B[EverGames] \x01Liczba Twoich kredytów: \x03%i\x01.", g_iCredits[client]);
	return Plugin_Handled;
}

public Action Command_OpenShop(int client, int args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;
	
	CreateMenuClient(client);
	DisplayMenu(g_hMenu[client], client, MENU_TIME_FOREVER);
	
	CPrintToChat(client, "\x0B[EverGames] \x01Liczba Twoich kredytów: \x03%i\x01.", g_iCredits[client]);
	return Plugin_Handled;
}

public Action Command_SetCredits(int client, int args)
{
	if(!IsValidClient(client))
		return Plugin_Handled;
	
	if(Owner(client)) {
		if(args < 2) {
			CPrintToChat(client, "\x0B[EverGames]\x01 Użycie: \x03sm_setcredits <#userid|nick> [ilość]\x01.");
		} else {
			char arg2[16];
			GetCmdArg(2, arg2, sizeof(arg2));
			
			int amount = StringToInt(arg2);
			
			char Target[32], TargetName[MAX_TARGET_LENGTH];
			int TargetList[MAXPLAYERS], TargetCount;
			bool TargetTranslate;
			GetCmdArg(1, Target, sizeof(Target));
			
			if ((TargetCount = ProcessTargetString(Target, client, TargetList, MAXPLAYERS, COMMAND_FILTER_NO_BOTS, TargetName, sizeof(TargetName), TargetTranslate)) <= 0)
			{
				CPrintToChat(client, "\x0B[EverGames]\x06 Wystąpił błąd przy ustawianiu kredytów!");
				CPrintToChat(client, "\x0B[EverGames]\x06 Sprawdź swój pierwszy argument!");
				return Plugin_Handled; 
			}
			
			for(int i = 0; i < TargetCount; i++) 
			{
				int iClient = TargetList[i];
				
				if(IsValidClient(iClient)) {
					g_iCredits[iClient] = amount;
					CPrintToChat(client, "\x0B[EverGames]\x01 Ustawiłeś \x03%i\x01 kredytów graczowi: \x07%N\x01!", amount, iClient);
				}
			}
		}
	} else {
		CPrintToChat(client, "\x0B[EverGames] \x06Nie masz uprawnień Właściciela!");
	}
	return Plugin_Handled;
}

public Action Command_Captain(int client, int args)
{
	if(!StrEqual(g_cCurrentRound, "None", false) && !StrEqual(g_cCurrentRound, "Simon", false)) {
		CPrintToChat(client, "\x0B[EverGames]\x07 Aktualnie trwa zabawa...");
	} else {
		if(!IsValidClient(CurrentCaptain)) {
			if(IsValidClient(client) && GetClientTeam(client) == 3 && IsPlayerAlive(client)) {
				setCaptain(client);
				return Plugin_Handled;
			} else {
				CPrintToChat(client, "\x0B[EverGames]\07 Musisz żyć lub być w Strażnikach, aby zostać Głównym Strażnikiem!");
			}
		} else {
			CPrintToChat(client, "\x0B[EverGames]\x07 Główny Strażnik już istnieje!");
		}
	}
	return Plugin_Handled;
}

public Action Command_NoCaptain(int client, int args)
{
	if(CurrentCaptain == client) {
		removeCaptain(client, 1);
	} else {
		CPrintToChat(client, "\x0B[EverGames] \x07Nie jesteś Głównym Strażnikiem!");
    }
	return Plugin_Handled;
}

public Action Command_RemoveCaptain(int client, int args)
{
	if(Owner(client) || Opiekun(client) || Admin(client)) {
		if(IsValidClient(CurrentCaptain)) {
			SetEntityRenderColor(CurrentCaptain, 255, 255, 255, 255);
			CPrintToChatAll("\x0B[EverGames] \x07Prowadzący został usunięty przez Administratora!");
			CurrentCaptain = -1;
			CreateTimer(2.0, Timer_SetNewCaptain);
			return Plugin_Handled;
		} else {
			CPrintToChat(client, "\x0B[EverGames] \x07Nie ma żadnego Głównego Strażnika!");
		}
	} else {
		CPrintToChat(client, "\x02[EverGames] \x07Nie masz uprawnień do tej komendy!");
	}
	
	return Plugin_Handled;
}

public Action Command_Drop(int client, const char[] command, int args)
{	
	if (IsValidClient(client))
	{
		char sName[32];
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		
		if(!IsValidEdict(weapon))
		{
			return Plugin_Stop;
		}

		GetEdictClassname(weapon, sName, sizeof(sName));

		if (StrEqual("weapon_hegrenade", sName, false) || StrEqual("weapon_flashbang", sName, false) || StrEqual("weapon_smokegrenade", sName, false) || StrEqual("weapon_incgrenade", sName, false) || StrEqual("weapon_molotov", sName, false) || StrEqual("weapon_decoy", sName, false) || StrEqual("weapon_tagrenade", sName, false)) {
			int iSequence = GetEntProp(weapon, Prop_Data, "m_nSequence");
			if((GetEngineVersion() == Engine_CSS && iSequence != 5) || (GetEngineVersion() == Engine_CSGO && iSequence != 2))
			{
				SDKHooks_DropWeapon(client, weapon);
				return Plugin_Handled;
			}
		} else if ((StrContains(sName, "knife", false) != -1) || (StrContains(sName, "bayonet", false) != -1)) {
			SDKHooks_DropWeapon(client, weapon);
			if(Owner(client)) { 
				char CommunityID[64];
				GetClientAuthId(client, AuthId_SteamID64, CommunityID, sizeof(CommunityID));
				
				if(StrEqual(CommunityID, "76561198191496115")) {
					GivePlayerItem(client, "weapon_knife"); 
				}
			}
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "_projectile") != -1)
	{
		SetEntData(entity, Collision_Offsets, 2, 1, true);
	}
}
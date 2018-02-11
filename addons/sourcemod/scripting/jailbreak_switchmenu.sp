#pragma newdecls required
#pragma semicolon 1

#include <adminmenu>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Team Switch"

int g_iChangeTeam[MAXPLAYERS+1] = { 0, ...};
// 0 = OnRoundEnd, 1 = OnPlayerDeath
int g_iChangeMode = 1;

Handle g_hTopMenu = INVALID_HANDLE;

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
	LoadTranslations("common.phrases");
	
	HookEvent("player_death", EventPlayerDeath);
	HookEvent("round_end", EventRoundEnd);
	
	RegAdminCmd("sm_swmenu", Command_SP, ADMFLAG_GENERIC, "Switches Player Menu");
	RegAdminCmd("sm_swadmenu", Command_SPAD, ADMFLAG_GENERIC, "Switches Player After Death Menu");
	RegAdminCmd("sm_swspec", Command_STO, ADMFLAG_GENERIC, "Switche Player to Spectator");
	
	Handle g_hTopMenuAdmin;
	
	if (LibraryExists("adminmenu") && ((g_hTopMenuAdmin = GetAdminTopMenu()) != INVALID_HANDLE))
	{
		OnAdminMenuReady(g_hTopMenuAdmin);
	}

}

public void OnClientPostAdminCheck(int client)
{
	g_iChangeTeam[client] = 0;
}

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == g_hTopMenu)
		return;

	g_hTopMenu = topmenu;

	TopMenuObject Category = FindTopMenuCategory(g_hTopMenu, ADMINMENU_PLAYERCOMMANDS);
	
	AddToTopMenu(g_hTopMenu, "sm_swmenuad", TopMenuObject_Item, AdminMenu_SPAD, Category, "sm_swmenuad", ADMFLAG_GENERIC);
	AddToTopMenu(g_hTopMenu, "sm_swmenu", TopMenuObject_Item, AdminMenu_SP, Category, "sm_swmenu", ADMFLAG_GENERIC);
	AddToTopMenu(g_hTopMenu, "sm_swspec", TopMenuObject_Item, AdminMenu_STO, Category, "sm_swspec", ADMFLAG_GENERIC);
	AddToTopMenu(g_hTopMenu, "sm_scrambleteams", TopMenuObject_Item, AdminMenu_ST, Category, "sm_scrambleteams", ADMFLAG_GENERIC);
}

public int AdminMenu_ST(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "Wymieszaj drużyny");
	} else if (action == TopMenuAction_SelectOption) {
		ServerCommand("mp_scrambleteams 1");
	}
}

public int AdminMenu_STO(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "Przerzuć gracza do widzów");
	} else if (action == TopMenuAction_SelectOption) {
		Command_STO(param, param);
	}
}

public int AdminMenu_SP(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "Zmień drużyne gracza natychmiastowo");
	} else if (action == TopMenuAction_SelectOption) {
		Command_SP(param,param);
	} 
}
public int AdminMenu_SPAD(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption) {
		Format(buffer, maxlength, "Zmień drużyne gracza po śmierci");
	} else if (action == TopMenuAction_SelectOption) {
		Command_SPAD(param, param);
	}
}

public Action Command_SP(int client, int args)
{
	Handle menu = CreateMenu(MenuHandlerSP);
	SetMenuTitle(menu, "EverGames.pl » Natychmiastowo przerzuć gracza:");
	
	LoopValidClients(i) 
	{
		char Nick[64];
		GetClientName(i, Nick, sizeof(Nick));
		AddMenuItem(menu, Nick, Nick);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20);
 
	return Plugin_Handled;
}

public Action Command_SPAD(int client, int args)
{
	Handle menu = CreateMenu(MenuHandlerSPAD);
	SetMenuTitle(menu, "EverGames.pl » Przerzuć gracza po śmierci:");
	
	LoopValidClients(i) 
	{
		char Nick[64];
		GetClientName(i, Nick, sizeof(Nick));
		AddMenuItem(menu, Nick, Nick);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20);
 
	return Plugin_Handled;
}

public Action Command_STO(int client, int args)
{
	Handle menu = CreateMenu(MenuHandlerSTO);
	SetMenuTitle(menu, "EverGames.pl » Przerzuć Gracza do Widzów:");
	
	LoopValidClients(i) 
	{
		char Nick[64];
		GetClientName(i, Nick, sizeof(Nick));
		AddMenuItem(menu, Nick, Nick);
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 20);
 
	return Plugin_Handled;
}

public int MenuHandlerSP(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select) {
		char info[64];
		int target = -1;
		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		LoopValidClients(i) {
			char ClientName[64];
			GetClientName(i, ClientName, sizeof(ClientName));
			
			if (StrEqual(info, ClientName))
				target = i;
		}
		
		ChangeClientTeam(target, GetOtherTeam(GetClientTeam(target)));
		
		CPrintToChatAll("\x0B[EverGames] \x03%N \x06został przerzucony przez \x07%N\x06.", target, client);
		
		Command_SP(client, client);
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public int MenuHandlerSPAD(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select) {
		char info[64];
		int target = -1;
		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		LoopValidClients(i) {
			char ClientName[64];
			GetClientName(i, ClientName, sizeof(ClientName));
			
			if (StrEqual(info, ClientName))
				target = i;
		}
		
		g_iChangeTeam[target] = 1;
		
		CPrintToChatAll("\x0B[EverGames] \x03%N \x06zmieni drużynę po śmierci\x06.", target);
		
		Command_SPAD(client, client);
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public MenuHandlerSTO(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select) {
		char info[64];
		int target = -1;
		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		LoopValidClients(i) {
			char ClientName[64];
			GetClientName(i, ClientName, sizeof(ClientName));
			
			if (StrEqual(info, ClientName))
				target = i;
		}
		
		ChangeClientTeam(target, 3);
		
		CPrintToChatAll("\x0B[EverGames] \x03%N \x06został przerzucony do Widzów przez \x07%N\x06.", target, client);
		
		Command_STO(client, client);
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public Action EventPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if(g_iChangeMode == 1) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		
		if(!IsValidClient(client))
			return Plugin_Handled;
		
		if (g_iChangeTeam[client] == 1)  {
			ChangeClientTeam(client, GetOtherTeam(GetClientTeam(client)));
			g_iChangeTeam[client] = 0;
		}
	}
	
	return Plugin_Handled;
}

public Action EventRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	if(g_iChangeMode == 0) {
		LoopValidClients(i) {
			if(g_iChangeTeam[i] == 1)
				ChangeClientTeam(i, GetOtherTeam(GetClientTeam(i)));
			
			g_iChangeTeam[i] = 0;
		}
	}
	
	return Plugin_Handled;
}

int GetOtherTeam(int Team)
{
	return (Team == 2) ? 3 : 2;
}
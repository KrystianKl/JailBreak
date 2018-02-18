#pragma newdecls required
#pragma semicolon 1

#include <clientprefs>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Jail Doors System"

int Guards = 0;
int GuardsAlive = 0;
int Prisoners = 0;
int PrisonersAlive = 0;

int g_iCaptain = -1;

int g_iHudColor_Red[MAXPLAYERS + 1] =  { 0, ... };
int g_iHudColor_Green[MAXPLAYERS + 1] =  { 210, ... };
int g_iHudColor_Blue[MAXPLAYERS + 1] =  { 255, ... };

bool g_bHudDisplay[MAXPLAYERS + 1] =  { true, ... };

char g_cCurrentDay[64] = "Nie wybrany";

Handle HudHandler;
Handle HudHandler1;
Handle HudHandler2;
Handle HudHandler3;
Handle HudHandler4;

Handle g_hHudColor_Red;
Handle g_hHudColor_Green;
Handle g_hHudColor_Blue;

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
	g_hHudColor_Red = RegClientCookie("g_hHudColor_Red", "g_hHudColor_Red", CookieAccess_Protected);
	g_hHudColor_Green = RegClientCookie("g_hHudColor_Green", "g_hHudColor_Green", CookieAccess_Protected);
	g_hHudColor_Blue = RegClientCookie("g_hHudColor_Blue", "g_hHudColor_Blue", CookieAccess_Protected);
	
	RegConsoleCmd("sm_hud", Command_ChangeHud);
	RegConsoleCmd("sm_hudcolor", Command_ChangeHudColor);
	
	HookEvent("round_start", OnRoundStart);
	HookEvent("round_end", OnRoundEnd);
	HookEvent("player_death", OnPlayerDeath);
	
	HudHandler = CreateHudSynchronizer();
	HudHandler1 = CreateHudSynchronizer();
	HudHandler2 = CreateHudSynchronizer();
	HudHandler3 = CreateHudSynchronizer();
	HudHandler4 = CreateHudSynchronizer();
	
	for (int i = MaxClients; i > 0; --i) 
	{
        if (!AreClientCookiesCached(i))
            continue;
        
        OnClientCookiesCached(i);
    }
}

public void OnClientCookiesCached(int client)
{
	char sCookieValue[11];
	GetClientCookie(client, g_hHudColor_Red, sCookieValue, sizeof(sCookieValue));
	g_iHudColor_Red[client] = (StringToInt(sCookieValue) == 0) ? 0 : StringToInt(sCookieValue);
	GetClientCookie(client, g_hHudColor_Green, sCookieValue, sizeof(sCookieValue));
	g_iHudColor_Green[client] = (StringToInt(sCookieValue) == 0) ? 210 : StringToInt(sCookieValue);
	GetClientCookie(client, g_hHudColor_Blue, sCookieValue, sizeof(sCookieValue));
	g_iHudColor_Blue[client] = (StringToInt(sCookieValue) == 0) ? 255 : StringToInt(sCookieValue);
}

public Action Command_ChangeHudColor(int client, int args)
{
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}
	
	Handle menu = CreateMenu(ColorHandler);
	
	SetMenuTitle(menu, "EverGames.pl » Wygląd koloru HUD'a:");
	
	char MenuOption[20];
	Format(MenuOption, sizeof(MenuOption), "Czerwony: %i (+)", g_iHudColor_Red[client]);
	AddMenuItem(menu, "czerplus", MenuOption);
	Format(MenuOption, sizeof(MenuOption), "Czerwony: %i (-)", g_iHudColor_Red[client]);
	AddMenuItem(menu, "czerminu", MenuOption);
	Format(MenuOption, sizeof(MenuOption), "Zielony: %i (+)", g_iHudColor_Green[client]);
	AddMenuItem(menu, "zielplus", MenuOption);
	Format(MenuOption, sizeof(MenuOption), "Zielony: %i (-)", g_iHudColor_Green[client]);
	AddMenuItem(menu, "zielminu", MenuOption);
	Format(MenuOption, sizeof(MenuOption), "Niebieski: %i (+)", g_iHudColor_Blue[client]);
	AddMenuItem(menu, "niebplus", MenuOption);
	Format(MenuOption, sizeof(MenuOption), "Niebieski: %i (-)", g_iHudColor_Blue[client]);
	AddMenuItem(menu, "niebminu", MenuOption);
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public Action Command_ChangeHud(int client, int args)
{
	if (!IsValidClient(client)) {
		return Plugin_Handled;
	}
	
	Handle menu = CreateMenu(MenuHandler);
	
	SetMenuTitle(menu, "EverGames.pl » Wygląd HUD'a:");
	
	if(g_bHudDisplay[client]) {
		AddMenuItem(menu, "domyslny", "Domyślny (X)");
		AddMenuItem(menu, "kolorowy", "Kolorowy");
	} else {
		AddMenuItem(menu, "domyslny", "Domyślny");
		AddMenuItem(menu, "kolorowy", "Kolorowy (X)");
	}
	AddMenuItem(menu, "nmenu", "Zmiana kolorów");
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public int ColorHandler(Handle menu, MenuAction action, client, itemNum)
{
	if (action == MenuAction_Select) {
		char info[32];
		char color[8];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info, "czerplus") == 0) {
			if(g_iHudColor_Red[client] < 255 && g_iHudColor_Red[client] > 0) {
				g_iHudColor_Red[client] += 5;
				IntToString(g_iHudColor_Red[client], color, sizeof(color));
				SetClientCookie(client, g_hHudColor_Red, color);
				RefreshClient(client);
			} else {
				g_iHudColor_Red[client] = (g_iHudColor_Red[client] > 251) ? 250 : 5;
				PrintToChat(client, " \x0B[EverGames]\x06 Nie możesz dać więcej niż 255 i mniej niz 0!");
			}
		} else if (strcmp(info, "czerminu") == 0 )  {
			if(g_iHudColor_Red[client] < 255 && g_iHudColor_Red[client] > 0) {
				g_iHudColor_Red[client] -= 5;
				IntToString(g_iHudColor_Red[client], color, sizeof(color));
				SetClientCookie(client, g_hHudColor_Red, color);
				RefreshClient(client);
			} else {
				g_iHudColor_Red[client] = (g_iHudColor_Red[client] > 251) ? 250 : 5;
				PrintToChat(client, " \x0B[EverGames]\x06 Nie możesz dać więcej niż 255 i mniej niz 0!");
			}
		} else if (strcmp(info, "zielplus") == 0 )  {
			if(g_iHudColor_Green[client] < 255 && g_iHudColor_Green[client] > 0) {
				g_iHudColor_Green[client] += 5;
				IntToString(g_iHudColor_Green[client], color, sizeof(color));
				SetClientCookie(client, g_hHudColor_Green, color);
				RefreshClient(client);
			} else {
				g_iHudColor_Green[client] = (g_iHudColor_Green[client] > 251) ? 250 : 5;
				PrintToChat(client, " \x0B[EverGames]\x06 Nie możesz dać więcej niż 255 i mniej niz 0!");
			}
		} else if (strcmp(info, "zielminu") == 0 )  {
			if(g_iHudColor_Green[client] < 255 && g_iHudColor_Green[client] > 0) {
				g_iHudColor_Green[client] -= 5;
				IntToString(g_iHudColor_Green[client], color, sizeof(color));
				SetClientCookie(client, g_hHudColor_Green, color);
				RefreshClient(client);
			} else {
				g_iHudColor_Green[client] = (g_iHudColor_Green[client] > 251) ? 250 : 5;
				PrintToChat(client, " \x0B[EverGames]\x06 Nie możesz dać więcej niż 255 i mniej niz 0!");
			}
		} else if (strcmp(info, "niebplus") == 0 )  {
			if(g_iHudColor_Blue[client] < 255 && g_iHudColor_Blue[client] > 0) {
				g_iHudColor_Blue[client] += 5;
				IntToString(g_iHudColor_Blue[client], color, sizeof(color));
				SetClientCookie(client, g_hHudColor_Blue, color);
				RefreshClient(client);
			} else {
				g_iHudColor_Blue[client] = (g_iHudColor_Blue[client] > 251) ? 250 : 5;
				PrintToChat(client, " \x0B[EverGames]\x06 Nie możesz dać więcej niż 255 i mniej niz 0!");
			}
		} else if (strcmp(info, "niebminu") == 0 )  {
			if(g_iHudColor_Blue[client] < 255 && g_iHudColor_Blue[client] > 0) {
				g_iHudColor_Blue[client] -= 5;
				IntToString(g_iHudColor_Blue[client], color, sizeof(color));
				SetClientCookie(client, g_hHudColor_Blue, color);
				RefreshClient(client);
			} else {
				g_iHudColor_Blue[client] = (g_iHudColor_Blue[client] > 251) ? 250 : 5;
				PrintToChat(client, " \x0B[EverGames]\x06 Nie możesz dać więcej niż 255 i mniej niz 0!");
			}
		}
		FakeClientCommand(client, "sm_hudcolor");
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public int MenuHandler(Handle menu, MenuAction action, client, itemNum) 
{
	if (action == MenuAction_Select) {
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info, "domyslny") == 0) {
			if(g_bHudDisplay[client]) {
				PrintToChat(client, " \x0B[EverGames]\x06 Aktualnie masz ustawiony \x07domyślny\x06 wygląd!");
			} else {
				g_bHudDisplay[client] = true;
				PrintToChat(client, " \x0B[EverGames]\x06 Ustawiłeś nowy \x07domyślny\x06 wygląd!");
				RefreshClient(client);
			}
			FakeClientCommand(client, "sm_hud");
		} else if (strcmp(info, "kolorowy") == 0 ) {
			if(!g_bHudDisplay[client]) {
				PrintToChat(client, " \x0B[EverGames]\x06 Aktualnie masz ustawiony \x07kolorowy\x06 wygląd!");
			} else {
				g_bHudDisplay[client] = false;
				PrintToChat(client, " \x0B[EverGames]\x06 Ustawiłeś nowy \x07kolorowy\x06 wygląd!");
				RefreshClient(client);
			}
			FakeClientCommand(client, "sm_hud");
		} else if (strcmp(info, "nmenu") == 0 ) {
			PrintToChat(client, " \x0B[EverGames]\x06 Aktualnie jesteś w menu kolorów HUD'a!");
			FakeClientCommand(client, "sm_hudcolor");
		}
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	Guards = 0;
	GuardsAlive = 0;
	Prisoners = 0;
	PrisonersAlive = 0;
	
	g_cCurrentDay = "Nie wybrany";
	
	JailBreak_GetRound(g_cCurrentDay);
	
	if(StrContains(g_cCurrentDay, "Simon", false) != -1) {
		g_cCurrentDay = "Normalny";
	} else if(StrContains(g_cCurrentDay, "Freeday", false) != -1) {
		g_cCurrentDay = "Freeday";
	} else if(StrContains(g_cCurrentDay, "Grenade", false) != -1) {
		g_cCurrentDay = "Grenade Day";
	} else if(StrContains(g_cCurrentDay, "NoScope", false) != -1) {
		g_cCurrentDay = "NoScope Day";
	} else if(StrContains(g_cCurrentDay, "Dodgeball", false) != -1) {
		g_cCurrentDay = "Dodgeball Day";
	} else {
		g_cCurrentDay = "Nieznany";
	}
	
	LoopValidClients(i)
		ClearHud(i);
	
	CreateTimer(1.5, FixHud);
}

public Action OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	g_iCaptain = -1;
}

public Action FixHud(Handle Timer)
{	
	OnDeath();
}

public Action OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	OnDeath();
}

void OnDeath()
{
	Guards = 0;
	GuardsAlive = 0;
	Prisoners = 0;
	PrisonersAlive = 0;
	
	LoopValidClients(i) {
		if(GetClientTeam(i) == CS_TEAM_CT) {
			if(IsPlayerAlive(i))
				GuardsAlive++;
			Guards++;
		} else if(GetClientTeam(i) == CS_TEAM_T) {
			if(IsPlayerAlive(i))
				PrisonersAlive++;
			Prisoners++;
		}
	}
	
	Refresh();
}

public void JailBreak_OnCaptainSet(int client)
{
	g_iCaptain = client;
	
	Refresh();
}

void Refresh()
{	
	LoopValidClients(i)
	{
		if(g_bHudDisplay[i]) {
			SetHudTextParams(0.02, 0.02, 300.0, 0, 130, 240, 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler, "EverGames.pl » JailBreak");
			if(StrEqual(g_cCurrentDay, "Normalny", false)) {
				if(g_iCaptain > 0) {
					SetHudTextParams(0.02, 0.05, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
					ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i | Więźniów: %i/%i\n\n\nProwadzący: %N", GuardsAlive, Guards, PrisonersAlive, Prisoners, g_iCaptain);
				} else {
					SetHudTextParams(0.02, 0.05, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
					ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i | Więźniów: %i/%i\n\n\nProwadzący: Brak", GuardsAlive, Guards, PrisonersAlive, Prisoners);
				}
			} else {
				SetHudTextParams(0.02, 0.05, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i | Więźniów: %i/%i", GuardsAlive, Guards, PrisonersAlive, Prisoners);
			}
			SetHudTextParams(0.02, 0.08, 300.0, 0, 225, 40, 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler1, "Dzień: %s", g_cCurrentDay);
		} else {
			SetHudTextParams(0.02, 0.02, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler, "EverGames.pl » JailBreak");
			if(StrEqual(g_cCurrentDay, "Normalny", false)) {
				if(g_iCaptain > 0) {
					SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
					ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i\n\n\nProwadzący: %N", GuardsAlive, Guards, g_iCaptain);
				} else {
					SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
					ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i\n\n\nProwadzący: Brak", GuardsAlive, Guards);
				}
			} else {
				SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i", GuardsAlive, Guards);
			}
			SetHudTextParams(0.140, 0.05, 300.0, 255, 255, 255, 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler3, "|");
			SetHudTextParams(0.155, 0.05, 300.0, 220, 0, 0, 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler4, "Więźniów: %i/%i", PrisonersAlive, Prisoners);
			SetHudTextParams(0.02, 0.08, 300.0, 0, 225, 40, 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler1, "Dzień: %s", g_cCurrentDay);
		}
	}
}

void RefreshClient(int i)
{
	ClearHud(i);
	
	if(g_bHudDisplay[i]) {
		SetHudTextParams(0.02, 0.02, 300.0, 0, 130, 240, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler, "EverGames.pl » JailBreak");
		if(StrEqual(g_cCurrentDay, "Normalny", false)) {
			if(g_iCaptain > 0) {
				SetHudTextParams(0.02, 0.05, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i | Więźniów: %i/%i\n\n\nProwadzący: %N", PrisonersAlive, Prisoners, GuardsAlive, Guards, g_iCaptain);
			} else {
				SetHudTextParams(0.02, 0.05, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i | Więźniów: %i/%i\n\n\nProwadzący: Brak", PrisonersAlive, Prisoners, GuardsAlive, Guards);
			}
		} else {
			SetHudTextParams(0.02, 0.05, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i | Więźniów: %i/%i", PrisonersAlive, Prisoners, GuardsAlive, Guards);
		}
		SetHudTextParams(0.02, 0.08, 300.0, 0, 225, 40, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler1, "Dzień: %s", g_cCurrentDay);
	} else {
		SetHudTextParams(0.02, 0.02, 300.0, g_iHudColor_Red[i], g_iHudColor_Green[i], g_iHudColor_Blue[i], 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler, "EverGames.pl » JailBreak");
		if(StrEqual(g_cCurrentDay, "Normalny", false)) {
			if(g_iCaptain > 0) {
				SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i\n\n\nProwadzący: %N", GuardsAlive, Guards, g_iCaptain);
			} else {
				SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i\n\n\nProwadzący: Brak", GuardsAlive, Guards);
			}
		} else {
			SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i", GuardsAlive, Guards);
		}
		SetHudTextParams(0.140, 0.05, 300.0, 255, 255, 255, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler3, "|");
		SetHudTextParams(0.155, 0.05, 300.0, 220, 0, 0, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler4, "Więźniów: %i/%i", PrisonersAlive, Prisoners);
		SetHudTextParams(0.02, 0.08, 300.0, 0, 225, 40, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler1, "Dzień: %s", g_cCurrentDay);
	}
}

void ClearHud(int client)
{
	ClearSyncHud(client, HudHandler);
	ClearSyncHud(client, HudHandler1);
	ClearSyncHud(client, HudHandler2);
	ClearSyncHud(client, HudHandler3);
	ClearSyncHud(client, HudHandler4);
}
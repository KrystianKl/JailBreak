#pragma newdecls required
#pragma semicolon 1

#include <clientprefs>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Weapons Menu"

enum Weapons 
{
	String:WeaponClass[64],
	String:WeaponName[64]
};

bool g_bNewWeaponSelected[MAXPLAYERS+1];
bool g_bRememberChoice[MAXPLAYERS+1];
bool g_bWeaponsDistributed[MAXPLAYERS + 1] = { false, ... };

char g_sPrimaryWeapon[MAXPLAYERS + 1][24];
char g_sSecondaryWeapon[MAXPLAYERS + 1][24];

Handle Timers[MAXPLAYERS + 1] = INVALID_HANDLE;
Handle g_hBaseMenuFirst = INVALID_HANDLE;
Handle g_hBaseMenuSecond = INVALID_HANDLE;
Handle g_hBuildMenuFirst = INVALID_HANDLE;
Handle g_hBuildMenuSecond = INVALID_HANDLE;
Handle g_hPriamryWeapon = INVALID_HANDLE;
Handle g_hSecondaryWeapon = INVALID_HANDLE;
Handle g_aPrimary_Array;
Handle g_aSecondary_Array;

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
	g_aPrimary_Array = CreateArray(128);
	g_aSecondary_Array = CreateArray(128);
	
	LoadWeaponList();
	
	g_hBaseMenuFirst = BaseMenuHandler(true);
	g_hBaseMenuSecond = BaseMenuHandler(false);
	g_hBuildMenuFirst = BuildOptionsMenuWeapons(true);
	g_hBuildMenuSecond = BuildOptionsMenuWeapons(false);
	
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	
	AddCommandListener(Event_CommandOnChat, "say");
	AddCommandListener(Event_CommandOnChat, "say_team");
	
	g_hPriamryWeapon = RegClientCookie("EverGames_PrimaryWeapon", "EverGames_PrimaryWeapon", CookieAccess_Private);
	g_hSecondaryWeapon = RegClientCookie("EverGames_SecondaryWeapon", "EverGames_SecondaryWeapon", CookieAccess_Private);
}

public int Menu_Options(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select) {
		char info[24];
		GetMenuItem(menu, param2, info, sizeof(info));
		
		if (StrEqual(info, "New")) {
			if (g_bWeaponsDistributed[client])
				g_bNewWeaponSelected[client] = true;
			
			DisplayMenu(g_hBuildMenuFirst, client, MENU_TIME_FOREVER);
			
			g_bRememberChoice[client] = false;
		} else if (StrEqual(info, "Same")) {
			if (g_bWeaponsDistributed[client]) {
				g_bNewWeaponSelected[client] = true;
				CPrintToChat(client, "\x0B[EverGames]\x06 Otrzymasz tą samą broń w następnej rundzie.");
			}
			
			GiveSavedWeapons(client);
			
			g_bRememberChoice[client] = false;
		} else if (StrEqual(info, "SameAll")) {
			if (g_bWeaponsDistributed[client])
				CPrintToChat(client, "\x0B[EverGames]\x06 Otrzymasz tą samą broń w każdej następnej rundzie.");
			
			GiveSavedWeapons(client);
			g_bRememberChoice[client] = true;
		} else if (StrEqual(info, "Random")) {
			if (g_bWeaponsDistributed[client]) {
				g_bNewWeaponSelected[client] = true;
				CPrintToChat(client, "\x0B[EverGames]\x06 Otrzymasz losową broń w następnej rundzie.");
			}
			
			g_sPrimaryWeapon[client] = "random";
			g_sSecondaryWeapon[client] = "random";
			GiveSavedWeapons(client);
			
			g_bRememberChoice[client] = false;
		} else if (StrEqual(info, "RandomAll")) {
			if (g_bWeaponsDistributed[client])
				CPrintToChat(client, "\x0B[EverGames]\x06 Otrzymasz losową broń każdej w następnej rundzie.");
			
			g_sPrimaryWeapon[client] = "random";
			g_sSecondaryWeapon[client] = "random";
			GiveSavedWeapons(client);
			
			g_bRememberChoice[client] = true;
		}
	}
}

public int Menu_Primary(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select) {
		char info[24];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		g_sPrimaryWeapon[client] = info;
		
		DisplayMenu(g_hBuildMenuSecond, client, MENU_TIME_FOREVER);
	}
}

public int Menu_Secondary(Handle menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select) {
		char info[24];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		g_sSecondaryWeapon[client] = info;
		GiveSavedWeapons(client);
		
		if (!IsPlayerAlive(client))
			g_bNewWeaponSelected[client] = true;
		
		if (g_bNewWeaponSelected[client])
			CPrintToChat(client, "\x0B[EverGames]\x06 Otrzymasz broń przy następnym odrodzeniu się.");
	}
}

public void OnMapStart()
{
	SetBuyZones("Disable");
}

public void Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(!IsValidClient(client))
		return;
	
	ClearTimer(client);
	Timers[client] = CreateTimer(1.0, GiveWeapons, client);
}

public Action GiveWeapons(Handle timer, any client)
{
	Timers[client] = INVALID_HANDLE;
	
	if (GetClientTeam(client) > 1 && IsPlayerAlive(client)) {
		char CurrentRound[64];
		JailBreak_GetRound(CurrentRound);
		
		if(JailBreak_isRoundActive())
			if(!StrEqual(CurrentRound, "Simon", false) && GetClientTeam(client) == CS_TEAM_CT || !StrEqual(CurrentRound, "War", false) || !StrEqual(CurrentRound, "War Total", false) || !StrEqual(CurrentRound, "Zombies", false) && GetClientTeam(client) == CS_TEAM_T)
				return;
		
		g_bWeaponsDistributed[client] = false;
		
		if (g_bNewWeaponSelected[client]) {
			GiveSavedWeapons(client);
			g_bNewWeaponSelected[client] = false;
		} else if (g_bRememberChoice[client]) {
			GiveSavedWeapons(client);
		} else {
			DisplayOptionsMenu(client);
		}
	}
}

public Action Event_CommandOnChat(int client, const char[] command, int arg)
{
	static char menuTriggers[][] = { "gun", "!gun", "/gun", "guns", "!guns", "/guns", "weapon", "!weapon", "/weapon", "weapons", "!weapons", "/weapons" };
	
	if (IsValidClient(client)) {
		char text[24];
		GetCmdArgString(text, sizeof(text));
		StripQuotes(text);
		TrimString(text);
	
		for(int i = 0; i < sizeof(menuTriggers); i++)
			if (StrEqual(text, menuTriggers[i], false)) {
				g_bRememberChoice[client] = false;
				DisplayOptionsMenu(client);
				
				return Plugin_Handled;
			}
	}
	
	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	g_bWeaponsDistributed[client] = false;
	g_bNewWeaponSelected[client] = false;
}

public void OnClientCookiesCached(int client)
{
	GetClientCookie(client, g_hPriamryWeapon, g_sPrimaryWeapon[client], 24);
	GetClientCookie(client, g_hSecondaryWeapon, g_sSecondaryWeapon[client], 24);
	
	g_bRememberChoice[client] = false;
}

public void OnClientDisconnect(int client)
{
	ClearTimer(client);
	
	SetClientCookie(client, g_hPriamryWeapon, g_sPrimaryWeapon[client]);
	SetClientCookie(client, g_hSecondaryWeapon, g_sSecondaryWeapon[client]);
}

public Action Fix(Handle timer, any client)
{
	Timers[client] = INVALID_HANDLE;
	
	if (GetClientTeam(client) > 1 && IsPlayerAlive(client))
		GiveSavedWeaponsFix(client);
}

Handle BaseMenuHandler(bool previousWeapons)
{
	Handle WeaponMenu = CreateMenu(Menu_Options);
	
	SetMenuTitle(WeaponMenu, "EverGames.pl » Wybierz bronie:");
	
	SetMenuExitButton(WeaponMenu, true);
	
	AddMenuItem(WeaponMenu, "New", "Nowe bronie");
	AddMenuItem(WeaponMenu, "Same", "Poprzednie bronie", (previousWeapons) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	AddMenuItem(WeaponMenu, "SameAll", "Poprzednie bronie (cały czas)", (previousWeapons) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	AddMenuItem(WeaponMenu, "Random", "Losowe bronie");
	AddMenuItem(WeaponMenu, "RandomAll", "Losowe bronie (cały czas)");
	
	return WeaponMenu;
}

Handle BuildOptionsMenuWeapons(bool PrimaryWeapon)
{
	Handle GlobalMenu;
	Handle WeaponItem[Weapons];
	
	if(PrimaryWeapon) {
		GlobalMenu = CreateMenu(Menu_Primary);
		
		SetMenuTitle(GlobalMenu, "EverGames.pl » Podstawowa broń:");
		SetMenuExitButton(GlobalMenu, true);
		
		for(int i = 0; i < GetArraySize(g_aPrimary_Array); i++)
		{
			GetArrayArray(g_aPrimary_Array, i, WeaponItem[0]);
			AddMenuItem(GlobalMenu, WeaponItem[WeaponClass], WeaponItem[WeaponName]);
		}
	} else {
		GlobalMenu = CreateMenu(Menu_Secondary);
		
		SetMenuTitle(GlobalMenu, "EverGames.pl » Drugorzędna broń:");
		SetMenuExitButton(GlobalMenu, true);
		
		for(int i = 0; i < GetArraySize(g_aSecondary_Array); i++)
		{
			GetArrayArray(g_aSecondary_Array, i, WeaponItem[0]);
			AddMenuItem(GlobalMenu, WeaponItem[WeaponClass], WeaponItem[WeaponName]);
		}
	}
	
	return GlobalMenu;
}

void ClearTimer(int client)
{
	if (Timers[client] != INVALID_HANDLE) {
		KillTimer(Timers[client]);
		Timers[client] = INVALID_HANDLE;
	}
}

void DisplayOptionsMenu(int client)
{
	if (strcmp(g_sPrimaryWeapon[client], "") == 0 || strcmp(g_sSecondaryWeapon[client], "") == 0) {
		DisplayMenu(g_hBaseMenuSecond, client, MENU_TIME_FOREVER);
	} else {
		DisplayMenu(g_hBaseMenuFirst, client, MENU_TIME_FOREVER);
	}
}

void SetBuyZones(const char[] status)
{
	int maxEntities = GetMaxEntities();
	char class[24];
	
	for (int i = MaxClients + 1; i < maxEntities; i++)
		if (IsValidEdict(i)) {
			GetEdictClassname(i, class, sizeof(class));
			if (StrEqual(class, "func_buyzone"))
				AcceptEntityInput(i, status);
		}
}

void GiveSavedWeaponsFix(int client)
{
	if (IsPlayerAlive(client)) {
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1) {
			if (StrEqual(g_sPrimaryWeapon[client], "Random")) {
				Handle WeaponItem[Weapons];
				
				GetArrayArray(g_aPrimary_Array, GetRandomInt(0, GetArraySize(g_aPrimary_Array) - 1), WeaponItem[0]);
				GivePlayerItem(client, WeaponItem[WeaponClass]);
			} else {
				GivePlayerItem(client, g_sPrimaryWeapon[client]);
			}
		}
			
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1) {
			if (StrEqual(g_sSecondaryWeapon[client], "Random")) {
				Handle WeaponItem[Weapons];
				
				GetArrayArray(g_aSecondary_Array, GetRandomInt(0, GetArraySize(g_aSecondary_Array) - 1), WeaponItem[0]);
				GivePlayerItem(client, WeaponItem[WeaponClass]);
			} else {
				GivePlayerItem(client, g_sSecondaryWeapon[client]);
			}
		}
		
		if(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE) == -1)
			GivePlayerItem(client, "weapon_hegrenade");
		
		g_bWeaponsDistributed[client] = true;
	}
}

void GiveSavedWeapons(int client)
{
	if (!g_bWeaponsDistributed[client] && IsPlayerAlive(client))
	{
		char CurrentRound[64];
		JailBreak_GetRound(CurrentRound);
		
		if(JailBreak_isRoundActive())
			if(!StrEqual(CurrentRound, "Simon", false) && GetClientTeam(client) == CS_TEAM_CT || !StrEqual(CurrentRound, "War", false) || !StrEqual(CurrentRound, "War Total", false) || (!StrEqual(CurrentRound, "Zombies", false) && GetClientTeam(client) == CS_TEAM_T))
				return;
		
		if(GetPlayerWeaponSlot(client, CS_SLOT_PRIMARY) == -1) {
			if (StrEqual(g_sPrimaryWeapon[client], "Random")) {
				Handle WeaponItem[Weapons];
				
				GetArrayArray(g_aPrimary_Array, GetRandomInt(0, GetArraySize(g_aPrimary_Array) - 1), WeaponItem[0]);
				GivePlayerItem(client, WeaponItem[WeaponClass]);
			} else {
				GivePlayerItem(client, g_sPrimaryWeapon[client]);
			}
		}
		
		if(GetPlayerWeaponSlot(client, CS_SLOT_SECONDARY) == -1) {
			if (StrEqual(g_sSecondaryWeapon[client], "Random")) {
				Handle WeaponItem[Weapons];
				
				GetArrayArray(g_aSecondary_Array, GetRandomInt(0, GetArraySize(g_aSecondary_Array) - 1), WeaponItem[0]);
				GivePlayerItem(client, WeaponItem[WeaponClass]);
			} else {
				GivePlayerItem(client, g_sSecondaryWeapon[client]);
			}
		}

		if(GetPlayerWeaponSlot(client, CS_SLOT_GRENADE) == -1)
			GivePlayerItem(client, "weapon_hegrenade");
		
		if(JailBreak_IsCaptain(client)) {
			FakeClientCommand(client, "sm_simonmenu");
		} else {
			FakeClientCommand(client, "sm_menu");
		}
		
		g_bWeaponsDistributed[client] = true;
		
		Timers[client] = CreateTimer(6.0, Fix, client);
	}
}

void LoadWeaponList()
{
	ClearArray(g_aPrimary_Array);
	ClearArray(g_aSecondary_Array);
	
	Handle Weapon[Weapons];
	
	Format(Weapon[WeaponClass], 64, "weapon_negev");
	Format(Weapon[WeaponName], 64, "Negev");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_m249");
	Format(Weapon[WeaponName], 64, "M249");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_bizon");
	Format(Weapon[WeaponName], 64, "PP-Bizon");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_p90");
	Format(Weapon[WeaponName], 64, "P90");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
/* 	Format(Weapon[WeaponClass], 64, "weapon_scar20");
	Format(Weapon[WeaponName], 64, "SCAR-20");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_g3sg1");
	Format(Weapon[WeaponName], 64, "G3SG1");
	PushArrayArray(g_aPrimary_Array, Weapon[0]); */
	
	Format(Weapon[WeaponClass], 64, "weapon_m4a1");
	Format(Weapon[WeaponName], 64, "M4A1");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_m4a1_silencer");
	Format(Weapon[WeaponName], 64, "M4A1-S");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_ak47");
	Format(Weapon[WeaponName], 64, "AK-47");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_aug");
	Format(Weapon[WeaponName], 64, "AUG");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_galilar");
	Format(Weapon[WeaponName], 64, "Galil AR");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
 	Format(Weapon[WeaponClass], 64, "weapon_awp");
	Format(Weapon[WeaponName], 64, "AWP");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_sg556");
	Format(Weapon[WeaponName], 64, "SG 553");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_ump45");
	Format(Weapon[WeaponName], 64, "UMP-45");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_mp7");
	Format(Weapon[WeaponName], 64, "MP7");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);

	Format(Weapon[WeaponClass], 64, "weapon_famas");
	Format(Weapon[WeaponName], 64, "FAMAS");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_mp9");
	Format(Weapon[WeaponName], 64, "MP9");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);

	Format(Weapon[WeaponClass], 64, "weapon_mac10");
	Format(Weapon[WeaponName], 64, "MAC-10");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
/* 	Format(Weapon[WeaponClass], 64, "weapon_ssg08");
	Format(Weapon[WeaponName], 64, "SSG 08");
	PushArrayArray(g_aPrimary_Array, Weapon[0]); */
	
	Format(Weapon[WeaponClass], 64, "weapon_nova");
	Format(Weapon[WeaponName], 64, "Nova");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_xm1014");
	Format(Weapon[WeaponName], 64, "XM1014");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_sawedoff");
	Format(Weapon[WeaponName], 64, "Sawed-Off");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_mag7");
	Format(Weapon[WeaponName], 64, "MAG-7");
	PushArrayArray(g_aPrimary_Array, Weapon[0]);
	
	// Pistols
	Format(Weapon[WeaponClass], 64, "weapon_elite");
	Format(Weapon[WeaponName], 64, "Dual Berettas");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);

	Format(Weapon[WeaponClass], 64, "weapon_deagle");
	Format(Weapon[WeaponName], 64, "Desert Eagle");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);

	Format(Weapon[WeaponClass], 64, "weapon_tec9");
	Format(Weapon[WeaponName], 64, "Tec-9");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_fiveseven");
	Format(Weapon[WeaponName], 64, "Five-SeveN");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);

 	Format(Weapon[WeaponClass], 64, "weapon_cz75a");
	Format(Weapon[WeaponName], 64, "CZ75-Auto");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_glock");
	Format(Weapon[WeaponName], 64, "Glock-18");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_usp_silencer");
	Format(Weapon[WeaponName], 64, "USP-S");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_p250");
	Format(Weapon[WeaponName], 64, "P250");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);
	
	Format(Weapon[WeaponClass], 64, "weapon_hkp2000");
	Format(Weapon[WeaponName], 64, "P2000");
	PushArrayArray(g_aSecondary_Array, Weapon[0]);
}
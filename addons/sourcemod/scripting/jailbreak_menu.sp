#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Global Menu"

Handle g_cVar_FF;

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
	RegConsoleCmd("sm_menu", DOMenu);
	RegConsoleCmd("buyammo1", DOMenu);
	RegConsoleCmd("buyammo2", DOMenu);
	
	RegConsoleCmd("sm_vipm", MenuVIP);
	RegConsoleCmd("sm_ownerm", MenuOwner);
	RegConsoleCmd("sm_simonmenu", DOsimon);
	
	g_cVar_FF = FindConVar("mp_teammates_are_enemies");
}

public Action MenuVIP(int client, int args)
{
	if(VIP_Elite(client) || VIP(client)) {
		Handle menu = CreateMenu(DIDMenuHandlerVIP);
		
		SetMenuTitle(menu, "EverGames.pl - JailBreak VIP Menu");
		
		AddMenuItem(menu, "reset", "Zresetuj ustawienia");
		AddMenuItem(menu, "model", "Wybierz model noża");
		AddMenuItem(menu, "hat", "Wybierz czapkę");
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	} else {
		CPrintToChat(client, "\x02[EverGames] \x07Nie masz uprawnień VIP Elite lub VIP.");
	}
	
	return Plugin_Handled; 
}

public int DIDMenuHandlerVIP(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info, "reset") == 0) {
			FakeClientCommand(client, "sm_fgsrtKL21");
			MenuVIP(client, 0);
		} else if (strcmp(info, "model") == 0)
			FakeClientCommand(client, "sm_fgsktKL21");
		else if (strcmp(info, "hat") == 0)
			FakeClientCommand(client, "sm_hats");
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	} 
}

public Action MenuOwner(int client, int args)
{
	if(Owner(client)) {
		Handle menu = CreateMenu(DIDMenuHandlerOwner);
		
		SetMenuTitle(menu, "EverGames.pl - JailBreak Owner Menu");
		
		AddMenuItem(menu, "daymode", "Włącz Dzień");
		AddMenuItem(menu, "nightmode", "Włącz Noc");
		AddMenuItem(menu, "fdall", "Daj wszystkim FreeDay'a");
		AddMenuItem(menu, "remove", "Usuń aktualnego prowadzącego");
		AddMenuItem(menu, "setday", "Wybierz zabawę na jutro");
		AddMenuItem(menu, "boxon", "Włącz Więziennego Box'a");
		AddMenuItem(menu, "boxoff", "Wyłącz Więziennego Box'a");
		
		SetMenuExitButton(menu, true);
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
	} else {
		CPrintToChat(client, "\x02[EverGames] \x07Nie masz uprawnień Właściciela.");
	}
	
	return Plugin_Handled; 
}

public int DIDMenuHandlerOwner(Handle menu, MenuAction action, int client, int itemNum)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info, "daymode") == 0) {
			FakeClientCommand(client, "sm_fogoff");
			MenuOwner(client, 0);
		} else if (strcmp(info, "nightmode") == 0) {
			FakeClientCommand(client, "sm_fogon");
			MenuOwner(client, 0);
		} else if (strcmp(info, "fdall") == 0) {
			LoopValidClients(i)
				if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
					JailBreak_SetFreeDay(i);
			MenuOwner(client, 0);
		} else if (strcmp(info, "remove") == 0) {
			FakeClientCommand(client, "sm_removecaptain");
			MenuOwner(client, 0);
		} else if (strcmp(info, "setday") == 0) {
			FakeClientCommand(client, "sm_setday");
		} else if (strcmp(info, "boxon") == 0) {
			SetCvar("mp_teammates_are_enemies", 1);
			CPrintToChatAll("\x0B[EverGames] \x06Box dla więźniów został \x05włączony\x05!");
			MenuOwner(client, 0);
		} else if (strcmp(info, "boxoff") == 0) {
			SetCvar("mp_teammates_are_enemies", 0);
			CPrintToChatAll("\x0B[EverGames] \x06Box dla więźniów został \x07włączony\x05!");
			MenuOwner(client, 0);
		}
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	} 
}

public Action DOMenu(int client, int args)
{
	char CurrentRound[64];
	Handle menu = CreateMenu(DIDMenuHandler);
	
	JailBreak_GetRound(CurrentRound);
	
	SetMenuTitle(menu, "EverGames.pl » JailBreak");
	
	if(StrEqual(CurrentRound, "Simon", false)) {
		if(JailBreak_IsCaptain(client)) {
			AddMenuItem(menu, "mguard", "Menu prowadzącego");
		} else if(GetClientTeam(client) == CS_TEAM_CT) {
			AddMenuItem(menu, "besimon", "Bądź prowadzącym");
		}
		if(GetClientTeam(client) == CS_TEAM_CT) AddMenuItem(menu, "guns", "Wybierz broń");
		if(GetClientTeam(client) == CS_TEAM_T) AddMenuItem(menu, "guard", "Bądź Strażnikiem");
		AddMenuItem(menu, "sklep", "Sklep");
		if(Owner(client) || Opiekun(client) || Admin(client) || VIP_Elite(client) || VIP(client)) AddMenuItem(menu, "vip", "Menu VIP");
		AddMenuItem(menu, "gang", "Menu Gangu");
	} else {
		if(GetClientTeam(client) == CS_TEAM_T) AddMenuItem(menu, "guard", "Bądź Strażnikiem");
		AddMenuItem(menu, "guns", "Wybierz broń");
		AddMenuItem(menu, "sklep", "Sklep");
		if(Owner(client) || Opiekun(client) || Admin(client) || VIP_Elite(client) || VIP(client)) AddMenuItem(menu, "vip", "Menu VIP");
		AddMenuItem(menu, "gang", "Menu Gangu");
	}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int DIDMenuHandler(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select) 
	{
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info, "guns") == 0)
			FakeClientCommand(client, "say !guns");
		else if (strcmp(info, "sklep") == 0)
			FakeClientCommand(client, "sm_sklep");
		else if (strcmp(info, "hats") == 0) 
			FakeClientCommand(client, "sm_hats");
		else if (strcmp(info, "mguard") == 0) 
			FakeClientCommand(client, "sm_simonmenu");
		else if (strcmp(info, "besimon") == 0) {
			FakeClientCommand(client, "sm_captain");
			DOMenu(client, 0);
		} else if (strcmp(info, "guard") == 0) {
			FakeClientCommand(client, "sm_guard");
			DOMenu(client, 0);
		} else if (strcmp(info, "vip") == 0 ) 
			FakeClientCommand(client, "sm_vipm");
		else if (strcmp(info, "gang") == 0 ) 
			FakeClientCommand(client, "sm_gang");
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

public Action DOsimon(int client, int args)
{
	Handle menu = CreateMenu(DIDMenuHandlerS);
	SetMenuTitle(menu, "EverGames.pl » Menu Głównego Strażnika");
	
	AddMenuItem(menu, "openjail", "Otwórz Cele");
	AddMenuItem(menu, "closejail", "Zamknij Cele");
	AddMenuItem(menu, "fdall", "Daj wszystkich FreeDay'a");
	AddMenuItem(menu, "ftc", "Daj FreeDay'a danemu graczowi");
	AddMenuItem(menu, "kill", "Zabij randomowego Więźnia");
	
	if(!GetConVarBool(g_cVar_FF)) AddMenuItem(menu, "ffa1", "Włącz BOX");
	else AddMenuItem(menu, "ffa2", "Wyłącz BOX");
	
	AddMenuItem(menu, "nosimon", "Opuść Głównego Strażnika");
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public int DIDMenuHandlerS(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select) 
	{
		if(!JailBreak_IsCaptain(client)) {
			CPrintToChat(client, "\x0B[EverGames]\x06 Nie jesteś Głównym Strażnikiem!");
			return;
		}
		
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		if (strcmp(info, "openjail") == 0) {
			FakeClientCommand(client, "sm_open");
			DOsimon(client, 0);
		} else if (strcmp(info, "closejail") == 0) {
			FakeClientCommand(client, "sm_close");
			DOsimon(client, 0);
		}  else if (strcmp(info, "fdall") == 0) {
			GiveFDAll();
			CPrintToChatAll("\x0B[EverGames]\x06 Główny Strażnik dał wszystkim FreeDay'a!");
			DOsimon(client, 0);
		} else if (strcmp(info, "ftc") == 0) {
			FDone(client);
		} else if (strcmp(info, "ffa1") == 0) {
			SetCvar("mp_teammates_are_enemies", 1);
			CPrintToChatAll("\x0B[EverGames]\x01 Główny Strażnik \x06włączył\x01 box'a!");
			DOsimon(client, 0);
		} else if (strcmp(info, "ffa2") == 0) {
			SetCvar("mp_teammates_are_enemies", 0);
			CPrintToChatAll("\x0B[EverGames]\x01 Główny Strażnik \x07wyłączył\x01 box'a!");
			DOsimon(client, 0);
		} else if (strcmp(info,"kill") == 0) {
			int victim = GetRandomPlayer(CS_TEAM_T);
			
			if(victim > 0)
			{
				ForcePlayerSuicide(victim);
				CPrintToChatAll("\x0B[EverGames]\x06 Główny Strażnik zabił randomowo:");
				CPrintToChatAll("\x0B[EverGames]\x07 » \x03%N", victim);
			}
			DOsimon(client,0);
		} else if (strcmp(info,"nosimon") == 0) {
			FakeClientCommand(client, "sm_nocaptain");
			DOMenu(client,0);
		}
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

void SetCvar(char[] cvarName, int value)
{
	Handle cvar;
	cvar = FindConVar(cvarName);

	int flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}

void GiveFDAll()
{
	LoopValidClients(i)
		if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) 
			JailBreak_SetFreeDay(i);
}

void FDone(int client)
{
	Handle menu = CreateMenu(DIDMenuHandlerFD);
	SetMenuTitle(menu, "EverGames.pl » Wybierz gracza który ma dostać FreeDay'a");
	
	char UserID[8], UserNick[128];
	int Loops = 0;
	
	LoopValidClients(i)
		if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T && !JailBreak_GetFreeDay(i)) 
		{
			Format(UserNick, 128, "%N", i);
			Format(UserID, 8, "%i", i);
			AddMenuItem(menu, UserID, UserNick);
			Loops++;
		}
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	if(Loops == 0) {
		CPrintToChat(client, "\x0B[EverGames]\x06 Brak graczy, aby rozdać FreeDay'a!");
		DOsimon(client, 0);
	}
}

public int DIDMenuHandlerFD(Handle menu, MenuAction action, int client, int itemNum) 
{
	if (action == MenuAction_Select) 
	{
		if(!JailBreak_IsCaptain(client)) {
			CPrintToChat(client, "\x0B[EverGames]\x06 Nie masz Głównego Strażnika!");
			return;
		}
		
		char info[32];
		
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		int i = StringToInt(info);
		
		if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T) 
		{
			JailBreak_SetFreeDay(i);
			CPrintToChatAll("\x0B[EverGames]\x06 FreeDay'a otrzymał: \x03%N\x06!", i);
			
			DOsimon(client, 0);
		} else {
			CPrintToChat(client, "\x0B[EverGames]\x06 Wskazany gracz jest nieprawidłowy!");
			FDone(client);
		}
	} else if (action == MenuAction_End) {
		CloseHandle(menu);
	}
}

int GetRandomPlayer(int Team)
{
	new RandomPlayers[MaxClients+1];
	int	PlayersCount;
	
	LoopValidClients(i)
		if(IsPlayerAlive(i) && GetClientTeam(i) == Team)
			RandomPlayers[PlayersCount++] = i;
		
	return (PlayersCount == 0) ? -1 : RandomPlayers[GetRandomInt(0, PlayersCount - 1)];
}
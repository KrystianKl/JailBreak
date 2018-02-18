#pragma newdecls required
#pragma semicolon 1

#include <sdkhooks>
#include <CustomPlayerSkins>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - TA Grenade WallHack"

bool g_bSeePlayers[MAXPLAYERS + 1] =  { false, ... };
bool g_bShowAll[MAXPLAYERS + 1] =  { false, ... };
bool g_bDayWithWH = false;

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
	RegConsoleCmd("sm_tagrenade", Command_TAGrenade);
	
	HookEvent("player_spawn", Event_PlayerReset);
	HookEvent("player_death", Event_PlayerReset);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundReset);
	HookEvent("tagrenade_detonate", OnTagrenadeDetonate);
}

public Action Command_TAGrenade(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	if(Owner(client)) {
		if(g_bShowAll[client]) {
			g_bShowAll[client] = false;
			PrintToChat(client, " \x0B[EverGames]\x06 Zmieniłeś ustawienie na: \x07FALSE");
		} else {
			g_bShowAll[client] = true;
			PrintToChat(client, " \x0B[EverGames]\x06 Zmieniłeś ustawienie na: \x05TRUE");
		}
	} else {
		CPrintToChat(client, "\x0B[EverGames]\x06 Nie masz uprawnień do tej komendy!");
	}
	
	return Plugin_Continue;
}

public void OnTagrenadeDetonate(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!IsValidClient(client))
		return;
	
	if(Owner(client) || Opiekun(client) || Admin(client) || VIP_Elite(client) || VIP(client)) {
		g_bSeePlayers[client] = true;
	} else {
		PrintToChat(client, " \x0B[EverGames]\x06 Aby użyć WH musisz mieć VIP'a lub VIP'a Elite!");
	}
	
 	CreateTimer(2.5, Timer_ResetTags, client);
}

public Action Timer_ResetTags(Handle timer, any client)
{
	if (IsValidClient(client))
		g_bSeePlayers[client] = false;
}

public void OnClientDisconnect(int client)
{
	g_bSeePlayers[client] = false;
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(StrEqual(CurrentRound, "Grenade", false) || StrEqual(CurrentRound, "Dodgeball", false))
		g_bDayWithWH = true;
	
	return Plugin_Handled;
}

public Action Event_PlayerReset(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (IsValidClient(client))
		g_bSeePlayers[client] = false;
}

public Action Event_RoundReset(Event event, const char[] name, bool dontBroadcast)
{
	LoopValidClients(i)
		g_bSeePlayers[i] = false;
	
	g_bDayWithWH = false;
}

public void OnAllPluginsLoaded()
{
	CreateTimer(0.3, Timer_SetupGlow, _, TIMER_REPEAT);
}

public Action Timer_SetupGlow(Handle timer, any data)
{
	LoopValidClients(i)
		SetupGlowSkin(i);

	return Plugin_Continue;
}

void SetupGlowSkin(int client)
{
	UnHookSkin(client);
	CPS_RemoveSkin(client);

	if (IsFakeClient(client) || IsClientSourceTV(client))
		return;

	if (!IsPlayerAlive(client))
		return;

	char model[PLATFORM_MAX_PATH];
	GetClientModel(client, model, sizeof(model));
	int skin = CPS_SetSkin(client, model, CPS_RENDER);

	if(skin == -1)
		return;
		
	
	if (SDKHookEx(skin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin))
		SetupGlow(client, skin);
}

void UnHookSkin(int client)
{
	if(CPS_HasSkin(client)) 
	{
		int skin = EntRefToEntIndex(CPS_GetSkin(client));

		if(IsValidEntity(skin))
			SDKUnhook(skin, SDKHook_SetTransmit, OnSetTransmit_GlowSkin);
	}
}

void SetupGlow(int client, int skin)
{
	int iOffset;

	if ((iOffset = GetEntSendPropOffs(skin, "m_clrGlow")) == -1)
		return;

	SetEntProp(skin, Prop_Send, "m_bShouldGlow", true, true);
	SetEntProp(skin, Prop_Send, "m_nGlowStyle", 0);
	SetEntPropFloat(skin, Prop_Send, "m_flGlowMaxDist", 10000000.0);

	int iRed = 255;
	int iGreen = 255;
	int iBlue = 255;

	if (GetClientTeam(client) == CS_TEAM_T) {
		iRed = 240;
		iGreen = 0;
		iBlue = 0;
	} else if(GetClientTeam(client) == CS_TEAM_CT) {
		iRed = 0;
		iGreen = 190;
		iBlue = 230;
	}

	SetEntData(skin, iOffset, iRed, _, true);
	SetEntData(skin, iOffset + 1, iGreen, _, true);
	SetEntData(skin, iOffset + 2, iBlue, _, true);
	SetEntData(skin, iOffset + 3, 255, _, true);
}

public bool OnTraceForTagrenade(int entity, int contentsMask, any tagrenade)
{
	return (entity == tagrenade) ? false : true;
}

public Action OnSetTransmit_GlowSkin(int skin, int client)
{
	LoopValidClients(i)
	{
		if (i < 1)
			continue;

		if (client == i)
			continue;

		if (IsFakeClient(i))
			continue;

		if (!IsPlayerAlive(i))
			continue;

		if (!CPS_HasSkin(i))
			continue;

		if (EntRefToEntIndex(CPS_GetSkin(i)) != skin)
			continue;
	}
	
	if(IsFakeClient(client) || g_bSeePlayers[client] || g_bShowAll[client] || g_bDayWithWH) 
		return Plugin_Continue;
		
	if(!IsPlayerAlive(client) && (Owner(client) || Opiekun(client) || Admin(client)))
		return Plugin_Continue;

	return Plugin_Handled;
}
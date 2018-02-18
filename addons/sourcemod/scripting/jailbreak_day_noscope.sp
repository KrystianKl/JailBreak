#pragma newdecls required
#pragma semicolon 1

#include <sdkhooks>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Day: NoScope"

int g_SmokeSprite;
int g_LightningSprite;
int m_flNextSecondaryAttack;
int g_hActiveWeapon = -1;
int g_iClip1 = -1;

Handle g_hTimeStart = INVALID_HANDLE;
Handle g_hTimeLeftToFF;

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
	g_hTimeLeftToFF = FindConVar("mp_roundtime");
	
	g_hActiveWeapon = FindSendPropInfo("CCSPlayer", "m_hActiveWeapon");
	g_iClip1 = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
	
	HookEvent("bullet_impact", Event_OnBulletImpact);
	HookEvent("round_prestart", Event_PreRoundStart);
	HookEvent("round_start", Event_OnRoundStart);
	HookEvent("weapon_reload", Event_OnPlayerReload);
	HookEvent("weapon_fire_on_empty", Event_OnPlayerReload);
	
	RegConsoleCmd("drop", Event_OnWeaponDrop);
	
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	
	LoopValidClients(i)
		OnClientPutInServer(i);
}

public void OnMapStart() 
{
	g_SmokeSprite = PrecacheModel("sprites/steam1.vmt");
	g_LightningSprite = PrecacheModel("sprites/lgtning.vmt");
}

public Action Event_PreRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "NoScope", false))
		return;
	
	LoopValidClients(i)
		SDKHook(i, SDKHook_PreThink, OnPreThink);
}

public Action Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	if (g_hTimeStart != INVALID_HANDLE)
		KillTimer(g_hTimeStart);
		
	g_hTimeStart = INVALID_HANDLE;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "NoScope", false))
		return;
	
	CreateTimer(0.5, SetWeaponsAndMovement);
	
	JailBreak_OpenDoors();
	CPrintToChatAll(" ");
	CPrintToChatAll(" ");
	CPrintToChatAll(" ");
	CPrintToChatAll(" ");
	CPrintToChatAll("\x02[EverGames] \x07Cele zostały otwarte.");
	CPrintToChatAll("\x04[EverGames] \x07===================================");
	CPrintToChatAll("\x04[EverGames] \x03Zabawa:");
	CPrintToChatAll("\x04[EverGames] \x04- \x06NoScope \x05(Bez Prawego Przycisku Myszki)");
	CPrintToChatAll("\x04[EverGames] \x03Opis:");
	CPrintToChatAll("\x04[EverGames] \x06Każdy ze Strażnikow dostaje AWP,");
	CPrintToChatAll("\x04[EverGames] \x06i musi zabić wszystkich więźniow,");
	CPrintToChatAll("\x04[EverGames] \x05Uwaga: \x0645s przed końcem TT moze zabić CT.");
	CPrintToChatAll("\x04[EverGames] \x07===================================");
	
	g_hTimeStart = CreateTimer(((60.0*GetConVarFloat(g_hTimeLeftToFF)) - 45.0), Timer_TimeLeft);
}

public Action Timer_TimeLeft(Handle timer)
{
	g_hTimeStart = INVALID_HANDLE;
	
	CPrintToChatAll("\x02[EverGames] \x07===================================");
	CPrintToChatAll("\x02[EverGames] \x07Pozostało \x0245 sekund\x07 do końca!");
	CPrintToChatAll("\x02[EverGames] \x07Strażnicy teraz mogą zostać zabici!");
	CPrintToChatAll("\x02[EverGames] \x07===================================");
}

public Action Event_OnWeaponDrop(int client, int args)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "NoScope", false))
		return Plugin_Continue;
	
	return Plugin_Handled;
}

public Action SetWeaponsAndMovement(Handle timer)
{
	LoopValidClients(i) 
	{
		RemoveAllWeapons(i, "");
		GivePlayerItem(i, "weapon_knife");
		
		if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.2);
		else if(IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_CT)
			GivePlayerItem(i, "weapon_awp");
	}
	ServerCommand("sm_broom");
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "NoScope", false))
		return;
	
	SDKHook(client, SDKHook_PreThink, OnPreThink);	
}

public Action CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "NoScope", false))
		return;
	
	LoopValidClients(i)
		SDKUnhook(i, SDKHook_PreThink, OnPreThink);
}

public Action OnPreThink(int client)
{
	int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	
	if(IsValidEdict(iWeapon)) {
		char WeaponName[MAX_NAME_LENGTH];
		GetEdictClassname(iWeapon, WeaponName, sizeof(WeaponName));
		
		if(StrEqual(WeaponName[7], "ssg08") || StrEqual(WeaponName[7], "sg550") || StrEqual(WeaponName[7], "awp") || StrEqual(WeaponName[7], "scar20") || StrEqual(WeaponName[7], "g3sg1"))
			SetEntDataFloat(iWeapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
	}
	
	return Plugin_Continue;
}

public Action OnWeaponCanUse(int client, int iWeapon)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "NoScope", false))
		return Plugin_Continue;

	char WeaponName[32];
	GetEdictClassname(iWeapon, WeaponName, sizeof(WeaponName));
	if (StrEqual(WeaponName, "weapon_knife") || (GetClientTeam(client) == CS_TEAM_CT && StrEqual(WeaponName, "weapon_awp")))
		return Plugin_Continue;
		
		
	return Plugin_Handled;
}

public Action OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || attacker == victim || !IsValidClient(attacker)) return Plugin_Continue;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "NoScope", false))
		return Plugin_Continue;
	
	if(GetClientTeam(victim) == CS_TEAM_CT && GetClientTeam(attacker) == CS_TEAM_T && g_hTimeStart != INVALID_HANDLE)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Event_OnPlayerReload(Handle event, const char[] name, bool dontBroadcast) 
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(StrEqual(CurrentRound, "NoScope", false)) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		
		if(IsValidClient(client) && IsPlayerAlive(client)) {
			CPrintToChat(client, "\x0B[EverGames]\x06 Amunicja została uzupełniona!");
			int g_iClip;
			int g_iEntityIndex = GetEntDataEnt2(client, g_hActiveWeapon);
			
			if (IsValidEdict(g_iEntityIndex)) {
				if (g_iEntityIndex == GetPlayerWeaponSlot(client, 0))
					g_iClip = 10;

				if (g_iClip)
					SetEntData(g_iEntityIndex, g_iClip1, g_iClip, 4, true);
			}
		}
	}
}

public int Event_OnBulletImpact(Handle event, const char[] name, bool dontBroadcast) 
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(StrEqual(CurrentRound, "NoScope", false)) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		
		float fPosition[3];
		float fImpact[3];
		float fDifference[3];
			
		GetClientEyePosition(client, fPosition);
		fImpact[0] = GetEventFloat(event, "x");
		fImpact[1] = GetEventFloat(event, "y");
		fImpact[2] = GetEventFloat(event, "z");
		
		float fDistance = GetVectorDistance(fPosition, fImpact);
		float fPercent = (0.4 / (fDistance / 100.0));
		
		fDifference[0] = fPosition[0] + ((fImpact[0] - fPosition[0]) * fPercent);
		fDifference[1] = fPosition[1] + ((fImpact[1] - fPosition[1]) * fPercent) - 0.08;
		fDifference[2] = fPosition[2] + ((fImpact[2] - fPosition[2]) * fPercent);
			
		int color[4] =  { 255, 255, 255, 255 };
			
		float dir[3] = {0.0, 0.0, 0.0};
			
		TE_SetupBeamPoints(fDifference, fImpact, g_LightningSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
		TE_SendToAll();
		
		TE_SetupSparks(fImpact, dir, 5000, 1000);
		TE_SendToAll();
			
		TE_SetupEnergySplash(fImpact, dir, false);
		TE_SendToAll();
		
		TE_SetupSmoke(fImpact, g_SmokeSprite, 5.0, 10);
		TE_SendToAll();
	}
}
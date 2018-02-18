#pragma newdecls required
#pragma semicolon 1

#include <sdkhooks>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Day: Dodgeball Day"

bool DodgeballDay = false;
int RoundTime = 15,
	g_WeaponParent;
Handle RoundTimer = INVALID_HANDLE;
Handle HealthTimer = INVALID_HANDLE;

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
	g_WeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_OnPlayerDeath);
	
	RegConsoleCmd("drop", DropGrenade);
	
	LoopValidClients(i)
		OnClientPutInServer(i);
}

public Action DropGrenade(int client, int args)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Dodgeball", false))
		return Plugin_Continue;
	
	if(!DodgeballDay)
		return Plugin_Continue;
	
	CPrintToChat(client, "\x0B[EverGames]\x06 Nie możesz upuścić: \x07granata\x06.");
	RemoveAllWeapons(client, "");
	GivePlayerItem(client, "weapon_flashbang");
	ClearAllWeapons();
	return Plugin_Handled;
}

public void OnEntityCreated(int entity, const char[] checkFlash)
{
	if (StrEqual(checkFlash, "flashbang_projectile"))
		SDKHook(entity, SDKHook_Spawn, OnEntitySpawned);
}

public void OnEntitySpawned(int entity)
{
	CreateTimer(0.0, Timer_RemoveThinkTick, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RemoveThinkTick(Handle timer, any entity)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Dodgeball", false))
		return;
		
	SetEntProp(entity, Prop_Data, "m_nNextThinkTick", -1);
	CreateTimer(1.5, Timer_RemoveFlashbang, entity, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_RemoveFlashbang(Handle timer, any entity)
{
	if (IsValidEntity(entity))
	{
		int client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		AcceptEntityInput(entity, "Kill");
		
		if (IsValidClient(client) && IsPlayerAlive(client))
		{
			RemoveAllWeapons(client, "");
			GivePlayerItem(client, "weapon_flashbang");
		}
	}
}

public Action Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	DodgeballDay = false;
	
	if (RoundTimer != INVALID_HANDLE)
		KillTimer(RoundTimer);
		
	RoundTimer = INVALID_HANDLE;
}

public Action Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{	
	DodgeballDay = false;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Dodgeball", false))
		return;
	
	RoundTime = 15;
	RoundTimer = CreateTimer(1.0, RoundPreStart, _, TIMER_REPEAT);
}

public Action RoundPreStart(Handle Timer, Handle pack)
{
	--RoundTime;
	
	if(RoundTime < 0) {
		LoopValidClients(i)
			if(IsPlayerAlive(i)) {
				if(GetEntProp(i, Prop_Send, "m_iHealth") > 1) {
					ForcePlayerSuicide(i);
					CPrintToChatAll("\x0B[EverGames]\x07 %N\x06 został zabity za oszukiwanie!", i);
				}
			}
	} else if(RoundTime == 14) {
		JailBreak_OpenDoors();
		CPrintToChatAll(" ");
		CPrintToChatAll(" ");
		CPrintToChatAll(" ");
		CPrintToChatAll(" ");
		CPrintToChatAll("\x02[EverGames] \x07Cele zostały otwarte.");
		CPrintToChatAll("\x0B[EverGames] \x07===================================");
		CPrintToChatAll("\x0B[EverGames] {blue}Zabawa:");
		CPrintToChatAll("\x0B[EverGames] \x04- \x06Dogdeball \x05(Dwa ognie)");
		CPrintToChatAll("\x0B[EverGames] {blue}Opis:");
		CPrintToChatAll("\x0B[EverGames] \x06Każdy dostaje po flash'u i jego zadaniem,");
		CPrintToChatAll("\x0B[EverGames] \x06jest wybić wszystkich graczy i przetrwać,");
		CPrintToChatAll("\x0B[EverGames] \x04Info: \x06Każdy ma po jednym hp.");
		CPrintToChatAll("\x0B[EverGames] \x07===================================");
	} else if(RoundTime == 10) {
		HealthTimer = CreateTimer(0.1, Timer_Health, _, TIMER_REPEAT);
		CPrintToChatAll("\x0B[EverGames] \x06Pozostało \x03%i sekund \x06do rozpoczęcia zabawy!", RoundTime);
		CPrintToChatAll("\x02[EverGames] \x07Ustawiam wszystkim po 1 pkt. życia!");
	} else if(RoundTime == 5) {
		CPrintToChatAll("\x0B[EverGames] \x06Pozostało \x03%i sekund \x06do rozpoczęcia zabawy!", RoundTime);
	} else if(RoundTime < 5 && RoundTime > 1) {
		CPrintToChatAll("\x0B[EverGames] \x06Pozostały \x03%i sekundy \x06do rozpoczęcia zabawy!", RoundTime);
	} else if(RoundTime == 1) {
		CPrintToChatAll("\x0B[EverGames] \x06Pozostała \x03%i sekunda \x06do rozpoczęcia zabawy!", RoundTime);
	} else if(RoundTime == 0) {
		CPrintToChatAll("\x0B[EverGames] \x06Zabawa w \x03Dodgeball\x06 została rozpoczęta!");
		DodgeballDay = true;
		RoundStart();
	}
}

public Action Timer_Health(Handle Timer)
{
	if(RoundTime < 1) {
		if (HealthTimer != INVALID_HANDLE)
			KillTimer(HealthTimer);
			
		HealthTimer = INVALID_HANDLE;
	}
	
	LoopValidClients(i)
		if(IsPlayerAlive(i)) {
			if(GetEntProp(i, Prop_Send, "m_iHealth") > 1)
				SetEntProp(i, Prop_Send, "m_iHealth", GetEntProp(i, Prop_Send, "m_iHealth") - 1);
			
			if(GetEntProp(i, Prop_Send, "m_ArmorValue") > 0)
				SetEntProp(i, Prop_Send, "m_ArmorValue", GetEntProp(i, Prop_Send, "m_ArmorValue") - 1);
		}
}

void RoundStart() {
	ClearAllWeapons();
	LoopValidClients(i) {
		SetEntProp(i, Prop_Send, "m_ArmorValue", 0);
		SetEntProp(i, Prop_Send, "m_bHasHelmet", 0);
		RemoveAllWeapons(i, "");
		GivePlayerItem(i, "weapon_flashbang");
		if(GetEntProp(i, Prop_Send, "m_iHealth") > 1)
			SetEntProp(i, Prop_Send, "m_iHealth", 1);
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
}

public Action Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Dodgeball", false))
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	CreateTimer(0.5, FixPlayer, client);
}

public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Dodgeball", false))
		return Plugin_Handled;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(!IsValidClient(attacker)) return Plugin_Handled;
	if(client == attacker) return Plugin_Handled;
	
	SetEntProp(attacker, Prop_Send, "m_iHealth", 1);
	
	return Plugin_Handled;
}

public Action FixPlayer(Handle Timer, any client)
{
	SetEntProp(client, Prop_Send, "m_iHealth", 100);
	SetEntProp(client, Prop_Send, "m_ArmorValue", 100);
	RemoveAllWeapons(client, "");
	GivePlayerItem(client, "weapon_knife");
}

public Action OnWeaponCanUse(int client, int weapon)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Dodgeball", false))
		return Plugin_Continue;

	if(!DodgeballDay)
		return Plugin_Continue;
	
	char g_cWeaponName[32];
	GetEdictClassname(weapon, g_cWeaponName, sizeof(g_cWeaponName));
	if (StrEqual(g_cWeaponName, "weapon_flashbang"))
		return Plugin_Continue;
	
	return Plugin_Handled;
}

public Action OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || !IsValidClient(attacker)) return Plugin_Continue;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Dodgeball", false))
		return Plugin_Continue;
	
	if(!DodgeballDay) {
		CPrintToChat(attacker, "\x0B[EverGames]\x06 Nie możesz teraz atakować!");
		return Plugin_Handled;
	}
	
	if(victim == attacker)
		return Plugin_Handled;

	return Plugin_Continue;
}

stock void ClearAllWeapons()
{
	int maxent = GetMaxEntities();
	char weapon[64];
	for (int i = GetMaxClients(); i < maxent; i++) {
		if (IsValidEdict(i) && IsValidEntity(i)) {
			GetEdictClassname(i, weapon, sizeof(weapon));
			if ((StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 ) && GetEntDataEnt2(i, g_WeaponParent) == -1)
				RemoveEdict(i);
		}
	}
}
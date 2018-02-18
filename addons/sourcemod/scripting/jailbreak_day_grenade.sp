#pragma newdecls required
#pragma semicolon 1

#include <sdkhooks>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Day: Grenade Day"

bool GrenadeDay = false;
int g_SmokeSprite,
	g_LightningSprite,
	RoundTime = 15,
	g_WeaponParent;
Handle RoundTimer = INVALID_HANDLE;

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
	HookEvent("hegrenade_detonate", OnHegrenadeDetonate);
	
	RegConsoleCmd("drop", DropGrenade);
	
	LoopValidClients(i)
		OnClientPutInServer(i);
}

public void OnMapStart()
{
	g_SmokeSprite = PrecacheModel("sprites/steam1.vmt");
	g_LightningSprite = PrecacheModel("sprites/lgtning.vmt");
}

public Action DropGrenade(int client, int args)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Grenade", false))
		return Plugin_Continue;
	
	if(!GrenadeDay)
		return Plugin_Continue;
	
	CPrintToChat(client, "\x0B[EverGames]\x06 Nie możesz upuścić: \x07granata\x06.");
	GivePlayerItem(client, "weapon_hegrenade");
	ClearAllWeapons();
	return Plugin_Handled;
}

public Action Event_RoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	GrenadeDay = false;
}

public Action Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{	
	GrenadeDay = false;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Grenade", false))
		return;
	
	RoundTime = 15;
	RoundTimer = CreateTimer(1.0, RoundPreStart, _, TIMER_REPEAT);
}

public Action RoundPreStart(Handle Timer, Handle pack)
{
	--RoundTime;
	
	if(RoundTime == 14) {
		JailBreak_OpenDoors();
		CPrintToChatAll(" ");
		CPrintToChatAll(" ");
		CPrintToChatAll(" ");
		CPrintToChatAll(" ");
		CPrintToChatAll("\x02[EverGames] \x07Cele zostały otwarte.");
		CPrintToChatAll("\x0B[EverGames] \x07===================================");
		CPrintToChatAll("\x0B[EverGames] {blue}Zabawa:");
		CPrintToChatAll("\x0B[EverGames] \x04- \x06Grenade Day \x05(Dzień granatów)");
		CPrintToChatAll("\x0B[EverGames] {blue}Opis:");
		CPrintToChatAll("\x0B[EverGames] \x06Każdy dostaje po granacie i musi,");
		CPrintToChatAll("\x0B[EverGames] \x06zabić przeciwną drużynę (CT lub TT),");
		CPrintToChatAll("\x0B[EverGames] \x04Info: \x06Strażnicy mają więcej życia i prędkości.");
		CPrintToChatAll("\x0B[EverGames] \x07===================================");
	} else if(RoundTime == 10 || RoundTime == 5) {
		CPrintToChatAll("\x0B[EverGames] \x06Pozostało \x03%i sekund \x06do rozpoczęcia zabawy!", RoundTime);
	} else if(RoundTime < 5 && RoundTime > 1) {
		CPrintToChatAll("\x0B[EverGames] \x06Pozostały \x03%i sekundy \x06do rozpoczęcia zabawy!", RoundTime);
	} else if(RoundTime == 1) {
		CPrintToChatAll("\x0B[EverGames] \x06Pozostała \x03%i sekunda \x06do rozpoczęcia zabawy!", RoundTime);
	} else if(RoundTime < 1) {
		if (RoundTimer != INVALID_HANDLE)
			KillTimer(RoundTimer);
		
		RoundTimer = INVALID_HANDLE;
		CPrintToChatAll("\x0B[EverGames] \x06Zabawa w \x03Grenade Day\x06 została rozpoczęta!");
		GrenadeDay = true;
		RoundStart();
	}
}

void RoundStart() {
	ClearAllWeapons();
	LoopValidClients(i) {
		if(GetClientTeam(i) == CS_TEAM_T) {
			SetEntProp(i, Prop_Send, "m_iHealth", 100);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
		} else if(GetClientTeam(i) == CS_TEAM_CT) {
			SetEntProp(i, Prop_Send, "m_iHealth", 350);
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.25);
		}
		RemoveAllWeapons(i, "");
		GivePlayerItem(i, "weapon_hegrenade");
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
	if(!StrEqual(CurrentRound, "Grenade", false))
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	CreateTimer(0.5, FixPlayer, client);
}

public Action FixPlayer(Handle Timer, any client)
{
	RemoveAllWeapons(client, "");
	GivePlayerItem(client, "weapon_knife");
}

public Action OnHegrenadeDetonate(Handle event, const char[] name, bool dontBroadcast)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Grenade", false))
		return Plugin_Handled;
		
	if(!GrenadeDay)
		return Plugin_Handled;
	
	int client = GetClientOfUserId(GetEventInt(event ,"userid"));
	
	float fImpact[3];
	
	fImpact[0] = GetEventFloat(event, "x");
	fImpact[1] = GetEventFloat(event, "y");
	fImpact[2] = GetEventFloat(event, "z");
	
	float dir[3] = {0.0, 0.0, 0.0};
	
	int color[4] = { 255, 255, 255, 255 };
	
	TE_SetupBeamPoints(fImpact, fImpact, g_LightningSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, color, 3);
	TE_SendToAll();
	
	TE_SetupSparks(fImpact, dir, 5000, 1000);
	TE_SendToAll();
		
	TE_SetupEnergySplash(fImpact, dir, false);
	TE_SendToAll();
	
	TE_SetupSmoke(fImpact, g_SmokeSprite, 5.0, 10);
	TE_SendToAll();
	
	if(IsValidClient(client) && IsPlayerAlive(client)) {
		RemoveAllWeapons(client, "");
		GivePlayerItem(client, "weapon_hegrenade");
	}
	
	return Plugin_Continue;
}

public Action OnWeaponCanUse(int client, int weapon)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Grenade", false))
		return Plugin_Continue;

	if(!GrenadeDay)
		return Plugin_Continue;
	
	char g_cWeaponName[32];
	GetEdictClassname(weapon, g_cWeaponName, sizeof(g_cWeaponName));
	if (StrEqual(g_cWeaponName, "weapon_hegrenade"))
		return Plugin_Continue;
	
	return Plugin_Handled;
}

public Action OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(!IsValidClient(victim) || !IsValidClient(attacker)) return Plugin_Continue;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(!StrEqual(CurrentRound, "Grenade", false))
		return Plugin_Continue;
	
	if(!GrenadeDay) {
		CPrintToChat(attacker, "\x0B[EverGames]\x06 Nie możesz atakować podczas czasu przygotowania!");
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
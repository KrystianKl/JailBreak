#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - AntiCamp System"

int g_iBRColorT[] = {150, 0, 0, 255},
	g_iBRColorCT[] = {0, 0, 150, 255},
	g_iBeamSprite = -1,
	g_iHaloSprite = -1,
	g_iTimerCount[MAXPLAYERS + 1],
	g_iCaughtCount[MAXPLAYERS + 1];

float g_fLastPos[MAXPLAYERS + 1][3];

Handle g_hTimerList[MAXPLAYERS + 1];
Handle g_hBeaconList[MAXPLAYERS + 1];

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
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_PostNoCopy);
	HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_PostNoCopy);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("cs_win_panel_match", Event_OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("announce_phase_end", Event_OnRoundEnd, EventHookMode_PostNoCopy);
}

public void OnMapStart()
{
	PrecacheSound("buttons/button17.wav",true);
	
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/light_glow02.vmt");
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	LoopValidClients(i) {
		if(g_hTimerList[i] != INVALID_HANDLE) {
			KillTimer(g_hTimerList[i]);
			g_hTimerList[i] = INVALID_HANDLE;
		}
		
		if(g_hBeaconList[i] != INVALID_HANDLE) {
			KillTimer(g_hBeaconList[i]);
			g_hBeaconList[i] = INVALID_HANDLE;
		}
		
		g_iCaughtCount[i] = 0;
		g_iTimerCount[i] = 0;
	}
	
	return Plugin_Continue;
}
public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(g_hTimerList[client] != INVALID_HANDLE) {
		KillTimer(g_hTimerList[client]);
		g_hTimerList[client] = INVALID_HANDLE;
	}
	
	g_iCaughtCount[client] = 0;
	g_iTimerCount[client] = 0;
	
	return Plugin_Continue;
}

public Action Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(StrEqual(CurrentRound, "Simon", false))
		return Plugin_Handled;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	GetClientAbsOrigin(client, g_fLastPos[client]);
	g_hTimerList[client] = CreateTimer(1.0, CheckCamperTimer, client);
	
	return Plugin_Continue;
}

public Action CheckCamperTimer(Handle timer, any client)
{
	if(!IsValidClient(client))
		return Plugin_Handled;
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(StrEqual(CurrentRound, "Simon", false))
		return Plugin_Handled;

	float currentPos[3];	
	GetClientAbsOrigin(client, currentPos);
	
	if(IsCamping(client, g_fLastPos[client], currentPos))
	{
		g_iCaughtCount[client] = 0;
		g_iTimerCount[client] = 1;
		g_hTimerList[client] = CreateTimer(1.0, CaughtCampingTimer, client);
	} else
		g_hTimerList[client] = CreateTimer(1.0, CheckCamperTimer, client);
	
	g_fLastPos[client] = currentPos;
	
	return Plugin_Handled;
}

public bool IsCamping(int client, float vec1[3], float vec2[3])
{
	return (GetVectorDistance(vec1, vec2) < 125.0) ? true : false;
}

public Action CaughtCampingTimer(Handle timer, any client)
{
	if(!IsValidClient(client))
		return Plugin_Handled;

	float currentPos[3];	
	GetClientAbsOrigin(client, currentPos);
	if(g_iTimerCount[client] < 20)
	{
		if(IsPlayerAlive(client) && IsCamping(client, g_fLastPos[client], currentPos))
			g_iCaughtCount[client]++;
		
		g_iTimerCount[client]++;
		g_hTimerList[client] = CreateTimer(1.0, CaughtCampingTimer, client);
	} else {
		if(g_iCaughtCount[client] >= 5 && IsPlayerAlive(client) && IsCamping(client, g_fLastPos[client], currentPos)) {
			CPrintToChatAll("\x0B[EverGames]\x06 Gracz \x07%N\x06 jest AFK.", client);
			g_hBeaconList[client] = CreateTimer(1.0, BeaconTimer, client);
			
			g_iCaughtCount[client] = 0;
			g_iTimerCount[client] = 1;
			g_hTimerList[client] = CreateTimer(1.0, CaughtCampingTimer, client);	
		} else {			
			g_hTimerList[client] = CreateTimer(1.0, CheckCamperTimer, client);
			g_fLastPos[client] = currentPos;
		}
	}
	
	return Plugin_Handled;
}

public Action BeaconTimer(Handle timer, any client)
{
	if(!IsValidClient(client))
		return Plugin_Handled;
	
	if(!IsPlayerAlive(client))
		return Plugin_Handled;
	
	if(g_hBeaconList[client] != INVALID_HANDLE) {
		KillTimer(g_hBeaconList[client]);
		g_hBeaconList[client] = INVALID_HANDLE;
	}
	
	float currentPos[3];	
	GetClientAbsOrigin(client, currentPos);
	
	if(!IsCamping(client, g_fLastPos[client], currentPos))
		return Plugin_Handled;
		
	g_fLastPos[client] = currentPos;
	
	if(GetClientTeam(client) == CS_TEAM_CT) {
		BeamRing(client, g_iBRColorCT);
	} else if(GetClientTeam(client) == CS_TEAM_T) {
		BeamRing(client, g_iBRColorT);
	}
	
	EmitSoundToAll("buttons/button17.wav", client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, currentPos, NULL_VECTOR, true, 0.0);
	
	int health = GetEntProp(client, Prop_Send, "m_iHealth");
	
	if(health <= 5) {
		SetEntProp(client, Prop_Data, "m_iFrags", GetEntProp(client, Prop_Data, "m_iFrags") + 1);
		SetEntProp(client, Prop_Data, "m_iDeaths", GetEntProp(client, Prop_Data, "m_iDeaths") - 1);
		ForcePlayerSuicide(client);
		CPrintToChatAll("\x0B[EverGames]\x07 %N\x06 został zgładzony za AFK!", client);
	} else {
		SetEntProp(client, Prop_Send, "m_iHealth", GetEntProp(client, Prop_Send, "m_iHealth") - 5);
	}
	
	g_hBeaconList[client] = CreateTimer(1.0, BeaconTimer, client);
	
	return Plugin_Handled;
}

public void BeamRing(client, color[4])
{
	float vec[3];
	GetClientAbsOrigin(client, vec);
	vec[2] += 10;

	TE_SetupBeamRingPoint(vec, 10.0, 335.0, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.6, 10.0, 0.5, color, 10, 0);
	TE_SendToAll();
}
#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - VIP & VIP Elite Core"

int g_fLastButtons[MAXPLAYERS+1], 
	g_fLastFlags[MAXPLAYERS+1],
	g_iJumps[MAXPLAYERS+1];

Handle EverGames[MAXPLAYERS+1];

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
	HookEvent("player_spawn", Event_OnPlayerSpawn);
	HookEvent("player_death",  Event_OnPlayerDeath);
	HookEvent("round_end", Event_OnRoundEnd);
	
	CreateTimer(75.0, Timer_AnnounceMessage, _, TIMER_REPEAT);
}

public Action Timer_AnnounceMessage(Handle timer)
{
	CPrintToChatAll("\x0B[EverGames] \x07===================================");
	CPrintToChatAll("\x0B[EverGames] \x06Informacje na temat rangi \x09VIP\x06 i \x09VIP Elite\x06,");
	CPrintToChatAll("\x0B[EverGames] \x06Dostepne pod komendami: \x03!vip \x06lub \x03!vipe");
	CPrintToChatAll("\x0B[EverGames] \x07===================================");
}

public Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(IsValidClient(client) && IsPlayerAlive(client)) {
		EverGames[client] = CreateTimer(0.15, Timer_ClientSpawn, client);
	}
}

public Action Timer_ClientSpawn(Handle timer, any client) 
{
	if(EverGames[client] != INVALID_HANDLE) {
		KillTimer(EverGames[client]);
		EverGames[client] = INVALID_HANDLE;
	}
	
	if(IsValidClient(client) && IsPlayerAlive(client)) {
		if(VIP_Elite(client)) {
			Podstawowe(client);
			SetEntProp(client, Prop_Send, "m_ArmorValue", 250);
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
		} else if(VIP(client)) {
			Podstawowe(client);
			SetEntProp(client, Prop_Send, "m_ArmorValue", 120);
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 1);
		} else {
			SetEntProp(client, Prop_Send, "m_ArmorValue", 0);
			SetEntProp(client, Prop_Send, "m_bHasHelmet", 0);
		}
	}
}

public void Podstawowe(int client)
{
	GivePlayerItem(client, "weapon_smokegrenade");
	GivePlayerItem(client, "weapon_hegrenade");
	GivePlayerItem(client, "weapon_tagrenade");
	GivePlayerItem(client, "weapon_healthshot");
}

public Action Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
    LoopValidClients(i)
		if(EverGames[i] != INVALID_HANDLE) {
			KillTimer(EverGames[i]);
			EverGames[i] = INVALID_HANDLE;
		}
}

public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	if(StrEqual(CurrentRound, "Dodgeball", false)) return Plugin_Handled;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(!IsValidClient(client)) return Plugin_Handled;
	if(!IsValidClient(attacker)) return Plugin_Handled;
	if(client == attacker) return Plugin_Handled;
	
	if(VIP_Elite(attacker)) {
		if(GetEventBool(event, "headshot")) {
			SetEntProp(attacker, Prop_Send, "m_iHealth", GetEntProp(attacker, Prop_Send, "m_iHealth") + 10);
			PrintToChat(attacker, " \x0B[EverGames] \x06Otrzymujesz \x07+10HP\x06 za zabicie \x09%N\x06.", client);
		} else {
			SetEntProp(attacker, Prop_Send, "m_iHealth", GetEntProp(attacker, Prop_Send, "m_iHealth") + 8);
			PrintToChat(attacker, " \x0B[EverGames] \x06Otrzymujesz \x07+8HP\x06 za zabicie \x09%N\x06.", client);
		}
	} else if(VIP(attacker)) {
		if(GetEventBool(event, "headshot")) {
			SetEntProp(attacker, Prop_Send, "m_iHealth", GetEntProp(attacker, Prop_Send, "m_iHealth") + 8);
			PrintToChat(attacker, " \x0B[EverGames] \x06Otrzymujesz \x07+8HP\x06 za zabicie \x09%N\x06.", client);
		} else {
			SetEntProp(attacker, Prop_Send, "m_iHealth", GetEntProp(attacker, Prop_Send, "m_iHealth") + 5);
			PrintToChat(attacker, " \x0B[EverGames] \x06Otrzymujesz \x07+5HP\x06 za zabicie \x09%N\x06.", client);
		}
	}
	
	return Plugin_Handled;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{	
	if(IsValidClient(client)) {
		if(Owner(client) || Opiekun(client) || Admin(client) || VIP_Elite(client) || VIP(client)) {
			int	fCurFlags = GetEntityFlags(client);	
			int fCurButtons	= GetClientButtons(client);
						
			if (g_fLastFlags[client] & FL_ONGROUND) {		
				if (!(fCurFlags & FL_ONGROUND) &&!(g_fLastButtons[client] & IN_JUMP) &&	fCurButtons & IN_JUMP) {
					g_iJumps[client]++;			
				}
			} else if (fCurFlags & FL_ONGROUND) {
				g_iJumps[client] = 0;						
			} else if (!(g_fLastButtons[client] & IN_JUMP) && fCurButtons & IN_JUMP) {
				if (0 <= g_iJumps[client] <= 1) {						
					g_iJumps[client]++;											
					float vVel[3];
					GetEntPropVector(client, Prop_Data, "m_vecVelocity", vVel);	
									
					vVel[2] = 250.0;
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);	
				}							
			}
			g_fLastFlags[client] = fCurFlags;				
			g_fLastButtons[client] = fCurButtons;
		}
	}
}
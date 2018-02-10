#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Marker"

int g_DefaultColors_c[7][4] = {{255,255,255,255}, {255,0,0,255}, {0,255,0,255}, {0,0,255,255}, {255,255,0,255}, {0,255,255,255}, {255,0,255,255}};
int g_iLaserSprite = -1;

float LastLaser[MAXPLAYERS+1][3];

bool LaserE[MAXPLAYERS+1] = {false, ...};

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
	RegConsoleCmd("+sm_marker", Command_StartLaster);
	RegConsoleCmd("-sm_marker", Command_EndLaster);
	RegConsoleCmd("+marker", Command_StartLaster);
	RegConsoleCmd("-marker", Command_EndLaster);
}

public void OnMapStart() {
	g_iLaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	
	CreateTimer(0.1, Timer_Pay, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public void OnClientPutInServer(client)
{
	LaserE[client] = false;
	LastLaser[client][0] = 0.0;
	LastLaser[client][1] = 0.0;
	LastLaser[client][2] = 0.0;
}

public Action Timer_Pay(Handle timer)
{
	float pos[3];
	int color = GetRandomInt(0,6);
	
	LoopValidClients(i)
		if(LaserE[i]) {
			TraceEye(i, pos);
			
			if(GetVectorDistance(pos, LastLaser[i]) > 6.0) {
				LaserP(LastLaser[i], pos, g_DefaultColors_c[color]);
				LastLaser[i][0] = pos[0];
				LastLaser[i][1] = pos[1];
				LastLaser[i][2] = pos[2];
			}
		}
}

public Action Command_StartLaster(int client, int args) 
{
	if(!IsValidClient(client))
		return Plugin_Handled;
	
	if(!IsPlayerAlive(client)) {
		CPrintToChat(client, "\x0B[EverGames] \x06Musisz być żywy aby używac markera!");
	} else {
		if(Owner(client)) {
			TraceEye(client, LastLaser[client]);
			LaserE[client] = true;
			CPrintToChatAll("\x0B[EverGames] {BLUE}%N \x06użyl markera!", client);
		} else if (Opiekun(client)) {
			TraceEye(client, LastLaser[client]);
			LaserE[client] = true;
			CPrintToChatAll("\x0B[EverGames] \x0B%N \x06użyl markera!", client);
		} else if (Admin(client)) {
			TraceEye(client, LastLaser[client]);
			LaserE[client] = true;
			CPrintToChatAll("\x0B[EverGames] \x07%N \x05użyl markera!", client);
		} else if (VIP_Elite(client)) {
			TraceEye(client, LastLaser[client]);
			LaserE[client] = true;
			CPrintToChatAll("\x0B[EverGames] \x09%N \x06użyl markera!", client);
		} else if (VIP(client)) {
			TraceEye(client, LastLaser[client]);
			LaserE[client] = true;
			CPrintToChatAll("\x0B[EverGames] \x05%N \x06użyl markera!", client);
		} else if (JailBreak_IsCaptain(client)) {
			TraceEye(client, LastLaser[client]);
			LaserE[client] = true;
			CPrintToChatAll("\x0B[EverGames] \x06Strażnik \x03%N \x06użyl markera!", client);
		} else {
			CPrintToChat(client, "\x0B[EverGames] \x06Musisz mieć rangę \x04VIP \x06lub \x0FVIP Elite\x06 aby używac markera!");
		}
	}
	return Plugin_Handled;
}

public Action Command_EndLaster(int client, int args) 
{
	LastLaser[client][0] = 0.0;
	LastLaser[client][1] = 0.0;
	LastLaser[client][2] = 0.0;
	LaserE[client] = false;
	
	return Plugin_Handled;
}

public int TraceEye(int client, float pos[3]) 
{
	float vAngles[3], vOrigin[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	TR_TraceRayFilter(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	
	if(TR_DidHit(INVALID_HANDLE)) TR_GetEndPosition(pos, INVALID_HANDLE);
	
	return;
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask) 
{
	return (entity > GetMaxClients() || !entity);
}

stock void LaserP(float start[3], float end[3], int color[4]) 
{
	TE_SetupBeamPoints(start, end, g_iLaserSprite, 0, 0, 0, 25.0, 2.0, 2.0, 10, 0.0, color, 0);
	TE_SendToAll();
}
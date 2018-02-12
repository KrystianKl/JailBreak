#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Death Camera"

#define FFADE_IN		0x0001
#define FFADE_OUT		0x0002
#define FFADE_MODULATE	0x0004
#define FFADE_STAYOUT	0x0008
#define FFADE_PURGE		0x0010

int g_iClientCamera[MAXPLAYERS+1];

bool g_bRagdoll[MAXPLAYERS+1];

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
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("player_spawn", OnPlayerSpawn);
}

public Action OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsValidClient(client)) 
	{
		QueryClientConVar(client, "cl_ragdoll_physics_enable", view_as<ConVarQueryFinished>(ClientConVar), client);
		ClearCam(client);
	}
}

public Action PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsValidClient(client))
	{	
		if (g_bRagdoll[client])
		{
			int ragdoll = GetEntPropEnt(client, Prop_Send, "m_hRagdoll");
			
			if (ragdoll < 0)
				return Plugin_Continue;
			
			SpawnCamAndAttach(client, ragdoll);
		}
	}
	
	return Plugin_Continue;
}

public void ClientConVar(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue)
{
	g_bRagdoll[client] = (StringToInt(cvarValue) > 0) ? true : false;
}

public bool SpawnCamAndAttach(int client, int Ragdoll)
{
	char StrModel[64];
	Format(StrModel, sizeof(StrModel), "models/blackout.mdl");
	PrecacheModel(StrModel, true);
	
	char StrName[64]; 
	Format(StrName, sizeof(StrName), "fpd_Ragdoll%d", client);
	DispatchKeyValue(Ragdoll, "targetname", StrName);
	
	int Entity = CreateEntityByName("prop_dynamic");
	
	if (Entity == -1)
		return false;
	
	char StrEntityName[64]; Format(StrEntityName, sizeof(StrEntityName), "fpd_RagdollCam%d", Entity);
	
	DispatchKeyValue(Entity, "targetname", StrEntityName);
	DispatchKeyValue(Entity, "parentname", StrName);
	DispatchKeyValue(Entity, "model",	  StrModel);
	DispatchKeyValue(Entity, "solid",	  "0");
	DispatchKeyValue(Entity, "rendermode", "10");
	DispatchKeyValue(Entity, "disableshadows", "1");
	
	float angles[3]; 
	GetClientEyeAngles(client, angles);
	
	char CamTargetAngles[64];
	Format(CamTargetAngles, 64, "%f %f %f", angles[0], angles[1], angles[2]);
	DispatchKeyValue(Entity, "angles", CamTargetAngles); 
	
	SetEntityModel(Entity, StrModel);
	DispatchSpawn(Entity);
		
	SetVariantString(StrName);
	AcceptEntityInput(Entity, "SetParent", Entity, Entity, 0);
	
	SetVariantString("facemask");
	AcceptEntityInput(Entity, "SetParentAttachment", Entity, Entity, 0);
	
	AcceptEntityInput(Entity, "TurnOn");
	
	SetClientViewEntity(client, Entity);
	g_iClientCamera[client] = Entity;
	
	CreateTimer(3.0, ClearCamTimer, client);
	PerformFade(client, 1500, false);

	return true;
}

public Action ClearCamTimer(Handle timer, any client)
{
	ClearCam(client);
}

public void ClearCam(int client)
{
	if(IsValidClient(client) && g_iClientCamera[client])
	{
		PerformFade(client, 0, true);
		SetClientViewEntity(client, client);
		g_iClientCamera[client] = false;
	}
}

public bool ClientOk(int client)
{
	if (IsClientConnected(client) && IsClientInGame(client))
	{
		if (!IsFakeClient(client))
		{
			if (GetClientTeam(client) != 1)
			{	
				return true;
			}
		}
	}
	return false;
}

public bool PerformFade(any client, int duration, int in2)
{
	int color[4] = { 0, 0, 0, 255 }; 
	
	Handle message = StartMessageOne("Fade", client); 

	if (GetUserMessageType() == UM_Protobuf) 
	{ 
        PbSetInt(message, "duration", duration);
        PbSetInt(message, "hold_time", 0);
        if (in2) PbSetInt(message, "flags", (FFADE_PURGE|FFADE_IN)); 
        else PbSetInt(message, "flags", (FFADE_PURGE|FFADE_OUT|FFADE_STAYOUT)); 
        
        PbSetColor(message, "clr", color); 
	} else { 
        BfWriteShort(message,duration); 
        BfWriteShort(message,0); 
        
        if (in2) BfWriteShort(message, (FFADE_PURGE|FFADE_IN));
        else BfWriteShort(message, (FFADE_PURGE|FFADE_OUT|FFADE_STAYOUT));
        
        BfWriteShort(message, FFADE_IN|FFADE_PURGE); 
        BfWriteByte(message,color[0]); 
        BfWriteByte(message,color[1]); 
        BfWriteByte(message,color[2]); 
        BfWriteByte(message,color[3]); 
	} 

	EndMessage(); 
	return true;
}

stock bool IsEntNearWall(int ent)
{
	float vOrigin[3], vec[3], vAngles[3];
	Handle trace;
	
	GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", vOrigin);
	GetEntPropVector(ent, Prop_Data, "m_angAbsRotation", vAngles);
	
	trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_PLAYERSOLID, RayType_Infinite, TraceRayDontHitSelf, ent);   
	
	if (TR_DidHit(trace))
	{
		TR_GetEndPosition(vec, trace);
		if (GetVectorDistance(vec, vOrigin) < 40)
		{
			CloseHandle(trace);
			return true;
		}
	}
	
	CloseHandle(trace);
	return false;
}

public bool TraceRayDontHitSelf(int entity, int mask, any data)
{
	return (entity == data) ? false : true;
}
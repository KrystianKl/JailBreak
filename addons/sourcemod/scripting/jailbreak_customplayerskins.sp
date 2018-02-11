#pragma newdecls required
#pragma semicolon 1

#include <sdkhooks>
#include <CustomPlayerSkins>
#include <EverGames_JailBreak>

#define EF_BONEMERGE                (1 << 0)
#define EF_NOSHADOW                 (1 << 4)
#define EF_NORECEIVESHADOW          (1 << 6)
#define EF_PARENT_ANIMATES          (1 << 9)

#define CPS_NOFLAGS         0
#define CPS_RENDER          (1 << 0)
#define CPS_NOATTACHMENT    (1 << 1)
#define CPS_IGNOREDEATH     (1 << 2)
#define CPS_TRANSMIT        (1 << 3)

int g_PlayerModels[MAXPLAYERS+1] = {INVALID_ENT_REFERENCE,...};
int g_TransmitSkin[MAXPLAYERS+1][MAXPLAYERS+1];
int g_SkinFlags[MAXPLAYERS+1];


public Plugin myinfo = {
	name = "[EverGames] JailBreak - Custom Player Skins (Core)",
	author = "Mitchell, Root & Mrkl21full",
	description = "Natives for custom skins to be applied to the players.",
	version = "1.5",
	url = "EverGames.pl"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) 
{
	CreateNative("CPS_SetSkin", Native_SetSkin);
	CreateNative("CPS_GetSkin", Native_GetSkin);
	CreateNative("CPS_RemoveSkin", Native_RemoveSkin);
	CreateNative("CPS_HasSkin", Native_HasSkin);
	CreateNative("CPS_SetTransmit", Native_SetTransmit);
	
	RegPluginLibrary("CustomPlayerSkins");
	return APLRes_Success;
}

public void OnPluginStart() 
{
	HookEvent("player_death", Event_OnPlayerDeath);

	LoopValidClients(i)
		setTransmit(i, 0, 1);
}

public void OnMapStart() 
{
	SetCvar("sv_disable_immunity_alpha", "1");
}

public void OnPluginEnd() 
{
	LoopValidClients(i)
		RemoveSkin(i, CPS_NOFLAGS);
}

public int Native_SetSkin(Handle plugin, int args) 
{
	int client = GetNativeCell(1);
	int skin = INVALID_ENT_REFERENCE;
	
	if(IsValidClient(client) && IsPlayerAlive(client)) 
	{
		char sModel[PLATFORM_MAX_PATH];
		GetNativeString(2, sModel, PLATFORM_MAX_PATH);
		int flags = GetNativeCell(3);
		skin = CreatePlayerModelProp(client, sModel, flags);
	}
	
	return skin;
}

public int Native_GetSkin(Handle plugin, int args) {
	int client = GetNativeCell(1);

	if(IsValidClient(client))
		if(IsValidEntity(g_PlayerModels[client]))
			return EntRefToEntIndex(g_PlayerModels[client]);
	
	return INVALID_ENT_REFERENCE;
}

public int Native_HasSkin(Handle plugin, int args) 
{
	int client = GetNativeCell(1);
	
	return (IsValidClient(client) && IsValidEntity(g_PlayerModels[client])) ? true : false;
}

public int Native_RemoveSkin(Handle plugin, int args) 
{
	int client = GetNativeCell(1);
	
	if(IsValidClient(client)) 
	{
		int flags = CPS_NOFLAGS;
		
		if(args > 1) {
			flags = GetNativeCell(2);
		}
		
		RemoveSkin(client, flags);
	}
	
	return INVALID_ENT_REFERENCE;
}

public int Native_SetTransmit(Handle plugin, int args) 
{
	int owner = GetNativeCell(1);
	int client = GetNativeCell(2);
	int transmit = GetNativeCell(3);
	
	setTransmit(owner, client, transmit);
}

public int Native_GetFlags(Handle plugin, int args) 
{
	int client = GetNativeCell(1);
	
	return g_SkinFlags[client];
}

public Action Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast) 
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsClientInGame(client)) 
		if(!(g_SkinFlags[client] & CPS_IGNOREDEATH))
			RemoveSkin(client, CPS_RENDER);
}

public void setTransmit(int owner, int client, int transmit) 
{
	if(client <= 0) {
		for(int i = 1; i <= MaxClients; i++)
			setTransmit(owner, i, transmit);
	} else {
		g_TransmitSkin[owner][client] = transmit;
	}
}

public int CreatePlayerModelProp(int client, char[] sModel, int flags) 
{
	RemoveSkin(client, CPS_RENDER);
	int skin = CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(skin, "model", sModel);
	DispatchKeyValue(skin, "disablereceiveshadows", "1");
	DispatchKeyValue(skin, "disableshadows", "1");
	DispatchKeyValue(skin, "solid", "0");
	DispatchKeyValue(skin, "spawnflags", "256");
	SetEntProp(skin, Prop_Send, "m_CollisionGroup", 11);
	DispatchSpawn(skin);
	SetEntProp(skin, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW|EF_PARENT_ANIMATES);
	SetVariantString("!activator");
	AcceptEntityInput(skin, "SetParent", client, skin);
	
	if(!(flags & CPS_NOATTACHMENT)) {
		SetVariantString("primary");
		AcceptEntityInput(skin, "SetParentAttachment", skin, skin, 0);
	}
	
	if(!(flags & CPS_RENDER)) {
		SetEntityRenderColor(client, 255, 255, 255, 0);
		SetEntityRenderMode(client, RENDER_TRANSALPHA);
	}
	
	g_SkinFlags[client] = flags;
	g_PlayerModels[client] = EntIndexToEntRef(skin);
	
	if(!(flags & CPS_TRANSMIT)) {
		SDKHook(skin, SDKHook_SetTransmit, OnShouldDisplay);
	}
	
	setTransmit(client, client, 0);
	
	return skin;
}


public void RemoveSkin(int client, int flags) 
{
	if(IsValidEntity(g_PlayerModels[client]))
		AcceptEntityInput(g_PlayerModels[client], "Kill");
	
	if(!(flags & CPS_RENDER))
		SetEntityRenderMode(client, RENDER_NORMAL);
	
	g_PlayerModels[client] = INVALID_ENT_REFERENCE;
	g_SkinFlags[client] = CPS_NOFLAGS;
	
	setTransmit(client, 0, 1);
}

public Action OnShouldDisplay(int skin, int client) 
{
	for(int i = 1; i <= MaxClients; i++)
		if(skin == EntRefToEntIndex(g_PlayerModels[i])) {
			if(g_TransmitSkin[i][client] == 0)
				return Plugin_Handled;
			
			break;
		}
	
	int target = GetEntPropEnt(client, Prop_Send, "m_hObserverTarget");
	
	if((target > 0 && target <= MaxClients) && (skin == EntRefToEntIndex(g_PlayerModels[target]))) {
		return Plugin_Handled;
	}

	return Plugin_Continue;
}

stock void SetCvar(char[] cvar, char[] value) 
{
	ConVar convar = FindConVar(cvar);
	
	if(convar != null) {
		convar.SetString(value, true, false);
	}
}

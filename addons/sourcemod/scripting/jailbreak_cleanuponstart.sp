#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Floor Cleaner"

int g_iWeaponParent = -1;

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
	g_iWeaponParent = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	
	RegAdminCmd("sm_broom", Command_Manual, ADMFLAG_CHEATS);
	RegAdminCmd("sm_broomkit", Command_Kit, ADMFLAG_CHEATS);
	RegAdminCmd("sm_broomknife", Command_Knife, ADMFLAG_CHEATS);
}

public Action Command_Manual(int client, int args)
{
	int iMaxEnts = GetMaxEntities();
	char weapon[64];
	
	for (int i = GetMaxClients(); i < iMaxEnts; i++)
		if (IsValidEdict(i) && IsValidEntity(i)) {
			GetEdictClassname(i, weapon, sizeof(weapon));
			if ((StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1) && GetEntDataEnt2(i, g_iWeaponParent) == -1)
				RemoveEdict(i);
		}
	
	return Plugin_Continue;
}

public Action Command_Kit(int client, int args)
{
	int iMaxEnts = GetMaxEntities();
	char sClassName[64];
	
	for(int i = MaxClients; i < iMaxEnts; i++)
		if(IsValidEntity(i) && IsValidEdict(i) && GetEdictClassname(i, sClassName, sizeof(sClassName)) && StrEqual(sClassName, "weapon_healthshot") && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == -1)
			RemoveEdict(i);
}

public Action Command_Knife(int client, int args)
{
	int iMaxEnts = GetMaxEntities();
	char sClassName[64];
	
	for(int i = MaxClients; i < iMaxEnts; i++)
		if(IsValidEntity(i) && IsValidEdict(i) && GetEdictClassname(i, sClassName, sizeof(sClassName)) && StrEqual(sClassName, "weapon_knife") && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == -1)
			RemoveEdict(i);
}

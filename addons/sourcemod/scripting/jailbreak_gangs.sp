#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
#include <sourcecomms>
#include <EverGames_Gangs>
#include <EverGames_JailBreak>

#pragma newdecls optional
#include <regex>
#include <menu-stocks>

#include "gangs/_global.sp"
#include "gangs/_sqlconnect.sp"
#include "gangs/_sql.sp"
#include "gangs/_native.sp"
#include "gangs/_stock.sp"
#include "gangs/_shared.sp"
#include "gangs/_events.sp"

#include "gangs/gbank.sp"
#include "gangs/gcreate.sp"
#include "gangs/glist.sp"
#include "gangs/ghelp.sp"
#include "gangs/gleft.sp"
#include "gangs/gskills.sp"
#include "gangs/gmenu.sp"
#include "gangs/gdelete.sp"
#include "gangs/grename.sp"
#include "gangs/gchat.sp"
#include "gangs/gsettings.sp"
#include "gangs/gabort.sp"
#include "gangs/ginvite.sp"
#include "gangs/gmembers.sp"

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_hSQLConnected = CreateGlobalForward("Gangs_OnSQLConnected", ET_Ignore, Param_Cell);
	g_hGangCreated = CreateGlobalForward("Gangs_OnGangCreated", ET_Ignore, Param_Cell, Param_Cell);
	g_hGangLeft = CreateGlobalForward("Gangs_OnGangLeft", ET_Ignore, Param_String, Param_String, Param_Cell);
	g_hGangDelete = CreateGlobalForward("Gangs_OnGangDelete", ET_Ignore, Param_Cell, Param_Cell, Param_String);
	g_hGangRename = CreateGlobalForward("Gangs_OnGangRename", ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_String);
	g_hGangClientJoined = CreateGlobalForward("Gangs_OnClientJoined", ET_Ignore, Param_Cell, Param_Cell);
	g_hGangMute = CreateGlobalForward("Gangs_OnGangMute", ET_Ignore, Param_String, Param_String, Param_Cell, Param_Cell);	
	
	CreateNative("Gangs_IsClientInGang", Native_IsClientInGang);
	CreateNative("Gangs_GetClientLevel", Native_GetClientAccessLevel);
	CreateNative("Gangs_GetClientGang", Native_GetClientGang);
	CreateNative("Gangs_ClientLeftGang", Native_LeftClientGang);
	CreateNative("Gangs_CreateClientGang", Native_CreateClientGang);
	CreateNative("Gangs_DeleteClientGang", Native_DeleteClientGang);
	CreateNative("Gangs_OpenClientGang", Native_OpenClientGang);
	CreateNative("Gangs_RenameClientGang", Native_RenameClientGang);
	CreateNative("Gangs_GetRangName", Native_GetRangName);
	
	CreateNative("Gangs_GetName", Native_GetGangName);
	CreateNative("Gangs_GetPoints", Native_GetGangPoints);
	CreateNative("Gangs_GetCredits", Native_GetGangCredits);
	CreateNative("Gangs_AddPoints", Native_AddGangPoints);
	CreateNative("Gangs_AddCredits", Native_AddGangCredits);
	CreateNative("Gangs_RemovePoints", Native_RemoveGangPoints);
	CreateNative("Gangs_RemoveCredits", Native_RemoveGangCredits);
	CreateNative("Gangs_GetMaxMembers", Native_GetGangMaxMembers);
	CreateNative("Gangs_GetMembersCount", Native_GetGangMembersCount);
	CreateNative("Gangs_GetOnlinePlayers", Native_GetOnlinePlayerCount);
	
	RegPluginLibrary("gangs");
	
	return APLRes_Success;
}

public Plugin myinfo = 
{
	name = GANGS_NAME ... "Core",
	author = GANGS_AUTHOR,
	description = GANGS_DESCRIPTION,
	version = GANGS_VERSION,
	url = GANGS_URL
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegConsoleCmd("sm_gang", Command_Gang);
	RegConsoleCmd("sm_g", Command_GangChat);
	RegConsoleCmd("sm_ghelp", Command_GangHelp);
	RegConsoleCmd("sm_gwplac", Command_GangWplac);
	RegConsoleCmd("sm_gwyplac", Command_GangWyplac);
	RegConsoleCmd("sm_gfixcredits", Command_FIX);
	RegConsoleCmd("sm_gcreate", Command_CreateGang);
	RegConsoleCmd("sm_glist", Command_ListGang);
	RegConsoleCmd("sm_gleft", Command_LeftGang);
	RegConsoleCmd("sm_gdelete", Command_DeleteGang);
	RegConsoleCmd("sm_grename", Command_RenameGang);
	RegConsoleCmd("sm_gabort", Command_AbortGang);
	RegConsoleCmd("sm_ginvite", Command_InviteGang);
	
	AddCommandListener(Command_Say, "say");
	//AddCommandListener(Command_Say, "say2");
	AddCommandListener(Command_SayTeam, "say_team");
	
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_EndStart);
}

public void OnMapStart()
{
	ClearGangsArrays();
	Gangs_CheckGame();
	CreateGangsCache();
	SQLGangsConnect();
}

public void OnClientPutInServer(int client)
{
	if(GetClientAuthId(client, AuthId_SteamID64, g_sClientID[client], sizeof(g_sClientID[]))) {
		UpdateClientOnlineState(client, true);
		if(!IsFakeClient(client)) {
			SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
}

public void OnClientDisconnect(int client)
{
	char newname[MAX_NAME_LENGTH];
	
	GetClientName(client, newname, sizeof(newname));
	CheckName(client, newname);
	
	UpdateClientOnlineState(client, false);
	Format(g_sClientID[client], sizeof(g_sClientID[]), "0");
	
	if(!IsFakeClient(client)) {
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}
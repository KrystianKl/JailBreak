#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Jail Doors System"

int Guards = 0;
int GuardsAlive = 0;
int Prisoners = 0;
int PrisonersAlive = 0;

int g_iCaptain = -1;

char g_cCurrentDay[64] = "Nie wybrany";

Handle HudHandler;
Handle HudHandler1;
Handle HudHandler2;
Handle HudHandler3;
Handle HudHandler4;

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
	HookEvent("round_start", OnRoundStart);
	HookEvent("round_end", OnRoundEnd);
	HookEvent("player_death", OnPlayerDeath);
	
	HudHandler = CreateHudSynchronizer();
	HudHandler1 = CreateHudSynchronizer();
	HudHandler2 = CreateHudSynchronizer();
	HudHandler3 = CreateHudSynchronizer();
	HudHandler4 = CreateHudSynchronizer();
}

public Action OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	Guards = 0;
	GuardsAlive = 0;
	Prisoners = 0;
	PrisonersAlive = 0;
	
	g_cCurrentDay = "Nie wybrany";
	
	JailBreak_GetRound(g_cCurrentDay);
	
	if(StrContains(g_cCurrentDay, "Simon", false) != -1) {
		g_cCurrentDay = "Normalny";
	} else if(StrContains(g_cCurrentDay, "Freeday", false) != -1) {
		g_cCurrentDay = "Freeday";
	} else {
		g_cCurrentDay = "Nieznany";
	}
	
	LoopValidClients(i)
		ClearHud(i);
	
	CreateTimer(1.5, FixHud);
}

public Action OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	g_iCaptain = -1;
}

public Action FixHud(Handle Timer)
{
	LoopValidClients(i) {
		if(GetClientTeam(i) == CS_TEAM_CT) {
			Guards++;
			GuardsAlive++;
		} else if(GetClientTeam(i) == CS_TEAM_T) {
			Prisoners++;
			PrisonersAlive++;
		}
	}
	
	Refresh();
}

public Action OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetClientTeam(client) == CS_TEAM_CT) {
		GuardsAlive--;
	} else if(GetClientTeam(client) == CS_TEAM_T) {
		PrisonersAlive--;
	}
	
	Refresh();
}

public void JailBreak_OnCaptainSet(int client)
{
	g_iCaptain = client;
	
	Refresh();
}

void Refresh()
{	
	LoopValidClients(i)
	{
		SetHudTextParams(0.02, 0.02, 300.0, 0, 130, 240, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler, "EverGames.pl » JailBreak");
		if(StrEqual(g_cCurrentDay, "Normalny", false)) {
			if(g_iCaptain > 0) {
				SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i\n\n\nProwadzący: %N", GuardsAlive, Guards, g_iCaptain);
			} else {
				SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
				ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i\n\n\nProwadzący: Brak", GuardsAlive, Guards);
			}
		} else {
			SetHudTextParams(0.02, 0.05, 300.0, 0, 210, 255, 255, 0, 0.25, 0.5, 0.5);
			ShowSyncHudText(i, HudHandler2, "Strażników: %i/%i", GuardsAlive, Guards);
		}
		SetHudTextParams(0.140, 0.05, 300.0, 255, 255, 255, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler3, "|");
		SetHudTextParams(0.155, 0.05, 300.0, 220, 0, 0, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler4, "Więźniów: %i/%i", PrisonersAlive, Prisoners);
		SetHudTextParams(0.02, 0.08, 300.0, 0, 225, 40, 255, 0, 0.25, 0.5, 0.5);
		ShowSyncHudText(i, HudHandler1, "Dzień: %s", g_cCurrentDay);
	}
}

void ClearHud(int client)
{
	ClearSyncHud(client, HudHandler);
	ClearSyncHud(client, HudHandler1);
	ClearSyncHud(client, HudHandler2);
	ClearSyncHud(client, HudHandler3);
	ClearSyncHud(client, HudHandler4);
}
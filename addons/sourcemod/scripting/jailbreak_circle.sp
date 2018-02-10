#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Marker Circle"

bool g_bCanMarker[MAXPLAYERS + 1];
bool g_bMarkerSetup[MAXPLAYERS + 1];

int g_iBeamSprite = -1;
int g_iHaloSprite = -1;
int g_iColors[8][4] = 
{
	{255, 255, 255, 255},
	{255, 0, 0, 255},
	{20, 255, 20, 255},
	{0, 65, 255, 255},
	{255, 255, 0, 255},
	{0, 255, 255, 255},
	{255, 0, 255, 255},
	{255, 80, 0, 255}
};

char g_sColorNamesRed[64];
char g_sColorNamesBlue[64];
char g_sColorNamesGreen[64];
char g_sColorNamesOrange[64];
char g_sColorNamesMagenta[64];
char g_sColorNamesRainbow[64];
char g_sColorNamesYellow[64];
char g_sColorNamesCyan[64];
char g_sColorNamesWhite[64];
char g_sColorNames[8][64] ={{""}, {""}, {""}, {""}, {""}, {""}, {""}, {""}};

float g_fMarkerRadiusMin = 100.0;
float g_fMarkerRadiusMax = 500.0;
float g_fMarkerRangeMax = 1500.0;
float g_fMarkerArrowHeight = 90.0;
float g_fMarkerArrowLength = 20.0;
float g_fMarkerSetupStartOrigin[3];
float g_fMarkerSetupEndOrigin[3];
float g_fMarkerOrigin[8][3];
float g_fMarkerRadius[8];

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
	RegConsoleCmd("+beacons", Command_Beacons);
	RegConsoleCmd("-beacons", Command_Beacons);
	
	HookEvent("round_end", OnRoundEnd);
	
	CreateTimer(1.0, Timer_DrawMakers, _, TIMER_REPEAT);

	PrepareMarkerNames();
}

public void PrepareMarkerNames()
{
	Format(g_sColorNamesRed, sizeof(g_sColorNamesRed), "{darkred}Czerwony{default}", LANG_SERVER);
	Format(g_sColorNamesBlue, sizeof(g_sColorNamesBlue), "{blue}Niebieski{default}", LANG_SERVER);
	Format(g_sColorNamesGreen, sizeof(g_sColorNamesGreen), "{green}Zielony{default}", LANG_SERVER);
	Format(g_sColorNamesOrange, sizeof(g_sColorNamesOrange), "{lightred}Pomarańczowy{default}", LANG_SERVER);
	Format(g_sColorNamesMagenta, sizeof(g_sColorNamesMagenta), "{purple}Magenta{default}", LANG_SERVER);
	Format(g_sColorNamesYellow, sizeof(g_sColorNamesYellow), "{orange}Żółty{default}", LANG_SERVER);
	Format(g_sColorNamesWhite, sizeof(g_sColorNamesWhite), "{default}Biały{default}", LANG_SERVER);
	Format(g_sColorNamesCyan, sizeof(g_sColorNamesCyan), "{blue}Morski{default}", LANG_SERVER);
	Format(g_sColorNamesRainbow, sizeof(g_sColorNamesRainbow), "{lightgreen}Tęczowy{default}", LANG_SERVER);


	g_sColorNames[0] = g_sColorNamesWhite;
	g_sColorNames[1] = g_sColorNamesRed;
	g_sColorNames[3] = g_sColorNamesBlue;
	g_sColorNames[2] = g_sColorNamesGreen;
	g_sColorNames[7] = g_sColorNamesOrange;
	g_sColorNames[6] = g_sColorNamesMagenta;
	g_sColorNames[4] = g_sColorNamesYellow;
	g_sColorNames[5] = g_sColorNamesCyan;
}

public Action Command_Beacons(int client, int args)
{
	if(JailBreak_isRoundActive())
		return Plugin_Handled;
	
	if(!JailBreak_IsCaptain(client)) {
		CPrintToChat(client, "\x0B[EverGames] \x06Tylko prowadzący może tego użyć!");
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action OnRoundEnd(Handle:event, const String:name[], bool:dontBroadcast)
{
	RemoveAllMarkers();
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (buttons & IN_ATTACK2 && !JailBreak_isRoundActive())
	{
		if (JailBreak_IsCaptain(client)) 
		{
			char g_weaponName[32];
			GetActiveWeaponName(client, g_weaponName, sizeof(g_weaponName));
			
			if(isKnife(g_weaponName)) {
				if (!g_bMarkerSetup[client])
					GetClientAimTargetPos(client, g_fMarkerSetupStartOrigin);
				
				GetClientAimTargetPos(client, g_fMarkerSetupEndOrigin);
				
				float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
				
				if (radius > g_fMarkerRadiusMax)
					radius = g_fMarkerRadiusMax;
				else if (radius < g_fMarkerRadiusMin)
					radius = g_fMarkerRadiusMin;
				
				if (radius > 0)
				{
					TE_SetupBeamRingPoint(g_fMarkerSetupStartOrigin, radius, radius+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 0.1, 2.0, 0.0, {255, 255, 255, 255}, 10, 0);
					TE_SendToClient(client);
				}
				
				g_bMarkerSetup[client] = true;
			}
		}
	} else if (g_bMarkerSetup[client]) {
		MarkerMenu(client);
		g_bMarkerSetup[client] = false;
	}
}

public void OnMapEnd()
{
	RemoveAllMarkers();
}

public void OnMapStart()
{
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/glow01.vmt");
	
	RemoveAllMarkers();
}

stock void MarkerMenu(int client)
{
	if (!IsValidClient(client) || !JailBreak_IsCaptain(client)) {
		CPrintToChat(client, "\x0B[EverGames] \x06Tylko prowadzący może tego użyć!");
		return;
	}

	int marker = IsMarkerInRange(g_fMarkerSetupStartOrigin);
	
	if (marker != -1)
	{
		RemoveMarker(marker);
		CPrintToChat(client, "\x0B[EverGames] \x06Marker pomyślnie usunięty!");
		return;
	}

	float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
	
	if (radius <= 0.0)
	{
		RemoveMarker(marker);
		CPrintToChat(client, "\x0B[EverGames] \x06Źle ustawiony znacznik.");
		return;
	}

	float g_fPos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", g_fPos);

	float range = GetVectorDistance(g_fPos, g_fMarkerSetupStartOrigin);
	
	if (range > g_fMarkerRangeMax)
	{
		CPrintToChat(client, "\x0B[EverGames] \x06Poza zasięgiem.");
		return;
	}

	if (IsValidClient(client))
	{
		Menu menu = CreateMenu(Handle_MarkerMenu);
		char menuinfo[255];

		Format(menuinfo, sizeof(menuinfo), "EverGames.pl » Wybierz kolor", client);
		SetMenuTitle(menu, menuinfo);

		Format(menuinfo, sizeof(menuinfo), "Czerwony", client);
		AddMenuItem(menu, "1", menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "Niebieski", client);
		AddMenuItem(menu, "3", menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "Zielony", client);
		AddMenuItem(menu, "2", menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "Pomarańczowy", client);
		AddMenuItem(menu, "7", menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "Biały", client);
		AddMenuItem(menu, "0", menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "Morski", client);
		AddMenuItem(menu, "5", menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "Magenta", client);
		AddMenuItem(menu, "6", menuinfo);
		
		Format(menuinfo, sizeof(menuinfo), "Żółty", client);
		AddMenuItem(menu, "4", menuinfo);

		menu.Display(client, 20);
	}
}

public int Handle_MarkerMenu(Menu menu, MenuAction action, int client, int itemNum)
{
	if (!IsValidClient(client))
		return;

	if (!JailBreak_IsCaptain(client)) 
	{
		CPrintToChat(client, "\x0B[EverGames] \x06Tylko prowadzący może tego użyć!");
		return;
	}

	if (action == MenuAction_Select)
	{
		char info[32], info2[32];
		bool found = menu.GetItem(itemNum, info, sizeof(info), _, info2, sizeof(info2));
		int marker = StringToInt(info);

		if (found)
		{
			SetupMarker(marker);
			CPrintToChat(client, "\x0B[EverGames] \x06Marker pomyślnie ustawiony!");
			FakeClientCommand(client, "sm_simonmenu");
		}
	}
}

public Action Timer_DrawMakers(Handle timer, any data)
{
	if(!JailBreak_isRoundActive()) {
		Draw_Markers();
	}

	return Plugin_Continue;
}

public void Draw_Markers()
{
	int g_iWarden = -1;
	
	for (int iClient = 1; iClient <= MaxClients; iClient++)
		if(IsValidClient(iClient))
    		if(JailBreak_IsCaptain(iClient)) g_iWarden = iClient;
    
	if (g_iWarden == -1)
		return;

	for (int j = 0; j<8; j++)
	{
		if (g_fMarkerRadius[j] <= 0.0)
			continue;

		float fWardenOrigin[3];
		GetEntPropVector(g_iWarden, Prop_Send, "m_vecOrigin", fWardenOrigin);

		if (GetVectorDistance(fWardenOrigin, g_fMarkerOrigin[j]) > g_fMarkerRangeMax)
		{
			CPrintToChat(g_iWarden, "\x0B[EverGames]\x06 Marker jest za daleko!");
			RemoveMarker(j);
			continue;
		}

		for (int i = 1; i <= MaxClients; i++) if (IsValidClient(i))
		{
			TE_SetupBeamRingPoint(g_fMarkerOrigin[j], g_fMarkerRadius[j], g_fMarkerRadius[j]+0.1, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 2.0, 0.0, g_iColors[j], 10, 0);
			TE_SendToAll();

			float fStart[3];
			AddVectors(fStart, g_fMarkerOrigin[j], fStart);
			fStart[2] += g_fMarkerArrowHeight;

			float fEnd[3];
			AddVectors(fEnd, fStart, fEnd);
			fEnd[2] += g_fMarkerArrowLength;

			TE_SetupBeamPoints(fStart, fEnd, g_iBeamSprite, g_iHaloSprite, 0, 10, 1.0, 2.0, 16.0, 1, 0.0, g_iColors[j], 5);
			TE_SendToAll();
		}
	}
}

public void SetupMarker(int marker)
{
	g_fMarkerOrigin[marker][0] = g_fMarkerSetupStartOrigin[0];
	g_fMarkerOrigin[marker][1] = g_fMarkerSetupStartOrigin[1];
	g_fMarkerOrigin[marker][2] = g_fMarkerSetupStartOrigin[2];

	float radius = 2*GetVectorDistance(g_fMarkerSetupEndOrigin, g_fMarkerSetupStartOrigin);
	if (radius > g_fMarkerRadiusMax)
		radius = g_fMarkerRadiusMax;
	else if (radius < g_fMarkerRadiusMin)
		radius = g_fMarkerRadiusMin;
	g_fMarkerRadius[marker] = radius;
}

public int GetClientAimTargetPos(int client, float g_fPos[3]) 
{
	if (client < 1)
		return -1;

	float vAngles[3];float vOrigin[3];

	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);

	Handle trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceFilterAllEntities, client);

	TR_GetEndPosition(g_fPos, trace);
	g_fPos[2] += 5.0;

	int entity = TR_GetEntityIndex(trace);

	CloseHandle(trace);

	return entity;
}

public void RemoveMarker(int marker)
{
	if (marker != -1)
	{
		g_fMarkerRadius[marker] = 0.0;
	}
}

public void RemoveAllMarkers()
{
	for (int i = 0; i < 8; i++)
		RemoveMarker(i);
}

public  int IsMarkerInRange(float g_fPos[3])
{
	for (int i = 0; i < 8; i++)
	{
		if (g_fMarkerRadius[i] <= 0.0)
			continue;

		if (GetVectorDistance(g_fMarkerOrigin[i], g_fPos) < g_fMarkerRadius[i])
			return i;
	}
	return -1;
}

public bool isKnife(const char[] classname){

	if(StrContains(classname, "knife", false) != -1) { return true; }
	return false;
}

public bool TraceFilterAllEntities(int entity, int contentsMask, any client)
{
	if (entity == client)
		return false;

	if (entity > MaxClients)
		return false;

	if (!IsClientInGame(entity))
		return false;

	if (!IsPlayerAlive(entity))
		return false;

	return true;
}

stock GetActiveWeaponName(client, String:buffer[], size)
{
	new weapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");

	if (!IsValidEntity(weapon)) {
		return INVALID_ENT_REFERENCE;
	}

	if (weapon == INVALID_ENT_REFERENCE) {
		buffer[0] = '\0';
		return INVALID_ENT_REFERENCE;
	}

	GetEntPropString(weapon, Prop_Data, "m_iClassname", buffer, size);

	return weapon;
}
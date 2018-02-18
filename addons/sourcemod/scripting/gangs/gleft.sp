public Action Command_LeftGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	if (!g_bIsInGang[client]) {
		CPrintToChat(client, "\x0B[EverGames] \x06Aby to zrobić musisz być w gangu!");
		return Plugin_Handled;
	}
	
	ShowLeftGangMenu(client);
	
	return Plugin_Handled;
}

public int Native_LeftClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	RemovePlayerFromGang(g_sClientID[client]);
}

stock void ShowLeftGangMenu(int client)
{
	char sGang[64];
	
	Menu menu = new Menu(Menu_GangLeft);
	Format(sGang, sizeof(sGang), "EverGames.pl » Czy na pewno chcesz wyjść z: %s?", g_sGang[g_iClientGang[client]]);
	
	menu.SetTitle(sGang);
	menu.AddItem("yes", "Tak, jestem pewien!");
	menu.AddItem("no", "Nie, to była pomyłka...");
	menu.Display(client, 15);
}

public int Menu_GangLeft(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "yes", false))
		{
			RemovePlayerFromGang(g_sClientID[client]);
		}
		else if(StrEqual(sParam, "no", false))
		{
			CPrintToChat(client, "\x0B[EverGames]\x01 Okej, może innym razem.");
		}
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void RemovePlayerFromGang(const char[] communityid, bool kicked = false, int client = -1)
{
	char sName[MAX_NAME_LENGTH];
	int level = -1;
	int gangid = -1;
	bool bFound = false;
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(StrEqual(communityid, iGangMembers[sCommunityID]))
		{
			gangid = iGangMembers[iGangID];
			level = iGangMembers[iAccessLevel];
			
			strcopy(sName, sizeof(sName), iGangMembers[sPlayerN]);
			
			bFound = true;
			
			break;
		}
	}
	
	if(!bFound)
	{
		return;
	}
	
	if(level >= GANGS_LEADER)
	{
		CPrintToChat(client, "\x0B[EverGames] \x06Jako przywódca nie możesz wyjść z gangu!");
		return;
	}
	
	ErasePlayerArray(communityid);
	
	
	char sQuery[256];
	Format(sQuery, sizeof(sQuery), "DELETE FROM `jailbreak_gangs_members` WHERE `CommunityID` = '%s' AND `GangID` = '%d'", communityid, gangid);
	SQLQuery(sQuery);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int count = iGang[iMembers] - 1;
			g_aCacheGang.Set(i, count, view_as<int>(iMembers));

			Gangs_LogFile(_, DEBUG, "(RemoveClientFromGang) GangID: %d - Members: %d", gangid, count);

			break;
		}
	}
	
	if(!kicked)
	{
		CPrintToChatAll("\x0B[EverGames] \x07%s\x06 opuścił \x03%s\x06!", sName, g_sGang[gangid]); // TODO: Translation
		Gangs_LogFile(_, INFO, "\"%s\" left %s!", sName, g_sGang[gangid]); // TODO: Translation
	} else {
		CPrintToChatAll("\x0B[EverGames] \x07%s\x06 został wywalony z gangu \x03%s\x06 przez \x09%N\x06!", sName, g_sGang[g_iClientGang[client]], client); // TODO: Translation
		Gangs_LogFile(_, INFO, "\"%s\" was kicked from %s by %N!", sName, g_sGang[g_iClientGang[client]], client); // TODO: Translation
	}
	
	int target = FindClientByCommunityID(communityid);
	if(Gangs_IsClientValid(target))
	{
		g_bIsInGang[target] = false;
		g_iClientGang[target] = 0;
		g_iClientLevel[target] = GANGS_NONE;
		g_bClientMuted[target] = false;
	}
	
	Call_StartForward(g_hGangLeft);
	Call_PushString(communityid);
	Call_PushString(sName);
	Call_PushCell(gangid);
	Call_Finish();
}

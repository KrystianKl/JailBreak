stock void ShowMembers(int client, bool online = true)
{
	char sGang[32], sRang[18], sName[MAX_NAME_LENGTH];
	
	Menu menu = new Menu(Menu_GangMembers);
	Format(sGang, sizeof(sGang), "%s - Opcje zapraszania", g_sGang[g_iClientGang[client]]);
	menu.SetTitle(sGang);
	
	if(online)
	{
		int iGLevel = g_iClientLevel[client];
		
		if(iGLevel == GANGS_LEADER || iGLevel == GANGS_INVITER)
			menu.AddItem("invite", "Zaproś gracza");
		
		//menu.AddItem("offline", "Tryb offline");
	}
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(online)
		{
			if(!iGangMembers[bOnline])
				continue;
		}
		else
		{
			if(iGangMembers[bOnline])
				continue;
		}
		
		for (int j = GANGS_TRIAL; j <= GANGS_LEADER; j++)
			{
				if(iGangMembers[iAccessLevel] == j)
				{
					Gangs_GetRangName(j, sRang, sizeof(sRang));
					break;
				}
			}
	
		Format(sName, sizeof(sName), "[%s] %s", sRang, iGangMembers[sPlayerN]);
		
		if(StrEqual(g_sClientID[client], iGangMembers[sCommunityID]) || iGangMembers[iAccessLevel] == GANGS_LEADER || (g_iClientLevel[client] == GANGS_COLEADER && iGangMembers[iAccessLevel] < g_iClientLevel[client]))
			menu.AddItem("", sName, ITEMDRAW_DISABLED);
		else
			menu.AddItem(iGangMembers[sCommunityID], sName);
	}
	
	char sBuffer[32];
	IntToString(online, sBuffer, sizeof(sBuffer));
	
	PushMenuCell(menu, "bOnline", online);
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 15);
}

public int Menu_GangMembers(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "invite", false))
			ShowInvitePlayers(client);
		else if(StrEqual(sParam, "offline", false))
			ShowMembers(client, false);
		else
			ShowPlayerDetails(client, sParam);
	}
	if (action == MenuAction_Cancel)
	{
		bool online = view_as<bool>(GetMenuCell(menu, "bOnline"));
		
		if(param == MenuCancel_ExitBack)
		{
			if(online)
				OpenClientGang(client);
			else
				ShowMembers(client);
		}
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowPlayerDetails(int client, const char[] communityid)
{
	char sGang[MAX_NAME_LENGTH + 32], sRang[18], sName[MAX_NAME_LENGTH];
	int level = -1;
	bool muted = false;
	bool found = false;
	
	for (int i = 0; i < g_aCacheGangMembers.Length; i++)
	{
		int iGangMembers[Cache_Gangs_Members];
		g_aCacheGangMembers.GetArray(i, iGangMembers[0]);
		
		if(StrEqual(communityid, iGangMembers[sCommunityID]))
		{
			level = iGangMembers[iAccessLevel];
			muted = iGangMembers[bMuted];
			
			for (int j = GANGS_TRIAL; j <= GANGS_LEADER; j++)
			{
				if(level == j)
				{
					Gangs_GetRangName(j, sRang, sizeof(sRang));
					break;
				}
			}
			
			strcopy(sName, sizeof(sName), iGangMembers[sPlayerN]);
			
			found = true;
			
			break;
		}
	}
	
	if(!found)
	{
		CPrintToChat(client, "\x0B[EverGames] \x07Nie możemy znaleźć gracza z takim CommunityID...");
		ShowMembers(client);
		return;
	}
	
	Menu menu = new Menu(Menu_GangMembersManage);
	Format(sGang, sizeof(sGang), "%s - Zarządzanie użytkownikami\n%s - %s", g_sGang[g_iClientGang[client]], sName, sRang);
	menu.SetTitle(sGang);
	
	/*int newLevel = GANGS_NONE;
	
	if(level < GANGS_COLEADER)
	{
		char sUp[48];
		newLevel = level + 1;
		Gangs_GetRangName(newLevel, sUp, sizeof(sUp));
		Format(sUp, sizeof(sUp), "Awansuj do %s", sUp);
		menu.AddItem("promote", sUp);
	}
	else
		menu.AddItem("", "Brak dostępnych awansów", ITEMDRAW_DISABLED);
	
	if(level > GANGS_TRIAL)
	{
		char sDown[48];
		newLevel = level - 1;
		Gangs_GetRangName(newLevel, sDown, sizeof(sDown));
		Format(sDown, sizeof(sDown), "Zdegraduj do %s", sDown);
		menu.AddItem("demote", sDown);
	}
	else
		menu.AddItem("", "Brak dostępnych degradów", ITEMDRAW_DISABLED);*/
	
	int cLevel = Gangs_GetClientLevel(client);
	
	if(cLevel >= GANGS_COLEADER) {
		if(muted)
			menu.AddItem("unmute", "Usuń wycieszenie");
		else
			menu.AddItem("mute", "Wycisz");
		
		menu.AddItem("kick", "Wyrzuć");
	} else if(cLevel >= GANGS_SKILLER) {
		menu.AddItem("kick", "Wyrzuć");
	} else {
		menu.AddItem("none", "Nie masz uprawnień");
	}
		
	PushMenuString(menu, "targetID", communityid);
	PushMenuString(menu, "targetName", sName);
	
	//if(newLevel > GANGS_NONE)
	//	PushMenuCell(menu, "levelRank", newLevel);
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 15);
}

public int Menu_GangMembersManage(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		char sTarget[32], sName[MAX_NAME_LENGTH];
		GetMenuString(menu, "targetID", sTarget, sizeof(sTarget));
		GetMenuString(menu, "targetName", sName, sizeof(sName));
		
		if(StrEqual(sParam, "kick", false))
			RemovePlayerFromGang(sTarget, true, client);
		
		if(StrEqual(sParam, "mute", false))
			UpdateClientMuteState(sTarget, true);
		
		if(StrEqual(sParam, "unmute", false))
			UpdateClientMuteState(sTarget, false);
		
		int target = FindClientByCommunityID(sTarget);
		if(Gangs_IsClientValid(target))
			ShowMembers(client);
		else
			ShowMembers(client, false);
	}
	
	if (action == MenuAction_Cancel)
	{
		if(param == MenuCancel_ExitBack)
			ShowMembers(client);
	}
	
	if (action == MenuAction_End)
		delete menu;
}

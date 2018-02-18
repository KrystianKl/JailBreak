public Action Command_DeleteGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
		
	if (!g_bIsInGang[client])
	{
		CPrintToChat(client, "\x0B[EverGames] \x06Aby to zrobić musisz mieć gang!");
		return Plugin_Handled;
	}
	
	ShowDeleteGangMenu(client);
	
	return Plugin_Handled;
}

public int Native_DeleteClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	if (!Gangs_IsClientValid(client))
	{
		return;
	}
	
	DeleteGang(client, gangid);
}

stock void ShowDeleteGangMenu(int client)
{
	char sGang[64];
	
	Menu menu = new Menu(Menu_GangDelete);
	Format(sGang, sizeof(sGang), "EverGames.pl » Czy na pewno chcesz usunąć: %s?", g_sGang[g_iClientGang[client]]);
	
	menu.SetTitle(sGang);
	menu.AddItem("yes", "Tak, jestem pewien!");
	menu.AddItem("no", "Nie, to był mój błąd...");
	menu.Display(client, 15);
}

public int Menu_GangDelete(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "yes", false))
		{
			DeleteGang(client, g_iClientGang[client]);
		}
		else if(StrEqual(sParam, "no", false))
		{
			CPrintToChat(client, "\x0B[EverGames] \x06Okej, może innym razem.");
		}
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void DeleteGang(int client, int gangid)
{
	if (!g_bIsInGang[client])
	{
		CPrintToChat(client, "\x0B[EverGames] \x01Nie jesteś w gangu!");
		return;
	}
	
	if(g_iClientLevel[client] < GANGS_LEADER)
	{
		CPrintToChat(client, "\x0B[EverGames] \x01Tylko przywódca gangu może to zrobić!");
		return;
	}
	
	CPrintToChatAll("\x0B[EverGames] \x07%N \x06usunął \x03%s\x06!", client, g_sGang[gangid]);
	Gangs_LogFile(_, INFO, "\"%L\" deleted %s!", client, g_sGang[gangid]);
	
	LoopClients(i)
	{
		if(g_iClientGang[i] == gangid)
		{
			ErasePlayerArray(g_sClientID[i]);
			g_bIsInGang[i] = false;
			g_iClientGang[i] = 0;
			g_iClientLevel[i] = GANGS_NONE;
			g_bClientMuted[i] = false;
		}
	}
	
	DeleteGangEntries(gangid);
	
	Call_StartForward(g_hGangDelete);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_PushString(g_sGang[gangid]);
	Call_Finish();
}

stock void DeleteGangEntries(int gangid)
{
	char sQuery[256];
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `jailbreak_gangs` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `jailbreak_gangs_members` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	Format(sQuery, sizeof(sQuery), "DELETE FROM `jailbreak_gangs_skills` WHERE `GangID` = '%d'", gangid);
	SQLQuery(sQuery);
	
	RemoveGangFromArray(gangid);
}

stock void RemoveGangFromArray(int gangid)
{
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			g_aCacheGang.Erase(i);
			break;
		}
	}
}

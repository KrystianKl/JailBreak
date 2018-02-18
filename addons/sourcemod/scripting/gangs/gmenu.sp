public Action Command_Gang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	if(args > 0)
	{
		CReplyToCommand(client, "\x0B[EverGames] \x01Syntax: sm_gang");
		return Plugin_Handled;
	}
	
	OpenClientGang(client);
	
	return Plugin_Handled;
}

public int Native_OpenClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!Gangs_IsClientValid(client))
		return;
	
	OpenClientGang(client);
}

stock void OpenClientGang(int client)
{
	if (!g_bIsInGang[client])
	{
		CPrintToChat(client, "\x0B[EverGames] \x06Nie jesteś w gangu!");
		CPrintToChat(client, "\x0B[EverGames] \x06Jeżeli chcesz stwórz gang komendą:");
		CPrintToChat(client, "\x0B[EverGames] \x06- !gcreate <Nazwa>");
		return;
	}
	
	char sTitle[512], sPoints[32], sCredits[32], sOnline[32];
	
	int points = Gangs_GetPoints(g_iClientGang[client]);
	int credits = Gangs_GetCredits(g_iClientGang[client]);
	int online = Gangs_GetOnlinePlayers(g_iClientGang[client]);
	int members = Gangs_GetMembersCount(g_iClientGang[client]);
	int maxmembers = Gangs_GetMaxMembers(g_iClientGang[client]);
	
	Format(sPoints, sizeof(sPoints), "Punktów: %d", points);
	Format(sCredits, sizeof(sCredits), "Kredytów: %d", credits);
	Format(sOnline, sizeof(sOnline), "Online: %d/%d/%d", online, members, maxmembers);
	
	Format(sTitle, sizeof(sTitle), "%s - Główne Menu\n%s\n%s\n%s\n \n", g_sGang[g_iClientGang[client]], sPoints, sCredits, sOnline);
	
	Menu menu = new Menu(Menu_GangMenu);
	
	menu.SetTitle(sTitle);
	
	menu.AddItem("skills", "Umiejętności");
	menu.AddItem("members", "Zaproś graczy");
	
	if(g_iClientLevel[client] == GANGS_LEADER)
		menu.AddItem("settings", "Ustawienia");
	else
		menu.AddItem("leftgang", "Opuść Gang");
	
	menu.ExitButton = true;
	
	menu.Display(client, 15);
}

public int Menu_GangMenu(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "members", false))
			ShowInvitePlayers(client);
			
			//ShowMembers(client);
		
		if(StrEqual(sParam, "skills", false))
			ShowSkills(client);
		
		if(StrEqual(sParam, "settings", false))
			ShowSettings(client);
		
		if(StrEqual(sParam, "leftgang", false))
			ShowLeftGangMenu(client);
	}
	if (action == MenuAction_End)
		delete menu;
}

stock void ShowSettings(int client)
{
	char sGang[32];
	
	Menu menu = new Menu(Menu_GangSettings);
	Format(sGang, sizeof(sGang), "%s - Ustawienia", g_sGang[g_iClientGang[client]]);
	menu.SetTitle(sGang);
	
	if(!g_bInRename[client])
		menu.AddItem("rename", "Zmień Nazwę");
	else
		menu.AddItem("rename", "Zmień Nazwę (w trakcie)", ITEMDRAW_DISABLED);
	
	if(g_iClientLevel[client] == GANGS_LEADER)
		menu.AddItem("delete", "Usuń");
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 15);
}

public int Menu_GangSettings(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		
		if(StrEqual(sParam, "rename", false))
		{
			if(!g_bInRename[client])
				RenameGangMenu(client);
			else
				CPrintToChat(client, "\x0B[EverGames] \x06Proces aktualnie trwa!");
			
			ShowSettings(client);
		}
		else if(StrEqual(sParam, "delete", false))
			ShowDeleteGangMenu(client);
	}
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}
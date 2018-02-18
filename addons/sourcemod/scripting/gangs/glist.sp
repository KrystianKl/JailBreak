public Action Command_ListGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	Menu menu = new Menu(Menu_GangList);
	menu.SetTitle("EverGames.pl » Lista Gangów");
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		menu.AddItem("", iGang[sGangName], ITEMDRAW_DISABLED);
	}
	
	menu.ExitButton = true;
	menu.Display(client, 15);
	
	return Plugin_Handled;
}

public int Menu_GangList(Menu menu, MenuAction action, int client, int param)
{
	if(action == MenuAction_End)
		CloseHandle(menu);
}

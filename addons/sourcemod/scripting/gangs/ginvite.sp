stock void ShowInvitePlayers(int client)
{
	char sGang[32];
	
	Menu menu = new Menu(Menu_GangInvite);
	Format(sGang, sizeof(sGang), "%s - Zaproszenie", g_sGang[g_iClientGang[client]]);
	menu.SetTitle(sGang);
	
	char sUserID[12], sName[MAX_NAME_LENGTH];
	int iUserID = -1;
	
	int iCount = 0;
	
	LoopClients(i)
	{
		if(!g_bIsInGang[i] && g_iInvited[i] == -1)
		{
			iUserID = GetClientUserId(i);
			IntToString(iUserID, sUserID, sizeof(sUserID));
			GetClientName(i, sName, sizeof(sName));
			menu.AddItem(sUserID, sName);
			iCount++;
		}
	}
	
	if(iCount <= 0)
	{
		CPrintToChat(client, "\x0B[EverGames] \x06Nie ma graczy do zaproszenia!");
		ShowMembers(client);
		
		delete menu;
	}
	else
	{
		menu.ExitBackButton = true;
		menu.ExitButton = false;
		menu.Display(client, 15);
	}
}

public int Menu_GangInvite(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Select)
	{
		char sParam[32];
		menu.GetItem(param, sParam, sizeof(sParam));
		int target = GetClientOfUserId(StringToInt(sParam));
		
		if (Gangs_IsClientValid(target) )
		{
			InvitePlayer(client, target);
		}
		
		ShowMembers(client);
	}
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}

public Action Timer_InviteExpire(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if (Gangs_IsClientValid(client) && g_iInvited[client] > 0)
	{
		CPrintToChat(client, "\x0B[EverGames] \x06Zaproszenie do gangu \x03%s\x06 wygasło!", g_sGang[g_iInvited[client]]);
		CPrintToChatAll("\x0B[EverGames] \x07%N\x06 odrzucił zaproszenie do gangu \x03%s\x06!", client, g_sGang[g_iInvited[client]]);
		
		g_iInvited[client] = -1;
	}
	
	g_hInviteTimer[client] = null;
	return Plugin_Stop;
}

stock void AddClientToGang(int client, int gang)
{
	char sQuery[512], sName[MAX_NAME_LENGTH], sEName[MAX_NAME_LENGTH];
	
	GetClientName(client, sName, sizeof(sName));
	SQL_EscapeString(g_hDatabase, sName, sEName, sizeof(sEName));
	
	Format(sQuery, sizeof(sQuery), "INSERT INTO `jailbreak_gangs_members` (`GangID`, `CommunityID`, `PlayerName`, `AccessLevel`) VALUES ('%d', '%s', '%s', '1')", g_iInvited[client], g_sClientID[client], sEName);
	SQL_TQuery(g_hDatabase, SQL_InsertPlayer, sQuery, GetClientUserId(client));
}

public void SQL_InsertPlayer(Handle owner, Handle hndl, const char[] error, any userid)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
	
	int client = GetClientOfUserId(userid);
	
	if (!Gangs_IsClientValid(client) )
		return;
		
	g_bIsInGang[client] = true;
	g_iClientGang[client] = g_iInvited[client];
	g_iClientLevel[client] = GANGS_TRIAL;
	g_bClientMuted[client] = false;
	g_iInvited[client] = -1;
	
	CPrintToChatAll("\x0B[EverGames] \x07%N\x06 dołączył do gangu \x03%s\x06!", client, g_sGang[g_iClientGang[client]]);
	
	Gangs_LogFile(_, INFO, "\"%L\" joined the gang %s!", client, g_sGang[g_iClientGang[client]]);
	
	PushClientArray(client);
	
	Call_StartForward(g_hGangClientJoined);
	Call_PushCell(client);
	Call_PushCell(g_iClientGang[client]);
	Call_Finish();
}

stock void CloseInviteProcess(int client)
{
	if(g_hInviteTimer[client] != null)
		KillTimer(g_hInviteTimer[client]);
	
	g_hInviteTimer[client] = null;
	g_iInvited[client] = -1;
}

public Action Command_InviteGang(int client, int args)
{	
	char sTarget[MAX_NAME_LENGTH];
	GetCmdArgString(sTarget, sizeof(sTarget));
	
	int iTarget = FindTarget(client, sTarget);
			
	if (Gangs_IsClientValid(iTarget))
	{
		InvitePlayer(client, iTarget);
	}
	
	return Plugin_Continue;
}

stock void InvitePlayer(int client, int target)
{
	if (!g_bIsInGang[client]) {
		CPrintToChat(client, "\x0B[EverGames] \x06Aby to zrobić musisz być w gangu!");
	} else {
		int Kredyty = Gangs_GetCredits(Gangs_GetClientGang(client));
		
		if(Kredyty < 1200) {
			CPrintToChat(client, "\x04[EverGames] \x07===================================");
			CPrintToChat(client, "\x0B[EverGames]\x06 Nie masz 1200 kredytów w banku!");
			CPrintToChat(client, "\x0B[EverGames]\x06 Aby dodać kredyty do banu wpisz:");
			CPrintToChat(client, "\x0B[EverGames]\x07 » \x05/gwplac <ilość>");
			CPrintToChat(client, "\x04[EverGames] \x07===================================");
		} else {
			if(g_iInvited[target] > 0) {
				CPrintToChat(client, "\x0B[EverGames] \x06Już zaprosiłeś gracza: \x07%N\x06!", target);
			} else if (g_bIsInGang[target]) {
				CPrintToChat(client, "\x0B[EverGames] \x06Gracz \x07%N\x06 jest już w gangu!", target);
			} else {
				if(Gangs_GetClientLevel(client) > 2) {
					int LiczbaMax, Liczba;
					for (int i = 0; i < g_aCacheGang.Length; i++)
					{
						g_aCacheGang.GetArray(i, g_iCacheGang[0]);
					
						if(g_iCacheGang[iGangID] == Gangs_GetClientGang(client)) {
							LiczbaMax = g_iCacheGang[iMaxMembers];
							Liczba = g_iCacheGang[iMembers] + 1;
						}
					}
					
					if(Liczba > LiczbaMax) {
						CPrintToChat(client, "\x04[EverGames] \x07===================================");
						CPrintToChat(client, "\x0B[EverGames]\x06 Aby mieć więcej graczy w gangu,");
						CPrintToChat(client, "\x0B[EverGames]\x06 dokup większą ilość slotów w gangu!");
						CPrintToChat(client, "\x0B[EverGames]\x06 Aby to zrobić wejdź na stronę EverGames.pl,");
						CPrintToChat(client, "\x0B[EverGames]\x06 i zakup slot w Panelu Gangów");
						CPrintToChat(client, "\x04[EverGames] \x07===================================");
					} else {
						Gangs_RemoveCredits(Gangs_GetClientGang(client), 1200);
						
						char szQuery[512], CommunityID[64], sName[MAX_NAME_LENGTH], sEName[MAX_NAME_LENGTH];

						GetClientAuthId(client, AuthId_SteamID64, CommunityID, sizeof(CommunityID));
						GetClientName(client, sName, sizeof(sName));
						SQL_EscapeString(g_hDatabase, sName, sEName, sizeof(sEName));
			
						Format(szQuery, sizeof(szQuery), "INSERT INTO `jailbreak_gangs_trans` (GangID, CommunityID, PlayerName, Ilosc, Rodzaj, Time) VALUES ('%i', '%s', '%s', '1200', '2', '%i')", Gangs_GetClientGang(client), CommunityID, sEName, GetTime());
						SQLQuery(szQuery);
						
						float fTime = 30.0;
					
						g_iInvited[target] = g_iClientGang[client];
						
						CPrintToChat(client, "\x0B[EverGames] \x06Zaprosiłeś \x07%N\x06 do \x03%s\x06!", target, g_sGang[g_iClientGang[client]]);
						
						CPrintToChat(target, "\x0B[EverGames] \x07===================================");
						CPrintToChat(target, "\x0B[EverGames] \x06Otrzymałeś zaproszenie od: ");
						CPrintToChat(target, "\x0B[EverGames] \x02- \x07%N", client);
						CPrintToChat(target, "\x0B[EverGames] \x06do gangu: \x03%s!",g_sGang[g_iClientGang[client]]);
						CPrintToChat(target, "\x0B[EverGames] \x06Możesz przyjąć zaproszenie pisząc \"\x07accept\x06\"");
						CPrintToChat(target, "\x0B[EverGames] \x06lub odrzucić zaproszenie pisząc \"\x07decline\x06\"");
						CPrintToChat(target, "\x0B[EverGames] \x06lub zaczekać \x0730 sekund\x06 do jego wygaśnięcia.");
						CPrintToChat(target, "\x0B[EverGames] \x07===================================");
						
						g_hInviteTimer[target] = CreateTimer(fTime, Timer_InviteExpire, GetClientUserId(target));
					}
				} else {
					CPrintToChat(client, "\x0B[EverGames]\x06 Nie masz odpowiednich uprawnień!");
				}
			}
		}
	}
}

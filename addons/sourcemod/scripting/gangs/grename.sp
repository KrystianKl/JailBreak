public Action Command_RenameGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	if(args != 1)
	{
		CReplyToCommand(client, "\x0B[EverGames] \x01Syntax: sm_renamegang <Nazwa>");
		return Plugin_Handled;
	}
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	RenameGang(client, g_iClientGang[client], sArg);
	return Plugin_Handled;
}

public int Native_RenameClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int gangid = GetNativeCell(2);
	
	char sGang[64];
	GetNativeString(3, sGang, sizeof(sGang));
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	RenameGang(client, gangid, sGang);
}

stock bool CheckGangRename(int client, const char[] sGang)
{
	Handle hRegex = CompileRegex("^[a-zA-Z0-9]+$");
	
	if(MatchRegex(hRegex, sGang) != 1)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Zabronione znaki w nazwie!");
		return false;
	}
	
	if (strlen(sGang) < 3)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Nazwa gangu jest za krótka!");
		return false;
	}
	
	if (strlen(sGang) > 8)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Nazwa gangu jest za długa!");
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sGang, false))
		{
			CPrintToChat(client, "\x0B[EverGames]\x07 Podobny gang już istnieje!");
			return false;
		}
	}
	
	if(StrEqual(g_sGang[g_iClientGang[client]], sGang, false))
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Nazwa gangu musi być inna!");
		return false;
	}
	
	if(g_iClientLevel[client] < 5)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Nie masz uprawnień do tego!");
		return false;
	}
	
	if(Gangs_GetPoints(g_iClientGang[client]) < 2000)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Gang nie ma wystarczającej liczby kredytów!");
		return false;
	}
	return true;
}

stock void RenameGang(int client, int gangid, const char[] newgangname)
{
	if (!g_bIsInGang[client]) {
		CPrintToChat(client, "\x0B[EverGames] \x06Aby to zrobić musisz mieć gang!");
		return;
	}
	
	if(!CheckGangRename(client, newgangname))
		return;

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "UPDATE `jailbreak_gangs` SET `GangName` = '%s' WHERE `GangID` = '%d'", newgangname, gangid); // Add new table -> logs
	
	Handle hDP = CreateDataPack();
	WritePackCell(hDP, GetClientUserId(client));
	WritePackCell(hDP, gangid);
	WritePackString(hDP, g_sGang[gangid]);
	WritePackString(hDP, newgangname);
	SQL_TQuery(g_hDatabase, SQL_RenameGang, sQuery, hDP);
}

public void SQL_RenameGang(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_RenameGang) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char oldgangname[64], newgangname[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int gangid = ReadPackCell(pack);
	ReadPackString(pack, oldgangname, sizeof(oldgangname));
	ReadPackString(pack, newgangname, sizeof(newgangname));
	CloseHandle(pack);
	
	CPrintToChatAll("\x0B[EverGames] \x07%N\x06 zmienił nazwę \x03%s\x06 na\x03 %s\x06!", client, oldgangname, newgangname);
	Gangs_LogFile(_, INFO, "\"%L\" renamed %s to %s!", client, oldgangname, newgangname);
	
	Format(g_sGang[gangid], sizeof(g_sGang[]), "%s", newgangname);
	
	CloseRenameProcess(client);
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (iGang[iGangID] == gangid)
		{
			int itmpGang[Cache_Gang];
			
			itmpGang[iGangID] = iGang[iGangID];
			strcopy(itmpGang[sGangName], 64, newgangname);
			itmpGang[iPoints] = iGang[iPoints];
			itmpGang[bChat] = iGang[bChat];
			itmpGang[bPrefix] = iGang[bPrefix];
			strcopy(itmpGang[sPrefixColor], 64, iGang[sPrefixColor]);
			itmpGang[iMaxMembers] = iGang[iMaxMembers];
			itmpGang[iMembers] = iGang[iMembers];

			Gangs_LogFile(_, DEBUG, "(SQL_RenameGang) GangID: %d - OldGangName: %s - NewGangName: %s", gangid, oldgangname, newgangname);

			g_aCacheGang.Erase(i);
			g_aCacheGang.PushArray(itmpGang[0]);
			break;
		}
	}
	
	Call_StartForward(g_hGangRename);
	Call_PushCell(client);
	Call_PushCell(gangid);
	Call_PushString(oldgangname);
	Call_PushString(newgangname);
	Call_Finish();
}

stock void RenameGangMenu(int client)
{
	float fTime = 20.0;
	
	g_hRenameTimer[client] = CreateTimer(fTime, Timer_RenameEnd, GetClientUserId(client));
	g_bInRename[client] = true;
	
	CPrintToChat(client, "\x0B[EverGames] \x06Masz 20 sekund na wpisanie nowej nazwy gangu!");
	CPrintToChat(client, "\x0B[EverGames] \x06Nową nazwę gangu wpisz na czacie!");
}

public Action Timer_RenameEnd(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if (Gangs_IsClientValid(client) )
	{
		g_bInRename[client] = false;
		
		CPrintToChat(client, "\x0B[EverGames] \x06Czas na zmianę nazwy upłyną!");
	}
	
	g_hRenameTimer[client] = null;
	return Plugin_Stop;
}

stock void CloseRenameProcess(int client)
{
	if(g_hRenameTimer[client] != null)
		KillTimer(g_hRenameTimer[client]);
	
	g_hRenameTimer[client] = null;
	g_bInRename[client] = false;
}

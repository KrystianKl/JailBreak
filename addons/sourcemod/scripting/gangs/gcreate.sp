public Action Command_CreateGang(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	if(args < 1)
	{
		CPrintToChat(client, "\x0B[EverGames]\x01 Syntax: \x06sm_creategang <Nazwa>");
		return Plugin_Handled;
	}
	
	if(JailBreak_GetCredits(client) < 26000) {
		CPrintToChat(client, "\x0B[EverGames]\x01 Potrzebujesz 26 tyś kredytów, aby założyć gang!");
		return Plugin_Handled;
	} else {
		int Kredyty = JailBreak_GetCredits(client) - 26000;
		JailBreak_SetCredits(client, Kredyty);
	}
	
	char sArg[64];
	GetCmdArgString(sArg, sizeof(sArg));
	
	CreateGang(client, sArg);
	return Plugin_Handled;
}

public int Native_CreateClientGang(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	char sGang[64];
	GetNativeString(2, sGang, sizeof(sGang));
	
	CreateGang(client, sGang);
}

stock bool CheckGangName(int client, const char[] sArg)
{
	Handle hRegex = CompileRegex("^[a-zA-Z0-9]+$");
	
	if(MatchRegex(hRegex, sArg) != 1)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Zabronione znaki w nazwie!");
		return false;
	}
	
	if (strlen(sArg) < 3)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Nazwa gangu jest za krótka!");
		return false;
	}
	
	if (strlen(sArg) > 8)
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Nazwa gangu jest za długa!");
		return false;
	}
	
	for (int i = 0; i < g_aCacheGang.Length; i++)
	{
		int iGang[Cache_Gang];
		g_aCacheGang.GetArray(i, iGang[0]);

		if (StrEqual(iGang[sGangName], sArg, false))
		{
			CPrintToChat(client, "\x0B[EverGames]\x07 Podobny gang już istnieje!");
			return false;
		}
	}
	
	if(!CanCreateGang(client))
	{
		CReplyToCommand(client, "\x0B[EverGames]\x07 Aktualnie jesteś w gangu!");
		return false;
	}
	
	return true;
}

stock void CreateGang(int client, const char[] gang)
{
	if(!CheckGangName(client, gang))
	{
		CPrintToChat(client, "\x0B[EverGames]\x07 Tworzenie '%s' nie powiodło się!", gang);
		int Kredyty = JailBreak_GetCredits(client) + 26000;
		JailBreak_SetCredits(client, Kredyty);
		CPrintToChat(client, "\x0B[EverGames]\x01 Zwrócono 26k na Twoje konto.");
		return;
	}

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "INSERT INTO `jailbreak_gangs` (`GangName`) VALUES ('%s')", gang);

	Handle hDP = CreateDataPack();
	WritePackCell(hDP, GetClientUserId(client));
	WritePackString(hDP, gang);
	SQL_TQuery(g_hDatabase, SQL_CreateGang, sQuery, hDP);
}

public void SQL_CreateGang(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_CreateGang) Query failed: %s", error);
		CloseHandle(pack);
		return;
	}
		
	char sGang[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, sGang, sizeof(sGang));
	CloseHandle(pack);

	char sQuery[512];
	Format(sQuery, sizeof(sQuery), "SELECT GangID FROM `jailbreak_gangs` WHERE `GangName` ='%s'", sGang);
	
	Handle hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackString(hPack, sGang);
	SQL_TQuery(g_hDatabase, SQL_SaveClientGangID, sQuery, hPack, DBPrio_Low);
}

public void SQL_SaveClientGangID(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_SaveClientGangID) Query failed: %s", error);
		return;
	}
	
	char sGang[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	ReadPackString(pack, sGang, sizeof(sGang));
	CloseHandle(pack);

	if (!Gangs_IsClientValid(client) )
		return;
	
	if (hndl != null)
	{
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) > 0)
			{
				AddGangToArray(SQL_FetchInt(hndl, 0), sGang);
				Gangs_LogFile(_, INFO, "\"%L\" created %s!", client, sGang);
				g_iClientGang[client] = SQL_FetchInt(hndl, 0);
				AddOwnerToGang(client, g_iClientGang[client], sGang);
			}
			else
			{
				g_bIsInGang[client] = false;
				g_iClientGang[client] = 0;
				g_iClientLevel[client] = GANGS_NONE;
				g_bClientMuted[client] = false;
			}
		}
	}
}

stock void AddGangToArray(int GangID, const char[] sGang)
{
	int iGang[Cache_Gang];

	iGang[iGangID] = GangID;
	Format(iGang[sGangName], 64, "%s", sGang);
	iGang[iCredits] = 0;
	iGang[iPoints] = 0;
	iGang[bChat] = false;
	iGang[bPrefix] = false;
	Format(iGang[sPrefixColor], 64, "");
	iGang[iMaxMembers] = 2;
	iGang[iMembers] = 1;

	Gangs_LogFile(_, DEBUG, "[AddGangToArray] GangID: %d - GangName: %s - Credits: %d - Points: %d - Chat: %d - Prefix: %d - PrefixColor: %s - MaxMembers: %d", iGang[iGangID], iGang[sGangName], iGang[iCredits], iGang[iPoints], iGang[bChat], iGang[bPrefix], iGang[sPrefixColor], iGang[iMaxMembers]);

	g_aCacheGang.PushArray(iGang[0]);
}

stock void AddOwnerToGang(int client, int gang, const char[] sGang)
{
	char sQuery[512], sName[MAX_NAME_LENGTH], sEName[MAX_NAME_LENGTH];
	
	GetClientName(client, sName, sizeof(sName));
	SQL_EscapeString(g_hDatabase, sName, sEName, sizeof(sEName));
	
	Format(sQuery, sizeof(sQuery), "INSERT INTO `jailbreak_gangs_members` (`GangID`, `CommunityID`, `PlayerName`, `AccessLevel`) VALUES ('%d', '%s', '%s', '6')", gang, g_sClientID[client], sEName);
	
	Handle hPack = CreateDataPack();
	WritePackCell(hPack, GetClientUserId(client));
	WritePackCell(hPack, gang);
	WritePackString(hPack, sGang);
	
	SQL_TQuery(g_hDatabase, SQL_InsertOwner, sQuery, hPack);
}

public void SQL_InsertOwner(Handle owner, Handle hndl, const char[] error, any pack)
{
	if (error[0])
	{
		Gangs_LogFile(_, ERROR, "(SQL_Callback) Query failed: %s", error);
		return;
	}
	
	char sGang[64];

	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int GangID = ReadPackCell(pack);
	ReadPackString(pack, sGang, sizeof(sGang));
	CloseHandle(pack);
	
	if (!Gangs_IsClientValid(client) )
		return;
		
	g_bIsInGang[client] = true;
	g_iClientLevel[client] = GANGS_LEADER;
	g_bClientMuted[client] = false;
	
	if(g_iClientGang[client] < 1 && !g_bIsInGang[client])
	{
		CReplyToCommand(client, "\x0B[EverGames] \x01Błąd podczas tworzenia!");
		int Kredyty = JailBreak_GetCredits(client) + 26000;
		JailBreak_SetCredits(client, Kredyty);
		return;
	} else {
		char szQuery[512];
		
		Format(szQuery, sizeof(szQuery), "INSERT INTO `jailbreak_gangs_skills` (`GangID`, `SkillID`, `Level`) VALUES ('%i', '1', '0'), ('%i', '2', '0'), ('%i', '3', '0'), ('%i', '4', '0'), ('%i', '5', '0'), ('%i', '6', '1'), ('%i', '7', '1'), ('%i', '8', '1'), ('%i', '9', '0'), ('%i', '10', '0'), ('%i', '11', '1'), ('%i', '12', '30'), ('%i', '13', '100');", GangID, GangID, GangID, GangID, GangID, GangID, GangID, GangID, GangID, GangID, GangID, GangID, GangID);
		SQLQuery(szQuery);
	}
	
	CPrintToChatAll("\x0B[EverGames] \x07%N\x06 stworzył\x03 %s\x06!", client, sGang);
	
	FillGangsCache_GangID(g_iClientGang[client]);
	
	Gangs_LogFile(_, INFO, "\"%L\" created %s!", client, sGang);
	
	PushClientArray(client);
	
	Call_StartForward(g_hGangCreated);
	Call_PushCell(client);
	Call_PushCell(g_iClientGang[client]);
	Call_Finish();
}

public void TQuery_GangMembers(Handle owner, Handle hndl, const char[] error, any userid)
{
	int client = GetClientOfUserId(userid);
	
	if (!Gangs_IsClientValid(client) )
		return;
	
	if (hndl != null)
	{
		if (error[0])
		{
			Gangs_LogFile(_, ERROR, "(TQuery_GangMembers) Query failed: %s", error);
			return;
		}
		
		while(SQL_FetchRow(hndl))
		{
			if(SQL_FetchInt(hndl, 0) > 0)
			{
				int iGang[Cache_Gangs_Members];
				char sCName[MAX_NAME_LENGTH], sSName[MAX_NAME_LENGTH];
				GetClientName(client, sCName, sizeof(sCName));
				
				iGang[iGangID] = SQL_FetchInt(hndl, 0);
				SQL_FetchString(hndl, 1, iGang[sCommunityID], 64);
				SQL_FetchString(hndl, 2, sSName, sizeof(sSName));
				iGang[iAccessLevel] = SQL_FetchInt(hndl, 3);
				iGang[bMuted] = view_as<bool>(SQL_FetchInt(hndl, 4));
				iGang[bOnline] = true;
				
				// currentname != sqlname
				if(!StrEqual(sCName, sSName, true))
				{
					// Insert new name in cache
					strcopy(iGang[sPlayerN], MAX_NAME_LENGTH, sCName);
					
					// Update name in database
					char sQuery[512], sCEName[MAX_NAME_LENGTH];
					SQL_EscapeString(g_hDatabase, sCName, sCEName, sizeof(sCEName));
					Format(sQuery, sizeof(sQuery), "UPDATE `jailbreak_gangs_members` SET `PlayerName` = '%s' WHERE `CommunityID` = '%s'", sCEName, iGang[sCommunityID]);
					SQLQuery(sQuery);
				}
				else
					strcopy(iGang[sPlayerN], MAX_NAME_LENGTH, sSName);
				
				Gangs_LogFile(_, DEBUG, "[TQuery_GangMembers] GangID: %d - CommunityID: %s - PlayerName: %s - AccessLevel: %d", iGang[iGangID], iGang[sCommunityID], iGang[sPlayerN], iGang[iAccessLevel]);
	
				g_aCacheGangMembers.PushArray(iGang[0]);
				
				if(iGang[iGangID] > 0)
				{
					g_bIsInGang[client] = true;
					g_iClientGang[client] = iGang[iGangID];
					g_iClientLevel[client] = iGang[iAccessLevel];
					g_bClientMuted[client] = iGang[bMuted];
				}
			}
			else
				g_bIsInGang[client] = false;
		}
		SortADTArrayCustom(g_aCacheGangMembers, Sort_GangMembers);
	}
}

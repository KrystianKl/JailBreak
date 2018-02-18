public Action:Command_FIX(client, args)
{
	if(client == 0) {
		decl String:arg1[10];
		GetCmdArg(1, arg1, sizeof(arg1));

		new GangID = StringToInt(arg1);
		
		decl String:arg2[10];
		GetCmdArg(2, arg2, sizeof(arg2));

		new FIX = StringToInt(arg2);

		Gangs_RemoveCredits(GangID, FIX);
	}
}

public Action:Command_GangWplac(client, args)
{
	if (Gangs_IsClientInGang(client)) {		
		if(args < 1)
		{
			CReplyToCommand(client, "\x0B[EverGames] \x01Użycie: {blue}sm_gwplac <ilość>");
			return Plugin_Handled;
		}

		decl String:arg1[10];
		GetCmdArg(1, arg1, sizeof(arg1));

		new amount = StringToInt(arg1);
		
		if(JailBreak_GetCredits(client) < amount)
		{
			CPrintToChat(client, "\x0B[EverGames] \x06Masz za mało kredytów.");
			return Plugin_Handled;
		}
		
		if(amount <= 0)
		{
			CPrintToChat(client, "\x0B[EverGames] \x06Nie możesz wpłacić liczby ujemnej.");
			return Plugin_Handled;
		}
		
		int GangID = Gangs_GetClientGang(client);
		
		new AA = JailBreak_GetCredits(client) - amount;
		JailBreak_SetCredits(client, AA);
		Gangs_AddCredits(GangID, amount);
			
		CPrintToChat(client, "\x0B[EverGames] \x06Odebrano z konta: \x07%i\x06.", amount);
		CPrintToChat(client, "\x0B[EverGames] \x06Aktualna liczba kredytów: \x07%i\x06.", JailBreak_GetCredits(client));
		CPrintToChat(client, "\x0B[EverGames] \x06Kredytów w Banku: \x07%i\x06.", Gangs_GetCredits(GangID));
		
		char sQuery[512], CommunityID[64], sName[MAX_NAME_LENGTH], sEName[MAX_NAME_LENGTH];

		GetClientAuthId(client, AuthId_SteamID64, CommunityID, sizeof(CommunityID));
		GetClientName(client, sName, sizeof(sName));
		SQL_EscapeString(g_hDatabase, sName, sEName, sizeof(sEName));
		
		Format(sQuery, sizeof(sQuery), "INSERT INTO `jailbreak_gangs_trans` (`GangID`, `CommunityID`, `PlayerName`, `Ilosc`, `Rodzaj`, `Time`) VALUES ('%d', '%s', '%s', '%i', '0', '%i')", GangID, CommunityID, sEName, amount, GetTime());
		SQLQuery(sQuery);
		
		return Plugin_Handled;
	} else {
		CPrintToChat(client, "\x0B[EverGames]\x06 Musisz być w Gangu, aby użyć tej komendy.");
		return Plugin_Handled;
	}
}

public Action:Command_GangWyplac(client, args)
{
	if (Gangs_IsClientInGang(client)) {
		if(args < 1)
		{
			CReplyToCommand(client, "\x0B[EverGames] \x01Użycie: {blue}sm_gwyplac <ilość>");
			return Plugin_Handled;
		}

		decl String:arg1[10];
		GetCmdArg(1, arg1, sizeof(arg1));

		new amount = StringToInt(arg1);
		
		if(amount <= 0)
		{
			CPrintToChat(client, "\x0B[EverGames] \x06Nie możesz wypłacić liczby ujemnej.");
			return Plugin_Handled;
		}
		
		int GangID = Gangs_GetClientGang(client);
		
		if(Gangs_GetClientLevel(client) > 2)
		{
			if(Gangs_GetCredits(GangID) > amount) {				
				new AB = JailBreak_GetCredits(client) + amount;
				JailBreak_SetCredits(client, AB);
				Gangs_RemoveCredits(GangID, amount);
					
				CPrintToChat(client, "\x0B[EverGames] \x06Dodano do konta: \x07%i\x06.", amount);
				CPrintToChat(client, "\x0B[EverGames] \x06Aktualna liczba kredytów: \x07%i\x06.", JailBreak_GetCredits(client));
				CPrintToChat(client, "\x0B[EverGames] \x06Kredytów w Banku: \x07%i\x06.", Gangs_GetCredits(GangID));
				
				char sQuery[512], CommunityID[64], sName[MAX_NAME_LENGTH], sEName[MAX_NAME_LENGTH];

				GetClientAuthId(client, AuthId_SteamID64, CommunityID, sizeof(CommunityID));
				GetClientName(client, sName, sizeof(sName));
				SQL_EscapeString(g_hDatabase, sName, sEName, sizeof(sEName));
				
				Format(sQuery, sizeof(sQuery), "INSERT INTO `jailbreak_gangs_trans` (`GangID`, `CommunityID`, `PlayerName`, `Ilosc`, `Rodzaj`, `Time`) VALUES ('%d', '%s', '%s', '%i', '1', '%i')", GangID, CommunityID, sEName, amount, GetTime());
				SQLQuery(sQuery);
				
				return Plugin_Handled;
			} else {
				CPrintToChat(client, "\x0B[EverGames]\x06 Nie ma w Banku takiej ilości kredytów.");
				return Plugin_Handled;
			}
		} else {
			CPrintToChat(client, "\x0B[EverGames]\x06 Aby wypłacać kredyty z Gangu musisz mieć większą range w Gangu.");
			return Plugin_Handled;
		}
	} else {
		CPrintToChat(client, "\x0B[EverGames]\x06 Musisz być w Gangu, aby użyć tej komendy.");
		return Plugin_Handled;
	}
}
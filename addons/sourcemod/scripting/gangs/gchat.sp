public Action Command_GangChat(int client, int args)
{
	if(!g_bIsInGang[client]) {
		CPrintToChat(client, "\x0B[EverGames] \x06Musisz być w gangu, aby użyć tej komendy!");
		return Plugin_Handled;
	}
	
	decl String:sText[MAX_MESSAGE_LENGTH];
	GetCmdArgString(sText, sizeof(sText));
	StripQuotes(sText);
	
	LoopClients(i) {
		if(g_bIsInGang[i] && !g_bClientMuted[client] && g_iClientGang[i] == g_iClientGang[client] || (Owner(i) || Opiekun(i) || Admin(i))) {
			if(strlen(sText) > 2) {
				if(Owner(client)) {
					CPrintToChat(i, "{darkred}[G-%s]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", g_sGang[g_iClientGang[client]], client, sText);
				} else if(Opiekun(client)) {
					CPrintToChat(i, "{darkred}[G-%s]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", g_sGang[g_iClientGang[client]], client, sText);
				} else if(Admin(client)) {
					CPrintToChat(i, "{darkred}[G-%s]\x01[\x02Admin\x01]\x07 %N: \x01%s", g_sGang[g_iClientGang[client]], client, sText);
				} else if(VIP_Elite(client)) {
					CPrintToChat(i, "{darkred}[G-%s]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", g_sGang[g_iClientGang[client]], client, sText);
				} else if(VIP(client)) {
					CPrintToChat(i, "{darkred}[G-%s]\x01[\x04VIP\x01]\x05 %N: \x01%s", g_sGang[g_iClientGang[client]], client, sText);
				} else {
					CPrintToChat(i, "{darkred}[G-%s]\x01[\x03Gracz\x01] \x03%N: \x01%s", g_sGang[g_iClientGang[client]], client, sText);
				}
			}
		}
	}
	
	return Plugin_Handled;
}

public Action Command_Say(int client, const char[] command, int argc)
{
	if(IsChatTrigger() || (g_iInvited[client] <= 0 && !g_bInRename[client])) {
		decl String:sText[MAX_MESSAGE_LENGTH];
		GetCmdArgString(sText, sizeof(sText));
		StripQuotes(sText);
		
		if(client == 0) {
			CPrintToChatAll("Console: %s", sText);
			return Plugin_Handled;
		}
		
		for(int i = 0; i <= 15; i++) {
			if(sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '	' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '') {
				CPrintToChat(client, "\x02[EverGames]\x07 Zakaz pisania kolorowymi znaczkami!");
				return Plugin_Handled;
			}
		}
		
		if(sText[0] == '@' || (sText[0] == '@' && sText[1] == ' ') && sText[0] > 0) {
			if(Owner(client) || Opiekun(client) || Admin(client)) {
				ReplaceString(sText, sizeof(sText), "@", "");
				if(Owner(client)) {
					CPrintToChatAll("\x02[\x07*WSZYSCY*\x02]\x0b %N\x09: \x01%s", client, sText);
				} else {
					CPrintToChatAll("\x02[\x07*WSZYSCY*\x02]\x07 %N\x09: \x01%s", client, sText);
				}
			} else {
				CPrintToChat(client, "\x0B[EverGames]\x06 Nie masz uprawnień do pisania na tym czacie!");
			}
			return Plugin_Handled;
		}
		
		char sGangs[128], GangColor[64], GangName[64];
		
		if(Gangs_GetClientGang(client) && Gangs_IsClientInGang(client)) {
			for (int i = 0; i < g_aCacheGang.Length; i++)
			{
				g_aCacheGang.GetArray(i, g_iCacheGang[0]);
			
				if(g_iCacheGang[iGangID] == Gangs_GetClientGang(client)) {
					strcopy(GangColor, sizeof(GangColor), g_iCacheGang[sPrefixColor]);
					strcopy(GangName, sizeof(GangName), g_iCacheGang[sGangName]);
				}
			}
			Format(sGangs, sizeof(sGangs), "{%s}[%s]", GangColor, GangName);
		} else {
			Format(sGangs, sizeof(sGangs), "");
		}
		
		for (new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsFakeClient(i)) {
				if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT) {
					if(IsPlayerAlive(client)) {
						if(Owner(client)) {
							CPrintToChat(i, "%s\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
						} else if(Opiekun(client)) {
							CPrintToChat(i, "%s\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
						} else if(Admin(client)) {
							CPrintToChat(i, "%s\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
						} else if(VIP_Elite(client)) {
							CPrintToChat(i, "%s\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else if(VIP(client)) {
							CPrintToChat(i, "%s\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else {
							CPrintToChat(i, "%s\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
						}
					} else {
						if(Owner(client)) {
							CPrintToChat(i, "%s[*]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
						} else if(Opiekun(client)) {
							CPrintToChat(i, "%s[*]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
						} else if(Admin(client)) {
							CPrintToChat(i, "%s[*]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
						} else if(VIP_Elite(client)) {
							CPrintToChat(i, "%s[*]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else if(VIP(client)) {
							CPrintToChat(i, "%s[*]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else {
							CPrintToChat(i, "%s[*]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
						}
					}
				} else if(GetClientTeam(client) != CS_TEAM_T || GetClientTeam(client) != CS_TEAM_CT) {
					if(Owner(client)) {
						CPrintToChat(i, "%s[SPEC]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
					} else if(Opiekun(client)) {
						CPrintToChat(i, "%s[SPEC]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
					} else if(Admin(client)) {
						CPrintToChat(i, "%s[SPEC]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
					} else if(VIP_Elite(client)) {
						CPrintToChat(i, "%s[SPEC]\x01[\x09VIP Elitex01]\x05 %N: \x01%s", sGangs, client, sText);
					} else if(VIP(client)) {
						CPrintToChat(i, "%s[SPEC]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else {
						CPrintToChat(i, "%s[SPEC]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
					}
				}
			}
		}
		
		new GAG = bNot:SourceComms_GetClientGagType(client);

		if(GAG) {
			CPrintToChat(client, "\x02[EverGames]\x07 Aktualnie masz blokadę na czat!");
			CPrintToChat(client, "\x02[EverGames]\x07 Prośbe o ungaga napisz na forum!");
			return Plugin_Handled;
		}
		
		if(sText[0] != '@' && sText[0] != '/' && sText[0] != '!' && sText[0] > 0) {
			if(GetClientTeam(client) == CS_TEAM_T || GetClientTeam(client) == CS_TEAM_CT) {
				if(IsPlayerAlive(client)) {
					if(Owner(client)) {
						CPrintToChatAll("%s\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
					} else if(Opiekun(client)) {
						CPrintToChatAll("%s\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
					} else if(Admin(client)) {
						CPrintToChatAll("%s\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
					} else if(VIP_Elite(client)) {
						CPrintToChatAll("%s\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else if(VIP(client)) {
						CPrintToChatAll("%s\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else {
						CPrintToChatAll("%s\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
					}
				} else {
					if(Owner(client)) {
						CPrintToChatAll("%s[*]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
					} else if(Opiekun(client)) {
						CPrintToChatAll("%s[*]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
					} else if(Admin(client)) {
						CPrintToChatAll("%s[*]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
					} else if(VIP_Elite(client)) {
						CPrintToChatAll("%s[*]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else if(VIP(client)) {
						CPrintToChatAll("%s[*]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else {
						CPrintToChatAll("%s[*]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
					}
				}
			} else if(GetClientTeam(client) != CS_TEAM_T || GetClientTeam(client) != CS_TEAM_CT) {
				if(Owner(client)) {
					CPrintToChatAll("%s[SPEC]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
				} else if(Opiekun(client)) {
					CPrintToChatAll("%s[SPEC]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
				} else if(Admin(client)) {
					CPrintToChatAll("%s[SPEC]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
				} else if(VIP_Elite(client)) {
					CPrintToChatAll("%s[SPEC]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
				} else if(VIP(client)) {
					CPrintToChatAll("%s[SPEC]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
				} else {
					CPrintToChatAll("%s[SPEC]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
				}
			}
			return Plugin_Handled;
		} else if(sText[0] == 0 || sText[0] == ' ') {
			CPrintToChat(client, "\x0B[EverGames] \x06Wprowadź wiadomość do napisania!");
			return Plugin_Handled;
		}
		return Plugin_Handled;
	} else if(g_iInvited[client] > 0) {
		char sMessage[12];
		GetCmdArgString(sMessage, sizeof(sMessage));
		StripQuotes(sMessage);
		
		if(StrEqual(sMessage, "accept", false)) {
			AddClientToGang(client, g_iInvited[client]);
			return Plugin_Handled;
		} else if(StrEqual(sMessage, "decline", false)) {
			Command_AbortGang(client, 0);
			CPrintToChatAll("\x0B[EverGames] \x03%N\x06 odrzucił zaproszenie do gangu \x07%s\x06!", client, g_sGang[g_iInvited[client]]);
			return Plugin_Handled;
		}
		else
			return Plugin_Continue;
	} else if (g_bInRename[client]) {
		int iLength = 8 + 1;
		char[] sNewName = new char[iLength];
		
		GetCmdArgString(sNewName, iLength);
		StripQuotes(sNewName);
		
		if(CheckGangRename(client, sNewName))
		{
			RenameGang(client, g_iClientGang[client], sNewName);
			ShowSettings(client);
			CloseRenameProcess(client);
		}
		
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

public Action Command_SayTeam(int client, const char[] command, int argc)
{
	decl String:sText[MAX_MESSAGE_LENGTH];
	GetCmdArgString(sText, sizeof(sText));
	StripQuotes(sText);
	
	new GAG = bNot:SourceComms_GetClientGagType(client);

	if(GAG) {
		CPrintToChat(client, "\x02[EverGames]\x07 Aktualnie masz blokadę na czat!");
		CPrintToChat(client, "\x02[EverGames]\x07 Prośbe o ungaga napisz na forum!");
		return Plugin_Handled;
	}
	
	if(client == 0) {
		CPrintToChatAll("Console: %s", sText);
		return Plugin_Handled;
	}
	
	for(int i=0; i<=15; i++) {
		if(sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '	' || sText[i] == '' || sText[i] == '' || sText[i] == '' || sText[i] == '') {
			CPrintToChat(client, "\x04[EverGames]\x06 Zakaz pisania kolorowymi znaczkami.");
			return Plugin_Handled;
		}
	}
	
	if(sText[0] == '@' || (sText[0] == '@' && sText[1] == ' ') && sText[0] > 0) {
		ReplaceString(sText, sizeof(sText), "@", "");
		if(!Owner(client) && !Opiekun(client) && !Admin(client)) {
			CPrintToChat(client, "\x02[\x07*DO ADMINÓW*\x02]\x03 %N: \x01%s", client, sText);
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i)) {
				if(Owner(i) || Opiekun(i) || Admin(i)) {
					if(Owner(client)) {
						CPrintToChat(i, "\x02[\x07*ADMIN*\x02]\x0b %N\x09: \x01%s", client, sText);
					} else if(Opiekun(client)) {
						CPrintToChat(i, "\x02[\x07*ADMIN*\x02]\x07 %N\x09: \x01%s", client, sText);
					} else if(Admin(client)) {
						CPrintToChat(i, "\x02[\x07*ADMIN*\x02]\x07 %N\x09: \x01%s", client, sText);
					} else {
						CPrintToChat(i, "\x02[\x07*DO ADMINÓW*\x02]\x03 %N: \x01%s", client, sText);
					}
				}
			}
		}
		return Plugin_Handled;
	}

	char sGangs[128], GangColor[64], GangName[64];
		
	if(Gangs_GetClientGang(client) && Gangs_IsClientInGang(client)) {
		for (int i = 0; i < g_aCacheGang.Length; i++)
		{
			g_aCacheGang.GetArray(i, g_iCacheGang[0]);
		
			if(g_iCacheGang[iGangID] == Gangs_GetClientGang(client)) {
				strcopy(GangColor, sizeof(GangColor), g_iCacheGang[sPrefixColor]);
				strcopy(GangName, sizeof(GangName), g_iCacheGang[sGangName]);
			}
		}
		Format(sGangs, sizeof(sGangs), "{%s}[%s]", GangColor, GangName);
	} else {
		Format(sGangs, sizeof(sGangs), "");
	}
		
	for (new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i)) {
			if(GetClientTeam(client) == CS_TEAM_T) {
				if(IsPlayerAlive(client)) {
					if(Owner(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
					} else if(Opiekun(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
					} else if(Admin(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
					} else if(VIP_Elite(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else if(VIP(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else {
						CPrintToChat(i, "\x0F[W]\x01%s\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
					}
				} else {
					if(Owner(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s[*]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
					} else if(Opiekun(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s[*]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
					} else if(Admin(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
					} else if(VIP_Elite(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else if(VIP(client)) {
						CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else {
						CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
					}
				}
			} else if(GetClientTeam(client) == CS_TEAM_CT) {
				if(IsPlayerAlive(client)) {
					if(Owner(client)) {
						CPrintToChat(i, "\x0B[S]\x01%s\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
					} else if(Opiekun(client)) {
						CPrintToChat(i, "\x0B[S]%s\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
					} else if(Admin(client)) {
						CPrintToChat(i, "\x0B[S]%s\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
					} else if(VIP_Elite(client)) {
						CPrintToChat(i, "\x0B[S]%s\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else if(VIP(client)) {
						CPrintToChat(i, "\x0B[S]%s\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else {
						CPrintToChat(i, "\x0B[S]%s\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
					}
				} else {
					if(Owner(client)) {
						CPrintToChat(i, "\x0B[S]%s[*]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
					} else if(Opiekun(client)) {
						CPrintToChat(i, "\x0B[S]%s[*]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
					} else if(Admin(client)) {
						CPrintToChat(i, "\x0B[S]%s[*]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
					} else if(VIP_Elite(client)) {
						CPrintToChat(i, "\x0B[S]%s[*]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else if(VIP(client)) {
						CPrintToChat(i, "\x0B[S]%s[*]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
					} else {
						CPrintToChat(i, "\x0B[S]%s[*]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
					}
				}
			}
		}
	}
		
	if(sText[0] != '@' && sText[0] != '/' && sText[0] != '!' && sText[0] > 0) {
		for (new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && !IsFakeClient(i)) {
				if(GetClientTeam(client) == CS_TEAM_T && (GetClientTeam(i) == CS_TEAM_T || Owner(client) || Opiekun(client) || Admin(client))) {
					if(IsPlayerAlive(client)) {
						if(Owner(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
						} else if(Opiekun(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
						} else if(Admin(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
						} else if(VIP_Elite(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else if(VIP(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else {
							CPrintToChat(i, "\x0F[W]\x01%s\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
						}
					} else {
						if(Owner(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s[*]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
						} else if(Opiekun(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s[*]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
						} else if(Admin(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
						} else if(VIP_Elite(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else if(VIP(client)) {
							CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else {
							CPrintToChat(i, "\x0F[W]\x01%s[*]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
						}
					}
				} else if(GetClientTeam(client) == CS_TEAM_CT && (GetClientTeam(i) == CS_TEAM_CT || Owner(client) || Opiekun(client) || Admin(client))) {
					if(IsPlayerAlive(client)) {
						if(Owner(client)) {
							CPrintToChat(i, "\x0B[S]\x01%s\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
						} else if(Opiekun(client)) {
							CPrintToChat(i, "\x0B[S]%s\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
						} else if(Admin(client)) {
							CPrintToChat(i, "\x0B[S]%s\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
						} else if(VIP_Elite(client)) {
							CPrintToChat(i, "\x0B[S]%s\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else if(VIP(client)) {
							CPrintToChat(i, "\x0B[S]%s\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else {
							CPrintToChat(i, "\x0B[S]%s\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
						}
					} else {
						if(Owner(client)) {
							CPrintToChat(i, "\x0B[S]%s[*]\x04[\x07Właściciel\x04]\x0b %N\x09: \x01%s", sGangs, client, sText);
						} else if(Opiekun(client)) {
							CPrintToChat(i, "\x0B[S]%s[*]\x02[\x0FOpiekun\x02]\x0B %N: \x01%s", sGangs, client, sText);
						} else if(Admin(client)) {
							CPrintToChat(i, "\x0B[S]%s[*]\x01[\x02Admin\x01]\x07 %N: \x01%s", sGangs, client, sText);
						} else if(VIP_Elite(client)) {
							CPrintToChat(i, "\x0B[S]%s[*]\x01[\x09VIP Elite\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else if(VIP(client)) {
							CPrintToChat(i, "\x0B[S]%s[*]\x01[\x04VIP\x01]\x05 %N: \x01%s", sGangs, client, sText);
						} else {
							CPrintToChat(i, "\x0B[S]%s[*]\x01[\x03Gracz\x01] \x03%N: \x01%s", sGangs, client, sText);
						}
					}
				}
			}
		}
		return Plugin_Handled;
	} else if(sText[0] == 0 || sText[0] == ' ') {
		CPrintToChat(client, "\x0B[EverGames] \x06Wprowadź wiadomość do napisania!");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

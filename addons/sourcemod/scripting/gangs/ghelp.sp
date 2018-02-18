public Action Command_GangHelp(int client, int args)
{
	if (!Gangs_IsClientValid(client) )
		return Plugin_Handled;
	
	CPrintToChat(client, "\x07============== {blue}[EverGames - Gangs] \x07 ==============");
	CPrintToChat(client, "\x02- \x04!gang \x07-\x06 Menu gangu");
	CPrintToChat(client, "\x02- \x04!gcreate <nazwa> \x07-\x06 Stworzenie gangu (26K kredytów)");
	CPrintToChat(client, "\x02- \x04!g <wiadomość> \x07-\x06 Prywatny czat gangu");
	CPrintToChat(client, "\x02- \x04!gwplac <ilość> \x07-\x06 Wpłacanie kredytów do banku");
	CPrintToChat(client, "\x02- \x04!gwyplac <ilość> \x07-\x06 Wypłacenie kredytów z banku");
	CPrintToChat(client, "\x02- \x04!glist \x07-\x06 Lista gangów");
	CPrintToChat(client, "\x07============== {blue}[EverGames - Gangs] \x07 ==============");
	
	return Plugin_Handled;
}

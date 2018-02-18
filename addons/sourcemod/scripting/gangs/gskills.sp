stock void ShowSkills(int client)
{
	char sGang[42];
	int count = 0;
	char sSkillLVL[64], sSkillID[12];
	int iGangGangSkills[Cache_Gangs_Skills];
	
	Menu menu = new Menu(Menu_GangSkillList);
	Format(sGang, sizeof(sGang), "%s - Umiejętności | Level", g_sGang[g_iClientGang[client]]);
	menu.SetTitle(sGang);
	for (int i = 0; i < g_aCacheGangSkills.Length; i++)
	{
		g_aCacheGangSkills.GetArray(i, iGangGangSkills[0]);
		
		if(iGangGangSkills[iSkillID] > 0)
		{
			count++;
			if(count == 1) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Zastrzyk Wzmacniający - %d/1", iGangGangSkills[iLevel]);
			} else if(count == 2) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Dodatkowe HP - %d/10", iGangGangSkills[iLevel]);
			} else if(count == 3) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Dodatkowa Prędkość - %d/5", iGangGangSkills[iLevel]);
			} else if(count == 4) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Mniejsza Grawitacja - %d/8", iGangGangSkills[iLevel]);
			} else if(count == 5) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Kolor podczas zabaw - %d/10", iGangGangSkills[iLevel]);
			} else if(count == 6) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Zasięg granata - %d/6", iGangGangSkills[iLevel]);
			} else if(count == 7) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Obrażenia granata - %d/6", iGangGangSkills[iLevel]);
			} else if(count == 8) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Większe obrażęnia - (Wyłączone)");
			} else if(count == 9) {
				if(iGangGangSkills[iLevel] == 1) {
					Format(sSkillLVL, sizeof(sSkillLVL), "Reinkarnacja - Włączona");
				} else {
					Format(sSkillLVL, sizeof(sSkillLVL), "Reinkarnacja - Wyłączona");
				}
			} else if(count == 10) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Regeneracja HP - %d/1", iGangGangSkills[iLevel]);
			} else if(count == 11) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Ilość regenerowanego HP - %d HP", iGangGangSkills[iLevel]);
			} else if(count == 12) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Co ile regenować HP - co %d sekund", iGangGangSkills[iLevel]);
			} else if(count == 13) {
				Format(sSkillLVL, sizeof(sSkillLVL), "Do ilu HP regenerować - do %d HP", iGangGangSkills[iLevel]);
			}
			Format(sSkillID, sizeof(sSkillID), "%d", iGangGangSkills[iSkillID]);
			menu.AddItem(sSkillID, sSkillLVL);
		}
	}

	if(count == 0)
	{
		menu.AddItem("noskill", "Brak umiejętności gangu!", ITEMDRAW_DISABLED);
	}
	
	menu.ExitBackButton = true;
	menu.ExitButton = false;
	menu.Display(client, 15);
}

public int Menu_GangSkillList(Menu menu, MenuAction action, int client, int param)
{
	if (action == MenuAction_Cancel)
		if(param == MenuCancel_ExitBack)
			OpenClientGang(client);
	if (action == MenuAction_End)
		delete menu;
}

#pragma newdecls required
#pragma semicolon 1

#include <clientprefs>
#include <fpvm_interface>
#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - CKM"

int iIronPickaxeView,
	iIronPickaxeWorld,
	iDiamondPickaxeView,
	iDiamondPickaxeWorld,
	iIronSwordView,
	iIronSwordWorld,
	iDiamondSwordView,
	iDiamondSwordWorld,
	iIronAxeView,
	iIronAxeWorld,
	iDiamondAxeView,
	iDiamondAxeWorld,
	iScrewdriverView, 
	iScrewdriverWorld,
	iBlueScrewdriverView,
	iBlueScrewdriverWorld;

int KnifeSelection[MAXPLAYERS+1];

Handle g_hMySelectionK;

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = JB_PLUGIN_AUTHOR,
	description = JB_PLUGIN_DESCRIPTION,
	version = JB_PLUGIN_VERSION,
	url = JB_PLUGIN_URL
};


public void OnPluginStart()
{	
	RegConsoleCmd("sm_fgsktKL21", CMD_CustomKnive, "- skg ~Mrkl21full");
	RegConsoleCmd("sm_fgsrtKL21", CMD_RestartCustom, "- srg ~Mrkl21full");
	
	g_hMySelectionK = RegClientCookie("KnifeModel", "KnifeModel", CookieAccess_Protected);
	
	LoopValidClients(i)
	{
        if (!AreClientCookiesCached(i))
            continue;
        
        OnClientCookiesCached(i);
    }
}

public void OnMapStart()
{
	// Minecraft Iron Pickaxe
	iIronPickaxeView = PrecacheModel("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_iron.mdl", true);
	iIronPickaxeWorld = PrecacheModel("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_iron.mdl", true);
	// Minecraft Diamond Pickaxe
	iDiamondPickaxeView = PrecacheModel("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_diamond.mdl", true);
	iDiamondPickaxeWorld = PrecacheModel("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_diamond.mdl", true);
	// Minecraft Iron Sword
	iIronSwordView = PrecacheModel("models/weapons/eminem/mc_items/sword/v_sword_iron.mdl", true);
	iIronSwordWorld = PrecacheModel("models/weapons/eminem/mc_items/sword/w_sword_iron.mdl", true);
	// Minecraft Diamond Sword
	iDiamondSwordView = PrecacheModel("models/weapons/eminem/mc_items/sword/v_sword_diamond.mdl", true);
	iDiamondSwordWorld = PrecacheModel("models/weapons/eminem/mc_items/sword/w_sword_diamond.mdl", true);
	// Minecraft Iron Axe
	iIronAxeView = PrecacheModel("models/weapons/eminem/mc_items/axe/v_axe_iron.mdl", true);
	iIronAxeWorld = PrecacheModel("models/weapons/eminem/mc_items/axe/w_axe_iron.mdl", true);
	// Minecraft Diamond Axe
	iDiamondAxeView = PrecacheModel("models/weapons/eminem/mc_items/axe/v_axe_diamond.mdl", true);
	iDiamondAxeWorld = PrecacheModel("models/weapons/eminem/mc_items/axe/w_axe_diamond.mdl", true);
	// Screwdriver
	iScrewdriverView = PrecacheModel("models/weapons/caleon1/screwdriver/v_knife_screwdriver.mdl", true);
	iScrewdriverWorld = PrecacheModel("models/weapons/caleon1/screwdriver/w_knife_screwdriver.mdl", true);
	// Blue Screwdriver
	iBlueScrewdriverView = PrecacheModel("models/weapons/eminem/blue_screwdriver/v_blue_screwdriver.mdl", true);
	iBlueScrewdriverWorld = PrecacheModel("models/weapons/eminem/blue_screwdriver/w_blue_screwdriver.mdl", true);
	
	// Minecraft Iron Pickaxe
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/pickaxe-02.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/pickaxe-02.vtf");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_iron.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_iron.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_iron.vvd");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_iron.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_iron.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_iron.phy");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_iron.vvd");
	
	// Minecraft Diamond Pickaxe
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/pickaxe-04.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/pickaxe-04.vtf");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_diamond.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_diamond.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/v_pickaxe_diamond.vvd");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_diamond.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_diamond.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_diamond.phy");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/pickaxe/w_pickaxe_diamond.vvd");
	
	// Minecraft Iron Sword
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/sword-02.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/sword-02.vtf");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/v_sword_iron.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/v_sword_iron.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/v_sword_iron.vvd");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_iron.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_iron.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_iron.phy");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_iron.vvd");
	
	// Minecraft Diamond Sword
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/sword-04.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/sword-04.vtf");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/v_sword_diamond.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/v_sword_diamond.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/v_sword_diamond.vvd");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_diamond.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_diamond.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_diamond.phy");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/sword/w_sword_diamond.vvd");

	// Minecraft Iron Axe
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/axe-02.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/axe-02.vtf");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/v_axe_iron.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/v_axe_iron.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/v_axe_iron.vvd");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_iron.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_iron.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_iron.phy");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_iron.vvd");
	
	// Minecraft Diamond Axe
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/axe-04.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/mc_items/axe-04.vtf");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/v_axe_diamond.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/v_axe_diamond.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/v_axe_diamond.vvd");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_diamond.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_diamond.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_diamond.phy");
	AddFileToDownloadsTable("models/weapons/eminem/mc_items/axe/w_axe_diamond.vvd");
	
	// Screwdriver
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/yellow.vtf");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/black.vmt");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/black.vtf");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/metal.vmt");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/metal.vtf");
	AddFileToDownloadsTable("materials/models/weapons/caleon1/screwdriver/yellow.vmt");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/w_knife_screwdriver.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/w_knife_screwdriver.mdl");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/w_knife_screwdriver.vvd");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/v_knife_screwdriver.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/v_knife_screwdriver.mdl");
	AddFileToDownloadsTable("models/weapons/caleon1/screwdriver/v_knife_screwdriver.vvd");
	
	// Blue Screwdriver
	AddFileToDownloadsTable("materials/models/weapons/eminem/player_screwdriver/white.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/player_screwdriver/white.vtf");
	AddFileToDownloadsTable("materials/models/weapons/eminem/player_screwdriver/white_normal.vtf");
	AddFileToDownloadsTable("materials/models/weapons/eminem/player_screwdriver/blue.vmt");
	AddFileToDownloadsTable("materials/models/weapons/eminem/player_screwdriver/blue.vtf");
	AddFileToDownloadsTable("materials/models/weapons/eminem/player_screwdriver/blue_normal.vtf");
	AddFileToDownloadsTable("models/weapons/eminem/blue_screwdriver/v_blue_screwdriver.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/blue_screwdriver/v_blue_screwdriver.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/blue_screwdriver/v_blue_screwdriver.vvd");
	AddFileToDownloadsTable("models/weapons/eminem/blue_screwdriver/w_blue_screwdriver.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/eminem/blue_screwdriver/w_blue_screwdriver.mdl");
	AddFileToDownloadsTable("models/weapons/eminem/blue_screwdriver/w_blue_screwdriver.phy");
	AddFileToDownloadsTable("models/weapons/eminem/blue_screwdriver/w_blue_screwdriver.vvd");
}

public Action CMD_CustomKnive(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
		ShowKnifeMenu(client);
	} else {
		CPrintToChat(client, "\x0B[EverGames]\x01 Nie masz uprawnień do tej komendy!");
	}
	
	return Plugin_Handled;
}

public Action CMD_RestartCustom(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
		char KnifeP[16];
		KnifeSelection[client] = 0;
		IntToString(KnifeSelection[client], KnifeP, sizeof(KnifeP));
		SetClientCookie(client, g_hMySelectionK, KnifeP);
		FPVMI_RemoveViewModelToClient(client, "weapon_knife");
		FPVMI_RemoveWorldModelToClient(client, "weapon_knife");
		CPrintToChat(client, "\x0B[EverGames]\x01 Model Noża został zrestartowany!");
	} else {
		CPrintToChat(client, "\x0B[EverGames]\x01 Nie masz uprawnień do tej komendy!");
	}
	
	return Plugin_Handled;
}

void ShowKnifeMenu(int client)
{
	Menu menu_knifes = new Menu(mh_KnifeHandler);
	SetMenuTitle(menu_knifes, "EverGames.pl » Wybierz Model Noża");

	AddMenuItem(menu_knifes, "default", "Domyślny Nóż");
	AddMenuItem(menu_knifes, "ironpickaxe", "Minecraft Iron Pickaxe Knife");
	AddMenuItem(menu_knifes, "diamondpickaxe", "Minecraft Diamond Pickaxe Knife");
	AddMenuItem(menu_knifes, "ironsword", "Minecraft Iron Sword Knife");
	AddMenuItem(menu_knifes, "diamondsword", "Minecraft Diamond Sword Knife");
	AddMenuItem(menu_knifes, "ironaxe", "Minecraft Iron Axe Knife");
	AddMenuItem(menu_knifes, "diamondaxe", "Minecraft Diamond Axe Knife");
	AddMenuItem(menu_knifes, "screwdriver", "Screwdriver Knife");
	AddMenuItem(menu_knifes, "bluescrewdriver", "Blue Screwdriver Knife");
	SetMenuPagination(menu_knifes, 0);
	DisplayMenu(menu_knifes, client, 0);
}

public int mh_KnifeHandler(Menu menu, MenuAction action, int client, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{		
			char item[64];
			GetMenuItem(menu, param2, item, sizeof(item));
			
			SetKnife(client, item);
		}
		case MenuAction_End:
		{
			CloseHandle(menu);
		}
	}
}

void SetKnife(int client, char[] item)
{
	char item2[16];
	
	if (StrEqual(item, "default")) {
		FPVMI_RemoveViewModelToClient(client, "weapon_knife");
		FPVMI_RemoveWorldModelToClient(client, "weapon_knife");
		KnifeSelection[client] = 0;
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Domyślny\x01!");
	} else if (StrEqual(item, "ironpickaxe")) {
		KnifeSelection[client] = 1;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iIronPickaxeView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iIronPickaxeWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Iron Pickaxe\x01!");
	} else if (StrEqual(item, "diamondpickaxe")) {
		KnifeSelection[client] = 2;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iDiamondPickaxeView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iDiamondPickaxeWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Diamond Pickaxe\x01!");
	} else if (StrEqual(item, "ironsword")) {
		KnifeSelection[client] = 3;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iIronSwordView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iIronSwordWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Iron Sword\x01!");
	} else if (StrEqual(item, "diamondsword")) {
		KnifeSelection[client] = 4;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iDiamondSwordView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iDiamondSwordWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Diamond Sword\x01!");
	} else if (StrEqual(item, "ironaxe")) {
		KnifeSelection[client] = 5;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iIronAxeView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iIronAxeWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Iron Axe\x01!");
	} else if (StrEqual(item, "diamondaxe")) {
		KnifeSelection[client] = 6;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iDiamondAxeView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iDiamondAxeWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Diamond Axe\x01!");
	} else if (StrEqual(item, "screwdriver")) {
		KnifeSelection[client] = 7;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iScrewdriverView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iScrewdriverWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Screwdriver (Śrubokręt)\x01!");
	} else if (StrEqual(item, "bluescrewdriver")) {
		KnifeSelection[client] = 8;
		FPVMI_AddViewModelToClient(client, "weapon_knife", iBlueScrewdriverView);
		FPVMI_AddWorldModelToClient(client, "weapon_knife", iBlueScrewdriverWorld);
		IntToString(KnifeSelection[client], item2, sizeof(item2));
		SetClientCookie(client, g_hMySelectionK, item2);
		CPrintToChat(client, "\x0B[EverGames]\x01 Nóż zmieniony na: \x06Blue Screwdriver (Niebieski śrubokręt)\x01!");
	}
}

public void OnClientCookiesCached(int client)
{
	char sCookieValue[11];
	GetClientCookie(client, g_hMySelectionK, sCookieValue, sizeof(sCookieValue));
	KnifeSelection[client] = StringToInt(sCookieValue);
}

public void OnClientPostAdminCheck(int client)
{
	if(AreClientCookiesCached(client)) {
		SetKnife_saved(client);
	}
}

void SetKnife_saved(int client)
{
	switch (KnifeSelection[client])
	{
		case 1:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iIronPickaxeView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iIronPickaxeWorld);
			}
		}
		case 2:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iDiamondPickaxeView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iDiamondPickaxeWorld);
			}
		}
		case 3:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iIronSwordView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iIronSwordWorld);
			}
		}
		case 4:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iDiamondSwordView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iDiamondSwordWorld);
			}
		}
		case 5:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iIronAxeView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iIronAxeWorld);
			}
		}
		case 6:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iDiamondAxeView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iDiamondAxeWorld);
			}
		}
		case 7:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iScrewdriverView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iScrewdriverWorld);
			}
		}
		case 8:
		{
			if(Owner(client) || Opiekun(client) || Admin(client) || VIP(client)) {
				FPVMI_AddViewModelToClient(client, "weapon_knife", iBlueScrewdriverView);
				FPVMI_AddWorldModelToClient(client, "weapon_knife", iBlueScrewdriverWorld);
			}
		}
		default:
		{
			// Nothing
		}
	}
}
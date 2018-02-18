#include <sourcemod>
#include <sdktools>
#include <menus>
#include <hosties>
#include <colors>
#include <lastrequest>

#pragma semicolon 1

#define PLUGIN_VERSION "2.1"

new g_LREntryNum;
new g_This_LR_Type;
new g_LR_Player_Prisoner;
new g_LR_Player_Guard;

new TWep;
new CTWep;

new String:g_sLR_Name[64];

// menu handler
new Handle:MenuLR = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "[EverGames] JailBreak - Last HP Fight",
	author = "Mrkl21full",
	description = "",
	version = "2.1",
	url = "EverGames.pl"
};

public OnPluginStart()
{
	// Load translations
	//LoadTranslations("lastrequest_hpfight.phrases");
	
	// Name of the LR
	Format(g_sLR_Name, sizeof(g_sLR_Name), "Walka na HP");	
	
	// menu
	
	MenuLR = CreateMenu(MenuHandler);
	SetMenuTitle(MenuLR, "Walka na HP");
	AddMenuItem(MenuLR, "M1", "Walka na M4A1");
	AddMenuItem(MenuLR, "M2", "Walka na AK47");
	AddMenuItem(MenuLR, "M3", "Walka na SG556");
	AddMenuItem(MenuLR, "M4", "Walka na AUG");
	AddMenuItem(MenuLR, "M5", "Walka na FAMAS");
	AddMenuItem(MenuLR, "M6", "Walka na Galil");
	AddMenuItem(MenuLR, "M7", "Walka na M249");
	AddMenuItem(MenuLR, "M8", "Walka na Negev");
	AddMenuItem(MenuLR, "M9", "Walka na Bizon");
	AddMenuItem(MenuLR, "M10", "Walka na P90");
	AddMenuItem(MenuLR, "M11", "Walka na Mp9");
	AddMenuItem(MenuLR, "M12", "Walka na Mp7");
	AddMenuItem(MenuLR, "M13", "Walka na Mac10");
	AddMenuItem(MenuLR, "M14", "Walka na UMP45");
	AddMenuItem(MenuLR, "M15", "Walka na Scout");
	AddMenuItem(MenuLR, "M16", "Walka na AWP");
	AddMenuItem(MenuLR, "M17", "Walka na SCAR20");
	AddMenuItem(MenuLR, "M18", "Walka na G3SG1");
	AddMenuItem(MenuLR, "M19", "Walka na Glock");
	AddMenuItem(MenuLR, "M20", "Walka na Dualies");
	AddMenuItem(MenuLR, "M21", "Walka na Deagle");
	AddMenuItem(MenuLR, "M22", "Walka na Tec9");
	AddMenuItem(MenuLR, "M23", "Walka na Fiveseven");
	AddMenuItem(MenuLR, "M24", "Walka na P250");
	AddMenuItem(MenuLR, "M25", "Walka na P2000");
	AddMenuItem(MenuLR, "M26", "Walka na Mag7");
	AddMenuItem(MenuLR, "M27", "Walka na Nova");
	AddMenuItem(MenuLR, "M28", "Walka na Sawed-Off");
	AddMenuItem(MenuLR, "M29", "Walka na XM1014");
	AddMenuItem(MenuLR, "M30", "Walka na Taser");
	SetMenuExitButton(MenuLR, true);
}

public OnConfigsExecuted()
{
	static bool:bAddedLRHPFight = false;
	if (!bAddedLRHPFight)
	{
		g_LREntryNum = AddLastRequestToList(LR_Start, LR_Stop, g_sLR_Name, false);
		bAddedLRHPFight = true;
	}   
}

public MenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 0) // M4A1
		{
			LR_AfterMenu(0);
		}
		if(param2 == 1) // Ak47
		{
			LR_AfterMenu(1);
		}
		if(param2 == 2) // SG556
		{
			LR_AfterMenu(2);
		}
		if(param2 == 3) // AUG
		{
			LR_AfterMenu(3);
		}
		if(param2 == 4) // FAMAS
		{
			LR_AfterMenu(4);
		}
		if(param2 == 5) // Galil
		{
			LR_AfterMenu(5);
		}
		if(param2 == 6) // M249
		{
			LR_AfterMenu(6);
		}
		if(param2 == 7) // Negev
		{
			LR_AfterMenu(7);
		}
		if(param2 == 8) // Bizon
		{
			LR_AfterMenu(8);
		}
		if(param2 == 9) // P90
		{
			LR_AfterMenu(9);
		}
		if(param2 == 10) // Mp9
		{
			LR_AfterMenu(10);
		}
		if(param2 == 11) // Mp7
		{
			LR_AfterMenu(11);
		}
		if(param2 == 12) // Mac10
		{
			LR_AfterMenu(12);
		}
		if(param2 == 13) // UMP45
		{
			LR_AfterMenu(13);
		}
		if(param2 == 14) // Scout
		{
			LR_AfterMenu(14);
		}
		if(param2 == 15) // AWP
		{
			LR_AfterMenu(15);
		}
		if(param2 == 16) // SCAR20
		{
			LR_AfterMenu(16);
		}
		if(param2 == 17) // G3SG1
		{
			LR_AfterMenu(17);
		}
		if(param2 == 18) // Glock
		{
			LR_AfterMenu(18);
		}
		if(param2 == 19) // Dualies
		{
			LR_AfterMenu(19);
		}
		if(param2 == 20) // Deagle
		{
			LR_AfterMenu(20);
		}
		if(param2 == 21) // Tec9
		{
			LR_AfterMenu(21);
		}
		if(param2 == 22) // Fiveseven
		{
			LR_AfterMenu(22);
		}
		if(param2 == 23) // P250
		{
			LR_AfterMenu(23);
		}
		if(param2 == 24) // P2000
		{
			LR_AfterMenu(24);
		}
		if(param2 == 25) // Mag7
		{
			LR_AfterMenu(25);
		}
		if(param2 == 26) // Nova
		{
			LR_AfterMenu(26);
		}
		if(param2 == 27) // Sawed-Off
		{
			LR_AfterMenu(27);
		}
		if(param2 == 28) // XM1014
		{
			LR_AfterMenu(28);
		}
		if(param2 == 29) // Taser
		{
			LR_AfterMenu(29);
		}
	}
}

public OnPluginEnd()
{
	RemoveLastRequestFromList(LR_Start, LR_Stop, g_sLR_Name);
}

public LR_Start(Handle:LR_Array, iIndexInArray)
{
	g_This_LR_Type = GetArrayCell(LR_Array, iIndexInArray, _:Block_LRType);
	if (g_This_LR_Type == g_LREntryNum)
	{
		g_LR_Player_Prisoner = GetArrayCell(LR_Array, iIndexInArray, _:Block_Prisoner);
		g_LR_Player_Guard = GetArrayCell(LR_Array, iIndexInArray, _:Block_Guard);
		
		new LR_Pack_Value = GetArrayCell(LR_Array, iIndexInArray, _:Block_Global1);   
		switch (LR_Pack_Value)
		{
			case -1:
			{
				PrintToServer("no info included");
			}
		}
		DisplayMenu(MenuLR, g_LR_Player_Prisoner, MENU_TIME_FOREVER);
		//CPrintToChatAll("\x02[EverGames] \x07Przygotujcie się!");
	}
}


public LR_Stop(Type, Prisoner, Guard)
{
	if (Type == g_LREntryNum)
	{
		if (IsClientInGame(Prisoner))
		{
			if (IsPlayerAlive(Prisoner))
			{
				SetEntityRenderColor(Prisoner, 255, 255, 255, 255);
				SetEntityGravity(Prisoner, 1.0);
				SetEntityHealth(Prisoner, 100);
				StripAllWeapons(Prisoner);
				GivePlayerItem(Prisoner, "weapon_knife");
				CPrintToChatAll("\x0B[EverGames] \x06Walkę na HP wygrywa: {blue}%N!\x06", g_LR_Player_Prisoner);
			}
		}
		if (IsClientInGame(Guard))
		{
			if (IsPlayerAlive(Guard))
			{
				SetEntityRenderColor(Guard, 255, 255, 255, 255);
				SetEntityGravity(Guard, 1.0);
				SetEntityHealth(Guard, 100);
				StripAllWeapons(Guard);
				GivePlayerItem(Guard, "weapon_knife");
				CPrintToChatAll("\x0B[EverGames] \x06Walkę na HP wygrywa: {blue}%N!\x06", g_LR_Player_Guard);
			}
		}
		SetEntPropFloat(g_LR_Player_Prisoner, Prop_Data, "m_flLaggedMovementValue", 1.0);
		SetEntPropFloat(g_LR_Player_Guard, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
}

public LR_AfterMenu(weapon)
{
	StripAllWeapons(g_LR_Player_Prisoner);
	StripAllWeapons(g_LR_Player_Guard);
	
	SetEntityHealth(g_LR_Player_Prisoner, 1000);
	SetEntityHealth(g_LR_Player_Guard, 1000);
	
	switch(weapon)
	{
		case 0:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_m4a1");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_m4a1");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}M4A1\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 1:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_ak47");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_ak47");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}AK47\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 2:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_sg556");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_sg556");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}SG556\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 3:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_aug");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_aug");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}AUG\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 4:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_famas");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_famas");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}FAMAS\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 5:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_galilar");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_galilar");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Galil\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 6:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_m249");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_m249");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}M249\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 7:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_negev");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_negev");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Negev\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 8:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_bizon");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_bizon");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Bizon\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 9:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_p90");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_p90");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}P90\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 10:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_mp9");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_mp9");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Mp9\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 11:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_mp7");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_mp7");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Mp7\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 12:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_mac10");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_mac10");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Mac10\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 13:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_ump45");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_ump45");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}UMP45\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 14:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_ssg08");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_ssg08");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Scout\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 15:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_awp");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_awp");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}AWP\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 16:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_scar20");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_scar20");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}SCAR20\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 17:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_g3sg1");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_g3sg1");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}G3SG1\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 18:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_glock");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_glock");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Glock\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 19:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_elite");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_elite");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Dualies\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 20:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_deagle");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_deagle");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Deagle\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 21:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_tec9");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_tec9");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Tec9\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 22:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_fiveseven");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_fiveseven");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Fiveseven\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 23:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_p250");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_p250");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}P250\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 24:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_hkp2000");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_hkp2000");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}P2000\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 25:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_mag7");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_mag7");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Mag7\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 26:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_nova");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_nova");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Nova\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 27:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_sawedoff");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_sawedoff");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Sawed-Off\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 28:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_xm1014");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_xm1014");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}XM1014\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
		case 29:
		{
			TWep = GivePlayerItem(g_LR_Player_Prisoner, "weapon_taser");
			CTWep = GivePlayerItem(g_LR_Player_Guard, "weapon_taser");
			
			CPrintToChatAll("\x0B[EverGames] \x06Walka na HP rozpoczęta! Broń: {blue}Taser\x06!");
			CreateTimer(0.1, Timer_Update);
			InitializeLR(g_LR_Player_Prisoner);
		}
	}
}

public Action Timer_Update(Handle timer)
{
	SetEntData(TWep, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 999);
	SetEntData(CTWep, FindSendPropInfo("CBaseCombatWeapon", "m_iClip1"), 999);
	
	int ammoOffset = FindSendPropInfo("CCSPlayer", "m_iAmmo");
	SetEntData(g_LR_Player_Prisoner, ammoOffset+(1*4), 0);
	SetEntData(g_LR_Player_Guard, ammoOffset+(1*4), 0);
	
	SetEntityGravity(g_LR_Player_Prisoner, 0.8);
	SetEntityGravity(g_LR_Player_Guard, 0.8);
	
	SetEntityRenderColor(g_LR_Player_Guard, 0, 0, 255);
	SetEntityRenderColor(g_LR_Player_Prisoner, 255, 0, 0);
}
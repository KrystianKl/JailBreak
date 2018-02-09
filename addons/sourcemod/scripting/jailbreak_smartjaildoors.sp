#pragma newdecls required
#pragma semicolon 1

#include <sdktools>
#include <cstrike>
#include <multicolors>
#include <EverGames_JailBreak>

#define DATAFILE "smartjaildoors.txt"
#define GetEntityName(%1,%2,%3) GetEntPropString(%1, Prop_Data, "m_iName", %2, %3)

typeset DoorHandler {
	function void (const char[] name, const char[] clsname, any data);
	function void (const char[] name, const char[] clsname);
}

typedef ConfirmMenuHandler = function void (int client, bool result, any data);

KeyValues g_kv;

DataPack g_MenuDataPasser[MAXPLAYERS + 1];

int g_sjdclient;
bool g_sjdlookat;
Menu g_SJDMenu2;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("JailBreak_OpenDoors", Native_SJD_OpenDoors);
	CreateNative("JailBreak_CloseDoors", Native_SJD_CloseDoors);
	CreateNative("JailBreak_IsMapConfigured", Native_SJD_IsMapConfigured);

	RegPluginLibrary("smartjaildoors");

	return APLRes_Success;
}

public Plugin myinfo =
{
	name = "[EverGames] JailBreak - CellCore",
	author = "Kailo97 & Mrkl21full",
	description = "",
	version = "2.1",
	url = "EverGames.pl"
};

public void OnPluginStart()
{
	LoadTranslations("smartjaildoors.phrases");
	LoadTranslations("common.phrases");
	
	g_kv = new KeyValues("smartjaildoors");
	g_kv.ImportFromFile(DATAFILE);
	if (!FileExists(DATAFILE))
		g_kv.ExportToFile(DATAFILE);
	
	RegAdminCmd("sm_sjd", Command_SJDMenu, ADMFLAG_ROOT);
	
	HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_death", OnPlayerDeath);
	
	CreateTimer(0.1, ShowLookAt, _, TIMER_REPEAT);
}

public void OnPluginEnd()
{
	if (g_sjdclient != 0) {
		CloseSJDMenu();
		delete g_SJDMenu2;
	}
	
	g_kv.ExportToFile(DATAFILE);
	delete g_kv;
}

public Action ShowLookAt(Handle timer)
{
	if (g_sjdlookat) {
		int target = GetClientAimTarget(g_sjdclient, false);
		if (target == -1) {
			PrintHintText(g_sjdclient, "Nie znaleziono obiektu");
		} else {
			char clsname[64], name[128];
			GetEntityClassname(target, clsname, sizeof(clsname));
			GetEntityName(target, name, sizeof(name));
			PrintHintText(g_sjdclient, "%s (%d): %s", clsname, target, name);
		}
	}
}

bool ExecuteDoors(DoorHandler handler, any data = 0)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));

	if (!g_kv.JumpToKey(mapname))
		return false;
	
	if (!g_kv.JumpToKey("doors")) {
		g_kv.Rewind();
		return false;
	}
	
	if (!g_kv.GotoFirstSubKey()) {
		g_kv.Rewind();
		return false;
	}
	
	char name[64], clsname[64];
	do {
		g_kv.GetSectionName(name, sizeof(name));
		g_kv.GetString("class", clsname, sizeof(clsname));
		Call_StartFunction(null, handler);
		Call_PushString(name);
		Call_PushString(clsname);
		if (data != 0)
			Call_PushCell(data);
		Call_Finish();
	} while (g_kv.GotoNextKey());
	
	g_kv.Rewind();
	
	return true;
}

void InputToDoor(const char[] name, const char[] clsname, const char[] input)
{
	int doors[128], MaxEntities = GetMaxEntities(), i = MaxClients + 1;
	char entclsname[64], entname[64];
	for (; i < MaxEntities; i++) {
		if (IsValidEntity(i)) {
			GetEntityClassname(i, entclsname, sizeof(entclsname));
			if (StrEqual(clsname, entclsname)) {
				GetEntityName(i, entname, sizeof(entname));
				if (StrEqual(name, entname, false)) {
					doors[++doors[0]] = i;
				}
			}
		}
	}
	
	if (doors[0] == 0) {
		char mapname[64];
		GetCurrentMap(mapname, sizeof(mapname));
		LogError("No entity with \"%s\" name on  map.", name, mapname);
	}
	
	for (i = 1; i <= doors[0]; i++)
		AcceptEntityInput(doors[i], input);
}

void DeleteDoor(const char[] name)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	g_kv.JumpToKey(mapname);
	g_kv.JumpToKey("doors");
	g_kv.JumpToKey(name);
	g_kv.DeleteThis();
	if (!g_kv.GotoFirstSubKey())
		g_kv.DeleteThis();
	g_kv.Rewind();
	g_kv.ExportToFile(DATAFILE);
}

void SaveDoorByEnt(int entity)
{
	char clsname[64], name[128];
	GetEntityClassname(entity, clsname, sizeof(clsname));
	GetEntityName(entity, name, sizeof(name));
	SaveDoor(name, clsname);
}

void SaveDoor(const char[] name, const char[] clsname)
{
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	
	g_kv.JumpToKey(mapname, true);
	g_kv.JumpToKey("doors", true);
	g_kv.JumpToKey(name, true);
	g_kv.SetString("class", clsname);
	g_kv.Rewind();
	g_kv.ExportToFile(DATAFILE);
}

public bool TraceEntityFilterPlayer(int entity, int contentsMask) 
{
    return entity > GetMaxClients();
}

void ShowConfirmMenu(int client, ConfirmMenuHandler handler, any data = 0, const char[] title = "", any ...)
{
	Menu menu = new Menu(ConfirmMenu);
	if (strlen(title)) {
		char buffer[256];
		VFormat(buffer, sizeof(buffer), title, 5);
		menu.SetTitle(buffer);
	}
	menu.AddItem("yes", "Tak");
	menu.AddItem("no", "Nie");
	g_MenuDataPasser[client] = new DataPack();
	WritePackFunction(g_MenuDataPasser[client], handler);
	if (data != 0) {
		WritePackCell(g_MenuDataPasser[client], true);
		WritePackCell(g_MenuDataPasser[client], data);
	} else
		WritePackCell(g_MenuDataPasser[client], false);
	ResetPack(g_MenuDataPasser[client]);
	menu.ExitButton = false;
	g_SJDMenu2 = menu;
	menu.Display(client, 5);
}

public int ConfirmMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			char info[16];
			menu.GetItem(param2, info, sizeof(info));
			ConfirmMenuHandler handler = view_as<ConfirmMenuHandler>(ReadPackFunction(g_MenuDataPasser[param1]));
			any data;
			if (ReadPackCell(g_MenuDataPasser[param1]))
				data = ReadPackCell(g_MenuDataPasser[param1]);
			delete g_MenuDataPasser[param1];
			if (StrEqual(info, "yes"))
				ExecuteConfirmMenuHandler(param1, handler, true, data);
			else
				ExecuteConfirmMenuHandler(param1, handler, false, data);
		}
		case MenuAction_Cancel: {
			ConfirmMenuHandler handler = view_as<ConfirmMenuHandler>(ReadPackFunction(g_MenuDataPasser[param1]));
			any data;
			if (ReadPackCell(g_MenuDataPasser[param1]))
				data = ReadPackCell(g_MenuDataPasser[param1]);
			delete g_MenuDataPasser[param1];
			ExecuteConfirmMenuHandler(param1, handler, false, data);
		}
		case MenuAction_End: delete menu;
	}
}

void ExecuteConfirmMenuHandler(int client, ConfirmMenuHandler handler, bool result, any data = 0)
{
	Call_StartFunction(null, handler);
	Call_PushCell(client);
	Call_PushCell(result);
	if (data != 0)
		Call_PushCell(data);
	Call_Finish();
}

public void OnRoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	if (g_sjdclient != 0) {
		CloseSJDMenu();
		if (g_SJDMenu2 != null)
			delete g_SJDMenu2;
	}
}

public void OnPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (client == g_sjdclient) {
		CloseSJDMenu();
		if (g_SJDMenu2 != null)
			delete g_SJDMenu2;
		CPrintToChat(client, "\x0B[EverGames]\x06 Nie możesz używać SJD kiedy nieżyjesz!");
	}
}

public void OnClientDisconnect(int client)
{	
	if (client == g_sjdclient) {
		CloseSJDMenu();
		if (g_SJDMenu2 != null)
			delete g_SJDMenu2;
	}
}

void OpenDoorsOnMap(bool bynative = false)
{
	DataPack Pack = new DataPack();
	Pack.WriteCell(bynative);
	if (!ExecuteDoors(OpenDoor, Pack))
		if (!bynative)
			CPrintToChat(g_sjdclient, "\x0B[EverGames]\x06 Wpierw dodaj drzwi, aby je otwierać!");
	delete Pack;
}

public void OpenDoor(const char[] name, const char[] clsname, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (StrEqual("func_movelinear", clsname) || StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname)) {
		InputToDoor(name, clsname, "Open");
	} else if (StrEqual("func_tracktrain", clsname)) {
		InputToDoor(name, clsname, "StartForward");
	} else if (StrEqual("func_breakable", clsname)) {
		InputToDoor(name, clsname, "Break");
	} else if (StrEqual("func_wall_toggle", clsname)) {
		Pack.Reset();
		if (!Pack.ReadCell())
			CPrintToChat(g_sjdclient, "\x0B[EverGames]\x06 Błędny obiekt klasy, aby otworzyć drzwi (%s)!", clsname);
	} else if (StrEqual("func_brush", clsname)) {
		InputToDoor(name, clsname, "Disable");
	}
}

void CloseDoorsOnMap(bool bynative = false)
{
	DataPack Pack = new DataPack();
	Pack.WriteCell(bynative);
	if (!ExecuteDoors(CloseDoor, Pack))
		if (!bynative)
			CPrintToChat(g_sjdclient, "\x0B[EverGames]\x06 Wpierw dodaj drzwi, aby je zamykać!");
	delete Pack;
}

public void CloseDoor(const char[] name, const char[] clsname, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (StrEqual("func_movelinear", clsname) || StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname) || StrEqual("prop_door_rotating", clsname)) {
		InputToDoor(name, clsname, "Close");
	} else if (StrEqual("func_tracktrain", clsname)) {
		Pack.Reset();
		if (!Pack.ReadCell())
			CPrintToChat(g_sjdclient, "\x0B[EverGames]\x06 Błędny obiekt klasy, aby zamknąć drzwi (%s)!", clsname);
	} else if (StrEqual("func_breakable", clsname)) {
		Pack.Reset();
		if (!Pack.ReadCell())
			CPrintToChat(g_sjdclient, "\x0B[EverGames]\x06 Błędny obiekt klasy, aby zamknąć drzwi (%s)!", clsname);
	} else if (StrEqual("func_wall_toggle", clsname)) {
		Pack.Reset();
		if (!Pack.ReadCell())
			CPrintToChat(g_sjdclient, "\x0B[EverGames]\x06 Błędny obiekt klasy, aby zamknąć drzwi (%s)!", clsname);
	} else if (StrEqual("func_brush", clsname)) {
		InputToDoor(name, clsname, "Enable");
	}
}

bool IsMapConfigured(const char[] mapName)
{
	if (!g_kv.JumpToKey(mapName))
		return false;
	
	if (!g_kv.JumpToKey("doors")) {
		g_kv.Rewind();
		return false;
	}
	
	g_kv.Rewind();
	return true;
}

bool DoorClassValidation(const char[] clsname)
{
	return (StrEqual("func_movelinear", clsname) || StrEqual("func_door", clsname) || StrEqual("func_door_rotating", clsname)
			|| StrEqual("prop_door_rotating", clsname) || StrEqual("func_tracktrain", clsname) || StrEqual("func_breakable", clsname)
			|| StrEqual("func_wall_toggle", clsname) || StrEqual("func_brush", clsname));
}

public Action Command_SJDMenu(int client, int args)
{
	if (IsPlayerAlive(client))
		ShowSJDMenu2(client);
	else
		CPrintToChat(client, "\x0B[EverGames]\x06 Nie możesz używać SJD kiedy nieżyjesz!");
	
	return Plugin_Handled;
}

void ShowSJDMenu2(int client)
{
	if(Owner(client)) {
		CPrintToChat(client, "\x0B[EverGames]\x06 Nie masz uprawnień!");
		return;
	}
	
	g_SJDMenu2 = new Menu(SJDMenu2);
	g_SJDMenu2.SetTitle("EverGames.pl » System otwierania drzwi");
	g_SJDMenu2.AddItem("doors", "Drzwi");
	g_SJDMenu2.AddItem("test", "Przetestuj");
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
	g_sjdclient = client;
}

void CloseSJDMenu()
{
	DisableLookAt();
	g_sjdclient = 0;
}

public int SJDMenu2(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			switch (param2) {
				case 0:
					SJDMenu2_ShowDoorsSubMenu(param1);
				case 1:
					SJDMenu2_ShowTestSubMenu(param1);
			}
		}
		case MenuAction_Cancel: CloseSJDMenu();
		case MenuAction_End: delete menu;
	}
}

void SJDMenu2_ShowDoorsSubMenu(int client, bool late = false)
{
	g_SJDMenu2 = new Menu(SJDMenu2_DoorsSubMenu);
	g_SJDMenu2.SetTitle("EverGames.pl » Zapisywanie drzwi");
	g_SJDMenu2.AddItem("save", "Zapisz drzwi");
	if (!ExecuteDoors(SJDMenu2_AddItemsToDoorsSubMenu)) {
		g_SJDMenu2.AddItem("nodoors", "Brak drzwi", ITEMDRAW_DISABLED);
	}
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
	EnableLookAt(late);
}

public void SJDMenu2_AddItemsToDoorsSubMenu(const char[] name, const char[] clsname)
{
	g_SJDMenu2.AddItem(name, name);
}

public int SJDMenu2_DoorsSubMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			if (param2 == 0) {
				int target = GetClientAimTarget(param1, false);
				if (target == -1) {
					CPrintToChat(param1, "\x0B[EverGames]\x06 Obiekt nie znaleziony!");
					SJDMenu2_ShowDoorsSubMenu(param1, true);
				} else {
					char clsname[64];
					GetEntityClassname(target, clsname, sizeof(clsname));
					if (!DoorClassValidation(clsname)) {
						CPrintToChat(param1, "\x0B[EverGames]\x06 Niewspierana nazwa obiektu!");
						SJDMenu2_ShowDoorsSubMenu(param1, true);
					} else {
						char name[64];
						GetEntityName(target, name, sizeof(name));
						if (strlen(name) == 0) {
							CPrintToChat(param1, "\x0B[EverGames]\x06 Obiekt nie ma nazwy!");
							SJDMenu2_ShowDoorsSubMenu(param1, true);
						} else {
							ShowConfirmMenu(param1, SJDMenu2_ConfirmSaveDoor, target, "EverGames.pl » Potwierdź usunięcie drzwi: %s", name);
						}
					}
				}
			} else {
				char info[64];
				menu.GetItem(param2, info, sizeof(info));
				SJDMenu2_ShowDoorItemMenu(param1, info);
			}
		}
		case MenuAction_Cancel:
			switch (param2) {
				case MenuCancel_ExitBack:
					ShowSJDMenu2(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: {
			DisableLookAt();
			delete menu;
		}
	}
}

public void SJDMenu2_ConfirmSaveDoor(int client, bool result, any entity)
{
	if (result) {
		SaveDoorByEnt(entity);
		char name[64];
		GetEntityName(entity, name, sizeof(name));
		CPrintToChat(client, "\x0B[EverGames]\x06 Drzwi \x07%s\x06zostały zapisane!", name);
	}
	
	if (IsClientInGame(client) && IsPlayerAlive(client))
		SJDMenu2_ShowDoorsSubMenu(client);
}

void SJDMenu2_ShowDoorItemMenu(int client, const char[] name)
{
	char clsname[64], mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	g_kv.JumpToKey(mapname);
	g_kv.JumpToKey("doors");
	g_kv.JumpToKey(name);
	g_kv.GetString("class", clsname, sizeof(clsname));
	g_kv.Rewind();

	g_SJDMenu2 = new Menu(SJDMenu2_DoorItemMenu);
	char buffer[64];
	FormatEx(buffer, sizeof(buffer), "Nazwa: %s", name);
	g_SJDMenu2.AddItem(name, buffer, ITEMDRAW_DISABLED);
	FormatEx(buffer, sizeof(buffer), "Nazwa klasy: %s", clsname);
	g_SJDMenu2.AddItem(clsname, buffer, ITEMDRAW_DISABLED);
	g_SJDMenu2.AddItem("delete", "Usuń drzwi");
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
}

public int SJDMenu2_DoorItemMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			char name[64];
			menu.GetItem(0, name, sizeof(name));
			DataPack Pack = new DataPack();
			Pack.WriteString(name);
			Pack.Reset();
			ShowConfirmMenu(param1, SJDMenu2_ConfirmDeleteDoor, Pack, "EverGames.pl » Potwierdź usunięcie drzwi: %s", name);
		}
		case MenuAction_Cancel: 
			switch (param2) {
				case MenuCancel_ExitBack:
					SJDMenu2_ShowDoorsSubMenu(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: delete menu;
	}
}

public void SJDMenu2_ConfirmDeleteDoor(int client, bool result, any data)
{
	DataPack Pack = view_as<DataPack>(data);
	if (result) {
		char name[64];
		Pack.ReadString(name, sizeof(name));
		DeleteDoor(name);
		CPrintToChat(client, "\x0B[EverGames]\x06 Drzwi \x07%s\x06zostały usunięte!", name);
	}
	
	delete Pack;
	if (IsClientInGame(client) && IsPlayerAlive(client))
		SJDMenu2_ShowDoorsSubMenu(client);
}

void SJDMenu2_ShowTestSubMenu(int client)
{
	g_SJDMenu2 = new Menu(SJDMenu2_TestSubMenu);
	g_SJDMenu2.SetTitle("EverGames.pl » Przetestuj:");
	g_SJDMenu2.AddItem("open", "Otwieranie cel");
	g_SJDMenu2.AddItem("close", "Zamykanie cel");
	g_SJDMenu2.OptionFlags |= MENUFLAG_BUTTON_EXITBACK;
	g_SJDMenu2.Display(client, MENU_TIME_FOREVER);
}

public int SJDMenu2_TestSubMenu(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action) {
		case MenuAction_Select: {
			switch (param2) {
				case 0:
					OpenDoorsOnMap();
				case 1:
					CloseDoorsOnMap();
			}
			SJDMenu2_ShowTestSubMenu(param1);
		}
		case MenuAction_Cancel:
			switch (param2) {
				case MenuCancel_ExitBack:
					ShowSJDMenu2(param1);
				case MenuCancel_Exit:
					CloseSJDMenu();
			}
		case MenuAction_End: delete menu;
	}
}

void EnableLookAt(bool late = false)
{
	if (late)
		CreateTimer(0.0, LateEnableLookAt);
	else
		g_sjdlookat = true;
}

public Action LateEnableLookAt(Handle timer)
{
	g_sjdlookat = true;
}

void DisableLookAt()
{
	g_sjdlookat = false;
}

public int Native_SJD_OpenDoors(Handle plugin, int numParams)
{
	OpenDoorsOnMap(true);
}

public int Native_SJD_CloseDoors(Handle plugin, int numParams)
{
	CloseDoorsOnMap(true);
}

public int Native_SJD_IsMapConfigured(Handle plugin, int numParams)
{
	int len;
	GetNativeStringLength(1, len);
	
	if (len <= 0)
		return view_as<int>(false);
	
	char[] mapName = new char[len + 1];
	GetNativeString(1, mapName, len + 1);
	
	return view_as<int>(IsMapConfigured(mapName));
}
#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Shop: HP"

#define ITEMNAME "Kup HP (100)"
#define PRICE 200
#define TEAMNAME JB_BOTH

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = JB_PLUGIN_AUTHOR,
	description = JB_PLUGIN_DESCRIPTION,
	version = JB_PLUGIN_VERSION,
	url = JB_PLUGIN_URL
};

public OnPluginStart()
{
	CreateTimer(0.1, Lateload);
}

public Action Lateload(Handle timer)
{
	JailBreak_AddItem(ITEMNAME, PRICE, TEAMNAME);
}

public OnPluginEnd()
{
	JailBreak_RemoveItem(ITEMNAME);
}

public void JailBreak_OnItemBought(int client, const char[] ItemName)
{
	if(StrEqual(ItemName, ITEMNAME))
	{
		CPrintToChat(client, "\x0B[EverGames]\x06 Właśnie kupiłeś: \x03100 HP\x06!");
		SetEntityHealth(client, 100);
	}
}
#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Shop: Flashbang"

#define ITEMNAME "Kup Flashbang'a"
#define PRICE 150
#define TEAMNAME JB_PRISIONERS

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
		CPrintToChat(client, "\x0B[EverGames]\x06 Właśnie kupiłeś: \x03Flashbang'a\x06!");
		GivePlayerItem(client, "weapon_flashbang");
	}
}
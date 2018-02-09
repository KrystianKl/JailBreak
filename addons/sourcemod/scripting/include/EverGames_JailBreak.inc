/*
*   This file is part of EverGames JailBreak.
*   Copyright (C) 2018  Mrkl21full
*
*   This program is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program. If not, see <http://www.gnu.org/licenses/>.
*/

#if defined _evergames_included
	#endinput
#endif

#define _evergames_included

#define LoopValidClients(%1) for(int %1 = 1; %1 <= MaxClients; %1++) if(IsValidClient(%1))

#define JB_PLUGIN_NAME "[EverGames] JailBreak"
#define JB_PLUGIN_AUTHOR "Mrkl21full"
#define JB_PLUGIN_DESCRIPTION "JailBreak system Core"
#define JB_PLUGIN_VERSION "2.1"
#define JB_PLUGIN_URL "EverGames.pl"

#define JB_GUARDS 1
#define JB_PRISIONERS 2
#define JB_BOTH 3

/**
 * Open jail's doors on current map saved in config.
 */

native void JailBreak_OpenDoors();

/**
 * Close jail's doors on current map saved in config.
 */

native void JailBreak_CloseDoors();

/**
 * Check if exist doors config for said map.
 *
 * @param mapName			String with map name for check.     
 */

native void JailBreak_IsMapConfigured(const char[] mapName);

/**
 * Check if player is captain.
 *
 * @param Client			Client index.      
 */

native void JailBreak_IsCaptain(int client);

/**
 * Get captain index (client index).      
 */

native void JailBreak_GetCaptain(int client);

/**
 * Set new captain and remove old.
 *
 * @param Client			Client index.      
 */

native void JailBreak_SetCaptain(int client);

/**
 * Forward called when player becomes captain.
 *
 * @param Client			Client who become captain.       
 */

forward void JailBreak_OnCaptainSet(int client);

/**
 * Add item to the shop in main plugin.
 *
 * @param Name				Item name.
 * @param Price				Item price.
 * @param TeamIndex			Team allowed to buy this item.		       
 */

native void JailBreak_AddItem(const char[] Name, int Price, int TeamIndex);

/**
 * Remove item from main plugin (useful when maps end).
 *
 * @param Name				Item name.		       
 */
 
native void JailBreak_RemoveItem(const char[] Name);

/**
 * Forward called when player bought item.
 *
 * @param Client			Client who bought the item.
 * @param ItemName			Item name to check.		       
 */

forward void JailBreak_OnItemBought(int client, const char[] ItemName);

/**
 * Get client credits.
 *
 * @param Client			Client target.
 */
 
native int JailBreak_GetCredits(int client);

/**
 * Set credits to a client.
 *
 * @param Client			Client target.
 * @param Credits			Number of credits to set.		       
 */
 
native void JailBreak_SetCredits(int client, int credits);

/**
 * Give FreeDay to player.
 *
 * @param Client			Client target. 
 */
 
native void JailBreak_SetFreeDay(int client);

/**
 * Check if player have FreeDay.
 *
 * @param Client			Client index.
 */
 
native bool JailBreak_GetFreeDay(int client);

/**
 * Set special round (used by roundprestart).
 *
 * @param Name				Round name.
 */

native void JailBreak_ChooseRound(const char[] Name);

/**
 * Check if the game is active.
 *
 * @param Round Name		Name of round to check.
 */

native bool JailBreak_GetRound(const char[] RoundName);

/**
 * Check if the special round game is active.
 */

native bool JailBreak_isRoundActive();

/**
 * Check if client have Owner permissions.
 *
 * @param Client			Client index.
 */

stock bool Owner(int client) {
	return (CheckCommandAccess(client, "sm_test", ADMFLAG_ROOT, true)) ? true : false;
}

/**
 * Check if client have Opiekun permissions.
 *
 * @param Client			Client index.
 */

stock bool Opiekun(int client) {
	return (CheckCommandAccess(client, "sm_test", ADMFLAG_CUSTOM3, true)) ? true : false;
}

/**
 * Check if client have Admin permissions.
 *
 * @param Client			Client index.
 */

stock bool Admin(int client) {
	return (CheckCommandAccess(client, "sm_test", ADMFLAG_BAN, true)) ? true : false;
}

/**
 * Check if client have VIP Elite permissions.
 *
 * @param Client			Client index.
 */

stock bool VIP_Elite(int client) {
	return (CheckCommandAccess(client, "sm_test", ADMFLAG_CUSTOM5, true)) ? true : false;
}
/**
 * Check if client have VIP permissions.
 *
 * @param Client			Client index.
 */

stock bool VIP(int client) {
	return (CheckCommandAccess(client, "sm_test", ADMFLAG_RESERVATION, true)) ? true : false;
}

/*
 * Check if a client index is valid.
 */

stock bool IsValidClient(int client)
{
	if (client > 0 && client <= MaxClients) {
		if (!IsClientConnected(client))
			return false;
		
		if (IsClientSourceTV(client))
			return false;

		if (!IsClientInGame(client))
			return false;

		return true;
	}
	return false;
}
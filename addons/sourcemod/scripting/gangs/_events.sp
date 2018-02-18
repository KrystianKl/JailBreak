public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(0.1, Usuwanie);
	
	char CurrentRound[64];
	JailBreak_GetRound(CurrentRound);
	
	if(!StrEqual(CurrentRound, "Simon", false))
	{
		DzisiajZabawa = true;
		return;
	}
	
	DzisiajZabawa = false;
	
	for (new i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && !IsFakeClient(i))
        {
			ClearTimer(g_hRegeneration[i]);
        }
    }
}

public Action Event_EndStart(Event event, const char[] name, bool dontBroadcast)
{
	for (new i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i) && !IsFakeClient(i))
        {
			ClearTimer(g_hRegeneration[i]);
        }
    }
}

public Action Usuwanie(Handle:Timer)
{
	ServerCommand("sm_broomkit");
	ServerCommand("sm_broomknife");
}

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (IsClientInGame(client) && IsPlayerAlive(client)) {
		CreateTimer(0.1, RespawnPL, client);
	}
}

public Action:RespawnPL(Handle:Timer, any:client)
{
	char TagEvent[16];
		
	if(Gangs_GetClientGang(client) && Gangs_IsClientInGang(client)) {
		Format(TagEvent, sizeof(TagEvent), "%s »", g_sGang[g_iClientGang[client]]);
	} else {
		if(Owner(client)) {
			Format(TagEvent, sizeof(TagEvent), "Właściciel »");
		} else if(Opiekun(client)) {
			Format(TagEvent, sizeof(TagEvent), "Opiekun »");
		} else if(Admin(client)) {
			Format(TagEvent, sizeof(TagEvent), "Admin »");
		} else if(VIP_Elite(client)) {
			Format(TagEvent, sizeof(TagEvent), "VIP Elite »");
		} else if(VIP(client)) {
			Format(TagEvent, sizeof(TagEvent), "VIP »");
		} else {
			Format(TagEvent, sizeof(TagEvent), "Gracz »");
		}
	}
	
	CS_SetClientClanTag(client, TagEvent);
	
	if(DzisiajZabawa && Gangs_IsClientInGang(client)) {
		int GangID = Gangs_GetClientGang(client);
		
		CPrintToChat(client, "\x0B[EverGames]\x06 Umiejętności gangu zostały wyłączone.");
		
		int iGangGangSkills[Cache_Gangs_Skills];
		
		for (int i = 0; i < g_aCacheGangSkills.Length; i++)
		{
			g_aCacheGangSkills.GetArray(i, iGangGangSkills[0]);
			
			if(iGangGangSkills[iGangID] == GangID) {
				if(iGangGangSkills[iSkillID] == 5) {
					if(iGangGangSkills[iLevel] == 1) {
						/* 1 - Niebieski 60 80 240 */
						SetEntityRenderColor(client, 60, 80, 240, 255);
					} else if(iGangGangSkills[iLevel] == 2) {
						/* 2 - Zielony 40 150 10 */
						SetEntityRenderColor(client, 40, 150, 10, 255);
					} else if(iGangGangSkills[iLevel] == 3) {
						/* 3 - Czerwony 255 5 5 */
						SetEntityRenderColor(client, 255, 5, 5, 255);
					} else if(iGangGangSkills[iLevel] == 4) {
						/* 4 - Limonkowy 5 255 5 */
						SetEntityRenderColor(client, 5, 255, 255, 255);
					} else if(iGangGangSkills[iLevel] == 5) {
						/* 5 - Żółty 255 255 5 */
						SetEntityRenderColor(client, 255, 255, 5, 255);
					} else if(iGangGangSkills[iLevel] == 6) {
						/* 6 - Aqua 5 255 255 */
						SetEntityRenderColor(client, 5, 255, 255, 255);
					} else if(iGangGangSkills[iLevel] == 7) {
						/* 7 - Morski 15 255 200 */
						SetEntityRenderColor(client, 15, 255, 200, 255);
					} else if(iGangGangSkills[iLevel] == 8) {
						/* 8 - Fioletowy 255 15 255 */
						SetEntityRenderColor(client, 255, 15, 255, 255);
					} else if(iGangGangSkills[iLevel] == 9) {
						/* 9 - Różowy 255 120 170 */
						SetEntityRenderColor(client, 255, 120, 170, 255);
					} else if(iGangGangSkills[iLevel] == 10) {
						/* 10 - Pomarańczowy 255 180 0 */
						SetEntityRenderColor(client, 255, 180, 0, 255);
					} else {
						/* DOMYŚLNY */
						SetEntityRenderColor(client, 255, 255, 255, 255);
					}
				}
			}
		}		
	} else if(!DzisiajZabawa && Gangs_IsClientInGang(client)) {
		int GangID = Gangs_GetClientGang(client);
		
		RespawnPlayer(client, GangID);
	} else {
		SetEntProp(client, Prop_Send, "m_iHealth", 100);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.00);
		SetEntityGravity(client, 1.00);
	}
}

RespawnPlayer(client, Gang)
{	
	int iGangGangSkills[Cache_Gangs_Skills];
	
	for (int i = 0; i < g_aCacheGangSkills.Length; i++)
	{
		g_aCacheGangSkills.GetArray(i, iGangGangSkills[0]);
		
		if(iGangGangSkills[iGangID] == Gang) {
			if(iGangGangSkills[iSkillID] == 1) {
				for (new j = 1; j <= iGangGangSkills[iLevel]; j++)
				{
					if((VIP_Elite(client) || VIP(client)) && j == 4) {
						// NIC
					} else {
						GivePlayerItem(client, "weapon_healthshot");
					}
				}
			}
			
			if(iGangGangSkills[iSkillID] == 2) {
				SetEntProp(client, Prop_Send, "m_iHealth", 100 + (iGangGangSkills[iLevel] * 5));
			}
			
			if(iGangGangSkills[iSkillID] == 3) {
				SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.00 + (iGangGangSkills[iLevel] * 0.05));
			}
			
			if(iGangGangSkills[iSkillID] == 4) {
				SetEntityGravity(client, 1.00 - (iGangGangSkills[iLevel] * 0.05));
			}
			
			if(iGangGangSkills[iSkillID] == 6) {
				g_zasiegGranata[client] = float(iGangGangSkills[iLevel]);
			}
			
			if(iGangGangSkills[iSkillID] == 7) {
				g_obrazeniaGranata[client] = float(iGangGangSkills[iLevel]);
			}
			
			if(iGangGangSkills[iSkillID] == 8) {
				g_globalneObrazenia[client] = float(iGangGangSkills[iLevel]);
			}
			
			if(iGangGangSkills[iSkillID] == 9) {
				g_Reinkarnacja[client] = iGangGangSkills[iLevel];
			}
			
			if(iGangGangSkills[iSkillID] == 10) {
				if(iGangGangSkills[iLevel] == 1) {
					g_bTryb[client] = true;
				} else {
					g_bTryb[client] = false;
				}
			}
			
			if(iGangGangSkills[iSkillID] == 11 && g_bTryb[client]) {
				g_iloscHP[client] = iGangGangSkills[iLevel];
			}
				
			if(iGangGangSkills[iSkillID] == 12 && g_bTryb[client]) {
				new Float:TimerCounter = float(iGangGangSkills[iLevel]);
				g_hRegeneration[client] = CreateTimer(TimerCounter, Regeneracja, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
			
			if(iGangGangSkills[iSkillID] == 13 && g_bTryb[client]) {	
				g_iloscMaxHP[client] = iGangGangSkills[iLevel];
			}
		}
	}
}

public Action Regeneracja(Handle:Timer, any:client)
{
	if (IsClientInGame(client) && IsPlayerAlive(client) && Gangs_IsClientInGang(client)) {
		new Health = GetEntProp(client, Prop_Send, "m_iHealth");
		
		int FixHealth = Health + g_iloscHP[client];
		int FixHealthInc = g_iloscMaxHP[client] - g_iloscHP[client];
		
		if(Health < g_iloscMaxHP[client] && Health > FixHealthInc) {
			SetEntProp(client, Prop_Send, "m_iHealth", g_iloscMaxHP[client]);
		} else {
			if(FixHealth < g_iloscMaxHP[client]) {
				SetEntProp(client, Prop_Send, "m_iHealth", Health + g_iloscHP[client]);
			}
		}
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if (IsClientInGame(victim) && IsPlayerAlive(victim) && Gangs_IsClientInGang(victim)) {
		damage = damage * g_globalneObrazenia[victim];
		return Plugin_Changed;
	}
	return Plugin_Continue;
} 

public OnEntityCreated(iEnt, const String:szClassname[])
{
	if(StrEqual(szClassname, "hegrenade_projectile"))
	{
		SDKHook(iEnt, SDKHook_SpawnPost, OnGrenadeSpawn);
	}
}

public OnGrenadeSpawn(iGrenade)
{
	CreateTimer(0.01, ChangeGrenadeDamage, iGrenade, TIMER_FLAG_NO_MAPCHANGE);
}

public Action ChangeGrenadeDamage(Handle hTimer, any iEnt)
{
	int client = GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity");
	
	if (IsClientInGame(client) && IsPlayerAlive(client) && Gangs_IsClientInGang(client)) {
		if(g_obrazeniaGranata[client] >= 2 && g_zasiegGranata[client] >= 2) {
			float obrazeniaGranata = 1.5;
			float zasiegGranata = 1.2;
			
			if(g_obrazeniaGranata[client] == 2) {
				obrazeniaGranata = 1.85;
			} else if(g_obrazeniaGranata[client] == 3) {
				obrazeniaGranata = 2.25;
			} else if(g_obrazeniaGranata[client] == 4) {
				obrazeniaGranata = 2.5;
			} else if(g_obrazeniaGranata[client] == 5) {
				obrazeniaGranata = 2.75;
			} else if(g_obrazeniaGranata[client] == 6) {
				obrazeniaGranata = 3.00;
			}
			
			if(g_zasiegGranata[client] == 2) {
				zasiegGranata = 1.5;
			} else if(g_zasiegGranata[client] == 3) {
				zasiegGranata = 1.85;
			} else if(g_zasiegGranata[client] == 4) {
				zasiegGranata = 2.25;
			} else if(g_zasiegGranata[client] == 5) {
				zasiegGranata = 2.60;
			} else if(g_zasiegGranata[client] == 6) {
				zasiegGranata = 3.0;
			}
			
			float flGrenadePower = GetEntPropFloat(iEnt, Prop_Send, "m_flDamage");
			float flGrenadeRadius = GetEntPropFloat(iEnt, Prop_Send, "m_DmgRadius");
			
			SetEntPropFloat(iEnt, Prop_Send, "m_flDamage", (flGrenadePower * obrazeniaGranata));
			SetEntPropFloat(iEnt, Prop_Send, "m_DmgRadius", (flGrenadeRadius * zasiegGranata));
		} else {
			float flGrenadePower = GetEntPropFloat(iEnt, Prop_Send, "m_flDamage");
			float flGrenadeRadius = GetEntPropFloat(iEnt, Prop_Send, "m_DmgRadius");
			
			SetEntPropFloat(iEnt, Prop_Send, "m_flDamage", (flGrenadePower * 1.5));
			SetEntPropFloat(iEnt, Prop_Send, "m_DmgRadius", (flGrenadeRadius * 1.2));
		}
	} else if (IsClientInGame(client) && IsPlayerAlive(client)) {
		float flGrenadePower = GetEntPropFloat(iEnt, Prop_Send, "m_flDamage");
		float flGrenadeRadius = GetEntPropFloat(iEnt, Prop_Send, "m_DmgRadius");
		
		SetEntPropFloat(iEnt, Prop_Send, "m_flDamage", (flGrenadePower * 1.0));
		SetEntPropFloat(iEnt, Prop_Send, "m_DmgRadius", (flGrenadeRadius * 1.0));
	}
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("attacker"));
	int victim = GetClientOfUserId(event.GetInt("userid"));
	
	bool headshot = event.GetBool("headshot");
	char sWeapon[64];
	
	ClearTimer(g_hRegeneration[victim]);
	
	g_zasiegGranata[victim] = 1.2;
	g_obrazeniaGranata[victim] = 1.5;
	g_globalneObrazenia[victim] = 1.0;
	g_Reinkarnacja[victim] = 0;
	g_bTryb[victim] = false;
	g_iloscHP[victim] = 0;
	g_iloscMaxHP[victim] = 0;
	
	if(GetClientTeam(client) == CS_TEAM_CT && !DzisiajZabawa) {
		return;
	}
	
	event.GetString("weapon", sWeapon, sizeof(sWeapon));
	
	if(Gangs_IsClientValid(client) && IsClientInGame(victim) && Gangs_IsClientInGang(client))
	{
		if(GetClientTeam(client) != GetClientTeam(victim))
		{
			int points = 0;
			
			if(headshot)
				points += 1;
			
			if(IsWeaponSecondary(sWeapon))
				points += 1;
			else if(IsWeaponKnife(sWeapon))
				points += 2;
			else if(IsWeaponGrenade(sWeapon))
				points += 2;
			else
				points += 1;
			
			Gangs_AddPoints(g_iClientGang[client], points);
			
			if(GetEngineVersion() == Engine_CSGO)
			{
				int assister = GetClientOfUserId(event.GetInt("assister"));
				
				if(Gangs_IsClientValid(assister) && (GetClientTeam(assister) != GetClientTeam(victim)))
				{
					int apoints = 0;
				
					if(headshot)
						apoints += 1;
					
					apoints += 1;
					
					Gangs_AddPoints(g_iClientGang[assister], apoints);
				}
			}
		}
	}
}

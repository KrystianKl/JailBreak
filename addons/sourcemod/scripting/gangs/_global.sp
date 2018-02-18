enum Cache_Gang
{
	iGangID = 0,
	String:sGangName[64],
	iCredits,
	iPoints,
	bool:bChat,
	bool:bPrefix,
	String:sPrefixColor[64],
	iMaxMembers,
	iMembers
};

enum Cache_Gangs_Members
{
	iGangID = 0,
	String:sCommunityID[64],
	String:sPlayerN[MAX_NAME_LENGTH],
	iAccessLevel,
	bool:bMuted,
	bool:bOnline
};

enum Cache_Gangs_Skills
{
	iGangID = 0,
	iSkillID,
	iLevel
};

enum Cache_Skills
{
	iSkillID = 0,
	String:sSkillName[64],
	iMaxLevel
}

bool:DzisiajZabawa;
new Float:g_fGravity[MAXPLAYERS + 1];
new MoveType:gMT_MoveType[MAXPLAYERS + 1];

// Cache
int g_iCacheGang[Cache_Gang];
ArrayList g_aCacheGang = null;

int g_iCacheGangMembers[Cache_Gangs_Members];
ArrayList g_aCacheGangMembers = null;

int g_iCacheGangSkills[Cache_Gangs_Skills];
ArrayList g_aCacheGangSkills = null;

int g_iCacheSkills[Cache_Skills];
ArrayList g_aCacheSkills = null;

// Database
Handle g_hDatabase;

// Save gang names
char g_sGang[128][64];

// Fowards
Handle g_hSQLConnected = null;
Handle g_hGangCreated = null;
Handle g_hGangLeft = null;
Handle g_hGangDelete = null;
Handle g_hGangRename = null;
Handle g_hGangClientJoined = null;
Handle g_hGangMute = null;
Handle g_hRegeneration[MAXPLAYERS+1];

// Client stuff
char g_sClientID[MAXPLAYERS + 1][64];
bool g_bIsInGang[MAXPLAYERS + 1] =  { false, ... };
bool g_bTryb[MAXPLAYERS + 1] =  { false, ... };
float g_zasiegGranata[MAXPLAYERS + 1] =  { 0.0, ... };
float g_obrazeniaGranata[MAXPLAYERS + 1] =  { 0.0, ... };
float g_globalneObrazenia[MAXPLAYERS + 1] =  { 0.0, ... };
int g_Reinkarnacja[MAXPLAYERS + 1] =  { 0, ... };
int g_iloscHP[MAXPLAYERS + 1] =  { 0, ... };
int g_iloscMaxHP[MAXPLAYERS + 1] =  { 0, ... };
int g_iClientGang[MAXPLAYERS + 1] =  { 0, ... };
int g_iClientLevel[MAXPLAYERS + 1] =  { 0, ... };
bool g_bClientMuted[MAXPLAYERS + 1] =  { false, ... };

// Rename
Handle g_hRenameTimer[MAXPLAYERS + 1] =  { null, ... };
bool g_bInRename[MAXPLAYERS + 1] =  { false, ... };

// Invite
Handle g_hInviteTimer[MAXPLAYERS + 1] =  { null, ... };
int g_iInvited[MAXPLAYERS + 1] =  { -1, ... }; // Gang ID

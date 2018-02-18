#pragma newdecls required
#pragma semicolon 1

#include <EverGames_JailBreak>

#define PLUGIN_NAME JB_PLUGIN_NAME ... " - Models Core"

int g_iPrisonersSkins = 0;
int g_iGuardsSkins = 0;

char g_cPrisonersModel[128][128];
char g_cPrisonersArms[128][128];
char g_cGuardModel[128][128];
char g_cGuardArms[128][128];

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
	HookEvent("player_spawn", OnPlayerEvents, EventHookMode_Post);
}

public void OnMapStart()
{
	char file[PLATFORM_MAX_PATH];
	
	BuildPath(Path_SM, file, sizeof(file), "configs/EverGames_Models.cfg");

	if (!FileExists(file))
		SetFailState("[EverGames] Fatal error: Unable to open generic configuration file \"%s\"!", file);

	// Precache all models
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard1/guard1.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard1/guard1_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard2/guard2.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard2/guard2_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard3/guard3.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard3/guard3_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard4/guard4.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard4/guard4_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard5/guard5.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/guard5/guard5_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6_arms.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.mdl", true);
	PrecacheModel("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7_arms.mdl", true);
	
	// Shared material files for guard1 guard2, guard3, prisoner2, prisoner3, prisoner4, prisoner5, prisoner6
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/brown_eye01_an_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/police_body_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/prisoner1_body.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/tex_0086_0.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/brown_eye_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/brown_eye01_an_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/police_body_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/police_body_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/prisoner1_body.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/prisoner1_body_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/tex_0086_0.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/shared/tex_0086_1.vtf");

	// -- Guard1
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard1/hair01_ao_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard1/hair01_ao_d2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard1/sewell01_head01_au_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard1/hair01_ao_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard1/hair01_ao_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard1/sewell01_head01_au_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard1/sewell01_head01_au_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard1/guard1.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard1/guard1.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard1/guard1.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard1/guard1.vvd");
	
	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard1/guard1_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard1/guard1_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard1/guard1_arms.vvd");

	// -- Guard2
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard2/npc_ryall_head_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard2/npc_ryall_head_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard2/npc_ryall_head_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard2/guard2.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard2/guard2.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard2/guard2.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard2/guard2.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard2/guard2_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard2/guard2_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard2/guard2_arms.vvd");

	// -- Guard3
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard3/policeman_ai_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard3/policeman_head_ai_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard3/policeman_ai_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard3/policeman_ai_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard3/policeman_head_ai_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard3/policeman_head_ai_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard3/guard3.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard3/guard3.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard3/guard3.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard3/guard3.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard3/guard3_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard3/guard3_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard3/guard3_arms.vvd");

	// -- Guard4
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/eyes.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_1_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_2_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_3_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_badge.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_eyelashes.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_hair_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_hair2_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_head_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_head2_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_metal.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_shoes.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/eyes.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/eyes_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_1_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_1_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_2_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_2_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_eyelashes.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_hair_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_head_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard4/femalecop_head_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard4/guard4.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard4/guard4.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard4/guard4.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard4/guard4.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard4/guard4_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard4/guard4_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard4/guard4_arms.vvd");

	// -- Guard5
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_head_a6_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_hs_body_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_hs_head_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_head_a6_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_head_a6_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_hs_body_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_hs_body_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_hs_head_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/guard5/guard_hs_head_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard5/guard5.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard5/guard5.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard5/guard5.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard5/guard5.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard5/guard5_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard5/guard5_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/guard5/guard5_arms.vvd");

	// -- Prisoner1
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/eye_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_bottom_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_head_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_top_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoners_torso_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/eye_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_bottom_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_bottom_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_head_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_head_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_top_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoner_lt_top_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner1/prisoners_torso_d.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner1/prisoner1_arms.vvd");

	// -- Prisoner2
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/charles01_body01_au_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/charles01_head01_au_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/hair01_au_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/hair02_au_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/charles01_body01_au_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/charles01_body01_au_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/charles01_head01_au_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/charles01_head01_au_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/hair01_au_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner2/hair01_au_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner2/prisoner2_arms.vvd");

	// -- Prisoner3
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/eyes.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/gi_head_14.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/m_white_13_co.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/eyes.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/gi_head_14.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/gi_head_nml.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/m_white_13_co.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner3/m_white_13_n.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner3/prisoner3_arms.vvd");

	// -- Prisoner4
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/1.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/eye.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/gi_head_1.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/1.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/1_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/eye.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/gi_head_1.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/gi_head_nml.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner4/skin_detail.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner4/prisoner4_arms.vvd");

	// -- Prisoner5
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/denise_head01_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_brow_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_eye_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_face_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair1_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair1_d_tr.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair2_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair2_d_tr.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_lashes_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_mouth_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_sh_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/shirt_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/denise_head01_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/denise_head01_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_brow_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_eye_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_eye_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_face_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_face_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair1_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair1_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair2_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_hair2_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_lashes_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_mouth_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/lara_sh_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/shirt_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner5/shirt_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner5/prisoner5_arms.vvd");

	// -- Prisoner6
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner6/postman01_eye01_an_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner6/prisonerfrombus_head02_au_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner6/prisonerfrombus_head02_au_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner6/prisonerfrombus_head02_au_normal.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner6/prisoner6_arms.vvd");

	// -- Prisoner7
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/4.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/arms.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/eye.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/murphy_hospital_clothes_d.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/4.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/4_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/eye.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/murphy_hospital_clothes_d.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/murphy_hospital_clothes_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/jailbreak/prisoner7/skin_detail.vtf");

	// Player model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7.vvd");

	// Arms model
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/jailbreak/prisoner7/prisoner7_arms.vvd");
	
	PrepareConfig(file);
}

public Action OnPlayerEvents(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (name[7] == 's')
	{
		if (IsValidClient(client) && !GetEntProp(client, Prop_Send, "m_bIsControllingBot"))
		{
			int g_iPrisonersRand = GetRandomInt(0, g_iPrisonersSkins - 1);
			int g_iGuardsRand = GetRandomInt(0, g_iGuardsSkins - 1);

			switch (GetClientTeam(client))
			{
				case CS_TEAM_T: {
					SetEntityModel(client, g_cPrisonersModel[g_iPrisonersRand]);
					SetEntPropString(client, Prop_Send, "m_szArmsModel", g_cPrisonersArms[g_iPrisonersRand]);
					CreateTimer(0.15, RemoveItemTimer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
				}
				case CS_TEAM_CT: {
					SetEntityModel(client, g_cGuardModel[g_iGuardsRand]);
					SetEntPropString(client, Prop_Send, "m_szArmsModel", g_cGuardArms[g_iGuardsRand]);
					CreateTimer(0.15, RemoveItemTimer, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

void PrepareConfig(const char[] file)
{
	Handle kv = CreateKeyValues("EverGames_JailBreak");

	FileToKeyValues(kv, file);

	if (KvJumpToKey(kv, "Prisoners")) {
		char g_cSectionName[128], g_cModelPath[128], g_cArmsModel[128];

		KvGotoFirstSubKey(kv);

		do {
			KvGetSectionName(kv, g_cSectionName, sizeof(g_cSectionName));

			if (KvGetString(kv, "Model", g_cModelPath, sizeof(g_cModelPath)) && KvGetString(kv, "Arms", g_cArmsModel, sizeof(g_cArmsModel))) {
				strcopy(g_cPrisonersModel[g_iPrisonersSkins], sizeof(g_cPrisonersModel[]), g_cModelPath);
				strcopy(g_cPrisonersArms[g_iPrisonersSkins], sizeof(g_cPrisonersArms[]), g_cArmsModel);

				PrecacheModel(g_cModelPath, true);
				PrecacheModel(g_cArmsModel, true);
			} else LogError("[EverGames] Player model or arms for \"%s\" is incorrect!", g_cSectionName);
		} while (KvGotoNextKey(kv));
	} else SetFailState("[EverGames] Fatal error: Missing \"Prisoners\" section!");
	
	KvRewind(kv);

	if (KvJumpToKey(kv, "Guards")) {
		char g_cSectionName[128], g_cModelPath[128], g_cArmsModel[128];

		KvGotoFirstSubKey(kv);

		do {
			KvGetSectionName(kv, g_cSectionName, sizeof(g_cSectionName));

			if (KvGetString(kv, "Model", g_cModelPath, sizeof(g_cModelPath)) && KvGetString(kv, "Arms", g_cArmsModel, sizeof(g_cArmsModel))) {
				strcopy(g_cGuardModel[g_iGuardsSkins], sizeof(g_cGuardModel[]), g_cModelPath);
				strcopy(g_cGuardArms[g_iGuardsSkins], sizeof(g_cGuardArms[]), g_cArmsModel);
				
				PrecacheModel(g_cModelPath, true);
				PrecacheModel(g_cArmsModel, true);
			} else LogError("[EverGames] Player model or arms for \"%s\" is incorrect!", g_cSectionName);
		}
		while (KvGotoNextKey(kv));
	} else SetFailState("[EverGames] Fatal error: Missing \"Guards\" g_cSectionName!");

	KvRewind(kv);

	CloseHandle(kv);
}

public Action RemoveItemTimer(Handle timer ,any ref)
{
	int client = EntRefToEntIndex(ref);

	if (client != INVALID_ENT_REFERENCE)
	{
		int item = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

		if (item > 0)
		{
			RemovePlayerItem(client, item);

			Handle ph=CreateDataPack();
			WritePackCell(ph, EntIndexToEntRef(client));
			WritePackCell(ph, EntIndexToEntRef(item));
			CreateTimer(0.15 , AddItemTimer, ph, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action AddItemTimer(Handle timer ,any ph)
{
	ResetPack(ph);

	int client = EntRefToEntIndex(ReadPackCell(ph));
	int item = EntRefToEntIndex(ReadPackCell(ph));

	if (client != INVALID_ENT_REFERENCE && item != INVALID_ENT_REFERENCE)
	{
		EquipPlayerWeapon(client, item);
	}
}
// Source: https://forums.alliedmods.net/showthread.php?t=315405

#include <sourcemod>
#include <sdktools>
#include <dhooks>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

public Plugin myinfo = {
    name = "L4D2 FirebulletsFix",
    author = "Garamond",
    description = "",
    version = VERSION,
    url = ""
};

#define DEBUG 0

// From command "maxplayers".
#define L4D2_MAXPLAYERS 18

#define TEAM_SURVIVORS 2

Handle g_weapon_shoot_position;
float g_old_weapon_shoot_position[L4D2_MAXPLAYERS + 1][3];

public void OnPluginStart()
{
    Handle gamedata = LoadGameConfigFile("l4d2_firebullets_fix");

    // Vector CBasePlayer::Weapon_ShootPosition()
    g_weapon_shoot_position = DHookCreate(GameConfGetOffset(gamedata, "CBasePlayer::Weapon_ShootPosition"), HookType_Entity, ReturnType_Vector, ThisPointer_CBaseEntity, on_weapon_shoot_position);

    CloseHandle(gamedata);
}

public void OnClientPutInServer(int client)
{
    if (!IsFakeClient(client)) {
        DHookEntity(g_weapon_shoot_position, true, client);
    }
}

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (!IsFakeClient(client) && IsPlayerAlive(client) && GetClientTeam(client) == TEAM_SURVIVORS) {
        GetClientEyePosition(client, g_old_weapon_shoot_position[client]);
    }
    return Plugin_Continue;
}

MRESReturn on_weapon_shoot_position(int pThis, DHookReturn hReturn)
{
    #if DEBUG
    float vec[3];
    DHookGetReturnVector(hReturn, vec);
    PrintToChatAll("%N Old ShootPosition: %.2f, %.2f, %.2f", pThis, g_old_weapon_shoot_position[pThis][0], g_old_weapon_shoot_position[pThis][1], g_old_weapon_shoot_position[pThis][2]);
    PrintToChatAll("%N New ShootPosition: %.2f, %.2f, %.2f", pThis, vec[0], vec[1], vec[2]);
    #endif

    DHookSetReturnVector(hReturn, g_old_weapon_shoot_position[pThis]);
    return MRES_Supercede;
}
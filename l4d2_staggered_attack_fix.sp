#include <sourcemod>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

public Plugin myinfo = {
    name = "L4D2 StaggeredAttackFix",
    author = "Garamond",
    description = "",
    version = VERSION,
    url = "https://github.com/garamond13/L4D2-Fixes"
};

#define TEAM_INFECTED 3

public Action OnPlayerRunCmd(int client, int& buttons, int& impulse, float vel[3], float angles[3], int& weapon, int& subtype, int& cmdnum, int& tickcount, int& seed, int mouse[2])
{
    if (IsFakeClient(client) && GetClientTeam(client) == TEAM_INFECTED) {
        int zombie_class = GetEntProp(client, Prop_Send, "m_zombieClass");
        if (zombie_class >= 1 && zombie_class <= 6 && GetEntPropFloat(client, Prop_Send, "m_staggerTimer", 1) > -1.0) {
            buttons &= ~IN_ATTACK2;
        }
    }
    return Plugin_Continue;
}
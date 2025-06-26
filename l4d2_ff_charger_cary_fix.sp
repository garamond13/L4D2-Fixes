#include <sourcemod>
#include <sdkhooks>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

public Plugin myinfo = {
    name = "L4D2 FFChargerCarryFix",
    author = "Garamond",
    description = "",
    version = VERSION,
    url = "https://github.com/garamond13/L4D2-Fixes"
};

#define DEBUG 0

#define TEAM_SURVIVORS 2

public void OnPluginStart()
{
    HookEvent("charger_carry_start", event_charger_carry_start);
    HookEvent("charger_carry_end", event_charger_carry_end);
}

void event_charger_carry_start(Event event, const char[] name, bool dontBroadcast)
{
    #if DEBUG
    PrintToChatAll("event_charger_carry_start(): victim = %N", GetClientOfUserId(GetEventInt(event, "victim")));
    #endif

    SDKHook(GetClientOfUserId(GetEventInt(event, "victim")), SDKHook_OnTakeDamage, on_take_damage_charger_carry);
}

void event_charger_carry_end(Event event, const char[] name, bool dontBroadcast)
{
    #if DEBUG
    PrintToChatAll("event_charger_carry_end(): victim = %N", GetClientOfUserId(GetEventInt(event, "victim")));
    #endif

    SDKUnhook(GetClientOfUserId(GetEventInt(event, "victim")), SDKHook_OnTakeDamage, on_take_damage_charger_carry);
}

Action on_take_damage_charger_carry(int victim, int& attacker, int& inflictor, float& damage, int& damagetype)
{
    if (attacker > 0 && attacker <= MaxClients && GetClientTeam(attacker) == TEAM_SURVIVORS) {

        #if DEBUG
        PrintToChatAll("on_take_damage_charger_carry(): attacker = %N, victim = %N", attacker, victim);
        #endif

        return Plugin_Handled;
    }
    return Plugin_Continue;
}
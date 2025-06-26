#include <sourcemod>
#include <sdktools>
#include <actions>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

public Plugin myinfo = {
    name = "L4D2 CommonsShoveFix",
    author = "Garamond",
    description = "",
    version = VERSION,
    url = ""
};

#define DEBUG 0

// Source: left4dhooks_anim
enum
{
    L4D2_ACT_TERROR_JUMP_LANDING = 662,
    L4D2_ACT_TERROR_JUMP_LANDING_HARD,
    L4D2_ACT_TERROR_JUMP_LANDING_NEUTRAL,
    L4D2_ACT_TERROR_JUMP_LANDING_HARD_NEUTRAL
};

Handle g_my_next_bot_pointer;
Handle g_get_body_interface;
Handle g_get_locomotion_interface;
int g_m_ladder_offset;

public void OnPluginStart()
{
    Handle gamedata = LoadGameConfigFile("l4d2_commons_shove_fix");

    // INextBot* CBaseEntity::MyNextBotPointer()
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "CBaseEntity::MyNextBotPointer");
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
    g_my_next_bot_pointer = EndPrepSDKCall();

    // IBody* INextBot::GetBodyInterface()
    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "INextBot::GetBodyInterface");
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
    g_get_body_interface = EndPrepSDKCall();

    // ZombieBotLocomotion* INextBot::GetLocomotionInterface()
    StartPrepSDKCall(SDKCall_Raw);
    PrepSDKCall_SetFromConf(gamedata, SDKConf_Virtual, "INextBot::GetLocomotionInterface");
    PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
    g_get_locomotion_interface = EndPrepSDKCall();

    g_m_ladder_offset = GameConfGetOffset(gamedata, "ZombieBotLocomotion::m_ladder");

    CloseHandle(gamedata);
}

public void OnActionCreated(BehaviorAction action, int actor, const char[] name)
{
    if (!strcmp(name, "InfectedShoved")) {
        
        // For common infected shove immunity on landing fix.
        __action_setlistener(action, __action_processor_OnStart, infected_shoved_on_start, false);
        
        // For common infected shove direction fix.
        __action_setlistener(action, __action_processor_OnShoved, infected_shoved_on_shoved, false);
    }
}

Action infected_shoved_on_start(any action, int actor, any priorAction, ActionResult result)
{
    Address my_next_bot_pointer = SDKCall(g_my_next_bot_pointer, actor);
    
    // Common infected shove immunity on landing fix.
    // Source: https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_common_shove
    //

    Address body_interface = SDKCall(g_get_body_interface, my_next_bot_pointer);

    // Get m_activity and check for landing.
    switch (LoadFromAddress(body_interface + view_as<Address>(80), NumberType_Int32)) {
        case
            L4D2_ACT_TERROR_JUMP_LANDING,
            L4D2_ACT_TERROR_JUMP_LANDING_HARD,
            L4D2_ACT_TERROR_JUMP_LANDING_NEUTRAL,
            L4D2_ACT_TERROR_JUMP_LANDING_HARD_NEUTRAL: {

            #if DEBUG
            PrintToChatAll("infected_shoved_on_start(): L4D2_ACT_TERROR_JUMP_LANDING");
            #endif

            // Get m_activityType and clear ACTIVITY_UNINTERRUPTIBLE flag.
            Address activity_type = body_interface + view_as<Address>(84);
            StoreToAddress(activity_type, LoadFromAddress(activity_type, NumberType_Int32) & ~4, NumberType_Int32, false);
        }
    }

    //

    // Common infected shove immunity while climbing fix.
    // Source: https://github.com/Target5150/MoYu_Server_Stupid_Plugins/tree/master/The%20Last%20Stand/l4d_fix_common_shove
    StoreToAddress(SDKCall(g_get_locomotion_interface, my_next_bot_pointer) + view_as<Address>(g_m_ladder_offset), Address_Null, NumberType_Int32, false);

    return Plugin_Continue;
}

// Common infected shove direction fix.
// Source: https://forums.alliedmods.net/showthread.php?t=319988
Action infected_shoved_on_shoved(any action, int actor, int entity, ActionDesiredResult result)
{
    char classname[8];
    GetEntityClassname(actor, classname, sizeof(classname));

    #if DEBUG
    PrintToChatAll("infected_shoved_on_shoved(): %s", classname);
    #endif

    if (!strcmp(classname, "witch")) {
        return Plugin_Continue;
    }
    return Plugin_Handled;
}
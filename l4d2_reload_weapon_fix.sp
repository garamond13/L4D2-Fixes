#include <sourcemod>

#pragma semicolon 1
#pragma newdecls required

#define VERSION "1.0.0"

public Plugin myinfo = {
    name = "L4D2 ReloadWeaponFix",
    author = "Garamond",
    description = "When do you get ammo from reload better match with animations",
    version = VERSION,
    url = "https://github.com/garamond13/L4D2-Fixes"
};

public void OnPluginStart()
{
    HookEvent("weapon_reload", event_weapon_reload);
}

void event_weapon_reload(Event event, const char[] name, bool dontBroadcast)
{
    int userid = GetEventInt(event, "userid");
    int weapon = GetEntPropEnt(GetClientOfUserId(userid), Prop_Data, "m_hActiveWeapon");
    
    // The classname will have prefix weapon_
    char weapon_name[24];
    GetEntityClassname(weapon, weapon_name, sizeof(weapon_name));
    
    // FIXME?: When down animations are longer. But you can't switch weapons anyway.
    if (!strcmp(weapon_name[7], "pistol")) {
        if (GetEntProp(weapon, Prop_Send, "m_isDualWielding")) {
            if (GetEntProp(weapon, Prop_Data, "m_iClip1") > 0) {
                set_pistol_ammo_timer(1.8, weapon, 30, userid);
            }
            else {
                set_pistol_ammo_timer(2.1, weapon, 30, userid);
            }
        }
        else {
            if (GetEntProp(weapon, Prop_Data, "m_iClip1") > 0) {
                set_pistol_ammo_timer(1.2, weapon, 15, userid);
            }
            else {
                set_pistol_ammo_timer(1.5, weapon, 15, userid);
            }
        }
    }
    else if (!strcmp(weapon_name[7], "pistol_magnum")) {
        if (GetEntProp(weapon, Prop_Data, "m_iClip1") > 0) {
            set_pistol_ammo_timer(1.2, weapon, 8, userid);
        }
        else {
            set_pistol_ammo_timer(1.5, weapon, 8, userid);
        }
    }

    else if (!strcmp(weapon_name[7], "smg") || !strcmp(weapon_name[7], "smg_silenced")) {
        set_ammo_timer(1.6, weapon, 50, userid);
    }
    else if (!strcmp(weapon_name[7], "smg_mp5")) {
        set_ammo_timer(2.4, weapon, 50, userid);
    }
    else if (!strcmp(weapon_name[7], "rifle")) {
        set_ammo_timer(1.6, weapon, 50, userid);
    }
    else if (!strcmp(weapon_name[7], "rifle_ak47")) {
        set_ammo_timer(1.8, weapon, 40, userid);
    }
    else if (!strcmp(weapon_name[7], "rifle_desert")) {
        set_ammo_timer(2.5, weapon, 60, userid);
    }
    else if (!strcmp(weapon_name[7], "rifle_sg552")) {
        set_ammo_timer(2.6, weapon, 50, userid);
    }
    else if (!strcmp(weapon_name[7], "hunting_rifle")) {
        set_ammo_timer(2.5, weapon, 15, userid);
    }
    else if (!strcmp(weapon_name[7], "sniper_military")) {
        set_ammo_timer(2.5, weapon, 30, userid);
    }
    else if (!strcmp(weapon_name[7], "sniper_scout")) {
        set_ammo_timer(2.4, weapon, 15, userid);
    }
    else if (!strcmp(weapon_name[7], "sniper_awp")) {
        set_ammo_timer(3.3, weapon, 20, userid);
    }
    else if (!strcmp(weapon_name[7], "grenade_launcher")) {
        set_ammo_timer(3.0, weapon, 1, userid);
    }
}

void set_ammo_timer(float time, int weapon, int clip_max, int userid)
{
    Handle pack;
    CreateDataTimer(time, set_ammo, pack, TIMER_FLAG_NO_MAPCHANGE);
    WritePackCell(pack, weapon);
    WritePackCell(pack, clip_max);
    WritePackCell(pack, userid);
}

void set_pistol_ammo_timer(float time, int weapon, int clip_max, int userid)
{
    Handle pack;
    CreateDataTimer(time, set_pistol_ammo, pack, TIMER_FLAG_NO_MAPCHANGE);
    WritePackCell(pack, weapon);
    WritePackCell(pack, clip_max);
    WritePackCell(pack, userid);
}

void set_ammo(Handle tiemr, Handle data)
{
    // Unpack data.
    ResetPack(data);
    int weapon = ReadPackCell(data);
    int clip_max = ReadPackCell(data);
    int client = GetClientOfUserId(ReadPackCell(data));

    if (client && GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon") == weapon && GetEntProp(weapon, Prop_Data, "m_bInReload")) {
        int primary_ammo_type = GetEntProp(weapon, Prop_Data, "m_iPrimaryAmmoType");
        int ammo = GetEntProp(client, Prop_Data, "m_iAmmo", 4, primary_ammo_type);
        int clip = GetEntProp(weapon, Prop_Data, "m_iClip1");
        int clip_to_max = clip_max - clip;

        // Set clip ammo.
        if (ammo + clip > clip_max) {
            SetEntProp(weapon, Prop_Data, "m_iClip1", clip_max);
        }
        else {
            SetEntProp(weapon, Prop_Data, "m_iClip1", ammo + clip);
        }
        
        // Set total ammo.
        if (ammo > clip_to_max) {
            SetEntProp(client, Prop_Data, "m_iAmmo", ammo - clip_to_max, 4, primary_ammo_type);
        }
        else {
            SetEntProp(client, Prop_Data, "m_iAmmo", 0, 4, primary_ammo_type);
        }
    }
}

void set_pistol_ammo(Handle tiemr, Handle data)
{
    // Unpack data.
    ResetPack(data);
    int weapon = ReadPackCell(data);
    int clip_max = ReadPackCell(data);
    int client = GetClientOfUserId(ReadPackCell(data));

    if (client && GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon") == weapon && GetEntProp(weapon, Prop_Data, "m_bInReload")) {
        SetEntProp(weapon, Prop_Data, "m_iClip1", clip_max);
    }
}
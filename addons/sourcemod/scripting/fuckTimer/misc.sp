#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <fuckTimer_stocks>

enum struct PluginData {
    ConVar ItemCleanup;
}
PluginData Core;

public Plugin myinfo =
{
    name = FUCKTIMER_PLUGIN_NAME ... "Misc",
    author = FUCKTIMER_PLUGIN_AUTHOR,
    description = FUCKTIMER_PLUGIN_DESCRIPTION,
    version = FUCKTIMER_PLUGIN_VERSION,
    url = FUCKTIMER_PLUGIN_URL
};

public void OnPluginStart()
{
    fuckTimer_StartConfig("misc");
    Core.ItemCleanup = AutoExecConfig_CreateConVar("misc_item_cleanup", "1", "Enable (1) or Disable (1) cleaning up of items and weapons?", _, true, 0.0, true, 1.0);
    fuckTimer_EndConfig();

    HookEvent("round_poststart", Event_RoundPostStart);
    HookEvent("player_death", Event_PlayerDeath);

    AddCommandListener(Command_Drop, "drop");
}

public void Event_RoundPostStart(Event event, const char[] name, bool dontBroadcast)
{
    ItemCleanup();
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    ItemCleanup();
}

void ItemCleanup()
{
    if (!Core.ItemCleanup.BoolValue)
    {
        return;
    }

    for (int iWeapon = MaxClients; iWeapon < MAX_ENTITIES; iWeapon++)
    {
        if (IsValidEntity(iWeapon))
        {
            char sClassname[32];
            GetEntityClassname(iWeapon, sClassname, sizeof(sClassname));

            if (StrContains(sClassname, "weapon", false) != -1 || StrContains(sClassname, "item", false) != -1)
            {
                RemoveEntity(iWeapon);
            }
        }
    }
}

public Action Command_Drop(int client, const char[] command, int args)
{
    if (!Core.ItemCleanup.BoolValue)
    {
        return;
    }

    if (client)
    {
        int iWeapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");

        char sClassname[32];
        GetEntityClassname(iWeapon, sClassname, sizeof(sClassname));

        if (StrContains(sClassname, "weapon", false) != -1 || StrContains(sClassname, "item", false) != -1)
        {
            SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", -1);
            RemoveEntity(iWeapon);
        }
    }
}
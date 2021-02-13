#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <fuckZones>

#define EFFECT_NAME "fuckTimer"

GlobalForward g_fwOnEnteringZone = null;
GlobalForward g_fwOnLeavingZone = null;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	g_fwOnEnteringZone = new GlobalForward("fuckTimer_OnEnteringZone", ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_fwOnLeavingZone = new GlobalForward("fuckTimer_OnLeavingZone", ET_Ignore, Param_Cell, Param_Cell, Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell);

	RegPluginLibrary("fuckTimer_zones");

	return APLRes_Success;
}

public void fuckZones_OnEffectsReady()
{
	fuckZones_RegisterEffect(EFFECT_NAME, OneZoneStartTouch, INVALID_FUNCTION, OnZoneEndTouch);

	fuckZones_RegisterEffectKey(EFFECT_NAME, "Tier", "0");

	fuckZones_RegisterEffectKey(EFFECT_NAME, "Start", "0");
	fuckZones_RegisterEffectKey(EFFECT_NAME, "End", "0");
	fuckZones_RegisterEffectKey(EFFECT_NAME, "Misc", "0");

	fuckZones_RegisterEffectKey(EFFECT_NAME, "Stage", "0");
	fuckZones_RegisterEffectKey(EFFECT_NAME, "Checkpoint", "0");

	fuckZones_RegisterEffectKey(EFFECT_NAME, "Bonus", "0");
}

public void OneZoneStartTouch(int client, int entity, StringMap values)
{
	char sName[MAX_ZONE_NAME_LENGTH];
	fuckZones_GetZoneName(entity, sName, sizeof(sName));

	Call_StartForward(g_fwOnEnteringZone);
	Call_PushCell(client);
	Call_PushCell(entity);
	Call_PushString(sName);
	Call_PushCell(IsStartZone(values));
	Call_PushCell(IsEndZone(values));
	Call_PushCell(GetStageNumber(values));
	Call_PushCell(GetCheckpointNumber(values));
	Call_Finish();
}

public void OnZoneEndTouch(int client, int entity, StringMap values)
{
	char sName[MAX_ZONE_NAME_LENGTH];
	fuckZones_GetZoneName(entity, sName, sizeof(sName));

	Call_StartForward(g_fwOnLeavingZone);
	Call_PushCell(client);
	Call_PushCell(entity);
	Call_PushString(sName);
	Call_PushCell(IsStartZone(values));
	Call_PushCell(IsEndZone(values));
	Call_PushCell(GetStageNumber(values));
	Call_PushCell(GetCheckpointNumber(values));
	Call_Finish();
}

bool IsStartZone(StringMap values)
{
	char sValue[MAX_KEY_VALUE_LENGTH];
	if (GetZoneValue(values, "Start", sValue, sizeof(sValue)))
	{
		return view_as<bool>(StringToInt(sValue));
	}
	return false;
}

bool IsEndZone(StringMap values)
{
	char sValue[MAX_KEY_VALUE_LENGTH];
	if (GetZoneValue(values, "End", sValue, sizeof(sValue)))
	{
		return view_as<bool>(StringToInt(sValue));
	}
	return false;
}

int GetStageNumber(StringMap values)
{
	char sValue[MAX_KEY_VALUE_LENGTH];
	if (GetZoneValue(values, "Stage", sValue, sizeof(sValue)))
	{
		return StringToInt(sValue);
	}
	return -1;
}

int GetCheckpointNumber(StringMap values)
{
	char sValue[MAX_KEY_VALUE_LENGTH];
	if (GetZoneValue(values, "Checkpoint", sValue, sizeof(sValue)))
	{
		return StringToInt(sValue);
	}
	return -1;
}

bool GetZoneValue(StringMap values, const char[] key, char[] value, int length)
{
	char sKey[MAX_KEY_NAME_LENGTH];
	StringMapSnapshot keys = values.Snapshot();

	for (int x = 0; x < keys.Length; x++)
	{
		keys.GetKey(x, sKey, sizeof(sKey));

		if (strcmp(sKey, key, false) == 0)
		{
			values.GetString(sKey, value, length);

			delete keys;
			return true;
		}
	}

	delete keys;
	return false;
}
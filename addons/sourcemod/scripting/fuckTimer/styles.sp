#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>
#include <intmap>
#include <ripext>
#include <fuckTimer_stocks>
#include <fuckTimer_api>
#include <fuckTimer_styles>

enum struct PluginData
{
    HTTPClient HTTPClient;

    IntMap Styles;
}
PluginData Core;

public Plugin myinfo =
{
    name = FUCKTIMER_PLUGIN_NAME ... "Styles",
    author = FUCKTIMER_PLUGIN_AUTHOR,
    description = FUCKTIMER_PLUGIN_DESCRIPTION,
    version = FUCKTIMER_PLUGIN_VERSION,
    url = FUCKTIMER_PLUGIN_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    CreateNative("fuckTimer_GetStyleName", Native_GetStyleName);
    CreateNative("fuckTimer_GetStyles", Native_GetStyles);

    RegPluginLibrary("fuckTimer_styles");

    return APLRes_Success;
}

public void fuckTimer_OnAPIReady()
{
    Core.HTTPClient = fuckTimer_GetHTTPClient();

    LoadStyles();
}

void LoadStyles()
{
    char sEndpoint[MAX_URL_LENGTH];
    FormatEx(sEndpoint, sizeof(sEndpoint), "Style");

    Core.HTTPClient.Get(sEndpoint, GetAllStyles);
}

public void GetAllStyles(HTTPResponse response, any value, const char[] error)
{
    if (response.Status != HTTPStatus_OK)
    {
        SetFailState("[Styles.GetAllStyles] Something went wrong. Status Code: %d, Error: %s", response.Status, error);
        return;
    }

    JSONArray jsonArray = view_as<JSONArray>(response.Data);

    if (jsonArray.Length < 1)
    {
        SetFailState("[Styles.GetAllStyles] We didn't found any styles...");
        return;
    }

    Core.Styles = new IntMap();

    JSONObject jsonObject = null;
    Style style;

    for (int i = 0; i < jsonArray.Length; i++)
    {
        jsonObject = view_as<JSONObject>(jsonArray.Get(i));

        style.Id = jsonObject.GetInt("Id");
        jsonObject.GetString("Name", style.Name, sizeof(Style::Name));
        style.IsActive = jsonObject.GetBool("IsActive");

        LogMessage("[Styles.GetAllStyles] Style: %s (Id: %d, IsActive: %d)", style.Name, style.Id, style.IsActive);

        Core.Styles.SetArray(style.Id, style, sizeof(style));

        delete jsonObject;
    }
}

public int Native_GetStyleName(Handle plugin, int numParams)
{
    int iStyle = GetNativeCell(1);
    int iLength = GetNativeCell(3);

    Style style;
    bool success = Core.Styles.GetArray(iStyle, style, sizeof(style));

    if (success && SetNativeString(2, style.Name, iLength) == SP_ERROR_NONE)
    {
        return true;
    }

    return false;
}

public any Native_GetStyles(Handle plugin, int numParams)
{
    return Core.Styles;
}
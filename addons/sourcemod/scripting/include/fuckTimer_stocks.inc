#if defined _fuckTimer_stocks_included
    #endinput
#endif
#define _fuckTimer_stocks_included

#include <autoexecconfig>

#define FUCKTIMER_PLUGIN_NAME "fuckTimer - "
#define FUCKTIMER_PLUGIN_AUTHOR "fuckTimer Contributors"
#define FUCKTIMER_PLUGIN_DESCRIPTION ""
#define FUCKTIMER_PLUGIN_VERSION "1.0.0-devvvvvvvvvvvvvvvv"
#define FUCKTIMER_PLUGIN_URL "github.com/fuckTimer"

#define fuckTimer_BASE_CLOUD_URL "https://fucktimer.cloud/file"
#define MAX_URL_LENGTH 256
#define MIN_BASE_URL_LENGTH 4
#define MIN_API_KEY_LENGTH 12

stock void fuckTimer_StartConfig(char[] file, char[] directory = "fuckTimer")
{
    AutoExecConfig_SetCreateDirectory(true);
    AutoExecConfig_SetCreateFile(true);
    AutoExecConfig_SetFile(file, directory);
}

stock void fuckTimer_EndConfig()
{
    AutoExecConfig_ExecuteFile();
    AutoExecConfig_CleanFile();
}

stock void fuckTimer_GetCurrentWorkshopMap(char[] sMap, int iMapSize)
{
	GetCurrentMap(sMap, iMapSize);
	ReplaceString(sMap, iMapSize, "/", "-", false);
} 
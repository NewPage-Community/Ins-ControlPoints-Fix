#include <sdkhooks>
#include <sdktools>

#define MAXCP 20

bool CPCappers[MAXCP][MAXPLAYERS];

public Plugin myinfo = 
{
	name        = "Ins Control Points Fix",
	author      = "Gunslinger",
	description = "Fix Control Points bug for Insurgency",
	version     = "1.0",
	url         = "https://new-page.xyz"
};

public void OnPluginStart()
{
	HookEvent("controlpoint_captured", CPCapturedPre, EventHookMode_Pre);
	HookEvent("controlpoint_captured", CPCaptured);
	HookEvent("controlpoint_starttouch", CPStartTouch, EventHookMode_Post);
	HookEvent("controlpoint_endtouch", CPEndTouch, EventHookMode_Post);
}

public void OnMapStart()
{
	// Clean array
	for (int i = 0; i < MAXCP; i++)
		for (int j = 0; j < MAXPLAYERS; j++)
			CPCappers[i][j] = false;
}

/*
"controlpoint_captured"
{
	"priority" "short"
	"cp" "byte"
	"cappers" "string"
	"cpname" "string"
	"team" "byte"
	"oldteam" "byte"
}
*/
public Action CPCapturedPre(Handle event, const char[] name, bool dontBroadcast)
{
	char FixCappers[MAXPLAYERS];
	int cp = GetEventInt(event, "cp");
	int team = GetEventInt(event, "team");

	for (int capper = 1, index = 0; capper < MaxClients; capper++)
		if (IsClientInGame(capper) && GetClientTeam(capper) == team && CPCappers[cp][capper])
			FixCappers[index++] = capper;
	
	SetEventString(event, "cappers", FixCappers);
	return Plugin_Changed;
}

public Action CPCaptured(Handle event, const char[] name, bool dontBroadcast)
{
	char cappers[MAXPLAYERS];
	GetEventString(event, "cappers", cappers, sizeof(cappers));
	int cappersLength = strlen(cappers);
	for (int i = 0; i < cappersLength; i++)
	{
		int client = cappers[i];
		if (IsClientInGame(client) && IsClientConnected(client) && IsPlayerAlive(client) && !IsFakeClient(client))
			PrintToChatAll("[capper] %N", client);
	}
	return Plugin_Continue;
}

/*
"controlpoint_starttouch"
{
	"area" "byte"
	"object" "short"
	"player" "short"
	"team" "short"
	"owner" "short"
	"type" "short"
}
*/
public Action CPStartTouch(Handle event, const char[] name, bool dontBroadcast)
{
	int area = GetEventInt(event, "area");
	int player = GetEventInt(event, "player");
	CPCappers[area][player] = true;
}

/*
"controlpoint_endtouch"
{
	"owner" "short"
	"player" "short"
	"team" "short"
	"area" "byte"
}
*/
public Action CPEndTouch(Handle event, const char[] name, bool dontBroadcast)
{
	int area = GetEventInt(event, "area");
	int player = GetEventInt(event, "player");
	CPCappers[area][player] = false;
}
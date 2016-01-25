#include <sourcemod>

public OnPluginStart()
{
	CreateTimer(5.0, Change);
}

public Action:Change(Handle:Timer)
{
	decl String:MapName[255];
	GetCurrentMap(MapName, 255);
	PrintToServer("Restarting Map to Fix Entity Numbers");
	ServerCommand("changelevel %s", MapName);
}
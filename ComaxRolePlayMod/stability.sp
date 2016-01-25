/*	Stability extension for Comax RP Mod.
*	@author	Reloaded.
*/

new String:PPosPluginPath[PLATFORM_MAX_PATH];
new Handle:g_restartinterval = INVALID_HANDLE;
new RestartIntervalMax; //Initalized later with a CVAR.
new Float:ClientOriginStart[32][3];


public ComaxStability()
{
	g_restartinterval = CreateConVar("sm_restartinterval", "-1", "Set interval to restart the map! In minutes! -1 for disabled.", FCVAR_PLUGIN);
	HookConVarChange(g_restartinterval, restartintervalchange);
	RestartIntervalMax = GetConVarInt(g_restartinterval);
	BuildPath(Path_SM, PPosPluginPath, sizeof(PPosPluginPath), "data/roleplay/Comax/PlayersPosition.txt");
	PrintToServer("Setting RestartIntervalMax to %d (%d)", RestartIntervalMax, GetConVarInt(g_restartinterval));
}


public restartintervalchange(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(StringToInt(newValue) <= 0) 
	{
		if(StringToInt(newValue) == -1)
		{
			RestartIntervalMax = StringToInt(newValue);
			PrintToServer("Comax: Restart Disabled.");
		} else {
			RestartIntervalMax = StringToInt(oldValue);
			PrintToServer("Comax: CVAR Change Hook reporting, the value entered is too small %d. Keeping value %d (%s).", RestartIntervalMax, oldValue);
		}
	} else {
		RestartIntervalMax = StringToInt(newValue);
		PrintToServer("Comax: Got CVAR Change. The restart interval now is %d (%s)", RestartIntervalMax, newValue);
	}
}


public Action:ClientTeleStart(Handle:timer, any:client)
{
	TeleportEntity(client, ClientOriginStart[client], NULL_VECTOR, NULL_VECTOR);
}

public GetPlayersPosition(client)
{
	new Handle:DB = CreateKeyValues("PlayersPosition");
	FileToKeyValues(DB, PPosPluginPath);
	
	new String:SteamID[52];
	GetClientAuthString(client, SteamID, sizeof(SteamID));
	
	if(KvJumpToKey(DB, SteamID, false))
	{	
		new Float:origin[3];
		origin[0] = KvGetFloat(DB, "x");
		origin[1] = KvGetFloat(DB, "y");
		origin[2] = KvGetFloat(DB, "z");
		PrintToChat(client, "\n\x01[\x04Comax\x01] Please wait \x047 seconds\x01... We're \x04teleporting\x01 you back to where \x04you were\x01!\n");
		ClientOriginStart[client] = origin;
		CreateTimer(7.0, ClientTeleStart, client);
		//SetEntPropVector(client, Prop_Send, "m_vecOrigin", origin);
		
		//TeleportEntity(client, origin, NULL_VECTOR, NULL_VECTOR);
		//DispatchKeyValue(client, "origin"
		//DispatchKeyValueFloat(client, "origin", origin);
		
		KvDeleteKey(DB, "x");
		KvDeleteKey(DB, "y");
		KvDeleteKey(DB, "z");
	}
	KvRewind(DB);
	KeyValuesToFile(DB, PPosPluginPath);
	CloseHandle(DB);
}

public Action:TimerForcerespawn(Handle:timer)
{
	ServerCommand("mp_forcerespawn 0");
}

//Goes under DisplayHud(Handle:Timer, any:Client) after the first if statement.
public ShowRestartTimer(Client)
{
	if(RestartIntervalMax < 11 && RestartIntervalMax > 0) {
		//10 min to restart
		SetHudTextParams(0.815, -1.0, 1.0, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);

		ShowHudText(Client, -1, "Comax Message:\nThe Map will restart in\n%d Minutes!", RestartIntervalMax);

	}
}

//This gets called from comaxrpmod.sp under ComaxClientPutInServer();
public CheckPlayerRestart(Client)
{
	if(GetGameTime() < 20)
	{
		if(GetGameTime() < 5)
			CreateTimer(15.0, TimerForcerespawn);
		GetPlayersPosition(Client);
	}
}

public SavePlayersPosition()
{
	new Handle:DB = CreateKeyValues("PlayersPosition");
	FileToKeyValues(DB, PPosPluginPath);
	
	for(new i = 1;i<GetMaxClients();i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			decl String:SteamID[52];
			GetClientAuthString(i, SteamID, sizeof(SteamID));
			
			if(KvJumpToKey(DB, SteamID, true))
			{
				decl Float:origin[3];
				GetClientAbsOrigin(i, origin);
				
				KvSetFloat(DB, "x", origin[0]);
				KvSetFloat(DB, "y", origin[1]);
				KvSetFloat(DB, "z", origin[2]);
				KvRewind(DB);
			}	
		}
	}
	
	KeyValuesToFile(DB, PPosPluginPath);
	CloseHandle(DB);
}

//This gets called from time.sp under ClockTick(Handle:Timer)
public RestartTick()
{
	if(RestartIntervalMax > 0)
			RestartIntervalMax--;
		
	if(RestartIntervalMax == 0)
	{
		new String:CMap[64];
		GetCurrentMap(CMap, sizeof(CMap));
		SavePlayersPosition();
		
		SetConVarInt(h_showhud, 0);
		ShowClosingEffects();
		
		ServerCommand("wait 500;changelevel %s", CMap);
		PrintToChatAll("[Comax] Map restart in 500 frames! (~ 4 -> 5 seconds)");
	} else if(RestartIntervalMax == 30) {
		//30 min to restart
		PrintToChatAll("\n[Comax] WARNING: Map restart in 30 minutes!");
	} else if(RestartIntervalMax == 20) {
		//20 min to restart
		PrintToChatAll("\n[Comax] WARNING: Map restart in 20 minutes!");
	} else if(RestartIntervalMax == 15) {
		//15 min to restart
		PrintToChatAll("\n[Comax] WARNING: Map restart in 15 minutes!");
	} else if(RestartIntervalMax < 11) {
		//10 min to restart
		PrintToChatAll("\n[Comax] WARNING\x01: Map restart in %d minutes!", RestartIntervalMax);
		/*SetHudTextParams(0.2, -1.0, 60.0, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
		for(new i = 1;i<GetMaxClients();i++)
		{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
		ShowHudText(i, -1, "Comax Message:\nThe Map will restart in\n%d Minutes!", RestartIntervalMax - CurrentTickForInt);
		}
		}*/
	}
}

public ShowClosingEffects()
{
	decl env_starfield;
	decl env_fade;
	
	env_starfield = CreateEntityByName("env_starfield");
	if(env_starfield != -1)
	{
		SetVariantFloat(2.0);
		AcceptEntityInput(env_starfield, "SetDensity");
		AcceptEntityInput(env_starfield, "TurnOn");
	}
	
	env_fade = CreateEntityByName("env_fade");
	if(env_fade != -1)
	{
		DispatchKeyValue(env_fade, "duration", "3");
		DispatchKeyValue(env_fade, "holdfade", "6");
		DispatchKeyValue(env_fade, "renderamt", "255");
		DispatchKeyValue(env_fade, "rendercolor", "0 0 0");
		DispatchKeyValue(env_fade, "spawnflags", "8");
		AcceptEntityInput(env_fade, "fade");
	}
	
	SetHudTextParams(-1.0, -1.0, 4.0, 255,255,255,255);
	for(new i = 1;i < GetMaxClients();i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
			ShowHudText(i, -1, "Thank you for playing with us!\nServer will now change the level...");
	}
}
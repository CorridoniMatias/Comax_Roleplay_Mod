/*	Stats extension for Comax RP Mod.
*	@author	Reloaded.
*/

/*
	OnPluginStart:
	CreateTimer(600.0, TimerUpdateStats);
	
	FormatTime(LastStartUp, sizeof(LastStartUp), "%H:%M:%S - %d/%m/%Y", GetTime());//%S = secs. Using same var for from Timing ext.
	g_kvstatsstatus = CreateConVar("sm_kvstats", "0", "Toggles KV stats system. 0 = off, 1 = on. Default 'off:0'", FCVAR_PLUGIN);
	BuildPath(Path_SM, StatsPluginPath, sizeof(StatsPluginPath), "data/roleplay/Comax/PlayersStats.txt");
	CreateTimer(1.0, UpdatePlayingTime);
	RegConsoleCmd("sm_stats", Command_DumpStats);
	RegAdminCmd("sm_dumpconnections", CommandDumpConnections, ADMFLAG_SLAY, "Prints the list of ppl connected today, while server start up");
	RegAdminCmd("sm_getplayerstats", CommandDumpStatstoAdmins, ADMFLAG_SLAY, "Prints the stats of the desired player");
*/

new String:StatsPluginPath[PLATFORM_MAX_PATH];
//static PlayingTime[32];
new CurrentSesionPlayingTime[32] = 0;
new TimeToday[32];
new ConnectionCount[32];
new String:IP[32];
new String:IDsToUpload[101][99];
new Handle:g_kvstatsstatus = INVALID_HANDLE;
new String: LastStartUp[55];

public ComaxStats()
{
	CreateTimer(600.0, TimerUpdateStats);
	
	FormatTime(LastStartUp, sizeof(LastStartUp), "%H:%M:%S - %d/%m/%Y", GetTime());//%S = secs. Using same var for from Timing ext.
	g_kvstatsstatus = CreateConVar("sm_kvstats", "0", "Toggles KV stats system. 0 = off, 1 = on. Default 'off:0'", FCVAR_PLUGIN);
	BuildPath(Path_SM, StatsPluginPath, sizeof(StatsPluginPath), "data/roleplay/Comax/PlayersStats.txt");
	CreateTimer(1.0, UpdatePlayingTime);
	RegConsoleCmd("sm_stats", Command_DumpStats);
	RegAdminCmd("sm_dumpconnections", CommandDumpConnections, ADMFLAG_SLAY, "Prints the list of ppl connected today, while server start up");
	RegAdminCmd("sm_getplayerstats", CommandDumpStatstoAdmins, ADMFLAG_SLAY, "Prints the stats of the desired player");
}

public Action:CommandDumpConnections(client, args)
{
	PrintToConsole(client, "[Comax] Dumping connections... Last server start up: %s", LastStartUp);
	AlterUploadList(client, 2);
	PrintToConsole(client, "[Comax] End of dump.");
	return Plugin_Handled;
}

public AlterUploadList(client, mode) //old name: AddPeopleToUploadList
{
	new Handle:Database;
	Database = CreateKeyValues("PlayersStats");
	FileToKeyValues(Database, StatsPluginPath);
	
	if(KvJumpToKey(Database, "IDsToUpload", true))
	{
		new String:auth[99], String:sid[32], String:itostring[5];
		if(client > 0)
		{
			if(IsClientConnected(client) && IsClientInGame(client))
			{
				GetClientAuthString(client, auth, sizeof(auth));
			}
		}
		
		if(mode == 1)
		{
			for(new i = 1;i < 101;i++)
			{
				Format(itostring, sizeof(itostring), "%d", i);
				KvGetString(Database, itostring, sid, 32, "unass");
				
				if(!StrEqual(sid, auth))
				{
					if(StrEqual(sid, "unass"))
					{
						IDsToUpload[i] = auth;
						KvSetString(Database, itostring, auth); //save
						KvGetString(Database, itostring, sid, 32, "unass"); // get again to check if save was correct.
						PrintToServer("Assigned: IDsToUpload[%d] = %s (%s) | itostring: %s. Array: %s ", i, auth, sid, itostring, IDsToUpload[i]);
						break;
					}
				} else {
					//user is already in the list
					PrintToServer("Existing: IDsToUpload[%d] = %s | itostring: %s. Array: %s", i, sid, itostring, IDsToUpload[i]);
					break;
				}
			}
		} else if(mode == 0)
		{
			//wipe user
			for(new i = 1;i < 101;i++)
			{
				Format(itostring, sizeof(itostring), "%d", i);
				KvDeleteKey(Database, itostring); 
				PrintToServer("Removing: All entried were removed.");
			}
		} else if(mode == 2)
		{
			
			for(new i = 1;i < 101;i++)
			{
				Format(itostring, sizeof(itostring), "%d", i);
				KvGetString(Database, itostring, sid, 32, "unass");
				
				if(!StrEqual(sid, "unass"))
				{
					PrintToConsole(client, "Connection #%d: SteamID(%s) -> IDsToUpload(%s).", i, sid, IDsToUpload[i]);
				}
			}
		} else if(mode == 3)
		{
			PrintToServer("Assigning: Dumping to array...");
			for(new i = 1;i < 101;i++)
			{
				Format(itostring, sizeof(itostring), "%d", i);
				KvGetString(Database, itostring, sid, 32, "unass");
				
				if(!StrEqual(sid, "unass"))
				{
					IDsToUpload[i] = sid;
					PrintToServer("Assigned: IDsToUpload[%d] = (%s) | itostring: %s. Array: %s ", i, sid, itostring, IDsToUpload[i]);
				}
			}
		}
	}
	
	KvRewind(Database);
	KeyValuesToFile(Database, StatsPluginPath);
	CloseHandle(Database);
	
	/*
	new String:auth[99];
	GetClientAuthString(client, auth, sizeof(auth));
	for(new i = 1;i < sizeof(IDsToUpload);i++)
	{
	if(!StrEqual(IDsToUpload[i], auth))
	{
	if(StrEqual(IDsToUpload[i], ""))
	{
	IDsToUpload[i] = auth;
	PrintToServer("Assigned: IDsToUpload[%d] = %s", i, IDsToUpload[i]);
	break;
	}
	} else {
	//user is already in the list
	PrintToServer("Existing: IDsToUpload[%d] = %s", i, IDsToUpload[i]);
	break;
	}
	}
	*/
}

public Action:Command_DumpStats(client, args)
{
	if(GetConVarInt(g_kvstatsstatus) == 1)
	{
		new String:auth[32], String:name[32], String:PlayingTimeString[90], String:CSPlayingTimeString[90]; 
		
		GetClientAuthString(client, auth, 32);
		GetClientName(client, name, 32);
		
		new days, hours, minute, seconds;	
		
		//seconds = PlayingTime[client];
		/*
		days = seconds / 8640;
		hours = seconds / 3600;
		minute = seconds / 60;
		
		seconds -= days * 8640;
		seconds -= hours * 3600;
		seconds -= minute * 60;
		
		while(seconds >= 60) {
		seconds = (seconds - 60);
		minute++;
		}
		*/
		
		minute = Minutes[client];
		
		while(minute >= 60) {
			minute = (minute - 60);
			hours++;
		}
		while(hours >= 24) {
			hours = (hours - 24);
			days++;
		}
		
		
		//Format(PlayingTimeString, sizeof(PlayingTimeString), "%d Day(s) %d Hour(s) %d Minute(s) %d Second(s)", days, hours, minute, seconds);
		Format(PlayingTimeString, sizeof(PlayingTimeString), "%d Day(s) %d Hour(s) %d Minute(s)", days, hours, minute);
		
		//Restart Variables.
		days = 0;
		hours = 0;
		minute = 0;
		
		seconds = CurrentSesionPlayingTime[client];
		
		while(seconds >= 60) {
			seconds = (seconds - 60);
			minute++;
		}
		
		while(minute >= 60) {
			minute = (minute - 60);
			hours++;
		}
		while(hours >= 24) {
			hours = (hours - 24);
			days++;
		}
		
		Format(CSPlayingTimeString, sizeof(CSPlayingTimeString), "%d Hour(s) %d Minute(s) %d Second(s)", hours, minute, seconds);
		
		PrintToChatAll("\x01[\x04Comax\x01] %s's stats:\nConnections: %d.\nPlaying Time: %s.\nCurrent sesion: %s.\nJob: %s", name, ConnectionCount[client], PlayingTimeString, CSPlayingTimeString, Job[client]);
		PrintToChat(client, "\nYour private info:\nBank Money: %d.\nWallet Money: %d.", Bank[client], Money[client]);
	}
	
	return Plugin_Handled;
}

public Action:CommandDumpStatstoAdmins(client, args)
{
	if(GetConVarInt(g_kvstatsstatus) == 1)
	{
		if(args < 1)
		{
			PrintToChat(client, "[Comax] Usage: sm_getplayerstats <name>");
			return Plugin_Handled;
		}
		
		
		new String:auth[32], String:name[32], String:PlayingTimeString[90], String:CSPlayingTimeString[90], String:arg1[20], Target = -1; 
		
		GetCmdArg(1, arg1, sizeof(arg1));
		
		for(new i=1; i <= GetMaxClients(); i++)
		{
			if(!IsClientConnected(i))
				continue;
			GetClientName(i, name, sizeof(name));
			if(StrContains(name, arg1, false) != -1)
			{
				Target = i;
				break;
			}
		}
		if(Target == -1)
		{
			PrintToConsole(client, "[Comax] Client '%s' not found.", arg1);
			return Plugin_Handled;
		}
		GetClientAuthString(Target, auth, 32);
		//GetClientName(Target, name, 32);
		
		new days, hours, minute, seconds;	
		/*		
		seconds = PlayingTime[Target];
		
		while(seconds >= 60) {
		seconds = (seconds - 60);
		minute++;
		}
		*/
		
		minute = Minutes[Target];
		
		while(minute >= 60) {
			minute = (minute - 60);
			hours++;
		}
		while(hours >= 24) {
			hours = (hours - 24);
			days++;
		}
		
		
		Format(PlayingTimeString, sizeof(PlayingTimeString), "%d Day(s) %d Hour(s) %d Minute(s)", days, hours, minute);
		
		seconds = CurrentSesionPlayingTime[Target];
		
		while(seconds >= 60) {
			seconds = (seconds - 60);
			minute++;
		}
		
		while(minute >= 60) {
			minute = (minute - 60);
			hours++;
		}
		while(hours >= 24) {
			hours = (hours - 24);
			days++;
		}
		
		Format(CSPlayingTimeString, sizeof(CSPlayingTimeString), "%d Hour(s) %d Minute(s) %d Second(s)", hours, minute, seconds);
		
		PrintToChat(client, "\x01[\x04Comax\x01] %s's stats:\nConnections: %d.\nPlaying Time: %s.\nCurrent sesion: %s.\nJob: %s", name, ConnectionCount[Target], PlayingTimeString, CSPlayingTimeString, Job[Target]);
		PrintToChat(client, "\nBank Money: %d.\nWallet Money: %d.", Bank[Target], Money[Target]);
	}
	
	return Plugin_Handled;
}

public UpdateStats(connection, client)
{
	//connection: 0 = disconnect, 1 = connect.
	new String:auth[32], String:name[32];
	
	GetClientAuthString(client, auth, 32);
	GetClientName(client, name, 32);
	
	new Handle:Database;
	Database = CreateKeyValues("PlayersStats");
	FileToKeyValues(Database, StatsPluginPath);
	
	if(KvJumpToKey(Database, auth, true))
	{
		if(connection == 1)
		{
			CurrentSesionPlayingTime[client] = 0;
			ConnectionCount[client] = KvGetNum(Database, "Connections", -1);
			TimeToday[client] = KvGetNum(Database, "TimeToday", 0);
			
			PrintToServer("TimeToday for client X: %d", TimeToday[client]);
			
			if(ConnectionCount[client] == -1)
			{
				ConnectionCount[client] = 0;
				KvSetNum(Database, "Connections",  ConnectionCount[client]);
			} else {
				ConnectionCount[client]++;
				KvSetNum(Database, "Connections",  ConnectionCount[client]);
			}
			
			KvSetString(Database, "Name",  name);
			
			//PlayingTime[client] = KvGetNum(Database, "PlayingTime", 0);
			GetClientIP(client, IP, sizeof(IP));
			KvSetString(Database, "IP", IP);
			decl String:ComaxTimeFormatted2[55];
			FormatTime(ComaxTimeFormatted2, sizeof(ComaxTimeFormatted2), "%H:%M:%S - %d/%m/%Y", GetTime());//%S = secs
			
			KvSetString(Database, "LastConnected", ComaxTimeFormatted2);
		} else if(connection == 0) {
			//Update all crap to database
			KvSetNum(Database, "PlayingTime", Minutes[client]);
			KvSetNum(Database, "PlayingTimeLastSession", CurrentSesionPlayingTime[client]);
			KvSetNum(Database, "TimeToday", TimeToday[client] + CurrentSesionPlayingTime[client]);
			//			PrintToServer("Client left with %d, TimeToday = %d, CurrentSesionPlayingTime = %d", TimeToday[client] + CurrentSesionPlayingTime[client], TimeToday[client], CurrentSesionPlayingTime[client]);
			KvSetString(Database, "Job", Job[client]);
			KvSetNum(Database, "BankMoney", Bank[client]);
			KvSetNum(Database, "PocketMoney", Money[client]);
			KvSetNum(Database, "Wages", Wages[client]);
			//reset
			CurrentSesionPlayingTime[client] = 0;
		} else if(connection == 2)
		{
			//Update all crap to database
			KvSetNum(Database, "PlayingTime", Minutes[client]);
			KvSetNum(Database, "PlayingTimeLastSession", CurrentSesionPlayingTime[client]);
			KvSetNum(Database, "TimeToday", TimeToday[client] + CurrentSesionPlayingTime[client]);
			KvSetString(Database, "Job", Job[client]);
			KvSetNum(Database, "BankMoney", Bank[client]);
			KvSetNum(Database, "PocketMoney", Money[client]);
			KvSetNum(Database, "Wages", Wages[client]);
			PrintToConsole(client, "Comax: Scheduled save executed. All you stats have been saved!");
		}
	}
	
	KvRewind(Database);
	KeyValuesToFile(Database, StatsPluginPath);
	CloseHandle(Database);
}

public Action:UpdatePlayingTime(Handle:timer) {
	new MC = GetMaxClients();	
	for(new i = 1;i <= MC;i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i) && i != 0)
		{
			CurrentSesionPlayingTime[i]++;
			//PlayingTime[i]++;
		}
	}
	CreateTimer(1.0, UpdatePlayingTime);
}

public Action:TimerUpdateStats(Handle:timer)
{
	PrintToServer("UPDATING STATS LOCALLY, 10 MIN!!!");
	for(new i = 1;i<GetMaxClients();i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			UpdateStats(2, i);
		} else {}
	}
	CreateTimer(600.0, TimerUpdateStats);
}

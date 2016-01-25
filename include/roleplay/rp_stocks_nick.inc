/************************************************
 * Roflcopter Roleplay
 *----------------------------------------------*
 * Copyright (C) 2012 SpaceBass
 *----------------------------------------------*
 * Original Roleplay idea and realisation by Joe 'PinkFairie' Maley.
 * Updated and expanded by Krim, Alm and SpaceBass
 * Code optimized and improoved by Monkeys
 *----------------------------------------------*
 * Licence: Creative Commons BY-NC-SA
 * http://creativecommons.org/licenses/by-nc-sa/3.0/
************************************************/
/** Double-include prevention */
#if defined _rp_stocks_included_
  #endinput
#endif
#define _rp_stocks_included_

//Terminate:
#pragma semicolon 1

// Hud Element hiding flags
#define	HIDEHUD_WEAPONSELECTION		( 1<<0 )	// Hide ammo count & weapon selection
#define	HIDEHUD_FLASHLIGHT			( 1<<1 )
#define	HIDEHUD_ALL					( 1<<2 )
#define HIDEHUD_HEALTH				( 1<<3 )	// Hide health & armor / suit battery
#define HIDEHUD_PLAYERDEAD			( 1<<4 )	// Hide when local player's dead
#define HIDEHUD_NEEDSUIT			( 1<<5 )	// Hide when the local player doesn't have the HEV suit
#define HIDEHUD_MISCSTATUS			( 1<<6 )	// Hide miscellaneous status elements (trains, pickup history, death notices, etc)
#define HIDEHUD_CHAT				( 1<<7 )	// Hide all communication elements (saytext, voice icon, etc)
#define	HIDEHUD_CROSSHAIR			( 1<<8 )	// Hide crosshairs
#define	HIDEHUD_VEHICLE_CROSSHAIR	( 1<<9 )	// Hide vehicle crosshair
#define HIDEHUD_INVEHICLE			( 1<<10 )
#define HIDEHUD_NAME			64

// Damage flags //
#define DMG_GENERIC	0
#define DMG_CRUSH	(1 << 0)
#define DMG_BULLET	(1 << 1)
#define DMG_SLASH	(1 << 2)
#define DMG_BURN	(1 << 3)
#define DMG_CRUSH	(1 << 0)
#define DMG_VEHICLE (1 << 4)
#define DMG_FALL (1 << 5)
#define DMG_BLAST (1 << 6)
#define DMG_CLUB (1 << 7)
#define DMG_SHOCK (1 << 8)
#define DMG_SONIC (1 << 9)
#define DMG_ENERGYBEAM (1 << 10)
#define DMG_PREVENT_PHYSICS_FORCE (1 << 11)
#define DMG_NEVERGIB (1 << 12)
#define DMG_ALWAYSGIB (1 << 13)
#define DMG_DROWN (1 << 14)
#define DMG_TIMEBASED ((1 << 15) | (1 << 16) | (1 << 17) | (1 << 18) | (1 << 19) | (1 << 20) | (1 << 21))
#define DMG_PARALYZE (1 << 15)
#define DMG_NERVEGAS (1 << 16)
#define DMG_POISON (1 << 17)
#define DMG_RADIATION (1 << 18)
#define DMG_DROWNRECOVER (1 << 19)
#define DMG_ACID (1 << 20)
#define DMG_SLOWBURN (1 << 21)
#define DMG_REMOVENORAGDOLL (1 << 22)
#define DMG_PHYSGUN (1 << 23)
#define DMG_PLASMA (1 << 24)
#define DMG_AIRBOAT (1 << 25)
#define DMG_DISSOLVE (1 << 26)
#define DMG_BLAST_SURFACE (1 << 27)
#define DMG_DIRECT (1 << 28)
#define DMG_BUCKSHOT (1 << 29)

//Variable:
static Float:GameTime[MAXPLAYERS+1];
public String:ConVarValue[33][64];

/*
 * Set's up for RP
 * @param DesiredMap Name of the map you play on
 */
stock FixMap(const String:DesiredMap[])
{
	new Teamplay;
	decl String:MapName[64];

	GetCurrentMap(MapName, sizeof(MapName));
	Teamplay = GetConVarInt(FindConVar("mp_teamplay"));

	if(!StrEqual(DesiredMap, MapName) || Teamplay == 0)
	{

		if(Teamplay == 0) PrintToConsole(0, "[RP] Restarting map to enable teamplay");
		if(!StrEqual(DesiredMap, MapName)) PrintToConsole(0, "[RP] Changing map to %s", DesiredMap);

		ServerCommand("mp_teamplay 1");
		ServerCommand("sm_map %s", DesiredMap);
	}
}

/*
 * Set's a clients speed
 * @param Client Player to use
 * @param Speed Speed to use
 */
stock SetSpeed(Client, Float:Speed)
{
	new SpeedOffset = FindSendPropOffs("CHL2MP_Player", "m_flMaxspeed");
	if(SpeedOffset > 0) SetEntData(Client, SpeedOffset, Speed, 4, true);
}

/*
 * Print's the robbery abortion message
 * @param Client Player's name to use
 */
stock PrintRobberyAbort(Client)
{

	for(new Y = 1; Y < MaxClients; Y++)
	{
		if(IsClientConnected(Y) && IsClientInGame(Y))
		{
			SetHudTextParams(-1.0, 0.015, 10.0, 255, 255, 255, 255, 0, 6.0, 0.1, 0.2);
			ShowHudText(Y, -1, "\n\nATTENTION: %N is getting away!", Client);
		}
	}
}

/*
 * Saves an integer
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param Variable Integer to store
 */
 /*
stock SaveInteger(Handle:Vault, const String:Key[], const String:SaveKey[], Variable)
{

	if(Variable == 0)
	{
		KvJumpToKey(Vault, Key, true);
		
		KvDeleteKey(Vault, SaveKey);

		KvRewind(Vault);

	}
	else
	{
		KvJumpToKey(Vault, Key, true);

		KvSetNum(Vault, SaveKey, Variable);
	
		KvRewind(Vault);
	}
}
*/
/*
 * Saves a string
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param Variable String to store
 */
stock SaveString(Handle:Vault, const String:Key[], const String:SaveKey[], const String:Variable[])
{
	KvJumpToKey(Vault, Key, true);

	KvSetString(Vault, SaveKey, Variable);

	KvRewind(Vault);
}

/*
 * Loads an integer
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param DefaultValue Integer to return if key not found
 */
 /*
stock LoadInteger(Handle:Vault, const String:Key[], const String:SaveKey[], DefaultValue)
{

	KvJumpToKey(Vault, Key, false);

	new Variable = KvGetNum(Vault, SaveKey, DefaultValue);

	KvRewind(Vault);

	return Variable;
}*/

/*
 * Loads a string
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param DefaultValue String to return if key not found
 * @param Reference String to return through reference
 */
stock LoadString(Handle:Vault, const String:Key[], const String:SaveKey[], const String:DefaultValue[], String:Reference[255])
{

	KvJumpToKey(Vault, Key, false);
	
	KvGetString(Vault, SaveKey, Reference, sizeof(Reference), DefaultValue);

	KvRewind(Vault);
}

/*
 * Loads a Job string
 * @param Vault Handle to the text file
 * @param Key The keyvalue name to use
 * @param SteamId The authid of the client
 * @param DefaultValue String to return if key not found
 * @param Reference String to return through reference
 */
stock LoadJobString(Handle:Vault, const String:Key[], const String:SaveKey[], const String:DefaultValue[], String:Reference[255])
{
	KvJumpToKey(Vault, Key, false);
	KvGetString(Vault, SaveKey, Reference, sizeof(Reference), DefaultValue);
	KvRewind(Vault);
}

/*
 * Prints NPC info
 * @param Client Player to print to
 * @param Vault Keyvalue handle to use
 * @param Header Header to use
 * @param Key Subkey to find inside the vault
 * @param MaxNPCs Maximum number of NPCs
 */
stock PrintNPC(Client, Handle:Vault, const String:Header[], const String:Key[], MaxNPCs)
{
	decl String:NPCId[32], String:Props[255];

	PrintToConsole(Client, Header);
	for(new X = 0; X < MaxNPCs; X++)
	{
		IntToString(X, NPCId, sizeof(NPCId));
	
		LoadString(Vault, Key, NPCId, "Null", Props);

		if(StrContains(Props, "Null", false) == -1) PrintToConsole(Client, "--%s: %s", NPCId, Props);	
	}
}

/*
 * Prints job info
 * @param Client Player to print to
 * @param Vault Keyvalue handle to use
 * @param Header Header to use
 * @param Key Subkey to find inside the vault
 * @param MaxNPCs Maximum number of Jobs
 */
stock PrintJob(Client, Handle:Vault, const String:Header[], const String:Key[], MaxJobs)
{

	decl String:JobId[32], String:JobTitle[255];
	PrintToConsole(Client, Header);
	for(new X = 0; X < MaxJobs; X++)
	{
		IntToString(X, JobId, sizeof(JobId));
	
		LoadString(Vault, Key, JobId, "Null", JobTitle);

		//Found in DB:
		if(StrContains(JobTitle, "Null", false) == -1) PrintToConsole(Client, "--%s: %s", JobId, JobTitle);	
	}
}

stock FindClient(String:TypedName[])
{
	decl String:TestName[32];
	decl Target;
	Target = -1;

	for(new X = 1; X <= GetMaxClients(); X++)
	{
		if(!IsClientInGame(X) || Target != -1)
		{
			continue;
		}

		GetClientName(X, TestName, 32);

		if(StrContains(TestName, TypedName, false) != -1)
		{
			Target = X;
		}
	}

	return Target;
}

stock FindDistance(Ent1, Ent2)
{
	decl Float:Loc1[3];
	decl Float:Loc2[3];
	decl Float:Distance;
	decl returnnumber;

	if(Ent1 <= GetMaxClients())
	{
		GetClientAbsOrigin(Ent1, Loc1);
	}
	else
	{
		GetEntPropVector(Ent1, Prop_Send, "m_vecOrigin", Loc1);
	}

	if(Ent2 <= GetMaxClients())
	{
		GetClientAbsOrigin(Ent2, Loc2);
	}
	else
	{
		GetEntPropVector(Ent2, Prop_Send, "m_vecOrigin", Loc2);
	}

	Distance = GetVectorDistance(Loc1, Loc2);

	returnnumber = RoundToCeil(Distance);

	return returnnumber;
}

stock RPON()
{
	decl String:MapName[64];
	GetCurrentMap(MapName, sizeof(MapName));

	if(StrContains(MapName, "rp", false) == 0)
	{
		return true;
	}

	return false;
}

stock Float:calcDistanceToTarget(Client,Player)
{
	decl Float:ClientOrigin[3], Float:PlayerOrigin[3];
	
	GetClientAbsOrigin(Client, ClientOrigin);
	ClientOrigin[2] += 40.0;
	
	if(Player > 0)
		GetClientAbsOrigin(Player, PlayerOrigin);
	return GetVectorDistance(ClientOrigin, PlayerOrigin);
}

stock FindPlayer(Client,String:idstr[])
{
	new uid = StringToInt(idstr);
	new id = GetClientOfUserId(uid);
	new MaxC = GetMaxClients();
	
	if(id == 0)
	{
		new numclients = 0;
		new numid = 0;
		new String:name[50];
		for(new i=1;i<MaxC;i++)
		{
			if(!IsClientInGame(i)) continue;
			GetClientName(i, name, 50);
			if(StrContains(name, idstr, false) != -1)
			{
				numclients++;
				if(numclients > 1) break;
				numid = i;
			}
		}
		if(numclients > 1)
		{
			PrintToConsole(Client,"There is more than one client matching that string, please be more specific.");
			return 0;
		}
		id = numid;
		if(id == 0)
		{
			//PrintToConsole(aid,"Client not found.");
			return 0;
		}
	}
	return id;
}


stock calcEnt(Ent)
{
	new MaxC = GetMaxClients();
	return MaxC + Ent;
}

stock calcSaveEnt(Ent)
{
	new MaxC = GetMaxClients();
	return Ent - MaxC;
}

//Functions for Casting
stock bool:int2bool(i)
{
	if(i == 1) return true; else return false;
}

stock bool2int(bool:i)
{
	if(i) return 1; else return 0;
}


//Mathematic funcs
stock bool:IsBetween(Value, min, max, bool:equal = false) 
{
	if(equal)
	{
		if(Value >= min && Value <= max) return true
	}
	else
	{
		if(Value > min && Value < max) return true;
	}
	return false;	
}


//Detect Teamkill
stock bool:TeamKill(Attacker, Client) 
{
	if(GetConVarInt(FindConVar("mp_teamplay")) == 1)
	{
		if(GetClientTeam(Attacker) == GetClientTeam(Client)) return true;
	}
	return false;	
}


//MISC
public bool:TraceEntityFilterPlayer(entity, contentsMask) {

	return entity <= 0;
}

//Check if player is looking at a wall using TraceRays
stock bool:LookAtWall(Client, Float:Dist) {


	decl Float:posEye[3], Float:posEyeAngles[3];
	new bool:isClientLookingAtWall = false;
	
	GetClientEyePosition(Client, posEye);
	GetClientEyeAngles(Client, posEyeAngles);
	


	posEyeAngles[0] = 0.0;
	new Handle:trace = TR_TraceRayFilterEx(posEye, posEyeAngles, CONTENTS_SOLID, RayType_Infinite, TraceEntityFilterPlayer);
	

	if (TR_DidHit(trace))
	{		
		if (TR_GetEntityIndex(trace) > 0) 
		{			
			return false;
		}
		
		decl Float:posEnd[3];
		TR_GetEndPosition(posEnd, trace);
		
		if (GetVectorDistance(posEye, posEnd) <= Dist ) 
		{		
			isClientLookingAtWall = true;
		}
	}
	
	CloseHandle(trace);
	
	return isClientLookingAtWall;
}


//Check if plugin is running
stock bool:IsPluginRuning(const String:plugin[])
{
	new Handle:Plugin_Roleplay = FindPluginByFile("plugin"); 		
	new PluginStatus:Plugin_Roleplay_Status = GetPluginStatus(Plugin_Roleplay);		
	
	if(Plugin_Roleplay == INVALID_HANDLE || Plugin_Roleplay_Status != Plugin_Running)
	{
		return false;
	}
	return true;
}

//Show/Hide Hud
stock HideHud(Client, flags)
{	
	SetEntProp(Client, Prop_Send, "m_iHideHUD", flags);
}

//Return m_iFrags of the Player
stock GetClientScore(Client)
{
	return GetEntProp(Client, Prop_Data, "m_iFrags");
}

//Sets the m_iFrags of the Player
stock SetClientScore(Client, score)
{
	SetEntProp(Client, Prop_Data, "m_iFrags", score);
}

//Changes the Deathcounter of the Player
stock SetClientDeath(Client, death)
{
	SetEntProp(Client, Prop_Data, "m_iDeaths", death); 
}

//Entity Funcs
stock GetEntityMaxs(entity, Float:vec[3])
{
    GetEntPropVector(entity, Prop_Send, "m_vecMaxs", vec);    
}

stock GetEntityMins(entity, Float:vec[3])
{
    GetEntPropVector(entity, Prop_Send, "m_vecMins", vec);    
}

stock SetEntityMaxs(entity, Float:vec[3])
{
    SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vec);    
}

stock SetEntityMins(entity, Float:vec[3])
{
    SetEntPropVector(entity, Prop_Send, "m_vecMins", vec);    
}

stock SetEntitySolid(entity, solid)
{
	new Collision = GetEntSendPropOffs(entity, "m_CollisionGroup");
	SetEntData(entity, Collision, solid, 1, true);
}


stock bool:IsValidClient(Client)
{
	if(Client == 0) return false;
	if(!IsClientConnected(Client) || !IsClientInGame(Client))return false;
	if(IsFakeClient(Client)) return false;
	if(Client == 0)return false;
	return true;
}

stock GetClientConVar(Client, const String:Name[], String:Value[64])
{  
	QueryClientConVar(Client, Name, ConVarQueryFinished:ClientConVar, Client);
	
	Value = ConVarValue[Client]
	return Value
}


public ClientConVar(QueryCookie:cookie, Client, ConVarQueryResult:result, const String:cvarName[64], const String:cvarValue[64])
{
	ConVarValue[Client] = cvarValue;
	PrintToChatAll("%s", ConVarValue[Client]);
}

stock OverflowMessage(Client, String:Contents[])
{
	
	//Anti-Spam:
	if(GameTime[Client] <= (GetGameTime() - 10))
	{
		
		//Print:
		CPrintToChat(Client, Contents);
		
		//Save:
		GameTime[Client] = GetGameTime();
	}
	
}

stock GetRandomPlayer()
{
	new Online = 0;
	
	for(new X = 1;X <= GetMaxClients();X++)
	{
		if(IsClientConnected(X) && IsClientInGame(X))
		{
			Online++;
		}
	}	
	return GetRandomInt(1, Online);
}

stock bool:CheckAdminFlagsByString(Client, flagString)
{
	if (GetUserFlagBits(Client) & ADMFLAG_ROOT)
	{
		return true;
	} 
	
	if (GetUserFlagBits(Client) & flagString)
	{
		return true;
	} 
	return false;
}

stock AutoPreCacher(const String:FilePath[])
{
	//Declare
	new String:DownloadPath[64];
	//Download Path
	BuildPath(Path_SM, DownloadPath, 64, FilePath);
	if(FileExists(DownloadPath) == false) SetFailState("[SM] ERROR: Missing file '%s'", DownloadPath);
	
	//Auto Downloader
	new Handle:fileh = OpenFile(DownloadPath, "r");
	new String:buffer[256];
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		new len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';
		TrimString(buffer);
		if (FileExists(buffer))
		{
			
			if(StrContains(buffer, ".mdl", false) != -1)
			{
				PrecacheModel(buffer)
			}
			
			if(StrContains(buffer, ".wav", false) != -1 || StrContains(buffer, ".mp3", false) != -1)
			{
				PrecacheSound(buffer, true)	
			}
			
		}
		
		if (IsEndOfFile(fileh))
			break;
	} 	
	
}
stock AutoDownloader(const String:FilePath[])
{
	//Declare
	new String:DownloadPath[64];
	//Download Path
	BuildPath(Path_SM, DownloadPath, 64, FilePath);
	if(FileExists(DownloadPath) == false) SetFailState("[SM] ERROR: Missing file '%s'", DownloadPath);
	
	//Auto Downloader
	new Handle:fileh = OpenFile(DownloadPath, "r");
	new String:buffer[256];
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		new len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';
		TrimString(buffer);
		if (FileExists(buffer))
		{
			AddFileToDownloadsTable(buffer);
		}
		
		if (IsEndOfFile(fileh))
			break;
	} 	
	
}

stock LogMSG(const String:file[], const String:format[])
{
	PrintToServer(format);
	LogToFile(file,format);
}	
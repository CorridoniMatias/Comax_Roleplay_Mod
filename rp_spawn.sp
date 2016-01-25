//Spawn v1.0 by Joe 'Pinkfairie' Maley:

//Includes:
#include <sourcemod>
#include <sdktools>

//Terminate:
#pragma semicolon 1

//Stocks:
#include "rp_stocks"

//Definitions:
#define MAXSPAWNS	25

//Database:
static String:SpawnPath[128];
static String:SpawnPath2[128];

//Rebels
static Float:SpawnPoints[MAXSPAWNS][3];

//Cops
static Float:SpawnPoints2[MAXSPAWNS][3];

static Status;
static Status2;

//Random Spawn:
stock RandomizeSpawn(Client)
{
	if(Status == 1)
	{
		//Roll:
		decl Roll;
		decl bool:Legit;

		//Initialize:
		Roll = GetRandomInt(0, MAXSPAWNS - 1);
	
		//Check:
		Legit = false;
		if(SpawnPoints[Roll][0] != 69.0) Legit = true;

		//Try Again:
		if(!Legit) RandomizeSpawn(Client);
		else
		{

			//Declare:
			new Float:RandomAngles[3];
	
			//Vectors:
			GetClientAbsAngles(Client, RandomAngles);
			RandomAngles[1] = GetRandomFloat(0.0, 360.0);

			//Spawn:
			TeleportEntity(Client, SpawnPoints[Roll], RandomAngles, NULL_VECTOR);
		}
	}
}

stock RandomizeSpawn2(Client)
{
	if(Status2 == 1)
	{
		//Roll:
		decl Roll;
		decl bool:Legit;

		//Initialize:
		Roll = GetRandomInt(0, MAXSPAWNS - 1);
	
		//Check:
		Legit = false;
		if(SpawnPoints2[Roll][0] != 69.0) Legit = true;

		//Try Again:
		if(!Legit) RandomizeSpawn2(Client);
		else
		{

			//Declare:
			new Float:RandomAngles[3];
	
			//Vectors:
			GetClientAbsAngles(Client, RandomAngles);
			RandomAngles[1] = GetRandomFloat(0.0, 360.0);

			//Spawn:
			TeleportEntity(Client, SpawnPoints2[Roll], RandomAngles, NULL_VECTOR);
		}
	}
	else
	{
		if(Status == 1)
		{
			PrintToChat(Client, "[RP] Server hasn't created any cop spawns. Spawning at a rebel coordinate.");
			RandomizeSpawn(Client);
		}
	}
}

//Create NPC:
public Action:CommandCreateSpawn(Client, Args)
{

	//Error:
	if(Args < 2)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_createspawn <id> <1-rebels 2-cops>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl Handle:Vault;
	decl String:SpawnId[32], String:TeamId[32], Num;
	decl Float:ClientOrigin[3];

	decl String:MapName[64];
	GetCurrentMap(MapName, 64);

	//Initialize:
	GetCmdArg(1, SpawnId, 32);
	GetCmdArg(2, TeamId, 32);

	Num = StringToInt(TeamId);

	if(Num > 2 || Num < 1)
	{
		
		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_createspawn <id> <1-rebels 2-cops>");

		//Return:
		return Plugin_Handled;
	}

	GetClientAbsOrigin(Client, ClientOrigin);

	//Rebel Database:
	if(Num == 1)
	{
		//Vault:
		Vault = CreateKeyValues("Vault");

		//Retrieve:
		FileToKeyValues(Vault, SpawnPath);

		//Save:
		KvJumpToKey(Vault, MapName, true);
		KvSetVector(Vault, SpawnId, ClientOrigin);
		KvRewind(Vault);

		//Store:
		KeyValuesToFile(Vault, SpawnPath);

		decl Number;
		Number = StringToInt(SpawnId);
		
		SpawnPoints[Number][0] = ClientOrigin[0];
		SpawnPoints[Number][1] = ClientOrigin[1];
		SpawnPoints[Number][2] = ClientOrigin[2];

		//Print:
		PrintToConsole(Client, "[RP] (Rebels) Created spawn #%s @ <%f, %f, %f>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
		RefreshSpawns();

		//Close:
		CloseHandle(Vault);
		return Plugin_Handled;
	}

	//Cop Database:
	if(Num == 2)
	{
		//Vault:
		Vault = CreateKeyValues("Vault");

		//Retrieve:
		FileToKeyValues(Vault, SpawnPath2);

		//Save:
		KvJumpToKey(Vault, MapName, true);
		KvSetVector(Vault, SpawnId, ClientOrigin);
		KvRewind(Vault);

		//Store:
		KeyValuesToFile(Vault, SpawnPath2);

		decl Number;
		Number = StringToInt(SpawnId);

		SpawnPoints2[Number][0] = ClientOrigin[0];
		SpawnPoints2[Number][1] = ClientOrigin[1];
		SpawnPoints2[Number][2] = ClientOrigin[2];

		//Print:
		PrintToConsole(Client, "[RP] (Cops) Created spawn #%s @ <%f, %f, %f>", SpawnId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	
		RefreshSpawns();

		//Close:
		CloseHandle(Vault);
		return Plugin_Handled;
	}

	//Return:
	return Plugin_Handled;
}

//Remove Spawn:
public Action:CommandRemoveSpawn(Client, Args)
{

	//Error:
	if(Args < 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_removespawn <id> <1-rebels 2-cops>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:	
	decl Handle:Vault;
	decl String:SpawnId[32], String:TeamId[32], Num;

	decl String:MapName[64];
	GetCurrentMap(MapName, 64);

	//Initialize:
	GetCmdArg(1, SpawnId, sizeof(SpawnId));
	GetCmdArg(2, TeamId, 32);

	Num = StringToInt(TeamId);

	if(Num > 2 || Num < 1)
	{
		
		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_removespawn <id> <1-rebels 2-cops>");

		//Return:
		return Plugin_Handled;
	}

	//Rebel Database:
	if(Num == 1)
	{
		//Vault:
		Vault = CreateKeyValues("Vault");

		//Retrieve:
		FileToKeyValues(Vault, SpawnPath);

		//Delete:
		KvJumpToKey(Vault, MapName, false);
		KvDeleteKey(Vault, SpawnId); 
		KvRewind(Vault);

		//Store:
		KeyValuesToFile(Vault, SpawnPath);

		decl Number;
		Number = StringToInt(SpawnId);

		SpawnPoints[Number][0] = 69.0;
		SpawnPoints[Number][1] = 69.0;
		SpawnPoints[Number][2] = 69.0;

		PrintToConsole(Client, "[RP] (Rebels) Removed Spawn %s from the database", SpawnId);

		RefreshSpawns();

		//Close:
		CloseHandle(Vault);

		//Return:
		return Plugin_Handled;
	}

	//Rebel Database:
	if(Num == 2)
	{
		//Vault:
		Vault = CreateKeyValues("Vault");

		//Retrieve:
		FileToKeyValues(Vault, SpawnPath2);

		//Delete:
		KvJumpToKey(Vault, MapName, false);
		KvDeleteKey(Vault, SpawnId); 
		KvRewind(Vault);

		//Store:
		KeyValuesToFile(Vault, SpawnPath2);

		decl Number;
		Number = StringToInt(SpawnId);

		SpawnPoints2[Number][0] = 69.0;
		SpawnPoints2[Number][1] = 69.0;
		SpawnPoints2[Number][2] = 69.0;

		PrintToConsole(Client, "[RP] (Cops) Removed Spawn %s from the database", SpawnId);

		RefreshSpawns();

		//Close:
		CloseHandle(Vault);

		//Return:
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

//List Spawns:
public Action:CommandListSpawns(Client, Args)
{
	if(Args < 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_spawnlist <1-rebels 2-cops>");

		//Return:
		return Plugin_Handled;
	}

	decl String:TeamId[32], Num;
	GetCmdArg(1, TeamId, 32);

	Num = StringToInt(TeamId);

	if(Num > 2 || Num < 1)
	{
		
		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_spawnlist <1-rebels 2-cops>");

		//Return:
		return Plugin_Handled;
	}

	//Rebels
	if(Num == 1)
	{
		//Declare:	
		decl Handle:Vault;

		//Vault:
		Vault = CreateKeyValues("Vault");

		//Retrieve:
		FileToKeyValues(Vault, SpawnPath);

		decl String:MapName[64];
		GetCurrentMap(MapName, 64);

		//Header:
		PrintToConsole(Client, "Spawns [REBELS] [%s]:", MapName);

		//Loop:
		for(new X = 0; X < MAXSPAWNS; X++)
		{

			//Check:
			if(SpawnPoints[X][0] != 69.0) PrintToConsole(Client, "%d: <%f, %f, %f>", X, SpawnPoints[X][0], SpawnPoints[X][1], SpawnPoints[X][2]);
		}
	
		//Close:
		CloseHandle(Vault);

		//Return:
		return Plugin_Handled;
	}

	if(Num == 2)
	{
		//Declare:	
		decl Handle:Vault;

		//Vault:
		Vault = CreateKeyValues("Vault");

		//Retrieve:
		FileToKeyValues(Vault, SpawnPath2);

		decl String:MapName[64];
		GetCurrentMap(MapName, 64);

		//Header:
		PrintToConsole(Client, "Spawns [COPS] [%s]:", MapName);

		//Loop:
		for(new X = 0; X < MAXSPAWNS; X++)
		{

			//Check:
			if(SpawnPoints2[X][0] != 69.0) PrintToConsole(Client, "%d: <%f, %f, %f>", X, SpawnPoints2[X][0], SpawnPoints2[X][1], SpawnPoints2[X][2]);
		}
	
		//Close:
		CloseHandle(Vault);

		//Return:
		return Plugin_Handled;
	}

	return Plugin_Handled;
}

//Load Spawn:
public Action:LoadSpawns(Handle:Timer, any:Client)
{

	//Declare:
	decl Handle:Vault, Handle:Vault2;
	decl String:Key[32];

	//Initialize:
	new Float:DefaultSpawn[3] = {69.0, 69.0, 69.0};
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);


	//REBEL SPAWN LOAD	
	//Retrieve:
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, SpawnPath);

	Status = 0;
	Status2 = 0;

	//Load:
	for(new X = 0; X < MAXSPAWNS; X++)
	{

		//Convert:
		IntToString(X, Key, 32);
		
		//Find:
		KvJumpToKey(Vault, MapName, false);
		KvGetVector(Vault, Key, SpawnPoints[X], DefaultSpawn);
		KvRewind(Vault);

		if(SpawnPoints[X][0] != 69.0)
		{
			Status = 1;
		}
	}
	KvRewind(Vault);

	//Close:
	CloseHandle(Vault);




	//COP SPAWN LOAD	
	//Retrieve:
	Vault2 = CreateKeyValues("Vault");
	FileToKeyValues(Vault2, SpawnPath2);


	//Load:
	for(new X = 0; X < MAXSPAWNS; X++)
	{

		//Convert:
		IntToString(X, Key, 32);
		
		//Find:
		KvJumpToKey(Vault2, MapName, false);
		KvGetVector(Vault2, Key, SpawnPoints2[X], DefaultSpawn);
		KvRewind(Vault2);

		if(SpawnPoints2[X][0] != 69.0)
		{
			Status2 = 1;
		}
	}
	KvRewind(Vault2);

	//Close:
	CloseHandle(Vault2);
}

public Action:RefreshSpawns()
{
	Status = 0;
	Status2 = 0;
	for(new X = 0; X < MAXSPAWNS; X++)
	{
		if(SpawnPoints[X][0] != 69.0)
		{
			Status = 1;
		}
		if(SpawnPoints2[X][0] != 69.0)
		{
			Status2 = 1;
		}
	}
	return Plugin_Handled;
}

//Spawn:
public EventSpawn(Handle:Event, const String:Name[], bool:Broadcast)
{

	//Declare:
	decl Client, TeamIndex;

	//Initialize:
	Client = GetClientOfUserId(GetEventInt(Event, "userid"));
	TeamIndex = GetClientTeam(Client);

	//Load:
	
	//Rebel:
	if(TeamIndex == 3)
	{
		RandomizeSpawn(Client);
	}
	//Cop
	else if(TeamIndex == 2)
	{
		RandomizeSpawn2(Client);
	}
	else
	{
		RandomizeSpawn(Client);
	}

	//Close:
	CloseHandle(Event);
}

//Information:
public Plugin:myinfo =
{

	//Initation:
	name = "NPCs",
	author = "Joe 'Pinkfairie' Maley",
	description = "Adds NPCs for RP",
	version = "1.0",
	url = "hiimjoemaley@hotmail.com"
}

//Map Start:
public OnMapStart()
{
	//Create NPCs:
	CreateTimer(1.0, LoadSpawns);	
}

//Initation:
public OnPluginStart()
{
	//Commands:
	RegAdminCmd("sm_createspawn", CommandCreateSpawn, ADMFLAG_CUSTOM4, "<id> - Creates a spawn point");
	RegAdminCmd("sm_removespawn", CommandRemoveSpawn, ADMFLAG_CUSTOM4, "<id> - Removes a spawn point");
	RegAdminCmd("sm_spawnlist", CommandListSpawns, ADMFLAG_CUSTOM1, "- Lists all the Spawns in the database");

	//Events:
	HookEvent("player_spawn", EventSpawn);

	//REBEL Spawn
	BuildPath(Path_SM, SpawnPath, 64, "data/roleplay/spawnrebel.txt");
	if(FileExists(SpawnPath) == false) PrintToConsole(0, "[SM] ERROR: Missing file '%s'", SpawnPath);

	//COMBINE (Cop) Spawn
	BuildPath(Path_SM, SpawnPath2, 64, "data/roleplay/spawncombine.txt");
	if(FileExists(SpawnPath2) == false) PrintToConsole(0, "[SM] ERROR: Missing file '%s'", SpawnPath2);

	//Server Variable:
	CreateConVar("spawn_version", "1.0", "Spawn Version",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
}
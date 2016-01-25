//Includes:
#include <sourcemod>
#include <sdktools>

//Terminate:
#pragma semicolon 1

//Stocks:
#include "rp_stocks"

//Definitions:
#define	MAXDOORS 2000

new Handle:LogDoors = INVALID_HANDLE;

//Paths:
static String:DoorPath[128];
static String:NamePath[64];
static String:ConfigPath[128];
static String:DoorLogPath[128];

//Variables:
static Locked[MAXDOORS];
static OwnsDoor[33][MAXDOORS];
static PoliceDoors[65];
static FireDoors[65];
static CustomDoor[2000];
static CustomDoorMode[2000];

//Misc:
static bool:PrethinkBuffer[33];

//Connection:
public OnClientPutInServer(Client)
{

	//Defaults:
	for(new X = 0; X < MAXDOORS; X++)
	{

		//Clear:
		OwnsDoor[Client][X] = 0;
	}

	//Load:
	Load(Client);
} 

public Action:CommandRefreshDoor(Console, Arguments)
{
	if(Arguments > 0)
	{
		PrintToConsole(Console, "[RP] Usage: sm_refreshdoors - Used for buydoor feature. Shouldn't be used by an admin.");
		return Plugin_Handled;
	}

	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, ConfigPath);
	new String:Entity[255];
	for(new X = 0; X < 64; X++)
	{
		IntToString(X, Entity, 255);
		
		PoliceDoors[X] = LoadInteger(Vault, "PoliceDoor", Entity, 0);
		FireDoors[X] = LoadInteger(Vault, "FirefighterDoor", Entity, 0);
	}
	KvRewind(Vault);
	CloseHandle(Vault);

	new Max;
	Max = GetMaxClients();
	for(new i=1; i <= Max; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			for(new X = 0; X < MAXDOORS; X++)
			{
	
				//Clear:
				OwnsDoor[i][X] = 0;
			}
			Load(i);
		}
	}
	ServerCommand("sm_doorrights");
	return Plugin_Handled;
}


//Give Door:
public Action:CommandGiveDoor(Client, Arguments)
{

	//Arguments:
	if(Arguments < 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_givedoor <Name>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:PlayerName[32];
	decl String:showname[2];

	//Initialize:
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	showname = "0";
	
	MakeDoor(Client,PlayerName,1,StringToInt(showname));

	//Return:
	return Plugin_Handled;
}

//Take Door:
public Action:CommandListDoor(Client, Arguments)
{
    decl Ent;
    decl String:Name[32];
    decl String:ClassName[20];
    Ent = GetClientAimTarget(Client, false); 
    if(Ent > GetMaxClients())
    {
      GetEdictClassname(Ent, ClassName, 20);

      //Error:
      if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	return Plugin_Handled;
				
      PrintToConsole(Client, "[RP] Searching Owners for Door #%d",Ent);      
      for(new x = 0; x<GetMaxClients(); x++)
      {
	    	GetClientName(x, Name, 32);
	        if(OwnsDoor[x][Ent])
	            PrintToConsole(Client, "[RP] %s owns #%d.",Name,Ent);
      }
			

    } else
    {
    
	    GetClientName(Ent, Name, 32); 
	    PrintToConsole(Client, "[RP] Searching Doors for user %s",Name);      
	    for(new x = 0; x<MAXDOORS; x++)
	    {
	        if(OwnsDoor[Ent][x])
	            PrintToConsole(Client, "[RP] owns Door #%d.",x);
	    }
    }
    return Plugin_Handled;
}


//Take Door:
public Action:CommandTakeDoor(Client, Arguments)
{

	//Arguments:
	if(Arguments < 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_takedoor <Name|#UserId>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl String:PlayerName[32];

	//Initialize:
	GetCmdArg(1, PlayerName, sizeof(PlayerName));

	decl String:showname[2];
	showname = "0";
	
	MakeDoor(Client,PlayerName,0,StringToInt(showname));
	return Plugin_Handled;
}

public Action:CommandTakeDoorAll(Client, Arguments)
{
	if(Arguments > 0)
	{
		PrintToConsole(Client, "[RP] Usage: sm_takedoorall <NO ARGS>");
		return Plugin_Handled;
	}
	decl Ent;
	Ent = GetClientAimTarget(Client, false);

	if(Ent <= 1)
	{
		PrintToConsole(Client, "[RP] Invalid Door.");
		return Plugin_Handled;	
	}
	decl String:ClassName[255];
	GetEdictClassname(Ent, ClassName, 255);

	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{
		PrintToConsole(Client, "[RP] Invalid Door.");
		return Plugin_Handled;
	}
	
	return Plugin_Handled;
}

stock MakeDoor(Client,String:PlayerName[32],What,showname=0)
{
	decl MaxPlayers, Player;
	Player = -1;
	MaxPlayers = GetMaxClients();
	
	decl String:target_name[255];
	decl target_list[33], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(
			PlayerName,
			Client,
			target_list,
			MaxPlayers,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		PrintToConsole(Client, "[RP] Could not find Client %s", PlayerName);
		return true;
	}
	
	if(target_count > 1)
	{
		PrintToConsole(Client, "[RP] Token %s not unique", PlayerName);
		return true;
	}
	
	Player = target_list[0];

	//Declare:
	decl Ent;
	decl String:Name[32], String:ClassName[255];

	//Name:
	GetClientName(Player, Name, 32);

	//Ent:
	Ent = GetClientAimTarget(Client, false);

	//Error:
	if(Ent <= 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Invalid Door.");

		//Return:
		return true;	
	}

	//Classname:	
	GetEdictClassname(Ent, ClassName, 255);

	//Error:
	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{

		//Print:
		PrintToConsole(Client, "[RP] Invalid Door.");

		//Return:
		return true;
	}

	if(CustomDoor[Ent] == 1 && What == 1)
	{
		if(CustomDoorMode[Ent] == 1)
		{
			ServerCommand("saveowner %d %d 11", Player, Ent);
			OwnsDoor[Player][Ent] = 1;
			PrintToChat(Client, "[RP] %s has been given ownership of custom door #%d.", Name, Ent);
		}
		if(CustomDoorMode[Ent] == 2)
		{
			PrintToChat(Client, "[RP] This custom door is temporarily made.  You can only give/take this door out if its saved in the database!");
		}
	}
	else if(CustomDoor[Ent] == 1 && What == 0)
	{
		if(CustomDoorMode[Ent] == 1)
		{
			ServerCommand("saveowner %d %d 99", Player, Ent);
			OwnsDoor[Player][Ent] = 0;
			PrintToChat(Client, "[RP] %s has lost ownership of custom door #%d.", Name, Ent);
		}
		if(CustomDoorMode[Ent] == 2)
		{
			PrintToChat(Client, "[RP] This custom door is temporarily made.  You can only give/take this door out if its saved in the database!");
		}
	}
	else
	{
		//Not Owner:
		if(OwnsDoor[Player][Ent] == What)
		{

			//Print:
			if(What == 0)
				PrintToConsole(Client, "[RP] Player does not own that door");
			else
				PrintToConsole(Client, "[RP] Player already owns the door");

			//Return:
			return true;
		}
	
		//Save:
		OwnsDoor[Player][Ent] = What;
	
		if(What == 0)
		{
			Delete(Player, Ent);
			PrintToChat(Client, "[RP] %s has lost ownership of door #%d.", Name, Ent);
			PrintToChat(Player, "[RP] You have lost ownership of door #%d.", Ent);
			OwnsDoor[Player][Ent] = 0;

			if(GetConVarInt(LogDoors) > 0)
			{
				decl Handle:Log, Line;
				Log = CreateKeyValues("DoorLog");
				FileToKeyValues(Log, DoorLogPath);

				decl String:EntString[10];
				IntToString(Ent, EntString, 10);
				KvJumpToKey(Log, EntString, true);
				Line = KvGetNum(Log, "Line", 0);
				Line = Line + 1;
				KvSetNum(Log, "Line", Line);
			
				decl String:Date[128], String:LogMess[128], String:AdminName[32];
				FormatTime(Date, 128, "[%x] [%I:%M:%S]");
				GetClientName(Client, AdminName, 32);
				Format(LogMess, sizeof(LogMess), "%s %s took keys from %s", Date, AdminName, Name);
			
				decl String:LineString[10];
				IntToString(Line, LineString, 10);
				KvSetString(Log, LineString, LogMess);
				KvRewind(Log);
				KeyValuesToFile(Log, DoorLogPath);
				CloseHandle(Log);
			}
		} else
		{
			Save(Player,Ent);
			PrintToChat(Client, "[RP] %s has been given ownership of door #%d.", Name, Ent);
			PrintToChat(Player, "[RP] You have been given ownership of door #%d.", Ent);
			OwnsDoor[Player][Ent] = 1;

			if(GetConVarInt(LogDoors) > 0)
			{
				decl Handle:Log, Line;
				Log = CreateKeyValues("DoorLog");
				FileToKeyValues(Log, DoorLogPath);

				decl String:EntString[10];
				IntToString(Ent, EntString, 10);
				KvJumpToKey(Log, EntString, true);
				Line = KvGetNum(Log, "Line", 0);
				Line = Line + 1;
				KvSetNum(Log, "Line", Line);
			
				decl String:Date[128], String:LogMess[128], String:AdminName[32];
				FormatTime(Date, 128, "[%x] [%I:%M:%S]");
				GetClientName(Client, AdminName, 32);
				Format(LogMess, sizeof(LogMess), "%s %s gave keys to %s", Date, AdminName, Name);
			
				decl String:LineString[10];
				IntToString(Line, LineString, 10);
				KvSetString(Log, LineString, LogMess);
				KvRewind(Log);	
				KeyValuesToFile(Log, DoorLogPath);
				CloseHandle(Log);
			}
		}
		return true;
	}
	return true;
}

//Give Door:
public Action:CommandDoorCop(Client, Arguments)
{

	//Arguments:
	if(Arguments < 2)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_copdoor <#id|name> <1|0>");

		//Return:
		return Plugin_Handled;
	}
	decl MaxPlayers, Player,String:PlayerName[50],what,String:Buffer[5];
	Player = -1;
	MaxPlayers = GetMaxClients();
	decl String:target_name[255];
	decl target_list[33], target_count, bool:tn_is_ml;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	GetCmdArg(2, Buffer, sizeof(Buffer));
	what = StringToInt(Buffer);

	if ((target_count = ProcessTargetString(
			PlayerName,
			Client,
			target_list,
			MaxPlayers,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		PrintToConsole(Client, "[RP] Could not find Client %s", PlayerName);
		return Plugin_Handled;
	}
	
	if(target_count > 1)
	{
		PrintToConsole(Client, "[RP] Token %s not unique", PlayerName);
		return Plugin_Handled;
	}
	
	Player = target_list[0];
	
	for(new X = 0; X < 64; X++)
	{
		if(PoliceDoors[X] != 0)
			OwnsDoor[Player][PoliceDoors[X]] = what;
	}

	//Return:
	return Plugin_Handled;
}

//Give Door (Firefighters):
public Action:CommandDoorFire(Client, Arguments)
{

	//Arguments:
	if(Arguments < 2)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_firedoor <#id|name> <1|0>");

		//Return:
		return Plugin_Handled;
	}
	decl MaxPlayers, Player,String:PlayerName[50],what,String:Buffer[5];
	Player = -1;
	MaxPlayers = GetMaxClients();
	decl String:target_name[255];
	decl target_list[33], target_count, bool:tn_is_ml;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	GetCmdArg(2, Buffer, sizeof(Buffer));
	what = StringToInt(Buffer);

	if ((target_count = ProcessTargetString(
			PlayerName,
			Client,
			target_list,
			MaxPlayers,
			0,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		PrintToConsole(Client, "[RP] Could not find Client %s", PlayerName);
		return Plugin_Handled;
	}
	
	if(target_count > 1)
	{
		PrintToConsole(Client, "[RP] Token %s not unique", PlayerName);
		return Plugin_Handled;
	}
	
	Player = target_list[0];
	
	for(new X = 0; X < 64; X++)
	{
		if(FireDoors[X] != 0)
			OwnsDoor[Player][FireDoors[X]] = what;
	}

	//Return:
	return Plugin_Handled;
}

//Save Door:
stock Save(Client = 0, Ent = -1, autoremove = 0)
{

	//Declare:
	decl Handle:Vault;
	decl String:SteamId[255], String:Key[32];
	
	//Initialize:
	if(Client != 0) GetClientAuthString(Client, SteamId, 32);
	Vault = CreateKeyValues("Vault");

	//Retrieve:
	FileToKeyValues(Vault, DoorPath);

	//Valid:
	if(Ent != -1)
	{

		//Convert:
		IntToString(Ent, Key, 32);
		
		//Save:
		SaveInteger(Vault, Key, SteamId, 1);
		
		
		new String:KeyBuffer[255];
		IntToString(Ent, KeyBuffer, 255);
		
		
		decl String:SaveBuffer[255];

		//Speichere Autoremoves
		decl String:SteamIdBuffer[32];
		GetClientAuthString(Client, SteamIdBuffer, 32);
		IntToString(autoremove, SaveBuffer, 255);
		SaveString(Vault, SteamIdBuffer, KeyBuffer, SaveBuffer);
	}

	//Locked Doors:
	if(Client == 0)
	{

		//Declare:
		decl String:DoorId[255];

		//Loop:
		for(new X = 0; X < MAXDOORS; X++)
		{
	
			//Convert:
			IntToString(X, DoorId, 255);

			//Save:
			if(Locked[X] == 1) SaveInteger(Vault, "Locked", DoorId, Locked[X]);
		}
	}

	//Store:
	KeyValuesToFile(Vault, DoorPath);

	//Close:
	CloseHandle(Vault);
}
                 			
//Load Doors:
stock Load(Client = 0)
{

	//Declare:
	decl Handle:Vault;
	decl String:SteamId[255], String:Key[32];
	
	//Initialize:
	if(Client != 0) GetClientAuthString(Client, SteamId, 32);
	Vault = CreateKeyValues("Vault");
	
	//Load:
	FileToKeyValues(Vault, DoorPath);

	//Valid Client:
	if(Client != 0)
	{

		//Loop:
		for(new X = 0; X < MAXDOORS; X++)
		{

			//Convert:
			IntToString(X, Key, 32);

			//Load:
			OwnsDoor[Client][X] = LoadInteger(Vault, Key, SteamId, 0);
		}
	}

	//Locked Doors:
	if(Client == 0)
	{

		//Declare:
		decl String:DoorId[255];

		//Loop:
		for(new X = 0; X < MAXDOORS; X++)
		{

			//Convert:
			IntToString(X, DoorId, 255);
			
			//Load:
			Locked[X] = LoadInteger(Vault, "Locked", DoorId, 0);

			//Lock:
			if(Locked[X] == 1)
			{

				//Declare:
				decl String:ClassName[255];

				//Class Name:
				GetEdictClassname(X, ClassName, 255);

				//Valid:
				if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")) AcceptEntityInput(X, "Lock", 0);
				if(StrEqual(ClassName, "func_door")) AcceptEntityInput(X, "Unlock", 0);
			}
		}
	}

	//Close:
	CloseHandle(Vault);
}

//Delete Delete:
stock Delete(Client = 0, Ent = -1)
{

	//Declare:
	decl Handle:Vault;
	decl String:SteamId[255], String:Key[32];
	
	//Initialize:
	if(Client != 0) GetClientAuthString(Client, SteamId, 32);
	Vault = CreateKeyValues("Vault");

	//Retrieve:
	FileToKeyValues(Vault, DoorPath);

	//Valid:
	if(Ent != -1)
	{

		//Convert:
		IntToString(Ent, Key, 32);

		//Delete:
		KvJumpToKey(Vault, Key, false);
		KvDeleteKey(Vault, SteamId); 
		KvRewind(Vault);
		
		KvJumpToKey(Vault, SteamId, false);
		KvDeleteKey(Vault, Key); 
		KvRewind(Vault);
	}

	//Locked Doors:
	if(Client == 0)
	{

		//Declare:
		decl String:DoorId[255];

		//Loop:
		for(new X = 0; X < MAXDOORS; X++)
		{

			//Convert:
			IntToString(X, DoorId, 255);

			//Delete:
			KvJumpToKey(Vault, "Locked", false);
			KvDeleteKey(Vault, DoorId);
			KvRewind(Vault);
		}
	}

	//Store:
	KeyValuesToFile(Vault, DoorPath);

	//Close:
	CloseHandle(Vault);
}

public Action:HandleSay(Client, Args)
{
	//World:
	if(Client == 0) return Plugin_Handled;

	//Declare:
	decl String:Arg[255];

	//Initialize:
	GetCmdArgString(Arg, sizeof(Arg));

	//Clean:
	StripQuotes(Arg);
	TrimString(Arg);
	
	//Listdoor:
	if(StrContains(Arg, "/door", false) == 0)
	{
		decl Ent;
		Ent = GetClientAimTarget(Client, false);
		if(Ent < 1)
		{
			PrintToChat(Client, "[RP] No Door selected");
			return Plugin_Handled;
		}
		decl String:ClassName[255];
		GetEdictClassname(Ent, ClassName, 20);
		if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
		{
			PrintToChat(Client, "[RP] No Door selected");
			return Plugin_Handled;
		}
		
		PrintToChat(Client, "[RP] Online Owner of door #%d:",Ent);      
    		for(new x = 1; x<GetMaxClients(); x++)
    		{
			if(IsClientConnected(x) && IsClientInGame(x))
			{
    				new String:Name[32];
	    			GetClientName(x, Name, 32);
        			if(OwnsDoor[x][Ent]) PrintToChat(Client, "[RP] %s",Name);
			}
		}
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

//Give Door:
public Action:CommandGiveDoorClient(Client, Arguments)
{

	//Arguments:
	if(Arguments < 1)
	{
		return Plugin_Handled;
	}

	decl String:SkinBuff[64];
  	GetClientModel(Client, SkinBuff, 64);
  
  	//Kein Markler
  	if(!StrEqual(SkinBuff, "models/monk.mdl", false))
  	{
  		return Plugin_Handled;
  	}
  
	//Declare:
	decl String:PlayerName[32];

	//Initialize:
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	decl Ent;
	decl String:ClassName[255];
	
	Ent = GetClientAimTarget(Client, false);
	GetEdictClassname(Ent, ClassName, 20);
	
	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{
		PrintToChat(Client, "[RP] No Door selected");
		return Plugin_Handled;
	}
	if(OwnsDoor[Client][Ent])
		MakeDoor(Client,PlayerName,1);
		
	return Plugin_Handled;
}

//Take Door:
public Action:CommandTakeDoorClient(Client, Arguments)
{

	//Arguments:
	if(Arguments < 1)
	{
		return Plugin_Handled;
	}

	decl String:SkinBuff[64];
  
 	GetClientModel(Client, SkinBuff, 64);
  
  	//Kein Markler
  	if(!StrEqual(SkinBuff, "models/monk.mdl", false))
  	{
  		return Plugin_Handled;
  	}
  
	//Declare:
	decl String:PlayerName[32];

	//Initialize:
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	decl Ent;
	decl String:ClassName[255];
	
	Ent = GetClientAimTarget(Client, false);
	GetEdictClassname(Ent, ClassName, 20);
	
	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{
		PrintToChat(Client, "[RP] No Door selected");
		return Plugin_Handled;
	}
	if(OwnsDoor[Client][Ent])
		MakeDoor(Client,PlayerName,0);
		
	return Plugin_Handled;
}

//Take Door:
public Action:CommandTakeSteamid(Client, Arguments)
{
	decl Ent,Handle:Vault,String:ClassName[20];
	Ent = GetClientAimTarget(Client, false);
	GetEdictClassname(Ent, ClassName, 20);
	
	//Arguments:
	if(Arguments < 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_takedoorbyid <SteamId>");

		//Return:
		return Plugin_Handled;
	}
	
	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{
		PrintToConsole(Client, "[RP] No Door selected");
		return Plugin_Handled;
	}
	
	//Declare:
	decl String:PlayerName[255],String:Key[32];

	//Initialize:
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	//Convert:
	IntToString(Ent, Key, 32);
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, DoorPath);
	
	//Delete:
	KvJumpToKey(Vault, Key, false);
	KvDeleteKey(Vault, PlayerName); 
	KvRewind(Vault);
	
	KvJumpToKey(Vault, PlayerName, false);
	KvDeleteKey(Vault, Key); 
	KvRewind(Vault);
		
	//Store:
	KeyValuesToFile(Vault, DoorPath);

	//Close:
	CloseHandle(Vault);
	PrintToConsole(Client, "[RP] Removed SteamId (%s) from Database",PlayerName);
	return Plugin_Handled;
}

//Take Door:
public Action:CommandShowAll(Client, Arguments)
{
	decl Ent,Handle:Vault,Handle:Vault2,String:ClassName[20];
	Ent = GetClientAimTarget(Client, false);
	GetEdictClassname(Ent, ClassName, 20);
	
	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{
		PrintToConsole(Client, "[RP] No Door selected");
		return Plugin_Handled;
	}
	
	Vault = CreateKeyValues("Vault");
	Vault2 = CreateKeyValues("Vault");
	decl String:EntS[40];
	decl String:buffer[255],String:Name[255],String:LastSeen[255],TimeStamp;
	IntToString(Ent,EntS,40);
	PrintToConsole(Client, "[RP] Starting lookup for door %d...",Ent);
	
	//Load:
	FileToKeyValues(Vault, DoorPath);
	FileToKeyValues(Vault2, NamePath);
	KvJumpToKey(Vault, EntS, true);
	KvGotoFirstSubKey(Vault,false);
	do
	{
		KvGetSectionName(Vault, buffer, sizeof(buffer));
		LoadString(Vault2, "name", buffer, "null", Name);
		LoadString(Vault2, "seen", buffer, "0", LastSeen);
		TimeStamp = StringToInt(LastSeen);
		FormatTime(LastSeen,255,"%d.%m.%Y",TimeStamp);
		
		if(!StrEqual(Name, "null", false))
			PrintToConsole(Client, "[RP] found: %s (%s) - Last Online: %s",buffer,Name,LastSeen);
		else
			PrintToConsole(Client, "[RP] found: %s",buffer);
	} while (KvGotoNextKey(Vault,false));
	CloseHandle(Vault);
	CloseHandle(Vault2);
	return Plugin_Handled;
}

public Action:AddDoor(Client, Arguments)
{
	if(Client != 0)
	{
		PrintToChat(Client, "[RP] Access Denied.");
		return Plugin_Handled;
	}
	decl String:DoorNumber[25];
	GetCmdArg(1, DoorNumber, sizeof(DoorNumber));
	decl String:DoorMode[25];
	GetCmdArg(2, DoorMode, sizeof(DoorMode));
	decl Convert;
	Convert = StringToInt(DoorNumber);
	decl Convert2;
	Convert2 = StringToInt(DoorMode);

	CustomDoor[Convert] = 1;
	CustomDoorMode[Convert] = Convert2;
	return Plugin_Handled;
}

public Action:AddDoorOwner(Client, Arguments)
{
	if(Client != 0)
	{
		PrintToChat(Client, "[RP] Access Denied.");
		return Plugin_Handled;
	}
	decl String:Userid[25];
	GetCmdArg(1, Userid, sizeof(Userid));
	decl String:DoorAssign[25];
	GetCmdArg(2, DoorAssign, sizeof(DoorAssign));
	decl UseridI;
	UseridI = StringToInt(Userid);
	decl DoorAssignI;
	DoorAssignI = StringToInt(DoorAssign);

	OwnsDoor[UseridI][DoorAssignI] = 1;
	return Plugin_Handled;
}

public Action:AutoLock(Client, Arguments)
{
	if(Client != 0)
	{
		PrintToChat(Client, "[RP] Access Denied.");
		return Plugin_Handled;
	}
	decl String:Doorid[25];
	GetCmdArg(1, Doorid, sizeof(Doorid));
	decl Ent;
	Ent = StringToInt(Doorid);
	AcceptEntityInput(Ent, "Lock", Client);
	Locked[Ent] = 1;
	Save();
	return Plugin_Handled;
}

public Action:AutoUnlock(Client, Arguments)
{
	if(Client != 0)
	{
		PrintToChat(Client, "[RP] Access Denied.");
		return Plugin_Handled;
	}
	decl String:Doorid[25];
	GetCmdArg(1, Doorid, sizeof(Doorid));
	decl Ent;
	Ent = StringToInt(Doorid);
	AcceptEntityInput(Ent, "Unlock", Client);
	Locked[Ent] = 0;
	Delete();
	return Plugin_Handled;
}

//Prethink:
public OnGameFrame()
{

	//Declare:
	decl MaxPlayers;

	//Initialize:
	MaxPlayers = GetMaxClients();

	//Loop:
	for(new Client = 1; Client <= MaxPlayers; Client++)
	{

		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{

			//Alive:
			if(IsPlayerAlive(Client))
			{

				//E Key:
				if(GetClientButtons(Client) & IN_USE)
				{

					//Overflow:
					if(!PrethinkBuffer[Client])
					{

						//Action:
						CommandUse(Client);

						//UnHook:
						PrethinkBuffer[Client] = true;
					}
				}

				//Shift:
				else if(GetClientButtons(Client) & IN_SPEED)
				{

					//Overflow:
					if(!PrethinkBuffer[Client])
					{

						//Action:
						CommandSpeed(Client);

						//UnHook:
						PrethinkBuffer[Client] = true;
					}
				}
				
				//R or Reload Button:
				else if(GetClientButtons(Client) & IN_RELOAD)
				{
					if(!PrethinkBuffer[Client])
					{
						CommandDoorMenu(Client);

						//UnHook:
						PrethinkBuffer[Client] = true;
					}
				}
				//Nothing:
				else
				{

					//Hook:
					PrethinkBuffer[Client] = false;
				}
			}
		}
	}
}

//E Key:
public Action:CommandUse(Client)
{

	//Declare:
	decl Ent;
	decl String:ClassName[255];

	//Initialize:
	Ent = GetClientAimTarget(Client, false);

	//Valid:
	if(Ent != -1)
	{

		//Class Name:
		GetEdictClassname(Ent, ClassName, 255);

		//Ownership:
		if(OwnsDoor[Client][Ent] == 1)
		{

			//Valid:
			if(StrEqual(ClassName, "func_door"))
			{

				//Locked:
				if(Locked[Ent] == 1) AcceptEntityInput(Ent, "Unlock", Client);

				//Open:
				AcceptEntityInput(Ent, "Toggle", Client);

				//Locked:
				if(Locked[Ent] == 1) AcceptEntityInput(Ent, "Lock", Client);
			}
		}
	}
}

//Shift Key:
public Action:CommandSpeed(Client)
{

	//Declare:
	decl Ent;
	decl String:ClassName[255];

	//Initialize:
	Ent = GetClientAimTarget(Client, false);

	//Valid:
	if(Ent != -1)
	{

		//Class Name:
		GetEdictClassname(Ent, ClassName, 255);

		//Ownership:
		if(OwnsDoor[Client][Ent] == 1)
		{

			//Valid:
			if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
			{
				decl Float:ClientOrigin[3], Float:EntOrigin[3];  
				decl Float:Dist; 
				GetClientAbsOrigin(Client, ClientOrigin);
				GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);
				Dist = GetVectorDistance(ClientOrigin, EntOrigin);
                
		                if(Dist <= 100)
                		{
					//Lock:
					if(Locked[Ent] != 1)
					{

						//Lock:
						Locked[Ent] = 1;
		    
						//Print:
						PrintToChat(Client, "[RP] You lock the door");

						//Lock:
						AcceptEntityInput(Ent, "Lock", Client);

						//Save:
						Save();
					}

					//Unlock:
					else if(Locked[Ent] == 1)
					{

						//Unlock:
						Locked[Ent] = 0;
	    
						//Print:
						PrintToChat(Client, "[RP] You unlock the door");

						//Unlock:
						AcceptEntityInput(Ent, "Unlock", Client);

						//Save:
						Delete();
					}
				}
			}
		}
	}
}

public Action:CommandDoorMenu(Client)
{
	decl Ent;
	Ent = GetClientAimTarget(Client, false);

	if(Ent != -1)
	{
		decl String:ClassName[255];
		GetEdictClassname(Ent, ClassName, 255);
		if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
		{
			decl Float:Distance, Float:YourOrigin[3], Float:DoorOrigin[3];
			GetClientAbsOrigin(Client, YourOrigin);
			GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", DoorOrigin);
			Distance = GetVectorDistance(YourOrigin, DoorOrigin);
			decl lock, own;
			lock = Locked[Ent];
			own = OwnsDoor[Client][Ent];
			if(Distance < 200)
			{
				ServerCommand("sm_doormenu %d %d %d %d", Client, Ent, lock, own);
			}
		}
	}
}

public Action:CommandDoorHistory(Client, Arguments)
{
	if(Arguments < 1)
	{
		PrintToChat(Client, "[RP] Usage: sm_doorhistory <door number>");
		return Plugin_Handled;
	}
	decl String:DoorNumber[10];
	GetCmdArg(1, DoorNumber, sizeof(DoorNumber));
	
	PrintToConsole(Client, "===================");
	PrintToConsole(Client, "Door Log For #%s", DoorNumber);
	PrintToConsole(Client, "===================");

	decl Handle:Log, Line;
	Log = CreateKeyValues("DoorLog");
	FileToKeyValues(Log, DoorLogPath);

	KvJumpToKey(Log, DoorNumber, false);
	Line = KvGetNum(Log, "Line", 0);

	for(new L = 1; L <= Line; L++)
	{
		decl String:LineString[10], String:LogLineMess[128];
		IntToString(L, LineString, 10);
		KvGetString(Log, LineString, LogLineMess, 128, "ERROR");
		PrintToConsole(Client, "%s", LogLineMess);
	}
	KvRewind(Log);	
	CloseHandle(Log);
	return Plugin_Handled;
}

public Action:CommandClearDoorHistory(Client, Arguments)
{
	if(Arguments < 1)
	{
		PrintToChat(Client, "[RP] Usage: sm_cleardoorhistory <door number>");
		return Plugin_Handled;
	}
	decl String:DoorNumber[10];
	GetCmdArg(1, DoorNumber, sizeof(DoorNumber));

	decl Handle:Log, Line;
	Log = CreateKeyValues("DoorLog");
	FileToKeyValues(Log, DoorLogPath);
	KvJumpToKey(Log, DoorNumber, false);
	Line = KvGetNum(Log, "Line", 0);
	if(Line > 0)
	{
		KvDeleteThis(Log);
	}
	KvRewind(Log);
	KeyValuesToFile(Log, DoorLogPath);
	CloseHandle(Log);
	PrintToConsole(Client, "[RP] Deleted Door Log For #%s", DoorNumber);
	return Plugin_Handled;
}

public Action:Reload(Client, Arguments)
{
	if(Client != 0) return Plugin_Handled;
	decl String:Redo[10];
	GetCmdArg(1, Redo, sizeof(Redo));
	decl String:Door[10];
	GetCmdArg(2, Door, sizeof(Door));

	decl lock;
	lock = Locked[StringToInt(Door)];

	ServerCommand("sm_doormenu %s %s %d 1", Redo, Door, lock);
	return Plugin_Handled;
}

//Information:
public Plugin:myinfo =
{

	//Initation:
	name = "Doors",
	author = "Joe 'Pinkfairie' Maley and Krim",
	description = "Doormod for RP",
	version = "1.1",
	url = "hiimjoemaley@hotmail.com & wmchris.de"
}

//Map Start:
public OnMapStart()
{
	decl String:MapName[128];
	GetCurrentMap(MapName, 128);

	decl String:FinalPathC[128];
	Format(FinalPathC, sizeof(FinalPathC), "data/roleplay/%s/config.txt", MapName);

	decl String:FinalPathD[128];
	Format(FinalPathD, sizeof(FinalPathD), "data/roleplay/%s/doors.txt", MapName);

	decl String:FinalPathLog[128];
	Format(FinalPathLog, sizeof(FinalPathLog), "data/roleplay/%s/doorlog.txt", MapName);

	BuildPath(Path_SM, ConfigPath, 128, FinalPathC);
	BuildPath(Path_SM, DoorPath, 128, FinalPathD);
	BuildPath(Path_SM, DoorLogPath, 128, FinalPathLog);

	//Load Locked Doors:
	Load();


	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, ConfigPath);
	new String:Entity[255];
	for(new X = 0; X < 64; X++)
	{
		IntToString(X, Entity, 255);
		
		PoliceDoors[X] = LoadInteger(Vault, "PoliceDoor", Entity, 0);
		FireDoors[X] = LoadInteger(Vault, "FirefighterDoor", Entity, 0);
	}
	KvRewind(Vault);
	CloseHandle(Vault);
}

//Initation:
public OnPluginStart()
{

	//Admin Commands:
	RegAdminCmd("sm_refreshdoors", CommandRefreshDoor, ADMFLAG_ROOT, "<Name> - Refreshes clients doors. Used for buydoor.");
	RegAdminCmd("sm_givedoor", CommandGiveDoor, ADMFLAG_CUSTOM3, "<Name> - Gives the door to a player");
	RegAdminCmd("sm_copdoor", CommandDoorCop, ADMFLAG_CUSTOM3, "<Name> - Gives the door to a player");
	RegAdminCmd("sm_firedoor", CommandDoorFire, ADMFLAG_CUSTOM3, "<Name> - Gives the door to a player");
	RegAdminCmd("sm_takedoor", CommandTakeDoor, ADMFLAG_CUSTOM3, "<Name> - Takes the door from a player");
	RegAdminCmd("sm_doorshow", CommandShowAll, ADMFLAG_CUSTOM3, " - Lookup for owner");
	RegAdminCmd("sm_takedoorbyid", CommandTakeSteamid, ADMFLAG_CUSTOM3, "<SteamID> - Remove user by SteamId");
	RegAdminCmd("sm_takedoorall", CommandTakeDoorAll, ADMFLAG_CUSTOM3, " - Take Everyones key from the door you look at");
	RegAdminCmd("sm_doorhistory", CommandDoorHistory, ADMFLAG_CUSTOM5, "- Gives history of admins who gave/took doors");	
	RegAdminCmd("sm_cleardoorhistory", CommandClearDoorHistory, ADMFLAG_ROOT, "- Clear History For A Door");

    	RegAdminCmd("sm_listdoor", CommandListDoor, ADMFLAG_CUSTOM3, "Point and go"); 
    	RegConsoleCmd("say", HandleSay);

	//Not To Be Used By Any Admin (for server use):
	RegAdminCmd("customdoorarray", AddDoor, ADMFLAG_ROOT, " - Server Use Only");
	RegAdminCmd("owndoor", AddDoorOwner, ADMFLAG_ROOT, " - Server Use Only");
	RegAdminCmd("sm_autodoorlock", AutoLock, ADMFLAG_ROOT, " - Server Use Only");
	RegAdminCmd("sm_autodoorunlock", AutoUnlock, ADMFLAG_ROOT, " - Server Use Only");
	RegAdminCmd("sm_backtodoor", Reload, ADMFLAG_ROOT, " - Server Use Only");

	//These commands have exploits so they're disabled.
    	//RegConsoleCmd("sm_gdoor",CommandGiveDoorClient);
    	//RegConsoleCmd("sm_tdoor",CommandTakeDoorClient);
   
	LogDoors = CreateConVar("sv_logdoors", "1", "[RP] Log Door Commands. 0 = off, 1 = on", FCVAR_PLUGIN);	

	//Name DB:
	BuildPath(Path_SM, NamePath, 64, "data/roleplay/names.txt");
	if(FileExists(NamePath) == false) PrintToConsole(0, "[SM] ERROR: Missing file '%s'", NamePath);

	//Server Variable:
	CreateConVar("door_version", "2.0", "Doors Version",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	LoadTranslations("common.phrases");
}
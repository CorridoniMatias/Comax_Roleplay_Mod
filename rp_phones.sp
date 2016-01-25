//Phones v3.1 by [GR]Nick_6893:

//Includes:
#include <sourcemod>
#include <sdktools>

//Terminate:
#pragma semicolon 1

//Stocks:
#include "rp_stocks"

//Definitions:
#define MAXPHONES 50
#define MAXDISTANCE 50

//Database:
static String:SpawnPath[128];
static Float:PhonePoints[MAXPHONES][3];
static bool:PrethinkBuffer[33] = false;

//Calling:
static Connected[33];
new bool:Answered[33] = false;

//Timers:
static TimeOut[33];

//Information:
public Plugin:myinfo =
{

	//Initation:
	name = "Phones",
	author = "[GR]Nick_6893",
	description = "Adds Phone Functions for RP",
	version = "1.0",
	url = "www.sourcemod.net"
}

//Initation:
public OnPluginStart()
{
	HookEvent("player_death", EventDeath);

	//Commands:
	RegAdminCmd("sm_createphone", CommandCreatePhone, ADMFLAG_CUSTOM4, "<id> - Creates a phone function");
	RegAdminCmd("sm_removephone", CommandRemovePhone, ADMFLAG_CUSTOM4, "<id> - Removes a phone function");
	RegAdminCmd("sm_phonelist", CommandListPhones, ADMFLAG_CUSTOM1, "- Lists all the Phones in the database");
	RegConsoleCmd("say", CommandSay);	

	//Phone DB:
	BuildPath(Path_SM, SpawnPath, 64, "data/roleplay/phones.txt");
	if(FileExists(SpawnPath) == false) PrintToConsole(0, "[SM] ERROR: Missing file '%s'", SpawnPath);

	//Server Variable:
	CreateConVar("phone_version", "1.0", "Phone Version",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
}

//Map Start:
public OnMapStart()
{
	CreateTimer(1.0, LoadPhones);

	//Precache:
	PrecacheSound("roleplay/ring.wav", true);
	AddFileToDownloadsTable("sound/roleplay/ring.wav");	
}

//In-Game:
public OnClientPutInServer(Client)
{

	//Default:
	Connected[Client] = 0;
	Answered[Client] = false;
	TimeOut[Client] = 0;
}

//Disconnect:
public OnClientDisconnect(Client)
{

	//Connected:
	if(Connected[Client] != 0)
	{

		//Declare:
		decl Player;

		//Initialize:
		Player = Connected[Client];

		//Print:
		PrintToChat(Player, "[RP] You have lost service, phone conversation aborted");
	
		//Send:
		Connected[Client] = 0;
		Answered[Client] = false;
		Connected[Player] = 0;
		Answered[Player] = false;
	}
}

//Create Phone:
public Action:CommandCreatePhone(Client, Args)
{

	//Error:
	if(Args < 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_createphone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl Handle:Vault;
	decl String:PhoneId[32];
	decl Float:ClientOrigin[3];

	//Initialize:
	GetCmdArg(1, PhoneId, 32);
	GetClientAbsOrigin(Client, ClientOrigin);

	decl String:MapName[64];
	GetCurrentMap(MapName, 64);

	//Vault:
	Vault = CreateKeyValues("Vault");

	//Retrieve:
	FileToKeyValues(Vault, SpawnPath);

	//Save:
	KvJumpToKey(Vault, MapName, true);
	KvSetVector(Vault, PhoneId, ClientOrigin);
	KvRewind(Vault);

	//Store:
	KeyValuesToFile(Vault, SpawnPath);

	//Print:
	PrintToConsole(Client, "[RP] Created phone #%s @ <%f, %f, %f>", PhoneId, ClientOrigin[0], ClientOrigin[1], ClientOrigin[2]);
	CreateTimer(1.0, LoadPhones);
	
	//Close:
	CloseHandle(Vault);

	//Return:
	return Plugin_Handled;
}

//Remove Phone:
public Action:CommandRemovePhone(Client, Args)
{

	//Error:
	if(Args < 1)
	{

		//Print:
		PrintToConsole(Client, "[RP] Usage: sm_removephone <id>");

		//Return:
		return Plugin_Handled;
	}

	//Declare:
	decl Handle:Vault;
	decl String:PhoneId[32];

	//Initialize:
	GetCmdArg(1, PhoneId, sizeof(PhoneId));

	decl String:MapName[64];
	GetCurrentMap(MapName, 64);

	//Vault:
	Vault = CreateKeyValues("Vault");

	//Retrieve:
	FileToKeyValues(Vault, SpawnPath);

	//Delete:
	KvJumpToKey(Vault, MapName, false);
	KvDeleteKey(Vault, PhoneId); 
	KvRewind(Vault);

	//Store:
	KeyValuesToFile(Vault, SpawnPath);

	PrintToConsole(Client, "[RP] Removed Phone %s from the database", PhoneId);

	//Close:
	CloseHandle(Vault);
	CreateTimer(1.0, LoadPhones);

	//Return:
	return Plugin_Handled;
}

//List Phones:
public Action:CommandListPhones(Client, Args)
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
	PrintToConsole(Client, "Phones [%s]:", MapName);

	//Loop:
	for(new X = 0; X < MAXPHONES; X++)
	{

		//Check:
		if(PhonePoints[X][0] != 0.0) PrintToConsole(Client, "%d: <%f, %f, %f>", X, PhonePoints[X][0], PhonePoints[X][1], PhonePoints[X][2]);
	}

	//Close:
	CloseHandle(Vault);

	//Return:
	return Plugin_Handled;
}

public Action:LoadPhones(Handle:Timer, any:Client)
{

	//Declare:
	decl Handle:Vault;
	decl String:Key[32];

	//Initialize:
	Vault = CreateKeyValues("Vault");
	new Float:DefaultSpawn[3] = {0.0, 0.0, 0.0};

	//Retrieve:
	FileToKeyValues(Vault, SpawnPath);

	decl String:MapName[64];
	GetCurrentMap(MapName, 64);

	//Load:
	for(new X = 0; X < MAXPHONES; X++)
	{

		//Convert:
		IntToString(X, Key, 32);
		
		//Find:
		KvJumpToKey(Vault, MapName, false);
		KvGetVector(Vault, Key, PhonePoints[X], DefaultSpawn);
		KvRewind(Vault);
	}

	//Close:
	CloseHandle(Vault);
}

public Action:CallMenu(Client)
{
	PrintToChat(Client, "[RP] Press <Escape> to access the phone menu.");

	new Handle:menu = CreateMenu(PhoneMenu);
	SetMenuTitle(menu, "Phone Menu");

	new maxClients = GetMaxClients();
	for (new i=1; i<=maxClients; i++)
		{
			if (!IsClientInGame(i))
			{
				continue;
			}
			decl String:name[65], String:ID[25];
			GetClientName(i, name, sizeof(name));
			IntToString(i, ID, sizeof(ID));
			AddMenuItem(menu, ID, name);
		}
	SetMenuPagination(menu, 7);
	DisplayMenu(menu, Client, 20);
 
	return Plugin_Handled;

}

public PhoneMenu(Handle:menu, MenuAction:action, Client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[64], Player;
		GetMenuItem(menu, param2, info, sizeof(info));
		Player = StringToInt(info);

		if(Player == -1)
		{
			PrintToChat(Client, "[RP] Could not find client");
		}
		else if(Player == Client)
		{
			PrintToChat(Client, "[RP] You cannot call yourself");
		}
		else if(!IsPlayerAlive(Player))
		{
			PrintToChat(Client, "[RP] Cannot call a dead player");
		}
		else
		{
			Call(Client, Player);
		}
	}
}

public Action:CommandUse(Client)
{
	decl Float:ClientOrigin[3];
	GetClientAbsOrigin(Client, ClientOrigin);
	for(new X = 0; X < MAXPHONES; X++)
	{
		if(PhonePoints[X][0] != 0.0)
		{
			new Float:PhoneOrigin[3];
			PhoneOrigin[0] = PhonePoints[X][0];
			PhoneOrigin[1] = PhonePoints[X][1];
			PhoneOrigin[2] = PhonePoints[X][2];
			if(GetVectorDistance(ClientOrigin, PhoneOrigin) <= MAXDISTANCE)
			{
				CallMenu(Client);
			}
		}
	}
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
				else
				{
					PrethinkBuffer[Client] = false;
				}
			}
		}
	}
}







//===========================================
//Rp_Talkzone Phone Stock Commands:
//===========================================
//Death:
public Action:EventDeath(Handle:Event, const String:Name[], bool:Broadcast)
{

	//Declare:
	decl Client;

	//Initialize:
	Client = GetClientOfUserId(GetEventInt(Event, "userid"));

	//Hangup:
	if(Connected[Client] != 0) HangUp(Client);
}

//Calling:
stock Call(Client, Player)
{

	//World:
	if(Client != 0 && Player != 0)
	{

		//Declare:
		decl String:PlayerName[32];

		//Initialize:
		GetClientName(Player, PlayerName, sizeof(PlayerName));

		//Not Connected:
		if(Connected[Player] == 0)
		{

			//Initialize:
			Connected[Client] = Player;
			Connected[Player] = Client;
	
			//Print:
			PrintToChat(Client, "[RP] You call %s...", PlayerName);

			//Send:
			RecieveCall(Player);
			TimeOut[Client] = 40;
			CreateTimer(1.0, TimeOutCall, Client);

		}
		else
		{

			//Print:
			PrintToChat(Client, "[RP] %s is already on the phone", PlayerName);
		}
	}
}

//Recieve:
stock RecieveCall(Client)
{

	//Sound:
	EmitSoundToClient(Client, "roleplay/ring.wav", SOUND_FROM_PLAYER, 5);

	//Print:
	PrintToChat(Client, "[RP] Your phone is ringing, Type /answer to recieve the call");

	//Send:
	TimeOut[Client] = 40;
	CreateTimer(1.0, TimeOutRecieve, Client);
}

//Answer:
stock Answer(Client)
{

	//Connected:
	if(!Answered[Client] && Connected[Client] != 0)
	{

		//Declare:
		decl Player;
		decl String:ClientName[32];
	
		//Initialize:
		Player = Connected[Client];
		GetClientName(Client, ClientName, sizeof(ClientName));

		//Print:
		PrintToChat(Client, "[RP] You answer your phone");
		PrintToChat(Player, "[RP] %s answered their phone", ClientName);
	
		//Send:
		Answered[Client] = true;
		Answered[Player] = true;

		//Sound:
		StopSound(Client, 5, "roleplay/ring.wav");
	}
	else if(Answered[Client])
	{

		//Print:
		PrintToChat(Client, "[RP] You already answered the phone");
	}
	else
	{
		PrintToChat(Client, "[RP] No one is calling you!");
	}
}

//Hang Up:
stock HangUp(Client)
{

	//Connected:
	if(Connected[Client] != 0)
	{

		//Declare:
		decl Player;
		decl String:ClientName[32], String:PlayerName[32];
	
		//Initialize:
		Player = Connected[Client];
		GetClientName(Client, ClientName, sizeof(ClientName));
		GetClientName(Player, PlayerName, sizeof(PlayerName));

		//Print:
		PrintToChat(Client, "[RP] You hang up on %s", PlayerName);
		PrintToChat(Player, "[RP] %s hung up on you", ClientName);
	
		//Send:
		Connected[Client] = 0;
		Answered[Client] = false;
		Connected[Player] = 0;
		Answered[Player] = false;

		//Sound:
		StopSound(Client, 5, "roleplay/ring.wav");
	}
	else
	{

		//Print:
		PrintToChat(Client, "[RP] You are not on the phone");
	}
}

//Time Out (Calling):
public Action:TimeOutCall(Handle:Timer, any:Client)
{
	
	//Push:
	if(TimeOut[Client] > 0) TimeOut[Client] -= 1;

	//Broken Connection:
	if(Connected[Client] == 0)
	{

		//End:
		TimeOut[Client] = 0;
	}

	//Not Answered:
	if(!Answered[Client] && TimeOut[Client] == 1)
	{

		//Declare:
		decl Player;
		decl String:PlayerName[32];
	
		//Initialize:
		Player = Connected[Client];
		GetClientName(Player, PlayerName, sizeof(PlayerName));

		//Print:
		PrintToChat(Client, "[RP] %s failed to answer their phone", PlayerName);

		//End Connection:
		Answered[Client] = false;
		Connected[Client] = 0;	
	}

	//Loop:
	if(TimeOut[Client] > 0)
	{

		//Send:
		CreateTimer(1.0, TimeOutCall, Client);
	}
}

//Time Out (Recieve):
public Action:TimeOutRecieve(Handle:Timer, any:Client)
{

	//Push:
	if(TimeOut[Client] > 0) TimeOut[Client] -= 1;

	//Broken Connection:
	if(Connected[Client] == 0)
	{

		//End:
		TimeOut[Client] = 0;
	}

	//Not Answered:
	if(!Answered[Client] && TimeOut[Client] == 1)
	{

		//Print:
		PrintToChat(Client, "[RP] Your phone has stopped ringing");

		//End Connection:
		Answered[Client] = false;
		Connected[Client] = 0;
	}

	//Loop:
	if(TimeOut[Client] > 0)
	{

		//Send:
		CreateTimer(1.0, TimeOutRecieve, Client);
	}
}

//Handle Chat:
public Action:CommandSay(Client, Arguments)
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

	//Answer:
	if(StrContains(Arg, "/answer", false) == 0)
	{

		//Answer:
		Answer(Client);
		return Plugin_Handled;
	}

	//Hangup:
	if(StrContains(Arg, "/hangup", false) == 0)
	{

		//Call:
		HangUp(Client);
		return Plugin_Handled;
	}

	//Phone:
	if(Connected[Client] != 0)
	{

		//On the Phone:
		if(Answered[Client])
		{
			decl String:ClientName[32];
			GetClientName(Client, ClientName, 32);
	
			//Print:
			PrintSilentChat(Client, ClientName, Connected[Client], "Phone", Arg);

			//Return:
			return Plugin_Handled;
		}
	}

	//Close:
	return Plugin_Continue;
}

//Silent:
stock PrintSilentChat(Client, String:ClientName[32], Player, String:Message[32], String:Arg[255])
{

	//Print:
	PrintToChat(Client, "(%s) %s: %s", Message, ClientName, Arg);
	PrintToChat(Player, "(%s) %s: %s", Message, ClientName, Arg);
}
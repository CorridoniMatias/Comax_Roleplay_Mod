
//Admin Commands:
/* Command Levels (flags):
*	- Admin Custom 1: Internal & some client operations. Don't give to basic admins.
*	- Admin Custom 2: Super Donator.
*	- Admin Custom 3: Client operations & Police tasks. Only give to Police and trusted admins.
*	- Admin Custom 4: Basic only.
*	- Admin Custom 5: Basic Admins Commands.
*	- Admin Custom 6: Creates Jobs & handles NPCS. Can give to admins.
*/

//This is called in OnPluginStart()
public ComaxStart()
{
	//Here is where you call the function of your extension to load it. Sort of a "constructor".
	
	//Comax: Stability
	ComaxStability();
	
	//Comax: Pick Pocketing Mod
	ComaxPickPocket();
	
	//Comax: VIP Doors
	ComaxVipDoors();
	
	//Comax: Stats
	ComaxStats();
	
	//Comax: Cars	
	//Directory: uses same as the custom model ext: addons/sourcemod/data/roleplay/Comax
	ComaxCars();
	
	//Comax: Gas Mod
	ComaxGasMod();
	
	//Comax: Timing
	ComaxTime();
	
	//Comax: Custom Models
	ComaxModels();
	
	//Comax: Money Printers
	ComaxMoneyPrinters();
}

//Goes under OnClientDisconnect(Client)
public ComaxClientDisconnect(Client)
{
	DestroyCar(Client, 0);
	HasCar[Client] = false;
	ComaxSQL_ClientDisconnect(Client);
}

//Goes under OnClientPutInServer();
public ComaxClientPutInServer(Client)
{
	ComaxSQL_ConnectConnect(Client); //We need to call this before the client makes any connections.
	CarsClientConnect(Client);
	
	AlterUploadList(Client, 1);
	HasCar[Client] = false;
	Cars[Client] = "";
	CurrentSesionPlayingTime[Client] = 0;
//	CanAddIllegal[Client] = 0;
	UpdateStats(1, Client);
	CreateTimer(2.0, AfterSpawnTimer, Client);
	Loaded[Client] = false;
	
	CheckPlayerRestart(Client);
}	
//Goes under OnClientAuthorized();
public ComaxClientAuthorized(Client)
{

}

//Goes under public EventSpawn(Handle:Event, const String:Name[], bool:Broadcast)
public ComaxPlayerSpawn(Client)
{
	CarsPlayerSpawn(Client);
}

//Goes under OnMapEnd();
public ComaxMapEnd()
{
	CarsMapEnd();
	IZMapRunning = false;
	//We need to close the mod to end every handle that we started!
	PrintToServer("\n\n\nComax RP Mod: Reloading Mod...\n\n\n");
	new String:filename[30];
	GetPluginFilename(INVALID_HANDLE, filename, sizeof(filename));
	ServerCommand("sm plugins reload %s", filename);
}	

//Goes under OnMapStart();
public ComaxMapStart()
{
	ComaxGasModMapStart();
	IZMapRunning = true;
	LoadCars();
	RestartIntervalMax = GetConVarInt(g_restartinterval);
	//First of all load custom models:
	LoadModels(1); //Load and download.
	//Get Idstoupload
	//AlterUploadList(0, 3); // client = 0. not used anyway.
	LoadGasStations();
	CreateTimer(GSTICK, TimerTickGasStations, _, TIMER_REPEAT);
	ServerCommand("mp_forecerespawn 1");
	SetConVarInt(h_showhud, 1);
}
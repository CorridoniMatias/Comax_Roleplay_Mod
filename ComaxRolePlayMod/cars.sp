/*	Cars extension for Comax RP Mod.
*	@author	Reloaded.
*/

/*
	OnPluginStart:
	
	RegAdminCmd("sm_reloadcars", CommandReloadCars, ADMFLAG_CUSTOM5, "Reload cars list");
	RegConsoleCmd("sm_cars", CommandSpawnCar, "Spawns a car");
	RegConsoleCmd("sm_setcarindex", CommandSetEntIndex, "COMUNICATION WITH CAR PLUGIN! Recieves the ID of the car.");
	RegConsoleCmd("sm_destroycar", DestroyCarCommand, "Destroys a car");
	RegAdminCmd("sm_removecar", RemoveCarCommand, ADMFLAG_SLAY, "Destroys a car of a cliend");
	BuildPath(Path_SM, CarsPluginPath, sizeof(CarsPluginPath), "data/roleplay/Comax/CarsInfo.txt");
*/
/*
//Cars
new String:CarsPluginPath[PLATFORM_MAX_PATH];
new bool:HasCar[32];
new String:EntTnameCar[32][20];
new String:CarList[20][2][100];
new String:Cars[32][100];
new String:CarName[32][32];
*/
new Handle:h_restorearray = INVALID_HANDLE;
new clientindexes[32][2];

public ComaxCars()
{
	RegAdminCmd("sm_reloadcars", CommandReloadCars, ADMFLAG_CUSTOM5, "Reload cars list");
	RegConsoleCmd("sm_cars", CommandSpawnCar, "Spawns a car");
	RegConsoleCmd("sm_setcarindex", CommandSetEntIndex, "COMUNICATION WITH CAR PLUGIN! Recieves the ID of the car.");
	RegServerCmd("comax_client_exit_car", CommandClientExitVeh, "Runs when a client exists a vehicle.");
	RegConsoleCmd("sm_destroycar", DestroyCarCommand, "Destroys a car");
	RegAdminCmd("sm_removecar", RemoveCarCommand, ADMFLAG_SLAY, "Destroys a car of a cliend");
	BuildPath(Path_SM, CarsPluginPath, sizeof(CarsPluginPath), "data/roleplay/Comax/CarsInfo.txt");
}

public RestoreWeaponAmmo(client, weapon, ammo[3])
{
	if(ammo[0] != -1 && ammo[1] != -1)
	{
		new m_iPrimaryAmmoType	= GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"); // Weapon calibre 99MM, .50, 5.7 X 28MM, grenades, etc. etc.
		
		if(m_iPrimaryAmmoType != -1)
		{
			SetEntProp(weapon, Prop_Send, "m_iClip1", ammo[0]); // Set weapon clip ammunition
			SetEntProp(client, Prop_Send, "m_iAmmo", ammo[1], _, m_iPrimaryAmmoType); // Set player ammunition of this weapon primary ammo type
		}
	}
	if(ammo[2] == -1) return;
	
	new m_iSecondaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iSecondaryAmmoType");
	if(m_iSecondaryAmmoType != -1)
		SetEntProp(client, Prop_Send, "m_iAmmo", ammo[2], _, m_iSecondaryAmmoType);	
}

public GetWeaponAmmo(client, weapon, ammo[3])
{
	new m_iPrimaryAmmoType	= GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType"); // Weapon calibre 99MM, .50, 5.7 X 28MM, grenades, etc. etc.
	
	if(m_iPrimaryAmmoType != -1)
	{
		ammo[0] = GetEntProp(weapon, Prop_Send, "m_iClip1");
		ammo[1] = GetEntProp(client, Prop_Send, "m_iAmmo", _, m_iPrimaryAmmoType); // Player ammunition for this weapon ammo type
	} else 
	{
		ammo[0] = -1; // -2 means this weapon does not support primary ammo in general. Example: physcannon, crowbar, etc.
		ammo[1] = -1; // -2 means this weapon does not support primary ammo in general. Example: physcannon, crowbar, etc.
	}	
	
	new m_iSecondaryAmmoType = GetEntProp(weapon, Prop_Send, "m_iSecondaryAmmoType");
	
	if(m_iSecondaryAmmoType != -1)
		ammo[2] =  GetEntProp(client, Prop_Send, "m_iAmmo", _, m_iSecondaryAmmoType);
	else 
		ammo[2] = -1;
}

public FixWeapon(client) //var to store the classname of the weapon.
{
	if(h_restorearray == INVALID_HANDLE)
		h_restorearray = CreateArray(6);
	
	
	new String:wep[20];
	
	GetClientWeapon(client, wep, sizeof(wep));
	
	////PrintToConsole(client, "Using weapon %s", wep);
	
	decl weaponent, String:cname[32], ammo[3];
	ammo = {0, 0, 0};
	
	for(new a = 0; a <= 47; a++)
	{				
		weaponent = GetEntPropEnt(client, Prop_Send, "m_hMyWeapons", a);
		if( weaponent != -1 )
		{

			GetEdictClassname(weaponent, cname, sizeof(cname));
			if(StrEqual(cname, wep))
			{
				GetWeaponAmmo(client, weaponent, ammo);
				
				//PrintToConsole(client, "Matched weapon ent %d. %s - %s", weaponent, wep, cname);
				
				AcceptEntityInput(weaponent, "kill");
				break;
			}
		}
	}
	/* Restore code
	new ent = GivePlayerItem(client, wep);
	if(ent != -1)
		RestoreWeaponAmmo(ent, ammo);
	*/
	
	clientindexes[client][0] = PushArrayArray(h_restorearray, ammo);
	clientindexes[client][1] = PushArrayString(h_restorearray, wep);
	//PrintToConsole(client, "Storing array at index %d\nString array at %d", clientindexes[client][0], clientindexes[client][1]);
}


public Action:CommandClientExitVeh(args)
{
	new String:arg1[10];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	
	new client = StringToInt(arg1);
	
	//PrintToConsole(client, "Fired Client Left Vehicle. Client ID: %d", client);
	
	FixWeapon(client);

	CreateTimer(1.5, timer_giveback, client);
	
	return Plugin_Handled;
}

public Action:timer_giveback(Handle:timer, any:client)
{
	if(IsPlayerAlive(client))
	{
		//PrintToConsole(client, "Player alive");
		if(clientindexes[client][0] != -1 && clientindexes[client][1] != -1)
		{
			decl String:wep[30];
			//Get weapon.
			GetArrayString(h_restorearray, clientindexes[client][1], wep, sizeof(wep));
			RemoveFromArray(h_restorearray, clientindexes[client][1]);
			
			//PrintToConsole(client, "Found weapon name: %s", wep);
			
			//decl Float:pos[3];
			
			//GetClientAbsOrigin(client, pos);
			//new ent = GivePlayerItem(client, wep);
			//new ent = CreateEntityByName(wep);
			new ent = Client_GiveWeapon(client, wep);
			//PrintToConsole(client, "Ent: %d", ent);
			if(ent != -1)
			{
				//pos[2] += 10.0;
				//TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
				decl ammo[3];
				//Get ammo.
				GetArrayArray(h_restorearray, clientindexes[client][0], ammo);
				RemoveFromArray(h_restorearray, clientindexes[client][0]);
				
				//PrintToConsole(client, "Found ammo:\n\t[0] = %d.\n\t[1] = %d.\n\t[2] = %d.", ammo[0], ammo[1], ammo[2]);
				
				RestoreWeaponAmmo(client, ent, ammo);
			}
			
			//Reset
			clientindexes[client][0] = -1;
			clientindexes[client][1] = -1;
		} //PrintToConsole(client, "Indexes values: \n\t[0] = %d.\n\t[1] = %d.", clientindexes[client][0], clientindexes[client][1]);
	}
}


//Goes under ComaxMapEnd();
public CarsMapEnd()
{
	if(h_restorearray != INVALID_HANDLE)
		CloseHandle(h_restorearray);
}	

//Goes under ComaxClientPutInServer();
public CarsClientConnect(client)
{
	clientindexes[client][0] = -1;
	clientindexes[client][1] = -1;
}

//Goes under ComaxPlayerSpawn(Client)
public CarsPlayerSpawn(client) {}

//Goes in HudModeMain[Client] == 1 under DisplayHud(Handle:Timer, any:Client)
public CarsHud(Client)
{
	new InVehicle = GetEntPropEnt(Client, Prop_Send, "m_hVehicle");
	if(InVehicle != -1)
	{
		if(TotalGas[InVehicle] > 30)
		{
			SetHudTextParams(0.015, -1.0, HUDTICK, 0, 255, 0, 255, 0, 6.0, 0.1, 0.2);
			ShowHudText(Client, -1, "Fuel Left: %d%.", TotalGas[InVehicle]);
		} else if(TotalGas[InVehicle] > 15)
		{
			SetHudTextParams(0.015, -1.0, HUDTICK, 255, 102, 0, 255, 0, 6.0, 0.1, 0.2);
			ShowHudText(Client, -1, "Fuel Left: %d%.\nConsider going to a Gas Station.", TotalGas[InVehicle]);
		} else if(TotalGas[InVehicle] < 16 && TotalGas[InVehicle] > 0)
		{
			SetHudTextParams(0.015, -1.0, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
			ShowHudText(Client, -1, "Fuel Left: %d%.\nFuel Level Critical! Go to a Gas Station ASAP!", TotalGas[InVehicle]);
		} else if(TotalGas[InVehicle] == 0)
		{
			SetHudTextParams(0.015, -1.0, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
			ShowHudText(Client, -1, "Fuel Left: %d%.\nYou ran out of Fuel. Please type !cars in chat then press ESC and click on Emergency Gas Fill.", TotalGas[InVehicle]);
		}
	}
}

//Cars.
public Action:CommandSetEntIndex(client, args)
{
	new String:arg1[15], String:arg2[15];
	//arg1 = vehicle idnex, arg2 = client;
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	//PrintToServer("Got VehicleID '%s' length: %d", arg1, strlen(arg1));
	if(strlen(arg1) == 1)
	{
		Format(arg1, sizeof(arg1), "%s0", arg1);
		//PrintToServer("Changing VID to '%s'", arg1);
	}
	
	//new veindex = StringToInt(arg1);
	
	new clientint = StringToInt(arg2);
	
	EntTnameCar[clientint] = arg1;
	
	SetCarGas(clientint);
}

public Action:DestroyCarCommand(client, args)
{
	new String:arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	if(StrEqual(arg1, "restore"))
	{
		HasCar[client] = false;
		return Plugin_Handled;
	}
	DestroyCar(client, 1);
	return Plugin_Handled;
}

public Action: RemoveCarCommand(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[Comax] Please type the name of the client, for example: sm_removecar reloaded or !removecar reloaded. @aim Coming soon...");
		return Plugin_Handled;
	}
	
	new String:arg1[30];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	new Target = FindTarget(client, arg1, true, false);
	if(Target == -1)
	{
		ReplyToCommand(client, "[Comax] Player not found!");
		return Plugin_Handled;
	}
	new String:Name[32];
	GetClientName(Target, Name, sizeof(Name));
	ReplyToCommand(client, "[Comax] Removed %s's car.", Name);
	GetClientName(client, Name, sizeof(Name));
	PrintToChat(Target, "[Comax] Admin %s removed your car!", Name);
	DestroyCar(Target, 1);
	return Plugin_Handled;
}

public DestroyCar(client, mode)
{
	if(HasCar[client])
	{	
		new ent = FindEntityByClassname(-1, EntTnameCar[client]);
		//new InVehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
		/*
		if(InVehicle != -1 || GetEntPropEnt(ent, Prop_Send, "m_hPlayer") != -1)
		{
			new Driver = GetEntPropEnt(ent, Prop_Send, "m_hPlayer");
			SetEntProp(Driver, Prop_Send, "m_CollisionGroup", 5);
			AcceptEntityInput(Driver, "ClearParent");
			SetEntPropEnt(Driver, Prop_Send, "m_hVehicle", -1);
			
			new hud = GetEntProp(Driver, Prop_Send, "m_iHideHUD");
			hud &= ~1;
			hud &= ~256;
			hud &= ~1024;
			SetEntProp(Driver, Prop_Send, "m_iHideHUD", hud);
			
			new EntEffects = GetEntProp(Driver, Prop_Send, "m_fEffects");
			EntEffects &= ~32;
			SetEntProp(Driver, Prop_Send, "m_fEffects", EntEffects);
			
			ForcePlayerSuicide(Driver);
		}
		*/
		if(IsValidEntity(ent) && ent > 0)
		{	
			new String:steamid[32];
			GetClientAuthString(client, steamid, 32);
			
			new Handle: DB = CreateKeyValues("CarsInfo");
			FileToKeyValues(DB, CarsPluginPath);
			
			if(KvJumpToKey(DB, steamid, false))
			{
				KvSetNum(DB, CarName[client], TotalGas[ent]);
			}
			
			KvRewind(DB);
			KeyValuesToFile(DB, CarsPluginPath);
			CloseHandle(DB);
			
			//Fixes the ugly movement bug c:
			decl Driver;
			Driver = GetEntPropEnt(ent, Prop_Send, "m_hPlayer");
			if(Driver != -1)
				ServerCommand("ForceClientExitCarEqualsOne %i %d", ent, Driver); //EntTnameCar[client]
			
			//PrintToServer("Preparing Ent #%i to kill.", ent);
			
			CreateTimer(1.0, RemoveCarTimer, ent);
			
			
			if(mode == 1)
				PrintToChat(client, "\x01[\x04Comax\x01] Car destroyed with fuel level at \x04%d\x01. Type \x04!cars\x01 in chat to open your garage!", TotalGas[ent]);				
			
			HasCar[client] = false;
			
		} else {
			if(mode == 1)
				PrintToServer("[Comax] Car with index %d cannot be killed", ent);
		}
	} else {
		if(mode == 1)
			PrintToChat(client, "\x01[\x04Comax\x01] You don't have a car! Type \x04!cars\x01 in \x04chat\x01 to open your garage.");
	}
}

public Action:RemoveCarTimer(Handle:timer, any:car)
{	
	decl Driver;
	Driver = GetEntPropEnt(car, Prop_Send, "m_hPlayer");
	if(Driver != -1)
	{
		decl String:name[32];
		GetClientName(Driver, name, sizeof(name));
		ServerCommand("sm_slay \"%s\"", name);
		//ForcePlayerSuicide(Driver); //If for some reason the player didnt exit the car just kill him.
	}
	
	AcceptEntityInput(car, "kill");
}

public CarSelectMenu(Handle:menuhandle, MenuAction:action, Client, Pos)
{
	if(action == MenuAction_Select)
	{
		decl String:ItemMM[20];
		GetMenuItem(menuhandle, Pos, ItemMM, sizeof(ItemMM));
		
		if(HasCar[Client])
		{
			if(StrEqual(ItemMM, "loadgas50"))
			{
				new Ent = FindEntityByClassname(-1, EntTnameCar[Client]);
				ServerCommand("setcanturnonforcarcomaxroleplay %d 1", StringToInt(EntTnameCar[Client]));
				TotalGas[Ent] += 50;
				Money[Client] -= 300;
				PrintToChat(Client, "\x01[\x04Comax\x01] Added \x0450%\x01 of Gas to your car. Cost: \x04$300\x01.");
				return;
			}
			
			if(StrEqual(ItemMM, "destroy"))
			{
				DestroyCar(Client, 1);
				return;
			}
			
			if(StrEqual(ItemMM, "lock"))
			{
				new Ent = FindEntityByClassname(-1, EntTnameCar[Client]);
				if(Ent != -1)
				{
					SetEntProp(Ent, Prop_Data, "m_bLocked", 1, 1);		
					SetEntityRenderColor(Ent, 255, 0, 0, 255);
					PrintToChat(Client, "\x01[\x04Comax\x01] Car locked. Type \x04!cars\x01 in \x04chat\x01 to unlock it!");
				} else {
					PrintToServer("[Comax] Reporting: Failed at locking car with ID of %s, ENT: %d", EntTnameCar[Client], Ent);
				}
				//SetEntProp(ent, type, prop, val, size)
				return;
			}
			
			if(StrEqual(ItemMM, "unlock"))
			{
				new Ent = FindEntityByClassname(-1, EntTnameCar[Client]);
				if(Ent != -1)
				{
					SetEntProp(Ent, Prop_Data, "m_bLocked", 0, 1);
					SetEntityRenderColor(Ent, 255, 255, 255, 255);
					PrintToChat(Client, "\x01[\x04Comax\x01] Car unlocked. Type \x04!cars\x01 in \x04chat\x01 to lock it!");
				} else {
					PrintToServer("[Comax] Reporting: Failed at unlocking car with ID of %s, ENT: %d", EntTnameCar[Client], Ent);
				}
				//SetEntProp(ent, type, prop, val, size)
				return;
			}
			return;
		}
		
		if(StrEqual(ItemMM, "apc"))
		{
			if(IsCombine(Client))
			{
				SetEntProp(Client, Prop_Data, "m_takedamage", 0, 1);
				ServerCommand("vehiclemod_spawnatuserid %d %s", GetClientUserId(Client), ItemMM);
				CreateTimer(1.0, TeleTimerCar, Client);
				CarName[Client] = ItemMM;
				PrintToChat(Client, "\x01[\x04Comax\x01] Your car, %s, is ready!", ItemMM);
				HasCar[Client] = true;
			}
			return;
		}
		
		//PrintToServer("Item: %s and cars for client '%s'", ItemMM, Cars[Client]);
		if(StrContains(Cars[Client], ItemMM, false) != -1)
		{	
			if(Minutes[Client] >= 90)
			{	if(!HasCar[Client])
				{
					
					//ServerCommand("vehiclemod_spawnatcoordscomax %f %f %f 0 subaru %d", Origin[0] + 5, Origin[1] + 20, Origin[2] + 0.5, client);
					//Usage vehiclemod_spawnatuserid <userid> <vehicle name> <skin>[optional])
					SetEntProp(Client, Prop_Data, "m_takedamage", 0, 1);
					ServerCommand("vehiclemod_spawnatuserid %d %s", GetClientUserId(Client), ItemMM);
					CreateTimer(1.0, TeleTimerCar, Client);
					PrintToChat(Client, "\x01[\x04Comax\x01] Your car, %s, is ready!", ItemMM);
					
					CarName[Client] = ItemMM;
					
					OldTime[Client] = RoundToFloor(GetGameTime());
					
					HasCar[Client] = true;
				} else {
					PrintToChat(Client, "\x01[\x04Comax\x01] You already have a car! Type \x04!destroycar\x01 to remove it."); 
				}
			} else {
				PrintToChat(Client, "\x01[\x04Comax\x01] You haven't spent enough time on the server, to see how much you've played type \x04!stats\x01 or \x04/stats\x01 in the \x04chat\x01. You need\x04 1 hour and 30 minutes\x01 to get a \x04car\x01.");
			}
		} else {
			PrintToServer("Client %d is buying a new Car!", Client);
			for(new i = 0;i<20;i++)
			{
				if(StrEqual(ItemMM, CarList[i][0]))
				{
					//PrintToServer("F1");
					decl value;
					value = StringToInt(CarList[i][1]);
					if(Money[Client] >= value)
					{
						//PrintToServer("F2");
						new String:SID[32];
						GetClientAuthString(Client, SID, 32);
						
						new Handle:DB = CreateKeyValues("CarsInfo");
						FileToKeyValues(DB, CarsPluginPath);
						//PrintToServer("F3");
						if(KvJumpToKey(DB, SID, true))
						{	
							//PrintToServer("F4");
							decl String:kvnoprocess[100];
							KvGetString(DB, "Cars", kvnoprocess, sizeof(kvnoprocess));
							if(StrEqual(kvnoprocess, ""))
							{
								Format(kvnoprocess, sizeof(kvnoprocess), "%s", CarList[i][0]);
							} else {
								Format(kvnoprocess, sizeof(kvnoprocess), "%s^^%s", kvnoprocess, CarList[i][0]);
							}
							//PrintToServer("F5 %s", kvnoprocess);
							KvSetString(DB, "Cars", kvnoprocess);
							
							PrintToServer("Updating client %d cars... Going from %s to %s", Client, Cars[Client], kvnoprocess);
							Format(Cars[Client], 100, kvnoprocess);
							//PrintToServer("F6 %s", kvnoprocess);
							Money[Client] -= value;
						}
						//PrintToServer("F7");
						
						PrintToChat(Client, "\x01[\x04Comax\x01] You've just bought \x04%s\x01 for \x04$%s\x01! Exclusive Car System only at Comax Servers!", CarList[i][0], CarList[i][1]);
						//Spawn Car:
						SetEntProp(Client, Prop_Data, "m_takedamage", 0, 1);
						ServerCommand("vehiclemod_spawnatuserid %d %s", GetClientUserId(Client), ItemMM);
						CreateTimer(1.0, TeleTimerCar, Client);
						PrintToChat(Client, "\x01[\x04Comax\x01] Your car, %s, is ready!", ItemMM);
						
						CarName[Client] = ItemMM;
						
						HasCar[Client] = true;
						//End of Spawn Car.
						KvRewind(DB);
						KeyValuesToFile(DB, CarsPluginPath);
						//PrintToServer("F8");
						CloseHandle(DB);
					} else {
						PrintToChat(Client, "\x01[\x04Comax\x01] You can't afford a \x04%s\x01 its value is \x04$%s\x01", CarList[i][0], CarList[i][1]);
					}
					break;
				}
			}
		}
		
		
	} else if(action == MenuAction_End)
	{
		if(menuhandle)
			CloseHandle(menuhandle);
	}
}


public Action:CommandSpawnCar(client, args)
{
	/*
	if(args < 1)
	{
	ReplyToCommand(client, "[Comax] It is sad to announce that Cars have broke since the last Game Update. We are working on this already. If you know the Admin Arg please type it.");
	return Plugin_Handled;
	}
	
	new String:arg1[32];
	GetCmdArg(1, arg1, 32);
	
	if(!StrEqual(arg1, "adminspawn"))
	{
	ReplyToCommand(client, "[Comax] It is sad to announce that Cars have broke since the last Game Update. We are working on this already. If you know the Admin Arg please type it.");
	return Plugin_Handled;
	}
	*/
	
	
	if(IsCuffed[client])
	{
		PrintToChat(client, "\x01[\x04Comax\x01] You cannot spawn a car while cuffed!");
		return Plugin_Handled;
	}
	
	if(Crime[client] >= 1000)
	{
		PrintToChat(client, "\x01[\x04Comax\x01] Your crime level is too high! Please try again later. Crime: %d", Crime[client]);
		return Plugin_Handled;
	}
	
	new Ent = FindEntityByClassname(-1, EntTnameCar[client]);
	if(Ent == -1)
	{
		HasCar[client] = false;
	}
	
	if(HasCar[client])
	{
		new Handle:menuhandle = CreateMenu(CarSelectMenu);
		SetMenuTitle(menuhandle, "Car options.\nComax Servers.\nBy Reloaded.");
		//new Ent = FindEntityByClassname(-1, EntTnameCar[client]);
		
		
		if(TotalGas[Ent] < 50)
		{
			AddMenuItem(menuhandle, "loadgas50", "Emergency Gas Fill-*");
		}
		
		if(Ent != -1)
		{
			if(!(GetEntProp(Ent, Prop_Data, "m_bLocked")))
			{
				AddMenuItem(menuhandle, "lock", "Lock car");
			} else {
				AddMenuItem(menuhandle, "unlock", "Unlock car");
			}
		} else {
			PrintToServer("[Comax] Reporting: Failed at adding car lock state with ID of %s, ENT: %d", EntTnameCar[client], Ent);
		}
		AddMenuItem(menuhandle, "destroy", "Destroy car");
		SetMenuPagination(menuhandle, 7);
		DisplayMenu(menuhandle, client, 260);
		return Plugin_Handled;
	}
	
	new Handle:menuhandle = CreateMenu(CarSelectMenu);
	SetMenuTitle(menuhandle, "Select a car:\nComax Servers.\nBy Reloaded.\nOwned means you\nalready own the car.");
	
	//PrintToServer("Reading from Var: %s", Cars[client]);
	if(StrEqual(Cars[client], "") || StrEqual(Cars[client], "^^"))
	{
		//if the Cars[client] var is empty or only the separator is in it then reload the cars for that client.
		GetClientCars(client);
	}
	
	if(IsCombine(client))
	{
		AddMenuItem(menuhandle, "apc", "APC - Cops");
	}
	
	for(new o = 0;o<20;o++)
	{
		if(!StrEqual(CarList[o][0], ""))
		{
			decl String:Showtxt[30];
			//decl String:Showtxtex[30];
			if(StrContains(Cars[client], CarList[o][0], false) != -1)
			{
				Format(Showtxt, sizeof(Showtxt), "%s - Owned", CarList[o][0]);
				//Format(Showtxtex, sizeof(Showtxtex), "%s^Spawn", CarList[o][0]);
				AddMenuItem(menuhandle, CarList[o][0], Showtxt);
			} else {
				
				Format(Showtxt, sizeof(Showtxt), "%s. Price: $%s", CarList[o][0], CarList[o][1]);
				//Format(Showtxtex, sizeof(Showtxtex), "%d^Buy", o);
				AddMenuItem(menuhandle, CarList[o][0], Showtxt);
			}
		}
	}
	
	SetMenuPagination(menuhandle, 7);
	SetMenuExitButton(menuhandle, true);
	
	DisplayMenu(menuhandle, client, 260);
	
	return Plugin_Handled;
	
	////OLD BASE////
	/*
	if(args < 1)
	{
	PrintToChat(client, "\x01[\x04Comax\x01] Please enter a car model!");
	return Plugin_Handled;
	}
	
	new String:arg1[50], String:Error[100];
	GetCmdArg(1, arg1, sizeof(arg1));
	if(StrEqual(arg1, "apc") && !IsCombine(client))
	{
	PrintToChat(client, "\x01[\x04Comax\x01] APCs are restricted to \x04combines only\x01!");
	return Plugin_Handled;
	}
	
	for(new i = 0;i<sizeof(CarList);i++)
	{
	if(StrEqual(arg1, CarList[i]) || HasCar[client])
	{
	if(Minutes[client] >= 1440 + 720)
	{	if(!HasCar[client])
	{
	
	//ServerCommand("vehiclemod_spawnatcoordscomax %f %f %f 0 subaru %d", Origin[0] + 5, Origin[1] + 20, Origin[2] + 0.5, client);
	//Usage vehiclemod_spawnatuserid <userid> <vehicle name> <skin>[optional])
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	ServerCommand("vehiclemod_spawnatuserid %d %s", GetClientUserId(client), arg1);
	CreateTimer(1.0, TeleTimerCar, client);
	PrintToChat(client, "\x01[\x04Comax\x01] Your car, %s, is ready!", arg1);
	HasCar[client] = true;
	break;
	} else {
	PrintToChat(client, "\x01[\x04Comax\x01] You already have a car! Type \x04!destroycar\x01 to remove it."); 
	break;
	}
	} else {
	PrintToChat(client, "\x04[\x04Comax\x01] You did not spend enough time on the server, to see how much you played type \x04!stats\x01 or \x04/stats\x01 in the \x04chat\x01. You need\x04 1 day and 12 hours\x01 to get a \x04free\x01 car.");
	break;
	}
	} else {
	if(StrEqual(Error, ""))
	{
	Format(Error, sizeof(Error), "%s", CarList[i]);
	} else {
	Format(Error, sizeof(Error), "%s, %s", Error, CarList[i]);
	}
	}
	}
	
	if(!HasCar[client])
	{
	PrintToChat(client, "\x01[\x04Comax\x01] Thats not a valid car! Valid Cars: \x04%s\x01.", Error);
	}
	*/
	
}

public Action:CommandReloadCars(client, args)
{
	new String:Name[32];
	GetClientName(client, Name, 32);
	
	ReplyToCommand(client, "[Comax] Loading from file... Resetting players' cars...");
	PrintToServer("Admin %s reloaded cars.", Name);
	
	for(new i = 1;i<GetMaxClients();i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			Cars[i] = "";
		}
	}
	LoadCars();
	
	return Plugin_Handled;
}

public GetClientCars(client)
{
	new Handle:DB = CreateKeyValues("CarsInfo");
	FileToKeyValues(DB, CarsPluginPath);
	
	new String:SteamID[30];
	
	decl String:kvnoprocess[99];
	
	//decl String:Bufferex[30][99];
	
	GetClientAuthString(client, SteamID, sizeof(SteamID));
	
	
	if(KvJumpToKey(DB, SteamID, true))
	{
		
		KvGetString(DB, "Cars", kvnoprocess, sizeof(kvnoprocess));
		
		Format(Cars[client], 100, "%s", kvnoprocess);
		
		PrintToServer("Got from KV %s added to cars %s", kvnoprocess, Cars[client]);
		
		//ExplodeString(kvnoprocess, "^^", Bufferex, 20, 99);
	}
	
	KvRewind(DB);
	CloseHandle(DB);
}


public LoadCars()
{
	new Handle:DB = CreateKeyValues("CarsInfo");
	FileToKeyValues(DB, CarsPluginPath);
	
	decl String:kvnoprocess[99];
	
	if(KvJumpToKey(DB, "CarList", false))
	{
		
		decl String:Stringval[3];
		
		decl String:Buffer[2][99];
		
		PrintToServer("Comax: Getting CarList.");
		for(new i = 0;i<20;i++)
		{
			Format(CarList[i][0], 100 , "");
			Format(CarList[i][1], 100 , "");
			//static String:CarList[100][2][100];
			
			Format(Stringval, sizeof(Stringval), "%d", i);
			KvGetString(DB, Stringval, kvnoprocess, sizeof(kvnoprocess));
			if(!StrEqual(kvnoprocess, ""))
			{
				ExplodeString(kvnoprocess, "^^", Buffer, 2,99);
				CarList[i][0] = Buffer[0]; // Name is set here
				CarList[i][1] = Buffer[1]; // Price is set here
				PrintToServer("Comax: Adding car %s (%s) with price %s (%s). ID: %d", CarList[i][0], Buffer[0], CarList[i][1], Buffer[1], i);
			}
		}
	} else {
		PrintToServer("Comax: CarList was not found or is corrupt!");
		return;
	}
	
	KvRewind(DB);
	CloseHandle(DB);
}

public Action:TeleTimerCar(Handle:timer, any:client)
{	
	new Float:Origin[3];
	GetClientAbsOrigin(client, Origin);
	Origin[2] += 100;
	TeleportEntity(client, Origin, NULL_VECTOR, NULL_VECTOR);
	
	if(!StrEqual(Job[client], "Root Admin"))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2);
	}
}
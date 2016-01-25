/*	Gas Station extension for Comax RP Mod.
*	@note You need cars extension.
*
*	@author	Reloaded.
*/


/*
	OnPluginStart:
	
	RegAdminCmd("sm_setgasstation", CommandAddGasStation, ADMFLAG_ROOT, "Adds a gas station place");
	RegAdminCmd("sm_removegasstation", CommandRemoveGasStation, ADMFLAG_ROOT, "Adds a gas station place");
	g_gassationrange = CreateConVar("sm_gasstationrange", "400.0", "Range in wich the gas is going to be loaded into the car.", FCVAR_PLUGIN);
*/
/*
new Float:GasStation[10][3];
new Float:GSTICK = 0.5;
new GasPrice = 3;
new Handle:g_gassationrange = INVALID_HANDLE; 
new GasClient[32];
new TotalGas[5000];
new OldTime[32];
*/

//Some vars for this files are in vars.sp

new String:stationspath[PLATFORM_MAX_PATH];

public ComaxGasMod()
{
	RegAdminCmd("sm_setgasstation", CommandAddGasStation, ADMFLAG_ROOT, "Adds a gas station place");
	RegAdminCmd("sm_removegasstation", CommandRemoveGasStation, ADMFLAG_ROOT, "Adds a gas station place");
	g_gassationrange = CreateConVar("sm_gasstationrange", "400.0", "Range in wich the gas is going to be loaded into the car.", FCVAR_PLUGIN);
}

//Goes under ComaxOnMapStart();
public ComaxGasModMapStart()
{
	decl String:curmap[50], String:temp[PLATFORM_MAX_PATH];
	GetCurrentMap(curmap, sizeof(curmap));
	Format(temp, sizeof(temp), "addons/sourcemod/data/roleplay/Comax/%s", curmap);
	CreateDirectory(temp, 511);
	BuildPath(Path_SM, stationspath, sizeof(stationspath), "/data/roleplay/Comax/%s/GasStations.txt", curmap);
}

public Action:CommandAddGasStation(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[Comax] Enter a Gas Station Number (0 - 9)");
		return Plugin_Handled;
	}
	
	new String:arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	new arg1i = StringToInt(arg1);
	
	if(arg1i > 9 || arg1i < 0)
	{
		ReplyToCommand(client, "[Comax] Please make sure you didn't type a number bigger than 9 or smaller than 0! Number entered: %d", arg1i);
		return Plugin_Handled;
	}
	
	new Handle: DB = CreateKeyValues("GasStations");
	FileToKeyValues(DB, stationspath);
	if(KvJumpToKey(DB, "GasStations", true))
	{
		new String:GS[100];
		KvGetString(DB, arg1, GS, 100, "NULLP");
		
		new Float:origin[3];
		GetClientAbsOrigin(client, origin);
		
		if(StrEqual(GS, "NULLP"))
		{
			Format(GS, 100, "%f %f %f", origin[0], origin[1], origin[2]);
			KvSetString(DB, arg1, GS);
			
			GasStation[arg1i][0] = origin[0];
			GasStation[arg1i][1] = origin[1];
			GasStation[arg1i][2] = origin[2];
			
			ReplyToCommand(client, "[Comax] Creating Gas Station %d(%s) at:\nOrigin:%f %f %f\nGS: %s\nGasStation[%d]: %f %f %f.", 
			arg1i, arg1, origin[0], origin[1], origin[2], GS, arg1i, GasStation[arg1i][0], GasStation[arg1i][1], GasStation[arg1i][2]);
		} else {
			ReplyToCommand(client, "[Comax] Found Gas Station %d at %f %f %f.", arg1i, GasStation[arg1i][0], GasStation[arg1i][1], GasStation[arg1i][2]);
			
			Format(GS, 100, "%f %f %f", origin[0], origin[1], origin[2]);
			
			GasStation[arg1i][0] = origin[0];
			GasStation[arg1i][1] = origin[1];
			GasStation[arg1i][2] = origin[2];
			
			KvSetString(DB, arg1, GS);
			ReplyToCommand(client, "[Comax] Changing Gas Station %d(%s) at:\nOrigin:%f %f %f\nGS: %s\nGasStation[%d]: %f %f %f.", 
			arg1i, arg1, origin[0], origin[1], origin[2], GS, arg1i, GasStation[arg1i][0], GasStation[arg1i][1], GasStation[arg1i][2]);
		}
	} else {
		ReplyToCommand(client, "[Comax] Cannot create/find Key.");
	}	
	
	KvRewind(DB);
	KeyValuesToFile(DB, stationspath);
	CloseHandle(DB);
	
	return Plugin_Handled;
}

public Action:TimerTickGasStations(Handle:timer) 
{
	decl Float:CarOrigin[3];
	
	for(new i = 1;i<GetMaxClients();i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			new InVehicle = GetEntPropEnt(i, Prop_Send, "m_hVehicle");
			if(InVehicle != -1)
			{
				//new Car = FindEntityByClassname(-1, EntTnameCar[i]);
				//			new InVehicle = GetEntPropEnt(i, Prop_Send, "m_hVehicle");
				
				//GetClientAbsOrigin(i, CarOrigin);
				GetEntPropVector(InVehicle, Prop_Send, "m_vecOrigin", CarOrigin);
				decl Float:Dist[11];
				for(new Y = 0;Y < 10;Y++)
				{
					Dist[Y] = GetVectorDistance(CarOrigin, GasStation[Y]);
					TE_SetupBeamRingPoint(GasStation[Y], 1.0, GetConVarFloat(g_gassationrange), g_BeamSprite, g_BeamSprite, 1, 5, 8.0, 4.0, 1.0, {0, 255, 0, 255}, 300, 0);
					TE_SendToClient(i, 0.1);
					SetHudTextParams(0.8, -1.0, 0.87, 0, 255, 0, 255, 0);
					
					
					if(Dist[Y] <= GetConVarFloat(g_gassationrange) && InVehicle != -1)
					{
						if(TotalGas[InVehicle] < 100)
						{
							if(Money[i] > GasPrice)
							{
								if(IsCombine(i) && StrEqual(CarName[i], "apc")) {} else
								Money[i] -= GasPrice;
								
								TotalGas[InVehicle]++;
								GasClient[i] += GasPrice;
								
								if(TotalGas[InVehicle] > 0)
								{
									ServerCommand("setcanturnonforcarcomaxroleplay %d 1", InVehicle);
								}
								
								if(IsCombine(i) && StrEqual(CarName[i], "apc"))
									ShowHudText(i, -1, "Comax Gas Station\nTotal Cost: $%d.\nGas in car: %d.\nFilling the tank...\nYour expenses are covered by Comax. You're a Cop.", GasClient[i], TotalGas[InVehicle]);
								else
								ShowHudText(i, -1, "Comax Gas Station\nTotal Cost: $%d.\nGas in car: %d.\nFilling the tank...", GasClient[i], TotalGas[InVehicle]);
								
							} else {
								ShowHudText(i, -1, "Comax Gas Station\nTotal Cost: %d.\nGas in car: %d.\nInsufficient funds. Price $%d.00.", GasClient[i], TotalGas[InVehicle], GasPrice);
							}
						} else {
							ShowHudText(i, -1, "Comax Gas Station\nTotal Cost: %d.\nGas in car: %d.\nThe tank is full.", GasClient[i], TotalGas[InVehicle]);
						}
						break;
					} else if(Dist[Y] > GetConVarFloat(g_gassationrange) && InVehicle != -1) {
						
						if(TotalGas[InVehicle] == 0)
						{
							ServerCommand("setcanturnonforcarcomaxroleplay %d 0", InVehicle);
							AcceptEntityInput(InVehicle, "TurnOff");
							SetEntProp(InVehicle, Prop_Data, "m_nSpeed", 0);
						}
						
						if(TotalGas[InVehicle] > 0 && GetGameTime() - OldTime[i] > 5) // tick every 5 seconds.
						{
							OldTime[i] = RoundToFloor(GetGameTime());
							TotalGas[InVehicle]--;
						}
					}
				}
			}
		}	
	}
}

public Action: CommandRemoveGasStation(client, args) 
{
	if(args < 1)
	{
		ReplyToCommand(client, "[Comax] Enter a Gas Station Number (0 - 9)");
		return Plugin_Handled;
	}
	
	new String:arg1[32];
	GetCmdArg(1, arg1, sizeof(arg1));
	
	new arg1i = StringToInt(arg1);
	
	if(arg1i > 9 || arg1i < 0)
	{
		ReplyToCommand(client, "[Comax] Please make sure you didn't type a number bigger than 9 or smaller than 0! Number entered: %d", arg1i);
		return Plugin_Handled;
	}
	
	new Handle: DB = CreateKeyValues("GasStations");
	FileToKeyValues(DB, stationspath);
	if(KvJumpToKey(DB, "GasStations", false))
	{
		new String:GS[100];
		KvGetString(DB, arg1, GS, 100, "NULLP");
		
		if(KvDeleteKey(DB, arg1))
		{
			ReplyToCommand(client, "[Comax] Gas Station %s removed.", arg1);
			
			GasStation[StringToInt(arg1)][0] = -100000.00;
			GasStation[StringToInt(arg1)][1] = -100000.00;
			GasStation[StringToInt(arg1)][2] = -100000.00;
		}
	} else {
		ReplyToCommand(client, "[Comax] Cannot create/find Key.");
	}	
	
	KvRewind(DB);
	KeyValuesToFile(DB, stationspath);
	CloseHandle(DB);
	
	return Plugin_Handled;
}

public LoadGasStations() {
	
	PrintToServer("[Comax] Loading Gas Stations...");
	
	new Handle: DB = CreateKeyValues("GasStations");
	FileToKeyValues(DB, stationspath);
	if(KvJumpToKey(DB, "GasStations", false))
	{
		new String:GS[100], String:arg1[3], String:buffer[3][50];
		
		for(new i = 0;i < 10;i++)
		{
			Format(arg1, sizeof(arg1), "%d", i);
			
			KvGetString(DB, arg1, GS, 100, "NULLP");
			ExplodeString(GS, " ", buffer, 3, 50);
			
			if(!StrEqual(GS, "NULLP"))
			{
				GasStation[i][0] = StringToFloat(buffer[0]);
				GasStation[i][1] = StringToFloat(buffer[1]);
				GasStation[i][2] = StringToFloat(buffer[2]);
				
				PrintToServer("[Comax] Creating Gas Station %d at:\nBuffer: %f %f %f\nGasStation: %f %f %f",
				i, StringToFloat(buffer[0]), StringToFloat(buffer[1]), StringToFloat(buffer[2]), GasStation[i][0], GasStation[i][1], GasStation[i][2]);
			} else {
				GasStation[i][0] = -100000.0;
				GasStation[i][1] = -100000.0;
				GasStation[i][2] = -100000.0;
			}
		}
	} else {
		PrintToServer("[Comax] No valid Gas Stations were found. Please use sm_setgasstation to set them up.");
	}	
	
	KvRewind(DB);
	KeyValuesToFile(DB, stationspath);
	CloseHandle(DB);
}

public SetCarGas(client)
{
	new Handle: DB = CreateKeyValues("CarsInfo");
	FileToKeyValues(DB, CarsPluginPath);
	
	new String:steamid[32];
	GetClientAuthString(client, steamid, 32);
	
	if(KvJumpToKey(DB, steamid, false))
	{
		TotalGas[StringToInt(EntTnameCar[client])] = KvGetNum(DB, CarName[client]);
		
		if(TotalGas[StringToInt(EntTnameCar[client])] > 0)
		{
			ServerCommand("setcanturnonforcarcomaxroleplay %d 1", StringToInt(EntTnameCar[client]));
		} else {
			ServerCommand("setcanturnonforcarcomaxroleplay %d 0", StringToInt(EntTnameCar[client]));
		}
	}
	
	KvRewind(DB);
	KeyValuesToFile(DB, CarsPluginPath);
	CloseHandle(DB);
}
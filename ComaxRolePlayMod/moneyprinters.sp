/*	Money Printers extension for Comax RP Mod.
*	@author	Reloaded.
*	@note Contains stuff from ROFLCopter Mod.
*/

//Model to Precache: PrecacheModel("models/props_lab/reciever01a.mdl", true);

new Float:Printer[33][10][3];
new PrinterWorth[33][10];
new PrinterEnt[33][10];
new Handle:cv_printer_max = INVALID_HANDLE;

public ComaxMoneyPrinters()
{
	RegConsoleCmd("sm_createprinter", CommandCreatePrinter, "Creates a printer");
	RegConsoleCmd("sm_destroyprinter", CommandDestroyPrinter, "destroys a printer");
	RegAdminCmd("sm_printerinfo", Command_PrinterInfo, ADMFLAG_CUSTOM4, "Prints printer info");
	RegAdminCmd("sm_gotoprinter", Command_GotoPrinter, ADMFLAG_CUSTOM4, "Teleports client to printer");
	RegAdminCmd("sm_setprinterworth", CommandSetPrinterWorth, ADMFLAG_ROOT, "Sets a printer worth");
	RegConsoleCmd("sm_printerhelp", Command_PrinterHelp);
}

//Goes under for(new T = 0; T <= 32; T++) in CommandUse(Client) after drug plants.
//Note if return == true you should return Plugin_Handled!
public bool:MoneyPrinterUse(Client, T, Float:TeleClient[3])
{
	for(new R = 0; R < 2; R++)
	{		
		if(Printer[T][R][0] != 0.0)
		{
			decl Float:PrinterDist;
			PrinterDist = GetVectorDistance(Printer[T][R], TeleClient);
			if(PrinterDist < 50 && Printer[T][R][0] != 0.0)
			{
				decl RandSpark;
				RandSpark = GetRandomInt(1, 100);
				if(RandSpark < 31)
				{
				// Printer has 30% chance to explode //
					
					PrintToChat(Client, "\x04[Comax]\x01 Your printer got hot and exploded!");
					CreateMoneyBoxes(T, PrinterWorth[T][R]);
					DestroyPrinter(T, R);
					return true;						
				} else
				if(Client == T)
				{
					CPrintToChat(Client, "{white}|RP-Printer| -{grey}  You collected $%d from the printer!", PrinterWorth[T][R]);
					Money[Client] += PrinterWorth[T][R];
					PrinterWorth[T][R] = 0;
					return true;
				}
				else
				{
					if(!IsCombine(Client) && !IsFirefighter(Client))
					{
						CPrintToChat(T, "{white}|RP-Printer| -{grey}  A player has stolen money from your printer!");
						CPrintToChat(Client, "{white}|RP| -{grey} You've collected $%d from the printer!", PrinterWorth[T][R]);
						Money[Client] += PrinterWorth[T][R];
						DestroyPrinter(T, R);
						AddCrime(Client, 200);
						return true;
					}
					else if(IsCombine(Client) && !IsFirefighter(Client))
					{
						DestroyPrinter(T, R);
						CPrintToChat(T, "{white}|RP-Printer| -{grey}  A cop has destroyed your printer!");
						CPrintToChat(Client, "{white}|RP| -{grey} You have received $100 for destroying a printer.");
						Money[Client] += 100;
						return true;
					}
				}
			}
		}
	}
	return false;
}

public DestroyPrinter(Client, PrinterNumber)
{
	Printer[Client][PrinterNumber][0] = 0.0;
	PrinterWorth[Client][PrinterNumber] = 0;
	decl String:CheckPrinter[64];
	GetEntPropString(PrinterEnt[Client][PrinterNumber], Prop_Data, "m_ModelName", CheckPrinter, 64);
	if(StrEqual(CheckPrinter, "models/props_lab/reciever01a.mdl", false))
	{
		AcceptEntityInput(PrinterEnt[Client][PrinterNumber], "kill");
	}
	PrinterEnt[Client][PrinterNumber] = 0;
}

//Goes after "Drug Addict Plants Loop" in DisplayHud(Handle:Timer, any:Client).
public PrinterHUD(Client, X, Float:ClientOrigin[3])
{
	decl Float:Distz;
	for(new Z = 0; Z < 2; Z++)
	{
		//X = 32 possible players
		//D = 5 possible plants
		//XOrigins = Player Origin
		//Looping through all players in this loop to see other drug origins!
		
		if(Printer[X][Z][0] != 0.0)
		{
			Distz = GetVectorDistance(Printer[X][Z], ClientOrigin);
			if(Distz < 50 && Printer[X][Z][0] != 0.0)
			{
				if(Client == X)
				{
					PrintCenterText(Client, "Printer ($%d) Press E to take the money!", PrinterWorth[X][Z]);
				}
				else
				{
					decl String:Steal[64];
					GetClientName(X, Steal, sizeof(Steal));
					if(!IsCombine(Client))
					{
						PrintCenterText(Client, "%s's Money Printer ($%d) Press E to take the money!", Steal, PrinterWorth[X][Z]);
					}
					else if(IsCombine(Client) || IsFirefighter(Client))
					{
						PrintCenterText(Client, "%s's Money Printer ($%d) Press E to take the money!", Steal, PrinterWorth[X][Z]);
					}
				}
			}
			
			decl Randq;
			Randq = GetRandomInt(1, 100);
			if(Randq > 94 && PrinterWorth[X][Z] <= GetConVarInt(cv_printer_max))
			{
				PrinterWorth[X][Z] += 5;
			}
			
		}					
	}
}

// -MUST- Call this in DynamicJobsRefresh(Client).
public PrinterRefresh(Client)
{
	decl String:CheckPrinter[64];
	for(new X = 0; X < 2; X++)
	{
		Printer[Client][X][0] = 0.0;
		PrinterWorth[Client][X] = 0;
		GetEntPropString(PrinterEnt[Client][X], Prop_Data, "m_ModelName", CheckPrinter, 64);
		
		if(StrEqual(CheckPrinter, "models/props_lab/reciever01a.mdl", false))
		{
			AcceptEntityInput(PrinterEnt[Client][X], "kill");
		}
		PrinterEnt[Client][X] = 0;
	}
}


public Action:Command_GotoPrinter(client, args) 
{
	new Float:TeleportOrigin[3];
	for(new X = 1; X < 2; X++)
	{
		if(Printer[client][X][0] == 0.0)
		{
			PrintToChat(client, "\x04[RP-Printer]\x01 You don't have a printer, type \x04sm_createprinter\x01 in \x04console\x01 to create one or \x04!createprinter\x01 in chat. Cost $400.");
		} else if(X == 1) {
			if(Crime[client] == 0 && !IsCuffed[client]) {
				//Math
				TeleportOrigin[0] = Printer[client][X][0];
				TeleportOrigin[1] = Printer[client][X][1];
				TeleportOrigin[2] = (Printer[client][X][2] + 5);
				
				//Teleport
				TeleportEntity(client, TeleportOrigin, NULL_VECTOR, NULL_VECTOR);
				
				PrintToChat(client, "\x04[RP-Printer]\x01 You have been teleported where your printer is!");
			} else {
				PrintToChat(client, "\x04[RP-Printer]\x01 Either your crime level is too high, or you're cuffed. Crime level: %d.", Crime[client]);
			}
		}
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:CommandDestroyPrinter(client, args)
{
	for(new X = 1; X < 2; X++)
	{
		if(Printer[client][X][0] == 0.0)
		{
			PrintToChat(client, "\x04[RP-Printer]\x01 You don't have a printer, type \x04sm_createprinter\x01 in \x04console\x01 to create one or \x04!createprinter\x01 in chat. Cost $500.");
		} else if(X > 0) {
			CreateMoneyBoxes(client, PrinterWorth[client][X]);
			PrintToChat(client, "\x04[RP-Printer]\x01 Printer destroyed. You lost: $%d", PrinterWorth[client][X]);
			DestroyPrinter(client, X);
		}
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:CommandSetPrinterWorth(client, args)
{
	for(new X = 1; X < 2; X++)
	{
		if(Printer[client][X][0] == 0.0)
		{
			PrintToChat(client, "\x04[RP-Printer]\x01 You don't have a printer, type \x04sm_createprinter\x01 in \x04console\x01 to create one or \x04!createprinter\x01 in chat. Cost $500.");
		} else if(X > 0) {
			new String:arg1[32];
			GetCmdArg(1, arg1, sizeof(arg1));
			new arg1toint = StringToInt(arg1);
			PrinterWorth[client][X] = arg1toint;
			PrintToChat(client, "\x04[RP-Printer]\x01 Setting worth to: $%d (%d)", arg1toint, PrinterWorth[client][X]);
		}
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:Command_PrinterHelp(client, args) 
{
	PrintToChat(client, "\x01[RP] About Printers:");
	PrintToChat(client, "\x01[RP] Printers print \x04$10\x01 every \x041 minute\x01.");
	PrintToChat(client, "\x01[RP] Commands: console command (chat command)");
	PrintToChat(client, "\x01[RP] sm_createprinter (!createprinter) - Creates a printer. NOTE: Creating a printer WILL cost you \x04$200\x01!");
	PrintToChat(client, "\x01[RP] sm_printerinfo (!printerinfo) - Displays the printer information (stats) remotly. \x04Donator only\x01.");
	PrintToChat(client, "\x01[RP] sm_gotoprinter (!gotoprinter) - Teleports you to the printer. \x04Donator only\x01.");
	PrintToChat(client, "\x01[RP] sm_printerhelp (!printerhelp) - Shows this information.");
	PrintToChat(client, "\x01[RP] Made by \x04[GR|BK] Reloaded\x01 (Originaly found in Roflcopter Mod).");
	
	return Plugin_Handled;
}

public Action:CommandCreatePrinter(Client, args) {
	if(IsCombine(Client))
	{
		PrintToChat(Client, "[Comax]\x01 You can not use this while on duty.");
		return Plugin_Handled;
	} else
	{
		decl Float:ClientOrigin[3];
		GetClientAbsOrigin(Client, ClientOrigin);
		for(new X = 1; X < 2; X++)
		{
			if(Printer[Client][X][0] == 0.0)
			{
				if(Money[Client] > 200) //Should have made a var.
				{
					decl Float:DOrigin[3];
					GetClientAbsOrigin(Client, DOrigin);
					Crime[Client] += 600;
					Printer[Client][X][0] = DOrigin[0];
					Printer[Client][X][1] = DOrigin[1];
					Printer[Client][X][2] = DOrigin[2] + 5.0;
					//AddCrime(Client, CRIMECUFF);
					PrinterWorth[Client][X] = 0;
					PrintToChat(Client, "\x04[Comax]\x01 Spawned a printer.");
					Money[Client] -= 200;
					new Ent = CreateEntityByName("prop_physics_override");
					DispatchKeyValue(Ent, "solid", "0");
					DispatchKeyValue(Ent, "rendercolor", "0 255 0");
					DispatchKeyValue(Ent, "model", "models/props_lab/reciever01a.mdl");
					DispatchSpawn(Ent);
					TeleportEntity(Ent, Printer[Client][X], NULL_VECTOR, NULL_VECTOR);
					DOrigin[2] += 30.0;
					TeleportEntity(Client, DOrigin, NULL_VECTOR, NULL_VECTOR);
					PrinterEnt[Client][X] = Ent;
					SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);
					AcceptEntityInput(Ent, "DisableMotion");
					//Item[Client][20] -= 1;
				} else {
					PrintToChat(Client, "\x04[Comax]\x01 You can't afford a printer. It's value is $200.");
					return Plugin_Handled;
				}
			} else
			if(X == 1)
			{
				PrintToChat(Client, "[Comax]\x01 You can only have one printer.");
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Handled;
}

public Action:Command_PrinterInfo(client, args)
{
	for(new X = 1; X < 2; X++)
	{
		if(Printer[client][X][0] == 0.0)
		{
			PrintToChat(client, "\x04[Comax]\x01 You don't have a printer, type \x04sm_createprinter\x01 in \x04console\x01 to create one or \x04!createprinter\x01 in chat");
		} else if(X == 1) {
			PrintToChat(client, "\x04[Comax]\x01 You currently \x04have\x01 a printer, it's worth is \x04%d\x01", PrinterWorth[client][X]); //, next rise in \x04%d\x01 seconds.
		}
	}
	return Plugin_Handled;
}

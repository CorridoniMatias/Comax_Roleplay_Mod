/*	Models extension for Comax RP Mod.
*	@author	Reloaded.
*/

new String:Models[86][2][150]; // 86 models, 2 divisions: model name, path & material. 99 chars each.
new String:DefaultModel[32][68]; // current model of a player
new String:ModelsPath[PLATFORM_MAX_PATH];
new Handle:ModelDownloadPath = INVALID_HANDLE;
new String: FileNameInDir[99];

public ComaxModels()
{
	CreateDirectory("addons/sourcemod/data/roleplay/Comax", 3);
	BuildPath(Path_SM, ModelsPath, sizeof(ModelsPath), "data/roleplay/Comax/Models.txt");
	RegAdminCmd("sm_updatemodels", Command_UpdateModels, ADMFLAG_ROOT, "Prints printer info");
	RegAdminCmd("sm_model", ShowModelsMenu, ADMFLAG_CUSTOM4, "Displays the model picker menu.");
}


public ModelsMenuHandle(Handle:ModelsMenu, MenuAction:action, Client, Press)
{
	if (action == MenuAction_Select)
	{
		new String:Name[32], String:SteamID[32];
		decl String:Click[68];
		GetMenuItem(ModelsMenu, Press, Click, sizeof(Click));
		if(StrEqual(Click, "")) {
			PrintToChat(Client, "[RP] Failed to load model. Model was not applied for security reasons.");
			PrintToServer("[RP] Failed to load model array was empty or other errors encounted. Dump of arrays:\n- Click: %s.\n- DefaultModel: %s.", Click, DefaultModel[Client]);
		} else {
			PlayerModel[Client] = Click;
			
			GetClientName(Client, Name, sizeof(Name));
			GetClientAuthString(Client, SteamID, sizeof(SteamID));
			
			PrintToServer("Applying model: %s to client %s (%s).", PlayerModel[Client], Name, SteamID);
			PrintToChat(Client, "[RP] Applying model: %s.", PlayerModel[Client]);
		}
		
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(ModelsMenu);
	}
	return 0;
}

public Action:Command_UpdateModels(client, args) 
{
	PrintToConsole(client, "[RP] Updating models sources... We still highly recommend to restart the map!");
	LoadModels(1);
	return Plugin_Handled;
}

public Action:ShowModelsMenu(client, args) 
{
	//new String:Formatted[99];
	LoadModels(0);
	new Handle:ModelsMenu = CreateMenu(ModelsMenuHandle);
	SetMenuTitle(ModelsMenu, "Select your model:");
	PrintToConsole(client, "Select your new model, current model: %s", PlayerModel[client]);
	AddMenuItem(ModelsMenu, DefaultModel[client], "-Default model-");
	
	for(new i = 0; i < sizeof(Models);i++) {
		//Format(Formatted, sizeof(Formatted), "%s", Models[i][1]);
		//PrintToServer("\nWTF at Models[%d]: %s - - - %s", i, Models[i][1], Formatted);
		if(!StrEqual(Models[i][0], "")) {
			AddMenuItem(ModelsMenu, Models[i][1], Models[i][0]);
		}
	}
	SetMenuPagination(ModelsMenu, 7);
	DisplayMenu(ModelsMenu, client, 260);
	SetMenuExitButton(ModelsMenu, false);
	return Plugin_Handled;
}

public LoadModels(download) {
	
	//Always load the models.
	
	PrintToServer("Starting to load custom models... \n");
	
	decl Handle:Database;
	
	Database = CreateKeyValues("Custom Models");
	
	FileToKeyValues(Database, ModelsPath);
	
	//Found in DB:
	if(KvJumpToKey(Database, "Models", false))
	{
		PrintToServer("Models found... starting to dump into array... \n");
		
		for(new Y = 0; Y < 86; Y++)
		{
			decl String:Stringval[3];
			decl String:kvnoprocess[150];
			decl String:Buffer[4][150] = {"", "", "", ""};
			
			//Convert:
			Format(Stringval, sizeof(Stringval), "%d", Y);
			KvGetString(Database, Stringval,  kvnoprocess, sizeof(kvnoprocess));
			if(StrEqual(kvnoprocess, "")) {
			} else {
				//Explode:
				ExplodeString(kvnoprocess, "<^¬¬^>", Buffer, 4, 150); // 1: name 2: path 3:materials (if needed), 4: .mdl file name (ONLY NECESSARY IF THE PATH HAS MORE THAN ONE MDL!).
				
				if(!DirExists(Buffer[1]) && StrContains(Buffer[1], ".mdl", false) == -1)
				{
					LogToFile(COMAX_ERRORS, "\n\nCOMAX RP::Models -> Cannot load model '%s'! Unable to open model path.\n\n", Buffer[0]);
					Models[Y][0] = "";
				} else if(!FileExists(Buffer[1]) && StrContains(Buffer[1], ".mdl", false) != -1) {
					LogToFile(COMAX_ERRORS, "\n\nCOMAX RP::Models -> Cannot load model '%s'! Unable to open file.\n\n", Buffer[0]);
					Models[Y][0] = "";
				} else {
					
					Models[Y][0] = Buffer[0];
					
					if(StrContains(Buffer[1], ".mdl", false) != -1)
					{
						Models[Y][1] = Buffer[1];
						PrintToServer("File:Dumping to array: Model name: %s, path: %s. Original: %s (Models[%d]). \n", Models[Y][0], Models[Y][1], kvnoprocess, Y);	
					} else {
						//models
						Models[Y][1] = "UNASS";
						PrintToServer("Space: %d\nBuffer[0]: %s\nBuffer[1]: %s\nBuffer[2]: %s\nBuffer[3]: %s", sizeof(Buffer),Buffer[0], Buffer[1], Buffer[2], Buffer[3]);
						decl String:Formatdownload[99];
						ModelDownloadPath = OpenDirectory(Buffer[1]);
						while(ReadDirEntry(ModelDownloadPath, FileNameInDir, sizeof(FileNameInDir))) {
							if(!StrEqual(FileNameInDir, ".") && !StrEqual(FileNameInDir, ".."))
							{
								Format(Formatdownload, sizeof(Formatdownload), "%s/%s", Buffer[1], FileNameInDir);
								AddFileToDownloadsTable(Formatdownload);
								if(StrContains(Buffer[3], ".mdl") != -1) {
									Format(Models[Y][1], 150, "%s/%s", Buffer[1], Buffer[3]);
								} else if(StrContains(FileNameInDir, ".mdl", false) != -1 && StrEqual(Models[Y][1], "UNASS")) 
								{
									Models[Y][1] = Formatdownload;
								}
							}
						}
						//materials
						ModelDownloadPath = OpenDirectory(Buffer[2]);
						while(ReadDirEntry(ModelDownloadPath, FileNameInDir, sizeof(FileNameInDir))) {
							if(!StrEqual(FileNameInDir, ".") && !StrEqual(FileNameInDir, ".."))
							{
								Format(Formatdownload, sizeof(Formatdownload), "%s/%s", Buffer[2], FileNameInDir);
								AddFileToDownloadsTable(Formatdownload);
								PrecacheModel(Formatdownload, true);
							}
						}
						
						PrintToServer("Path:Dumping to array: Model name: %s, path: %s. Materials: %s. Original: %s (Models[%d]). \n", Models[Y][0], Models[Y][1], Buffer[2],kvnoprocess, Y);	
					}
					
					if(download == 1) {
						//Load models and add then to the downloads table, most likely to be used only once per map change.
						if(!StrEqual(Models[Y][1], "")) {
							PrecacheModel(Models[Y][1], true);
							AddFileToDownloadsTable(Models[Y][1]);
							PrintToServer("Precache running... File: %s... Adding file to dowloads table... \n", Models[Y][1]);
						}
					}
				}
				
				if(StrEqual(Models[Y][0], "")) //Reset the variable if theres nothing in it.
					Models[Y][1] = "";
				
			}
		}
	} else {
		PrintToServer("Could not find Models. Please try setting them up!  \n");
	}
	KvRewind(Database);
	CloseHandle(Database);
}

public Action:AfterSpawnTimer(Handle:timer, any: client)
{
	if(IsClientInGame(client) && IsClientConnected(client))
	{
		if(IsPlayerAlive(client))
		{
			GetClientModel(client, DefaultModel[client], 68); //MAKE SURE CLIENT IS *NOT* IN SPEC MODE.
		}
	}
	return Plugin_Handled;
}
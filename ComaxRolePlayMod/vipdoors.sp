/*
	OnPluginStart:
	//Comax: VIP Doors
	RegAdminCmd("sm_createvipdoor", commandcreatevipdoor, ADMFLAG_ROOT,"Creates a VIP door");
	RegAdminCmd("sm_removevipdoor", commandremovevipdoor, ADMFLAG_ROOT,"Removes a VIP door");
	RegAdminCmd("sm_listvipdoors", commandlistvipdoor, ADMFLAG_CUSTOM3,"Prints the VIP door list");

*/

new VIPDoor[20] = {-1,...};

public ComaxVipDoors()
{
	RegAdminCmd("sm_createvipdoor", commandcreatevipdoor, ADMFLAG_ROOT,"Creates a VIP door");
	RegAdminCmd("sm_removevipdoor", commandremovevipdoor, ADMFLAG_ROOT,"Removes a VIP door");
	RegAdminCmd("sm_listvipdoors", commandlistvipdoor, ADMFLAG_CUSTOM3,"Prints the VIP door list");
}

//This goes in if(Ent != -1) under CommandUse(Client)
public bool:ToggleVipDoor(Client, Ent, String:ClassName[])
{
	if((StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating") || StrEqual(ClassName, "func_door")) && (IsCombine(Client) || GetVipLevel(Client) > 0 || IsFirefighter(Client)))
	{
		for(new i = 0;i < sizeof(VIPDoor);i++)
		{
			if(VIPDoor[i] == Ent)
			{
				AcceptEntityInput(Ent, "Unlock");
				
				AcceptEntityInput(Ent, "Toggle");
				
				AcceptEntityInput(Ent, "Lock");
				break;
			}
		} 
		return true;
	}
	return false;
}

//This MUST be called at the end of OnMapStart();
public LoadVIPDoors()
{
	new String:itostring[5], res;
	
	new Handle:kv = CreateKeyValues("Vault");
	FileToKeyValues(kv, ConfigPath);
	
	if(KvJumpToKey(kv, "VipDoors", false))
	{
		for(new i = 0;i < sizeof(VIPDoor);i++)
		{
			Format(itostring, sizeof(itostring), "%d", i);
			res = KvGetNum(kv, itostring, -1);
			
			if(res != -1)
			{
				VIPDoor[i] = res;
				PrintToServer("[Comax] Adding ID = '%d' -- VIPDoor[%d] = '%d' -- KV: %d", i, i, VIPDoor[i], res);
			} else {
				VIPDoor[i] = res;
				PrintToServer( "[Comax] Skipping ID = '%d' -- VIPDoor[%d] = '%d' -- KV: %d", i, i, VIPDoor[i], res);
			}
		} 
	} else {
		PrintToServer("[Comax] No VIP doors were found");
	}
	
	KvRewind(kv);
	CloseHandle(kv);
}


public Action:commandcreatevipdoor(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[Comax] Please enter an id. (0 - 20). Use sm_listvipdoors to view all the available doors.");
		return Plugin_Handled;
	}
	
	new String:arg1[5], ent;
	
	GetCmdArg(1, arg1, sizeof(arg1));
	
	if(StringToInt(arg1) > 20 || StringToInt(arg1) < 0)
	{
		ReplyToCommand(client, "[Comax] Please enter a valid id 0 - 20. %s", arg1);
		return Plugin_Handled;
	}
	
	ent = GetClientAimTarget(client, false);
	if(ent == -1 || !IsValidEntity(ent))
	{
		ReplyToCommand(client, "[Comax] Invalid entity. %d", ent);
		return Plugin_Handled;
	}
	
	new Handle:kv = CreateKeyValues("Vault");
	FileToKeyValues(kv, ConfigPath);
	
	if(KvJumpToKey(kv, "VipDoors", true))
	{
		new res = KvGetNum(kv, arg1, -1);
		if(res == -1)
		{
			ReplyToCommand(client, "[Comax] Creating VIP door with id of %s. Entity number: %d", arg1, ent);
		} else {
			ReplyToCommand(client, "[Comax] Replacing existing VIP door %d with new door %d.", res, ent);
		}
		
		VIPDoor[StringToInt(arg1)] = ent;
		
		KvSetNum(kv, arg1, ent);
	}
	
	KvRewind(kv);
	KeyValuesToFile(kv, ConfigPath);
	CloseHandle(kv);
	return Plugin_Handled;
}	

public Action:commandremovevipdoor(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[Comax] Please enter an id. (0 - 20). Use sm_listvipdoors to view all the available doors.");
		return Plugin_Handled;
	}
	
	new String:arg1[5];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	
	new Handle:kv = CreateKeyValues("Vault");
	FileToKeyValues(kv, ConfigPath);
	
	if(KvJumpToKey(kv, "VipDoors", false))
	{
		if(KvDeleteKey(kv, arg1))
		{
			ReplyToCommand(client, "[Comax] Door with id %s removed.", arg1);
			VIPDoor[StringToInt(arg1)] = -1;
		} else ReplyToCommand(client, "[Comax] Cannot find door with id %s.", arg1);
		
	} else {
		ReplyToCommand(client, "[Comax] Sorry no VIP doors were found");
	}
	
	KvRewind(kv);
	KeyValuesToFile(kv, ConfigPath);
	CloseHandle(kv);
	return Plugin_Handled;
	
}
public Action:commandlistvipdoor(client, args)
{	
	new String:itostring[5], res;
	
	new Handle:kv = CreateKeyValues("Vault");
	FileToKeyValues(kv, ConfigPath);
	
	if(KvJumpToKey(kv, "VipDoors", false))
	{
		for(new i = 0;i < sizeof(VIPDoor);i++)
		{
			Format(itostring, sizeof(itostring), "%d", i);
			res = KvGetNum(kv, itostring, -1);
			
			PrintToConsole(client, "[Comax] ID = '%d' -- VIPDoor[%d] = '%d' -- KV: %d", i, i, VIPDoor[i], res);
		} 
	} else {
		ReplyToCommand(client, "[Comax] Sorry no VIP doors were found");
	}
	
	KvRewind(kv);
	CloseHandle(kv);
	return Plugin_Handled;
}

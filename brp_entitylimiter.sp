/*
*	Comax RolePlay Mod: Client entity limiter.
*/

#include <sourcemod>
#include <sdktools>

static Entity[32][40]; //32 players, 40 entities -> select later how many to assign.
static Handle:h_maxentities = INVALID_HANDLE;

public Plugin:myinfo = {
	name = "Client Entity Limiter - Comax RolePlay Mod",
	author = "[CMX] Reloaded",
	description = "Removes 'old' entities when the client spawns new ones",
	url = "comaxservers.com.ar"
};

public OnPluginStart()
{
	RegServerCmd("comax_addentity", commandaddentity, "Command add entity");
	RegServerCmd("comax_removeentity", commandremoveentity, "Command add entity");
	h_maxentities = CreateConVar("sm_maxents", "10", "Set the max amt of ents a player can have (Only props!). Counting 0! From 1 till 38 (39 in total)", FCVAR_PLUGIN|FCVAR_NOTIFY, true, 1.0, true, 38.0);
}

public OnClientDisconnect(client)
{
	for(new i = 0;i<GetConVarInt(h_maxentities);i++)
	{
		if(Entity[client][i] != 0)
		{
			if(IsValidEntity(Entity[client][i]))
			{
				AcceptEntityInput(Entity[client][i], "Kill");
			}	
			Entity[client][i] = 0;
		}
	}
}

public Action:commandaddentity(args)
{
	if(args < 1)
	{
		PrintToServer("--- ERROR: Expected parameter Client. ---");
		return Plugin_Handled;
	}
	
	if(args < 2)
	{
		PrintToServer("--- ERROR: Expected parameter Ent. ---");
		return Plugin_Handled;
	}
	
	new String:arg1[32], String:arg2[10];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	new client = StringToInt(arg1), ent = StringToInt(arg2);
	
	AssignNewEntity(client, ent);
	
	return Plugin_Handled;
}

public Action:commandremoveentity(args)
{
	if(args < 1)
	{
		PrintToServer("--- ERROR: Expected parameter Client. ---");
		return Plugin_Handled;
	}
	
	if(args < 2)
	{
		PrintToServer("--- ERROR: Expected parameter Ent. ---");
		return Plugin_Handled;
	}
	
	new String:arg1[32], String:arg2[10];
	
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	new client = StringToInt(arg1), ent = StringToInt(arg2);
	
	RemoveClientEntity(client, ent);
	
	return Plugin_Handled;
}

public RemoveClientEntity(client, ent)
{	
	for(new i = 0;i<GetConVarInt(h_maxentities);i++)
	{
		/*if(Entity[client][i] == ent)
		{
			replace = true;
		} 
		//Tidy the structure
		if(replace)
		{
			Entity[client][i] = Entity[client][i + 1];
		}*/
		
		if(Entity[client][i] == ent)
		{
			Entity[client][i] = 0;
		} 
		
		if(Entity[client][i] == 0)
		{
			Entity[client][i] = Entity[client][i + 1];
			Entity[client][i + 1] = 0;
		}
		
		//PrintToConsole(client, "assigning: Entity[client][%d] = Entity[client][%d] -- Entity[client][%d] = %d", i, i + 1, i, Entity[client][i]);
	}
}

public AssignNewEntity(client, ent)
{
	decl maxents;
	maxents = GetConVarInt(h_maxentities);
	for(new i = 0;i<maxents;i++)
	{
		if(Entity[client][i] == 0)
		{
			Entity[client][i] = ent;
			break;
		} 
		if(i == (maxents - 1))
		{
			//PrintToServer("matches: %d = %d", i , (maxents - 1));
			if(IsValidEntity(Entity[client][0]))
			{
				AcceptEntityInput(Entity[client][0], "Kill");
			} else {
				PrintToServer("FATAL ERROR: Cannot kill entity %d. Owner: %d", ent, client);
			}
			
			for(new o = 0;o<maxents;o++)
			{
				Entity[client][o] = Entity[client][o + 1];
				//PrintToConsole(client, "%d) assigning: Entity[client][%d] = Entity[client][%d] -- Entity[client][%d] = %d", client, o, o + 1, o, Entity[client][o]);
			}
			Entity[client][i] = ent;
			//PrintToConsole(client, "assigning: Entity[client][%d] = %d", i, ent);
		}
		//PrintToConsole(client, "Entity[client][%d] = %d;", i , Entity[client][i]);
	}
}
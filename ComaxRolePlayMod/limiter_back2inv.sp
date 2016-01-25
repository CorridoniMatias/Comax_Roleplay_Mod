

//Goes under Delete(Client, Args)
public CheckPropOwnership(Ent)
{
	decl String:gname2[10];
	GetEntPropString(Ent, Prop_Data, "m_iName",gname2, sizeof(gname2));
	decl owner;
	owner = StringToInt(gname2);
	
	if(owner != -1 && (IsClientConnected(owner) && IsClientInGame(owner)))
	{
		PrintToChat(owner, "[Comax] An admin deleted one of your unsaved props");
		ServerCommand("comax_removeentity %d %d", owner, Ent);
	}
}

//Goes under if(Ent != -1) in CommandUse(Client)
//if return == true then return Plugin_Handlded;
public bool:ReAddToInv(Client, Ent, String:ClassName[])
{
	// Comax: Owner entity - Requires bSaveit and bEntityLimiter, both by Reloaded.
	if(StrEqual(ClassName, "prop_physics") || StrEqual(ClassName, "prop_physics_override"))
	{			
		decl String:gname2[10];
		GetEntPropString(Ent, Prop_Data, "m_iName",gname2, sizeof(gname2));
		decl owner;
		owner = StringToInt(gname2);
		
		if(owner != -1)
		{
			if(owner == Client)
			{
				for(new X = 0; X < MAXITEMS; X++)
				{
					//Money:
					if(ItemAmount[Ent][X] > 0)
					{
						
						PrintToChat(Client, "\x01[\x04Comax\x01] You've re-added \x04%s\x01 to your inventory.", ItemName[X]);
						
						AcceptEntityInput(Ent, "Kill");
						
						ServerCommand("comax_removeentity %d %d", owner, Ent);
						
						Item[Client][X] += ItemAmount[Ent][X];
						//Save:
						ItemAmount[Ent][X] = 0;
						
					}
				}
				//Return:
				return true;
			} else if(owner != 0) {
				decl String:Name[32];
				GetClientName(owner, Name, sizeof(Name));
				
				PrintToChat(Client, "\x01[\x04Comax\x01] You don't own this prop. Its owner is \x04%s\x01", Name);
				return true;
			} else { //owner = server
				PrintToConsole(Client, "[Comax] You don't own this prop. It has been spawned by the server.");
				return true;
			}
		}
	}
	return false;
}

//Goes under ItemAction[ItemId] == 7 in UsingItems(Handle:ItemUse, MenuAction:action, Client, param2)
public AddPropToList(Client, Ent, ItemId)
{
	//Comax Entity Limiter
	ServerCommand("comax_addentity \"%d\" %d", Client, Ent);
	
	/*decl String:gname[10];
	Format(gname, sizeof(gname), "%d", Client);
	SetEntPropString(Ent, Prop_Data, "m_iName", gname);
	decl String:gname2[10];
	GetEntPropString(Ent, Prop_Data, "m_iName", gname2, sizeof(gname2));*/
	decl String:gname[10];
	Format(gname, sizeof(gname), "%d", Client);
	DispatchKeyValue(Ent, "targetname", gname);
	ItemAmount[Ent][ItemId] = 1;
	//PropLimit[Client] += 1;
}
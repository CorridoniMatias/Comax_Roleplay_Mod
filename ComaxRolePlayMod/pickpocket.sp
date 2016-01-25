/*	Pick Pocket extension for Comax RP Mod.
*	@author	Reloaded.
*/


new Handle:g_RobStatus = INVALID_HANDLE;
new static CanRob[32] = 0; //NOTE FROM RELOADED: This will be ALSO used as the wating time to rob again. 0 = Can rob. Greater than 0 Can't rob.

public ComaxPickPocket()
{
	g_RobStatus = CreateConVar("sm_pickpocketing", "1", "Allow pickpocketing mod. 0 = off, 1 = on. Default 'on'", FCVAR_PLUGIN);
}

//This goes under public PlayerInformation(Handle:PlayerInfo, MenuAction:action, Client, param2)
public PickPocketItemSelected(String:info2[], Client)
{
	//Rob:
	if(StrContains(info2, "-", false) != -1)
	{
		new String:buffer[2][8];
		ExplodeString(info2, "-", buffer, 2, 8);
		StartRobberMenu(StringToInt(buffer[1]), Client);
	}
}

//This goes after if(Dist2 <= 150) in public Action:CommandUse(Client)
public PickPocketAddMenu(Handle:PlayerInfo, Client, Ent)
{
	new RobStatus = GetConVarInt(g_RobStatus);
	
	if(RobStatus == 1) {
		if(StrEqual(Job[Client], "Robber", false))
		{
			decl String:send[10];
			Format(send, sizeof(send), "0-%d", Ent);
			AddMenuItem(PlayerInfo, send, "-| ROB! |-");
		}
	}
}

public StartRobberMenu(Ent, Client) //Ent is target
{
	decl RobStatus;
	RobStatus = GetConVarInt(g_RobStatus);
	if(RobStatus == 1) {
		//PrintToChat(Client, "Fase 1, Var = 1");
		if(StrEqual(Job[Client], "Robber", false))
		{
			//PrintToChat(Client, "Fase 2, IsRobber = True");
			if(Ent > 0 && Ent <= GetMaxClients())
			{	
				//PrintToChat(Client, "Fase 3, Got Ent");
				decl String:ClassName[20], String:ClientName[60], String:ItemMenu[99], String:itemid[30];
				GetEdictClassname(Ent, ClassName, sizeof(ClassName));
				if(StrEqual(ClassName, "player", false))
				{
					//PrintToChat(Client, "Fase 4, IsPlayer = True");
					if(CanRob[Client] == 0)
					{
						//PrintToChat(Client, "Fase 5, CanRob = True");
						GetClientName(Ent, ClientName, sizeof(ClientName));
						new Handle:PlayerItems = CreateMenu(ItemListenerHandle);
						SetMenuTitle(PlayerItems, "Now viewing %s's items.\nDisplaying 10 items.\nPlease select one to rob.\nPick Pocketing Mod by \nReloaded.", ClientName);
						for(new i = 0;i<=10;i++)
						{
							//Checking if player has any of the items at all...
							if(Item[Ent][i] > 0)
							{
								Format(ItemMenu, sizeof(ItemMenu), "%s", ItemName[i]);
								IntToString(i, itemid, sizeof(itemid));
								AddMenuItem(PlayerItems, itemid, ItemMenu);
							}
						}
						SetMenuPagination(PlayerItems, 20);
						DisplayMenu(PlayerItems, Client, 260);
						SetMenuExitButton(PlayerItems, true);
						return;
					} else {
						PrintToChat(Client, "\x01\x04[\x01RP\x04]\x01 Please wait %d more seconds before robbing again.", CanRob[Client]);
						return;
					}
				}
			}
		}
	}	
}

public ItemListenerHandle(Handle:PlayerItems, MenuAction:action, Client, Press)
{
	if (action == MenuAction_Select)
	{
		decl Ent;
		Ent = GetClientAimTarget(Client, false);
		
		if(Ent != -1)
		{
			decl String:Click[3];
			new String:NameT[66],String:NameC[66];
			GetMenuItem(PlayerItems, Press, Click, sizeof(Click));
			new option = StringToInt(Click);
			GetClientName(Ent, NameT, sizeof(NameT));
			GetClientName(Client, NameC, sizeof(NameC));
			//ServerCommand("sm_additem \"%s\" %d 1",NameC,option);
			//ServerCommand("sm_removeitem \"%s\" %d 1",NameT,option);
			Item[Ent][option] -= 1;
			Item[Client][option] += 1;	
			AddCrime(Client, 100);
			Save(Client);
			PrintToChat(Client, "\x01\x04[\x01Comax\x04]\x01 %s robbed from %s.",ItemName[option],NameT);
			PrintToChat(Ent, "\x01\x04[\x01Comax\x04]\x01 %s has stolen '%s' from you.",NameC,ItemName[option]);
			CanRob[Client] = 60;
			CreateTimer(1.0, RestoreRobTimer, Client);
		} else {
			PrintToChat(Client, "[Comax] Whoops! Apparently your target got away :(");
		}
	}
	else if (action == MenuAction_End)
	{
		CloseHandle(PlayerItems);
	}
}

public Action:RestoreRobTimer(Handle:timer, any:client)
{
	if(CanRob[client] > 0) {
		CanRob[client]--;
		CreateTimer(1.0, RestoreRobTimer, client);
	}
	return Plugin_Handled;
}
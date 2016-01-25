#include <sourcemod>

/*	SQL Table Creation.
*	
*	Main Table: Strong entity.
*	CREATE TABLE IF NOT EXISTS rp_main_client (steamid VARCHAR(32), PRIMARY KEY(steamid), Job VARCHAR(20) DEFAULT 'UNEMPLOYED', Bank INT DEFAULT 0, Money INT DEFAULT 0, Wages INT DEFAULT 0, Minutes INT DEFAULT 0, Crime INT DEFAULT 0, Exploit INT DEFAULT 0, Pruned INT DEFAULT 0, Negative INT DEFAULT 0, Checks INT DEFAULT 0, ExpRebel INT DEFAULT 0, ExpCombine INT DEFAULT 0, TimeJail INT DEFAULT 0, Grams INT DEFAULT 0, MainHudColor INT DEFAULT 0, CenterHudColor INT DEFAULT 0, ExpLevel INT DEFAULT 0, Planted INT DEFAULT 0, CuffCount INT DEFAULT 0);
*
*	Items Table: 1 to many relation with rp_main_client, where many is this and 1 is rp_main_client.
*	CREATE TABLE IF NOT EXISTS rp_items_client (steamid VARCHAR(32), itemid INT, PRIMARY KEY (steamid, itemid), amount INT);
*
*	NOTICE: The variable new ItemCost[MAXITEMS] now must be initialized with new ItemCost[MAXITEMS] = {-1, ...};
*/

new String:tables[2][100] =  {
								"rp_main_client",
								"rp_items_client"
							};

enum Table
{
	T_MAIN = 0,
	T_ITEMS,
}

new Handle:h_database = INVALID_HANDLE;

//Both start with a 'false' value.
new bool:useUpdate[32][sizeof(tables)];
new bool:loadedItem[32][MAXITEMS];

public startConnection()
{
	SQL_TConnect(ConnectCallBack, "RolePlaySQLDatabase");
}

public ConnectCallBack(Handle:owner, Handle:db, const String:error[], any:data)
{
	if(db == INVALID_HANDLE)
		SetFailState("RolePlaySQLDatabase::ConnectCallBack - Cannot establish SQL connection. Error: %s", error);

	if(h_database != INVALID_HANDLE)
	{
		CloseHandle(h_database);
		h_database = INVALID_HANDLE;
	}
	
	h_database = db;
	
	PrintToServer("RolePlaySQLDatabase::ConnectCallBack - Successfully connected. Loading tables...");
	
	createTables(h_database);
}

public bool:createTables(Handle:db)
{
	if(db == INVALID_HANDLE)
		return false;
	
	decl String:checkQuery[600]; //Both queries are 637.
	
//	StrCat(checkQuery, sizeof(checkQuery), );
	
	SQL_LockDatabase(h_database);
	//SQL_TQueryEx(db, ErrorOnlyCallback, checkQuery);
	Format(checkQuery, sizeof(checkQuery), "CREATE TABLE IF NOT EXISTS rp_main_client (steamid VARCHAR(32) PRIMARY KEY NOT NULL, Job VARCHAR(20) DEFAULT '%s', Bank INT DEFAULT 0, Money INT DEFAULT 0, Wages INT DEFAULT 0, Minutes INT DEFAULT 0, Crime INT DEFAULT 0, Exploit INT DEFAULT 0, Pruned INT DEFAULT 0, Negative INT DEFAULT 0, Checks INT DEFAULT 0, ExpRebel INT DEFAULT 0, ExpCombine INT DEFAULT 0, TimeJail INT DEFAULT 0, Grams INT DEFAULT 0, MainHudColor INT DEFAULT 0, CenterHudColor INT DEFAULT 0, ExpLevel INT DEFAULT 0, Planted INT DEFAULT 0, CuffCount INT DEFAULT 0);", DEFAULTJOB);
	//SQL_FastQuery(h_database, checkQuery);
	new Handle:query = SQL_Query(db, checkQuery);
	
	if(query == INVALID_HANDLE)
	{
		SQL_GetError(db, checkQuery, sizeof(checkQuery));
		PrintToServer("Cannot create trable: %s", checkQuery);
	}
	
	checkQuery = "CREATE TABLE IF NOT EXISTS rp_items_client (steamid VARCHAR(32), itemid INT, amount INT, PRIMARY KEY (steamid, itemid));";
	//SQL_FastQuery(h_database, checkQuery);
	query = SQL_Query(db, checkQuery);
	
	if(query == INVALID_HANDLE)
	{
		SQL_GetError(db, checkQuery, sizeof(checkQuery));
		PrintToServer("Cannot create trable: %s", checkQuery);
	}
	SQL_UnlockDatabase(h_database);
	CloseHandle(query);
	return true;
}

SaveInteger(client, Handle:db, String:field[], String:steamid[], value, Table:tbl = T_MAIN)
{
	if(isBot[client]) return;
	if(!isBot[client])
	{
		if(IsFakeClient(client))
		{
			isBot[client] = true;
			return;
		}
	}
	
	if(db == INVALID_HANDLE)
	{
		PrintToServer("SaveInteger::Error - Database handle is invalid");
		return;
	}
	
	decl table;
	table = _:tbl; //This is just so people don't try to send random numbers.
	
	new String:query[300];
	
	if(!useUpdate[client][table])
	{
		Format(query, sizeof(query), "INSERT INTO %s (steamid, %s) VALUES ('%s', %d);", tables[table], field, steamid, value);
		useUpdate[client][table] = true;
	}
	else
		Format(query, sizeof(query), "UPDATE %s SET %s=%d WHERE steamid='%s'", tables[table], field, value, steamid);
	
	//PrintToServer(query);
	
	SQL_TQueryEx(db, ErrorOnlyCallback, query); //RowAffectedCallBack
}	

LoadInteger(Handle:db, String:field[], String:steamid[], defaultvalue, Table:tbl = T_MAIN)
{
	if(StrContains(steamid, "BOT") != -1) return defaultvalue;
	
	if(db == INVALID_HANDLE)
		return defaultvalue;
	
	decl table;
	table = _:tbl; //This is just so people don't try to send random numbers.
	
	new String:query[200];
	
	Format(query, sizeof(query), "SELECT %s FROM %s WHERE steamid='%s'", field, tables[table], steamid);
	
	SQL_LockDatabase(db); 
	
	//SQL_TQuery(db, testcb, query, buffer);
	new Handle:response = SQL_Query(db, query);
	
	if(response == INVALID_HANDLE)
	{
		PrintToServer("-::-LoadInteger reporting response is invalid.");
		return defaultvalue;
	}
	
	if(SQL_FetchRow(response))
	{
		decl temp;
		temp = SQL_FetchInt(response, 0);
		CloseHandle(response);
		SQL_UnlockDatabase(db);
		
		return temp;
	}
	
	SQL_UnlockDatabase(db);
	
	return defaultvalue;
}	

LoadStringSQL(Handle:db, String:field[], String:steamid[], String:buffer[], maxsize, String:defaultvalue[] = "", Table:tbl = T_MAIN)
{
	if(StrContains(steamid, "BOT") != -1)
		strcopy(buffer, maxsize, defaultvalue);
	
	if(db == INVALID_HANDLE)
		strcopy(buffer, maxsize, defaultvalue);
	
	decl table;
	table = _:tbl; //This is just so people don't try to send random numbers.
	
	new String:query[200];
	
	Format(query, sizeof(query), "SELECT %s FROM %s WHERE steamid='%s'", field, tables[table], steamid);
	
	SQL_LockDatabase(db);
	
	//SQL_TQuery(db, testcb, query, buffer);
	new Handle:response = SQL_Query(db, query);
	
	if(response == INVALID_HANDLE)
	{
		PrintToServer("-::-LoadInteger reporting response is invalid.");
		strcopy(buffer, maxsize, defaultvalue);
	}
	
	if(SQL_FetchRow(response))
	{
		if(SQL_IsFieldNull(response, 0))
			strcopy(buffer, maxsize, defaultvalue);
		else
			SQL_FetchString(response, 0, buffer, maxsize);
		CloseHandle(response);
		SQL_UnlockDatabase(db);
		return;
	}
	
	SQL_UnlockDatabase(db);
	
	strcopy(buffer, maxsize, defaultvalue);
}	

SaveStringSQL(client, Handle:db, String:field[], String:steamid[], String:value[], Table:tbl = T_MAIN)
{
	if(isBot[client]) return;
	if(!isBot[client])
	{
		if(IsFakeClient(client))
		{
			isBot[client] = true;
			return;
		}
	}
	
	if(db == INVALID_HANDLE)
	{
		PrintToServer("SaveStringSQL::Error - Database handle is invalid");
		return;
	}
	
	decl table;
	table = _:tbl; //This is just so people don't try to send random numbers.
	
	new String:query[300];
	
	if(!useUpdate[client][table])
		Format(query, sizeof(query), "INSERT INTO %s (steamid, %s) VALUES ('%s', '%s');", tables[table], field, steamid, value);
	else
		Format(query, sizeof(query), "UPDATE %s SET %s='%s' WHERE steamid='%s'", tables[table], field, value, steamid);
	
	
	SQL_TQueryEx(db, ErrorOnlyCallback, query); //RowAffectedCallBack
}

public LoadPlayerItems(Handle:db, client)
{
	if(isBot[client]) return;
	
	if(db == INVALID_HANDLE)
		return;
	
	//PrintToConsole(client, "\n\n--------------------- Start of items ----------------------------");
		
	new String:sid[32];
	GetClientAuthString(client, sid, sizeof(sid));
	new String:query[200];
	Format(query, sizeof(query), "SELECT itemid, amount FROM rp_items_client WHERE steamid='%s'", sid);
	
	new Handle:data = CreateKeyValues("d");
	KvSetNum(data, "client", client);
	//PrintToConsole(client, "Getting items: %s", query);
	SQL_TQueryEx(db, GetClientItemsCB, query, data);
}

public GetClientItemsCB(Handle:datab, Handle:hQuery, const String:error[], any:data)
{
	if(SQLError(datab, error))
		RetryQuery(datab, GetClientItemsCB, data, error);
	
	decl itemid, amount, client, String:name[32];
	
	client = KvGetNum(Handle:data, "client", -1);
	
	if(client == -1) return;
	
	new String:sid[32];
	GetClientAuthString(client, sid, sizeof(sid));
	GetClientName(client, name, sizeof(name));
	
	new its = 0;
	
	while(SQL_FetchRow(hQuery))
	{
		itemid = SQL_FetchInt(hQuery, 0);
		amount = SQL_FetchInt(hQuery, 1);
		
		//PrintToConsole(client, "Retrieving '%s'(%d) with amount of %d for client %s(%d).", ItemName[itemid], itemid, amount, name, client);
		its++;
		Item[client][itemid] = amount;
		loadedItem[client][itemid] = true;
	}
	
	LogToFile(COMAX_ERRORS, "Loaded a total of %d items for client %s(%s)(%d). Bank: %d - Minutes: %d - Money: %d. Using update: %s", its, name, sid, client, Bank[client], Minutes[client], Money[client], ((useUpdate[client][T_MAIN]) ? "TRUE" : "FALSE"));
	//PrintToConsole(client, "--------------------- End of items ----------------------------\n\n");
	CloseHandle(Handle:data);
}

public DeletePlayerItem(Handle:db, client, String:sid[], itemid)
{
	if(isBot[client]) return;
	
	if(db == INVALID_HANDLE)
		return;
	
	new String:query[200];
	Format(query, sizeof(query), "DELETE FROM rp_items_client WHERE steamid='%s'", sid);
	
	SQL_TQueryEx(db, ErrorOnlyCallback, query);
}

public SavePlayerItems(Handle:db, client)
{
	if(isBot[client]) return;
	
	if(db == INVALID_HANDLE)
		return;
		
	//We need a massive size on the update query.
	new String:query_ins[1024], String:query_upt[8192], String:temp[128], String:sid[32];
	
	query_ins = "INSERT INTO rp_items_client VALUES ";
	query_upt = "UPDATE rp_items_client SET amount = CASE itemid "; //This is 48 chars
	GetClientAuthString(client, sid, sizeof(sid));
	
	new ins = 0, upt = 0;
	
	for(new X; X < MAXITEMS; X++)
	{
		if(ItemCost[X] == -1) continue;
		
		if(!HasItem(client, X)) 
		{
			if(!LoadedItem(client, X)) continue;

			//PrintToServer("Deleting item %s(%d) from client %s(%d).", ItemName[X], X, sid, client);
			/*DeletePlayerItem(db, client, sid, X);
			loadedItem[client][X] = false;
			continue;*/
		}
		
		if(!LoadedItem(client, X))
		{
			//PrintToServer("Inserting item %s(%d) to client %s(%d).", ItemName[X], X, sid, client);
			Format(temp, sizeof(temp), "('%s', %d, %d),", sid, X, Item[client][X]);
			StrCat(query_ins, sizeof(query_ins), temp);
			loadedItem[client][X] = true;
			ins++;
		}
		else
		{
			//PrintToServer("Updating item %s(%d) on client %s(%d).", ItemName[X], X, sid, client);
			Format(temp, sizeof(temp), "WHEN %d THEN %d ", X, Item[client][X]);
			StrCat(query_upt, sizeof(query_upt), temp);
			upt++;
		}
	}
	
	decl len;
	
	len = strlen(query_ins) - 1;
	
	if(query_ins[len] == ',')
		query_ins[len] = ';';
	else if(query_ins[len] == ' ')
		query_ins = "";
		
	len = strlen(query_upt);
	
	if(len == 48)
		query_upt = "";		
		
	//PrintToConsole(client, "Insert length: %d (%d items)\nUpdate length: %d (Out of bounds = %s | %d items) ", strlen(query_ins), ins, len, ((len > sizeof(query_upt)) ? "Yes" : "No"), upt);
	
	/*new Handle:kv = CreateKeyValues("kv");
	KvSetNum(kv, "client", client);*/
	
	if(strlen(query_upt) > 0)
	{
		Format(temp, sizeof(temp), "END WHERE steamid='%s';", sid);
		StrCat(query_upt, sizeof(query_upt), temp);
		
		//SQL_TQueryEx(db, ItemUpdatedCB, query_upt);
		SQL_TQueryEx(db, ItemUpdatedCB, query_upt);
		//PrintToConsole(client, query_upt);
	}
	if(strlen(query_ins) > 0)
	{
		//SQL_TQueryEx(db, ItemUpdatedCB, query_ins);
		SQL_TQueryEx(db, ItemUpdatedCB, query_ins);
	}
	
	/*PrintToServer("----------------- DISPLAYING ITEM TABLE QUERY ----------------");
	PrintToServer(query_ins);
	PrintToServer(query_upt);
	PrintToServer("--------------------------------------------------------------");*/
	
}

public ItemUpdatedCB(Handle:datab, Handle:hQuery, const String:error[], any:data)
{
	//new client = KvGetNum(Handle:data, "client", -1);
	new len = SQLGetQueryLength(data);
	new String:query[len];
	SQLGetQuery(data, query, len);
	CloseHandle(Handle:data);
	if(SQLError(datab, error) || hQuery == INVALID_HANDLE)
	{
	
		LogToFile(COMAX_ERRORS,"Error on query: ^.^	^.^	  ^.^");
		LogToFile(COMAX_ERRORS,query);
		LogToFile(COMAX_ERRORS,error);
	}
}

public SavePlayerItem(client, Handle:db, itemid, amount, String:steamid[], Table:tbl)
{
	if(isBot[client]) return;
	
	if(db == INVALID_HANDLE)
		return;
	
	new table = _:tbl;
	
	new String:query[200];
	
	if(!LoadedItem(client, itemid))
	{
		Format(query, sizeof(query), "INSERT INTO %s (steamid, itemid, amount) VALUES ('%s', %d, %d);", tables[table], steamid, itemid, amount);
		loadedItem[client][itemid] = true;
	}
	else
		Format(query, sizeof(query), "UPDATE %s SET amount=%d WHERE steamid='%s' AND itemid=%d", tables[table], amount, steamid, itemid);
		
	SQL_TQueryEx(db, ErrorOnlyCallback, query);
}	
/*
public RowAffectedCallBack(Handle:datab, Handle:hQuery, const String:error[], any:data)
{
	if(StrContains(error, "Duplicate", false) == -1)
		if(SQLError(datab, error))
			RetryQuery(datab, RowAffectedCallBack, data, error);

	new String:field[20], String:steamid[32], String:query[300];
	KvGetString(Handle:data, "field", field, sizeof(field), "NULL");
	KvGetString(Handle:data, "steamid", steamid, sizeof(steamid), "NULL");
	new client = KvGetNum(Handle:data, "client");
	new value = KvGetNum(Handle:data, "value");
	new table = KvGetNum(Handle:data, "table");
	
	if(StrContains(error, "Duplicate", false) != -1)
	{
		PrintToServer("Duplicate key found. Using UPDATE instead.");
		Format(query, sizeof(query), "UPDATE %s SET %s=%d WHERE steamid='%s'", tables[table], field, value, steamid);
		useUpdate[client][table] = true;
		SQL_TQueryEx(datab, ErrorOnlyCallback, query);
	} else {
		if(SQL_GetAffectedRows(datab) <= 0)
		{
			PrintToServer("No rows affected. Using INSERT instead.");
			Format(query, sizeof(query), "INSERT INTO %s (steamid, %s) VALUES ('%s', %d);", tables[table], field, steamid, value);
			useUpdate[client][table] = false;
			SQL_TQueryEx(datab, ErrorOnlyCallback, query);
		}
	}
	
	CloseHandle(Handle:data);
}
*/
public CheckExistence(Handle:db, client)
{
	if(isBot[client]) return;
	
	if(db == INVALID_HANDLE)
		return;
		
	new String:query[150], String:sid[32];
	
	GetClientAuthString(client, sid, sizeof(sid));
	
	Format(query, sizeof(query), "SELECT Bank FROM %s WHERE steamid='%s'", tables[T_MAIN], sid);
	
	SQL_TQuery(db, exsistencecb, query, client);
}

public exsistencecb(Handle:datab, Handle:hQuery, const String:error[], any:client)
{
	if(SQL_GetRowCount(hQuery) > 0)
	{
		PrintToServer("Using UPDATE on client %d", client);
		useUpdate[client][T_MAIN] = true;
	} else
		PrintToServer("Using INSERT on client %d", client);
		
}

public bool:HasItem(client, itemid)
{
	return Item[client][itemid] > 0;
}

public bool:LoadedItem(client, itemid)
{
	return loadedItem[client][itemid];
}

//This gets called from public ComaxClientPutInServer(Client) in comaxrpmod.sp
public ComaxSQL_ConnectConnect(client)
{
	CheckExistence(h_database, client);
}

//This gets called from public ComaxClientDisconnect(Client) in comaxrpmod.sp
public ComaxSQL_ClientDisconnect(client)
{
	for(new i = 0; i < MAXITEMS;i++)
		loadedItem[client][i] = false;
		
	for(new i = 0; i < sizeof(tables);i++)
		useUpdate[client][i] = false;
}


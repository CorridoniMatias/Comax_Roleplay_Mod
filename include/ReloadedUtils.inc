/*
	Reloaded's Utils by Elite| Reloaded.
	You can use and alter this code but you must give credit.
*/

#if defined utilsincluded
 #endinput
#endif
#define utilsincluded

new Handle:g_maxretries = INVALID_HANDLE;

enum PrecacheType {
	PT_Null,
	PT_Materials,
	PT_Models,
	PT_Sounds
};

/**
 * Adds all the files in the desired folder to the downloads table. 
 * @note				---Not yet tested on post Steam Pipe games.---
 * @note				Never add the last / of the path to the parameter.
 * @note				Precache ONLY if all the files in the dir are the same type.
 * @param path			Path to the folder.
 * @return				true on success; false on fail
 */
 stock bool:AddFolderToDownloadsTable(String:path[], bool:precache=false, PrecacheType:type = PT_Null)
 {
	new Handle:hModelDownloadPath = OpenDirectory(path);
	new String:sFileNameInDir[40], String:Formatdownload[200];
	if(hModelDownloadPath != INVALID_HANDLE)
	{
		while(ReadDirEntry(hModelDownloadPath, sFileNameInDir, sizeof(sFileNameInDir))) {
			if(!StrEqual(sFileNameInDir, ".") && !StrEqual(sFileNameInDir, ".."))
			{
				Format(Formatdownload, sizeof(Formatdownload), "%s/%s", path, sFileNameInDir);
				AddFileToDownloadsTable(Formatdownload);
				if(precache && !StrEqual(type, "UNASS"))
				{
					if(type == PT_Materials || type == PT_Models)
					{
						PrecacheModel(Formatdownload, true);
					} else if(type == PT_Sounds)
					{
						PrecacheSound(FormatDownload, true);
					}
				}
			}
		}
		return true;
	} else {
		PrintToServer("ReloadedsUtils::AddFolderToDownloadsTable: Unable to open path '%s'", path)
		return false;
	}
 }
 
 /**
 * Generates a new string based on an already existing string starting on a certain position.
 * @param orig		Original string to scan and copy from.
 * @param pos 		Position to start copying from.
 * @param dest		Destination string.
 * @param max_size	Size of the destination string.
 *
 * @return 			No return.
 **/
 
 public SubStr(String:orig[], pos, String:dest[], max_size)
{
	Format(orig, strlen(orig), "%s", orig[pos]);
	
	strcopy(dest, max_size, orig);
}
 

 /**
 * Merges two different KeyValues into one.
 * @param kv			Handle to the KeyValues to write to.
 * @param akv			Handle to the KeyValues to read from.
 * @return				No return.
 */

public KvMerge(Handle:kv, Handle:akv)
{
	if(akv != INVALID_HANDLE)
	{
		if(KvGotoFirstSubKey(akv, false))
		{
			new String:temp[100], String:name[50];
			do
			{
				KvGetSectionName(akv, name, sizeof(name));
			
				if(StrEqual(name, "query") || StrEqual(name, "length")) continue; //If this is set, it will just get overwritten.
				
				
				//This would overwrite the important query data.
				new KvDataTypes:type = KvGetDataType(akv, NULL_STRING);
				
				if(type == KvData_None) 
					continue;
				
				else if(type == KvData_Int)
					KvSetNum(kv, name, KvGetNum(akv, NULL_STRING, -1));
				
				else if(type == KvData_String)
				{
					KvGetString(akv, NULL_STRING, temp, sizeof(temp), "NULL");
					KvSetString(kv, name, temp);
				}
			} while(KvGotoNextKey(akv, false));
		}
	}
}

 /**
 * Determines whether if the query was successful or not.
 * @param datab			Handle to the Database (-NOT- the query).
 * @param str			Error string returned from the query. If query was not threaded Format using SQL_GetError().
 * @return				True on error, false otherwise.
 */
 
 public bool:SQLError(Handle:datab, const String:str[])
{
	if(datab == INVALID_HANDLE || !StrEqual(str, ""))
		return true;	
	return false;
}

 /**
 * Returns the SQL query compressed in a KeyValues handle.
 * @param data			Handle to the KeyValues.
 * @param squery		String to copy the query to.
 * @param len			The length of squery. It is recommended that you set the size of squery to SQLGetQueryLength().
 * @return				No return.
 */

public SQLGetQuery(any:data, String:squery[], len)
{
	new Handle:kv = Handle:data;
	new String:query[len + 2];
	KvGetString(kv, "query", query, len + 2, "NULL");
	strcopy(squery, len + 2, query);
}

 /**
 * Returns the SQL Query length compressed in a KeyValues handle.
 * @param data			Handle to the KeyValues.
 * @return				The Query length.
 */

public SQLGetQueryLength(any:data)
{
	new Handle:kv = Handle:data;
	return KvGetNum(kv, "length", -1);
}

 /**
 * Returns how many times the query has been retried.
 * @param data			Handle to the KeyValues.
 * @return				The number of retries.
 */

public SQLGetRetries(any:data)
{
	new Handle:kv = Handle:data;
	return KvGetNum(kv, "retries", -1);
}


 /**
 * Compresses the SQL Query to KeyValues and sends as the 'data' param.
 * @note	 Only use if you are going to send the Query to the callback for further queries. Use SQL_TQuery() instead.
 * @note	 akv cannot contain the key "query" or "length".
 * @note	 It is -HIGHLY- recommended to CloseHandle() the KeyValues Handle when not used anymore.
 * @param data			Handle to the KeyValues.
 * @param callback		Callback to send to SQL_TQuery().
 * @param query			SQL Query to process.
 * @param akv			Handle to the KeyValues that contain data that should be sent to the callback.
 * @return				No return.
 */
 
SQL_TQueryEx(Handle:datab, SQLTCallback:callback, String:query[], Handle:akv = INVALID_HANDLE)
{
	new Handle:kv = CreateKeyValues("data");
	KvMerge(kv, akv);
	KvSetString(kv, "query", query);
	KvSetNum(kv, "length", strlen(query));
	SQL_TQuery(datab, callback, query, kv);
	//CloseHandle(kv);
}

/**
 * Retries an SQL Threaded Query.
 * @param data			Handle to the KeyValues.
 * @param callback		Callback to send to SQL_TQuery().
 * @param data			Data Handle that contains the KeyValues. Just type data if you're calling from a threaded query callback.
 * @param error			Error to print to the server. Optional.
 * @return				No return.
 */

RetryQuery(Handle:datab, SQLTCallback:callback, any:data, const String:error[] = "")
{
	decl length;
	length = SQLGetQueryLength(data);
	new String:query[length];
	SQLGetQuery(data, query, length);
	
	if(g_maxretries != INVALID_HANDLE)
	{
		decl retries;
		retries = SQLGetRetries(data);
		if(retries == -1)
			KvSetNum(Handle:data, "retries", 1);
		//Marked as OPTIONAL. Uncomment to enable maxretries. PS: You must create g_maxretries.
		else if(retries > GetConVarInt(g_maxretries))
		{
			LogError("Query failed after %d retries: %s. ERROR: %s", retries, query, error);
			CloseHandle(Handle:data);
			return;
		}

		else
			KvSetNum(Handle:data, "retries", retries + 1);
	}
	
	//marked as optional. Uncomment if you want to have error logs.
	//PrintToServer("CALLBACK::ERROR ----\nError: %s.\nQuery: %s\nForcing Retry...", error, query);
	SQL_TQueryEx(datab, callback, query, Handle:data);
	
}

/**
 * PreCoded Callback that only retries a query if it fails.
 * @note		Usage: SQL_TQueryEx(database, ErrorOnlyCallback, query); <- This is just an example.
 * @return				No return.
*/
public ErrorOnlyCallback(Handle:datab, Handle:hQuery, const String:error[], any:data)
{
	/*if(SQLError(datab, error))
		RetryQuery(datab, ErrorOnlyCallback, data, error);
	else*/
	CloseHandle(Handle:data);
	
}

//If you're editing this please give credits. Thank you.
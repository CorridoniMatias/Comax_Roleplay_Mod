/*	Time extension for Comax RP Mod.
*	@author	Reloaded.
*/

new ServerHour;
new ServerMinute;
new AM;
new TimeLeftT;

public ComaxTime()
{
	RegAdminCmd("sm_minutes", CommandSetMins, ADMFLAG_ROOT, "Set minutes");
	CreateTimer(1.2, ClockTick);
	decl String:ComaxTimeFormatted[55];
	decl String:TimeBuffer[3][55];
	FormatTime(ComaxTimeFormatted, sizeof(ComaxTimeFormatted), "%I:%M:%p", GetTime());//%S = secs
	ExplodeString(ComaxTimeFormatted, ":", TimeBuffer, 3, 55);
	ServerHour = StringToInt(TimeBuffer[0]);
	ServerMinute = StringToInt(TimeBuffer[1]);
	AM = (StrEqual(TimeBuffer[2], "AM")) ? true : false;
	RegAdminCmd("sm_settime", Command_SetTime, ADMFLAG_ROOT, "Set the time for server");
}

//Goes under DisplayHud(Handle:Timer, any:Client) after the first if statement.
public ShowClock(Client)
{
	decl String:Display[32];
	if(AM)
	{
		Display = "AM";
	} 
	else
	{
		Display = "PM";
	}
	
	SetHudTextParams(-1.0, 0.9, 1.2, 100, 150, 150, 255, 0, 6.0, 0.1, 0.2);
	if(ServerMinute < 10)
	{
		ShowHudText(Client, -1, "Time: %d : 0%d  %s", ServerHour, ServerMinute, Display);
	}
	else
	{
		if(ServerHour == 6 && ServerMinute > 24 && ServerMinute < 31 && !AM)
		{
			SetHudTextParams(-1.0, 0.9, 1.2, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
			switch(ServerMinute)
			{
				case 25: TimeLeftT = 5;
				case 26: TimeLeftT = 4;
				case 27: TimeLeftT = 3;
				case 28: TimeLeftT = 2;
				case 29: TimeLeftT = 1;
				case 30: TimeLeftT = 0;
			}
			if(TimeLeftT > 0)
			{	
				ShowHudText(Client, -1, "Time: %d : %d  %s\nWarning: Stats will be uploaded in %d minutes! beware of massive lag during the upload!", ServerHour, ServerMinute, Display, TimeLeftT);
			} else if(TimeLeftT == 0) {
				ShowHudText(Client, -1, "Time: %d : %d %s\nWarning: Stats are now being uploaded! beware of massive lag during the upload! This process takes 5 minutes!", ServerHour, ServerMinute, Display);
			}
		} else {
			ShowHudText(Client, -1, "Time: %d : %d  %s", ServerHour, ServerMinute, Display);
		}
	}
}

public Action:ClockTick(Handle:Timer)
{

	RestartTick();
	
	
	//STATS UPLOADER//
	
	/*if(ServerHour == 6 && ServerMinute == 29 && !AM) // we use 29 because the minutes++ is at the end
	{	
		ForceStatsUpload(1);
	}*/
	
	if(ServerMinute == 59)
	{
		if(ServerHour == 11)
		{
			if(AM)
			{
				AM = false;
			}
			else
			{
				AM = true;
			}
		}
		
		if(ServerHour == 12)
		{
			ServerHour = 1;
			ServerMinute = 0;
			CreateTimer(60.0, ClockTick);
			return Plugin_Handled;
		}
		
		ServerHour += 1;
		ServerMinute = 0;
		CreateTimer(60.0, ClockTick);
		return Plugin_Handled;
	}
	
	ServerMinute += 1;
	
	CreateTimer(60.0, ClockTick);
	return Plugin_Handled;
}


public Action:Command_SetTime(client, args) {
	if(args < 1)
	{
		PrintToConsole(client, "[SM] Usage: sm_settime <hour> <minute> <AM/PM (Use Capital letters)>");
		PrintToConsole(client, "[SM] NOTE: If you want to set it to the default server time type sm_settime default 0 0");
		return Plugin_Handled;
	}
	if(args < 2)
	{
		PrintToConsole(client, "[SM] Please enter the minutes!");
		return Plugin_Handled;
	}
	if(args < 3)
	{
		PrintToConsole(client, "[SM] AM or PM?");
		return Plugin_Handled;
	}
	
	new String:arg1[32], String:arg2[32], String:arg3[3];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	
	if(StrEqual(arg1, "default"))
	{
		decl String:ComaxTimeFormatted[55];
		decl String:TimeBuffer[3][55];
		FormatTime(ComaxTimeFormatted, sizeof(ComaxTimeFormatted), "%I:%M:%p", GetTime());//%S = secs
		ExplodeString(ComaxTimeFormatted, ":", TimeBuffer, 3, 55);
		ServerHour = StringToInt(TimeBuffer[0]);
		ServerMinute = StringToInt(TimeBuffer[1]);
		AM = (StrEqual(TimeBuffer[2], "AM")) ? true : false;
		return Plugin_Handled;
	}
	
	new hour = StringToInt(arg1);
	new minutes = StringToInt(arg2);
	
	if(StrEqual(arg3, "PM")) {
		AM = false;
		ServerHour = hour;
		ServerMinute = minutes;
	} else if(StrEqual(arg3, "AM")) {
		AM = true;
		ServerHour = hour;
		ServerMinute = minutes;
	} else {
		PrintToConsole(client, "[SM] AM or PM please in capital letters!");
		return Plugin_Continue;
	}
	
	return Plugin_Handled;
}
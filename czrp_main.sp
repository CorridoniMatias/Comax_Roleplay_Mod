//Original Roleplay v2.4 by Joe 'Pinkfairie' Maley and Krim
//Revised by [GR]Nick 3.2.6n
//Re-Revised by EasSide[-ZZ-]
//Comax RolePlay Mod by Reloaded

/* CHANGELOG ->
	* 4.2 - First stable release
*/

//Includes:
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <morecolors>
#include <smlib>
#include <ReloadedUtils>


//Stocks:
#include "rp_stocks"

//Terminate:
#pragma semicolon 1

//Comax Defines:
#define RPVERSION "5.0.0.0"
#define DEBUG 1 //THIS SHOULD REMAIN TO 0 UNLESS YOU'RE TESTING!

//Comax: VIP
#define DONATORSJOB "Donator - VIP"
#define SDONATORSJOB "Super Donator - VIP"
#define VIP_LEVEL_BASIC		1
#define VIP_LEVEL_SUPER		2


//========================================================
//Easy Setups
//========================================================

//1 = Red
//2 = Orange
//3 = Green
//4 = Blue
//5 = Purple
//6 = White
//7 = Gold - The original rp color

//Hud Start Colors
#define DEFAULTMAINHUDCOLOR	2
#define DEFAULTCENTERHUDCOLOR	2

//Suicide Menu Names
#define	SUICIDEONE	"-|Execution Order 001|-"
#define SUICIDETWO	"-|Execution Order 002|-"

//Afk Room Name
#define	AFKROOM		"-|Afk Room|-"
//========================================================
//Easy Setups
//========================================================


//Jetpack (Credits to Knagg0)
//==================
#define MOVETYPE_WALKJETPACK			2
#define MOVETYPE_FLYGRAVITYJETPACK		5
#define MOVECOLLIDE_DEFAULTJETPACK		0
#define MOVECOLLIDE_FLY_BOUNCEJETPACK	1
#define LIFE_ALIVE	0
new Handle:sm_jetpack			= INVALID_HANDLE;
new Handle:sm_jetpack_speed		= INVALID_HANDLE;
new Handle:sm_jetpack_volume	= INVALID_HANDLE;
new g_iLifeState	= -1;
new g_iMoveCollide	= -1;
new g_iMoveType		= -1;
new g_iVelocity		= -1;
new String:g_sSound[255]	= "vehicles/airboat/fan_blade_fullthrottle_loop1.wav";
new bool:g_bJetpacks[MAXPLAYERS + 1]	= {false,...};
new Float:g_fTimer	= 0.0;
new g_iMaxClients	= 0;
//================

//Defaults:
#define DEFAULTMONEY	5000
#define DEFAULTBANK	0
#define DEFAULTWAGES	2

//If you change this default job name, you must also change the job name (id 20) in the data/roleplay/jobs.txt
#define DEFAULTJOB	"Unemployed"

#define DEFAULTGANG "Gang Member"
#define DEFAULTGANGLEADER "Gang Leader"

//Misc:
#define PAYCHECKTIMER	60
#define HUDTICK		1.2
#define	MAXJOBS		1000
#define MAXITEMS	1100
#define	MAXDOORS  4128
#define MAXNPCS	100
#define MAXCARS	50
#define MAXGAMBLING	75
#define MAXCRIMEZONES	100
new NPCList[MAXNPCS];
new NPCListInverse[4000];
new NPCLiveUpdate[15][2048];
#define bits_SUIT_DEVICE_SPRINT	0x00000001

new String:Noticeadd[128];
new String:DoorBuyPath[128];
new String:DoorPathadd[128];
#define NOTBUYABLE	0
#define BUYABLE	1
#define SALEABLE	2
#define NOAMOUNT	"0"
#define ERROR	"Error Amount"
#define NOONE	"noone"

//Cvars:
new Handle:ExperienceMode = INVALID_HANDLE;
new Handle:CuffCrime = INVALID_HANDLE;
new Handle:CrimeJail = INVALID_HANDLE;
new Handle:TaxiCrime = INVALID_HANDLE;
new Handle:RobMode = INVALID_HANDLE;
new Handle:StarterPackMode = INVALID_HANDLE;
new Handle:FireFighterMode = INVALID_HANDLE;
new Handle:FireFighterTeam = INVALID_HANDLE;
new Handle:FireFighterChiefMode = INVALID_HANDLE;
new Handle:PlayerWeekMode = INVALID_HANDLE;
new Handle:Locks = INVALID_HANDLE;
new Handle:CrimeMenuAmt = INVALID_HANDLE;
new Handle:CrimeMenuSet = INVALID_HANDLE;
new Handle:CombineTeam = INVALID_HANDLE;
new Handle:RebelTeam = INVALID_HANDLE;
new Handle:Deduction = INVALID_HANDLE;
new Handle:CategoryInv = INVALID_HANDLE;
new Handle:SaveClientJobs = INVALID_HANDLE;
new Handle:AllowSwitch = INVALID_HANDLE;
new Handle:DrugWorth = INVALID_HANDLE;
new Handle:DrugProb = INVALID_HANDLE;
new Handle:RebelKillRebel = INVALID_HANDLE;
new Handle:RebelKillCombine = INVALID_HANDLE;
new Handle:MaxPlants = INVALID_HANDLE;


//HUD:
new Money[33];
new Bank[33];
new Neg[33];
new Wages[33];
new Paycheck[33];
new String:Job[33][255];
new String:OrgJob[33][255];
new Minutes[33];
new Crime[33];
//new PropLimit[45];
new TimeConverter[33];
new NumChecks[33];
new PoliceMedHeal[33];
new Override[33];
new AfkClient[33];
new OwnsCar[33][51];
new CarEntity[2001];
new LockedCar[2001];
new SkinDoor[2001];
new CatalogDoor[2001];
new CatalogDoorInverse[101];
new HudModeMain[33];
new HudModeCenter[33];
new RedCrimeMenu[33];
new Probation[33];
new RandomTiming[33];
new WeaponOffset;
new CuffCount[206];
new ExpLevel[1024];
new Planted[400];

//Drugs

new Grams[33];



new CurrentNum[33];
new String:CurrentSound[33][60][64];

new ExpRebel[33];
new ExpCombine[33];
new ExpCombineCheck[33];
new NoKill[33];
new NoCrime[33];
new UncuffStop[33];
new MainHudColor[33];
new CenterHudColor[33];
new TourGuide[33];
new WeaponEq[MAXPLAYERS + 1] = {0,...};

new Float:NoKillZones[101][3];
new Float:NoCrimeOrigin[MAXCRIMEZONES + 1][3];

new Float:TeleStartOrigin[33][3];
new Float:TeleEndOrigin[33][3];

new Float:DrugPlant[33][10][3];
new DrugPlantWorth[33][10];
new DrugEnt[33][10];



//Printers!


new bool:InJailC[33];

//Menus:
new MenuTarget[33];
new SelectedBuffer[7][33];

//Items:
new ItemCost[MAXITEMS] = {-1, ...};
new bool:IsGiving[33];
new ItemAmount[2048][MAXITEMS];
new SelectedItem[33];
new Item[33][MAXITEMS];
new String:ItemName[MAXITEMS][255];
new ItemAction[MAXITEMS];
new String:ItemVar[MAXITEMS][255];
new bool:DoorLocked[MAXDOORS]; 
new DoorLocks[MAXDOORS] = 0;
new TickId[33];
new RaffleWin[33];
new BombData[2001][6];
new TrailAmount[33];
new TrailSpam[33];
new GodMode[33];

//Drugs:
new UserMsg:FadeID;
new UserMsg:ShakeID;
new DrugTick[33];
new DrugHealth[33];
new Float:DrugSpeed[33]; 

//Robbing:
new RobCash[33];
new Float:RobOrigin[33][3];
new Float:RobTimerBuffer[3][100];
new Float:lastpressedSH[33];
new Float:lastpressedE[33]; 
new pressedE[33];
new kopfgeld[33];  
new bool:AutoBounty[33];
new bool:LooseMoney[33];

//Law:
new Float:JailOrigin[11][3];
new Float:VIPJailOrigin[3];
new Float:ExitOrigin[3];
new Float:AFKOrigin[3];
new Float:GarbageOrigin[3];
new Float:OrderOrigin[3];  
new Float:OrderOrigin2[3];
new bool:IsCuffed[33];
new CuffColor[4] = {0, 0, 255, 200};
//new Float:TimeInJail[33];
new FreeIn[33];
//new Float:Autofree[33]; 
new Float:lastspawn[33]; 
new bool:GetFree[33];
new bool:killOrder[33];

//Databases:
new Handle:SaveVault = INVALID_HANDLE;
new String:NPCPath[128];
new String:JobPath[128];
new String:SavePath[128];
new String:ConfigPath[128];
new String:ItemPath[128];
new String:LockPath[128]; 
new String:DownloadPath[128];
new String:NamePath[128];
new String:ZonesPath[128];
new String:TaxiPath[128];
new String:NoticePath[128];
new String:CarPath[128];
new String:StarterPath[128];
new String:RulesPath[128];
new String:DoorPath[128];
new String:PlayerWeekPath[128];
new String:RoulettePath[128];
new String:RouletteOrigins[128];
new String:CrimeZonesPath[128];
new String:JobAttributesPath[128];
new String:WeaponidsPath[128];
new String:WeaponArray[30][255];



//Misc:
new bool:PrethinkBuffer[33] = false;
new DroppedMoneyValue[2048];
new GlobalVendorId[33];
new ExploitJail[33];
new Float:LockTime[33];
new Float:HackTime[33];
new Float:SawTime[33];
new Float:ScannerTime[33];
new Float:InterruptTime[33]; 
new bool:Loaded[33];
new Prune[33];
new LaserCache;
new bool:EnableTracers[33];
new Float:AuctItems[7] = 1.0;
new Float:AuctVendor = 1.0;
new InternalFrags[33];
new GPS[33][33];
new String:Notice[MAXDOORS][255];
new AnyJail;
new AnySui1;
new AnySui2;
new AnyExit;
new AnyVip;
new AnyAfk;
new AnyGarbage;
new WaterGun[33];
new GarbageAmount;
new SolidGroup;
new String:JoinMessage[512] = "Welcome^Find an Employer to^Select a Job and^Begin Playing!";
new String:Lines[11][255];
new String:PlayerModel[33][255];
new bool:Stealth[33];
new EquipSpam[33];
new Hitman[33];
new HitmanBuyer[33];
new HitmanTimer[33];
new Bribe[33];
new BribeAmt[33];
new SalesMan[33];
new bool:PermitJetpack[33];

//Gambling:
new WheelNumber[38];
new WheelColor[38];
new WheelNumberType[38];
new Float:GamblingOrigin[MAXGAMBLING + 1][3];
new String:GamblingOwner[MAXGAMBLING + 1][255];
new String:GamblingOwnerName[MAXGAMBLING + 1][255];
new RouletteBalance[MAXGAMBLING + 1];
new Casino[MAXGAMBLING + 1];
new CasinoMaxBet[MAXGAMBLING + 1];
new WheelPosition[33];
new WheelMode[33];
new BettingProtection[33];

//Effects
new g_BeamSprite;
new g_HaloSprite;
new Smoke;
new Water;
new whiteColor[4] = {255, 255, 255, 255};
new greyColor[4] = {128, 128, 128, 255};
new TickerColor[4] = {255, 0, 0, 255};
new TickerColor2[4] = {255, 255, 0, 255};
new TickerColor3[4] = {0, 255, 0, 255};
new WaterColor[4] = {0, 255, 255, 255};
new TourColor[4] = {215, 215, 20, 255};
new TeleColor1[4] = {0, 255, 0, 255};
new TeleColor2[4] = {255, 0, 0, 255};
new PinkColor[4] = {255, 128, 255, 255};

/************************************************************/
/*	COMAX ROLEPLAY MOD RELATED VARIABLES --- DO NOT TOUCH!	*/

//Errors
new String:COMAX_ERRORS[85];

//Game Time

//PICKPOCKETING MOD


// Custom Models //

// Stats

//Also using existing vars: Jobs, bank money, pocket moeny


//Mod protector:
new AllowedServer;

//cars vars.

//Stability

//VIP doors

//Game Desc.

//Comax HUD
new Handle:h_showhud = INVALID_HANDLE;

//Printers

/* ***********************************************************/

//Game Description. Thanks to ROFLCopter Mod




//Cars Mod by Reloaded. This Addon *-REQUIRES-* VehicleMod Addon.
//Gas Stations
//Cars

//Stats Plugin by Reloaded.


//Custom Models by Reloaded.

new bool:isBot[32] = {false,...};

//Comax is loaded here so it can see all the mod variables.
#include "/ComaxRolePlayMod/vars.sp" //Must be the first file to include
#include "/ComaxRolePlayMod/moneyprinters.sp"
#include "/ComaxRolePlayMod/gasmod.sp"
#include "/ComaxRolePlayMod/cars.sp"
#include "/ComaxRolePlayMod/models.sp"
#include "/ComaxRolePlayMod/sqlhandler.sp"
#include "/ComaxRolePlayMod/limiter_back2inv.sp"
#include "/ComaxRolePlayMod/stats.sp"
#include "/ComaxRolePlayMod/vipdoors.sp"
#include "/ComaxRolePlayMod/pickpocket.sp"
#include "/ComaxRolePlayMod/time.sp"
#include "/ComaxRolePlayMod/stability.sp"
#include "/ComaxRolePlayMod/comaxrpmod.sp" //Must be the first last to include




public Action:Command_ModAbout(client, args) 
{
	PrintToChat(client, "\x01[Comax] Comax RolePlay Mod, by [GR|CMX] Reloaded. Version: %s. Check console for propper formatting.", RPVERSION);
	PrintToChat(client, "|===========================================================|");
	PrintToChat(client, "|=================== Comax RolePlay Mod ====================|");
	PrintToChat(client, "|All of the new features were coded by Reloaded:			 |");
	PrintToChat(client, "|PickPocketing Mod, Money Printers, Clock, Custom Models,   |");
	PrintToChat(client, "|Clients' stats, Cars System.				     		     |");
	PrintToChat(client, "|Copyright 2011 - 2013  The Comax Team. All rights reserved.|");
	PrintToChat(client, "|=================== Comax RolePlay Mod ====================|");
	PrintToChat(client, "|===========================================================|");
	new String:Message[600];
	
	Message = "Comax RolePlay Mod by Reloaded\nNew Features: PickPocketing Mod, Money Printers, Clock, Custom Models,Clients' stats, Cars System.\nCopyright 2011 - 2013 The Comax Team. All rights reserved.";
	
	new Handle:Kv = CreateKeyValues("menu");
	KvSetString(Kv, "title", "About Comax");
	KvSetNum(Kv, "level", 1);
	KvSetString(Kv, "msg", Message);
	CreateDialog(client, Kv, DialogType_Text);
	CloseHandle(Kv);
	return Plugin_Handled;
}

public Action:CommandDebugJail(client, args)
{
	if(args < 1)
	{
		PrintToConsole(client, "insert client");
		return Plugin_Handled;
	}
	new String:arg1[50];
	
	GetCmdArg(1, arg1, 50);
	
	new Target = FindTarget(client, arg1);
	new String:name[MAX_NAME_LENGTH];
	if(Target == -1)
	{
		PrintToConsole(client, "[SM] The ban has not been recorded.");
		return Plugin_Handled;
	}	
	GetClientName(Target, name, sizeof(name));
	
	
	Crime[Target] = 5000;
	
	PrintToConsole(client, "Set crime to %d (%s) to %s", Crime[Target], arg1, name);
	PrintToChat(Target, "Admin set ur crine to %d (%s), ur name: %s", Crime[Target], arg1, name);
	
	Cuff(Target);
	Jail(Target, 1);
	
	return Plugin_Handled;
}

public Action: CommandVipSwitch(Client, args)
{
	if((GetVipLevel(Client) == VIP_LEVEL_BASIC || GetVipLevel(Client) == VIP_LEVEL_SUPER) && !StrEqual(Job[Client], DONATORSJOB)) {
		ForcePlayerSuicide(Client);
		PrintToChat(Client, "[Comax] Changing into Donator Mode...");
		Job[Client] = DONATORSJOB;
	} else if((GetVipLevel(Client) == VIP_LEVEL_BASIC || GetVipLevel(Client) == VIP_LEVEL_SUPER) && StrEqual(Job[Client], DONATORSJOB)) {
		ForcePlayerSuicide(Client);
		PrintToChat(Client, "[Comax] Changing into Player Mode...");
		//OrgJob[Client] = Job[Client];
		Job[Client] = DEFAULTJOB;
	} else if(GetVipLevel(Client) == 0) {
		PrintToChat(Client, "[Comax] You're not a Donator, type !donate in chat for more info.");
	}
	return Plugin_Handled;
}

public Action: CommandSVipSwitch(Client, args)
{
	if(GetVipLevel(Client) == VIP_LEVEL_SUPER && !StrEqual(Job[Client], SDONATORSJOB)) {
		PrintToChat(Client, "[Comax] Changing into Super Donator Mode...");
		Job[Client] = SDONATORSJOB;
	} else if(GetVipLevel(Client) == VIP_LEVEL_SUPER && StrEqual(Job[Client], SDONATORSJOB)) {
		PrintToChat(Client, "[Comax] Changing into Player Mode...");
		//OrgJob[Client] = Job[Client];
		Job[Client] = DEFAULTJOB;
	} else if(GetVipLevel(Client) < 2) { // < 2 means basic vip or no vip at all.
		PrintToChat(Client, "[Comax] You're not a Super Donator, type !donate in chat for more info.");
	}
	return Plugin_Handled;
}

public Action:CommandSetMins(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[Comax] Type user name");
		return Plugin_Handled;
	}
	if(args < 2)
	{
		ReplyToCommand(client, "[Comax] Type minutes");
		return Plugin_Handled;
	}
	
	new String:arg1[30], String:arg2[30];
	GetCmdArg(1, arg1, sizeof(arg1));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	new Target = FindTarget(client, arg1, true, false);
	if(Target == -1)
	{
		ReplyToCommand(client, "[Comax] Player not found!");
		return Plugin_Handled;
	}
	
	Minutes[Target] = StringToInt(arg2);
	PrintToChat(client, "[Comax] Set minutes to %s(%d)", arg2, StringToInt(arg2));
	PrintToChat(Target, "[Comax] An admin set your minutes to %s(%d)", arg2, StringToInt(arg2));
	return Plugin_Handled;
}

public Action:commandrestartmap(client, args)
{
	if(GetConVarInt(h_showhud) == 1)
	{
		new String:CMap[64];
		GetCurrentMap(CMap, sizeof(CMap));
		SavePlayersPosition();
		
		SetConVarInt(h_showhud, 0);
		ShowClosingEffects();
		
		ServerCommand("wait 500;changelevel %s", CMap);
		PrintToChatAll("[Comax] An admin has triggered map restart, restarting in 500 frames! (~ 4 -> 5 seconds)");
	}
	return Plugin_Handled;
}


//DON'T TOUCH THIS!!




//Comax RolePlay Mod made by Reloaded. Original mod by Nick. CMXEND

public Action:Command_initnotice(Client,Arguments)
{
	decl Ent;
	//Arguments:
	if(Arguments < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_initnotice <Ent> <String>");
		
		//Return:
		return Plugin_Handled;
	}
	
	decl String:Text[255],String:EntName[32];
	GetCmdArg(1, EntName, sizeof(EntName));
	GetCmdArg(2, Text, sizeof(Text)); 
	Ent = StringToInt(EntName);
	Notice[Ent] = Text;
	return Plugin_Handled; 
}

public Action:CommandKickOpen(Client, Args)
{
	if(Client == 0)
	{
		return Plugin_Handled;
	}
	
	if(IsCombine(Client))
	{
		new DoorEnt;
		decl String:ClassName[64];
		
		DoorEnt = GetClientAimTarget(Client, false);
		GetEdictClassname(DoorEnt, ClassName, sizeof(ClassName));
		new Float:Dist;
		new Float:ClientOrigin[3];
		new Float:EntOrigin[3];
		GetClientAbsOrigin(Client, ClientOrigin);
		GetEntPropVector(DoorEnt, Prop_Send, "m_vecOrigin", EntOrigin);
		Dist = GetVectorDistance(ClientOrigin, EntOrigin);
		if(Dist <= 300.0)
		{
			if(DoorLocks[DoorEnt] < 1)
			{
				AcceptEntityInput(DoorEnt, "Unlock", Client);
				ServerCommand("sm_justpicked %d %d", DoorEnt, Client);
				CPrintToChat(Client, "{white}|RP| -{grey} Door has been opened");
				AddCrime(Client,240);
			}
			
			if(DoorEnt > 2)
			{
				if(DoorLocked[DoorEnt])
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You can't kick this door.");
				}
				else
				{
					//Doors:
					if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
					{
						if(DoorLocks[DoorEnt] < 1)
						{
							AcceptEntityInput(DoorEnt, "Unlock", Client);
							if(StrEqual(ClassName, "func_door_rotating"))
								AcceptEntityInput(DoorEnt, "Open", Client);
							if(StrEqual(ClassName, "func_door"))
								AcceptEntityInput(DoorEnt, "Toggle", Client);
							ServerCommand("sm_kickdoor %d %d", DoorEnt, Client);
							Bank[Client] -= 1000;
							CPrintToChat(Client, "{white}|RP| -{grey} You kick open the door, and were charged $1,000 for damages.");
							Save(Client);
							
						}
						else
						{
							CPrintToChat(Client, "{white}|RP| -{grey} This door has extra locks.");
						}
					}
				}
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Please look at a door.");
			}
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You are too far away from the target.");
		}
	}
	return Plugin_Handled;
}

public Action:Command_auctis(Client,Args)
{
	PrintToConsole(Client, "|RP| - Actual Price Modificators (%f):",AuctVendor);
	for(new X = 0; X < 7; X++)
	{
		PrintToConsole(Client, "%d: %f",X,AuctItems[X]);
	}
	return Plugin_Handled;
}

public Action:Command_switchStealth(Client,Args)
{
	if(GetConVarInt(AllowSwitch) > 0)
	{
		if(IsCombine(Client) || IsFirefighter(Client))
		{
			Bribe[Client] = 0;
			BribeAmt[Client] = 0;
			CPrintToChat(Client, "{white}|RP| -{grey} Changing into Player Mode");
			OrgJob[Client] = Job[Client];
			Job[Client] = DEFAULTJOB;
			Stealth[Client] = true;
		}
		else if((StrContains(OrgJob[Client], "Police", false) != -1) || (StrContains(OrgJob[Client], "SWAT", false) != -1) || (StrContains(OrgJob[Client], "Firefight", false) != -1) || (StrContains(OrgJob[Client], "Admin", false) != -1))
		{
			if(Crime[Client] > 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You cannot switch when you have crime.");
			}
			else
			{
				Bribe[Client] = 0;
				BribeAmt[Client] = 0;
				CPrintToChat(Client, "{white}|RP| -{grey} Changing back to %s", OrgJob[Client]);
				Job[Client] = OrgJob[Client];
				if(IsCuffed[Client])
				{
					ForcePlayerSuicide(Client);
					Uncuff(Client);
				}
				Crime[Client] = 0;
				kopfgeld[Client] = 0;
				
				DynamicJobsRefresh(Client);
			}
		}
		else
		{
			if(StrEqual(Job[Client], "Probation", false) || StrEqual(Job[Client], "Asshole", false)) return Plugin_Handled;
			if(!StrEqual(Job[Client], DEFAULTJOB, false))
			{
				decl Handle:Check;
				Check = CreateKeyValues("Vault");
				FileToKeyValues(Check, JobPath);
				for(new c = 0; c < MAXJOBS; c++)
				{
					decl String:CheckId[255], String:CheckJob[255];
					IntToString(c, CheckId, 255);
					LoadString(Check, "1", CheckId, "Null", CheckJob);
					if(StrEqual(CheckJob, Job[Client], false))
					{
						if(Crime[Client] > 0)
						{
							CPrintToChat(Client, "{white}|RP| -{grey} You must have 0 crime to switch back to %s", OrgJob[Client]);
						}
						else if(IsCuffed[Client])
						{
							CPrintToChat(Client, "{white}|RP| -{grey} You cannot be cuffed while switching");
						}
						else
						{
							DynamicJobsRefresh(Client);
							Stealth[Client] = true;
							CPrintToChat(Client, "{white}|RP| -{grey} Switching to regular player.");
							OrgJob[Client] = Job[Client];
							Job[Client] = DEFAULTJOB;
							CloseHandle(Check);
							kopfgeld[Client] = 0;
							ForcePlayerSuicide(Client);
						}
						return Plugin_Handled;
					}
					else if(StrEqual(CheckJob, OrgJob[Client], false) && Stealth[Client] == true)
					{
						if(Crime[Client] > 0)
						{
							CPrintToChat(Client, "{white}|RP| -{grey} You must have 0 crime to switch back to %s", OrgJob[Client]);
						}
						else if(IsCuffed[Client])
						{
							CPrintToChat(Client, "{white}|RP| -{grey} You cannot be cuffed while switching");
						}
						else
						{
							DynamicJobsRefresh(Client);
							CPrintToChat(Client, "{white}|RP| -{grey} Switching back to %s.", OrgJob[Client]);
							Job[Client] = OrgJob[Client];
							Stealth[Client] = false;
							ForcePlayerSuicide(Client);
							kopfgeld[Client] = 0;
							CloseHandle(Check);
						}
						return Plugin_Handled;
					}
				}
				CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
				CloseHandle(Check);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You must have a job to use !switch.");
			}
		}
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Server has disabled this function.");
	}
	return Plugin_Handled;
}

public Action:Command_SetIncome(Client,Args)
{
	decl Player; 
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_setincome <USER> <MONEY>");
		return Plugin_Handled;      
	}
	if(Args == 2)
	{
		decl String:PlayerName[32];
		decl MaxPlayers; 
		decl String:Name[32];
		new Munny = 0; 
		decl String:Muny[32];
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));
		Munny = StringToInt(Muny);  
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
		}
		
		//Invalid Name:
		if(Player == -1)
		{
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
			//Return:
			return Plugin_Handled;
		}
		
		GetClientName(Client, Name, sizeof(Name));
		GetClientName(Player, PlayerName, sizeof(PlayerName));
		Minutes[Player] = RoundToCeil(Pow(float(Munny-1), 3.0));
		Wages[Player] = Munny;
		CPrintToChat(Client, "{white}|RP| -{grey} The wage of Player %s has been set to %d", PlayerName, Munny);
		CPrintToChat(Player, "{white}|RP| -{grey} Your wage is set to %d by %s", Munny, Name);
		Save(Player);
	}
	return Plugin_Handled;
}

public Action:Command_bountyall(Client,Args)
{
	decl MaxPlayers;
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		if(Crime[X] && !kopfgeld[X])
			addkopfgeld(X,1);
	}
	return Plugin_Handled;
}

public Action:Command_setGPSBug(Client,Args)
{
	decl Player,Player2; 
	if(Args < 3)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_gpsbug <USERTO> <USERFROM> <1|0>");
		return Plugin_Handled;      
	}
	if(Args == 3)
	{
		decl String:PlayerName[32];
		decl String:PlayerName2[32];
		decl MaxPlayers; 
		decl String:Level[32];
		decl String:Name[32];
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, PlayerName2, sizeof(PlayerName2));
		GetCmdArg(3, Level, sizeof(Level));
		new lvl = StringToInt(Level);  
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
			if(StrContains(Name, PlayerName2, false) != -1) Player2 = X;
		}
		
		//Invalid Name:
		if(Player == -1 || Player2 == -1)
		{
			
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client");
			
			//Return:
			return Plugin_Handled;
		}
		
		PrintToConsole(Client, "|RP| - GPS Bug %d -> %d : %d",Player2,Player,lvl);
		GPS[Player][Player2] = lvl;
	}
	return Plugin_Handled;
}

public Action:Command_setMoney(Client,Args)
{
	decl Player; 
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_setmoney <USER> <MONEY>");
		return Plugin_Handled;      
	}
	if(Args == 2)
	{
		decl String:PlayerName[32];
		decl MaxPlayers; 
		decl String:Name[32];
		new Munny = 0; 
		decl String:Muny[32];
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));
		Munny = StringToInt(Muny);  
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
		}
		
		//Invalid Name:
		if(Player == -1)
		{
			
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
			
			//Return:
			return Plugin_Handled;
		}
		
		GetClientName(Client, Name, sizeof(Name));
		GetClientName(Player, PlayerName, sizeof(PlayerName));
		
		Money[Player] = Munny; 
		PrintToConsole(Client, "|RP| - Set the money for %s to $%d", PlayerName,Munny);
		CPrintToChat(Player, "{white}|RP| -{grey} Your Money has been set to $%d by %s",Munny,Name); 
		Save(Player); 
	}
	return Plugin_Handled; 
}

public Action:Command_addMoney(Client,Args)
{
	decl Player; 
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_addmoney <USER> <MONEY>");
		return Plugin_Handled;      
	}
	if(Args == 2)
	{
		decl String:PlayerName[32];
		decl MaxPlayers; 
		decl String:Name[32];
		new Munny = 0; 
		decl String:Muny[32];
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));
		Munny = StringToInt(Muny);  
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
		}
		
		//Invalid Name:
		if(Player == -1)
		{
			
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
			
			//Return:
			return Plugin_Handled;
		}
		
		GetClientName(Client, Name, sizeof(Name));
		GetClientName(Player, PlayerName, sizeof(PlayerName));
		
		Money[Player] += Munny; 
		PrintToConsole(Client, "|RP| - Added money for %s: $%d", PlayerName,Munny);
		CPrintToChat(Player, "{white}|RP| -{grey} Your Money has been set to $%d by %s",Money[Player],Name);
		Save(Player); 
	}
	return Plugin_Handled; 
}

public Action:Command_setMoneyBank(Client,Args)
{
	decl Player; 
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_setmoneybank <USER> <MONEY>");
		return Plugin_Handled;      
	}
	if(Args == 2)
	{
		decl String:PlayerName[32];
		decl MaxPlayers; 
		decl String:Name[32];
		new Munny = 0; 
		decl String:Muny[32];
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));
		Munny = StringToInt(Muny);  
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
		}
		
		//Invalid Name:
		if(Player == -1)
		{
			
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
			
			//Return:
			return Plugin_Handled;
		}
		
		GetClientName(Client, Name, sizeof(Name));
		GetClientName(Player, PlayerName, sizeof(PlayerName));
		
		Bank[Player] = Munny; 
		PrintToConsole(Client, "|RP| - Set the bank for %s to $%d", PlayerName,Munny);
		CPrintToChat(Player, "{white}|RP| -{grey} Your Bank has been set to $%d by %s",Munny,Name); 
		Save(Player);
	}
	return Plugin_Handled; 
}

public Action:Command_addMoneyBank(Client,Args)
{
	decl Player; 
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_addmoneybank <USER> <MONEY>");
		return Plugin_Handled;      
	}
	if(Args == 2)
	{
		decl String:PlayerName[32];
		decl MaxPlayers; 
		decl String:Name[32];
		new Munny = 0; 
		decl String:Muny[32];
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, Muny, sizeof(Muny));
		Munny = StringToInt(Muny);  
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
		}
		
		//Invalid Name:
		if(Player == -1)
		{
			
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
			
			//Return:
			return Plugin_Handled;
		}
		
		GetClientName(Client, Name, sizeof(Name));
		GetClientName(Player, PlayerName, sizeof(PlayerName));
		
		Bank[Player] += Munny;
		
		PrintToConsole(Client, "|RP| - Added $%d to the bank of %s", Munny,PlayerName);
		CPrintToChat(Player, "{white}|RP| -{grey} Your Bank has been set to $%d by %s",Bank[Player],Name);
		
		Save(Player);
	}
	return Plugin_Handled; 
}

//Get Item:
public Action:CommandRemoveItemPly(Client, Args)
{
	
	//Error:
	if(Args < 3)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_getitem <name> <id> <amount>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl String:ItemId[255];
	decl String:Amount[255];
	
	//Initialize:
	GetCmdArg(2, ItemId, sizeof(ItemId));
	GetCmdArg(3, Amount, sizeof(Amount));
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Player, Name, sizeof(Name));
	
	//Set:
	Item[Player][StringToInt(ItemId)] -= StringToInt(Amount);
	
	//Print:
	PrintToConsole(Client, "|RP| - Removed %d %s's from %s", StringToInt(Amount), ItemName[StringToInt(ItemId)], Name);
	CPrintToChat(Player, "{white}|RP| -{grey} Removed %d %s's by %s", StringToInt(Amount), ItemName[StringToInt(ItemId)], ClientName);
	
	//Save:
	Save(Player);
	
	//Return:
	return Plugin_Handled;
}

public Action:CommandDLCHECK(Client,Args)
{  
	PrintToConsole(Client,"Start Check"); 
	new Handle:fileh = OpenFile(DownloadPath, "r");
	new String:buffer[256];
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		new len = strlen(buffer);
		if (buffer[len-1] == '\n')
			buffer[--len] = '\0';
		
		if (FileExists(buffer))
		{
			PrintToConsole(Client,"DL: %s",buffer);
		} else
		{
			PrintToConsole(Client,"IG: %s",buffer);  
		}
		
		if (IsEndOfFile(fileh))
			break;
	}
	return Plugin_Handled;     
}


public Action:Command_boersenschluss(Client,Args)
{
	boersenschluss();
	return Plugin_Handled;
}

public Action:Command_boersencrash(Client,Args)
{
	boersencrash();
	return Plugin_Handled;
}

public Action:Command_listItems(Client,Args)
{
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listitem <name> <page>");
		return Plugin_Handled;
	}
	decl Player;
	
	decl String:PlayerName[32];
	decl MaxPlayers; 
	decl String:Name[32], String:Page[32], PageInt, PageInt2; 
	
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	GetCmdArg(2, Page, sizeof(Page)); 
	PageInt = StringToInt(Page);
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		//Connected:
		if(!IsClientConnected(X)) continue;
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	if(PageInt < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listitem <name> <page>");
		return Plugin_Handled;
	}
	
	PageInt2 = PageInt * 50;
	decl PageBeg;
	PageBeg = PageInt2 - 50;
	PrintToConsole(Client, "|RP| - Searching for Items from %s (%d - %d)", PlayerName, PageBeg, PageInt2); 
	
	for(new p = PageInt2 - 50; p < PageInt2; p++)
	{
		if(Item[Player][p] > 0)
		{
			PrintToConsole(Client, "%d x %s", Item[Player][p],ItemName[p]);
		}    
	}
	return Plugin_Handled;
}

stock auctisStart()
{
	for(new X = 0; X < 7; X++) 
	{
		AuctItems[X] = GetRandomFloat(0.8,1.5);
	}
	
	for(new p = 100; p < 107; p++)
	{
		ItemCost[p] = GetRandomInt(50,800);
	}
	
	AuctVendor = GetRandomFloat(0.85,0.98);  
	CreateTimer(400.0, actAuct);
	return true;
}

public Action:actAuct(Handle:Timer)
{
	new Z = GetRandomInt(0,100);
	
	if(Z == 0) 
	{
		boersencrash();
		return Plugin_Handled;
	}
	if(Z == 50 || Z == 100)
	{
		boersenschluss();
		return Plugin_Handled;
	}
	
	for(new X = 0; X < 7; X++)
	{
		new Y = GetRandomInt(1,200);
		if(Y == 50) AuctItems[X] = 0.7;
		if(Y == 10) AuctItems[X] = 1.1;
		if(Y == 100 || Y == 200 || Y == 1) AuctItems[X] = 0.9;  
		AuctItems[X] = FloatMul(AuctItems[X],GetRandomFloat(0.78,1.20));
		if(AuctItems[X] > 1.5) AuctItems[X] = 1.5;
		if(AuctItems[X] < 0.5) AuctItems[X] = 0.5;
	}  
	AuctVendor = GetRandomFloat(0.80,0.98);
	CreateTimer(400.0, actAuct);  
	return Plugin_Handled; 
}

stock boersencrash()
{
	SetHudTextParams(-1.0, 0.015, 10.0, 255, 0, 255, 255, 1, 4.0, 0.1, 0.2);     
	for(new X = 1; X <= GetMaxClients(); X++)
	{
		//Connected:
		if(IsClientConnected(X) && IsClientInGame(X))
		{
			ShowHudText(X, -1, "The stock market crashed!");
			sellAllAct(X, 0.3);
		}
	}
	auctisStart();
}

stock boersenschluss()
{
	SetHudTextParams(-1.0, 0.015, 10.0, 255, 0, 255, 255, 1, 4.0, 0.1, 0.2);  
	for(new X = 1; X <= GetMaxClients(); X++)
	{
		//Connected:
		if(IsClientConnected(X) && IsClientInGame(X))
		{
			ShowHudText(X, -1, "The stock market closed!");
			sellAllAct(X, 0.0);
		}
	}
	auctisStart();
}

stock sellAllAct(Client,Float:modifier)
{
	for(new p = 100; p < 107; p++)
	{
		if(Item[Client][p] > 0)
		{
			new ItemPrice;
			if(modifier == 0.0)
				ItemPrice = RoundToCeil(FloatMul(FloatMul(float(ItemCost[p]),AuctItems[106-p]),AuctVendor));
			else
			ItemPrice = RoundToCeil(FloatMul(FloatMul(float(ItemCost[p]),modifier),AuctVendor));
			
			new Itemmoney = 0;
			for(new q=0; q < Item[Client][p]; q++)
			{
				Itemmoney += ItemPrice; 
			}
			CPrintToChat(Client, "{white}|RP| -{grey} You sold %d x %s for %d$",Item[Client][p],ItemName[p],Itemmoney);  
			Item[Client][p] = 0;
			Bank[Client] += Itemmoney;
		}
		Save(Client);
	}
}

//Cuff:
stock Cuff(Client)
{
	//Speed:
	SetSpeed(Client, 90.0);
	
	//Cuff:
	IsCuffed[Client] = true;
	kopfgeld[Client] = 0;
	
	decl Time, Time2, CrimeConvar;
	CrimeConvar = GetConVarInt(CrimeJail);
	
	if(Crime[Client] < CrimeConvar)
	{
		TimeConverter[Client] = 35;
	}
	else
	{
		Time = Crime[Client]/CrimeConvar;
		Time2 = Time*60;
		TimeConverter[Client] = RoundToCeil(float(Time2));
	}
	
	ExpCombineCheck[Client] = Crime[Client];
	
	if(Probation[Client] == 300)
	{
		TimeConverter[Client] = 300;
	}
	
	//Disable Jeypack
	PermitJetpack[Client] = false;
	
	//Save:
	ExploitJail[Client] = 1;
	Crime[Client] = 0;
	Save(Client);
	
	//Color:
	SetEntityRenderMode(Client, RENDER_GLOW);
	SetEntityRenderColor(Client, CuffColor[0], CuffColor[1], CuffColor[2], CuffColor[3]);
	SetEntityMoveType(Client, MOVETYPE_NONE);
	UncuffStop[Client] = 1;
	CreateTimer(0.5, Unfreeze, Client);
}

public Action:Unfreeze(Handle:Timer, any:Client)
{
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{
		UncuffStop[Client] = 0;
		SetEntityMoveType(Client, MOVETYPE_WALK);
	}
}

public Action:UnfreezeXx(Handle:Timer, any:Client)
{
	if(IsClientConnected(Client) && IsClientInGame(Client) && !IsCuffed[Client])
	{
		SetEntityMoveType(Client, MOVETYPE_WALK);
	}
}

//Uncuff:
stock Uncuff(Client)
{
	TimeConverter[Client] = 0;
	
	//Speed:
	SetSpeed(Client, 190.0);
	
	//Cuff:
	IsCuffed[Client] = false;
	
	//Enable Jetpack
	PermitJetpack[Client] = true;
	
	//Save;
	ExploitJail[Client] = 0;
	//TimeInJail[Client] = 0.0;
	FreeIn[Client] = 0;
	InJailC[Client] = false;
	
	//Color:
	SetEntityRenderMode(Client, RENDER_NORMAL);
	SetEntityRenderColor(Client, 255, 255, 255, 255);
	
	autoFreeTimerKill(Client);
	Probation[Client] = 0;
	CreateTimer(2.0, GravityGun, Client);
}

//VIP Jail:
stock vipjail(Player,Client)
{
	if(Player > 0 && Player <= GetMaxClients())
	{ 
		if(!IsCuffed[Player])
		{
			PrintToConsole(Client, "|RP| - target is not cuffed");
		} 
		else
		{ 
			CPrintToChat(Player, "{white}|RP| -{grey} You've been sent to the VIP Jail");
			TeleportEntity(Player, VIPJailOrigin, NULL_VECTOR, NULL_VECTOR);
			
			/*if(TimeInJail[Player] == 0.0)
				jailtimerstart(Player);*/
			if(FreeIn[Player] == 0)
				StartJail(Player, 600);
			
		}
	} else
	{
		PrintToConsole(Client, "|RP| - target is not a player");  
	}
}

stock suicidechamber(Player,Client,Num)
{
	if(Player > 0 && Player <= GetMaxClients())
	{ 
		if(!IsCuffed[Player])
		{
			PrintToConsole(Client, "|RP| - target is not cuffed");
		} 
		else
		{ 
			CPrintToChat(Player, "{white}|RP| -{grey} You've been sent to the suicide chamber");
			LooseMoney[Player] = true;
			if(Num == 1)
			{
				TeleportEntity(Player, OrderOrigin, NULL_VECTOR, NULL_VECTOR);
			}
			if(Num == 2)
			{
				TeleportEntity(Player, OrderOrigin2, NULL_VECTOR, NULL_VECTOR);
			}
			
			//if(TimeInJail[Player] == 0.0)
				//jailtimerstart(Player);
				
			if(FreeIn[Player] == 0)
				StartJail(Player);
			
			GetFree[Player] = true;
			killOrder[Player] = true;
			
		}
	} else
	{
		PrintToConsole(Client, "|RP| - target is not a player");  
	}
}


public Action:autofreeExec(Client)
{
	if(IsCuffed[Client])
	{
		Uncuff(Client);
		if(AnyExit == 1)
		{
			TeleportEntity(Client, ExitOrigin, NULL_VECTOR, NULL_VECTOR);  
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Server has not created an exit coordinate.");
			ForcePlayerSuicide(Client);
		}
	}        
} 
/*
stock jailtimerstart(Player)
{
	TimeInJail[Player] = 1.0; 
}
*/
public Action:jail_timer_COMAX(Handle:timer, any:client)
{
	if(IsCuffed[client])
	{
		//TimeInJail[Player] = TimeInJail[Player] + 1.0;
		if(FreeIn[client] == 0)
		{
			autofreeExec(client); 
		} else
		{
			FreeIn[client]--;
			CreateTimer(1.0, jail_timer_COMAX, client);
		}
	} else
		autofreeExec(client); 
}

StartJail(client, time = 15) // Def = 15 secs
{	
	if(client > 0 && client <= GetMaxClients())
	{ 
		if(IsCuffed[client])
		{		
			/*if(time > 240)
				time = 240;*/
				
				
			CPrintToChat(client, "{white}|RP| -{grey} You'll be free in %d seconds.",time);
			
			FreeIn[client] = time;
			CreateTimer(1.0, jail_timer_COMAX, client);
			PrintToServer("Starting jail for client %d. FreeIn = %d", client, time);
		}
	}
}

/*
public Action:jailtimer(Player)
{
	if(IsCuffed[Player])
	{
		TimeInJail[Player] = TimeInJail[Player] + 1.0;
		if(Autofree[Player] > 0)
		{  
			if(FloatCompare(TimeInJail[Player],Autofree[Player]) == 1)
			{   
				autofreeExec(Player); 
			}   
		}
	} else
	{
		TimeInJail[Player] = 0.0;  
	}
}
*/
stock autoFreeTimerKill(Player)
{
	//Autofree[Player] = 0.0;
	FreeIn[Player] = 0;
	//TimeInJail[Player] = 0.0; 
	CPrintToChat(Player, "{white}|RP| -{grey} You're free");
	Probation[Player] = 0;
}
/*
stock autofree(Player,Float:Time)
{
	if(Player > 0 && Player <= GetMaxClients())
	{ 
		if(IsCuffed[Player])
		{		
			Autofree[Player] = Time;
			decl NoDec;
			NoDec = RoundToFloor(Float:Time);
			if(NoDec > 240)
			{
				NoDec = 240;
				CPrintToChat(Player, "{white}|RP| -{grey} You'll be free in %d seconds",NoDec);
			}
			else
			{
			CPrintToChat(Player, "{white}|RP| -{grey} You'll be free in %d seconds",NoDec);
			}
		}
	}
}
*/
public Action:Command_vipjail(Client,Args)
{
	if(!IsCombine(Client) && StrContains(Job[Client], "Admin", false) == -1)
	{
		PrintToConsole(Client, "Unknown command: sm_vipjail");
		return Plugin_Handled;
	}
	
	decl Player; 
	if(Args == 1)
	{
		decl String:PlayerName[32];
		decl MaxPlayers; 
		decl String:Name[32]; 
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));  
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
		}
		
		//Invalid Name:
		if(Player == -1)
		{
			
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
			
			//Return:
			return Plugin_Handled;
		}
	} else
	{
		Player = GetClientAimTarget(Client, true); 
	}
	
	vipjail(Player,Client);
	return Plugin_Handled;
}

public Action:command_Kopfgeld(Client,Args)
{
	if(!IsCombine(Client) && StrContains(Job[Client], "Admin", false) == -1  || StrContains(Job[Client], "Recruit", false) != -1)
	{
		PrintToConsole(Client, "Unknown command: sm_bounty");
		return Plugin_Handled;
	}
	
	//Error:
	if(Args < 2)
	{
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_bounty <name> <amount>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32];
	decl String:Bounty[32];
	decl String:Name[32]; 
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	GetCmdArg(2, Bounty, sizeof(Bounty));
	
	if(StringToInt(Bounty) > 200 && StrContains(Job[Client], "Admin", false) == -1)
	{
		//Print:
		PrintToConsole(Client, "|RP| - Bounty is too high!");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	addkopfgeld(Player,StringToInt(Bounty));
	return Plugin_Handled; 
}

stock addkopfgeld(Player,Bounty)
{
	decl String:Name[32];
	GetClientName(Player, Name, sizeof(Name));
	decl MaxPlayers;
	MaxPlayers = GetMaxClients();
	
	SetHudTextParams(-1.0, 0.015, 10.0, 255, 255, 255, 255, 1, 4.0, 0.1, 0.2); 
	//Loop:
	for(new Y = 1; Y <= MaxPlayers; Y++)
	{
		//Connected:
		if(IsClientConnected(Y) && IsClientInGame(Y) && Y != Player)
		{ 
			if(Bounty == 0)  
				ShowHudText(Y, -1, "The bounty for %s got revoked",Name,Bounty);
			else
			ShowHudText(Y, -1, "%s has now a bounty of %d$ on his head",Name,Bounty);
		}
	} 
	if(Bounty == 0)
	{
		ShowHudText(Player, -1, "Your bounty got revoked");
		AutoBounty[Player] = false;
	}
	else 
	{
		ShowHudText(Player, -1, "A bounty of %d$ is set on your head! If you die you'll get in jail!",Bounty);
	}
	kopfgeld[Player] = Bounty;
}

public Action:Command_uncuff(Client, Args)
{
	//Error:
	if(Args < 1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_uncuff <name>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	Uncuff(Player);
	
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Player, PlayerName, sizeof(PlayerName));
	
	//Print:
	CPrintToChat(Client, "{white}|RP| -{grey} You uncuff %s",PlayerName);
	CPrintToChat(Player, "{white}|RP| -{grey} You are uncuffed by %s",ClientName);
	return Plugin_Handled; 
}

public Action:Command_cuff(Client, Args)
{
	//Error:
	if(Args < 1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_cuff <name>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	Cuff(Player);
	CreateTimer(0.5, RemoveWeapons, Player);
	
	//HP:
	SetEntityHealth(Player, 100);
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Player, PlayerName, sizeof(PlayerName));
	//Print:
	CPrintToChat(Client, "{white}|RP| -{grey} Got him. %s is now cuffed",PlayerName);
	CPrintToChat(Player, "{white}|RP| -{grey} You are cuffed by %s",ClientName);
	
	return Plugin_Handled; 
}

//Crime:
stock AddCrime(Client, Time)
{
	
	//Not Combine:
	if(!IsCombine(Client) && NoCrime[Client] == 0)
	{
		//Add:
		Crime[Client] += Time;
	}
}


//Shake:
stock Shake(Client, Float:Length, Float:Severity)
{
	if(IsClientInGame(Client))
	{
		//Declare:
		decl Handle:ViewMessage;
		
		//Clients:
		new SendClient[2];
		SendClient[0] = Client;
		
		//Write:
		ViewMessage = StartMessageEx(ShakeID, SendClient, 1);
		BfWriteByte(ViewMessage, 0);
		BfWriteFloat(ViewMessage, Severity);
		BfWriteFloat(ViewMessage, 10.0);
		BfWriteFloat(ViewMessage, Length);
		
		//Send:
		EndMessage();
	}
}



//Effects:
public Action:DrugFade(Handle:Timer, any:Client)
{
	if(IsClientInGame(Client))
	{
		//Declare:
		decl Handle:ViewMessage;
		
		//Clients:
		new SendClient[2];
		SendClient[0] = Client;
		
		//Write:
		ViewMessage = StartMessageEx(FadeID, SendClient, 1);
		BfWriteShort(ViewMessage, 255);
		BfWriteShort(ViewMessage, 255);
		BfWriteShort(ViewMessage, (0x0002));
		BfWriteByte(ViewMessage, GetRandomInt(0, 255));
		BfWriteByte(ViewMessage, GetRandomInt(0, 255));
		BfWriteByte(ViewMessage, GetRandomInt(0, 255));
		BfWriteByte(ViewMessage, 128);
		
		//Send:
		EndMessage();
	}
}

//Smoke:
public Action:Explosion(Handle:Timer, any:Client)
{
	if(IsClientInGame(Client))
	{
		//Declare:
		decl Float:ClientOrigin[3];
		
		//Initialize:
		GetClientAbsOrigin(Client, ClientOrigin);
		ClientOrigin[0] += GetRandomFloat(-100.0, 100.0);
		ClientOrigin[1] += GetRandomFloat(-100.0, 100.0);
		
		//Write:
		TE_SetupExplosion(ClientOrigin, 0, 30.0, 30, 0, 100, 100);
		
		//Send:
		TE_SendToClient(Client);
	}
}

//Random Look:
public Action:RandomLook(Handle:Timer, any:Client)
{
	
	//Declare:
	new Float:ClientOrigin[3], Float:RandomAngles[3];
	
	//Not World:
	if(Client > 0)
	{
		
		//In-Game:
		if(IsClientInGame(Client))
		{
			
			//Vectors:
			GetClientAbsOrigin(Client, ClientOrigin);
			GetClientAbsAngles(Client, RandomAngles);
			RandomAngles[1] = GetRandomFloat(0.0, 360.0);
		}
	}
	
	//Teleport:
	TeleportEntity(Client, ClientOrigin, RandomAngles, NULL_VECTOR);
}

//Defaults:
stock SetUpDefaults(Client, bool:ShouldLoad = false)
{
	
	//Loaded:
	if(!Loaded[Client])
	{
		
		//Values:
		Money[Client] = DEFAULTMONEY;
		Bank[Client] = DEFAULTBANK;
		Wages[Client] = DEFAULTWAGES;
		Job[Client] = DEFAULTJOB;
		OrgJob[Client] = DEFAULTJOB; 
		lastspawn[Client] = GetGameTime();
		Paycheck[Client] = PAYCHECKTIMER;
		LooseMoney[Client] = false;
		kopfgeld[Client] = 0;
		AutoBounty[Client] = false;
		Minutes[Client] = 0;
		//PropLimit[Client] = 0;
		Prune[Client] = 0;
		Crime[Client] = 0;
		ExploitJail[Client] = 0;
		//TimeInJail[Client] = 0.0;
		FreeIn[Client] = 0;
		DrugTick[Client] = 0;
		GetFree[Client] = false;
		killOrder[Client] = false;
		ExpLevel[Client] = 0;
		CuffCount[Client] = 0;
		Planted[Client] = 0;
		
		InternalFrags[Client] = 0;
		for(new X = 0; X < 33; X++)
		{
			GPS[X][Client] = 0;
		}
		
		//Load:
		if(ShouldLoad) Load(Client);
	}
}

//Load Items:
stock LoadItems()
{
	
	//Declare:
	decl ActionId, Cost;
	decl Handle:Vault;
	decl String:Buffer[4][255];
	decl String:ReferenceString[255], String:ItemId[255];
	
	//Initialize:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, ItemPath);
	
	//Loop:
	for(new X = 0; X < MAXITEMS; X++)
	{
		
		//Convert:
		IntToString(X, ItemId, sizeof(ItemId));
		
		//Load:
		LoadString(Vault, "Items", ItemId, "Null", ReferenceString);
		
		//Check:
		if(!StrEqual(ReferenceString, "Null"))
		{
			
			//Explode:
			ExplodeString(ReferenceString, "^", Buffer, 4, 255);
			
			//Convert:
			decl String:ActionString[2][32];
			ExplodeString(Buffer[1], "-", ActionString, 2, 32);
			ActionId = StringToInt(ActionString[0]);
			Cost = StringToInt(Buffer[3]);
			
			//Save:
			ItemName[X] = Buffer[0];
			ItemAction[X] = ActionId;
			ItemVar[X] = Buffer[2];
			ItemCost[X] = Cost;
			
			//Furniture:
			if(ItemAction[X] == 7)
			{
				PrecacheModel(ItemVar[X]);
			}
		}
	}
	
	//Save:
	KeyValuesToFile(Vault, ItemPath);
	
	//Close:
	CloseHandle(Vault);
}

//Paycheck:
stock TickPaycheck(Client)
{
	
	//Declare:
	decl Float:Dist;
	decl bool:InJail;
	decl Float:ClientOrigin[3];
	
	//Pay:
	if(Paycheck[Client] == 1)
	{
		
		//Update:
		Money[Client] += Wages[Client];
		Paycheck[Client] = 61;
		MinuteTimer(Client);
		
		if(EquipSpam[Client] > 0) EquipSpam[Client]--;
		//EquipSpam[Client] = 0;
		
		//Save:
		Save(Client);
	}
	
	//Origin:
	if(IsClientInGame(Client)) GetClientAbsOrigin(Client, ClientOrigin);
	
	//Jail:
	InJail = false;
	for(new X; X < 3; X++)
	{
		
		//Initialize:
		Dist = GetVectorDistance(ClientOrigin, JailOrigin[X]);
		
		//Check:
		if(Dist <= 155) InJail = true;
	}
	
	//Tick:
	if(!InJail) Paycheck[Client] = (Paycheck[Client] - 1);
}

stock bool:IsOfficial(Client)
{
	if(StrContains(Job[Client], "City Official", false) != -1) return true;
	if(StrContains(Job[Client], "Mayor", false) != -1) return true;
	else return false;
}

//Combine Check:
stock bool:IsCombine(Client)
{
	//Contains Combine:
	if(StrContains(Job[Client], "Police", false) != -1) return true;
	if(StrContains(Job[Client], "SWAT", false) != -1) return true;
	if(StrContains(Job[Client], "Admin", false) != -1) return true;
	if(StrContains(Job[Client], "Undercover", false) != -1) return true;
	if(GetConVarInt(FireFighterChiefMode) == 1 && StrEqual(Job[Client], "Firefighter Chief", false)) return true;
	else return false;
}

stock bool:IsGangster(Client)
{
	if(StrContains(Job[Client], "Gangster", false) != -1) return true;
	else return false;
}

stock bool:IsUnderCover(Client)
{
	if(StrContains(Job[Client], "Undercover", false) != -1) return true;
	else return false;
}

//FireFighter Check:
stock bool:IsFirefighter(Client)
{
	if(StrContains(Job[Client], "Firefighter", false) != -1) return true;
	else return false;
}

//Probation Check:
stock bool:OnProbation(Client)
{
	if(StrEqual(Job[Client], "Probation", false)) return true;
	else return false;
}

stock bool:IsRecruit(Client)
{
	if(StrContains(Job[Client], "Police Recruit", false) != -1) return true;
	else return false;
}
//Gambling Zone:
stock bool:IsGambling(Client)
{
	if(IsClientConnected(Client))
	{
		if(IsClientInGame(Client))
		{
			decl Float:Check, Float:YourOrigin[3];
			GetClientAbsOrigin(Client, YourOrigin);
			YourOrigin[2] += 40.0;
			for(new GamZones = 1; GamZones <= MAXGAMBLING; GamZones++)
			{
				if(!IsCuffed[Client])
				{
					Check = GetVectorDistance(GamblingOrigin[GamZones], YourOrigin);
					if(Check <= 150 && GamblingOrigin[GamZones][0] != 69.0)
					{
						return true;
					}
				}
			}
		}
	}
	return false;
}

//Draw Menu:
stock DrawMenu(Client, String:Buffers[7][64], MenuHandler:MenuHandle, Variables[7] = {0, 0, 0, 0, 0, 0, 0})
{
	
	//Declare:
	decl Handle:Panel;
	
	//Initialize:
	Panel = CreatePanel();
	
	//Print:
	OverflowMessage(Client, "|RP| - Press <Escape> to access the menu");
	
	
	//Display:
	for(new X = 0; X < 7; X++) if(strlen(Buffers[X]) > 0)
	{
		
		//Add:
		DrawPanelItem(Panel, Buffers[X]);
		
		//Var:
		SelectedBuffer[X][Client] = Variables[X];
	}
	
	//Draw:
	SendPanelToClient(Panel, Client, MenuHandle, 30);
	
	//Close:
	CloseHandle(Panel);
}


public OnClientPostAdminCheck(Client) 
{
	if(GetVipLevel(Client) > 0)
	{
		new String:name[32];
		GetClientName(Client, name, 32);
		PrintToChatAll("\x01[\x04Comax\x01] Donator \x04%s\x01 connected.", name);
	}	
}

public GetVipLevel(Client)
{
	if(IsClientInGame(Client))
	{
		new AdminId:AdminID = GetUserAdmin(Client);
		if(AdminID != INVALID_ADMIN_ID)
		{
			if(GetUserFlagBits(Client)&ADMFLAG_CUSTOM4 > 0 && GetUserFlagBits(Client)&ADMFLAG_CUSTOM2 > 0)
				return VIP_LEVEL_SUPER;
			else if(GetUserFlagBits(Client)&ADMFLAG_CUSTOM4 > 0)
				return VIP_LEVEL_BASIC;
		}
	} 
	return 0; // 0 = No VIP Access
}

public Action:SDKWeaponCanUse(client, weapon)
{
	if(IsCuffed[client])
		return Plugin_Handled;
	
	return Plugin_Continue;
}

public OnClientAuthorized(Client)
{
	ComaxClientAuthorized(Client);
}

//In-Game:
public OnClientPutInServer(Client)
{

	decl String:SteamId[255];
	
	//Initialize:
	GetClientAuthString(Client, SteamId, 32);
	
	if(IsFakeClient(Client) || StrContains(SteamId, "BOT", false) != -1) 
		isBot[Client] = true;
		

	SDKHook(Client, SDKHook_WeaponCanUse, SDKWeaponCanUse);

	//Comax RP Mod:
	ComaxClientPutInServer(Client);


	//Declare
	//decl String:FormatMessage[1024];
	
	//Default Values:
	SetUpDefaults(Client, true);
	HackTime[Client] = GetGameTime();
	SawTime[Client] = GetGameTime();
	ScannerTime[Client] = GetGameTime(); 
	InterruptTime[Client] = GetGameTime();
	SawTime[Client] = GetGameTime(); 
	LockTime[Client] = GetGameTime();
	EnableTracers[Client] = true;
	lastpressedE[Client] = 0.0;
	pressedE[Client] = 0;
	RaffleWin[Client] = 0;
	TourGuide[Client] = 99;
	InJailC[Client] = false;
	Stealth[Client] = false;
	EquipSpam[Client] = 0;
	Bribe[Client] = 0;
	BribeAmt[Client] = 0;
	PermitJetpack[Client] = true;
	
	DynamicJobsRefresh(Client);
	
	//Register:
	PrintToChat(Client, "\x01[RP] Comax RolePlay Mod v%s by \x04[CMX] Reloaded\x01 + Roleplay_Remixed by EasSidez (Original mod by \x04[GR]Nick_6893{A}\x01) loaded successfully!", RPVERSION);
	saveUserName(Client);
}



public bool:OnClientConnect(Client, String:Reject[], Len)
{
	//Disable:
	Loaded[Client] = false;
	return true; 
	
}

//Disconnect:
public OnClientDisconnect(Client)
{
	//COMAX:
	SDKUnhook(Client, SDKHook_WeaponCanUse, SDKWeaponCanUse);

	//Disable:
	//sellAllAct(Client,0.0);
	StopJetpack(Client);
	for(new X = 0; X < 33; X++)
	{
		GPS[Client][X] = 0;
	}
	//Change back to cop mode 		
	if(!IsCombine(Client) && ((StrContains(OrgJob[Client], "Police", false) != -1) || (StrContains(OrgJob[Client], "SWAT", false) != -1) || (StrContains(OrgJob[Client], "Admin", false) != -1)))
	{
		Job[Client] = OrgJob[Client];
	}
	
	DynamicJobsRefresh(Client);
	
	//uncomment to enable drop money when disconnect
	//CreateMoneyBoxes(Client, Money[Client]);
	//Money[Client] = 0;
	
	Save(Client);
	Loaded[Client] = false;
	Stealth[Client] = false;
	isBot[Client] = false;
	ComaxClientDisconnect(Client);
	return true;
}

public DynamicJobsRefresh(Client)
{
	TeleStartOrigin[Client][0] = 0.0;
	TeleEndOrigin[Client][0] = 0.0;
	
	decl String:CheckDrugPlant[64];
	for(new X = 0; X < GetConVarInt(MaxPlants); X++)
	{
		DrugPlant[Client][X][0] = 0.0;
		DrugPlantWorth[Client][X] = 0;
		GetEntPropString(DrugEnt[Client][X], Prop_Data, "m_ModelName", CheckDrugPlant, 64);
		
		if(StrEqual(CheckDrugPlant, "models/props_lab/cactus.mdl", false))
		{
			AcceptEntityInput(DrugEnt[Client][X], "kill");
		}
		DrugEnt[Client][X] = 0;
	}
	
	
	if(Hitman[Client] > 0 && HitmanBuyer[Client] > 0)
	{
		if(IsClientConnected(HitmanBuyer[Client]) && IsClientInGame(HitmanBuyer[Client]))
		{
			CPrintToChat(HitmanBuyer[Client], "{white}|RP| -{grey} The hitman has failed to complete his task.  You have been refunded $750");
			Money[HitmanBuyer[Client]] += 750;
		}
	}
	
	Hitman[Client] = 0;
	HitmanTimer[Client] = 0;
	HitmanBuyer[Client] = 0;
	
	SalesMan[Client] = 0;
	PermitJetpack[Client] = false;
	
	PrinterRefresh(Client);
}

public FaceModel(Client)
{
	//YOU SHOULD NOT BE EDITTING THIS!  EDIT THE JOB SETUP DATABASE!
	decl String:Buffer[64];
	GetClientModel(Client, Buffer, 64);
	if(!StrEqual(PlayerModel[Client], Buffer, false)) SetEntityModel(Client, PlayerModel[Client]);
}

SteamIdToInt(Client, nBase = 10)
{
	
	//Declare:
	decl String:SteamId[32];
	
	//Initulize:
	GetClientAuthString(Client, SteamId, 32);
	
	//Declare:
	decl String:subinfo[3][16];
	
	//Explode:
	ExplodeString(SteamId, ":", subinfo, sizeof(subinfo), sizeof(subinfo[]));
	
	//Initulize:
	new Int = StringToInt(subinfo[2], nBase);
	
	if(StrEqual(subinfo[1], "1"))
	{
		
		//Initulize:
		Int *= -1;
	}
	
	//Return:
	return Int;
}


HasClientWeapon(Client, const String:WeaponName[], Value)
{
	
	if(Value == 1)
	{
		
		//Initulize:
		WeaponEq[Client] = 1;
		
		//Give Item:
		GivePlayerItem(Client, WeaponName);
		
		//Initulize:
		WeaponEq[Client] = 0;
	}
	
	//Declare:
	new MaxGuns = 64;
	
	//Loop:
	for(new X = 0; X < MaxGuns; X = (X + 4))
	{
		
		//Declare:
		new WeaponId = GetEntDataEnt2(Client, WeaponOffset + X);
		
		//Is Valid:
		if(WeaponId > 0)
		{
			
			//Declare:
			decl String:ClassName[32];
			
			//Initialize:
			GetEdictClassname(WeaponId, ClassName, sizeof(ClassName));
			
			//Is Valid:
			if(StrEqual(ClassName, WeaponName))
			{
				
				//Return:
				return WeaponId;
				
			}
		}
	}
	
	//Return:
	return -1;
}

//Hud:
public Action:DisplayHud(Handle:Timer, any:Client)
{
	//Connected:
	if(IsClientConnected(Client) && IsClientInGame(Client) && GetConVarInt(h_showhud) == 1)
	{
	
		ShowRestartTimer(Client);
		ShowClock(Client);
	
		new plyteam = GetClientTeam(Client);
		//Combine:
		if(IsCombine(Client) && StrContains(Job[Client], "Admin", false) == -1 || StrContains(Job[Client], "FireFighter Memb", false) != -1 && GetConVarInt(FireFighterTeam) == 1)
		{
			if(plyteam != 2)
				ChangeClientTeam(Client,2);
		}
		
		//Rebel:
		if(!IsCombine(Client) && StrContains(Job[Client], "FireFighter Memb", false) == -1 || StrContains(Job[Client], "Admin", false) != -1 || StrContains(Job[Client], "FireFighter Memb", false) != -1 && GetConVarInt(FireFighterTeam) == 2)
		{
			if(plyteam != 3)  
				ChangeClientTeam(Client,3);
		}
		
		//Dead:
		if(!IsPlayerAlive(Client))
		{
			
			//Loop:
			CreateTimer(HUDTICK, DisplayHud, Client);
			//Return:
			return Plugin_Handled;
		}
		
		if(OnProbation(Client) && Crime[Client] >= 500)
		{
			Probation[Client] = 300;
			Cuff(Client);
			Jail(Client, Client);
			CreateTimer(0.5, RemoveWeapons2, Client);
			CPrintToChat(Client, "{white}|RP| -{grey} You have been jailed for going over 500 crime while on probation.");
		}
		
		//Declare:
		decl String:Buffer[64];
		decl Player, Float:Dist;
		decl Float:ClientOrigin[3], Float:PlayerOrigin[3];
		decl MaxPlayers;
		decl CrimeLimit;
		
		//Initialize:
		GetClientAbsOrigin(Client, ClientOrigin);
		ClientOrigin[2] += 40.0;
		Player = GetClientAimTarget(Client, true);
		if(Player > 0) GetClientAbsOrigin(Player, PlayerOrigin);
		Dist = GetVectorDistance(ClientOrigin, PlayerOrigin);
		
		if(GetConVarInt(CuffCrime) <= 0)
		{
			CrimeLimit = 1;
		}
		else
		{
			CrimeLimit = GetConVarInt(CuffCrime);
		}
		
		//Cuffed:
		if(DrugTick[Client] > 0) SetSpeed(Client,DrugSpeed[Client]); 
		if(IsCuffed[Client]) SetSpeed(Client, 90.0);
		if(OnProbation(Client) && !IsCuffed[Client]) SetSpeed(Client, 120.0);
		//if(TimeInJail[Client] > 0) jailtimer(Client);
		
		//Initialize:
		MaxPlayers = GetMaxClients();
		
		//Model:
		GetClientModel(Client, Buffer, 64); 
		
		//Models
		FaceModel(Client);
		
		//No Kill Zones:
		for(new X = 1; X <= MaxPlayers; X++)
		{
			if(IsClientConnected(X))
			{
				if(IsClientInGame(X))
				{
					decl Float:Distz, Float:XOrigins[3];
					GetClientAbsOrigin(X, XOrigins);
					XOrigins[2] += 40.0;
					for(new Zonesd = 1; Zonesd <= 100; Zonesd++)
					{
						if(!IsCuffed[Client] && GodMode[Client] == 0)
						{
							Distz = GetVectorDistance(NoKillZones[Zonesd], XOrigins);
							if(Distz <= 200 && Crime[X] < CrimeLimit)
							{
								NoKill[X] = 1;
								Zonesd = 150;
							}
							if((Distz > 200 && NoKill[X] == 6 && Zonesd != 150) || (NoKill[X] == 6 && Zonesd != 150 && Crime[X] >= CrimeLimit))
							{	
								NoKill[X] = 2;
								Zonesd = 150;
							}
						}
						else if(GodMode[Client] == 1)
						{
							NoKill[X] = 3;
						}
						else
						{
							NoKill[X] = 2;
						}
					}
					//Drug Addict Plants Loop:
					for(new D = 0; D < GetConVarInt(MaxPlants); D++)
					{
						//X = 32 possible players
						//D = 5 possible plants
						//XOrigins = Player Origin
						//Looping through all players in this loop to see other drug origins!
						
						if(DrugPlant[X][D][0] != 0.0)
						{
							//TE_SetupBeamRingPoint(DrugPlant[X][D], 25.0, 1.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TeleColor2, 10, 0);
							//TE_SendToClient(Client);
							Distz = GetVectorDistance(DrugPlant[X][D], ClientOrigin);
							if(Distz < 50 && DrugPlant[X][D][0] != 0.0)
							{
								if(Client == X)
								{
									PrintCenterText(Client, "Drug Plant (%d grams) Press E to take the drugs!", DrugPlantWorth[X][D]);
								}
								else
								{
									decl String:Steal[64];
									GetClientName(X, Steal, sizeof(Steal));
									if(!IsCombine(Client))
									{
										PrintCenterText(Client, "%s's Drug Plant (%d grams) Press E to steal the drugs!", Steal, DrugPlantWorth[X][D]);
									}
									else if(IsCombine(Client) || IsFirefighter(Client))
									{
										PrintCenterText(Client, "%s's Drug Plant (%d grams) Press E to destroy the drugs!", Steal, DrugPlantWorth[X][D]);
									}
								}
							}
							
							//Grams increasing randomly 5 percent of the time x32maxplayers:
							decl Randq, Percent;
							Randq = GetRandomInt(1, 100);
							
							Percent = 95;
							if(GetConVarInt(DrugProb) > 0 && GetConVarInt(DrugProb) < 100)
							{
								Percent = 100 - GetConVarInt(DrugProb);
							}
							
							if(Randq > Percent && DrugPlantWorth[X][D] < 500)
							{
								DrugPlantWorth[X][D] += 1;
							}
						}					
					}
					
					//Check moneyprinters.sp for further info.
					PrinterHUD(Client, X, ClientOrigin);
				}
			}
		}
		
		if(NoKill[Client] == 1)
		{
			SetEntProp(Client, Prop_Data, "m_takedamage", 0, 1);
			NoKill[Client] = 6;
		}
		if(NoKill[Client] == 2)
		{
			SetEntProp(Client, Prop_Data, "m_takedamage", 2, 1);
			NoKill[Client] = 3;
		}
		
		//No Crime Zone:
		for(new CrimeZones = 1; CrimeZones <= MAXCRIMEZONES; CrimeZones++)
		{
			if(!IsCuffed[Client])
			{
				decl Float:CriDistz;
				CriDistz = GetVectorDistance(NoCrimeOrigin[CrimeZones], ClientOrigin);
				if(CriDistz <= 150 && NoCrimeOrigin[CrimeZones][0] != 69.0)
				{
					NoCrime[Client] = 1;
					CrimeZones = 2500;
				}
				else if(CriDistz > 150 && CrimeZones != 2500)
				{
					NoCrime[Client] = 0;
				}
			}
		}
		
		//Gambling Zones:
		for(new GamZones = 1; GamZones <= MAXGAMBLING; GamZones++)
		{
			if(!IsCuffed[Client])
			{
				decl Float:GamDistz;
				GamDistz = GetVectorDistance(GamblingOrigin[GamZones], ClientOrigin);
				if(GamDistz <= 150 && GamblingOrigin[GamZones][0] != 69.0)
				{					
					SetHudTextParams(-1.0, 0.085, HUDTICK, 0, 200, 50, 255, 1, 6.0, 0.1, 0.2);  
					if(Casino[GamZones] == 0)
					{
						ShowHudText(Client, -1, "Gambling Zone [Closed] - Owner: %s", GamblingOwnerName[GamZones]);
						GamZones = 9999;
					}
					else
					{
						ShowHudText(Client, -1, "Gambling Zone [Opened] - Owner: %s", GamblingOwnerName[GamZones]);
						GamZones = 9999;
					}
				}
			}
		}
		
		for(new T = 0; T <= 32; T++)
		{
			if(TeleStartOrigin[T][0] != 0.0 && TeleEndOrigin[T][0] != 0.0)
			{
				TE_SetupBeamRingPoint(TeleStartOrigin[T], 100.0, 1.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TeleColor1, 10, 0);
				TE_SendToClient(Client);
				TE_SetupBeamRingPoint(TeleEndOrigin[T], 1.0, 100.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TeleColor2, 10, 0);
				TE_SendToClient(Client);
				
				decl Float:TeleDist, Float:TeleDistEnd;
				TeleDist = GetVectorDistance(TeleStartOrigin[T], ClientOrigin);
				TeleDistEnd = GetVectorDistance(TeleEndOrigin[T], ClientOrigin);
				if(TeleDist < 100)
				{
					decl String:Scientist[255];
					GetClientName(T, Scientist, sizeof(Scientist));
					PrintCenterText(Client, "Press E to use %s's teleporter! (Cost: $200)", Scientist);
					TE_SetupBeamPoints(TeleStartOrigin[T], TeleEndOrigin[T], LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, TeleColor1, 0);
					TE_SendToClient(Client);
				}
				if(TeleDistEnd < 100)
				{
					decl String:Scientist[255];
					GetClientName(T, Scientist, sizeof(Scientist));
					PrintCenterText(Client, "%s's teleporter", Scientist);
				}
			}
		}
		
		//Employed:
		if(!StrEqual(Job[Client], DEFAULTJOB))
		{
			if(Crime[Client] > 2000)
			{
				new bnty = RoundToFloor(Crime[Client] / 20.0);
				if(kopfgeld[Client] < bnty)
				{
					addkopfgeld(Client,bnty);
					SetHudTextParams(-1.0, 0.045, 30.0, 255, 255, 255, 255, 1, 4.0, 0.1, 0.2);  
					ShowHudText(Client, -1, "Get below 2000 crime to remove your bounty");
					AutoBounty[Client] = true;
				}
			}
			else if(Crime[Client] < 2000 && AutoBounty[Client]) //Kopfgeld löschen
			{
				addkopfgeld(Client,0); 
			}	
			
			if(StrEqual(Job[Client], "Hitman", false))
			{
				if(Hitman[Client] > 0 && !IsCuffed[Client])
				{
					if(IsClientConnected(HitmanBuyer[Client]) && IsClientInGame(HitmanBuyer[Client]))
					{
						if(IsClientConnected(Hitman[Client]) && IsClientInGame(Hitman[Client]))
						{
							decl Float:HitmanOrigin[3];
							GetClientAbsOrigin(Hitman[Client], HitmanOrigin);
							HitmanOrigin[2] += 20.0;
							TE_SetupBeamPoints(ClientOrigin, HitmanOrigin, LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, TeleColor2, 0);
							TE_SendToClient(Client);
							HitmanTimer[Client] -= 1;
							if(HitmanTimer[Client] == 0)
							{
								decl String:Killman[64];
								GetClientName(Hitman[Client], Killman, sizeof(Killman));
								CPrintToChat(Client, "{white}|RP| -{grey} You have failed to kill: %s", Killman);
								CPrintToChat(HitmanBuyer[Client], "{white}|RP| -{grey} This hit on %s has failed.  You have been refunded $750.", Killman);
								Hitman[Client] = 0;
								Money[HitmanBuyer[Client]] += 750;
							}
							else if(HitmanTimer[Client] == 180)
							{
								decl String:Killman[64];
								GetClientName(Hitman[Client], Killman, sizeof(Killman));
								CPrintToChat(Client, "{white}|RP| -{grey} You have 3 minutes left to kill %s", Killman);
							}
							else if(HitmanTimer[Client] == 60)
							{
								decl String:Killman[64];
								GetClientName(Hitman[Client], Killman, sizeof(Killman));
								CPrintToChat(Client, "{white}|RP| -{grey} You have 1 minute left to kill %s", Killman);
							}
						}
						else
						{
							CPrintToChat(Client, "{white}|RP| -{grey} The hit has been cancelled");
							CPrintToChat(Hitman[Client], "{white}|RP| -{grey} The hit has been cancelled.  Refunded $750.");
							Hitman[Client] = 0;
							Money[Client] += 750;
						}
					}
					else
					{
						Hitman[Client] = 0;
						CPrintToChat(Client, "{white}|RP| -{grey} The hit has been cancelled");
					}
				}
			}
			
			//Player's Hud:
			if(Player > 0 && IsClientInGame(Client) && HudModeCenter[Client] == 1)
			{
				decl String:PlayName[60];
				GetClientName(Player, PlayName, sizeof(PlayName));
				
				if(RedCrimeMenu[Client] == 0)
				{
					decl CrimeL;
					CrimeL = GetConVarInt(CuffCrime);
					if(Crime[Player] < CrimeL && IsCombine(Client) && !IsCombine(Player))
					{
						SetHudTextParams(-1.0, 0.035, HUDTICK, 0, 200, 50, 255, 0, 6.0, 0.1, 0.2);
						ShowHudText(Client, -1, "%s\nCrime: %d", PlayName, Crime[Player]);
					}
					if(Crime[Player] >= CrimeL && Crime[Player] < (CrimeL + 550) && IsCombine(Client) && !IsCombine(Player))
					{
						SetHudTextParams(0.015, 0.32, HUDTICK, 255, 150, 25, 255, 0, 6.0, 0.1, 0.2);
						ShowHudText(Client, -1, "%s\nCrime: %d", PlayName, Crime[Player]);
					}
					if(Crime[Player] >= (CrimeL + 550) && IsCombine(Client) && !IsCombine(Player))
					{
						SetHudTextParams(30.0, 0.035, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
						ShowHudText(Client, -1, "%s\nCrime: %d", PlayName, Crime[Player]);
					}
				}
				
				if(Dist <= 250)
				{
					//Setup & Send:
					if(CenterHudColor[Client] == 1)
					{
						SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
					}
					if(CenterHudColor[Client] == 2)
					{
						SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 150, 50, 255, 0, 6.0, 0.1, 0.2);
					}
					if(CenterHudColor[Client] == 3)
					{
						SetHudTextParams(-1.0, -1.0, HUDTICK, 0, 200, 50, 255, 0, 6.0, 0.1, 0.2);
					}
					if(CenterHudColor[Client] == 4)
					{
						SetHudTextParams(-1.0, -1.0, HUDTICK, 0, 150, 200, 255, 0, 6.0, 0.1, 0.2);
					}
					if(CenterHudColor[Client] == 5)
					{
						SetHudTextParams(-1.0, -1.0, HUDTICK, 200, 150, 200, 255, 0, 6.0, 0.1, 0.2);
					}
					if(CenterHudColor[Client] == 6)
					{
						SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 255, 255, 255, 0, 6.0, 0.1, 0.2);
					}
					if(CenterHudColor[Client] == 7)
					{
						SetHudTextParams(-1.0, -1.0, HUDTICK, 200, 150, 0, 255, 0, 6.0, 0.1, 0.2);
					} 
					
					if(IsCombine(Client))
					{	
						if(FreeIn[Player] > 0)
							ShowHudText(Client, -1, "Employment: %s\nIncome: $%d\nBounty: $%d\nWallet: $%d\nBank: $%d\nFree In: %ds", Job[Player], Wages[Player],kopfgeld[Player],Money[Player], Bank[Player],FreeIn[Player]);
						else
							ShowHudText(Client, -1, "Employment: %s\nIncome: $%d\nBounty: $%d\nWallet: $%d\nBank: $%d", Job[Player], Wages[Player],kopfgeld[Player],Money[Player], Bank[Player]);
						
					} else
					{
						if(kopfgeld[Player] > 0)
							ShowHudText(Client, -1, "Employment: %s\nIncome: $%d\nBounty: $%d", Job[Player], Wages[Player],kopfgeld[Player]);
						else
						ShowHudText(Client, -1, "Employment: %s\nIncome: $%d", Job[Player], Wages[Player]);
					}  
				} else 
				if(Dist <= 1000 && kopfgeld[Player] > 0)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2); 
					ShowHudText(Client, -1, "Bounty $%d", kopfgeld[Player]); 
				}      
			}
			
			//NOW CAN GO NEGATIVE!!!!
			//Negative Cash:
			//if(Money[Client] < 0) Money[Client] = 0;
			
			//Client's Hud:
			TickPaycheck(Client);
			decl Float:CriminalOrigin[3];
			new BeamColor[4] = {50, 0, 255, 200}; //3300FF 
			
			if(EnableTracers[Client])
			{
				//Aktienticker
				//showAktien(Client);
				
				//Bounty Tracer
				new AltBeamColor[4] = {255, 100, 100, 200};
				new Alt2BeamColor[4] = {100, 255, 100, 200};
				for(new X = 1; X <= MaxPlayers; X ++)
				{
					if(IsClientConnected(X) && IsClientInGame(X))
					{
						if((kopfgeld[X] > 0 && !IsCombine(Client)) || (IsCombine(Client) && Crime[X] == 0 && kopfgeld[X] > 0))
						{
							if(X != Client)
							{
								GetClientAbsOrigin(X, CriminalOrigin);
								TE_SetupBeamPoints(ClientOrigin, CriminalOrigin, LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, AltBeamColor, 0);
								TE_SendToClient(Client);
							}
						}
						
						if(GPS[Client][X] == 1)
						{
							if(X != Client)
							{
								GetClientAbsOrigin(X, CriminalOrigin);
								TE_SetupBeamPoints(ClientOrigin, CriminalOrigin, LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, Alt2BeamColor, 0);
								TE_SendToClient(Client);
							}
						}
						
						if(ScannerTime[Client] >= GetGameTime())
						{
							if(X != Client && IsCombine(X))
							{
								GetClientAbsOrigin(X, CriminalOrigin);
								TE_SetupBeamPoints(ClientOrigin, CriminalOrigin, LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, BeamColor, 0);
								TE_SendToClient(Client);
							}
						}
					}
				}
			}    
			//Combine/Criminal:
			if(IsCombine(Client) || Crime[Client] > 0)
			{
				
				//Crime HUD:
				SetHudTextParams(3.050, -1.50, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
				
				//Declare:
				new bool:IsCrime = false;
				new String:FormatHud[255] = "Crime:  \n";
				
				//Loop:
				for(new X = 1; X <= MaxPlayers; X ++)
				{
					
					//Connected:
					if(IsClientConnected(X))
					{
						
						//In-Game:
						if(IsClientInGame(X))
						{
							
							//Check:
							if(Crime[X] > 0)
							{
								GetClientAbsOrigin(X, CriminalOrigin);
								CriminalOrigin[2] += 40.0;
								
								//Beam:
								if(IsCombine(Client) && EnableTracers[Client] && InterruptTime[X] < GetGameTime())
								{
									BeamColor = {50, 0, 255, 200}; //3300FF
									//Start:
									if(Crime[X] < 100)
									{
										BeamColor[2] = Crime[X]; 
										BeamColor[0] = Crime[X] / 4;
										BeamColor[1] = 100 - Crime[X];    
									} else
									{
										BeamColor[1] = Crime[X] / 10;
										if(BeamColor[1] > 250) BeamColor[1] = 250;
									}
									TE_SetupBeamPoints(ClientOrigin, CriminalOrigin, LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, BeamColor, 0);
									TE_SendToClient(Client);
								} 
							}
							if(Crime[X] > GetConVarInt(CrimeMenuAmt))
							{
								//Save:
								IsCrime = true;
								
								//Declare:
								decl String:XName[32];
								decl String:TempSave[255];
								
								//Initialize:
								TempSave = FormatHud;
								GetClientName(X, XName, 32);
								
								//Format:
								Format(FormatHud, 255, "%s%s (%d)  \n", TempSave, XName, Crime[X]);
							}
						} 
					}
				}
				
				//Display:
				if(IsCrime && RedCrimeMenu[Client] == 1) ShowHudText(Client, -1, "%s ", FormatHud);  
			}
			
			if(ExpRebel[Client] < 0) ExpRebel[Client] = 0;
			
			//Update:
			if(NoCrime[Client] == 0)
			{
				if(Crime[Client] > 0) Crime[Client] -= 1;
				if(Crime[Client] < 0) Crime[Client] = 0;
			}
			decl Munny;
			Munny = RoundToCeil(Pow(float(Wages[Client]), 3.0)) - Minutes[Client];
			
			if(HudModeMain[Client] == 1)
			{
				//COMAX: CAR HUD
				
				CarsHud(Client);
				
			
				//Normal HUD: 
				if(MainHudColor[Client] == 1)
				{
					SetHudTextParams(0.015, 0.015, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
				}
				if(MainHudColor[Client] == 2)
				{
					SetHudTextParams(0.015, 0.015, HUDTICK, 255, 150, 50, 255, 0, 6.0, 0.1, 0.2);
				}
				if(MainHudColor[Client] == 3)
				{
					SetHudTextParams(0.015, 0.015, HUDTICK, 0, 200, 50, 255, 0, 6.0, 0.1, 0.2);
				}
				if(MainHudColor[Client] == 4)
				{
					SetHudTextParams(0.015, 0.015, HUDTICK, 0, 150, 200, 255, 0, 6.0, 0.1, 0.2);
				}
				if(MainHudColor[Client] == 5)
				{
					SetHudTextParams(0.015, 0.020, HUDTICK, 255, 128, 255, 255, 0, 6.0, 0.1, 0.2);
				}
				if(MainHudColor[Client] == 6)
				{
					SetHudTextParams(0.015, 0.015, HUDTICK, 255, 255, 255, 255, 0, 6.0, 0.1, 0.2);
				}
				if(MainHudColor[Client] == 7)
				{
					SetHudTextParams(0.015, 0.015, HUDTICK, 200, 150, 0, 255, 0, 6.0, 0.1, 0.2);
				}
				if(kopfgeld[Client] > 0)
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nBounty: $%d", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],kopfgeld[Client]);	
				else if(FreeIn[Client] > 0 && IsCuffed[Client])
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nFree In: %ds", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],FreeIn[Client]); 
				
				//Regular HUD with experience mode.
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && !IsCombine(Client) && NoKill[Client] == 3 && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Client) && IsGangster(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nRespect: %d\nLevel: %d\nCrime: %d", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny, ExpRebel[Client], ExpLevel[Client], Crime[Client]);
					//Isn't Gangster:
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && !IsCombine(Client) && NoKill[Client] == 3 && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nLevel: %d\nCrime: %d", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny, ExpLevel[Client], Crime[Client]);
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && IsCombine(Client) && NoKill[Client] == 3 && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nLevel: %d", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny,ExpLevel[Client]);
				//FireFighter (Member)
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && NoKill[Client] == 3 && !IsCombine(Client) && GetConVarInt(ExperienceMode) == 1 && IsFirefighter(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nCrime: %d\nLevel: %d", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny, Crime[Client], ExpLevel[Client]);
				//FireFighter (Chief)
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && NoKill[Client] == 3 && IsCombine(Client) && GetConVarInt(ExperienceMode) == 1 && IsFirefighter(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nLevel: %d", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny,ExpLevel[Client]);
				
				
				//Regular HUD with no experience mode.
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && NoKill[Client] == 3 && GetConVarInt(ExperienceMode) == 0 && IsCombine(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny);
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && NoKill[Client] == 3 && GetConVarInt(ExperienceMode) == 0 && !IsCombine(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nCrime: %d", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny, Crime[Client]);
				
				
				//In NoKill zone with experience mode.
				
				
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && !IsCombine(Client) && NoKill[Client] == 6 && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nLevel: %d\n\n[No Kill Zone]", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny, ExpRebel[Client]);
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && IsCombine(Client) && NoKill[Client] == 6 && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\nExp: %d\n\n[No Kill Zone]", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny, ExpCombine[Client]);
				//FireFighter
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && NoKill[Client] == 6 && GetConVarInt(ExperienceMode) == 1 && IsFirefighter(Client))
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\n\n[No Kill Zone]", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny);
				
				//In NoKill zone with no experience mode.
				else if(FreeIn[Client] == 0 && !IsCuffed[Client] && NoKill[Client] == 6 && GetConVarInt(ExperienceMode) == 0)
					ShowHudText(Client, -1, "Wallet: $%d\nBank: $%d\nEmployment: %s\nIncome: $%d in %d\nNext Promotion: %d min\n\n[No Kill Zone]", Money[Client], Bank[Client], Job[Client], Wages[Client], Paycheck[Client],Munny);
			}
		}
		else
		{
			
			//Unemployed HUD:
			ExplodeString(JoinMessage, "^", Lines, 10, 255);
			
			SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 150, 50, 255, 0, 6.0, 0.1, 0.2);
			ShowHudText(Client, -1, "%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", Lines[0], Lines[1], Lines[2], Lines[3], Lines[4], Lines[5], Lines[6], Lines[7], Lines[8], Lines[9], Lines[10]);
			
			//You must find the employer.....Dynamic mod now lol
			//JobMenu(Client);
		}
		
		if(HudModeCenter[Client] == 1) showNotice(Client);
		
		//Loop:
		CreateTimer(HUDTICK, DisplayHud, Client);
		
		//Return:
		return Plugin_Handled;
	} else if(GetConVarInt(h_showhud) == 0)
	{
		CreateTimer(HUDTICK, DisplayHud, Client); //Loop HUD if cvar = 0.
	}
	
	//Disconnect:
	return Plugin_Handled;
}

stock showNotice(Client)
{
	decl Ent;
	Ent = GetClientAimTarget(Client,false);
	
	if(Ent > 0)
	{ 
		decl Float:ClientOrigin[3], Float:EntOrigin[3];  
		decl Float:Dist; 
		GetClientAbsOrigin(Client, ClientOrigin);
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);
		Dist = GetVectorDistance(ClientOrigin, EntOrigin);
		
		if(Dist <= 800)
		{
			if(!StrEqual(Notice[Ent], "null", false))
			{
				if(CenterHudColor[Client] == 1)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 0, 0, 255, 0, 6.0, 0.1, 0.2);
				}
				if(CenterHudColor[Client] == 2)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 150, 50, 255, 0, 6.0, 0.1, 0.2);
				}
				if(CenterHudColor[Client] == 3)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 0, 200, 50, 255, 0, 6.0, 0.1, 0.2);
				}
				if(CenterHudColor[Client] == 4)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 0, 150, 200, 255, 0, 6.0, 0.1, 0.2);
				}
				if(CenterHudColor[Client] == 5)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 200, 150, 200, 255, 0, 6.0, 0.1, 0.2);
				}
				if(CenterHudColor[Client] == 6)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 255, 255, 255, 255, 0, 6.0, 0.1, 0.2);
				}
				if(CenterHudColor[Client] == 7)
				{
					SetHudTextParams(-1.0, -1.0, HUDTICK, 200, 150, 0, 255, 0, 6.0, 0.1, 0.2);
				} 
				ShowHudText(Client, -1, "%s", Notice[Ent]);
			}
		}
	}
}

stock showAktien(Client)
{   
	if(TickId[Client] < 20) TickId[Client] += 1; else TickId[Client] = 1;
	new TickIt = RoundToFloor(FloatDiv(float(TickId[Client]),3.0));
	new ItemId = 100+TickIt;
	new ItemPrice = RoundToCeil(FloatMul(FloatMul(float(ItemCost[ItemId]),AuctItems[106-ItemId]),AuctVendor));  
	SetHudTextParams(0.95,0.015, HUDTICK, 200, 200, 200, 150, 0, 6.0, 0.1, 0.2);
	ShowHudText(Client, -1, "Stocks:\n%s for %d$",ItemName[ItemId],ItemPrice); 
}

//Job Menu:
public Action:JobMenu(Client)
{
	//Connected:
	if(!IsClientConnected(Client) || !IsClientInGame(Client))
	{	
		return Plugin_Handled;
	}
	
	//Alive:
	if(!IsPlayerAlive(Client))
	{
		return Plugin_Handled;
	}
	
	if(IsCombine(Client) || IsFirefighter(Client))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Use !switch to change your job.");
		return Plugin_Handled;
	}
	
	if(!StrEqual(Job[Client], DEFAULTJOB, false))
	{
		decl Handle:Check;
		Check = CreateKeyValues("Vault");
		FileToKeyValues(Check, JobPath);
		for(new c = 0; c < MAXJOBS; c++)
		{
			decl String:CheckId[255], String:CheckJob[255];
			IntToString(c, CheckId, 255);
			LoadString(Check, "1", CheckId, "Null", CheckJob);
			if(StrEqual(CheckJob, Job[Client], false))
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Use !switch to change your job.");
				CloseHandle(Check);
				return Plugin_Handled;
			}
		}
		CloseHandle(Check);
	}
	
	new Handle:PickingJob = CreateMenu(JobMenuCreate);
	SetMenuTitle(PickingJob, "Job Employer:\n=============\nPick a Job!");
	decl Handle:Vault;
	
	//Initialize:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, JobPath);
	
	//Loop:
	for(new X = 1; X < MAXJOBS; X++)
	{
		//Declare:
		decl String:JobId[255];
		decl String:ReferenceJob[255];
		
		//Convert:
		IntToString(X, JobId, 255);
		
		//Load:
		LoadString(Vault, "0", JobId, "Null", ReferenceJob);
		
		//Found:
		if(!StrEqual(ReferenceJob, "Null"))
		{
			AddMenuItem(PickingJob, JobId, ReferenceJob);
		}
	}
	CloseHandle(Vault);
	SetMenuPagination(PickingJob, 7);
	DisplayMenu(PickingJob, Client, 30);
	//Return:
	return Plugin_Handled;
}

//Start:
public Action:HandleSay(Client, Args)
{
	
	//World:
	if(Client == 0) return Plugin_Handled;
	
	//Declare:
	decl String:Arg[255];
	
	//Initialize:
	GetCmdArgString(Arg, sizeof(Arg));
	
	//Clean:
	StripQuotes(Arg);
	TrimString(Arg);
	
	//Unemployed
	if(StrEqual(Job[Client], DEFAULTJOB))
	{
		if(StrContains(Arg, "!jobmenu", false) == 0 || StrContains(Arg, "/jobmenu", false) == 0)
		{
			//Send Menu
			JobMenu(Client);
			
			//Return
			return Plugin_Handled;
		}
	}
	else if(StrContains(Arg, "!jobmenu", false) == 0 || StrContains(Arg, "/jobmenu", false) == 0)
	{
		//Print
		CPrintToChat(Client, "{white}|RP| -{grey} You must talk to an employer to open the job menu.");
			
		//Return
		return Plugin_Handled;
	}
	
	if(StrContains(Arg, "/stats", false) == 0 || StrContains(Arg, "!stats", false) == 0)
	{
		decl String:ClientName[MAX_NAME_LENGTH];
		GetClientName(Client, ClientName, sizeof(ClientName));
		
		//Print
		CPrintToChatAll("{white}|RP| -{grey} %s's Stats:{white}\n============================\n{grey}Bank: {green}$%d\n{grey}Income: {green}$%d{grey}\nLevel: {green}%d{grey}\nCuffs: {green}%d{grey}\nTotal Plants: {green}%d{white}\n============================", ClientName, Bank[Client], Wages[Client], ExpLevel[Client], CuffCount[Client], Planted[Client]);
		//Return
		return Plugin_Handled;
	}
	//Cuffed:
	if(!IsCuffed[Client])
	{
		
		//Items:
		if(StrContains(Arg, "/items", false) == 0 || StrContains(Arg, "!items", false) == 0 || StrContains(Arg, "/inventory", false) == 0 || StrContains(Arg, "!inventory", false) == 0 || StrContains(Arg, "/item", false) == 0 || StrContains(Arg, "!item", false) == 0)
		{		
			//Inventory:
			Inventory(Client);
			IsGiving[Client] = false;
			
			//Return:
			return Plugin_Handled;
		}
		if(StrContains(Arg, "!writecheck", false) == 0 || StrContains(Arg, "/writecheck", false) == 0)
		{
			if(NumChecks[Client] == 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You've ran out of checks. Go to the bank to buy more check books");
				return Plugin_Handled;
			}
			CheckMenu(Client, 0);
			return Plugin_Handled;
		}
		if(StrContains(Arg, "!buydoor", false) == 0 || StrContains(Arg, "/buydoor", false) == 0)
		{
			decl Entdoor;
			Entdoor = GetClientAimTarget(Client, false);
			BuyDoorFunction(Client, Entdoor);
		}
		if(StrContains(Arg, "!selldoor", false) == 0 || StrContains(Arg, "/selldoor", false) == 0)
		{
			decl Entdoor;
			Entdoor = GetClientAimTarget(Client, false);
			SellDoorFunction(Client, Entdoor);
		}
		if(StrContains(Arg, "/exitafk", false) == 0)
		{
			if(AfkClient[Client] == 1 && AnyExit == 1)
			{
				TeleportEntity(Client, ExitOrigin, NULL_VECTOR, NULL_VECTOR);
				CPrintToChat(Client, "{white}|RP| -{grey} You're free from the afk room.");
				AfkClient[Client] = 0;
			}
			else if(AfkClient[Client] == 1 && AnyExit == 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Server has not created an exit coordinate.");
				AfkClient[Client] = 0;
				ForcePlayerSuicide(Client);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Access Denied.");
			}
			return Plugin_Handled;
		}
		if(StrContains(Arg, "/minutes", false) == 0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You have spent %d minutes in this server.", Minutes[Client]);
			return Plugin_Handled;
		}
		//Items:
		if(StrContains(Arg, "/on", false) == 0 && IsFirefighter(Client))
		{
			WaterOn(Client);
			return Plugin_Handled;
		}
		if(StrContains(Arg, "/off", false) == 0 && IsFirefighter(Client))
		{
			WaterOff(Client);
			return Plugin_Handled;
		}
		if(StrContains(Arg, "/city_racism_allowed", false) == 0 && IsOfficial(Client))
		{
			CPrintToChat(Client, "Server cvar 'city_racism' changed to allowed");
			CPrintToChat(Client, "{white}|RP| -{grey} Racism is now: {green}Allowed.");
			return Plugin_Handled;
		}
		if(StrContains(Arg, "/city_foullanguage_allowed", false) == 0 && IsOfficial(Client))
		{
			CPrintToChat(Client, "Server cvar 'city_foul_language' changed to allowed");
			CPrintToChat(Client, "{white}|RP| -{grey} Foul Language is now: {green}Allowed.");
		}
		if(StrContains(Arg, "/city_racism_disallowed", false) == 0 && IsOfficial(Client))
		{
			CPrintToChat(Client, "Server cvar 'city_racism' changed to illegal");
			CPrintToChat(Client, "{white}|RP| -{grey} Racism is now: {green}Illegal.");
			return Plugin_Handled;
		}
		if(StrContains(Arg, "/city_foullanguage_disallowed", false) == 0 && IsOfficial(Client))
		{
			CPrintToChat(Client, "Server cvar 'city_foul_language' changed to illegal");
			CPrintToChat(Client, "{white}|RP| -{grey} Foul Language is now: {green}Illegal.");
		}
		if((StrContains(Arg, "/dispose", false) == 0 || StrContains(Arg, "!dispose", false) == 0) && IsFirefighter(Client))
		{
			decl Ent;
			Ent = GetClientAimTarget(Client, false);
			if(Ent > 0)
			{
				decl String:modelname[128];
				GetEntPropString(Ent, Prop_Data, "m_ModelName", modelname, 128);
				if(StrEqual(modelname, "models/props_lab/reciever01b.mdl", false))
				{
					if(BombData[Ent][1] == 0)
					{
						BombEvent1(Ent, Client);
						return Plugin_Handled;
					}
					if(BombData[Ent][1] != 0)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} Wrong Action!");
						return Plugin_Handled;
					}
				}
				CPrintToChat(Client, "{white}|RP| -{grey} This item is not a bomb.");
				return Plugin_Handled;
			}
			return Plugin_Handled;
		}
		if((StrContains(Arg, "/defuse", false) == 0 || StrContains(Arg, "!defuse", false) == 0) && IsFirefighter(Client))
		{
			decl Ent;
			Ent = GetClientAimTarget(Client, false);
			if(Ent > 0)
			{
				decl String:modelname[128];
				GetEntPropString(Ent, Prop_Data, "m_ModelName", modelname, 128);
				if(StrEqual(modelname, "models/props_lab/reciever01b.mdl", false))
				{
					if(BombData[Ent][1] == 1)
					{
						BombEvent2(Ent, Client);
						return Plugin_Handled;
					}
					if(BombData[Ent][1] != 1)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} Wrong Action!");
						return Plugin_Handled;
					}
				}
				CPrintToChat(Client, "{white}|RP| -{grey} This item is not a bomb.");
				return Plugin_Handled;
			}
			return Plugin_Handled;
		}
		if(StrContains(Arg, "/telekill", false) == 0 || StrContains(Arg, "!telekill", false) == 0)
		{
			if(StrEqual(Job[Client], "Scientist", false))
			{
				TeleStartOrigin[Client][0] = 0.0;
				TeleEndOrigin[Client][0] = 0.0;
				CPrintToChat(Client, "{white}|RP-Scientist| -{grey}  Teleport deleted.");
				ClientCommand(Client, "play buttons/button19.wav");
				return Plugin_Handled;
			}
		}
		if(StrContains(Arg, "/telestart", false) == 0 || StrContains(Arg, "!telestart", false) == 0) 
		{
			if(StrEqual(Job[Client], "Scientist", false))
			{
				GetClientAbsOrigin(Client, TeleStartOrigin[Client]);
				TeleStartOrigin[Client][2] += 20.0;
				CPrintToChat(Client, "{white}|RP-Scientist| -{grey}  Created teleport entrance.");
				ClientCommand(Client, "play buttons/blip1.wav");
				return Plugin_Handled;
			}
		}
		if(StrContains(Arg, "/teleend", false) == 0 || StrContains(Arg, "!teleend", false) == 0)
		{
			if(StrEqual(Job[Client], "Scientist", false))
			{
				GetClientAbsOrigin(Client, TeleEndOrigin[Client]);
				TeleEndOrigin[Client][2] += 20.0;
				CPrintToChat(Client, "{white}|RP-Scientist| -{grey}  Created teleport ending.");
				ClientCommand(Client, "play buttons/blip1.wav");
				return Plugin_Handled;
			}
		}
		if(StrContains(Arg, "/garbage", false) == 0 || StrContains(Arg, "!garbage", false) == 0)
		{
			if(StrEqual(Job[Client], "Sanitation", false))
			{
				decl Float:ClientOrigin[3];
				GetClientAbsOrigin(Client, ClientOrigin);
				ClientOrigin[2] += 20.0;
				TE_SetupBeamPoints(ClientOrigin, GarbageOrigin, LaserCache, 0, 0, 66, 3.0, 3.0, 3.0, 0, 0.0, TeleColor1, 0);
				TE_SendToClient(Client);
				CPrintToChat(Client, "{white}|RP| -{grey} Follow the green beam to find the garbage zone.");
				return Plugin_Handled;
			}
		}
		if(StrContains(Arg, "/plant", false) == 0 || StrContains(Arg, "!plant", false) == 0)
		{
			if(StrEqual(Job[Client], "Drug Addict", false))
			{
				if(Money[Client] > 299)
				{
					decl Float:ClientOrigin[3];
					GetClientAbsOrigin(Client, ClientOrigin);
					for(new X = 0; X < GetConVarInt(MaxPlants); X++)
					{
						if(DrugPlant[Client][X][0] == 0.0)
						{
							decl Float:DOrigin[3];
							GetClientAbsOrigin(Client, DOrigin);
							DrugPlant[Client][X][0] = DOrigin[0];
							DrugPlant[Client][X][1] = DOrigin[1];
							DrugPlant[Client][X][2] = DOrigin[2] + 5.0;
							Money[Client] -= 299;
							AddCrime(Client, 150);
							DrugPlantWorth[Client][X] = 0;
							CPrintToChat(Client, "{white}|RP-Drug| -{grey} Planted a seed.");
							
							decl Ent;
							Ent = CreateEntityByName("prop_physics_override");
							//DispatchKeyValue(Ent, "physdamagescale", "0.0");
							DispatchKeyValue(Ent, "solid", "0");
							DispatchKeyValue(Ent, "model", "models/props_lab/cactus.mdl");
							DispatchSpawn(Ent);
							SetEntData(Ent, SolidGroup, 2, 4, true);
							TeleportEntity(Ent, DrugPlant[Client][X], NULL_VECTOR, NULL_VECTOR);
							DOrigin[2] += 30.0;
							TeleportEntity(Client, DOrigin, NULL_VECTOR, NULL_VECTOR);
							DrugEnt[Client][X] = Ent;
							SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);
							AcceptEntityInput(Ent, "DisableMotion");
							Planted[Client] += 1;
							CheckPlanted(Client);
							return Plugin_Handled;
						}
					}
					CPrintToChat(Client, "{white}|RP-Drug| -{grey} You can only plant %d seeds at a time.", GetConVarInt(MaxPlants));
				}
				else
				{
					CPrintToChat(Client, "{white}|RP-Drug| -{grey} You do not have $300.");
				}
			}
		}
		
		/*if(StrContains(Arg, "/models", false) == 0 || StrContains(Arg, "!models", false) == 0)
		{
			if(StrContains(Job[Client], "Donator", false) != -1)
			{
				new Handle:DonatorModels = CreateMenu(CustomModels);
				SetMenuTitle(DonatorModels, "Donator Models:\n=============\n");
				
				decl Handle:Models;
				Models = CreateKeyValues("Donator Models");
				FileToKeyValues(Models, ModelsPath);
				
				decl String:ModelNumber[255], String:ModelNAME[255];
				for(new X = 1; X < 50; X++)
				{
					IntToString(X, ModelNumber, sizeof(ModelNumber));
					LoadString(Models, "names", ModelNumber, "Null", ModelNAME);
					if(!StrEqual(ModelNAME, "Null"))
					{
						AddMenuItem(DonatorModels, ModelNumber, ModelNAME);
					}
				}
				CloseHandle(Models);
				
				SetMenuPagination(DonatorModels, 7);
				DisplayMenu(DonatorModels, Client, 30);
				CPrintToChat(Client, "{white}|RP| -{grey} Press <Escape> to access the model menu");
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You are not a donator!");
			}
			return Plugin_Handled;
		}*/
		if(StrContains(Arg, "/type", false) == 0 || StrContains(Arg, "!type", false) == 0)
		{
			if(StrContains(Job[Client], "Salesman", false) != -1)
			{
				new Handle:Type = CreateMenu(SalesTypes);
				SetMenuTitle(Type, "Types of Salesman:\n=============\n");
				
				AddMenuItem(Type, "1", "-|Weapons|-"); //1
				AddMenuItem(Type, "2", "-|Alcohol and Drugs|-"); //2-3
				AddMenuItem(Type, "3", "-|Food|-"); //4
				AddMenuItem(Type, "4", "-|Locks and Cuffs|-");  //5-9-13-14
				AddMenuItem(Type, "5", "-|Furniture|-"); //7
				AddMenuItem(Type, "6", "-|Med Kits|-"); //8
				AddMenuItem(Type, "7", "-|HUD Stuff|-"); //20-21
				AddMenuItem(Type, "8", "-|Skins and Trails|-"); //22-23
				
				SetMenuPagination(Type, 7);
				DisplayMenu(Type, Client, 30);
				CPrintToChat(Client, "{white}|RP| -{grey} Press <Escape> to access the menu.");
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You are not a salesman!");
			}
			return Plugin_Handled;
		}
	}
	//Tracers:
	if(StrContains(Arg, "/tracers", false) == 0)
	{
		
		//Action:
		EnableTracers[Client] = !EnableTracers[Client];
		
		//Print:
		CPrintToChat(Client, "{white}|RP| -{grey} Tracers have been toggled");
	}
	/*
	if(StrContains(Arg, "/kill", false) == 0)
	{
	if(!IsCuffed[Client])
	{
	decl ClientID;
	ClientID = GetClientUserId(Client);
	//Initialize:
	LooseMoney[Client] = true;
	//Send:
	ServerCommand("sm_slay #%d 1", ClientID);
	}
	}
	*/
	if(StrContains(Arg, "/mainhud", false) == 0)
	{
		if(HudModeMain[Client] == 1)
		{
			HudModeMain[Client] = 0;
			CPrintToChat(Client, "{white}|RP| -{grey} Main Hud is now hidden");
			return Plugin_Handled;
		}
		if(HudModeMain[Client] == 0)
		{
			HudModeMain[Client] = 1;
			CPrintToChat(Client, "{white}|RP| -{grey} Main Hud is now visible");
			return Plugin_Handled;
		}
	}
	
	if(StrContains(Arg, "/centerhud", false) == 0)
	{
		if(HudModeCenter[Client] == 1)
		{
			HudModeCenter[Client] = 0;
			CPrintToChat(Client, "{white}|RP| -{grey} Center Hud is now hidden");
			return Plugin_Handled;
		}
		if(HudModeCenter[Client] == 0)
		{
			HudModeCenter[Client] = 1;
			CPrintToChat(Client, "{white}|RP| -{grey} Center Hud is now visible");
			return Plugin_Handled;
		}
	}
	
	
	if(StrContains(Arg, "/crimehud", false) == 0 && IsCombine(Client))
	{
		if(RedCrimeMenu[Client] == 1)
		{
			RedCrimeMenu[Client] = 0;
			CPrintToChat(Client, "{white}|RP| -{grey} Crime Hud is now hidden");
			return Plugin_Handled;
		}
		if(RedCrimeMenu[Client] == 0)
		{
			RedCrimeMenu[Client] = 1;
			CPrintToChat(Client, "{white}|RP| -{grey} Crime Hud is now visible");
			return Plugin_Handled;
		}
	}
	
	if(StrContains(Arg, "/bribe", false) == 0)
	{
		BribeFunc(Client);
		return Plugin_Handled;
	}
	
	//Cuffed:
	if(IsCuffed[Client]) CPrintToChat(Client, "{white}|RP| -{grey} Dont forget - youre Cuffed");
	
	return Plugin_Continue;
}

public SalesTypes(Handle:Type, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:mode[255];
		GetMenuItem(Type, param2, mode, sizeof(mode));
		
		SalesMan[Client] = StringToInt(mode);
		
		if(SalesMan[Client] == 1) CPrintToChat(Client, "{white}|RP| -{grey} You are now a weapons dealer.");
		else if(SalesMan[Client] == 2) CPrintToChat(Client, "{white}|RP| -{grey} You are now a alcohol & drugs dealer.");
		else if(SalesMan[Client] == 3) CPrintToChat(Client, "{white}|RP| -{grey} You are now a food dealer.");
		else if(SalesMan[Client] == 4) CPrintToChat(Client, "{white}|RP| -{grey} You are now a lock & cuff dealer.");
		else if(SalesMan[Client] == 5) CPrintToChat(Client, "{white}|RP| -{grey} You are now a furniture dealer.");
		else if(SalesMan[Client] == 6) CPrintToChat(Client, "{white}|RP| -{grey} You are now a med kit dealer.");
		else if(SalesMan[Client] == 7) CPrintToChat(Client, "{white}|RP| -{grey} You are now a HUD dealer.");
		else if(SalesMan[Client] == 8) CPrintToChat(Client, "{white}|RP| -{grey} You are now a skins & trails dealer.");
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Type);
	}
	return 0;
}

stock BribeFunc(Client)
{
	if(IsCombine(Client))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You are a cop!");
	}
	else
	{
		if(FreeIn[Client] > 0) //Autofree
		{
			decl MaxPlayers;
			decl bool:CombineInGame;
			decl Target;
			Target = -1;
			
			decl Float:ClientOrigin[3], Float:CopOrigin[3];  
			decl Float:Distance; 
			GetClientAbsOrigin(Client, ClientOrigin);
			
			MaxPlayers = GetMaxClients();
			CombineInGame = false;
			
			for(new X = 1; X <= MaxPlayers; X++)
			{
				if(StrContains(Job[X], "Police", false) != -1 || StrContains(Job[X], "SWAT", false) != -1 || StrContains(Job[X], "Admin", false) != -1)
				{
					if(IsClientConnected(X) && IsClientInGame(X))
					{
						GetClientAbsOrigin(X, CopOrigin);
						Distance = GetVectorDistance(ClientOrigin, CopOrigin);
						if(Distance < 300)
						{
							CombineInGame = true;
							Target = X;
						}
					}
				}
			}
			
			if(!CombineInGame || Target == -1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} There are no police near you to bribe!");
			}
			else if(Money[Client] < 1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You do not have money.");
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Press <escape> to send a bribe amount");
				
				decl String:CopName[64];
				GetClientName(Target, CopName, sizeof(CopName));
				
				new Handle:Bribem = CreateMenu(ConfirmBribe);
				SetMenuTitle(Bribem, "Send a bribe to %s:\n=============\nWallet: $%d\n\nPlease click an amount!", CopName, Money[Client]);
				
				decl String:MoneyAll[15];
				Format(MoneyAll, sizeof(MoneyAll), "All ($%d)", Money[Client]);
				AddMenuItem(Bribem, "99", MoneyAll);
				AddMenuItem(Bribem, "25", "$25");
				AddMenuItem(Bribem, "50", "$50");
				AddMenuItem(Bribem, "100", "$100");
				AddMenuItem(Bribem, "200", "$200");
				AddMenuItem(Bribem, "500", "$500");
				AddMenuItem(Bribem, "1000", "$1000");
				SetMenuPagination(Bribem, 7);
				DisplayMenu(Bribem, Client, 30);
				Bribe[Client] = Target;
			}
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You are not in jail");
		}
	}
}

public ConfirmBribe(Handle:Bribem, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[255];
		GetMenuItem(Bribem, param2, info, sizeof(info));
		
		if(StringToInt(info) > Money[Client])
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You do not have %s", info);
		}
		else
		{
			if(IsClientConnected(Bribe[Client]) && IsClientInGame(Bribe[Client]) && IsCombine(Bribe[Client]))
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Sent a bribe confirmation");
				CPrintToChat(Bribe[Client], "{white}|RP| -{grey} A bribe has been received.  Press <escape> to view offer");
				
				decl String:BribeName[64];
				GetClientName(Client, BribeName, sizeof(BribeName));
				
				if(StringToInt(info) != 99)
				{
					BribeAmt[Client] = StringToInt(info);
				}
				else
				{
					BribeAmt[Client] = Money[Client];
				}
				
				new Handle:Terms = CreateMenu(ConfirmFree);
				SetMenuTitle(Terms, "A Bribe has been recieved\n=============\nName: %s\nAmount: $%d\n\nClick accept or decline to the bribe", BribeName, BribeAmt[Client]);
				AddMenuItem(Terms, "1", "Accept");
				AddMenuItem(Terms, "2", "Decline");
				SetMenuPagination(Terms, 7);
				DisplayMenu(Terms, Bribe[Client], 30);
				
				//Cops bribe person:
				Bribe[Bribe[Client]] = Client;
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Cop has left the game");
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Bribem);
	}
	return 0;
}

public ConfirmFree(Handle:Terms, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[255];
		GetMenuItem(Terms, param2, info, sizeof(info));
		
		if(IsClientConnected(Bribe[Client]) && IsClientInGame(Bribe[Client]))
		{
			if(IsCombine(Bribe[Client]))
			{
				CPrintToChat(Client, "{white}|RP| -{grey} The player has joined the combine team");
			}
			//else if(Autofree[Bribe[Client]] == 0 || !IsCuffed[Bribe[Client]])
			else if(FreeIn[Bribe[Client]] == 0 || !IsCuffed[Bribe[Client]])
			{
				CPrintToChat(Client, "{white}|RP| -{grey} The player is not in jail anymore");
			}
			else if(StringToInt(info) == 1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Accepted bribe. Recieved $%d", BribeAmt[Bribe[Client]]);
				CPrintToChat(Bribe[Client], "{white}|RP| -{grey} Your bribe has been accepted.");
				Money[Bribe[Client]] -= BribeAmt[Bribe[Client]];
				Money[Client] += BribeAmt[Bribe[Client]];
				autofreeExec(Bribe[Client]);
			}
			else
			{
				CPrintToChat(Bribe[Client], "{white}|RP| -{grey} Your offer has been declined");
			}
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Player has left the game");
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Terms);
	}
	return 0;
}

public Action:BuyDoorFunction(Client, Entdoor)
{
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	if(SkinDoor[Entdoor] > 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This is a custom door. You must ask an admin to buy this door.");
		return Plugin_Handled;
	}
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl Buyable;
	
	decl Handle:BuyDoor;
	BuyDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(BuyDoor, DoorBuyPath);
	KvJumpToKey(BuyDoor, DoorStringN, false);
	Buyable = KvGetNum(BuyDoor, "Buyable", 0);
	
	if(Buyable == 0 || Buyable == 99)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This door is not buyable or sellable. Try another time");		
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	if(Buyable == 2)
	{
		decl Ownerhere;
		Ownerhere = 0;
		decl Max;
		decl String:Owner[255];
		KvGetString(BuyDoor, "Owner", Owner, 255, ERROR);
		Max = GetMaxClients();
		new Target = -1;
		for(new i=1; i <= Max; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i))
			{
				decl String:Ste[255];
				GetClientAuthString(i, Ste, 255);
				if(StrEqual(Ste, Owner, false))
				{
					Ownerhere = 1;
					Target = i;
				}
			}
		}
		if(Ownerhere != 1)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} The owner of this house must be here while you buy it");
			KvRewind(BuyDoor);
			CloseHandle(BuyDoor);
			return Plugin_Handled;
		}
		decl String:AmountHouse[255];
		KvGetString(BuyDoor, "Amount", AmountHouse, 255, NOAMOUNT);
		decl Num;
		Num = StringToInt(AmountHouse);
		if(Bank[Client] >= Num && Num != 0)
		{
			Bank[Client] = Bank[Client] - Num;
			Bank[Target] = Bank[Target] + Num;
			decl String:SteamId2[255];
			GetClientAuthString(Client, SteamId2, 255);
			
			decl Handle:SetupDoor;
			SetupDoor = CreateKeyValues("Vault");
			FileToKeyValues(SetupDoor, DoorPathadd);
			KvJumpToKey(SetupDoor, DoorStringN, true);
			//KvSetNum(SetupDoor, Owner, 0);
			KvDeleteKey(SetupDoor, Owner);
			
			KvSetNum(SetupDoor, SteamId2, 1);
			KvRewind(SetupDoor);
			KeyValuesToFile(SetupDoor, DoorPathadd);
			CloseHandle(SetupDoor);
			
			KvRewind(BuyDoor);
			KvJumpToKey(BuyDoor, DoorStringN, true);
			KvDeleteThis(BuyDoor);
			KvRewind(BuyDoor);
			KvJumpToKey(BuyDoor, DoorStringN, true);
			decl String:DoorAmount[255];
			IntToString(Num, DoorAmount, 255);
			KvSetString(BuyDoor, "Amount", DoorAmount);
			KvSetString(BuyDoor, "Owner", SteamId2);
			KvSetNum(BuyDoor, "Buyable", NOTBUYABLE);
			//KvSetString(BuyDoor, "1", "noone");
			//KvSetString(BuyDoor, "2", "noone");
			//KvSetString(BuyDoor, "3", "noone");
			for(new X = 1; X <= 50; X++)
			{
				decl String:IdKey[10];
				IntToString(X, IdKey, 10);
				KvDeleteKey(BuyDoor, IdKey);
			}
			KvRewind(BuyDoor);
			KeyValuesToFile(BuyDoor, DoorBuyPath);
			CloseHandle(BuyDoor);
			CPrintToChat(Client, "{white}|RP| -{grey} You successfully bought it for: $%d", Num);
			CPrintToChat(Client, "{white}|RP| -{grey} Giving Key Access in 5 seconds...");
			CPrintToChat(Client, "{white}|RP| -{grey} If you do not like your door message, use the console command: sm_doorname change it up");
			new String:NameSs[255];
			GetClientName(Client, NameSs, 255);
			decl String:OwnerMess[255];
			Format(OwnerMess, 255, "%s's House", NameSs);
			decl Handle:Mess;
			Mess = CreateKeyValues("Vault");
			FileToKeyValues(Mess, Noticeadd);
			KvJumpToKey(Mess, "Owner", true);
			KvSetString(Mess, DoorStringN, OwnerMess);
			KvRewind(Mess);
			KeyValuesToFile(Mess, Noticeadd);
			CloseHandle(Mess);
			
			ApplyMessage(Entdoor, OwnerMess);
			
			CPrintToChat(Target, "{white}|RP| -{grey} Someone has bought your house");
			CPrintToChat(Target, "{white}|RP| -{grey} Losing Key Access in 5 seconds...");
			ServerCommand("sm_refreshdoors");
			
			return Plugin_Handled;
		}			
		CPrintToChat(Client, "{white}|RP| -{grey} You do not have enough money in the bank to buy this house");
		return Plugin_Handled;
	}
	
	
	decl String:AmountHouse[255];
	KvGetString(BuyDoor, "Amount", AmountHouse, 255, NOAMOUNT);
	
	decl Num;
	Num = StringToInt(AmountHouse);
	
	if(Bank[Client] >= Num && Num != 0)
	{
		decl String:SteamId[255];
		GetClientAuthString(Client, SteamId, 255);
		
		Bank[Client] = Bank[Client] - Num;
		KvSetNum(BuyDoor, "Buyable", NOTBUYABLE);
		KvSetString(BuyDoor, "Owner", SteamId);
		//KvSetString(BuyDoor, "1", "noone");
		//KvSetString(BuyDoor, "2", "noone");
		//KvSetString(BuyDoor, "3", "noone");
		for(new X = 1; X <= 50; X++)
		{
			decl String:IdKey[10];
			IntToString(X, IdKey, 10);
			KvDeleteKey(BuyDoor, IdKey);
		}
		KvRewind(BuyDoor);
		KeyValuesToFile(BuyDoor, DoorBuyPath);
		CloseHandle(BuyDoor);
		CPrintToChat(Client, "{white}|RP| -{grey} You successfully bought it for: $%d", Num);
		CPrintToChat(Client, "{white}|RP| -{grey} Giving Key Access in 5 seconds...");
		CPrintToChat(Client, "{white}|RP| -{grey} If you do not like your door message, use the console command: sm_doorname to change it up");
		
		new String:NameS[255];
		GetClientName(Client, NameS, 255);
		decl String:OwnerMess[255];
		Format(OwnerMess, 255, "%s's House", NameS);
		decl Handle:Mess;
		Mess = CreateKeyValues("Vault");
		FileToKeyValues(Mess, Noticeadd);
		KvJumpToKey(Mess, "Owner", true);
		KvSetString(Mess, DoorStringN, OwnerMess);
		KvRewind(Mess);
		KeyValuesToFile(Mess, Noticeadd);
		CloseHandle(Mess);
		ApplyMessage(Entdoor, OwnerMess);
		
		decl Handle:SetupDoor;
		SetupDoor = CreateKeyValues("Vault");
		FileToKeyValues(SetupDoor, DoorPathadd);
		KvJumpToKey(SetupDoor, DoorStringN, true);
		KvSetNum(SetupDoor, SteamId, 1);
		KvRewind(SetupDoor);
		//KvJumpToKey(SetupDoor, SteamId, true);
		//KvSetNum(SetupDoor, DoorStringN, 0);
		//KvRewind(SetupDoor);
		KeyValuesToFile(SetupDoor, DoorPathadd);
		CloseHandle(SetupDoor);
		ServerCommand("sm_refreshdoors");
		
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You do not have enough money in the bank to buy this house");
	return Plugin_Handled;
}

public Action:SellDoorFunction(Client, Entdoor)
{
	decl Check;
	decl Check2;
	decl String:Worth[255];
	decl String:SteamIds[255];
	GetClientAuthString(Client, SteamIds, 255);
	
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	if(SkinDoor[Entdoor] > 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This is a custom door. You must ask an admin to sell this door.");
		return Plugin_Handled;
	}
	decl String:DoorStringN2[255];
	IntToString(Entdoor, DoorStringN2, 255);
	
	decl Handle:SellDoor;
	SellDoor = CreateKeyValues("Vault");
	FileToKeyValues(SellDoor, DoorPathadd);
	KvJumpToKey(SellDoor, DoorStringN2, false);
	Check = KvGetNum(SellDoor, SteamIds, 0);
	if(Check == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot sell a door when you don't own it");
		KvRewind(SellDoor);
		CloseHandle(SellDoor);
		return Plugin_Handled;
	}
	
	decl Handle:SetDoor;
	SetDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(SetDoor, DoorBuyPath);
	KvJumpToKey(SetDoor, DoorStringN2, false);
	Check2 = KvGetNum(SetDoor, "Buyable", 99);
	if(Check2 == 99)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This door is not made to be buyable or sellable");
		KvRewind(SetDoor);
		KeyValuesToFile(SetDoor, DoorBuyPath);
		CloseHandle(SetDoor);
		KvRewind(SellDoor);
		CloseHandle(SellDoor);
		return Plugin_Handled;
	}
	
	decl String:Owner[255];
	KvGetString(SetDoor, "Owner", Owner, 255, ERROR);
	decl String:Ste[255];
	GetClientAuthString(Client, Ste, 255);
	if(!StrEqual(Ste, Owner, false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
		KvRewind(SetDoor);
		CloseHandle(SetDoor);
		KvRewind(SellDoor);
		CloseHandle(SellDoor);
		return Plugin_Handled;
	}
	decl String:Temp1[255];
	for(new X = 1; X <= 50; X++)
	{
		decl String:IdKey[10];
		IntToString(X, IdKey, 10);
		KvGetString(SetDoor, IdKey, Temp1, 255, NOONE);
		if(!StrEqual(Temp1, "noone", false))
		{
			KvDeleteKey(SellDoor, Temp1);
		}
	}
	
	KvDeleteKey(SellDoor, SteamIds);
	KvRewind(SellDoor);
	KeyValuesToFile(SellDoor, DoorPathadd);
	CloseHandle(SellDoor);
	
	KvSetNum(SetDoor, "Buyable", BUYABLE);
	KvDeleteKey(SetDoor, "Owner");
	KvGetString(SetDoor, "Amount", Worth, 255, ERROR);
	
	KvRewind(SetDoor);
	KeyValuesToFile(SetDoor, DoorBuyPath);
	CloseHandle(SetDoor);
	
	decl String:SaleMess[255];
	Format(SaleMess, 255, "Door Price l $%s", Worth);
	decl Handle:Mess;
	Mess = CreateKeyValues("Vault");
	FileToKeyValues(Mess, Noticeadd);
	KvJumpToKey(Mess, "Owner", true);
	KvSetString(Mess, DoorStringN2, SaleMess);
	KvRewind(Mess);
	KeyValuesToFile(Mess, Noticeadd);
	CloseHandle(Mess);
	ApplyMessage(Entdoor, SaleMess);
	
	decl Float:CashBack;
	CashBack = float(StringToInt(Worth));
	
	CashBack = CashBack - CashBack/100*GetConVarInt(Deduction);
	
	Bank[Client] = Bank[Client] + RoundFloat(CashBack);
	
	CPrintToChat(Client, "{white}|RP| -{grey} You successfully sold your house back to real estate!");
	CPrintToChat(Client, "{white}|RP| -{grey} You've received $%d (%d percent deduction off original price of house)", RoundFloat(CashBack), GetConVarInt(Deduction));
	CPrintToChat(Client, "{white}|RP| -{grey} Losing Key Access in 5 seconds...");
	ServerCommand("sm_refreshdoors");
	
	return Plugin_Handled;
}

//Suicide:
public Action:CommandSuicide(Client, Arguments)
{
	PrintToConsole(Client, "|RP| - Nah.");
	return Plugin_Handled;
}

//Items:
public Action:Inventory(Client)
{
	new bool:Available = false;
	
	new Handle:ItemMenu = CreateMenu(InventoryMenu);
	
	decl Number, Value;
	Number = 0;
	Value = 0;
	if(GetConVarInt(CategoryInv) > 0)
	{
		//Display Functions First
		new Taken[64];
		for(new X = 0; X < MAXITEMS; X++)
		{
			if(Item[Client][X] > 0)
			{
				Available = true;
				if(ItemAction[X] == 1 && Taken[1] != 2)
				{
					Taken[1] = 2;
					AddMenuItem(ItemMenu, "-1", "-|Weapons|-");
				}
				else if(ItemAction[X] == 2 && Taken[2] != 2)
				{
					Taken[2] = 2;
					AddMenuItem(ItemMenu, "-2", "-|Alcohol|-");
				}
				else if(ItemAction[X] == 3 && Taken[3] != 2)
				{
					Taken[3] = 2;
					AddMenuItem(ItemMenu, "-3", "-|Drugs|-");
				}
				else if(ItemAction[X] == 4 && Taken[4] != 2)
				{
					Taken[4] = 2;
					AddMenuItem(ItemMenu, "-4", "-|Food|-");
				}
				else if(ItemAction[X] == 5 && Taken[5] != 2)
				{
					Taken[5] = 2;
					AddMenuItem(ItemMenu, "-5", "-|Lockpicks|-");
				}
				else if(ItemAction[X] == 6 && Taken[6] != 2)
				{
					Taken[6] = 2;
					AddMenuItem(ItemMenu, "-6", "|-Doorhacks|-");
				}
				else if(ItemAction[X] == 7 && Taken[7] != 2)
				{
					Taken[7] = 2;
					AddMenuItem(ItemMenu, "-7", "-|Furniture|-");
				}
				else if(ItemAction[X] == 8 && Taken[8] != 2)
				{
					Taken[8] = 2;
					AddMenuItem(ItemMenu, "-8", "-|Med Kits|-");
				}
				else if(ItemAction[X] == 9 && Taken[9] != 2)
				{
					Taken[9] = 2;
					AddMenuItem(ItemMenu, "-9", "-|Cuff Saws|-");
				}
				else if(ItemAction[X] == 10 && Taken[10] != 2)
				{
					Taken[10] = 2;
					AddMenuItem(ItemMenu, "-10", "-|Bombs|-");
				}
				else if(ItemAction[X] == 11 && Taken[11] != 2)
				{
					Taken[11] = 2;
					AddMenuItem(ItemMenu, "-11", "-|Traps|-");
				}
				else if(ItemAction[X] == 12 && Taken[12] != 2)
				{
					Taken[12] = 2;
					AddMenuItem(ItemMenu, "-12", "-|Raffle Tickets|-");
				}
				else if(ItemAction[X] == 13 && Taken[13] != 2)
				{
					Taken[13] = 2;
					AddMenuItem(ItemMenu, "-13", "-|Locks|-");
				}
				else if(ItemAction[X] == 14 && Taken[14] != 2)
				{
					Taken[14] = 2;
					AddMenuItem(ItemMenu, "-14", "-|Lockbreakers|-");
				}
				else if(ItemAction[X] == 15 && Taken[15] != 2)
				{
					Taken[15] = 2;
					AddMenuItem(ItemMenu, "-15", "-|GPS Bugs|-");
				}
				else if(ItemAction[X] == 16 && Taken[16] != 2)
				{
					Taken[16] = 2;
					AddMenuItem(ItemMenu, "-16", "-|GPS Scanner|-");
				}
				else if(ItemAction[X] == 17 && Taken[17] != 2)
				{
					Taken[17] = 2;
					AddMenuItem(ItemMenu, "-17", "-|Police Scanners|-");
				}
				else if(ItemAction[X] == 18 && Taken[18] != 2)
				{
					Taken[18] = 2;
					AddMenuItem(ItemMenu, "-18", "-|Police Jammers|-");
				}
				else if(ItemAction[X] == 19 && Taken[19] != 2)
				{
					Taken[19] = 2;
					AddMenuItem(ItemMenu, "-19", "-|Checks|-");
				}
				else if(ItemAction[X] == 20 && Taken[20] != 2)
				{
					Taken[20] = 2;
					AddMenuItem(ItemMenu, "-20", "-|MainHud Colors|-");
				}
				else if(ItemAction[X] == 21 && Taken[21] != 2)
				{
					Taken[21] = 2;
					AddMenuItem(ItemMenu, "-21", "-|CenterHud Colors|-");
				}
				else if(ItemAction[X] == 22 && Taken[22] != 2)
				{
					Taken[22] = 2;
					AddMenuItem(ItemMenu, "-22", "-|Skins|-");
				}
				else if(ItemAction[X] == 23 && Taken[23] != 2)
				{
					Taken[23] = 2;
					AddMenuItem(ItemMenu, "-23", "-|Trails|-");
				}
				else if(ItemAction[X] == 24 && Taken[24] != 2)
				{
					Taken[24] = 2;
					AddMenuItem(ItemMenu, "-24", "-|Full Suits|-");
				}
				else if(ItemAction[X] == 25 && Taken[25] != 2)
				{
					Taken[25] = 2;
					AddMenuItem(ItemMenu, "-25", "-|Money Drops|-");
				}
				else if(ItemAction[X] == 26 && Taken[26] != 2)
				{
					Taken[26] = 2;
					AddMenuItem(ItemMenu, "-26", "-|Crime Reducers|-");
				}
				else if(ItemAction[X] == 27 && Taken[27] != 2)
				{
					Taken[27] = 2;
					AddMenuItem(ItemMenu, "-27", "-|Jetpacks|-");
				}
				else if(ItemAction[X] == 28 && Taken[28] != 2)
				{
					Taken[28] = 2;
					AddMenuItem(ItemMenu, "-28", "-|Permanant Jetpacks|-");
				}
				else if(ItemAction[X] == 29 && Taken[29] != 2)
				{
					Taken[29] = 2;
					AddMenuItem(ItemMenu, "-29", "-|Invisibility Cloaks|-");
				}
				else if(ItemAction[X] == 30 && Taken[30] != 2)
				{
					Taken[30] = 2;
					AddMenuItem(ItemMenu, "-30", "-|Player Colors|-");
				}
				else if(ItemAction[X] == 31 && Taken[31] != 2)
				{
					Taken[31] = 2;
					AddMenuItem(ItemMenu, "-31", "-|God Suit|-");
				}
				else if(ItemAction[X] == 32 && Taken[32] != 2)
				{
					Taken[32] = 2;
					AddMenuItem(ItemMenu, "-32", "-|Ghost Suit|-");
				}
				else if(ItemAction[X] == 33 && Taken[33] != 2)
				{
					Taken[33] = 2;
					AddMenuItem(ItemMenu, "-33", "-|Bank Account Hack|-");
				}
				else if(ItemAction[X] == 34 && Taken[34] != 2)
				{
					Taken[34] = 2;
					AddMenuItem(ItemMenu, "-34", "-|Money Printers|-");
				}
				else if(ItemAction[X] == 35 && Taken[35] != 2)
				{
					Taken[35] = 2;
					AddMenuItem(ItemMenu, "-35", "-|Weed Plants|-");
				}
				else if(ItemAction[X] == 36 && Taken[36] != 2)
				{
					Taken[36] = 2;
					AddMenuItem(ItemMenu, "-36", "-|Freedom Cards|-");
				}
				
				Number = Number + Item[Client][X];
				Value = Value + (Item[Client][X]*ItemCost[X]);
			}
		}
	}
	else
	{
		decl String:MenuLine[64];
		decl String:ItemPick[12];
		for(new X = 0; X < MAXITEMS; X++)
		{
			if(Item[Client][X] > 0)
			{
				Available = true;
				Format(MenuLine, 64, "-|%d|- x %s", Item[Client][X], ItemName[X]);
				Format(ItemPick, 12, "%d", X);
				AddMenuItem(ItemMenu, ItemPick, MenuLine);
				Number = Number + Item[Client][X];
				Value = Value + (Item[Client][X]*ItemCost[X]);
			}
		}
	}
	SetMenuTitle(ItemMenu, "Item Inventory:\n=============\nTotal Items: %d\nTotal Value: $%d", Number, Value);
	
	if(Available)
	{
		SetMenuPagination(ItemMenu, 7);
		DisplayMenu(ItemMenu, Client, 50);
		CPrintToChat(Client, "{white}|RP| -{grey} Press <escape> to view your inventory.");
	}
	else
	{
		CloseHandle(ItemMenu);
		CPrintToChat(Client, "{white}|RP| -{grey} You don't have any items!");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

//Vendor Menus:
public VendorMenu(Client, iVendorId, isAuct, isBuy)
{
	
	//Declare:
	decl Handle:Vault;
	decl String:Props[255], String:VendorId[255];
	
	//Save:
	GlobalVendorId[Client] = iVendorId;
	
	//Initialize:
	IntToString(iVendorId, VendorId, 255);
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Load:
	LoadString(Vault, "VItems", VendorId, "Null", Props);
	
	//Found in DB:
	if(StrContains(Props, "Null", false) == -1)
	{
		
		//Declare:
		new Vars[7];
		new String:Buffer[7][32];
		new String:DisplayBuffer[7][64];
		new Price;
		
		//Explode:
		ExplodeString(Props, " ", Buffer, 7, 32);
		
		//Loop:
		for(new X = 0; X < 7; X++)
		{
			//Variables:
			Vars[X] = StringToInt(Buffer[X]); 
			
			if(isAuct && isBuy)
			{
				Price = RoundToCeil(FloatMul(FloatMul(float(ItemCost[Vars[X]]),AuctItems[X]),AuctVendor));
			}
			else if(isAuct)
			{
				Price = RoundToCeil(FloatMul(float(ItemCost[Vars[X]]),AuctItems[X]));
			} else
			Price = ItemCost[Vars[X]];
			
			
			//Display:
			if(strlen(ItemName[Vars[X]]) > 0) Format(DisplayBuffer[X], 64, "%s - $%d", ItemName[Vars[X]], Price);
		}
		
		if(isBuy && isAuct)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} NPC is buying items with variable prices"); 
			DrawMenu(Client, DisplayBuffer, HandleSellAuct, Vars);
		}
		else if(isBuy)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} NPC is buying items"); 
			DrawMenu(Client, DisplayBuffer, HandleSell, Vars);
		}
		else if(isAuct)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} NPC is selling items with variable prices"); 
			DrawMenu(Client, DisplayBuffer, HandleBuyAuct, Vars);
		}
	}
	CloseHandle(Vault);
}

public VendorMenuNEW(Client, iVendorId)
{
	//Declare:
	decl Handle:Vault;
	decl String:Props[255], String:VendorId[255];
	
	//Save:
	GlobalVendorId[Client] = iVendorId;
	
	//Initialize:
	IntToString(iVendorId, VendorId, 255);
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Load:
	LoadString(Vault, "VItems", VendorId, "Null", Props);
	
	//Found in DB:
	if(StrContains(Props, "Null", false) == -1)
	{
		
		//Declare:
		new Vars[25];
		new String:Buffer[25][32];
		new Price;
		
		//Explode:
		ExplodeString(Props, " ", Buffer, 25, 32);
		
		new Handle:menu = CreateMenu(VendorXNEW);
		SetMenuTitle(menu, "Vendor:\n=============");
		decl String:DisplayItem[64];
		decl String:VendorBuffer[64];
		
		if(Grams[Client] > 0)
		{
			Format(VendorBuffer, 64, "Drugs-%d", Grams[Client]);
			Format(DisplayItem, 64, "-|Sell Drugs (%dg)|-", Grams[Client]);
			AddMenuItem(menu, VendorBuffer, DisplayItem);
		}
		
		//Loop:
		for(new X = 0; X < 25; X++)
		{
			
			
			Format(VendorBuffer, 64, "%s-%s", Buffer[X], VendorId);
			
			//Variables:
			Vars[X] = StringToInt(Buffer[X]); 
			
			Price = ItemCost[Vars[X]];
			
			if(strlen(ItemName[Vars[X]]) > 0)
			{
				Format(DisplayItem, 64, "%s - $%d", ItemName[Vars[X]], Price);
				//AddMenuItem(menu, Buffer[X], DisplayItem);
				AddMenuItem(menu, VendorBuffer, DisplayItem);
			}
		}
		SetMenuPagination(menu, 7);
		DisplayMenu(menu, Client, 30);
		
		if(Grams[Client] == 0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} NPC is selling items.");
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} NPC is selling items and buying drugs.");
		}
	}
	CloseHandle(Vault);
}

public VendorXNEW(Handle:menu, MenuAction:action, Client, param2)
{
	if (action == MenuAction_Select)
	{
		new String:info[64];
		//new ItemId;
		GetMenuItem(menu, param2, info, sizeof(info));
		//ItemId = StringToInt(info);
		
		decl String:DrugBuffer[64];
		Format(DrugBuffer, 64, "Drugs-%d", Grams[Client]);
		if(StrEqual(info, DrugBuffer, false))
		{
			decl DrugMoney;
			DrugMoney = Grams[Client]*GetConVarInt(DrugWorth);
			AddCrime(Client, 200);
			CPrintToChat(Client, "{white}|RP-Drug|{darkgrey} -  You've received $%d for selling %d grams of drugs", DrugMoney, Grams[Client]);
			Grams[Client] = 0;
			Money[Client] += DrugMoney;
		}
		
		
		{
			
			//Cash or Credit Menu:
			decl String:InfoType1[64], String:InfoType2[64], String:InfoType3[64], String:InfoType4[64];
			
			//Format(InfoType1, 32, "Cash-%d", ItemId);
			//Format(InfoType2, 32, "Credit-%d", ItemId);
			Format(InfoType1, 64, "Cash-%s", info);
			Format(InfoType2, 64, "Credit-%s", info);
			Format(InfoType3, 64, "Bulk-%s", info);
			Format(InfoType4, 64, "Back-%s", info);
			
			new Handle:Payment = CreateMenu(Pay);
			SetMenuTitle(Payment, "Payment:");
			AddMenuItem(Payment, InfoType1, "-|Cash|-");
			AddMenuItem(Payment, InfoType2, "-|Credit|-");
			AddMenuItem(Payment, InfoType3, "-|Buy Bulk|-");
			AddMenuItem(Payment, InfoType4, "-|Back|-");
			SetMenuPagination(Payment, 7);
			DisplayMenu(Payment, Client, 30);
		}
	}
}






//Minute Timer:
public MinuteTimer(Client)
{
	
	//Valid:
	if(IsClientConnected(Client) && IsClientInGame(Client) && Loaded[Client])
	{
		
		//Add:
		Minutes[Client] += 1;
		
		//Wages:
		if(Minutes[Client] >= Pow(float(Wages[Client]), 3.0))
		{
			
			//Add:
			Wages[Client] += 1;
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You have recieved a raise for spending a total of %d minutes in the server", Minutes[Client]);
		}
		
		//Save:
		Save(Client);
	}
}

//Clear Overlay:
public Action:RemoveOverlay(Handle:Timer, any:Client)
{
	
	//Clear:
	ClientCommand(Client, "r_screenoverlay 0");
}


//Clear Overlay:
public Action:RemoveDrugEffect(Handle:Timer, any:Client)
{
	if(DrugTick[Client] > 7) 
	{
		DrugTick[Client] = 0;
		ClientCommand(Client, "r_screenoverlay 0"); 
		SetSpeed(Client, 190.0);
		SetEntityGravity(Client,1.0);
		
		if(GetClientHealth(Client) > DrugHealth[Client])
			SetEntityHealth(Client,DrugHealth[Client]);
	} else
	{
		new Float:vec[3];
		GetClientAbsOrigin(Client, vec);
		vec[2] = FloatAdd(vec[2],10.0);
		TE_SetupBeamRingPoint(vec, 10.0, 100.0, g_BeamSprite, g_HaloSprite, 0, 15, 0.5, 5.0, 0.0, greyColor, 10, 0);
		TE_SendToAll();
		TE_SetupBeamRingPoint(vec, 10.0, 100.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 10.0, 0.5, whiteColor, 10, 0);
		TE_SendToAll();
		
		CreateTimer(10.0, RemoveDrugEffect, Client); 
		DrugTick[Client]++;
	}
	
	
}


//Status:
public Action:CommandStatus(Client, Args)
{
	
	//Declare:
	decl MaxPlayers;
	decl String:ClientName[32];
	
	//Initialize:
	MaxPlayers = GetMaxClients();
	
	//Print:
	PrintToConsole(Client, "Status:");
	
	//Loop:
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//In-Game:
		if(IsClientInGame(X))
		{
			
			//Initialize:
			GetClientName(X, ClientName, 32);
			
			//Print:
			PrintToConsole(Client, "%s: Wallet: $%d. Bank: $%d. Employment: %s. Wages: %d.", ClientName, Money[X], Bank[X], Job[X], Wages[X]); 
		}
	}
	
	//Return:
	return Plugin_Handled;
}

//UserID Save
stock saveUserName(Client)
{
	
	decl String:SteamId[255];
	decl Handle:Vault;
	GetClientAuthString(Client, SteamId, 255);
	decl String:Name[255];
	GetClientName(Client, Name, 255);
	decl String:LastSeen[255];
	IntToString(GetTime(), LastSeen, 255);
	
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NamePath);
	
	//Save:
	SaveString(Vault, "name", SteamId, Name);
	SaveString(Vault, "seen", SteamId, LastSeen);
	
	//Store:
	KeyValuesToFile(Vault, NamePath);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return true;
}

//Create Job:
public Action:CommandCreateJob(Client, Args)
{
	
	//Error:
	if(Args < 3)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_createjob <Id> <Job> <0|1|2>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl Flag, iJobId;
	decl Handle:Vault;
	decl String:JobId[255], String:JobName[255], String:sFlag[32];
	
	//Initialize:
	GetCmdArg(1, JobId, sizeof(JobId));
	GetCmdArg(2, JobName, sizeof(JobName));
	GetCmdArg(3, sFlag, sizeof(sFlag));
	StringToIntEx(sFlag, Flag);
	StringToIntEx(JobId, iJobId);
	
	//Invalid Id:
	if(iJobId < 1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Id must be above 0");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Invalid Flag:
	if(Flag != 1 && Flag != 0)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Flag must be 0 or 1");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, JobPath);
	
	//Save:
	SaveString(Vault, sFlag, JobId, JobName);
	
	//Store:
	KeyValuesToFile(Vault, JobPath);
	
	//Print:
	PrintToConsole(Client, "|RP| - Added job %s - '%s (%s)' into the database", JobId, JobName, sFlag);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//Lock a door
public Action:CommandLock(Client, Args)
{
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	if(Ent != -1)
	{
		if(!DoorLocked[Ent])
		{
			decl Handle:Vault;
			decl String:NPCId[255];
			
			Vault = CreateKeyValues("Vault");
			IntToString(Ent,NPCId,32);
			FileToKeyValues(Vault, LockPath); 
			SaveString(Vault, "1", NPCId, "1");
			KeyValuesToFile(Vault, LockPath);
			CloseHandle(Vault);  
			
			DoorLocked[Ent] = true;
			CPrintToChat(Client, "{white}|RP| -{grey} Door #%d is locked",Ent); 
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Door #%d is already locked",Ent);  
		}  
	}
	return Plugin_Handled; 
}

public Action:CommandUnLock(Client, Args)
{
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	if(Ent != -1)
	{
		if(DoorLocked[Ent])
		{
			decl Handle:Vault;
			decl String:NPCId[255];
			
			Vault = CreateKeyValues("Vault");
			IntToString(Ent,NPCId,32);
			FileToKeyValues(Vault, LockPath);
			KvDeleteKey(Vault, NPCId);
			KeyValuesToFile(Vault, LockPath);
			CloseHandle(Vault);
			
			DoorLocked[Ent] = false;
			CPrintToChat(Client, "{white}|RP| -{grey} Door #%d is unlocked",Ent); 
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Door #%d is already unlocked",Ent);  
		}  
	}
	return Plugin_Handled;
}

//Remove Job:
public Action:CommandRemoveJob(Client, Args)
{
	
	//Error:
	if(Args < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_removejob <Id> <0|1>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl Flag;
	decl bool:Deleted;
	decl Handle:Vault;
	decl String:JobId[255], String:sFlag[32];
	
	//Initialize:
	GetCmdArg(1, JobId, sizeof(JobId));
	GetCmdArg(2, sFlag, sizeof(sFlag));
	StringToIntEx(sFlag, Flag);
	
	//Invalid:
	if(Flag != 1 && Flag != 0)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Flag must be 0 or 1");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, JobPath);
	
	//Delete:
	KvJumpToKey(Vault, sFlag, false);
	Deleted = KvDeleteKey(Vault, JobId); 
	KvRewind(Vault);
	
	//Store:
	KeyValuesToFile(Vault, JobPath);
	
	//Print:
	if(!Deleted) PrintToConsole(Client, "|RP| - Failed to remove job %s (%s) from the database", JobId, sFlag);
	else PrintToConsole(Client, "|RP| - Removed job %s (%s) from the database", JobId, sFlag);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//Employ:
public Action:CommandEmploy(Client, Args)
{
	
	//Error:
	if(Args < 3)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_employ <name> <id> <level>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl iJobId;
	decl Handle:Vault;
	decl String:JobId[255];
	decl String:ReferenceString[255];
	decl Level;
	decl String:JobLevel[32];
	
	//Initialize:
	GetCmdArg(2, JobId, sizeof(JobId));
	StringToIntEx(JobId, iJobId);
	GetCmdArg(3, JobLevel, sizeof(JobLevel));
	StringToIntEx(JobLevel, Level);
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Player, Name, sizeof(Name));
	
	//Invalid Id:
	if(iJobId < 1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Id must be above 0");
		
		//Return:
		return Plugin_Handled;
	}
	if(Level > 2)
	{
		//Print
		PrintToConsole(Client, "|RP| - Category must be 2 or below.");
		
		//Return
		return Plugin_Handled;
	}
	if(Level < 0)
	{
		//Print
		PrintToConsole(Client, "|RP| - Category must be atleast 0.");
		
		//Return
		return Plugin_Handled;
	}
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, JobPath);
	
	//Load:
	LoadString(Vault, JobLevel, JobId, "Null", ReferenceString);
	
	//Check:
	if(!StrEqual(ReferenceString, "Null"))
	{
		
		//Save:
		Job[Player] = ReferenceString;
		OrgJob[Player] = ReferenceString;
	}
	else 
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Unable to find ID");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Store:
	KeyValuesToFile(Vault, JobPath);
	
	//Print:
	PrintToConsole(Client, "|RP| - Set %s's job to %s", Name, ReferenceString);
	CPrintToChat(Player, "{white}|RP| -{grey} %s set your job to %s", ClientName, ReferenceString);
	
	DynamicJobsRefresh(Player);
	
	Stealth[Player] = false;
	
	//Close:
	Save(Player);
	CloseHandle(Vault);
	
	ForcePlayerSuicide(Player);
	
	//Return:
	return Plugin_Handled;
}

//Crime:
public Action:CommandCrime(Client, Args)
{
	
	//Error:
	if(Args < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_crime <Name> <Crime #>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	decl String:Amount[32];
	decl iAmount;
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	GetCmdArg(2, Amount, sizeof(Amount));
	iAmount = StringToInt(Amount);
	
	if(StrContains("@all", PlayerName, false) != -1)
	{
		for(new X = 1; X <= GetMaxClients(); X++)
		{
			if(IsClientConnected(X))
			{
				Crime[X] = iAmount;
			}
		}
		CPrintToChatAll("{white}|RP| -{grey} Everyones crime has been set to: %d", iAmount);
		return Plugin_Handled;
	}
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Action:
	Crime[Player] = iAmount;
	GetClientName(Player, Name, sizeof(Name));
	GetClientName(Client, ClientName, sizeof(ClientName));
	
	//Print:
	PrintToConsole(Client, "|RP| - Set %s's crime to %s", Name, Amount);
	CPrintToChat(Player, "{white}|RP| -{grey} %s set your crime to %s", ClientName, Amount);
	
	//Return:
	return Plugin_Handled;
}

//Name:
public Action:CommandName(Client, Args)
{
	
	//Error:
	if(Args < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_name <Name> <New Name>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	decl String:TargetName[32];
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	GetCmdArg(2, TargetName, sizeof(TargetName));
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Action:
	ClientCommand(Player, "name %s", TargetName);
	GetClientName(Player, Name, sizeof(Name));
	GetClientName(Client, ClientName, sizeof(ClientName));
	
	//Print:
	PrintToConsole(Client, "|RP| - Set %s's name to %s", Name, TargetName);
	CPrintToChat(Player, "{white}|RP| -{grey} %s set your name to %s", ClientName, TargetName);
	
	//Return:
	return Plugin_Handled;
}

//Create Item:
public Action:CommandCreateItem(Client, Args)
{
	
	//Error:
	if(Args < 5)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_createitem <id> <name> <type> <variables> <cost>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl Handle:Vault;
	decl String:Buffers[4][128];
	decl String:SaveBuffer[255], String:ItemId[255];
	
	//Initialize:
	GetCmdArg(1, ItemId, sizeof(ItemId));
	GetCmdArg(2, Buffers[0], 128);
	GetCmdArg(3, Buffers[1], 128);
	GetCmdArg(4, Buffers[2], 128);
	GetCmdArg(5, Buffers[3], 128);
	
	//Implode:
	ImplodeStrings(Buffers, 4, "^", SaveBuffer, 255);
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, ItemPath);
	
	//Save:
	SaveString(Vault, "Items", ItemId, SaveBuffer);
	
	//Store:
	KeyValuesToFile(Vault, ItemPath);
	
	//Print:
	PrintToConsole(Client, "|RP| - Added Item %s - %s, Type: %s @ %s", ItemId, Buffers[0], Buffers[1], Buffers[2]);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//Remove Item:
public Action:CommandRemoveItem(Client, Args)
{
	
	//Error:
	if(Args < 1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_removeitem <id>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:	
	decl bool:Deleted;
	decl Handle:Vault;
	decl String:ItemId[255];
	
	//Initialize:
	GetCmdArg(1, ItemId, sizeof(ItemId));
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, ItemPath);
	
	//Delete:
	KvJumpToKey(Vault, "Items", false);
	Deleted = KvDeleteKey(Vault, ItemId); 
	KvRewind(Vault);
	
	//Store:
	KeyValuesToFile(Vault, ItemPath);
	
	//Print:
	if(!Deleted) PrintToConsole(Client, "|RP| - Failed to remove Item %s from the database", ItemId);
	else PrintToConsole(Client, "|RP| - Removed Item %s from the database", ItemId);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//Add Item:
public Action:CommandAddItem(Client, Args)
{
	
	//Error:
	if(Args < 3)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_additem <name> <id> <amount>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl String:ItemId[255];
	decl String:Amount[255];
	
	//Initialize:
	GetCmdArg(2, ItemId, sizeof(ItemId));
	GetCmdArg(3, Amount, sizeof(Amount));
	
	if(StringToInt(ItemId) < 1)
	{
		PrintToConsole(Client, "|RP| - The item id must be at least 1 or higher.");
		return Plugin_Handled;
	}
	if(StringToInt(Amount) < 1)
	{
		PrintToConsole(Client, "|RP| - The amount must be at least 1 or higher.");
		return Plugin_Handled;
	}
	
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Player, Name, sizeof(Name));
	
	//Set:
	Item[Player][StringToInt(ItemId)] += StringToInt(Amount);
	
	//Print:
	PrintToConsole(Client, "|RP| - Gave %d %s's to %s", StringToInt(Amount), ItemName[StringToInt(ItemId)], Name);
	CPrintToChat(Player, "{white}|RP| -{grey} Recieved %d %s's from %s", StringToInt(Amount), ItemName[StringToInt(ItemId)], ClientName);
	
	//Save:
	Save(Player);
	
	//Return:
	return Plugin_Handled;
}

public Action:CommandTakeItem(Client, Args)
{
	//Error:
	if(Args < 3)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_takeitem <name> <id> <amount>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers, Player;
	decl String:PlayerName[32], String:ClientName[32];
	decl String:Name[32];
	
	//Initialize:
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	
	//Find:
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		//Connected:
		if(!IsClientConnected(X)) continue;
		
		//Initialize:
		GetClientName(X, Name, sizeof(Name));
		
		//Save:
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	
	//Invalid Name:
	if(Player == -1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl String:ItemId[255];
	decl String:Amount[255];
	
	//Initialize:
	GetCmdArg(2, ItemId, sizeof(ItemId));
	GetCmdArg(3, Amount, sizeof(Amount));
	
	if(StringToInt(ItemId) < 1)
	{
		PrintToConsole(Client, "|RP| - The item id must be at least 1 or higher.");
		return Plugin_Handled;
	}
	if(StringToInt(Amount) < 1)
	{
		PrintToConsole(Client, "|RP| - The amount must be at least 1 or higher.");
		return Plugin_Handled;
	}
	
	if(Item[Player][StringToInt(ItemId)] < StringToInt(Amount))
	{
		PrintToConsole(Client, "|RP| - You cannot make a player have a negative item amount. (Player has %d of Item %s)", Item[Player][StringToInt(ItemId)], ItemName[StringToInt(ItemId)]);
		return Plugin_Handled;
	}
	
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Player, Name, sizeof(Name));
	
	//Set:
	Item[Player][StringToInt(ItemId)] -= StringToInt(Amount);
	
	//Print:
	PrintToConsole(Client, "|RP| - Taken %d %s's to %s", StringToInt(Amount), ItemName[StringToInt(ItemId)], Name);
	CPrintToChat(Player, "{white}|RP| -{grey} Admin %s taken %d %s's from you", ClientName, StringToInt(Amount), ItemName[StringToInt(ItemId)]);
	
	//Save:
	Save(Player);
	
	//Return:
	return Plugin_Handled;
}

//Add Vendor Item:
public Action:CommandAddVendorItem(Client, Args)
{
	
	//Error:
	if(Args < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_addvendoritem <vendor id> <item id>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl Handle:Vault;
	decl String:Buffer[255];
	decl String:VendorId[255], String:ItemId[255];
	
	//Initialize:
	GetCmdArg(1, VendorId, sizeof(VendorId));
	GetCmdArg(2, ItemId, sizeof(ItemId));
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Load:
	LoadString(Vault, "VItems", VendorId, "Null", Buffer);
	
	//Found:
	if(StrContains(Buffer, "Null", false) == -1)
	{
		
		//Declare:
		decl String:AddString[2][255];
		decl String:OutputString[255];
		
		//Initialize:
		AddString[0] = Buffer;
		AddString[1] = ItemId;
		
		//Join:
		ImplodeStrings(AddString, 2, " ", OutputString, 255);
		
		//Save:
		SaveString(Vault, "VItems", VendorId, OutputString);
	}
	else
	{
		
		//Save:
		SaveString(Vault, "VItems", VendorId, ItemId);
	}
	
	
	//Store:
	KeyValuesToFile(Vault, NPCPath);
	
	//Print:
	PrintToConsole(Client, "|RP| - Added Item %s to Vendor #%s", ItemName[StringToInt(ItemId)], VendorId);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//Remove Vendor Item:
public Action:CommandRemoveVendorItem(Client, Args)
{
	
	//Error:
	if(Args < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_removevendoritem <npc id> <item id>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl String:Formated[32];
	decl bool:Deleted;
	decl Handle:Vault;
	decl String:Buffer[255];
	decl String:VendorId[255], String:ItemId[255];
	
	//Initialize:
	GetCmdArg(1, VendorId, sizeof(VendorId));
	GetCmdArg(2, ItemId, sizeof(ItemId));
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Load:
	LoadString(Vault, "VItems", VendorId, "Null", Buffer);
	
	//Found:
	if(StrContains(Buffer, "Null", false) == -1)
	{
		
		//Spaces:
		if(StrContains(Buffer, " ", false) == -1)
		{
			
			//Delete:
			KvJumpToKey(Vault, "VItems", false);
			KvDeleteKey(Vault, VendorId);
			KvRewind(Vault);
			
			Deleted = true;
		}
		
		//First:
		Format(Formated, 32, "%s ", ItemId);
		if(StrContains(Buffer, Formated, false) == 0)
		{
			
			//Replace:
			ReplaceString(Buffer, 255, Formated, " ");
			ReplaceString(Buffer, 255, "  ", " ");
			ReplaceString(Buffer, 255, "  ", " ");
			TrimString(Buffer);
			
			//Save:
			SaveString(Vault, "VItems", VendorId, Buffer);
			Deleted = true;
		}
		
		//Last:
		Format(Formated, 32, " %s", ItemId);
		if(StrContains(Buffer, Formated, false) != -1)
		{
			
			//Length:
			if(strlen(Buffer[StrContains(Buffer, Formated, false) + strlen(Formated)]) < 1)
			{
				
				ReplaceString(Buffer, 255, Formated, " ");
				ReplaceString(Buffer, 255, "  ", " ");
				ReplaceString(Buffer, 255, "  ", " ");
				TrimString(Buffer);
				
				//Save:
				SaveString(Vault, "VItems", VendorId, Buffer);
				Deleted = true;
			}
		}
		
		//Deleted:
		if(!Deleted)
		{
			
			//Format:
			Format(Formated, 32, " %s ", ItemId);
			
			//Replace:
			ReplaceString(Buffer, 255, Formated, " ");
			ReplaceString(Buffer, 255, "  ", " ");
			ReplaceString(Buffer, 255, "  ", " ");
			TrimString(Buffer);
			
			//Save:
			SaveString(Vault, "VItems", VendorId, Buffer);
			Deleted = true;
		}
	}
	else
	{
		
		//False:
		Deleted = false;
	}
	
	//Store:
	KeyValuesToFile(Vault, NPCPath);
	
	//Print:
	if(!Deleted) PrintToConsole(Client, "|RP| - Failed to remove Item %s from vendor #%s", ItemId, VendorId);
	else PrintToConsole(Client, "|RP| - Removed Item %s from vendor #%s", ItemId, VendorId);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//List Jobs:
public Action:CommandListJobs(Client, Args)
{
	
	//Declare:	
	decl Handle:Vault;
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, JobPath);
	
	//Header:
	PrintToConsole(Client, "Jobs:");
	
	//Public:
	PrintJob(Client, Vault, "-0: (Public)", "0", MAXJOBS);
	
	//Private:
	PrintJob(Client, Vault, "-1: (Admin)", "1", MAXJOBS);
	
	//Cop
	PrintJob(Client, Vault, "-2: (Cop)", "2", MAXJOBS);
	
	//Store:
	KeyValuesToFile(Vault, JobPath);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//List Items:
public Action:CommandListItems(Client, Args)
{
	
	if(Args < 1)
	
	{	
		PrintToConsole(Client, "|RP| - Usage: sm_itemlist <page> <sortfuncstring>");
		return Plugin_Handled;
	}
	
	decl String:Page[10], String:Category[25], PageInt,PageInt2;
	GetCmdArg(1, Page, sizeof(Page));
	GetCmdArg(2, Category, sizeof(Category));
	PageInt = StringToInt(Page);
	
	//Declare:	
	decl Handle:Vault;
	decl String:ReferenceString[255], String:ItemId[255];
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, ItemPath);
	
	//Header:
	PrintToConsole(Client, "Items:");
	
	PrintToConsole(Client, "Printing Itemlist Page %d", PageInt);
	PageInt2 = PageInt * 50;
	//Loop:
	if(strlen(Category) == 0)
	{
		for(new X = PageInt2 - 50; X < PageInt2; X++)
		{
			
			//Convert:
			IntToString(X, ItemId, sizeof(ItemId));
			
			//Load:
			LoadString(Vault, "Items", ItemId, "Null", ReferenceString);
			
			//Check:
			if(!StrEqual(ReferenceString, "Null"))
			{
				//Format:
				ReplaceString(ReferenceString, 255, "^", " "); 
				
				//Print:
				PrintToConsole(Client, "%d - %s", X, ReferenceString);
			}		
		}
		//Close:
		CloseHandle(Vault);
		
		//Return:
		return Plugin_Handled;
	}
	for(new X = PageInt2 - 50; X < PageInt2; X++)
	{
		
		//Convert:
		IntToString(X, ItemId, sizeof(ItemId));
		
		//Load:
		LoadString(Vault, "Items", ItemId, "Null", ReferenceString);
		
		//Check:
		if(!StrEqual(ReferenceString, "Null"))
		{
			decl String:FuncCate[4][128];
			ExplodeString(ReferenceString, "^", FuncCate, 4, 32);
			
			if(StrContains(FuncCate[1], Category, false) != -1)
			{
				//Format:
				ReplaceString(ReferenceString, 255, "^", " "); 
				
				//Print:
				PrintToConsole(Client, "%d - %s", X, ReferenceString);
			}		
		}
	}
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
	
	
}

public Action:CommandListNotices(Client, Args)
{
	if(Args < 1)
	
	{	
		PrintToConsole(Client, "|RP| - Usage: sm_noticelist <page>");
		return Plugin_Handled;
	}
	decl String:Page[10], PageInt,PageInt2;
	GetCmdArg(1, Page, sizeof(Page));
	PageInt = StringToInt(Page);
	
	//Declare:	
	decl Handle:Vault;
	decl String:ReferenceString[255], String:ItemId[255];
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NoticePath);
	
	//Header:	
	PrintToConsole(Client, "Printing Noticelist Page %d", PageInt);
	PageInt2 = PageInt * 50;
	//Loop:
	for(new X = PageInt2 - 50; X < PageInt2; X++)
	{
		//Convert:
		IntToString(X, ItemId, sizeof(ItemId));
		
		//Load:
		LoadString(Vault, "Owner", ItemId, "Null", ReferenceString);
		if(!StrEqual(ReferenceString, "Null"))
		{
			PrintToConsole(Client, "%d - %s", X, ReferenceString);
		}
	}
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//Item Handle:
public InventoryMenu(Handle:ItemMenu, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		decl infoint;
		GetMenuItem(ItemMenu, param2, info, sizeof(info));
		infoint = StringToInt(info);
		decl String:HiddenInfo[64];
		
		if(infoint == 99999)
		{
			Inventory(Client);
		}
		else if(IsGiving[Client])
		{
			if(infoint < 0)
			{
				OrganizeList(Client, infoint);
			}
			else
			{
				decl String:AllIn[64];
				
				new Handle:GiveAmount = CreateMenu(GiveMenu);
				SetMenuTitle(GiveAmount, "Giving %s(s)\n=============\n%d left", ItemName[infoint], Item[Client][infoint]);
				
				new String:Buffers[7][10] = {"69", "1", "5", "25", "100", "500", "1000"};
				
				for(new X = 0; X < 7; X++)
				{
					if(StringToInt(Buffers[X]) == 69)
					{
						Format(AllIn, 64, "All (%d)", Item[Client][infoint]);
						Format(HiddenInfo, 64, "%s-%d", info, Item[Client][infoint]);
						AddMenuItem(GiveAmount, HiddenInfo, AllIn);
					}
					else
					{
						Format(HiddenInfo, 64, "%s-%s", info, Buffers[X]);
						AddMenuItem(GiveAmount, HiddenInfo, Buffers[X]);
					}
				}
				SetMenuPagination(GiveAmount, 7);
				DisplayMenu(GiveAmount, Client, 30);
			}
		}
		else
		{
			if(infoint < 0)
			{
				OrganizeList(Client, infoint);
			}
			else
			{
				decl String:HiddenInfo2[64];
				Format(HiddenInfo, 64, "%s-1", info);
				Format(HiddenInfo2, 64, "%s-2", info);
				new Handle:ItemUse = CreateMenu(UsingItems);
				SetMenuTitle(ItemUse, "%s\n=============\n%d left", ItemName[infoint], Item[Client][infoint]);
				if(ItemAction[infoint] == 7)
				{
					AddMenuItem(ItemUse, HiddenInfo, "-|Spawn|-");
					AddMenuItem(ItemUse, HiddenInfo2, "-|Drop|-");
				}
				else if(ItemAction[infoint] == 13)
				{
					decl String:HiddenInfo3[64], String:HiddenInfo4[64];
					Format(HiddenInfo3, 64, "%s-4", info);
					Format(HiddenInfo4, 64, "%s-5", info);
					AddMenuItem(ItemUse, HiddenInfo, "-|Use|-");
					AddMenuItem(ItemUse, HiddenInfo3, "-|Use 5|-");
					AddMenuItem(ItemUse, HiddenInfo4, "-|Use 10|-");
					AddMenuItem(ItemUse, HiddenInfo2, "-|Drop|-");
				}
				else
				{
					AddMenuItem(ItemUse, HiddenInfo, "-|Use|-");
					AddMenuItem(ItemUse, HiddenInfo2, "-|Drop|-");
				}
				
				AddMenuItem(ItemUse, "69-3", "-|Back to Inventory|-");
				
				SetMenuPagination(ItemUse, 7);
				DisplayMenu(ItemUse, Client, 30);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(ItemMenu);
	}
	return 0;
}

public Action:OrganizeList(Client, infoint)
{
	new Handle:ItemMenu = CreateMenu(InventoryMenu);
	
	decl Number, Value;
	Number = 0;
	Value = 0;
	decl String:MenuLine[64];
	decl String:ItemPick[12];
	for(new X = 0; X < MAXITEMS; X++)
	{
		if(Item[Client][X] > 0 && ItemAction[X] == FloatAbs(float(infoint)))
		{
			Format(MenuLine, 64, "-|%d|- x %s", Item[Client][X], ItemName[X]);
			Format(ItemPick, 12, "%d", X);
			AddMenuItem(ItemMenu, ItemPick, MenuLine);
			Number = Number + Item[Client][X];
			Value = Value + (Item[Client][X]*ItemCost[X]);
		}
	}
	
	AddMenuItem(ItemMenu, "99999", "-|Back to Inventory|-");
	SetMenuTitle(ItemMenu, "Item Inventory:\n=============\nTotal Items: %d\nTotal Value: $%d", Number, Value);
	
	SetMenuPagination(ItemMenu, 7);
	DisplayMenu(ItemMenu, Client, 50);
}

//Handle Prompting:
public UsingItems(Handle:ItemUse, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(ItemUse, param2, info, sizeof(info));
		
		decl String:Spliter[2][255];
		ExplodeString(info, "-", Spliter, 2, 32);
		
		//Declare:
		decl ItemId;
		
		//Initialize:
		ItemId = StringToInt(Spliter[0]);
		
		//Use:
		if(StringToInt(Spliter[1]) == 1 || StringToInt(Spliter[1]) == 4 || StringToInt(Spliter[1]) == 5 && lastspawn[Client] <= (GetGameTime() - 5) && Item[Client][ItemId] > 0)
		{
			lastspawn[Client] = GetGameTime();
			
			//HL2 Item:
			if(ItemAction[ItemId] == 1)
			{
				
				//Give:
				GivePlayerItem(Client, ItemVar[ItemId]);
				
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You use %s", ItemName[ItemId]);
				
				//Save:
				Item[Client][ItemId] -= 1;
			}
			
			//Alchohal:
			if(ItemAction[ItemId] == 2)
			{
				
				//Declare:
				decl Roll;
				
				//Initialize:
				Roll = GetRandomInt(1, 3);
				
				//Switch:
				if(Roll == 1) ClientCommand(Client, "r_screenoverlay effects/tp_eyefx/tpeye.vmt");
				if(Roll == 2) ClientCommand(Client, "r_screenoverlay effects/tp_eyefx/tpeye2.vmt");
				if(Roll == 3) ClientCommand(Client, "r_screenoverlay effects/tp_eyefx/tpeye3.vmt");
				
				//Shake:
				Shake(Client, 60.0, (5.0 * StringToFloat(ItemVar[ItemId])));
				
				//Timer:
				CreateTimer(60.0, RemoveOverlay, Client);
				
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You use %s", ItemName[ItemId]);
				Item[Client][ItemId] -= 1;
				SpawnGarbage(Client, 1);
			}
			
			//Drugs:
			if(ItemAction[ItemId] == 3)
			{
				
				DrugTick[Client] = 1;
				//Declare:
				decl Var;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				DrugHealth[Client] = GetClientHealth(Client);
				
				
				//Switch:
				if(Var == 2)
				{
					ClientCommand(Client, "r_screenoverlay debug/yuv.vmt"); //Coke
					SetEntityHealth(Client,150);
				}
				if(Var == 5) 
				{
					ClientCommand(Client, "r_screenoverlay effects/tp_eyefx/tp_eyefx.vmt"); //Extasy
					DrugSpeed[Client] = 390.0;
					
				}
				if(Var == 3)
				{
					ClientCommand(Client, "r_screenoverlay effects/com_shield002a.vmt"); //Heroin
					SetEntityHealth(Client,1);
					SetEntityGravity(Client,0.4);
				}
				if(Var == 4)
				{
					ClientCommand(Client, "r_screenoverlay models/effects/portalfunnel_sheet.vmt"); //LSD
					DrugSpeed[Client] = 290.0; 
					SetEntityGravity(Client,0.8); 
				}
				if(Var == 1) 
				{
					ClientCommand(Client, "r_screenoverlay models/props_combine/portalball001_sheet.vmt"); //Weed
					DrugSpeed[Client] = 80.0; 
					SetEntityHealth(Client,150);
					SetEntityGravity(Client,0.8);
				}
				if(Var == 6) 
				{
					ClientCommand(Client, "r_screenoverlay effects/combine_binocoverlay.vmt"); //Trip
					DrugSpeed[Client] = 300.0; 
					SetEntityHealth(Client,150);  
				} 
				
				if(Var == 7) //Doping Speed
				{
					DrugSpeed[Client] = 300.0; 
				}
				if(Var == 8) //Doping Health
				{
					SetEntityHealth(Client,200);
				}
				if(Var == 9) //Doping Gravity
				{
					SetEntityGravity(Client,0.5);
				}
				if(Var == 10) //Multi Dope
				{
					DrugSpeed[Client] = 200.0;
					SetEntityHealth(Client,200); 
					SetEntityGravity(Client,0.6);
				}
				if(Var == 11) //Bear Dope
				{
					SetEntityHealth(Client,800);
				}
				
				if(Var <= 6)
				{
					//Shake:
					Shake(Client, 60.0, (5.0 * StringToFloat(ItemVar[ItemId])));
					
					//Random Look:
					if(Var != 6)
						for(new Float:X = 0.0; X < 60.0; X = (X + (25.0 * FloatDiv(float(Var), 5.0)))) CreateTimer(X, RandomLook, Client);
					
					//Colors:
					if(Var >= 4 && Var != 6) for(new X = 0; X < 60; X += (7 - Var)) CreateTimer(float(X), DrugFade, Client);
					
					//Explosions:
					if(Var >= 2 && Var != 6) for(new X = 0; X < 60; X = (X + GetRandomInt(3,8))) CreateTimer(float(X), Explosion, Client);
				}
				
				//Timer:
				CreateTimer(10.0, RemoveDrugEffect, Client);
				
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You use %s", ItemName[ItemId]);
				Item[Client][ItemId] -= 1;
				AddCrime(Client,20);
			}
			
			//Food:
			if(ItemAction[ItemId] == 4)
			{
				
				//Declare:
				decl Var;
				decl ClientHP;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				ClientHP = GetClientHealth(Client);
				
				//Max HP:
				if(ClientHP < 100)
				{
					
					//Work:
					if((ClientHP + Var) > 100) SetEntityHealth(Client, 100);
					else SetEntityHealth(Client, (ClientHP + Var));
					
					//Print:
					CPrintToChat(Client, "{white}|RP| -{grey} You eat %s for +%dhp!", ItemName[ItemId], Var);
					Item[Client][ItemId] -= 1;
					SpawnGarbage(Client, 2);
				}
				else
				{
					
					//Print:
					CPrintToChat(Client, "{white}|RP| -{grey} You cannot eat right now, your health is full");
				}
			}
			
			//Lockpick:
			if(ItemAction[ItemId] == 5)
			{
				
				//Declare:
				decl Var;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				
				//Buffer:
				if(LockTime[Client] <= (GetGameTime() - (60 * Var)))
				{
					
					//Declare:
					decl DoorEnt;
					decl String:ClassName[255];
					
					//Initialize:
					DoorEnt = GetClientAimTarget(Client, false);
					
					//ClassName:
					GetEdictClassname(DoorEnt, ClassName, 255);
					
					//Action:
					if(DoorEnt > 1)
					{
						
						if(DoorLocked[DoorEnt])
						{
							CPrintToChat(Client, "{white}|RP| -{grey} Door is not unlockable");
						}
						else
						{
							//Doors:
							if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
							{
								if(DoorLocks[DoorEnt] < 1)
								{
									//Unlock:
									AcceptEntityInput(DoorEnt, "Unlock", Client);
									
									//Print:
									CPrintToChat(Client, "{white}|RP| -{grey} Door has been unlocked");
									
									//Save:
									LockTime[Client] = GetGameTime();
									AddCrime(Client,100); 
								} else
								{
									CPrintToChat(Client, "{white}|RP| -{grey} This door has some additional locks!");
								}
								
							}
						}
						
						//Metal:
						if(StrEqual(ClassName, "func_door"))
						{
							
							//Print:
							CPrintToChat(Client, "{white}|RP| -{grey} Lockpick cannot be used on this door");
						}
					}
				}
				else
				{
					
					CPrintToChat(Client, "{white}|RP| -{grey} You can only use this once every %d minutes", Var);
				}
			}
			
			//Hack:
			if(ItemAction[ItemId] == 6)
			{
				if(IsCuffed[Client])
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You're cuffed. You cannot use this item.");
					return 0;	
				}
				
				//Declare:
				decl Var;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				
				//Buffer:
				if(HackTime[Client] <= (GetGameTime() - (60 * Var)))
				{
					
					//Declare:
					decl DoorEnt;
					decl String:ClassName[255];
					
					//Initialize:
					DoorEnt = GetClientAimTarget(Client, false);
					
					//ClassName:
					GetEdictClassname(DoorEnt, ClassName, 255);
					
					//Action:
					if(DoorEnt > 1)
					{
						
						if(DoorLocked[DoorEnt])
						{
							CPrintToChat(Client, "{white}|RP| -{grey} Door is superlocked. (sm_lockit)");
						}
						else
						{
							//Metal:
							if(StrEqual(ClassName, "func_door"))
							{
								if(DoorLocks[DoorEnt] < 1)
								{
									//Unlock:
									AcceptEntityInput(DoorEnt, "Unlock", Client);
									AcceptEntityInput(DoorEnt, "Toggle", Client);
									
									//Print:
									CPrintToChat(Client, "{white}|RP| -{grey} Door has been opened");
									
									//Save:
									HackTime[Client] = GetGameTime();
									AddCrime(Client,100); 
								}
								else
								{
									CPrintToChat(Client, "{white}|RP| -{grey} This door has some additional locks!");
								}
							}
						}
						
						//Doors:
						if(StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
						{
							
							//Print:
							CPrintToChat(Client, "{white}|RP| -{grey} Cannot be used on this door");
						}
					}
				}
				else
				{
					
					CPrintToChat(Client, "{white}|RP| -{grey} You can only use this once every %d minutes", Var);
				}
			}
			
			//Furniture:
			if(ItemAction[ItemId] == 7)
			{
				/*if(PropLimit[Client] != 15)
				{				*/
					if(StrEqual(ItemVar[ItemId], "models/props_lab/reciever01b.mdl", false) && (IsCombine(Client) || IsFirefighter(Client)))
					{
						CPrintToChat(Client, "{white}|RP| -{grey} Your not allowed to spawn bombs. Do your job!");
					}
					else
					{
						//Declare:
						decl Ent;
						decl Float:EyeAngles[3];
						decl Float:ClientOrigin[3], Float:FurnitureOrigin[3];
						
						//Initialize:
						GetClientAbsOrigin(Client, ClientOrigin);
						GetClientEyeAngles(Client, EyeAngles);
						
						//Math:
						FurnitureOrigin[0] = (ClientOrigin[0] + (50 * Cosine(DegToRad(EyeAngles[1]))));
						FurnitureOrigin[1] = (ClientOrigin[1] + (50 * Sine(DegToRad(EyeAngles[1]))));
						FurnitureOrigin[2] = (ClientOrigin[2] + 100);
						
						//Print:
						CPrintToChat(Client, "{white}|RP| -{grey} You spawn a %s!", ItemName[ItemId]);
						
						//Create:
						Ent = CreateEntityByName("prop_physics_override");
						
						//Key Values:
						//Finally destroyable props! god damn.
						DispatchKeyValue(Ent, "physdamagescale", "1.0");
						SetEntProp(Ent, Prop_Data, "m_takedamage", 2, 1);
						DispatchKeyValue(Ent, "Health", "100");
						
						//Model:
						DispatchKeyValue(Ent, "model", ItemVar[ItemId]);
						
						//Spawn & Send:
						DispatchSpawn(Ent);
						TeleportEntity(Ent, FurnitureOrigin, NULL_VECTOR, NULL_VECTOR);
						
						if(StrEqual(ItemVar[ItemId], "models/props_lab/reciever01b.mdl", false) && !IsCombine(Client) && !IsFirefighter(Client))
						{
							CPrintToChat(Client, "{white}|RP| -{grey} Press E on the bomb to activate.");
							BombData[Ent][1] = 0;
							BombData[Ent][2] = 0;
							BombData[Ent][3] = 9999;
							BombData[Ent][4] = 0;
							BombData[Ent][5] = 0;
						} else {
							AddPropToList(Client, Ent, ItemId);
						}
						
						//Remove:
						Item[Client][ItemId] -= 1;
					}
				/*}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You already have {green}15{grey} spawned props!");
				}*/
			}
			
			//Med Kits:
			if(ItemAction[ItemId] == 8)
			{
				
				//Declare:
				decl Var;
				decl Player;
				decl PlayerHP;
				decl String:ClientName[32], String:PlayerName[32];
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				Player = GetClientAimTarget(Client, true);
				PlayerHP = GetClientHealth(Player);
				GetClientName(Client, ClientName, 32);
				GetClientName(Player, PlayerName, 32);
				
				//Legit:
				if(Player > 0)
				{
					
					//Connected:
					if(IsClientConnected(Player) && IsClientInGame(Player))
					{
						if(PlayerHP >= 100)
						{
							CPrintToChat(Client, "{white}|RP| -{grey} The player %s does already have full HP!", PlayerName);
						}
						else
						{
							//Work:
							if((PlayerHP + Var) > 100) SetEntityHealth(Player, 100);
							else SetEntityHealth(Player, (PlayerHP + Var));
							
							//Print:
							CPrintToChat(Client, "{white}|RP| -{grey} You heal %s for +%dHP!", PlayerName, Var);
							CPrintToChat(Player, "{white}|RP| -{grey} You have been healed by %s for +%dHP!", ClientName, Var);
							Item[Client][ItemId] -= 1;
						}
					}
				}
				else
				{
					
					//Print:
					CPrintToChat(Client, "{white}|RP| -{grey} Invalid Player");
				}
			}
			
			//Saw:
			if(ItemAction[ItemId] == 9)
			{
				
				//Declare:
				decl Var;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				
				//Buffer:
				if(SawTime[Client] <= (GetGameTime() - (60 * Var)))
				{
					
					//Not Cuffed:
					if(!IsCuffed[Client])
					{
						
						//Declare:
						decl Player;
						
						//Initialize:
						Player = GetClientAimTarget(Client, true);
						
						//Legit:
						if(Player > 0)
						{
							
							//Connected:
							if(IsClientConnected(Player) && IsClientInGame(Player))
							{
								
								//Declare:
								decl String:ClientName[32], String:PlayerName[32];
								
								//Initialize:
								GetClientName(Client, ClientName, 32);
								GetClientName(Player, PlayerName, 32);
								
								//Cuffed:
								if(IsCuffed[Player])
								{
									
									
									//Print:
									CPrintToChat(Client, "{white}|RP| -{grey} You saw the handcuffs off of %s!", PlayerName);
									CPrintToChat(Player, "{white}|RP| -{grey} %s sawed off your handcuffs!", ClientName);
									
									//Action:
									Uncuff(Player);
									
									//Save:
									SawTime[Client] = GetGameTime();
								}
								else
								{
									
									//Print:
									CPrintToChat(Client, "{white}|RP| -{grey} %s is not cuffed", PlayerName);
								}
							}
						}
						else
						{
							
							//Print:
							CPrintToChat(Client, "{white}|RP| -{grey} Invalid Player");
						}
					}
					else
					{
						
						//Print:
						CPrintToChat(Client, "{white}|RP| -{grey} You cannot do this while cuffed");
						
					}
				}
				else
				{
					
					//Print:
					CPrintToChat(Client, "{white}|RP| -{grey} You can only use this once every %d minutes", Var);
				}
			}
			
			//Bombs:
			if(ItemAction[ItemId] == 10)
			{
				
				//Not Cuffed:
				if(!IsCuffed[Client])
				{
					decl ClientID;
					ClientID = GetClientUserId(Client);
					
					//Send:
					ServerCommand("%s #%d 1", ItemVar[ItemId], ClientID);
					
					//Save:
					Item[Client][ItemId] -= 1;
				}
				
			}
			
			//Trap - Disable Using:
			if(ItemAction[ItemId] == 11)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You can only drop traps.");
			}
			
			//Raffle Tickets:
			if(ItemAction[ItemId] == 12)
			{
				//Declare:
				decl Var,Winamount;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				
				new random = GetRandomInt(1,200);
				if(random < 50)
				{
					Winamount = 10*Var;
				} else if(random < 60)
				{
					Winamount = 20*Var;
				} else if(random == 98)
				{
					Winamount = 100*Var;
				} else if(random == 99 && RaffleWin[Client] < 0)
				{
					Winamount = 200*Var;
				} else if(random == 100 && RaffleWin[Client] < 0)
				{
					Winamount = 500*Var;
				} else if(random > 180)
				{
					Winamount = 2*Var;
				} else if(random > 170)
				{
					Winamount = 5*Var;
				} 
				
				if(Winamount > 0)
					CPrintToChat(Client, "{white}|RP-Lottery| -{grey}  You won %d$",Winamount);
				else
				CPrintToChat(Client, "{white}|RP-Lottery| -{grey}  You draw a blank");
				RaffleWin[Client] += Winamount - 10*Var;
				Money[Client] += Winamount;
				Item[Client][ItemId] -= 1;
				if(Winamount >= 200*Var)
				{
					decl String:ClientName[255];
					GetClientName(Client, ClientName, sizeof(ClientName));
					new MaxPlayers = GetMaxClients();
					for(new X = 1; X <= MaxPlayers; X++)
					{
						//Connected:
						if(IsClientConnected(X) && IsClientInGame(X) && X != Client)
						{
							CPrintToChat(X, "\x01\x04{white}|RP-Lottery| -{grey} \x01 The Player \"%s\" hit the jackpot and won $%d with a $%d ticket",ClientName,Winamount,10*Var);        
						}
					}
				}
			}
			
			//AddLock
			if(ItemAction[ItemId] == 13)
			{
				//Declare:
				decl DoorEnt;
				decl String:ClassName[255];
				
				//Initialize:
				DoorEnt = GetClientAimTarget(Client, false);
				
				//ClassName:
				GetEdictClassname(DoorEnt, ClassName, 255);
				
				//Action:
				if(DoorEnt > 1)
				{
					if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
					{
						if(StringToInt(Spliter[1]) == 4)
						{
							if(Item[Client][ItemId] >= 5)
							{
								DoorLocks[DoorEnt] += 5;
								Item[Client][ItemId] -= 5;
								CPrintToChat(Client, "{white}|RP| -{grey} Added 5 locks on the door"); 
							}
							else
							{
								CPrintToChat(Client, "{white}|RP| -{grey} You do not have 5 locks.");
							}
						}
						else if(StringToInt(Spliter[1]) == 5)
						{
							if(Item[Client][ItemId] >= 10)
							{
								DoorLocks[DoorEnt] += 10;
								Item[Client][ItemId] -= 10;
								CPrintToChat(Client, "{white}|RP| -{grey} Added 10 locks on the door"); 
							}
							else
							{
								CPrintToChat(Client, "{white}|RP| -{grey} You do not have 10 locks.");
							}
						}
						else
						{
							DoorLocks[DoorEnt] += 1;
							Item[Client][ItemId] -= 1;
							CPrintToChat(Client, "{white}|RP| -{grey} Added a lock on the door"); 
						}	
						decl Handle:Vault;
						decl String:DoorId[255];
						decl String:LockNr[255];
						
						Vault = CreateKeyValues("Vault");
						IntToString(DoorEnt,DoorId,20);
						IntToString(DoorLocks[DoorEnt],LockNr,20);
						FileToKeyValues(Vault, LockPath); 
						SaveString(Vault, "2", DoorId, LockNr);
						KeyValuesToFile(Vault, LockPath);
						CloseHandle(Vault); 
					}
					else
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You cannot add a Doorlock to this.");
					}
				}
			}
			
			//Destroylock
			if(ItemAction[ItemId] == 14)
			{
				//Declare:
				decl DoorEnt;
				decl String:ClassName[255];
				
				//Initialize:
				DoorEnt = GetClientAimTarget(Client, false);
				
				//ClassName:
				GetEdictClassname(DoorEnt, ClassName, 255);
				
				//Action:
				if(DoorEnt > 1)
				{
					if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
					{
						if(DoorLocks[DoorEnt] < 1)
							CPrintToChat(Client, "{white}|RP| -{grey} This door has no additional locks");
						else
						{
							DoorLocks[DoorEnt] -= 1;
							Item[Client][ItemId] -= 1;
							decl Handle:Vault;
							decl String:DoorId[255];
							decl String:LockNr[255];
							
							Vault = CreateKeyValues("Vault");
							IntToString(DoorEnt,DoorId,20);
							IntToString(DoorLocks[DoorEnt],LockNr,20);
							FileToKeyValues(Vault, LockPath); 
							SaveString(Vault, "2", DoorId, LockNr);
							KeyValuesToFile(Vault, LockPath);
							CloseHandle(Vault); 
							CPrintToChat(Client, "{white}|RP| -{grey} You broke a lock on this door"); 
						}
					}
					else
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You cannot remove a Doorlock from this.");
					}
				}
			}
			
			//GPS Bug
			if(ItemAction[ItemId] == 15)
			{
				decl Player;
				//Initialize:
				Player = GetClientAimTarget(Client, true);
				
				//Legit:
				if(Player > 0)
				{
					GPS[Client][Player] = true;
					decl String:PlayerName[32];
					GetClientName(Player, PlayerName, 32);
					CPrintToChat(Client, "{white}|RP| -{grey} You hide a GPS Bug on %s.",PlayerName);
					CPrintToChat(Client, "{white}|RP| -{grey} You can trigger the tracers by saying /tracers");
					Item[Client][ItemId] -= 1; 
				}
			}
			
			//GPS Scanner
			if(ItemAction[ItemId] == 16)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Scanning for GPS Bugs...");
				for(new X = 0; X < 32; X++)
				{
					if(GPS[X][Client] == 1)
					{
						decl String:PlayerName[32];
						GetClientName(X, PlayerName, 32);
						CPrintToChat(Client, "{white}|RP| -{grey} Found a GPS Bug from %s.",PlayerName);
						GPS[X][Client] = 0;
						Item[Client][ItemId] -= 1; 
					} 	
				}
			}
			
			//Police scanner
			if(ItemAction[ItemId] == 17)
			{
				//Declare:
				decl Var;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				CPrintToChat(Client, "{white}|RP| -{grey} Initializing Police Scanner for %d minutes",Var);
				ScannerTime[Client] = GetGameTime() + (60*Var);
				Item[Client][ItemId] -= 1; 
			}
			
			//Police jammer
			if(ItemAction[ItemId] == 18)
			{
				//Declare:
				decl Var;
				
				//Initialize:
				Var = StringToInt(ItemVar[ItemId]);
				CPrintToChat(Client, "{white}|RP| -{grey} Initializing Police Jammer for %d minutes",Var);
				InterruptTime[Client] = GetGameTime() + (60*Var);
				Item[Client][ItemId] -= 1; 
			}
			
			if(ItemAction[ItemId] == 19)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You cannot use a check! You can give, drop, or cash it in at a bank (click banker npc and click cash in)");
			}
			//Main Hud Color
			if(ItemAction[ItemId] == 20)
			{
				decl Var;
				Var = StringToInt(ItemVar[ItemId]);
				if(Var == 1)
				{
					MainHudColor[Client] = 1;
					CPrintToChat(Client, "{white}|RP| -{grey} Main Hud Color: Red");
				}
				if(Var == 2)
				{
					MainHudColor[Client] = 2;
					CPrintToChat(Client, "{white}|RP| -{grey} Main Hud Color: Orange");
				}
				if(Var == 3)
				{
					MainHudColor[Client] = 3;
					CPrintToChat(Client, "{white}|RP| -{grey} Main Hud Color: Green");
				}
				if(Var == 4)
				{
					MainHudColor[Client] = 4;
					CPrintToChat(Client, "{white}|RP| -{grey} Main Hud Color: Blue");
				}
				if(Var == 5)
				{
					MainHudColor[Client] = 5;
					CPrintToChat(Client, "{white}|RP| -{grey} Main Hud Color: Purple");
				}
				if(Var == 6)
				{
					MainHudColor[Client] = 6;
					CPrintToChat(Client, "{white}|RP| -{grey} Main Hud Color: White");
				}
				if(Var == 7)
				{
					MainHudColor[Client] = 7;
					CPrintToChat(Client, "{white}|RP| -{grey} Main Hud Color: Gold");
				}
				Item[Client][ItemId] -= 1;
			}
			
			//Center Hud Color
			if(ItemAction[ItemId] == 21)
			{
				decl Var;
				Var = StringToInt(ItemVar[ItemId]);
				if(Var == 1)
				{
					CenterHudColor[Client] = 1;
					CPrintToChat(Client, "{white}|RP| -{grey} Center Hud Color: Red");
				}
				if(Var == 2)
				{
					CenterHudColor[Client] = 2;
					CPrintToChat(Client, "{white}|RP| -{grey} Center Hud Color: Orange");
				}
				if(Var == 3)
				{
					CenterHudColor[Client] = 3;
					CPrintToChat(Client, "{white}|RP| -{grey} Center Hud Color: Green");
				}
				if(Var == 4)
				{
					CenterHudColor[Client] = 4;
					CPrintToChat(Client, "{white}|RP| -{grey} Center Hud Color: Blue");
				}
				if(Var == 5)
				{
					CenterHudColor[Client] = 5;
					CPrintToChat(Client, "{white}|RP| -{grey} Center Hud Color: Purple");
				}
				if(Var == 6)
				{
					CenterHudColor[Client] = 6;
					CPrintToChat(Client, "{white}|RP| -{grey} Center Hud Color: White");
				}
				if(Var == 7)
				{
					CenterHudColor[Client] = 7;
					CPrintToChat(Client, "{white}|RP| -{grey} Center Hud Color: Gold");
				}
				Item[Client][ItemId] -= 1;
			}
			
			//Models
			if(ItemAction[ItemId] == 22)
			{
				Override[Client] = 0;
				if(IsCombine(Client) && !IsUnderCover(Client))		
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You cannot use skins as a combine.");
				}
				if(!IsCombine(Client) || IsUnderCover(Client))
				{
					Override[Client] = 1;
					//decl Var;
					//Var = StringToInt(ItemVar[ItemId]);
					SetEntityModel(Client, (ItemVar[ItemId]));
					PlayerModel[Client] = (ItemVar[ItemId]);
					CPrintToChat(Client, "{white}|RP| -{grey} You have become: %s", (ItemVar[ItemId]));
					
					/*if(Var == 1)
					{
						SetEntityModel(Client, "models/alyx.mdl");
						PlayerModel[Client] = "models/alyx.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become alyx.");
					}
					if(Var == 2)
					{
						SetEntityModel(Client, "models/eli.mdl");
						PlayerModel[Client] = "models/eli.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become eli.");
					}
					if(Var == 3)
					{
						SetEntityModel(Client, "models/breen.mdl");
						PlayerModel[Client] = "models/breen.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become breen.");
					}	
					if(Var == 4)
					{
						SetEntityModel(Client, "models/kleiner.mdl");
						PlayerModel[Client] = "models/kleiner.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become kleiner.");
					}	
					if(Var == 5)
					{
						SetEntityModel(Client, "models/barney.mdl");
						PlayerModel[Client] = "models/barney.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become barney.");
					}
					if(Var == 6)
					{
						SetEntityModel(Client, "models/mossman.mdl");
						PlayerModel[Client] = "models/mossman.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become mossman.");
					}
					if(Var == 7)
					{
						SetEntityModel(Client, "models/gman.mdl");
						PlayerModel[Client] = "models/gman.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become gman.");
					}
					if(Var == 8)
					{
						SetEntityModel(Client, "models/player/snake.mdl");
						PlayerModel[Client] = "models/player/snake.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become snake.");
					}
					if(Var == 9)
					{
						SetEntityModel(Client, "models/police.mdl");
						PlayerModel[Client] = "models/police.mdl";
						CPrintToChat(Client, "{white}|RP| -{grey} You have become a police spy.");
					}
					*/
				}
			}
			
			//Sprite Trails
			if(ItemAction[ItemId] == 23)
			{
				if(IsClientConnected(Client) && IsClientInGame(Client))
				{
					if(TrailSpam[Client] == 5)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You have maxed out the amount of trails spawned");
					}
					else
					{
						if(TrailAmount[Client] == 10) TrailAmount[Client] = 0;
						TrailAmount[Client] += 1;
						TrailSpam[Client] += 1;
						new String:tName[128];
						Format(tName, sizeof(tName), "target%i", Client);
						DispatchKeyValue(Client, "targetname", tName);
						
						new trail = CreateEntityByName("env_spritetrail");
						DispatchKeyValue(trail, "parentname", tName);
						SetVariantString(tName);
						DispatchKeyValue(trail, "renderamt", "255");
						DispatchKeyValue(trail, "rendercolor", ItemVar[ItemId]);
						DispatchKeyValue(trail, "rendermode", "1");
						DispatchKeyValue(trail, "spritename", "materials/sprites/laserbeam.vmt");
						DispatchKeyValue(trail, "lifetime", "1.5");
						DispatchKeyValue(trail, "startwidth", "7");
						DispatchKeyValue(trail, "endwidth", "0.1");
						DispatchSpawn(trail);
						
						decl Float:CurrentOrigin[3];
						GetClientAbsOrigin(Client, CurrentOrigin);
						if(TrailAmount[Client] == 1) CurrentOrigin[2] += 10.0;
						if(TrailAmount[Client] == 2) CurrentOrigin[2] += 20.0;
						if(TrailAmount[Client] == 3) CurrentOrigin[2] += 30.0;
						if(TrailAmount[Client] == 4) CurrentOrigin[2] += 40.0;
						if(TrailAmount[Client] == 5) CurrentOrigin[2] += 50.0;
						TeleportEntity(trail, CurrentOrigin, NULL_VECTOR, NULL_VECTOR);
						AcceptEntityInput(trail, "SetParent", trail, trail);
						Item[Client][ItemId] -= 1;
						CPrintToChat(Client, "{white}|RP| -{grey} %s is now enabled. [%d/5 Active] (Trail will die off when you leave)", ItemName[ItemId], TrailSpam[Client]);
						CreateTimer(9999999999999.0, KillEffect, trail);
						CreateTimer(9999999999999.0, MinusTrail, Client);
					}
				}
			}
			//Full Suit
			if(ItemAction[ItemId] == 24)
			{
				
				//Give:
				GivePlayerItem(Client, "item_battery");
				GivePlayerItem(Client, "item_battery");
				GivePlayerItem(Client, "item_battery");
				GivePlayerItem(Client, "item_battery");
				GivePlayerItem(Client, "item_battery");
				GivePlayerItem(Client, "item_battery");
				GivePlayerItem(Client, "item_battery");
				//Client_SetArmor(Client, 100);
				//EmitSoundToClient(Client, "items/battery_pickup.wav", SOUND_FROM_PLAYER, 1);
				
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You use %s", ItemName[ItemId]);
				
				//Save:
				Item[Client][ItemId] -= 1;
			}
			//Money Drop Item
			if(ItemAction[ItemId] == 25)
			{
				
				//Code
				decl String:Var;
				decl String:Player[MAX_NAME_LENGTH];
				decl Float:ClientOrigin[3];
				
				
				//Initialize:
				GetClientAbsOrigin(Client, ClientOrigin);
				//Write:
				TE_SetupExplosion(ClientOrigin, 0, 30.0, 30, 0, 100, 100);
				
				//Initialize:
				GetClientName(Client, Player, 32);
				Var = StringToInt(ItemVar[ItemId]);
				CreateMoneyBoxes(Client, Var);
				GivePlayerItem(Client, "rpg_missile");
				TE_SendToAll();
				CPrintToChatAll("{white}|RP| -{green}%s {grey}has just spawned $%d", Player, Var);
				
				//Save
				Item[Client][ItemId] -=1;
			}
			//Crime Eraser
			if(ItemAction[ItemId] == 26)
			{
				decl CrimeLimit;
				decl Var;
				Var = StringToInt(ItemVar[ItemId]);
				CrimeLimit = GetConVarInt(CuffCrime);
				
				if(Crime[Client] >= CrimeLimit)
				{
					Crime[Client] -= Var;
					CPrintToChat(Client, "{white}|RP| -{grey}You have just dropped %d crime!", Var);
				}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey}You do not have cuffable crime.");
				}
				
				//Save
				Item[Client][ItemId] -=1;
			}
			//Jetpack
			if(ItemAction[ItemId] == 27)
			{
				decl Jetpack;
				if(Jetpack > 0)
				{
					PermitJetpack[Client] = true;
				}
				CPrintToChat(Client, "{white}|RP| -{grey} You have equipped a Jetpack! Bind +sm_jetpack to a key to use it!");
				//Save
				Item[Client][ItemId] -=1;
			}	
			//Permanant Jetpack
			if(ItemAction[ItemId] == 28)
			{
				decl Jetpack;
				if(Jetpack > 0)
				{
					PermitJetpack[Client] = true;
				}
				CPrintToChat(Client, "{white}|RP| -{grey} You have equipped a Jetpack! Bind +sm_jetpack to a key to use it!");
			}
			//Cloak Item
			if(ItemAction[ItemId] == 29)
			{
				decl Alpha;
				Alpha = StringToInt(ItemVar[ItemId]);
				
				//Set Mode		
				SetEntityRenderMode(Client, RENDER_TRANSCOLOR);
				
				//Set Color
				SetEntityRenderColor(Client, 255, 255, 255, Alpha);
				
				//Loop to hide weapon
				for(new i = 0, Weapon; i < 47; i += 4)
				{

					//Initialize:
					Weapon = GetEntDataEnt2(Client, WeaponOffset + i);

					//Is Valid Weapon:
					if(Weapon > -1)
					{
						//Set Weapon Render:
						SetEntityRenderMode(Weapon, RENDER_TRANSCOLOR);
						//Set Weapon Color
						SetEntityRenderColor(Weapon, 255, 255, 255, Alpha);
					
					}
				}
				
				//Print
				CPrintToChat(Client, "{white}|RP| -{grey} You have equipped a level %d cloak!", Alpha);
			}
			//Player Colors
			if(ItemAction[ItemId] == 30)
			{
				decl Var;
				Var = StringToInt(ItemVar[ItemId]);
				
				if(Var == 1)
				{
					SetEntityRenderMode(Client, RENDER_TRANSCOLOR);
					SetEntityRenderColor(Client, 255, 0, 0, 255);
				}
				if(Var == 2)
				{
					SetEntityRenderMode(Client, RENDER_TRANSCOLOR);
					SetEntityRenderColor(Client, 0, 255, 0, 255);
				}
				if(Var == 3)
				{
					SetEntityRenderMode(Client, RENDER_TRANSCOLOR);
					SetEntityRenderColor(Client, 0, 0, 255, 255);
				}
				if(Var == 4)
				{
					SetEntityRenderMode(Client, RENDER_TRANSCOLOR);
					SetEntityRenderColor(Client, 255, 125, 0, 255);
				}
				if(Var == 5)
				{
					SetEntityRenderMode(Client, RENDER_TRANSCOLOR);
					SetEntityRenderColor(Client, 255, 0, 255, 255);
				}
				
				CPrintToChat(Client, "{white}|RP| -{grey} You have changed your color!");
			}
			//God Suit Item
			if(ItemAction[ItemId] == 31)
			{
				SetEntProp(Client, Prop_Data, "m_takedamage", 0, 1);
				GodMode[Client] = 1; 
				Item[Client][ItemId] -= 1;
			}
			//Ghost Suit Item
			if(ItemAction[ItemId] == 32)
			{
				decl String:ClientName[32];
				
				GetClientName(Client, ClientName, sizeof(ClientName));
				ServerCommand("sm_noclip %d", ClientName);
				Item[Client][ItemId] -= 1;
			}
			//Bank Doubler Item
			if(ItemAction[ItemId] == 33)
			{
				//Declare
				decl String:PlayerName[MAX_NAME_LENGTH];
				
				//Initialize
				GetClientName(Client, PlayerName, sizeof(PlayerName));
				
				//Set
				Bank[Client] *= 2;
				
				//Print
				CPrintToChat(Client, "{white}|RP| -{grey}{green}%s {grey}has just doubled their bank to: {green}$%d{grey}!", PlayerName, Bank[Client]);
				
				//Save
				Item[Client][ItemId] -=1;
			}
			//Money Printer Item
			if(ItemAction[ItemId] == 34)
			{
				decl Float:ClientOrigin[3];
				GetClientAbsOrigin(Client, ClientOrigin);
				
				for(new R = 0; R < 1; R++)
				{
					if(Printer[Client][R][0] == 0.0)
					{
						decl Float:DOrigin[3];
						GetClientAbsOrigin(Client, DOrigin);
						Printer[Client][R][0] = DOrigin[0];
						Printer[Client][R][1] = DOrigin[1];
						Printer[Client][R][2] = DOrigin[2] + 5.0;
						AddCrime(Client, 350);
						PrinterWorth[Client][R] = 0;
						CPrintToChat(Client, "{white}|RP-Printer| -{grey}  Created a Printer!");
						
						decl Ent;
						Ent = CreateEntityByName("prop_physics_override");
						//DispatchKeyValue(Ent, "physdamagescale", "0.0");
						DispatchKeyValue(Ent, "solid", "0");
						SetEntityRenderColor(Ent, 0, 255, 0, 255);
						DispatchKeyValue(Ent, "model", "models/props_lab/reciever01a.mdl");
						DispatchSpawn(Ent);
						SetEntData(Ent, SolidGroup, 2, 4, true);
						TeleportEntity(Ent, Printer[Client][R], NULL_VECTOR, NULL_VECTOR);
						DOrigin[2] += 30.0;
						TeleportEntity(Client, DOrigin, NULL_VECTOR, NULL_VECTOR);
						PrinterEnt[Client][R] = Ent;
						SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);
						AcceptEntityInput(Ent, "DisableMotion");
						
						//Save
						Item[Client][ItemId] -= 1;
					}
					else
					{
						CPrintToChat(Client, "{white}|RP-Printer| -{grey}  You already have a Money Printer Spawned!");
					}			
				}
			}
			if(ItemAction[ItemId] == 36)
			{
				{
					CPrintToChat(Client, "{white}|RP|{grey} - To use a Freedom Card, use /freedomcard while cuffed.");
				}
			}
			Save(Client);
		}
		
		//Drop:
		if(StringToInt(Spliter[1]) == 2)
		{
			decl String:HiddenInfo[12], String:AllIn[64];
			new Handle:DropAmount = CreateMenu(DropMenu);
			SetMenuTitle(DropAmount, "Dropping %s(s)\n=============\n%d left", ItemName[ItemId], Item[Client][ItemId]);
			
			decl String:Buffers[7][10] = {"69", "1", "5", "25", "100", "500", "1000"};
			
			for(new X = 0; X < 7; X++)
			{
				if(StringToInt(Buffers[X]) == 69)
				{
					Format(AllIn, 64, "All (%d)", Item[Client][ItemId]);
					Format(HiddenInfo, 12, "%d-%d", ItemId, Item[Client][ItemId]);
					AddMenuItem(DropAmount, HiddenInfo, AllIn);
				}
				else
				{
					Format(HiddenInfo, 12, "%d-%s", ItemId, Buffers[X]);
					AddMenuItem(DropAmount, HiddenInfo, Buffers[X]);
				}
			}
			SetMenuPagination(DropAmount, 7);
			DisplayMenu(DropAmount, Client, 30);
		}
		if(StringToInt(Spliter[1]) == 3)
		{
			Inventory(Client);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(ItemUse);
	}
	return 0;
}
/*
public Action:Command_SetUsage(Client, Args)
{
	decl String:Player1[32];
	decl String:Props[32];
	decl String:Target[MAX_NAME_LENGTH];
	if(Args != 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Syntax: sm_setpropsused <player> <amount>");
		return Plugin_Handled;
	}
	GetCmdArg(1, Player1, sizeof(Player1));
	new Player = FindTarget(Client, Player1);
		
	GetCmdArg(2, Props, sizeof(Props));
	new Usage = StringToInt(Props, sizeof(Props));
		
	if(Player == -1)
	{
		ReplyToCommand(Client, "Invalid Target");
		return Plugin_Handled;
	}
	PropLimit[Player] = Usage;
	Save(Player);
	GetClientName(Player, Target, sizeof(Target));
	CPrintToChat(Client, "{white}|RP| -{grey} You set the used props of {green}%s {grey}to {green}%d{grey}.", Target, Usage);
	return Plugin_Handled;
}
*/
public Action:KillEffect(Handle:Timer, any:trail)
{
	if(IsValidEntity(trail))
	{
		decl String:Checker[128];
		GetEdictClassname(trail, Checker, sizeof(Checker));
		if(StrEqual(Checker, "env_spritetrail", true))
		{
			AcceptEntityInput(trail, "Kill");
		}
	}
}

public Action:MinusTrail(Handle:Timer, any:Client)
{
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{
		if(TrailSpam[Client] > 0)
		{
			TrailSpam[Client] -= 1;
		}
	}
}

//Giving:
public GiveMenu(Handle:GiveAmount, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		//Valid:
		if(IsClientConnected(MenuTarget[Client]) && IsClientInGame(MenuTarget[Client]))
		{
			new String:info[64];
			GetMenuItem(GiveAmount, param2, info, sizeof(info));
			
			decl String:Spliter[2][255];
			ExplodeString(info, "-", Spliter, 2, 32);
			
			//Declare:
			decl ItemId, Amount;
			
			//Initialize:
			ItemId = StringToInt(Spliter[0]);
			Amount = StringToInt(Spliter[1]);
			
			//Has:
			if(Item[Client][ItemId] - Amount >= 0)
			{
				
				//Declare:
				decl String:ClientName[32], String:PlayerName[32];
				
				//Initialize:
				GetClientName(Client, ClientName, 32);
				GetClientName(MenuTarget[Client], PlayerName, 32);
				
				//Action:
				Item[Client][ItemId] -= Amount;
				Save(Client);
				
				Item[MenuTarget[Client]][ItemId] += Amount;
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You give %s %d x %s!", PlayerName, Amount, ItemName[ItemId]);
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} You recieve %d x %s from %s!", Amount, ItemName[ItemId], ClientName);
				
				//Save:
				IsGiving[Client] = true;
				
				//Send:
				Inventory(Client);
				
				//Save:
				
				Save(MenuTarget[Client]);
			}
			else
			{
				
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You don't have %d x %s!", Amount, ItemName[ItemId]);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(GiveAmount);
	}
	return 0;
}

//Drop Menu Handle:
public DropMenu(Handle:DropAmount, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(DropAmount, param2, info, sizeof(info));
		
		decl String:Spliter[2][255];
		ExplodeString(info, "-", Spliter, 2, 32);
		
		
		//Declare:
		decl ItemId, Amount;
		decl Ent, Collision;
		decl Float:Position[3];
		new Float:Angles[3] = {0.0, 0.0, 0.0};
		
		//Initialize:
		ItemId = StringToInt(Spliter[0]);
		Ent = CreateEntityByName("prop_physics");
		
		//Check:
		Amount = StringToInt(Spliter[1]);
		
		//Has:
		if(Item[Client][ItemId] - Amount >= 0 && Amount > 0)
		{
			
			//Values:
			DispatchKeyValue(Ent, "model", "models/Items/BoxMRounds.mdl");
			
			//Spawn:
			DispatchSpawn(Ent);
			
			//Angles:
			Angles[1] = GetRandomFloat(0.0, 360.0);
			
			//Position:
			GetClientAbsOrigin(Client, Position);
			Position[2] += 10.0;
			
			//Debris:
			Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
			if(IsValidEntity(Ent)) SetEntData(Ent, Collision, 1, 1, true);
			
			//Send:
			TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
			
			//Update:
			ItemAmount[Ent][ItemId] = Amount;
			
			//Send:
			CPrintToChat(Client, "{white}|RP| -{grey} You drop %d x %s", Amount, ItemName[ItemId]);
			Item[Client][ItemId] -= Amount;
			Save(Client);
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You don't have %d x %s!", Amount, ItemName[ItemId]);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(DropAmount);
	}
	return 0;
}

//Cash or Credit:
public Pay(Handle:Payment, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(Payment, param2, info, sizeof(info));
		
		if(!StrContains(info, "Cash", false))
		{
			decl String:Argument_Buffers[3][255];
			ExplodeString(info, "-", Argument_Buffers, 3, 32);
			
			decl NUM;
			NUM = StringToInt(Argument_Buffers[1]);
			
			decl VEN;
			VEN = StringToInt(Argument_Buffers[2]);
			
			if(Money[Client] >= ItemCost[NUM])
			{
				Money[Client] -= ItemCost[NUM];
				Item[Client][NUM] += 1;
				CPrintToChat(Client, "{white}|RP| -{grey} You purchase 1 x %s for %d$ with cash", ItemName[NUM],ItemCost[NUM]);
				Save(Client);
				VendorMenuNEW(Client, VEN);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You don't have enough money for this item");
			}
		}
		if(!StrContains(info, "Credit", false))
		{
			decl String:Argument_BuffersT[3][32];
			ExplodeString(info, "-", Argument_BuffersT, 3, 32);
			
			decl NUM;
			NUM = StringToInt(Argument_BuffersT[1]);
			
			decl VEN;
			VEN = StringToInt(Argument_BuffersT[2]);
			
			if(Bank[Client] >= (-1000 + ItemCost[NUM]))
			{
				Bank[Client] -= ItemCost[NUM];
				Item[Client][NUM] += 1;
				CPrintToChat(Client, "{white}|RP| -{grey} You purchase 1 x %s for %d$ with a credit card", ItemName[NUM],ItemCost[NUM]);
				Save(Client);
				VendorMenuNEW(Client, VEN);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You cannot go below $-1000 with credit");
			}
		}
		if(!StrContains(info, "Bulk", false))
		{
			decl String:Argument_BuffersB[3][32];
			ExplodeString(info, "-", Argument_BuffersB, 3, 32);
			decl NUM;
			NUM = StringToInt(Argument_BuffersB[1]);
			decl VEN;
			VEN = StringToInt(Argument_BuffersB[2]);
			
			decl String:TwoX[64], String:FiveX[64], String:TenX[64], String:TFX[64], String:Title[64];
			decl String:TwoXS[64], String:FiveXS[64], String:TenXS[64], String:TFXS[64];
			
			Format(Title, 64, "Bulk [%s|-", ItemName[NUM]);
			Format(TwoX, 64, "2-%d-%d", NUM, VEN);
			Format(FiveX, 64, "5-%d-%d", NUM, VEN);
			Format(TenX, 64, "10-%d-%d", NUM, VEN);
			Format(TFX, 64, "25-%d-%d", NUM, VEN);
			
			Format(TwoXS, 64, "2x - $%d", (ItemCost[NUM] * 2));
			Format(FiveXS, 64, "5x - $%d", (ItemCost[NUM] * 5));
			Format(TenXS, 64, "10x - $%d", (ItemCost[NUM] * 10));
			Format(TFXS, 64, "25x - $%d", (ItemCost[NUM] * 25));
			
			new Handle:PaymentBulk = CreateMenu(PayBulk);
			SetMenuTitle(PaymentBulk, Title);
			if((ItemCost[NUM] * 2) > 0) AddMenuItem(PaymentBulk, TwoX, TwoXS);
			if((ItemCost[NUM] * 5) > 0) AddMenuItem(PaymentBulk, FiveX, FiveXS);
			if((ItemCost[NUM] * 10) > 0) AddMenuItem(PaymentBulk, TenX, TenXS);
			if((ItemCost[NUM] * 25) > 0) AddMenuItem(PaymentBulk, TFX, TFXS);
			SetMenuPagination(PaymentBulk, 7);
			DisplayMenu(PaymentBulk, Client, 30);
		}
		if(!StrContains(info, "Back", false))
		{
			decl String:CheckVen[3][32];
			ExplodeString(info, "-", CheckVen, 3, 32);
			decl VEN;
			VEN = StringToInt(CheckVen[2]);
			VendorMenuNEW(Client, VEN);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Payment);
	}
	return 0;
}

public PayBulk(Handle:PaymentBulk, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(PaymentBulk, param2, info, sizeof(info));
		
		decl String:Bulk_Buffers[3][32];
		ExplodeString(info, "-", Bulk_Buffers, 3, 32);
		
		decl AMOUNT;
		AMOUNT = StringToInt(Bulk_Buffers[0]);
		
		decl NUM;
		NUM = StringToInt(Bulk_Buffers[1]);
		
		decl VEN;
		VEN = StringToInt(Bulk_Buffers[2]);
		
		if(Bank[Client] >= (-1000 + (ItemCost[NUM]*AMOUNT)))
		{
			Bank[Client] -= (ItemCost[NUM] * AMOUNT);
			Item[Client][NUM] += AMOUNT;
			CPrintToChat(Client, "{white}|RP| -{grey} |BULK| You purchase %d x %s for %d$", AMOUNT, ItemName[NUM],(ItemCost[NUM]*AMOUNT));
			Save(Client);
			VendorMenuNEW(Client, VEN);
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You cannot go below $-1000 with credit");
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(PaymentBulk);
	}
	return 0;
}


//Vendor Handle:
public HandleBuyAuct(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{
	
	//Select:
	if(HandleAction == MenuAction_Select)
	{
		
		//Declare:
		decl ItemId;
		
		//Initialize:
		ItemId = SelectedBuffer[Parameter - 1][Client];
		new ItemPrice = RoundToCeil(FloatMul(float(ItemCost[ItemId]),AuctItems[Parameter - 1]));
		
		//Enough Money:
		if(Money[Client] >= ItemPrice)
		{
			
			//Transact:
			Money[Client] -= ItemPrice;
			Item[Client][ItemId] += 1;
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You purchase 1 x %s for %d$", ItemName[ItemId],ItemPrice);
			Save(Client); 
			//Display:
			VendorMenu(Client, GlobalVendorId[Client],true,false);
		}
		else
		{
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You don't have enough money for this item");
		}
	}
}

public HandleSell(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{
	
	//Select:
	if(HandleAction == MenuAction_Select)
	{
		
		//Declare:
		decl ItemId;
		
		//Initialize:
		ItemId = SelectedBuffer[Parameter - 1][Client];
		
		new ItemPrice = ItemCost[ItemId]; 
		
		//Enough Items:
		if(Item[Client][ItemId] >= 1)
		{
			
			//Transact:
			Money[Client] += ItemPrice;
			Item[Client][ItemId] -= 1;
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You sold 1 x %s for %d", ItemName[ItemId],ItemPrice);
			Save(Client); 
			//Display:
			VendorMenu(Client, GlobalVendorId[Client],false,true);
		}
		else
		{
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You don't have this item");
		}
	}
}

public HandleSellAuct(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{
	
	//Select:
	if(HandleAction == MenuAction_Select)
	{
		
		//Declare:
		decl ItemId;
		
		//Initialize:
		ItemId = SelectedBuffer[Parameter - 1][Client];
		
		new ItemPrice = RoundToCeil(FloatMul(FloatMul(float(ItemCost[ItemId]),AuctItems[Parameter - 1]),AuctVendor)); 
		
		//Enough Items:
		if(Item[Client][ItemId] >= 1)
		{
			
			//Transact:
			Money[Client] += ItemPrice;
			Item[Client][ItemId] -= 1;
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You sold 1 x %s for %d", ItemName[ItemId],ItemPrice);
			Save(Client); 
			//Display:
			VendorMenu(Client, GlobalVendorId[Client],true,true);
		}
		else
		{
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You don't have this item");
		}
	}
}



//Job Menu Handle:
public JobMenuCreate(Handle:PickingJob, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[255];
		GetMenuItem(PickingJob, param2, info, sizeof(info));
		if(StrContains(Job[Client], "ASSHOLE", false) != -1)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You are not allowed to change your job");
		}
		else
		{
			//Declare:
			decl Handle:Vault;
			decl String:ReferenceString[255];
			
			//Initialize:
			Vault = CreateKeyValues("Vault");
			
			//Load:
			FileToKeyValues(Vault, JobPath);
			
			//Variables (String):
			LoadString(Vault, "0", info, DEFAULTJOB, ReferenceString);
			
			//Update:
			Job[Client] = ReferenceString;
			
			//Save Jobs:
			if(!IsCombine(Client) && Stealth[Client] == false && GetConVarInt(SaveClientJobs) > 0)
			{
				OrgJob[Client] = ReferenceString;
			}
			
			//Close:
			CloseHandle(Vault);
			
			CPrintToChat(Client, "{white}|RP| -{grey} Changing job to: %s (Type /job for information about your job)", ReferenceString);
			Override[Client] = 0;
			
			if(AnyGarbage != 1 && StrEqual(ReferenceString, "Sanitation", false))
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Server has not created a garbage zone. Pick another job.");
				Job[Client] = DEFAULTJOB;
			}
			
			decl Handle:Attributes;
			Attributes = CreateKeyValues("Vault");
			FileToKeyValues(Attributes, JobAttributesPath);
			if(Override[Client] != 1) LoadString2(Attributes, Job[Client], "model", "models/humans/Group03/Male_02.mdl", PlayerModel[Client]);
			CloseHandle(Attributes);
			
			//Delete tele if they switched jobs and had one on...
			DynamicJobsRefresh(Client);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(PickingJob);
	}
	return 0;
}

public Action:CommandJobInformation(Client,Args)
{
	//===============================================
	//EDIT THE JOBS_SETUP DATABASE AND DESCRIPTION --- EXCEPT FOR COPS/FIREFIGHTERS - Look Below
	//===============================================
	
	/*if(Client == 0) return Plugin_Handled;
	CPrintToChat(Client,"\x01\x04=====[%s]=====\x01", Job[Client]);
	
	decl Handle:Attributes, String:Description[1000];
	Attributes = CreateKeyValues("Vault");
	FileToKeyValues(Attributes, JobAttributesPath);
	LoadString3(Attributes, Job[Client], "description", "error", Description);
	CloseHandle(Attributes);
	
	if(!IsCombine(Client) && !IsFirefighter(Client))
	{
		if(!StrEqual(Description, "error", false))
		{
			decl String:Desclines[10][128];
			ExplodeString(Description, "^", Desclines, 10, 128);
			
			for(new l = 0; l < 10;l++)
			{
				if(strlen(Desclines[l]) > 0)
				{
					CPrintToChat(Client, "%s", Desclines[l]);
				}
			}
		}
		else
		{
			CPrintToChat(Client, "No description is found.");
		}
	}
	else
	{
		if(IsCombine(Client) && !IsFirefighter(Client))
		{
			CPrintToChat(Client, "1) As a cop, you are in charge of keeping the city safe!");
			CPrintToChat(Client, "2) People who have high crime should be arrested.");
			CPrintToChat(Client, "3) Remember that robbers can rob twice as fast than any other job.");
			CPrintToChat(Client, "4) Income: $1 per second a person is in jail. (Earned only if player is sent to jail for over 1 min)");
		}
		else if(IsFirefighter(Client))
		{
			CPrintToChat(Client, "1) As a firefighter, you are in charge of keeping the city safe!");
			CPrintToChat(Client, "2) Watch out for bombs as they can explode and cause fires.");
			CPrintToChat(Client, "3) Income: Ranges from $1000 to $3000 depending on event.");
			CPrintToChat(Client, "4) Commands For water gun: /on /off");
		}
		else
		{
			CPrintToChat(Client, "No job description is available");
		}
	}
	CPrintToChat(Client,"\x01\x04====================\x01", Job[Client]);
	return Plugin_Handled;*/
	
	
	
	if(Client == 0) return Plugin_Handled;
	PrintToChat(Client,"\x01\x04=====[%s]=====\x01", Job[Client]);
	if(StrEqual(Job[Client], "Robber", false))
	{
		PrintToChat(Client, "1) As a robber, you can rob twice as fast! (A cop must be online)");
		PrintToChat(Client, "2) You can rob twice as much money than any other job!");
		PrintToChat(Client, "3) If you get caught by the police, you will lose all your money plus $750 bank penalty.");
		PrintToChat(Client, "4)\x01\x04PickPocketing mod!\x01 Press \x04E\x01 on a player to rob them!\x01");
	}
	else if(StrEqual(Job[Client], "Medic", false))
	{
		PrintToChat(Client, "1) As a medic, you can heal any person whose under 100 health.");
		PrintToChat(Client, "2) You cannot heal cops.");
		PrintToChat(Client, "3) To heal, press e on a player and a menu item will show up called heal player.");
		PrintToChat(Client, "4) Income: $5 for every 1 health refill.");
	}
	else if(StrEqual(Job[Client], "RP Guide", false))
	{
		PrintToChat(Client, "1) As a guide, people can use you as a tour guide for help. (Locations in a map)");
		PrintToChat(Client, "2) You must stay within 15ft of the person you're guiding.");
		PrintToChat(Client, "3) To start a tour, press e on a player and click guide.  The player must then confirm.");
		PrintToChat(Client, "4) Income: $2 every second your guiding a person.");
	}
	else if(StrEqual(Job[Client], "Scientist", false))
	{
		PrintToChat(Client, "1) As a scientist, you can set up a teleporter for people to use.");
		PrintToChat(Client, "2) To make an entrance, type /telestart. To make an ending, type /teleend.");
		PrintToChat(Client, "3) You can adjust the tele start or end by retyping the same command.");
		PrintToChat(Client, "4) You can stop a teleport by typing /telekill.");
		PrintToChat(Client, "5) Income: $200 every teleport.");
	}
	else if(StrEqual(Job[Client], "Sanitation", false))
	{
		PrintToChat(Client, "1) As a garbage man, you can clean up trash in the city.");
		PrintToChat(Client, "2) When you find trash, bring it to the garbage zone and press e on it.");
		PrintToChat(Client, "3) Type /garbage to show you where is the garbage zone! (A beam will appear)");
		PrintToChat(Client, "4) Income: Ranges from $5 - $15 per item.");
	}
	else if(StrEqual(Job[Client], "Stripper", false))
	{
		PrintToChat(Client, "1) As a stripper, you can have people pay for love.");
		PrintToChat(Client, "2) Crime will be added everytime you make love.");
		PrintToChat(Client, "3) People have to press e on you and click make love.");
		PrintToChat(Client, "4) Income: Up to $750 per person.");
	}
	else if(StrEqual(Job[Client], "Drug Addict", false))
	{
		PrintToChat(Client, "1) As a drug addict, you can grow drugs by planting seeds by typing /plant!");
		PrintToChat(Client, "2) As you plant seeds, your crime will rise.  Watch out for cops!");
		PrintToChat(Client, "3) As time permits, plants will max out at 300 grams!");
		PrintToChat(Client, "4) Cops and other players can destroy/steal your plants.");
		PrintToChat(Client, "5) You can also lose drugs by going to jail or someone has killed you.");
		PrintToChat(Client, "6) Income: $5 per gram sold to a vendor.");
	}
	else if(StrEqual(Job[Client], "Donator - VIP", false))
	{
		PrintToChat(Client, "1) You're a donator! (You don't say).");
		PrintToChat(Client, "2) !gotoprinter (sm_gotoprinter) - Teleports you to your printer.");
		PrintToChat(Client, "3) !printerinfo (sm_printerinfo) - Get your printer stats anywhere!");
		PrintToChat(Client, "4) !chatmode (sm_chatmode) - Chat colors :D");
		PrintToChat(Client, "5) !model (sm_model) - Select any model you want from our database.");
		PrintToChat(Client, "6) Access to VIP places.");
		PrintToChat(Client, "7) NPCs at your house! Ask an admin, to get them.");
	}
	else if(IsCombine(Client) && !IsFirefighter(Client))
	{
		PrintToChat(Client, "1) As a cop, you are in charge of keeping the city safe!");
		PrintToChat(Client, "2) People who have high crime should be arrested.");
		PrintToChat(Client, "3) Remember that robbers can rob twice as fast than any other job.");
		PrintToChat(Client, "4) Income: $1 per second a person is in jail. (Earned only if player is sent to jail for over 1 min)");
	}
	else if(IsFirefighter(Client))
	{
		PrintToChat(Client, "1) As a firefighter, you are in charge of keeping the city safe!");
		PrintToChat(Client, "2) Watch out for bombs as they can explode and cause fires.");
		PrintToChat(Client, "3) Income: Ranges from $100 to $500 depending on event.");
	}
	else
	{
		PrintToChat(Client, "No job description is available");
	}
	PrintToChat(Client,"\x01\x04====================\x01", Job[Client]);
	return Plugin_Handled;
}

//BankMenu Handle:
public AtBank(Handle:BankMain, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info2[64];
		GetMenuItem(BankMain, param2, info2, sizeof(info2));
		
		//Withdrawl:
		if(StringToInt(info2) == 1)
		{
			Transfer1(Client);
		}
		//Deposit:
		if(StringToInt(info2) == 2)
		{
			Transfer2(Client);
		}
		if(StringToInt(info2) == 3)
		{
			ListChecks(Client);
		}
		if(StringToInt(info2) == 4)
		{
			if(Money[Client] >= 10)
			{
				NumChecks[Client] = NumChecks[Client] + 10;
				Money[Client] = Money[Client] - 10;
				CPrintToChat(Client, "{white}|RP| -{grey} Successfully bought a check book. You now have %d checks", NumChecks[Client]);
				Save(Client);
				if(Neg[Client] == 0)
				{
					BankMenu1(Client);
				}
				else
				{
					BankMenu2(Client);
				}
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You do not have $10");
			}
		}
		if(StringToInt(info2) == 5)
		{
			Bank[Client] = Bank[Client] + Money[Client];
			CPrintToChat(Client, "{white}|RP| -{grey} Deposited $%d into bank", Money[Client]);
			Money[Client] = 0;
			Save(Client);
			if(Neg[Client] == 0)
			{
				BankMenu1(Client);
			}
			else
			{
				BankMenu2(Client);
			}
		}
		if(StringToInt(info2) == 6)
		{
			if(NumChecks[Client] == 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You need to buy more checks.");
			}
			else
			{
				CheckMenu(Client, 1);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(BankMain);
	}
	return 0;
}

public Action:Transfer1(Client)
{
	decl String:AllIn[64], String:AllString[24], String:Dollar[24];
	decl String:Buffers[7][10] = {"69", "1", "5", "25", "100", "500", "1000"};
	new Handle:Withdraw = CreateMenu(WithdrawNow);
	SetMenuTitle(Withdraw, "Bank > Withdrawing\n=============\nCash: $%d\nBank: $%d", Money[Client], Bank[Client]);
	
	for(new X = 0; X < 7; X++)
	{
		if(StringToInt(Buffers[X]) == 69)
		{
			Format(AllIn, 64, "All ($%d)", Bank[Client]);
			IntToString(Bank[Client], AllString, 24);
			AddMenuItem(Withdraw, AllString, AllIn);
		}
		else
		{
			Format(Dollar, sizeof(Dollar), "$%s", Buffers[X]);
			AddMenuItem(Withdraw, Buffers[X], Dollar);
		}
	}
	AddMenuItem(Withdraw, "12312399", "-|Back to Bank Menu|-");
	SetMenuPagination(Withdraw, 7);
	DisplayMenu(Withdraw, Client, 30);
}

public Action:Transfer2(Client)
{
	decl String:AllIn[64], String:AllString[24], String:Dollar[24];
	decl String:Buffers[7][10] = {"69", "1", "5", "25", "100", "500", "1000"};
	new Handle:Deposit = CreateMenu(DepositNow);
	SetMenuTitle(Deposit, "Bank > Depositing\n=============\nCash: $%d\nBank: $%d", Money[Client], Bank[Client]);
	
	for(new X = 0; X < 7; X++)
	{
		if(StringToInt(Buffers[X]) == 69)
		{
			Format(AllIn, 64, "All ($%d)", Money[Client]);
			IntToString(Money[Client], AllString, 24);
			AddMenuItem(Deposit, AllString, AllIn);
		}
		else
		{
			Format(Dollar, sizeof(Dollar), "$%s", Buffers[X]);
			AddMenuItem(Deposit, Buffers[X], Dollar);
		}
	}
	AddMenuItem(Deposit, "12312399", "-|Back to Bank Menu|-");
	SetMenuPagination(Deposit, 7);
	DisplayMenu(Deposit, Client, 30);
}

public Action:CommandWithdraw(Client, Args)
{
	if(Args < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_withdraw <amount>");
		return Plugin_Handled;
	}
	decl AmountInt;
	decl String:Amount[32];
	
	GetCmdArg(1, Amount, sizeof(Amount));
	AmountInt = StringToInt(Amount);
	
	if(AmountInt <= 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_withdraw <amount>");
		return Plugin_Handled;
	}
	
	decl Handle:Vault;
	decl Float:Dist, Float:ClientOrigin[3], Float:Origin[3];
	decl String:NPCId[255], String:Props[255], String:Buffer[5][32];
	
	Vault = CreateKeyValues("Vault");
	
	FileToKeyValues(Vault, NPCPath);
	
	for(new X = 0; X < 100; X++)
	{
		IntToString(X, NPCId, 255);
		LoadString(Vault, "1", NPCId, "Null", Props);
		
		if(StrContains(Props, "Null", false) == -1)
		{
			ExplodeString(Props, " ", Buffer, 5, 32);
			
			GetClientAbsOrigin(Client, ClientOrigin);
			Origin[0] = StringToFloat(Buffer[1]);
			Origin[1] = StringToFloat(Buffer[2]);
			Origin[2] = StringToFloat(Buffer[3]);
			
			Dist = GetVectorDistance(ClientOrigin, Origin);
			
			if(Dist <= 150)
			{
				if(Neg[Client] > 0)
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You cannot withdraw if you have a negative bank balance!");
					return Plugin_Handled;
				}
				else if(AmountInt > Bank[Client])
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You cannot withdraw more then your bank!");
					return Plugin_Handled;
				}
				Money[Client] = Money[Client] + AmountInt;
				Bank[Client] = Bank[Client] - AmountInt;
				CPrintToChat(Client, "{white}|RP| -{grey} Transaction was successful");
				CloseHandle(Vault);
				Save(Client);
				return Plugin_Handled;
			}
		}
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You are not at a bank.");
	CloseHandle(Vault);
	return Plugin_Handled;
}

public Action:CommandDeposit(Client, Args)
{
	if(Args < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_deposit <amount>");
		return Plugin_Handled;
	}
	decl AmountInt;
	decl String:Amount[32];
	
	GetCmdArg(1, Amount, sizeof(Amount));
	AmountInt = StringToInt(Amount);
	
	if(AmountInt <= 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_deposit <amount>");
		return Plugin_Handled;
	}
	
	decl Handle:Vault;
	decl Float:Dist, Float:ClientOrigin[3], Float:Origin[3];
	decl String:NPCId[255], String:Props[255], String:Buffer[5][32];
	
	Vault = CreateKeyValues("Vault");
	
	FileToKeyValues(Vault, NPCPath);
	
	for(new X = 0; X < 100; X++)
	{
		IntToString(X, NPCId, 255);
		LoadString(Vault, "1", NPCId, "Null", Props);
		
		if(StrContains(Props, "Null", false) == -1)
		{
			ExplodeString(Props, " ", Buffer, 5, 32);
			
			GetClientAbsOrigin(Client, ClientOrigin);
			Origin[0] = StringToFloat(Buffer[1]);
			Origin[1] = StringToFloat(Buffer[2]);
			Origin[2] = StringToFloat(Buffer[3]);
			
			Dist = GetVectorDistance(ClientOrigin, Origin);
			
			if(Dist <= 150)
			{
				if(AmountInt > Money[Client])
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You cannot deposit more then your what you have.");
					return Plugin_Handled;
				}
				Money[Client] = Money[Client] - AmountInt;
				Bank[Client] = Bank[Client] + AmountInt;
				CPrintToChat(Client, "{white}|RP| -{grey} Transaction was successful");
				CloseHandle(Vault);
				Save(Client);
				return Plugin_Handled;
			}
		}
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You are not at a bank.");
	CloseHandle(Vault);
	return Plugin_Handled;
}

//PlayerMenu Handle:
public PlayerInformation(Handle:PlayerInfo, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info2[64];
		GetMenuItem(PlayerInfo, param2, info2, sizeof(info2));
		
		PickPocketItemSelected(info2, Client);
		
		//Give Money:
		if(StringToInt(info2) == 1)
		{
			new String:Buffers[7][64] = {"1", "5", "25", "100", "500", "1000", "All"};
			new Variables[7] = {1, 5, 25, 100, 500, 1000, 69};
			DrawMenu(Client, Buffers, HandleGiveMoney, Variables);
		}
		
		//Give Item:
		if(StringToInt(info2) == 2)
		{
			IsGiving[Client] = true;
			Inventory(Client);
		}
		
		//Jail:
		if(StringToInt(info2) == 3 && IsCombine(Client) && !IsCombine(MenuTarget[Client]))
		{
			Jail(MenuTarget[Client], Client);
		}
		
		//VIP Cell (10min):
		if(StringToInt(info2) == 4 && IsCombine(Client))
		{
			if(AnyVip == 1)
			{
				//autofree(MenuTarget[Client],600.0);
				//StartJail(MenuTarget[Client], 600);
				CPrintToChat(Client, "{white}|RP| -{grey} Your target will get free in 10 minutes"); 
				vipjail(MenuTarget[Client],Client);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Server has not created a vip jail cell");
			}
		}
		
		//AfkRoom:
		if(StringToInt(info2) == 5 && IsCombine(Client))
		{
			if(AnyAfk == 1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Your target has been sent to the afk room.");
				TeleportEntity(MenuTarget[Client], AFKOrigin, NULL_VECTOR, NULL_VECTOR);
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} Type /exitafk in chat to leave the afk room.");
				Uncuff(MenuTarget[Client]);
				AfkClient[MenuTarget[Client]] = 1;
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Server has not created an afk room");
			}
		}
		
		//Suicide 1:
		if(StringToInt(info2) == 6 && IsCombine(Client))
		{
			//Jail:
			if(AnySui1 == 1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Your target is sent to the suicide chamber");
				suicidechamber(MenuTarget[Client],Client,1);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Server has not created this suicide coordinate.");
			}
		}
		
		//Suicide 2
		if(StringToInt(info2) == 7 && IsCombine(Client))
		{
			//Jail:
			if(AnySui2 == 1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Your target is sent to the suicide chamber"); 
				suicidechamber(MenuTarget[Client],Client,2);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} Server has not created this suicide coordinate.");
			}
		}
		//Search Player
		if(StringToInt(info2) == 16 && IsCombine(Client))
		{	
			decl String:Combine[MAX_NAME_LENGTH];
			GetClientName(Client, Combine, sizeof(Combine));
			decl String:Arrested[MAX_NAME_LENGTH];
			GetClientName((MenuTarget[Client]), Arrested, sizeof(Arrested));
			if(Grams[MenuTarget[Client]] > 0)
			{
				Grams[MenuTarget[Client]] = 0;
				CPrintToChat((MenuTarget[Client]), "{white}|RP| -{grey} %s has found drugs on you in the search!", Combine);
				CPrintToChat(Client, "{white}|RP| -{grey} You have found drugs on %s. Rewarded $100!", Arrested);
			}
			if(Item[MenuTarget[Client]][5] > 0)
			{
				CPrintToChat((MenuTarget[Client]), "{white}|RP| -{grey} %s has found an Illegal Weapon: Grenades, on your person, fined $100.", Combine);
				Item[MenuTarget[Client]][5] = 0;
				CPrintToChat(Client, "{white}|RP| -{grey} Found Grenades on %s, you have been rewarded $55!", Arrested);
				Money[Client] += 50;
			}
			if(Item[MenuTarget[Client]][7] > 0)
			{
				CPrintToChat((MenuTarget[Client]), "{white}|RP| -{grey} %s has found an Illegal Weapon: RPG, on your person, fined $100.", Combine);
				Item[MenuTarget[Client]][7] = 0;
				CPrintToChat(Client, "{white}|RP| -{grey} Found an RPG on %s, you have been rewarded $150!", Arrested);
				Money[Client] += 150;
			}
			Save(MenuTarget[Client]);
			Save(Client);
		}
		if(StringToInt(info2) == 17 && IsCombine(Client))
		{	
			decl String:Player[MAX_NAME_LENGTH];
			GetClientName(Client, Player, sizeof(Player));
			if(IsCuffed[Client])
			{					
				if(AnyExit == 1)
				{
					TeleportEntity(Client, ExitOrigin, NULL_VECTOR, NULL_VECTOR);  
				}
				Uncuff(Client);
				CPrintToChat(Client, "{white}|RP|{grey} - You have released {green}%s{grey}.", Player);
			}
			Save(Client);
		}
		//Police Medic Heal Function
		if(StringToInt(info2) == 8 && IsCombine(Client) && StrEqual(Job[Client], "Police Medic", false) && IsCombine(MenuTarget[Client]))
		{	
			if(PoliceMedHeal[Client] == 1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You can only heal once every 30 seconds");
			}
			else
			{
				decl Total;
				Total = GetClientHealth(MenuTarget[Client]) + 50;
				if(Total > 100)
				{
					SetEntityHealth(MenuTarget[Client], 100);
					CPrintToChat(Client, "{white}|RP| -{grey} Received $50 for healing a cop.");
					Money[Client] += 50;
				}
				else
				{
					SetEntityHealth(MenuTarget[Client], Total);
					CPrintToChat(Client, "{white}|RP| -{grey} Received $100 for healing a cop.");
					Money[Client] += 100;
				}
				PoliceMedHeal[Client] = 1;
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} A police medic has healed you.");
				CreateTimer(30.0, RestoreHeal, Client);
			}
		}
		
		//Promote and Demote Gang Members
		if(StringToInt(info2) == 9 && StrEqual(Job[Client], DEFAULTGANGLEADER, false))
		{
			if(!StrEqual(Job[MenuTarget[Client]], DEFAULTGANG, false))
				Job[MenuTarget[Client]] = DEFAULTGANG;
			else
			Job[MenuTarget[Client]] = DEFAULTJOB;
		}
		if(StringToInt(info2) == 10 && StrEqual(Job[Client], "Medic", false))
		{
			decl HealthNeeded, Charge;
			HealthNeeded = 100 - GetClientHealth(MenuTarget[Client]);
			Charge = HealthNeeded*5;
			decl String:Healer[255], String:Hurt[255];
			GetClientName(Client, Healer, sizeof(Healer));
			GetClientName(MenuTarget[Client], Hurt, sizeof(Hurt));
			if(Money[MenuTarget[Client]] > Charge)
			{			
				Money[MenuTarget[Client]] = Money[MenuTarget[Client]] - Charge;
				Money[Client] = Money[Client] + Charge;
				SetEntityHealth(MenuTarget[Client], 100);
				CPrintToChat(Client, "{white}|RP-Medic| -{grey}  You've earned $%d for healing %s", Charge, Hurt);
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} You've been charged $%d for a refill of health.", Charge);
				Save(Client);
				Save(MenuTarget[Client]);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP-Medic| -{grey}  %s does not have enough money to pay for a refill of health", Hurt);
			}
		}
		if(StringToInt(info2) == 11 && StrEqual(Job[Client], "RP Guide", false))
		{
			if(TourGuide[MenuTarget[Client]] != 99)
			{
				CPrintToChat(Client, "{white}|RP-Guide| -{grey}  This player is getting a tour by someone else right now");
			}
			else if(StrEqual(Job[MenuTarget[Client]], "RP Guide", false))
			{
				CPrintToChat(Client, "{white}|RP-Guide| -{grey}  This player is already a tour guide!");
			}
			else
			{
				CPrintToChat(Client, "{white}|RP-Guide| -{grey}  Waiting for player to respond...");
				decl String:TourGuy[255];
				GetClientName(Client, TourGuy, sizeof(TourGuy));
				
				//Confirm:
				new Handle:Guide = CreateMenu(GuideConfirm);
				SetMenuTitle(Guide, "Guided Tour\n=============\nWould you like \n%s\n to give you a tour?\nCost: $2 per second", TourGuy);
				decl String:Accept[64], String:Decline[64];
				Format(Accept, 64, "1-%d", Client);
				Format(Decline, 64, "2-%d", Client);
				AddMenuItem(Guide, Accept, "-|Yes|-");
				AddMenuItem(Guide, Decline, "-|No|-");
				SetMenuPagination(Guide, 7);
				DisplayMenu(Guide, MenuTarget[Client], 30);
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} Press <Escape> to accept or decline a guided tour.");
			}
		}
		if(StringToInt(info2) == 12 && StrEqual(Job[MenuTarget[Client]], "Stripper", false))
		{
			if(EquipSpam[Client] > 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You are too tired.  Try again later.");
			}
			else
			{
				new Handle:Love = CreateMenu(LoveConfirm);
				SetMenuTitle(Love, "Make Love\n=============\nLevel of Satisfaction:\nPrices:\nLittle: $250\nModerate: $500\nAll the way: $750");
				AddMenuItem(Love, "1", "-|Little|-");
				AddMenuItem(Love, "2", "-|Moderate|-");
				AddMenuItem(Love, "3", "-|All the way|-");
				SetMenuPagination(Love, 7);
				DisplayMenu(Love, Client, 30);
			}
		}
		if(StringToInt(info2) == 13 && StrEqual(Job[MenuTarget[Client]], "Hitman", false))
		{
			if(Hitman[MenuTarget[Client]] > 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} This hitman is already after someone else.  Try again later.");
			}
			else
			{
				new Handle:Die = CreateMenu(HitConfirm);
				SetMenuTitle(Die, "Place a hit\n=============\nPrice $750");
				
				decl MaxPlayers;
				MaxPlayers = GetMaxClients();
				
				decl String:Name[50], String:hitids[25];
				for(new Target = 1; Target <= MaxPlayers; Target++)
				{
					if(IsClientConnected(Target) && IsClientInGame(Target))
					{
						if(Client != Target && Target != MenuTarget[Client])
						{
							GetClientName(Target, Name, sizeof(Name));
							Format(hitids, 25, "%d-%d", Target, MenuTarget[Client]);
							AddMenuItem(Die, hitids, Name);
						}
					}
				}
				SetMenuPagination(Die, 7);
				DisplayMenu(Die, Client, 30);
			}
		}
		if(StringToInt(info2) == 15 && StrEqual(Job[MenuTarget[Client]], "Lawyer", false))
		{
			decl String:Lawyer[MAX_NAME_LENGTH];
			decl String:Buyer[MAX_NAME_LENGTH];
			
			GetClientName(Client, Buyer, sizeof(Buyer));
			GetClientName(MenuTarget[Client], Lawyer, sizeof(Lawyer));
			
			if(Crime[Client] > 499)
			{
				if(Bank[Client] > 199)
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You have payed %s $200 to remove some bad reputation the law has on you.", Lawyer);
					CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} %s has payed you to remove some bad dirt off him.", Buyer);
					Crime[Client] -= 500;
					Bank[Client] -= 200;
					Bank[MenuTarget[Client]] += 200;
				}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You do not have $200 in your bank.");
				}
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You need atleast 500 crime to talk to a lawyer.");
			}
		}
		if(StringToInt(info2) == 14 && StrEqual(Job[MenuTarget[Client]], "Salesman", false))
		{
			if(SalesMan[MenuTarget[Client]] == 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} This salesman is not selling any items");
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} Someone is trying to buy items but you haven't selected a type of salesman.  Please type /type in chat.");
			}
			else
			{
				decl String:StoreName[64];
				GetClientName(MenuTarget[Client], StoreName, sizeof(StoreName));
				
				new Handle:TypeP = CreateMenu(SalesTypesP);
				SetMenuTitle(TypeP, "%s's Store:\n=============\n", StoreName);
				
				if(SalesMan[MenuTarget[Client]] == 1)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 1)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				else if(SalesMan[MenuTarget[Client]] == 2)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 2 || ItemAction[X] == 3)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				else if(SalesMan[MenuTarget[Client]] == 3)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 4)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				else if(SalesMan[MenuTarget[Client]] == 4)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 5 || ItemAction[X] == 9 || ItemAction[X] == 13 || ItemAction[X] == 14)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				else if(SalesMan[MenuTarget[Client]] == 5)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 7)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				else if(SalesMan[MenuTarget[Client]] == 6)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 8)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				else if(SalesMan[MenuTarget[Client]] == 7)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 20 || ItemAction[X] == 21)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				else if(SalesMan[MenuTarget[Client]] == 8)
				{
					for(new X = 0; X < MAXITEMS; X++)
					{
						if(ItemAction[X] == 22 || ItemAction[X] == 23)
						{
							decl String:MenuLine[64], String:PassItem[10];
							Format(MenuLine, sizeof(MenuLine), "%s - $%d", ItemName[X], ItemCost[X]);
							Format(PassItem, sizeof(PassItem), "%d", X);
							AddMenuItem(TypeP, PassItem, MenuLine);
						}
					}
				}
				SetMenuPagination(TypeP, 7);
				DisplayMenu(TypeP, Client, 30);
				CPrintToChat(Client, "{white}|RP| -{grey} Press <Escape> to access the menu.");
			}
		}
		/*if(StringToInt(info2) == 15 && StrEqual(Job[Client], "Kidnapper", false))
		{
			decl Float:ClientOrigin[3], Float:EntOrigin[3];
			
			//Initialize
			GetClientAbsOrigin(Client, ClientOrigin);
			GetClientAbsOrigin(Ent, EntOrigin);
			
			new Float:Distz = GetVectorDistance(ClientOrigin, EntOrigin);
			
			//Distance:
			if(Distz <= 75)
			{
			}
		}
		*/
		if(StringToInt(info2) == -1)
		{
			BribeFunc(Client);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(PlayerInfo);
	}
	return 0;
}

public SalesTypesP(Handle:TypeP, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:itemid[64];
		GetMenuItem(TypeP, param2, itemid, sizeof(itemid));
		
		if(StrEqual(Job[MenuTarget[Client]], "Salesman", false))
		{
			if(Bank[Client] >= ItemCost[StringToInt(itemid)])
			{
				Bank[Client] -= ItemCost[StringToInt(itemid)];
				Item[Client][StringToInt(itemid)] += 1;
				
				if(ItemCost[StringToInt(itemid)] >= 5)
				{
					decl Float:sales, final;
					sales = FloatMul(float(ItemCost[StringToInt(itemid)]), 0.65);
					final = RoundToCeil(sales);
					Money[MenuTarget[Client]] += final;
					CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} A customer has bought 1x of %s.  Received a bonus of $%d", ItemName[StringToInt(itemid)], final);
				}
				else
				{
					CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} A customer has bought 1x of %s", ItemName[StringToInt(itemid)]);
					
				}
				CPrintToChat(Client, "{white}|RP| -{grey} You have purchased 1x of %s", ItemName[StringToInt(itemid)]);
				DisplayMenu(TypeP, Client, 30);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You do not have $%d", ItemCost[StringToInt(itemid)]);
				DisplayMenu(TypeP, Client, 30);
			}
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Cannot locate the Salesman.");	
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(TypeP);
	}
	return 0;
}

public GuideConfirm(Handle:Guide, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:choice[64];
		GetMenuItem(Guide, param2, choice, sizeof(choice));
		
		decl String:Choice_Buffers[3][32];
		ExplodeString(choice, "-", Choice_Buffers, 2, 32);
		
		if(StrEqual(Job[StringToInt(Choice_Buffers[1])], "RP Guide", false))
		{
			decl String:Leader[255], String:Follow[255];
			GetClientName(StringToInt(Choice_Buffers[1]), Leader, sizeof(Leader));
			GetClientName(Client, Follow, sizeof(Follow));
			if(StringToInt(Choice_Buffers[0]) == 1)
			{
				CPrintToChat(StringToInt(Choice_Buffers[1]), "{white}|RP-Guide| -{grey}  %s has accepted your tour. The tour has started!", Follow);
				CPrintToChat(Client, "{white}|RP| -{grey} Starting tour. Follow %s to show you around.  To stop the tour, walk away from him.", Leader);
				TourFunction(Client, StringToInt(Choice_Buffers[1]));
			}
			else
			{
				CPrintToChat(StringToInt(Choice_Buffers[1]), "{white}|RP-Guide| -{grey}  %s has turned down your tour.", Follow);
				CPrintToChat(Client, "{white}|RP| -{grey} You have turned down the tour.");
			}
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Cannot locate the tour guide");
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Guide);
	}
	return 0;
}

public Action:TourFunction(Client, Leader)
{
	if(!IsClientConnected(Leader) || !IsClientInGame(Leader))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Your tour guide has left the game. Tour has ended.");
		TourGuide[Client] = 99;
		return Plugin_Handled;
	}
	if(!IsClientConnected(Client) || !IsClientInGame(Client))
	{
		CPrintToChat(Leader, "{white}|RP-Guide| -{grey}  Tour has ended due to player leaving.");
		return Plugin_Handled;
	}
	if(!StrEqual(Job[Leader], "RP Guide", false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Your tour guide has changed jobs. Tour has ended.");
		TourGuide[Client] = 99;
		return Plugin_Handled;
	}
	decl Float:ClientOrigin[3], Float:LeaderOrigin[3], Float:Dist;
	GetClientAbsOrigin(Client, ClientOrigin);
	GetClientAbsOrigin(Leader, LeaderOrigin);
	ClientOrigin[2] += 30;
	LeaderOrigin[2] += 30;
	Dist = GetVectorDistance(ClientOrigin, LeaderOrigin);
	if(Dist > 500 && Dist < 800)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Get closer to the tour guide to continue tour.");
		CPrintToChat(Leader, "{white}|RP-Guide| -{grey}  Get closer to the player to continue tour.");
	}
	if(Dist >= 800)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Ended tour.");
		CPrintToChat(Leader, "{white}|RP-Guide| -{grey}  Player is to far away. Tour has ended.");
		TourGuide[Client] = 99;
		return Plugin_Handled;
	}
	
	if(Money[Client] >= 2)
	{
		Money[Client] = Money[Client] - 2;
		Money[Leader] = Money[Leader] + 2;
		TE_SetupBeamPoints(ClientOrigin, LeaderOrigin, LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, TourColor, 0);
		TE_SendToClient(Client);
		TE_SetupBeamPoints(ClientOrigin, LeaderOrigin, LaserCache, 0, 0, 66, 0.5, 3.0, 3.0, 0, 0.0, TourColor, 0);
		TE_SendToClient(Leader);
	}
	if(Money[Client] < 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You've ran out of money.  Tour has ended");
		CPrintToChat(Leader, "{white}|RP-Guide| -{grey}  Player is out of money. Tour has ended.");
		return Plugin_Handled;
	}
	TourGuide[Client] = Leader;
	CreateTimer(1.0, PayTourGuide, Client);
	return Plugin_Handled;
}

public Action:PayTourGuide(Handle:Timer, any:Client)
{
	TourFunction(Client, TourGuide[Client]);
}

public LoveConfirm(Handle:Love, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info2[64];
		GetMenuItem(Love, param2, info2, sizeof(info2));
		
		decl Float:ClientOrigin[3], Float:StripperOrigin[3], Float:Dist;
		GetClientAbsOrigin(Client, ClientOrigin);
		GetClientAbsOrigin(MenuTarget[Client], StripperOrigin);
		ClientOrigin[2] += 30;
		StripperOrigin[2] += 30;
		Dist = GetVectorDistance(ClientOrigin, StripperOrigin);
		if(Dist > 100)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You have to be close to your stripper.");
			CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} A player is trying to make love with you.  Move closer to the player.");
		}
		else if(StringToInt(info2) == 1 && StrEqual(Job[MenuTarget[Client]], "Stripper", false))
		{
			if(Money[Client] > 249)
			{
				decl String:StripperName[64], String:ClientName[64];
				GetClientName(Client, ClientName, sizeof(ClientName));
				GetClientName(MenuTarget[Client], StripperName, sizeof(StripperName));
				CPrintToChat(Client, "{white}|RP| -{grey} Paid $250 to %s.", StripperName);
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} Received $250 from %s.", ClientName);
				EquipSpam[Client] = 2;
				Money[Client] -= 250;
				Money[MenuTarget[Client]] += 250;
				AddCrime(Client,250);
				AddCrime(MenuTarget[Client],250);
				CurrentNum[Client] = 1;
				CurrentNum[MenuTarget[Client]] = 1;
				SetEntityMoveType(Client, MOVETYPE_NONE);
				SetEntityMoveType(MenuTarget[Client], MOVETYPE_NONE);
				CreateTimer(16.0, UnfreezeXx, Client);
				CreateTimer(16.0, UnfreezeXx, MenuTarget[Client]);
				LoveX(Client, MenuTarget[Client], 0.1, "vo/k_lab/al_letsdoit.wav", 1);
				LoveX(Client, MenuTarget[Client], 2.0, "vo/npc/Alyx/hurt04.wav", 2);
				LoveX(Client, MenuTarget[Client], 3.0, "vo/npc/Alyx/hurt04.wav", 3);
				LoveX(Client, MenuTarget[Client], 4.0, "vo/npc/Alyx/hurt05.wav", 4);
				LoveX(Client, MenuTarget[Client], 5.0, "vo/npc/Alyx/uggh02.wav", 5);
				LoveX(Client, MenuTarget[Client], 6.0, "vo/npc/Alyx/hurt05.wav", 6);
				LoveX(Client, MenuTarget[Client], 7.0, "vo/npc/Alyx/uggh02.wav", 7);
				LoveX(Client, MenuTarget[Client], 8.0, "vo/npc/Alyx/uggh02.wav", 8);
				LoveX(Client, MenuTarget[Client], 9.0, "vo/npc/female01/pain06.wav", 9);
				LoveX(Client, MenuTarget[Client], 10.0, "vo/npc/female01/pain06.wav", 10);
				LoveX(Client, MenuTarget[Client], 10.5, "vo/npc/female01/pain06.wav", 11);
				LoveX(Client, MenuTarget[Client], 11.0, "vo/npc/female01/pain06.wav", 12);
				LoveX(Client, MenuTarget[Client], 11.5, "vo/npc/female01/pain04.wav", 13);
				LoveX(Client, MenuTarget[Client], 12.0, "vo/npc/female01/pain04.wav", 14);
				LoveX(Client, MenuTarget[Client], 12.5, "vo/npc/female01/pain03.wav", 15);
				LoveX(Client, MenuTarget[Client], 13.0, "vo/npc/female01/ow02.wav", 16);
				LoveX(Client, MenuTarget[Client], 14.0, "vo/npc/female01/ow01.wav", 17);
				LoveX(Client, MenuTarget[Client], 15.0, "vo/npc/female01/ow02.wav", 18);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You do not have $250.");
			}
		}
		else if(StringToInt(info2) == 2 && StrEqual(Job[MenuTarget[Client]], "Stripper", false))
		{
			if(Money[Client] > 499)
			{
				decl String:StripperName[64], String:ClientName[64];
				GetClientName(Client, ClientName, sizeof(ClientName));
				GetClientName(MenuTarget[Client], StripperName, sizeof(StripperName));
				EquipSpam[Client] = 2;
				CPrintToChat(Client, "{white}|RP| -{grey} Paid $500 to %s.", StripperName);
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} Received $500 from %s.", ClientName);
				Money[Client] -= 500;
				Money[MenuTarget[Client]] += 500;
				AddCrime(Client,500);
				AddCrime(MenuTarget[Client],500);
				CurrentNum[Client] = 0;
				CurrentNum[MenuTarget[Client]] = 0;
				SetEntityMoveType(Client, MOVETYPE_NONE);
				SetEntityMoveType(MenuTarget[Client], MOVETYPE_NONE);
				CreateTimer(20.0, UnfreezeXx, Client);
				CreateTimer(20.0, UnfreezeXx, MenuTarget[Client]);
				LoveX(Client, MenuTarget[Client], 0.1, "vo/k_lab/al_letsdoit.wav", 1);
				LoveX(Client, MenuTarget[Client], 2.0, "vo/npc/female01/startle02.wav", 2);
				LoveX(Client, MenuTarget[Client], 3.0, "vo/npc/female01/startle02.wav", 3);
				LoveX(Client, MenuTarget[Client], 4.0, "vo/npc/female01/startle02.wav", 4);
				LoveX(Client, MenuTarget[Client], 5.0, "vo/npc/female01/startle02.wav", 5);				
				LoveX(Client, MenuTarget[Client], 6.0, "vo/npc/female01/ow01.wav", 6);
				LoveX(Client, MenuTarget[Client], 6.5, "vo/npc/female01/startle02.wav", 7);
				LoveX(Client, MenuTarget[Client], 7.0, "vo/npc/female01/ow01.wav", 8);
				LoveX(Client, MenuTarget[Client], 7.5, "vo/npc/female01/startle02.wav", 9);
				LoveX(Client, MenuTarget[Client], 8.0, "vo/npc/female01/ow01.wav", 10);
				LoveX(Client, MenuTarget[Client], 8.5, "vo/npc/female01/startle02.wav", 11);
				LoveX(Client, MenuTarget[Client], 9.0, "vo/npc/female01/pain03.wav", 12);
				LoveX(Client, MenuTarget[Client], 9.5, "vo/npc/female01/pain03.wav", 13);
				LoveX(Client, MenuTarget[Client], 10.0, "vo/npc/female01/pain03.wav", 14);
				LoveX(Client, MenuTarget[Client], 10.5, "vo/npc/female01/pain03.wav", 15);
				LoveX(Client, MenuTarget[Client], 11.0, "vo/npc/female01/pain03.wav", 16);
				LoveX(Client, MenuTarget[Client], 11.5, "vo/npc/female01/pain03.wav", 17);
				LoveX(Client, MenuTarget[Client], 12.0, "vo/npc/female01/pain04.wav", 18);
				LoveX(Client, MenuTarget[Client], 12.5, "vo/npc/female01/pain04.wav", 19);
				LoveX(Client, MenuTarget[Client], 13.0, "vo/npc/female01/pain04.wav", 20);
				LoveX(Client, MenuTarget[Client], 13.5, "vo/npc/female01/pain08.wav", 21);
				LoveX(Client, MenuTarget[Client], 14.0, "vo/npc/female01/pain09.wav", 22);
				LoveX(Client, MenuTarget[Client], 15.0, "vo/npc/female01/pain08.wav", 23);
				LoveX(Client, MenuTarget[Client], 16.0, "vo/npc/female01/pain09.wav", 24);
				LoveX(Client, MenuTarget[Client], 17.0, "vo/npc/female01/pain08.wav", 25);
				LoveX(Client, MenuTarget[Client], 18.0, "vo/npc/female01/pain09.wav", 26);
				LoveX(Client, MenuTarget[Client], 19.0, "vo/npc/Alyx/hurt05.wav", 27);
				LoveX(Client, MenuTarget[Client], 20.0, "vo/npc/Alyx/gasp02.wav", 28);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You do not have $500.");
			}
		}
		else if(StringToInt(info2) == 3 && StrEqual(Job[MenuTarget[Client]], "Stripper", false))
		{
			if(Money[Client] > 749)
			{
				decl String:StripperName[64], String:ClientName[64];
				GetClientName(Client, ClientName, sizeof(ClientName));
				GetClientName(MenuTarget[Client], StripperName, sizeof(StripperName));
				CPrintToChat(Client, "{white}|RP| -{grey} Paid $750 to %s.", StripperName);
				CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} Received $750 from %s.", ClientName);
				EquipSpam[Client] = 2;
				Money[Client] -= 750;
				Money[MenuTarget[Client]] += 750;
				AddCrime(Client,750);
				AddCrime(MenuTarget[Client],750);
				CurrentNum[Client] = 0;
				CurrentNum[MenuTarget[Client]] = 0;
				SetEntityMoveType(Client, MOVETYPE_NONE);
				SetEntityMoveType(MenuTarget[Client], MOVETYPE_NONE);
				CreateTimer(40.0, UnfreezeXx, Client);
				CreateTimer(40.0, UnfreezeXx, MenuTarget[Client]);
				LoveX(Client, MenuTarget[Client], 0.1, "vo/k_lab/al_letsdoit.wav", 1);
				LoveX(Client, MenuTarget[Client], 2.0, "vo/npc/Alyx/gasp02.wav", 2);
				LoveX(Client, MenuTarget[Client], 3.0, "vo/npc/Alyx/gasp02.wav", 3);
				LoveX(Client, MenuTarget[Client], 4.0, "vo/npc/Alyx/gasp02.wav", 4);
				LoveX(Client, MenuTarget[Client], 5.0, "vo/npc/Alyx/gasp02.wav", 5);
				LoveX(Client, MenuTarget[Client], 6.0, "vo/npc/Alyx/gasp02.wav", 6);
				LoveX(Client, MenuTarget[Client], 6.5, "vo/npc/Alyx/uggh02.wav", 7);
				LoveX(Client, MenuTarget[Client], 7.5, "vo/npc/Alyx/gasp02.wav", 8);
				LoveX(Client, MenuTarget[Client], 8.0, "vo/npc/Alyx/uggh02.wav", 9);
				LoveX(Client, MenuTarget[Client], 9.0, "vo/npc/Alyx/gasp02.wav", 10);
				LoveX(Client, MenuTarget[Client], 9.5, "vo/npc/Alyx/uggh02.wav", 11);
				LoveX(Client, MenuTarget[Client], 10.5, "vo/npc/Alyx/gasp02.wav", 12);
				LoveX(Client, MenuTarget[Client], 11.0, "vo/npc/Alyx/uggh02.wav", 13);
				LoveX(Client, MenuTarget[Client], 12.0, "vo/npc/Alyx/hurt05.wav", 14);
				LoveX(Client, MenuTarget[Client], 13.0, "vo/npc/Alyx/hurt04.wav", 15);
				LoveX(Client, MenuTarget[Client], 14.0, "vo/npc/Alyx/hurt05.wav", 16);
				LoveX(Client, MenuTarget[Client], 15.0, "vo/npc/Alyx/hurt04.wav", 17);
				LoveX(Client, MenuTarget[Client], 16.0, "vo/npc/Alyx/hurt05.wav", 18);
				LoveX(Client, MenuTarget[Client], 17.0, "vo/npc/Alyx/hurt04.wav", 19);
				LoveX(Client, MenuTarget[Client], 18.0, "vo/npc/Alyx/hurt05.wav", 20);
				LoveX(Client, MenuTarget[Client], 19.0, "vo/npc/Alyx/hurt04.wav", 21);
				LoveX(Client, MenuTarget[Client], 20.0, "vo/npc/Alyx/hurt06.wav", 22);
				LoveX(Client, MenuTarget[Client], 21.0, "vo/npc/Alyx/hurt08.wav", 23);
				LoveX(Client, MenuTarget[Client], 22.0, "vo/npc/Alyx/hurt06.wav", 24);
				LoveX(Client, MenuTarget[Client], 23.0, "vo/npc/Alyx/hurt08.wav", 25);
				LoveX(Client, MenuTarget[Client], 24.0, "vo/npc/Alyx/hurt06.wav", 26);
				LoveX(Client, MenuTarget[Client], 25.0, "vo/npc/Alyx/hurt08.wav", 27);
				LoveX(Client, MenuTarget[Client], 26.0, "vo/npc/Alyx/hurt06.wav", 28);
				LoveX(Client, MenuTarget[Client], 27.0, "vo/npc/Alyx/hurt08.wav", 29);
				LoveX(Client, MenuTarget[Client], 28.0, "vo/npc/female01/pain06.wav", 30);
				LoveX(Client, MenuTarget[Client], 29.0, "vo/npc/female01/pain06.wav", 31);
				LoveX(Client, MenuTarget[Client], 30.5, "vo/npc/female01/pain06.wav", 32);
				LoveX(Client, MenuTarget[Client], 31.0, "vo/npc/female01/pain06.wav", 33);
				LoveX(Client, MenuTarget[Client], 31.5, "vo/npc/female01/pain06.wav", 34);
				LoveX(Client, MenuTarget[Client], 32.0, "vo/npc/female01/pain06.wav", 35);
				LoveX(Client, MenuTarget[Client], 32.5, "vo/npc/female01/pain06.wav", 36);
				LoveX(Client, MenuTarget[Client], 33.0, "vo/npc/female01/pain06.wav", 37);
				LoveX(Client, MenuTarget[Client], 33.5, "vo/npc/female01/pain06.wav", 38);
				LoveX(Client, MenuTarget[Client], 34.0, "vo/npc/female01/pain06.wav", 39);
				LoveX(Client, MenuTarget[Client], 34.5, "vo/npc/female01/pain06.wav", 40);
				LoveX(Client, MenuTarget[Client], 35.0, "vo/npc/female01/pain06.wav", 41);
				LoveX(Client, MenuTarget[Client], 35.5, "vo/npc/female01/pain06.wav", 42);
				LoveX(Client, MenuTarget[Client], 36.0, "vo/Citadel/al_success_yes_nr.wav", 43);
				LoveX(Client, MenuTarget[Client], 39.0, "vo/Citadel/al_success_yes02_nr.wav", 44);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You do not have $750.");
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Love);
	}
	return 0;
}

public Action:LoveX(Client, Stripper, Float:Time, const String:Sound[64], number)
{
	CurrentSound[Client][number] = Sound;
	CurrentSound[Stripper][number] = Sound;
	CreateTimer(Time, RunSound, Client);
	CreateTimer(Time, RunSound2, Stripper);
}

public Action:RunSound(Handle:Timer, any:Client)
{
	if(IsClientInGame(Client) && IsClientConnected(Client) && !IsCuffed[Client] && IsPlayerAlive(Client))
	{
		decl Float:ClientOrigin[3];
		GetClientAbsOrigin(Client, ClientOrigin);
		ClientOrigin[2] += GetRandomFloat(10.0, 75.0);
		TE_SetupBeamRingPoint(ClientOrigin, 1.0, GetRandomFloat(100.0, 250.0), g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, PinkColor, 10, 0);
		TE_SendToAll();
		ClientCommand(Client, "play %s", CurrentSound[Client][CurrentNum[Client]]);
		CurrentNum[Client] += 1;
	}
	return Plugin_Handled;
}

public Action:RunSound2(Handle:Timer, any:Stripper)
{
	if(IsClientInGame(Stripper) && IsClientConnected(Stripper) && !IsCuffed[Stripper] && IsPlayerAlive(Stripper))
	{
		decl Float:StripperOrigin[3];
		GetClientAbsOrigin(Stripper, StripperOrigin);
		StripperOrigin[2] += GetRandomFloat(10.0, 75.0);
		TE_SetupBeamRingPoint(StripperOrigin, 1.0, GetRandomFloat(100.0, 250.0), g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, PinkColor, 10, 0);
		TE_SendToAll();
		ClientCommand(Stripper, "play %s", CurrentSound[Stripper][CurrentNum[Stripper]]);
		CurrentNum[Stripper] += 1;
	}
	return Plugin_Handled;
}

public HitConfirm(Handle:Die, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info2[64];
		GetMenuItem(Die, param2, info2, sizeof(info2));
		decl String:Spliter[2][32];
		ExplodeString(info2, "-", Spliter, 2, 32);
		
		if(IsClientInGame(StringToInt(Spliter[0])) && IsClientConnected(StringToInt(Spliter[0])))
		{
			if(IsClientInGame(StringToInt(Spliter[1])) && IsClientConnected(StringToInt(Spliter[1])))
			{
				if(StrEqual(Job[StringToInt(Spliter[1])], "Hitman", false))
				{
					if(Money[Client] < 750)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You do not have enough money.");
					}
					else
					{
						decl String:Targetname[64];
						GetClientName(StringToInt(Spliter[0]), Targetname, sizeof(Targetname));
						CPrintToChat(StringToInt(Spliter[1]), "{white}|RP| -{grey} A hit has been placed on %s for 5 minutes.", Targetname);
						CPrintToChat(StringToInt(Spliter[0]), "{white}|RP| -{grey} Someone has placed a hit on you");
						CPrintToChat(Client, "{white}|RP| -{grey} You have placed a hit on %s for 5 minutes.  If you disconnect early, you will not be refunded.", Targetname);
						Money[Client] -= 750;
						Hitman[StringToInt(Spliter[1])] = StringToInt(Spliter[0]);
						HitmanBuyer[StringToInt(Spliter[1])] = Client;
						HitmanTimer[StringToInt(Spliter[1])] = 300;
					}
				}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey} The hitman has changed his job.");
				}
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} The hitman has left the game");
			}
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} The player you selected has left the game");
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Die);
	}
	return 0;
}

public Action:SpawnGarbage(Client, Type)
{
	decl Float:EyeAngles[3];
	decl Float:ClientOrigin[3], Float:TrashOrigin[3];
	
	GetClientAbsOrigin(Client, ClientOrigin);
	GetClientEyeAngles(Client, EyeAngles);
	
	TrashOrigin[0] = (ClientOrigin[0] + (50 * Cosine(DegToRad(EyeAngles[1]))));
	TrashOrigin[1] = (ClientOrigin[1] + (50 * Sine(DegToRad(EyeAngles[1]))));
	TrashOrigin[2] = (ClientOrigin[2] + 100);
	
	if(GarbageAmount < 10)
	{
		decl Ent;
		Ent = CreateEntityByName("prop_physics_override");
		DispatchKeyValue(Ent, "physdamagescale", "0.0");
		decl Rand;
		Rand = GetRandomInt(1, 100);
		if(Type == 1)
		{
			if(Rand < 25) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_glassbottle001a.mdl");
			else if(Rand >= 25 && Rand < 50) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_metalcan001a.mdl");
			else if(Rand >= 50 && Rand < 75) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_plasticbottle003a.mdl");
			else if(Rand >= 75) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_milkcarton001a.mdl");
		}
		else if(Type == 2)
		{
			if(Rand < 40) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_takeoutcarton001a.mdl");
			else if(Rand >= 40 && Rand < 70) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_bag001a.mdl");
			else if(Rand >= 70 && Rand < 90) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_metalcan002a.mdl");
			else if(Rand >= 90) DispatchKeyValue(Ent, "model", "models/props_junk/garbage_newspaper001a.mdl");
		}
		DispatchSpawn(Ent);
		TeleportEntity(Ent, TrashOrigin, NULL_VECTOR, NULL_VECTOR);
		GarbageAmount += 1;
	}
}

public Action:RestoreHeal(Handle:Timer, any:Client)
{
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{
		PoliceMedHeal[Client] = 0;
	}
}

public TeleJail(Client)
{
	decl RandomInt;
	decl bool:Correct;
	Correct = false;
	
	RandomInt = GetRandomInt(1, 10);
	if(JailOrigin[RandomInt][0] != 69.0) Correct = true;
	
	if(!Correct) TeleJail(Client);
	else
	{
		TeleportEntity(Client, JailOrigin[RandomInt], NULL_VECTOR, NULL_VECTOR);
	}
}

//Jail:
public Jail(Client, Combine)
{
	if(FreeIn[Client] > 0 && Combine != Client) 
	{
		PrintToChat(Combine, "[RP] - Client is already jailed.");
		return;
	}

	SetEntityMoveType(Client, MOVETYPE_WALK);
	
	if(AnyJail != 1)
	{
		CPrintToChat(Combine, "{white}|RP| -{grey} Server has not created any jail cells.");
	}
	else
	{
		//Declare:
		decl String:ClientName[32], String:CombineName[32];
		
		//Names:
		GetClientName(Combine, CombineName, 32);
		GetClientName(Client, ClientName, 32);
		
		//Action:
		//TimeInJail[Client] = 0.0;
		FreeIn[Client] = 0;
		
		TeleJail(Client);
		
		if(ExpCombineCheck[Client] < 600 && Client != Combine && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Combine))
		{
			ExpRebel[Client] = ExpRebel[Client] - 2;
		}
		if(ExpCombineCheck[Client] >= 600 && ExpCombineCheck[Client] <= 1000 && Client != Combine && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Combine))
		{
			ExpCombine[Combine] = ExpCombine[Combine] + 1;
			ExpRebel[Client] = ExpRebel[Client] - 3;
		}
		if(ExpCombineCheck[Client] > 1000 && Client != Combine && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Combine))
		{
			ExpCombine[Combine] = ExpCombine[Combine] + 1;
			ExpRebel[Client] = ExpRebel[Client] - 4;
		}
		
		//Promotion System.
		if(ExpCombineCheck[Client] >= 600 && Client != Combine && GetConVarInt(ExperienceMode) == 1 && !IsFirefighter(Combine))
		{
			if(ExpCombine[Combine] == 200 && StrContains(Job[Combine], "Recruit", false) != -1)
			{
				Job[Combine] = "Police Officer";
				OrgJob[Combine] = "Police Officer";
				CPrintToChat(Combine, "{white}|RP| -{grey} You have been promoted to: Police Officer");
				Save(Combine);
			}
			else if(ExpCombine[Combine] == 400 && StrContains(Job[Combine], "Officer", false) != -1)
			{
				Job[Combine] = "Police Senior Officer";
				OrgJob[Combine] = "Police Senior Officer";
				CPrintToChat(Combine, "{white}|RP| -{grey} You have been promoted to: Police Senior Officer");
				Save(Combine);
			}
			else if(ExpCombine[Combine] == 600 && StrContains(Job[Combine], "Senior", false) != -1)
			{
				Job[Combine] = "Police Jail Guard";
				OrgJob[Combine] = "Police Jail Guard";
				CPrintToChat(Combine, "{white}|RP| -{grey} You have been promoted to: Police Jail Guard");
				Save(Combine);
			}
			else if(ExpCombine[Combine] == 800 && StrContains(Job[Combine], "Guard", false) != -1)
			{
				Job[Combine] = "Police Chief";
				OrgJob[Combine] = "Police Chief";
				CPrintToChat(Combine, "{white}|RP| -{grey} You have been promoted to: Police Chief");
				Save(Combine);
			}
			else if(ExpCombine[Combine] == 1000 && StrContains(Job[Combine], "Chief", false) != -1)
			{
				Job[Combine] = "Police Medic";
				OrgJob[Combine] = "Police Medic";
				CPrintToChat(Combine, "{white}|RP| -{grey} You have been promoted to: Police Medic");
				Save(Combine);
			}
			else if(ExpCombine[Combine] == 1200 && StrContains(Job[Combine], "Medic", false) != -1)
			{
				Job[Combine] = "SWAT";
				OrgJob[Combine] = "SWAT";
				CPrintToChat(Combine, "{white}|RP| -{grey} You have been promoted to: SWAT");
				Save(Combine);
			}
			else if(ExpCombine[Combine] == 1400 && StrContains(Job[Combine], "SWA", false) != -1)
			{
				Job[Combine] = "SWAT Leader";
				OrgJob[Combine] = "SWAT Leader";
				CPrintToChat(Combine, "{white}|RP| -{grey} You have been promoted to: SWAT Leader");
				Save(Combine);
			}
		}
		
		ExpCombineCheck[Client] = 0;
		
		//Check:
		if(Client != Combine)
		{

			//Print:
			CPrintToChat(Combine, "{white}|RP| -{grey} You have sent %s to jail! (Free in %ds)", ClientName, TimeConverter[Client]);
			CPrintToChat(Client, "{white}|RP| -{grey} You have been sent to jail by %s!", CombineName);
			

			
			if(TimeConverter[Client] > 35 && InJailC[Client] == false)
			{
				CPrintToChat(Combine, "{white}|RP| -{grey} Received $%d for jailing %s.", TimeConverter[Client], ClientName);
				Money[Combine] += TimeConverter[Client];
			}
			if(TimeConverter[Client] > 240 && InJailC[Client] == true)
			{
				TimeConverter[Client] = 240;
			}
			if(StrEqual(Job[Client], "Robber", false))
			{
				Money[Client] = 0;
				if(Bank[Client] > 249)
				{
					Bank[Client] = Bank[Client] - 250;
				}
				Save(Client);
				CPrintToChat(Client, "{white}|RP-Robber| -{grey}  Lost all money and $250 bank penalty!");
			}
			
			if(Grams[Client] > 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} %s has found drugs in your pocket.  Lost %d grams of drugs.", CombineName, Grams[Client]);
				Grams[Client] = 0;
				CPrintToChat(Combine, "{white}|RP| -{grey} Found drugs in %s's pocket. Received $250 bonus!", ClientName);
				Money[Combine] += 250;
			}
		}
		InJailC[Client] = true;
		if(FreeIn[Client] == 0)
		{
			//autofree(Client,float(TimeConverter[Client]));
			StartJail(Client, TimeConverter[Client]);
		}
		//jailtimerstart(Client);
	}	
}

public WithdrawNow(Handle:Withdraw, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:howmuch[64];
		GetMenuItem(Withdraw, param2, howmuch, sizeof(howmuch));
		
		if(StringToInt(howmuch) == 12312399)
		{
			if(Neg[Client] == 0)
			{
				BankMenu1(Client);
			}
			else
			{
				BankMenu2(Client);
			}
		}
		else if(StringToInt(howmuch) <= Bank[Client])
		{
			Bank[Client] = Bank[Client] - StringToInt(howmuch);
			Money[Client] = Money[Client] + StringToInt(howmuch);
			Save(Client);
			CPrintToChat(Client, "{white}|RP| -{grey} You withdrawed $%s", howmuch);
			Transfer1(Client);
			
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You do not have $%s in the bank", howmuch);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Withdraw);
	}
	return 0;
}

public DepositNow(Handle:Deposit, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:howmuch[64];
		GetMenuItem(Deposit, param2, howmuch, sizeof(howmuch));
		
		if(StringToInt(howmuch) == 12312399)
		{
			if(Neg[Client] == 0)
			{
				BankMenu1(Client);
			}
			else
			{
				BankMenu2(Client);
			}
		}
		else if(StringToInt(howmuch) <= Money[Client])
		{
			Bank[Client] = Bank[Client] + StringToInt(howmuch);
			Money[Client] = Money[Client] - StringToInt(howmuch);
			Save(Client);
			CPrintToChat(Client, "{white}|RP| -{grey} You deposited $%s", howmuch);
			Transfer2(Client);
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You do not have $%s", howmuch);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Deposit);
	}
	return 0;
}

//Transaction Handle:
public HandleGiveMoney(Handle:Menu, MenuAction:HandleAction, Client, Parameter)
{
	
	//Select:
	if(HandleAction == MenuAction_Select)
	{
		
		//Declare:
		decl Amount;
		
		//Initialize:
		Amount = SelectedBuffer[Parameter-1][Client];
		if(SelectedBuffer[Parameter-1][Client] == 69) Amount = Money[Client];
		
		//Check:
		if(Money[Client] - Amount >= 0)
		{
			
			//Declare:
			decl String:PlayerName[32];
			decl String:ClientName[32];
			
			//Initialize:
			GetClientName(Client, ClientName, 32);
			GetClientName(MenuTarget[Client], PlayerName, 32);
			
			//Transact:
			Money[Client] -= Amount;  
			Save(Client); 
			
			Money[MenuTarget[Client]] += Amount;
			Save(MenuTarget[Client]); 
			
			
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You gave %s $%d", PlayerName, Amount);
			CPrintToChat(MenuTarget[Client], "{white}|RP| -{grey} You recieve $%d from %s", Amount, ClientName);
			
			//Initialize:
			new String:Buffers[7][64] = {"1", "5", "25", "100", "500", "1000", "All"};
			new Variables[7] = {1, 5, 25, 100, 500, 1000, 69};
			
			//Draw:
			DrawMenu(Client, Buffers, HandleGiveMoney, Variables);
		}
		else
		{
			
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You don't have that much money");
		}
	}
	else if(HandleAction == MenuAction_End)
	{
		CloseHandle(Menu);
	}
	return 0;
}

//Robbing:
public Action:BeginRob(Client, const String:Name[32], Cash, Type, Id)
{
	
	//Combine:
	if(IsCombine(Client))
	{
		
		//Print:
		CPrintToChat(Client, "{white}|RP| -{grey} Prevent crime, do not start it!");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl MaxPlayers;
	decl bool:CombineInGame;
	
	//Initialize:
	MaxPlayers = GetMaxClients();
	CombineInGame = false;
	
	//Loop:
	for(new X = 1; X <= MaxPlayers; X++) if(StrContains(Job[X], "Police", false) != -1 || StrContains(Job[X], "SWAT", false) != -1 || StrContains(Job[X], "Admin", false) != -1) CombineInGame = true;
	
	//Zero Combines:
	if(GetConVarInt(RobMode) == 1 && !CombineInGame)
	{
		
		//Easy Mode:
		CPrintToChat(Client, "{white}|RP| -{grey} Try again later, There is no police online to stop you!");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Ready:
	if(RobTimerBuffer[Type][Id] >= (GetGameTime() - (120 * 1)) && !StrEqual(Job[Client], "Robber", false))
	{
		
		//Print:
		CPrintToChat(Client, "{white}|RP| -{grey} The register has been robbed too recently!");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Robber Job robbing at faster intevals:
	if(RobTimerBuffer[Type][Id] >= (GetGameTime() - (60 * 1)) && StrEqual(Job[Client], "Robber", false))
	{
		
		//Print:
		CPrintToChat(Client, "{white}|RP| -{grey} The register has been robbed too recently!");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Cuffed:
	if(IsCuffed[Client]) return Plugin_Handled;
	
	//Save:
	RobTimerBuffer[Type][Id] = GetGameTime();
	
	//Loop:
	for(new Y = 1; Y <= MaxPlayers; Y++)
	{
		
		//Connected:
		if(IsClientConnected(Y) && IsClientInGame(Y))
		{
			
			//Declare:
			new String:sType[32];
			decl String:PlayerName[32];
			
			//Initialize:
			GetClientName(Client, PlayerName, 32);
			if(Type == 1) sType = "Banker";
			if(Type == 2) sType = "Vendor";
			
			//Print:
			//SetHudTextParams(-1.0, 0.015, 10.0, 255, 255, 255, 255, 0, 6.0, 0.1, 0.2);
			//ShowHudText(Y, -1, "ATTENTION: %s is robbing a %s!", PlayerName, sType);
		}
	}
	
	//Start:
	RobCash[Client] = Cash;
	CreateTimer(1.0, BeginRobbery, Client, TIMER_REPEAT);
	CPrintToChat(Client, "{white}|RP| -{grey} You have started the robbery, stay close to continue getting money");
	AddCrime(Client, 120);
	
	//Return:
	return Plugin_Handled;
}

public Action:BeginRobbery(Handle:Timer, any:Client)
{
	
	//Cleared:
	if(RobCash[Client] <= 0)
	{
		
		//Print:
		CPrintToChat(Client, "{white}|RP| -{grey} You have taken all of the money, run!");
		
		//Kill:
		KillTimer(Timer);
		
		//Print:
		//CPrintToChat(Client, "{white}|RP| -{grey} You have moved too far from the register! Robbery aborted");
		PrintRobberyAbort(Client);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Return:
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsPlayerAlive(Client)) return Plugin_Handled;
	
	//Declare:
	decl Float:Dist;
	decl Float:ClientOrigin[3];
	
	//Initialize:
	GetClientAbsOrigin(Client, ClientOrigin);
	Dist = GetVectorDistance(RobOrigin[Client], ClientOrigin);
	
	//Too Far Away:
	if(Dist >= 150)
	{
		
		//Print:
		CPrintToChat(Client, "{white}|RP| -{grey} You have moved too far from the register! Robbery aborted");
		PrintRobberyAbort(Client);
		
		//Kill:
		RobCash[Client] = 0;
		KillTimer(Timer);
		
		//Return:
		return Plugin_Handled;
	}
	
	//Money:
	Money[Client] += 2;
	RobCash[Client] -= 2;
	
	//Return:
	return Plugin_Handled;
}

//Save:
public Save(Client)
{
	
	//Loaded:
	if(Loaded[Client] && Minutes[Client] >= 1)
	{
		
		//World:
		if(Client != 0)
		{
			//Declare:
			decl String:SteamId[255];
			decl String:ItemId[32];
			
			//Initialize:
			GetClientAuthString(Client, SteamId, 32);
			
			//Variables (Integer):
			
			if(Bank[Client] >= 0)
			{
				Neg[Client] = 0;
				SaveInteger(Client, h_database, "Bank", SteamId, Bank[Client]);
			}
			if(Bank[Client] < 0)
			{
				Neg[Client] = 0 - Bank[Client];
				SaveInteger(Client, h_database, "Bank", SteamId, 0);
			}
			
			SaveInteger(Client, h_database, "Money", SteamId, Money[Client]);
			SaveInteger(Client, h_database, "Wages", SteamId, Wages[Client]);
			SaveInteger(Client, h_database, "Minutes", SteamId, Minutes[Client]);
			SaveInteger(Client, h_database, "Crime", SteamId, Crime[Client]);
			SaveInteger(Client, h_database, "Exploit", SteamId, ExploitJail[Client]);
			SaveInteger(Client, h_database, "Pruned", SteamId, Prune[Client]);
			SaveInteger(Client, h_database, "Negative", SteamId, Neg[Client]);
			SaveInteger(Client, h_database, "Checks", SteamId, NumChecks[Client]);
			SaveInteger(Client, h_database, "ExpRebel", SteamId, ExpRebel[Client]);
			SaveInteger(Client, h_database, "ExpCombine", SteamId, ExpCombine[Client]);
			SaveInteger(Client, h_database, "TimeJail", SteamId, TimeConverter[Client]);
			SaveInteger(Client, h_database, "Grams", SteamId, Grams[Client]);
			//SaveInteger(Client, SaveVault, "Props", SteamId, PropLimit[Client]);
			SaveInteger(Client, h_database, "MainHudColor", SteamId, MainHudColor[Client]);
			SaveInteger(Client, h_database, "CenterHudColor", SteamId, CenterHudColor[Client]);
			SaveInteger(Client, h_database, "ExpLevel", SteamId, ExpLevel[Client]);
			SaveInteger(Client, h_database, "Planted", SteamId, Planted[Client]);
			SaveInteger(Client, h_database, "CuffCount", SteamId, CuffCount[Client]);
			
			/*//Items:
			for(new X = 0; X < MAXITEMS; X++) 
			{
				
				//Convert:
				IntToString(X, ItemId, 32);	
				
				//Save:
				SaveInteger(Client, SaveVault, ItemId, SteamId, Item[Client][X]);
			}*/
			
			SavePlayerItems(h_database, Client);
			
			//Variables (String): 
			//SaveString(SaveVault, "Job", SteamId, OrgJob[Client]);
			SaveStringSQL(Client, h_database, "Job", SteamId, OrgJob[Client]);
			
			//Store:
			//KeyValuesToFile(SaveVault, SavePath);
		}
	}
}

//Load:
public Load(Client)
{
	//Declare:
	decl String:SteamId[255], String:ItemId[32];
	decl String:ReferenceString[255];
	
	//Initialize:
	GetClientAuthString(Client, SteamId, 32);

	
	
	//Variables (Integer):
	Money[Client] = LoadInteger(h_database, "Money", SteamId, DEFAULTMONEY);
	PrintToServer("Loaded Money: %d", Money[Client]);

	Bank[Client] = LoadInteger(h_database, "Bank", SteamId, DEFAULTBANK);
	Wages[Client] = LoadInteger(h_database, "Wages", SteamId, DEFAULTWAGES);
	Minutes[Client] = LoadInteger(h_database, "Minutes", SteamId, 0);
	Crime[Client] = LoadInteger(h_database, "Crime", SteamId, 0);
	ExploitJail[Client] = LoadInteger(h_database, "Exploit", SteamId, 0);
	Prune[Client] = LoadInteger(h_database, "Pruned", SteamId, 0);
	Neg[Client] = LoadInteger(h_database, "Negative", SteamId, 0);
	NumChecks[Client] = LoadInteger(h_database, "Checks", SteamId, 10);
	Neg[Client] = LoadInteger(h_database, "Negative", SteamId, 0);
	ExpRebel[Client] = LoadInteger(h_database, "ExpRebel", SteamId, 0);
	ExpCombine[Client] = LoadInteger(h_database, "ExpCombine", SteamId, 0);
	TimeConverter[Client] = LoadInteger(h_database, "TimeJail", SteamId, 0);
	Grams[Client] = LoadInteger(h_database, "Grams", SteamId, 0);
	//PropLimit[Client] = LoadInteger(h_database, "Props", SteamId, 0);
	MainHudColor[Client] = LoadInteger(h_database, "MainHudColor", SteamId, DEFAULTMAINHUDCOLOR);
	CenterHudColor[Client] = LoadInteger(h_database, "CenterHudColor", SteamId, DEFAULTCENTERHUDCOLOR);
	Planted[Client] = LoadInteger(h_database, "Planted", SteamId, 0);
	ExpLevel[Client] = LoadInteger(h_database, "ExpLevel", SteamId, 0);
	CuffCount[Client] = LoadInteger(h_database, "CuffCount", SteamId, 0);
	
	UncuffStop[Client] = 0;
	NoKill[Client] = 3;
	NoCrime[Client] = 0;
	ExpCombineCheck[Client] = 0;
	Override[Client] = 0;
	AfkClient[Client] = 0;
	WaterGun[Client] = 0;
	HudModeMain[Client] = 1;
	HudModeCenter[Client] = 1;
	Probation[Client] = 0;
	RedCrimeMenu[Client] = 1;
	BettingProtection[Client] = 0;
	TrailAmount[Client] = 0;
	TrailSpam[Client] = 0;
	
	if(GetConVarInt(CrimeMenuSet) > 0)
	{
		RedCrimeMenu[Client] = 1;
	}
	
	decl Handle:AddCar;
	AddCar = CreateKeyValues("Vault");
	FileToKeyValues(AddCar, CarPath);
	for(new W = 0; W <= MAXCARS; W++)
	{
		decl String:Number[255];
		IntToString(W, Number, 255);
		KvJumpToKey(AddCar, Number, false);
		
		OwnsCar[Client][W] = KvGetNum(AddCar, SteamId, 0);
		KvRewind(AddCar);
		
	}
	KvRewind(AddCar);
	CloseHandle(AddCar);
	
	
	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, DoorPath);
	for(new Q = 0; Q <= 100; Q++)
	{
		decl String:Number[255], Test;
		IntToString(Q, Number, 255);
		KvJumpToKey(Vault, Number, false);
		
		Test = KvGetNum(Vault, SteamId, 0);
		if(Test == 1)
		{
			ServerCommand("owndoor %d %d", Client, CatalogDoorInverse[Q]);
		}
		KvRewind(Vault);
	}
	KvRewind(Vault);
	CloseHandle(Vault);
	
	//Check:
	if(Prune[Client] == 0)
	{
		
		//Minutes:
		if(Minutes[Client] > 1000)
		{
			
			//Reset:
			//Minutes[Client] = 1000;
			//Wages[Client] = 10;
			//CPrintToChat(Client, "{white}|RP| -{grey} *Your wages and total minutes have been rolled back due to an unintentional exploit");
			//CPrintToChat(Client, "{white}|RP| -{grey} *This will only happen one time");
			Prune[Client] = 1;
		}
	}
	
	/*//Items:
	for(new X; X < MAXITEMS; X++)
	{
		
		//Convert:
		IntToString(X, ItemId, 32);
		
		//Load:
		Item[Client][X] = LoadInteger(SaveVault, ItemId, SteamId, 0);
	}*/
	
	LoadPlayerItems(h_database, Client);
	
	if(Bank[Client] == 0 && Neg[Client] > 0)
	{
		Bank[Client] = 0 - Neg[Client];
	}
	
	//Variables (String):
	//LoadString(SaveVault, "Job", SteamId, DEFAULTJOB, ReferenceString);
	LoadStringSQL(h_database, "Job", SteamId, ReferenceString, sizeof(ReferenceString), DEFAULTJOB);
	Job[Client] = ReferenceString;
	OrgJob[Client] = ReferenceString;
	
	//Save:
	Loaded[Client] = true;
	
	//If Person is new - This is the Starter Pack
	if(Minutes[Client] == 0 && GetConVarInt(StarterPackMode) == 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You are new to this server. Finding any starter packs...");
		decl Handle:Start;
		Start = CreateKeyValues("Vault");
		FileToKeyValues(Start, StarterPath);
		KvJumpToKey(Start, "Data", false);
		Minutes[Client] = 1;
		Wages[Client] = KvGetNum(Start, "Wages", 2);
		if(Wages[Client] > 2) CPrintToChat(Client, "{white}|RP| -{grey} Wage: %d", Wages[Client]);
		Bank[Client] = KvGetNum(Start, "Bank", 0);
		if(Bank[Client] > 0) CPrintToChat(Client, "{white}|RP| -{grey} Bank: %d", Bank[Client]);
		Money[Client] = KvGetNum(Start, "Money", 0);
		if(Money[Client] > 0) CPrintToChat(Client, "{white}|RP| -{grey} Money: %d", Bank[Client]);
		
		for(new X; X < MAXITEMS; X++)
		{
			IntToString(X, ItemId, 32);
			Item[Client][X] = KvGetNum(Start, ItemId, 0);
			if(Item[Client][X] != 0) CPrintToChat(Client, "{white}|RP| -{grey} %dx of %s", Item[Client][X], ItemName[X]);
		}
		KvRewind(Start);
		CloseHandle(Start);
		//Save(Client); // Fucks up the sql shit.
	}
	
	
	decl Handle:Attributes;
	Attributes = CreateKeyValues("Vault");
	FileToKeyValues(Attributes, JobAttributesPath);
	LoadString2(Attributes, Job[Client], "model", "models/humans/Group03/Male_02.mdl", PlayerModel[Client]);
	CloseHandle(Attributes);
	
	//Hud:
	CreateTimer(0.1, DisplayHud, Client);
}

public Action:Command_Rules(Client, Args)
{	
	ShowMOTDPanel(Client, "Basic Rules", "Basic Rules: \n1. No Cheating\n2. No Glitching\n3. Don't RDM People below 10 hours (Hours = Score)\nThanks, Server Admins.", MOTDPANEL_TYPE_TEXT);
	//CPrintToChat(Client, "{white}|RP| -{grey} Press <esc> for a rules list!");
	return Plugin_Handled;
}

public Action:Command_Help(Client, Args)
{
	ShowMOTDPanel(Client, "Basic Help", "HL2DM: Roleplay Remixed by: EasSidezz\nHow to Play:\n======Job Help======\nDrug Addict: With $300, You can plant Weed Plants upto a maximum of %d, which grow upto 500 Grams Maximum. You press E on them to harvest them, then you can sell them to NPCs for Money!\nScientist: As a scientist, you can create teleporters with /telestart and /teleend, respectivly. Use /telekill to delete both of them.\nSanitation: Take garbage to the trash zone and press E on it.\nRobber: You rob at *2 faster intervals. Press Shift twice to rob an npc or banker.\nStripper: People pay you to do \"Favours\" for them.", MOTDPANEL_TYPE_TEXT);
	return Plugin_Handled;
}
//Death:
public Action:EventDeath(Handle:Event, const String:Name[], bool:Broadcast)
{
	
	//Declare:
	decl Client, Attacker;
	
	//Initialize:
	Client = GetClientOfUserId(GetEventInt(Event, "userid"));
	Attacker = GetClientOfUserId(GetEventInt(Event, "attacker"));
	
	//World:
	if((Client == 0 || Attacker == 0) && LooseMoney[Client] == false) return Plugin_Handled;
	
	ClientCommand(Client, "r_screenoverlay debug/yuv.vmt");
	
	if(WaterGun[Client] == 1)
	{
		WaterGun[Client] = 0;
	}
	
	//Free from jail
	if(GetFree[Client] == true)
	{
		Uncuff(Client);
		GetFree[Client] = false;
	}
	
	//Hitman kills his person!
	if(StrEqual(Job[Attacker], "Hitman", false) && Hitman[Attacker] == Client)
	{
		Hitman[Attacker] = 0;
		CPrintToChat(Attacker, "{white}|RP| -{grey} Received $750 for killing your objective.");
		Money[Attacker] += 750;
		CPrintToChat(HitmanBuyer[Attacker], "{white}|RP| -{grey} The hitman has killed your target");		
	}
	
	if((NoKill[Attacker] == 6 || NoKill[Attacker] == 1) && (!IsCombine(Attacker) && NoKill[Client] != 6) && Attacker != Client)
	{
		Cuff(Attacker);
		CreateTimer(0.3, RemoveWeapons2, Attacker);
		//autofree(Attacker, 90.0);
		
		StartJail(Attacker, 90);
		
		Jail(Attacker,Attacker);
		CPrintToChat(Attacker, "{white}|RP| -{grey} You have been jailed for 1 minute and 30 seconds for killing someone while in a no kill zone");
	}
	
	decl MaxPlayers2;
	decl bool:CombineInGame;
	decl NumCheck;
	NumCheck = 0;
	
	MaxPlayers2 = GetMaxClients();
	CombineInGame = false;
	
	for(new X = 1; X <= MaxPlayers2; X++) 
	{
		if(StrContains(Job[X], "Police", false) != -1 || StrContains(Job[X], "SWAT", false) != -1)
		{
			CombineInGame = true;
			NumCheck = NumCheck + 1;
		}
	}
	
	//Zero Combines:
	if(!CombineInGame && Client != Attacker || NumCheck < 2 && Client != Attacker && GetConVarInt(ExperienceMode) == 1)
	{
		CPrintToChat(Attacker, "{white}|RP| -{grey} No respect points are given when less then 2 cops are on");
	}
	
	
	
	if(Client != Attacker && kopfgeld[Client] == 0 && IsCombine(Client) && !IsCombine(Attacker))
	{
		AddCrime(Attacker, GetConVarInt(RebelKillCombine));
		if(NumCheck > 1 && GetConVarInt(ExperienceMode) == 1)
		{
			if(StrContains(Job[Attacker], "Gangster", false) != -1)
			{			
				ExpRebel[Attacker] = ExpRebel[Attacker] + 2;
			}
		}
	}
	if(Client != Attacker && kopfgeld[Client] == 0 && !IsCombine(Client) && !IsCombine(Attacker))
	{
		AddCrime(Attacker, GetConVarInt(RebelKillRebel));
		if(NumCheck > 1 && GetConVarInt(ExperienceMode) == 1 && CombineInGame)
		{
			if(IsGangster(Attacker) && IsGangster(Client))
			{
				ExpRebel[Attacker] = ExpRebel[Attacker] + 1;
				ExpRebel[Client] = ExpRebel[Client] - 1;
			}
		}
	}
	if(Client == Attacker && LooseMoney[Client] == false)
		return Plugin_Handled; //Suizid  
	
	if(Client != 0 && Attacker != 0)
	{
		new teamAtt = GetClientTeam(Attacker);
		new teamDef = GetClientTeam(Client); 
		InternalFrags[Attacker] += 1; 
		if(teamAtt == teamDef)
			SetEntProp(Attacker, Prop_Data, "m_iFrags", RoundToCeil(FloatDiv(float(Minutes[Attacker]),60.0))+1); //TK Kaschieren
		else
		SetEntProp(Attacker, Prop_Data, "m_iFrags", RoundToCeil(FloatDiv(float(Minutes[Attacker]),60.0))); 
	}
	
	SetTeamScore(3,0);
	SetTeamScore(2,0);    
	
	if(IsCombine(Attacker) && Crime[Client] > 0) Crime[Client] = Crime[Client] / 2;
	
	if(kopfgeld[Client] > 0)
	{       
		decl MaxPlayers;
		decl String:ClientName[70];
		
		//Initialize:
		MaxPlayers = GetMaxClients();
		SetHudTextParams(-1.0, 0.015, 10.0, 255, 255, 255, 255, 1, 4.0, 0.1, 0.2); 
		GetClientName(Client, ClientName, sizeof(ClientName));
		//Loop:
		for(new Y = 1; Y <= MaxPlayers; Y++)
		{
			//Connected:
			if(IsClientConnected(Y) && IsClientInGame(Y))
			{ 
				ShowHudText(Y, -1, "%s got captured! The bounty is gone",ClientName);
			}
		}
		
		if(!IsCombine(Attacker))
			Money[Attacker] += kopfgeld[Client];
		if(StrContains(Job[Attacker], "Bounty Hunter", false) != -1)
		{
			Money[Attacker] += kopfgeld[Client] * 4;
			CPrintToChat(Attacker, "{white}|RP| -{grey} You have recieved quad bounty for being a Bounty Hunter.");
		}
		Cuff(Client);
		AutoBounty[Client] = false;
	}
	
	//Selling Stocks 
	//sellAllAct(Client,0.0);
	
	//Drop Money:
	if(Money[Client] > 0)
	{
		
		//Combine:
		if(!IsCombine(Attacker) || LooseMoney[Client] == true || killOrder[Client] == true)
		{
			//Update:
			if(IsCombine(Client))
			{
				new manamount = GetRandomInt(1,50);
				CreateMoneyBoxes(Client,manamount);
			} else if(LooseMoney[Client] == true && killOrder[Client] == true) //Money verlust durch order66 / Bullen
			{
				new moneylost = 0;
				if(Wages[Client] < Money[Client])
				{
					moneylost = Money[Client] / 5;
					if(moneylost < Wages[Client]) moneylost = Wages[Client];
				} else moneylost = Money[Client];
				Money[Client] = Money[Client] - moneylost;
				CreateMoneyBoxes(Client,moneylost);
				CPrintToChat(Client, "{white}|RP| -{grey} You have lost $%d", moneylost);
				killOrder[Client] = false;
			} else
			{
				CreateMoneyBoxes(Client,Money[Client]);
				CPrintToChat(Client, "{white}|RP| -{grey} You have lost $%d", Money[Client]);
				Money[Client] = 0;
			}
			
			LooseMoney[Client] = false;
		}
	}
	if(Grams[Client] > 0 && Client != Attacker)
	{
		decl Loss;
		Loss = GetRandomInt(1, Grams[Client]);
		Grams[Client] -= Loss;
		CPrintToChat(Client, "{white}|RP| -{grey} You have dropped %d grams of drugs", Loss);
	}
	
	//Save:
	Save(Client);
	
	//Close:
	CloseHandle(Event);
	
	//Return:
	return Plugin_Handled;
}

stock CreateMoneyBoxes(Client,Amount)
{
	//Declare:
	decl Collision;
	decl Float:Position[3],Float:OrgPos[2];
	new Float:Angles[3] = {0.0, 0.0, 0.0};
	GetClientAbsOrigin(Client, Position);
	Position[2] += 30.0;
	OrgPos[0] = Position[0];
	OrgPos[1] = Position[1];
	
	while(Amount > 0)
	{
		//Initialize:
		new Ent = CreateEntityByName("prop_physics_override");
		
		if(Amount > 1000) //goldbar
		{
			DroppedMoneyValue[Ent] = 1000;
			DispatchKeyValue(Ent, "model", "models/money/goldbar.mdl");
			Amount -= 1000; 
		}	
		//Values:
		else if(Amount > 500) //note
		{
			DroppedMoneyValue[Ent] = 500;
			DispatchKeyValue(Ent, "model", "models/money/goldbar.mdl");
			Amount -= 500; 
		}
		else if(Amount > 200) //note
		{
			DroppedMoneyValue[Ent] = 200;
			DispatchKeyValue(Ent, "model", "models/money/note2.mdl");
			Amount -= 200; 
		}
		else if(Amount > 100) //note 
		{
			DroppedMoneyValue[Ent] = 100;
			DispatchKeyValue(Ent, "model", "models/money/note.mdl");
			Amount -= 100;
		}
		else if(Amount > 50) //note 3
		{
			DroppedMoneyValue[Ent] = 50;
			DispatchKeyValue(Ent, "model", "models/money/note3.mdl");
			Amount -= 50; 
		}
		else if(Amount > 20) //golcoin
		{
			DroppedMoneyValue[Ent] = 20;
			DispatchKeyValue(Ent, "model", "models/money/silvcoin.mdl");
			Amount -= 20; 
		}
		else if(Amount > 10) //silvcoin
		{
			DroppedMoneyValue[Ent] = 10;
			DispatchKeyValue(Ent, "model", "models/money/silvcoin.mdl");
			Amount -= 10;  
		}
		else if(Amount > 5) //silvcoin
		{
			DroppedMoneyValue[Ent] = 5;
			DispatchKeyValue(Ent, "model", "models/money/silvcoin.mdl");
			Amount -= 5;  
		}
		else //broncoin
		{
			DroppedMoneyValue[Ent] = 1;
			DispatchKeyValue(Ent, "model", "models/money/broncoin.mdl");
			Amount -= 1; 
		}
		
		//Spawn:
		DispatchSpawn(Ent);
		
		//Angles:
		Angles[1] = GetRandomFloat(0.0, 360.0);
		Position[0] = OrgPos[0] + GetRandomFloat(-50.0, 50.0);
		Position[1] = OrgPos[1] + GetRandomFloat(-50.0, 50.0);
		
		
		//Debris:
		Collision = GetEntSendPropOffs(Ent, "m_CollisionGroup");
		if(IsValidEntity(Ent)) SetEntData(Ent, Collision, 1, 1, true);
		
		//Send:
		TeleportEntity(Ent, Position, Angles, NULL_VECTOR);
	}
	return true;
}

//Damage:
public Action:EventDamage(Handle:Event, const String:Name[], bool:Broadcast)
{
	
	//Declare:
	decl Client, Attacker;
	decl String:WeaponName[32];
	
	//Initialize:
	Client = GetClientOfUserId(GetEventInt(Event, "userid"));
	Attacker = GetClientOfUserId(GetEventInt(Event, "attacker"));
	
	//World:
	if(Attacker == 0) return Plugin_Handled;
	if(Client == 0) return Plugin_Handled;
	if(Client != Attacker && kopfgeld[Client] == 0) AddCrime(Attacker, 15);
	
	//Weapon:
	GetClientWeapon(Attacker, WeaponName, 32);
	
	//Stunstick:
	if(StrEqual(WeaponName, "weapon_stunstick", false) && IsCombine(Attacker) && !IsCombine(Client))
	{
		decl Float:ClientOrigin[3], Float:PlayerOrigin[3], Float:Dist;
		GetClientAbsOrigin(Attacker, ClientOrigin);
		GetClientAbsOrigin(Client, PlayerOrigin);
		Dist = GetVectorDistance(ClientOrigin, PlayerOrigin);
		
		//Check if player is close, prevent nade cuffing and far away shooting.
		if(Dist <= 250)
		{
			//Declare:
			decl String:ClientName[32], String:AttackerName[32];
			
			//Initialize:
			GetClientName(Attacker, AttackerName, 32);
			GetClientName(Client, ClientName, 32);
			
			//Toggle:
			if(IsCuffed[Client])
			{
				if(UncuffStop[Client] == 0)
				{
					Uncuff(Client);
					
					SetEntityHealth(Client, 100);
					
					CPrintToChat(Attacker, "{white}|RP| -{grey} You uncuff %s", ClientName);
					CPrintToChat(Client, "{white}|RP| -{grey} You are uncuffed by %s", AttackerName);
					return Plugin_Handled;
				}
				SetEntityHealth(Client, 100);
				return Plugin_Handled;	
			}
			
			decl CrimeLimit;
			CrimeLimit = GetConVarInt(CuffCrime);
			
			if(Crime[Client] < CrimeLimit && CrimeLimit != 0)
			{
				SetEntityHealth(Client, 100);
				CPrintToChat(Attacker, "{white}|RP| -{grey} You cannot cuff a player that has under %d crime", CrimeLimit);
			}
			
			//Cuff:
			if(Crime[Client] >= CrimeLimit)
			{
				//Print:
				CPrintToChat(Attacker, "{white}|RP| -{grey} You cuff %s with %d crime.", ClientName, Crime[Client]);
				CPrintToChat(Client, "{white}|RP| -{grey} You are cuffed by %s", AttackerName);
				
				Cuff(Client);
				CreateTimer(0.5, RemoveWeapons, Client);
				
				//HP:
				SetEntityHealth(Client, 100);
				CuffCount[Attacker] += 1;
				CheckCuffs(Attacker);
			}		
			
			//Return:
			return Plugin_Handled;	
		}
	}
	return Plugin_Handled;
}

public setDoorRights(Client,var)
{
	decl ClientID;
	//Initialize:
	ClientID = GetClientUserId(Client);
	
	ServerCommand("sm_copdoor #%d %d", ClientID, var);
}

public setDoorRights2(Client,var)
{
	decl ClientID;
	//Initialize:
	ClientID = GetClientUserId(Client);
	
	ServerCommand("sm_firedoor #%d %d", ClientID, var);
}

//Spawn:
public EventSpawn(Handle:Event, const String:Name[], bool:Broadcast)
{
	
	//Declare:
	decl Client;
	
	//Initialize:
	Client = GetClientOfUserId(GetEventInt(Event, "userid"));
	
	ComaxPlayerSpawn(Client);
	
	//Color:
	SetEntityRenderMode(Client, RENDER_NORMAL);
	SetEntityRenderColor(Client, 255, 255, 255, 255);
	
	//Speed:
	SetSpeed(Client, 190.0);
	
	//OverLays
	if(StrContains(Job[Client], "ASSHOLE", false) != -1)
	{
		SetEntityHealth(Client,30);
		ClientCommand(Client, "r_screenoverlay debug/yuv.vmt");
	} else
	{
		ClientCommand(Client, "r_screenoverlay 0");
	}
	
	if(OnProbation(Client))
	{
		SetEntityHealth(Client,75);
		SetSpeed(Client, 120.0);
	}
	
	EquipSpam[Client] = 0;
	
	//Restrict:
	CreateTimer(0.5, RemoveWeapons, Client);
	CreateTimer(1.5, CombineWeapons, Client);
	if(IsCombine(Client)) setDoorRights(Client,1); else setDoorRights(Client,0);
	if(IsFirefighter(Client)) setDoorRights2(Client,1); else setDoorRights2(Client,0);
	
	SetEntProp(Client, Prop_Data, "m_iFrags", RoundToCeil(FloatDiv(float(Minutes[Client]),60.0))); 
	
	//Jailed:
	if(ExploitJail[Client] == 1)
	{
		//Jail:
		Jail(Client, Client);
		
		//Save:
		if(!IsCombine(Client)) IsCuffed[Client] = true;
		
		//Color:
		SetEntityRenderMode(Client, RENDER_GLOW);
		SetEntityRenderColor(Client, CuffColor[0], CuffColor[1], CuffColor[2], CuffColor[3]);
		
		//CPrintToChat(Client, "{white}|RP| -{grey} You'll be free in %d seconds", TimeConverter[Client]);
		
		
		//Send:
		CreateTimer(1.0, WaitJail, Client);
	}
	else
	{
		
		//Cuffed:
		IsCuffed[Client] = false;
	}
	
	CreateTimer(2.0, SendJobMenu, Client);
	
	
	//Close:
	CloseHandle(Event);
}

public Action:SendJobMenu(Handle:timer, any:Client)
{
	if(StrEqual(Job[Client], DEFAULTJOB))
	{
		JobMenu(Client);
	}
}

//Wait:
public Action:WaitJail(Handle:Timer, any:Client)
{
	//Jail:
	Jail(Client, Client);
}

//Remove Weapons:
public Action:RemoveWeapons(Handle:Timer, any:Client)
{
	if(IsClientConnected(Client) && IsClientInGame(Client) && IsPlayerAlive(Client))
	{
		//Declare:
		decl Offset;
		decl MaxGuns;
		decl WeaponId;
		
		//Initialize:
		Offset = FindSendPropOffs("CHL2MP_Player", "m_hMyWeapons");
		
		//Weapons:
		if(IsCuffed[Client]) MaxGuns = 256;
		else MaxGuns = 16;
		
		//Loop:
		for(new X = 0; X < MaxGuns; X = (X + 4))
		{
			
			//Initialize:
			WeaponId = GetEntDataEnt2(Client, Offset + X);
			
			//Valid:
			if(WeaponId > 0)
			{
				
				//Weapon:
				RemovePlayerItem(Client, WeaponId);
				RemoveEdict(WeaponId);
			}
		}
	}
}

public Action:GiveWeapon(Client, Args)
{
	decl String:Weapon[32];
	decl String:Player[32], String:Sender[MAX_NAME_LENGTH];
	decl String:TargetName[MAX_NAME_LENGTH];
	
	GetCmdArg(1, Player, sizeof(Player));
	new Target = FindTarget(Client, Player);
	
	GetCmdArg(2, Weapon, sizeof(Weapon));
	Client_GiveWeapon(Target, Weapon, true);
	
	
	if(Target == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Target not found");		
		//Return 
		return Plugin_Handled;
	}
	if(!IsPlayerAlive(Target))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This command must be used on an alive player.");
		
		//Return
		return Plugin_Handled;
	}
	else if(Args != 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Wrong Usage: sm_weapon <player> <classname>");
		
		//Return
		return Plugin_Handled;
	}
	GetClientName(Target, TargetName, sizeof(TargetName));
	CPrintToChat(Client, "{white}|RP| -{grey} you gave %s a %s", TargetName, Weapon);
	GetClientName(Client, Sender, sizeof(Sender));
	CPrintToChat(Target, "{white}|RP| -{grey} %s gave you a %s", Sender, Weapon);
	
	return Plugin_Handled;
}
/*
public Action:AntiCheat(Client, Args)
{
	decl String:Command[64];
	decl String:Name[MAX_NAME_LENGTH];
	
	GetClientName(Client, Name, MAX_NAME_LENGTH);
	if(IsClientInGame(Client))
	{
		CPrintToChatAll("{white}%s just tried to use a cheat command! LOL RETARD.", Name);
		KickClient(Client, Command);
	}
	return Plugin_Handled;
}
*/
public Action:GravityGun(Handle:Timer, any:Client)
{
	GivePlayerItem(Client, "weapon_physcannon");
}

public Action:RemoveWeapons2(Handle:Timer, any:Attacker)
{
	if(IsClientConnected(Attacker) && IsClientInGame(Attacker) && IsPlayerAlive(Attacker))
	{
		//Declare:
		decl Offset;
		decl MaxGuns;
		decl WeaponId;
		
		//Initialize:
		Offset = FindSendPropOffs("CHL2MP_Player", "m_hMyWeapons");
		
		//Weapons:
		if(IsCuffed[Attacker]) MaxGuns = 256;
		else MaxGuns = 16;
		
		//Loop:
		for(new X = 0; X < MaxGuns; X = (X + 4))
		{
			
			//Initialize:
			WeaponId = GetEntDataEnt2(Attacker, Offset + X);
			
			//Valid:
			if(WeaponId > 0)
			{
				
				//Weapon:
				RemovePlayerItem(Attacker, WeaponId);
				RemoveEdict(WeaponId);
			}
		}
	}
}

stock CheckCuffs(Client)
{
	if(IsCombine(Client) && !IsCuffed[Client])
	{
		if(CuffCount[Client] > 4 && CuffCount[Client] < 15)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(CuffCount[Client] > 14 && CuffCount[Client] < 25)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(CuffCount[Client] > 24 && CuffCount[Client] < 65)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(CuffCount[Client] > 64 && CuffCount[Client] < 105)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(CuffCount[Client] > 104 && CuffCount[Client] < 150)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(CuffCount[Client] > 149 && CuffCount[Client] < 250)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(CuffCount[Client] > 249 && CuffCount[Client] < 500)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(CuffCount[Client] > 499 && CuffCount[Client] < 1000)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
	}
}

stock CheckPlanted(Client)
{	
	if(!IsCombine(Client) && !IsCuffed[Client] && GetConVarInt(ExperienceMode) == 1)
	{
		if(Planted[Client] > 49 && Planted[Client] < 150)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(Planted[Client] > 149 && Planted[Client] < 250)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(Planted[Client] > 249 && Planted[Client] < 400)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(Planted[Client] > 399 && Planted[Client] < 450)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(Planted[Client] > 499 && Planted[Client] < 600)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
		if(Planted[Client] > 599 && Planted[Client] < 700)
		{
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
			Save(Client);
		}
	}
}

/*public Action:LevelHP(Handle:Timer, any:Client)
{
	decl HP;
	HP = GetClientHealth(Client);
	new LevelHP2 = HP + ExpLevel[Client];
	SetEntityHealth(Client, LevelHP2);
	return Plugin_Handled;
}
*/
//Combine Weapons:
public Action:CombineWeapons(Handle:Timer, any:Client)
{
	
	//=====================================================
	//=====================================================
	//YOU SHOULD NOT BE EDITTING THIS!!! EDIT THE JOB SETUP DATABASE!
	//=====================================================
	//=====================================================
	if(!IsClientInGame(Client) || !IsClientConnected(Client) || !IsPlayerAlive(Client))
	{
		return Plugin_Handled;
	}
	
	//Rebel Respect Experience:
	if(!IsCombine(Client) && !IsCuffed[Client] && GetConVarInt(ExperienceMode) == 1)
	{
		if(ExpRebel[Client] > 199 && ExpRebel[Client] < 400)
		{
			GivePlayerItem(Client, "weapon_crowbar");
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
		}
		if(ExpRebel[Client] > 399 && ExpRebel[Client] < 600)
		{
			GivePlayerItem(Client, "weapon_crowbar");
			GivePlayerItem(Client, "weapon_pistol");
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
		}
		if(ExpRebel[Client] > 599 && ExpRebel[Client] < 800)
		{
			GivePlayerItem(Client, "weapon_crowbar");
			GivePlayerItem(Client, "weapon_pistol");
			GivePlayerItem(Client, "weapon_smg1");
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
		}
		if(ExpRebel[Client] > 799 && ExpRebel[Client] < 1000)
		{
			GivePlayerItem(Client, "weapon_crowbar");
			GivePlayerItem(Client, "weapon_pistol");
			GivePlayerItem(Client, "weapon_smg1");
			GivePlayerItem(Client, "weapon_shotgun");
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
		}
		if(ExpRebel[Client] > 999 && ExpRebel[Client] < 1150)
		{
			GivePlayerItem(Client, "weapon_crowbar");
			GivePlayerItem(Client, "weapon_pistol");
			GivePlayerItem(Client, "weapon_smg1");
			GivePlayerItem(Client, "weapon_shotgun");
			GivePlayerItem(Client, "weapon_crossbow");
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
		}
		if(ExpRebel[Client] > 1149)
		{
			GivePlayerItem(Client, "weapon_crowbar");
			GivePlayerItem(Client, "weapon_pistol");
			GivePlayerItem(Client, "weapon_smg1");
			GivePlayerItem(Client, "weapon_shotgun");
			GivePlayerItem(Client, "weapon_crossbow");
			GivePlayerItem(Client, "weapon_357");
			ExpLevel[Client] += 1;
			CPrintToChat(Client, "{white}|RP| -{grey} You've leveled up! You're now level: {green}%d{grey}.", ExpLevel[Client]);
		}
		Save(Client);
	}
	
	if(IsCombine(Client))
	{
		//Give Default Cop Weapons:
		GivePlayerItem(Client, "weapon_stunstick");
		GivePlayerItem(Client, "weapon_pistol");
	}
	if(IsPlayerAlive(Client))
	{
		//CreateTimer(1.0, LevelHP, Client);
		
		//Something eassides did.
		if(SteamIdToInt(Client) == 34892582 || SteamIdToInt(Client) == 39835951 || SteamIdToInt(Client) == 52528532 || SteamIdToInt(Client) == 56425741)
			CPrintToChat(Client, "{white}|RP| -{grey} Congratulations, Go fuck yourself, eas! :)");
	}

	if(!IsCuffed[Client])
	{
		decl Handle:Attributes;
		Attributes = CreateKeyValues("Vault");
		FileToKeyValues(Attributes, JobAttributesPath);
		
		decl WeaponAmount, Health, Suit, God, Jetpack;
		
		for(new X = 1; X < 26; X++)
		{
			WeaponAmount = LoadInteger2(Attributes, Job[Client], WeaponArray[X], 0);
			if(WeaponAmount > 0)
			{
				for(new Y = 1; Y <= WeaponAmount; Y++)
				{
					GivePlayerItem(Client, WeaponArray[X]);
				}
			}
		}
		Health = LoadInteger2(Attributes, Job[Client], "health", 0);
		Suit = LoadInteger2(Attributes, Job[Client], "suit", 0);
		God = LoadInteger2(Attributes, Job[Client], "god", 0);
		Jetpack = LoadInteger2(Attributes, Job[Client], "jetpack", 0);
		if(Override[Client] != 1) LoadString2(Attributes, Job[Client], "model", "models/humans/Group03/Male_02.mdl", PlayerModel[Client]);
		if(Health > 0) SetEntityHealth(Client, Health); else SetEntityHealth(Client, 100);
		if(Suit > 0) SetEntProp(Client, Prop_Data, "m_ArmorValue", Suit, 1);
		if(Jetpack > 0) PermitJetpack[Client] = true;
		
		if(God == 1)
		{
			SetEntProp(Client, Prop_Data, "m_takedamage", 0, 1);
			GodMode[Client] = 1;
		}
		else
		{
			SetEntProp(Client, Prop_Data, "m_takedamage", 2, 1);
			GodMode[Client] = 0;
		}
		CloseHandle(Attributes);
	}
	return Plugin_Handled;
}

//Prethink:
public OnGameFrame()
{
	
	//Declare:
	decl MaxPlayers;
	
	//Initialize:
	MaxPlayers = GetMaxClients();
	
	if(GetConVarBool(sm_jetpack) && g_fTimer < GetGameTime() - 0.075)
	{
		g_fTimer = GetGameTime();
		
		for(new i = 1; i <= g_iMaxClients; i++)
		{
			if(g_bJetpacks[i])
			{
				if(!IsAlive(i)) StopJetpack(i);
				else AddVelocity(i, GetConVarFloat(sm_jetpack_speed));
			}
		}
	}
	
	//Loop:
	for(new Client = 1; Client <= MaxPlayers; Client++)
	{
		
		//Connected:
		if(IsClientConnected(Client) && IsClientInGame(Client))
		{
			
			//Declare:
			decl Float:ClientOrigin[3];
			
			//Origin:
			if(IsClientInGame(Client)) GetClientAbsOrigin(Client, ClientOrigin);
			
			//Alive:
			if(IsPlayerAlive(Client))
			{
				//unlimited Run
				new m_bitsActiveDevices = GetEntProp(Client, Prop_Send, "m_bitsActiveDevices");
				if (m_bitsActiveDevices & bits_SUIT_DEVICE_SPRINT && (StrContains(Job[Client], "Admin", false) != -1 || StrContains(Job[Client], "SWAT", false) != -1 || StrContains(Job[Client], "Firefighter Chief", false) != -1 || StrContains(Job[Client], "Police", false) != -1 || StrContains(Job[Client], "Bounty Hunter", false) != -1)) 
				{
					SetEntPropFloat(Client, Prop_Data, "m_flSuitPowerLoad", 0.0);
					SetEntProp(Client, Prop_Send, "m_bitsActiveDevices", m_bitsActiveDevices & ~bits_SUIT_DEVICE_SPRINT);
				}
				
				//Attack:
				if(GetClientButtons(Client) & IN_USE) if(IsCuffed[Client]) CreateTimer(0.0, RemoveWeapons, Client);
				
				//E Key:
				if(GetClientButtons(Client) & IN_USE)
				{
					
					//Overflow:
					if(!PrethinkBuffer[Client])
					{
						
						//Action:
						CommandUse(Client);
						
						//UnHook:
						PrethinkBuffer[Client] = true;
					}
				}
				
				//Shift Key:
				else if(GetClientButtons(Client) & IN_SPEED)
				{
					
					//Cuffed:
					if(IsCuffed[Client]) SetSpeed(Client, 45.0);
					if(!IsCuffed[Client] && OnProbation(Client)) SetSpeed(Client, 45.0);
					
					//Overflow:
					if(!PrethinkBuffer[Client])
					{
						
						//Action:
						CommandSpeed(Client);
						
						//UnHook:
						PrethinkBuffer[Client] = true;
					}
				}
				//Nothing:
				else
				{
					
					//Hook:
					PrethinkBuffer[Client] = false;
				}
			}
		}
	}
}

stock bool:IsMoneyModel(Ent)
{
	decl String:moneymodel[128];
	GetEntPropString(Ent, Prop_Data, "m_ModelName", moneymodel, 128);
	
	if(StrEqual(moneymodel, "models/money/broncoin.mdl", false)) return true;
	if(StrEqual(moneymodel, "models/money/silvcoin.mdl", false)) return true;
	if(StrEqual(moneymodel, "models/money/goldcoin.mdl", false)) return true;
	if(StrEqual(moneymodel, "models/money/note3.mdl", false)) return true;
	if(StrEqual(moneymodel, "models/money/note2.mdl", false)) return true;
	if(StrEqual(moneymodel, "models/money/note.mdl", false)) return true;
	if(StrEqual(moneymodel, "models/money/goldbar.mdl", false)) return true;
	else return false;
}

stock bool:IsBombModel(Ent)
{
	decl String:bombmodel[128];
	GetEntPropString(Ent, Prop_Data, "m_ModelName", bombmodel, 128);
	
	if(StrEqual(bombmodel, "models/props_lab/reciever01b.mdl", false)) return true;
	else return false;
}


public DestroyDrugPlant(Client, PlantNumber)
{
	DrugPlant[Client][PlantNumber][0] = 0.0;
	DrugPlantWorth[Client][PlantNumber] = 0;
	decl String:CheckDrugPlant[64];
	GetEntPropString(DrugEnt[Client][PlantNumber], Prop_Data, "m_ModelName", CheckDrugPlant, 64);
	if(StrEqual(CheckDrugPlant, "models/props_lab/cactus.mdl", false))
	{
		AcceptEntityInput(DrugEnt[Client][PlantNumber], "kill");
	}
	DrugEnt[Client][PlantNumber] = 0;
}


//E Key:
public Action:CommandUse(Client)
{
	//Declare:
	decl Ent;
	
	//Initialize:
	Ent = GetClientAimTarget(Client, false);

	
	//Cuffed:
	if(IsCuffed[Client])
	{
		
		if(Ent > 0 && Ent <= GetMaxClients())
		{
			if(IsCombine(Ent))
			{
			} else
			{
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You may not do this while cuffed");
				
				//Return:
				return Plugin_Handled;
			}
		} else
		{
			//Print:
			CPrintToChat(Client, "{white}|RP| -{grey} You may not do this while cuffed");
			
			//Return:
			return Plugin_Handled;
		}
	}	
	//Check:
	if(Ent != -1)
	{
		decl String:ClassName[22];
		GetEdictClassname(Ent, ClassName, 22);
		
		
		//VIPDoor: By Reloaded
		if(ToggleVipDoor(Client, Ent, ClassName))
			return Plugin_Handled;
		
		//Money:
		if(DroppedMoneyValue[Ent] > 0 && StrEqual(ClassName, "prop_physics"))
		{
			//Declare:
			decl Float:Dist;
			decl Float:ClientOrigin[3], Float:EntOrigin[3];
			
			//Initialize:
			GetClientAbsOrigin(Client, ClientOrigin);
			GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);
			Dist = GetVectorDistance(ClientOrigin, EntOrigin);
			
			//Range:
			if(Dist <= 300 && IsMoneyModel(Ent))
			{
				
				//Exchange:
				Money[Client] += DroppedMoneyValue[Ent];
				
				//Remove Ent:
				AcceptEntityInput(Ent, "Kill", Client);
				
				//Print:
				CPrintToChat(Client, "{white}|RP| -{grey} You pick up $%d!", DroppedMoneyValue[Ent]);
				
				//Save:
				DroppedMoneyValue[Ent] = 0;
				
				//Return:
				return Plugin_Handled;
			}
		}
		
		if(StrEqual(ClassName, "prop_physics") && BombData[Ent][0] == 0)
		{
			if(IsBombModel(Ent))
			{
				Bomb(Client, Ent);
				return Plugin_Handled;
			}
		}
		
		//Loop:
		for(new X = 0; X < MAXITEMS; X++)
		{
			
			//Money:
			if(ItemAmount[Ent][X] > 0)
			{
				
				//Declare:
				decl Float:Dist;
				decl Float:ClientOrigin[3], Float:EntOrigin[3];
				
				//Initialize:
				GetClientAbsOrigin(Client, ClientOrigin);
				GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);
				Dist = GetVectorDistance(ClientOrigin, EntOrigin);
				
				decl String:modelcheck[128];
				GetEntPropString(Ent, Prop_Data, "m_ModelName", modelcheck, 128);
				
				//Range:
				if(Dist <= 300 && StrEqual(modelcheck, "models/Items/BoxMRounds.mdl", false))
				{
					
					//Remove Ent:
					AcceptEntityInput(Ent, "Kill", Client);
					
					if(X == 97)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You picked up a trap!!!");
						
						//Write:		
						TE_SetupExplosion(ClientOrigin, 0, 30.0, 30, 0, 100, 100);
						
						//Initialize:
						LooseMoney[Client] = true;
						//Send:
						ForcePlayerSuicide(Client);
						TE_SendToAll();
					} else
					{
						//Exchange:
						Item[Client][X] += ItemAmount[Ent][X];
						CPrintToChat(Client, "{white}|RP| -{grey} You pick up %d x %s!", ItemAmount[Ent][X], ItemName[X]);
					}
					//Save:
					ItemAmount[Ent][X] = 0;
					
					//Return:
					return Plugin_Handled;
				}
			}
		}
		
		if(StrEqual(ClassName, "prop_physics", false) && DroppedMoneyValue[Ent] == 0 && !IsMoneyModel(Ent) && !IsBombModel(Ent))
		{
			if(StrEqual(Job[Client], "Sanitation", false))
			{
				decl Float:ClientOrigin[3], Float:Dist;
				GetClientAbsOrigin(Client, ClientOrigin);
				Dist = GetVectorDistance(ClientOrigin, GarbageOrigin);
				if(Dist < 100)
				{
					if(GarbageAmount > 0)
					{
						GarbageAmount -= 1;
					}
					AcceptEntityInput(Ent, "Kill", Client);
					decl Value;
					Value = GetRandomInt(36, 150);
					CPrintToChat(Client, "{white}|RP-Garbage| -{grey}  You've received $%d for cleaning up trash.", Value);
					Money[Client] += Value;
					Save(Client);
					return Plugin_Handled;
				}
				else
				{
					CPrintToChat(Client, "{white}|RP-Garbage| -{grey}  Bring this object to the garbage zone for money");
					return Plugin_Handled;
				}
			}
		}
		if(ReAddToInv(Client, Ent, ClassName))
			return Plugin_Handled;
		
		
		if((StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")) && !IsCombine(Client))
		{
			if(lastpressedE[Client] > (GetGameTime()-3.0))
				pressedE[Client]++;
			else
			pressedE[Client] = 0;
			
			lastpressedE[Client] = GetGameTime();	
			
			if(pressedE[Client] == 10)
			{
				Cuff(Client);
				Jail(Client,Client);
			}
			else if(pressedE[Client] == 9)
			{
				CPrintToChat(Client, "{white}|RP-Doorblock| -{grey}  Last warning - stop doorblocking or jail!");
			}
			else if(pressedE[Client] > 5)
			{
				CPrintToChat(Client, "{white}|RP-Doorblock| -{grey}  You are blocking this door. Stop Using it.");
			}
		}
		
		//Player:
		if(Ent > 0 && Ent <= GetMaxClients())
		{
			if(IsCombine(Client) && IsCuffed[Ent])
			{
				if(lastpressedE[Client] > (GetGameTime() - 3.0))
				{
					Jail(Ent,Client);
				}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey} Press USE again to put the person in jail");
					lastpressedE[Client] = GetGameTime(); 
				}
			}
			
			//Declare:
			decl Float:Dist2;
			decl Float:ClientOrigin2[3];
			decl Float:EntOrigin[3];
			decl String:ClientName[255];
			
			//Initialize:
			GetClientAbsOrigin(Client, ClientOrigin2);
			GetClientAbsOrigin(Ent, EntOrigin);
			Dist2 = GetVectorDistance(ClientOrigin2, EntOrigin);
			GetClientName(Ent, ClientName, sizeof(ClientName));
			//
			//
			//Close:
			if(Dist2 <= 150)
			{
				MenuTarget[Client] = Ent;
				new Handle:PlayerInfo = CreateMenu(PlayerInformation);
				SetMenuTitle(PlayerInfo, "%s\n=============", ClientName);
				
				PickPocketAddMenu(PlayerInfo, Client, Ent);
				
				AddMenuItem(PlayerInfo, "1", "-|Give Money|-");
				AddMenuItem(PlayerInfo, "2", "-|Give Item|-");
				if(IsCombine(Client) && IsCuffed[Ent])
				{
					AddMenuItem(PlayerInfo, "3", "-|Jail|-");
					AddMenuItem(PlayerInfo, "4", "-|VIP 10min|-");
					AddMenuItem(PlayerInfo, "5", AFKROOM);
					AddMenuItem(PlayerInfo, "6", SUICIDEONE);
					AddMenuItem(PlayerInfo, "7", SUICIDETWO);
					AddMenuItem(PlayerInfo, "16", "-|Search Player|-");
					AddMenuItem(PlayerInfo, "17", "-|Release Player|-");
				}
				if(IsCombine(Client) && IsCombine(Ent) && StrEqual(Job[Client], "Police Medic", false))
				{
					AddMenuItem(PlayerInfo, "8", "-|Heal Player|-");
				}
				
				//Bribe Menu Button
				if(IsCombine(Ent) && FreeIn[Client] > 0 && !IsCombine(Client))
				{
					AddMenuItem(PlayerInfo, "-1", "-|Bribe|-");
				}
				
				if(StrEqual(Job[Client], DEFAULTGANGLEADER, false) && !StrEqual(Job[Ent], DEFAULTGANG, false) && !IsCombine(Ent))
				{
					AddMenuItem(PlayerInfo, "9", "-|Add Gang Member|-");
				}
				else if(StrEqual(Job[Client], DEFAULTGANGLEADER, false) && StrEqual(Job[Ent], DEFAULTGANG, false) && !IsCombine(Ent)) 
				{
					AddMenuItem(PlayerInfo, "9", "-|Rem Gang Member|-");
				}
				else if(StrEqual(Job[Client], "Medic", false) && GetClientHealth(Ent) < 100 && !IsCombine(Ent))
				{
					AddMenuItem(PlayerInfo, "10", "-|Heal Player|-");
				}
				else if(StrEqual(Job[Client], "RP Guide", false) && !IsCombine(Ent))
				{
					AddMenuItem(PlayerInfo, "11", "-|Guide Player|-");
				}
				else if(StrEqual(Job[MenuTarget[Client]], "Lawyer", false) && !IsCombine(Ent))
				{
					AddMenuItem(PlayerInfo, "15", "-|Reduce Crime (400)|-");
				}
				
				
				
				if(StrEqual(Job[MenuTarget[Client]], "Stripper", false) && !IsCombine(Client))
				{
					AddMenuItem(PlayerInfo, "12", "-|Make Love|-");
				}
				if(StrEqual(Job[MenuTarget[Client]], "Hitman", false) && !IsCombine(Client))
				{
					AddMenuItem(PlayerInfo, "13", "-|Place a Hit|-");
				}
				if(StrEqual(Job[MenuTarget[Client]], "Salesman", false) && !IsCombine(Client))
				{
					AddMenuItem(PlayerInfo, "14", "-|Buy Items|-");
				}
				
				SetMenuPagination(PlayerInfo, 7);
				DisplayMenu(PlayerInfo, Client, 30);
				
				//Return:
				return Plugin_Handled;
			}
		}
		//Declare:	
		decl Handle:Vault;
		decl Float:Dist, Float:ClientOrigin[3], Float:Origin[3];
		decl String:NPCId[255], String:Props[255], String:Buffer[5][32];
		
		//Vault:
		Vault = CreateKeyValues("Vault");
		
		//Retrieve:
		FileToKeyValues(Vault, NPCPath);
		
		//Loop:
		for(new X = 0; X < 100; X++)
		{
			
			//Convert:
			IntToString(X, NPCId, 255);
			
			//Load:
			LoadString(Vault, "1", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					if(Neg[Client] == 0)
					{
						BankMenu1(Client);
					}
					else
					{
						BankMenu2(Client);
					}
					
					//Return:
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
			
			//Load:
			LoadString(Vault, "0", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					if(OnProbation(Client))
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You cannot change your job when your're on Probation");
						return Plugin_Handled;
					}
					//Job Menu:
					JobMenu(Client);
					
					//Return:
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
			
			//Load:
			LoadString(Vault, "2", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					
					//Job Menu:
					VendorMenuNEW(Client, X);
					
					//Return:
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
			
			//Load:
			LoadString(Vault, "3", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					
					//Job Menu:
					VendorMenu(Client, X, true,false);
					//Return:
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
			
			//Load:
			LoadString(Vault, "4", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					
					//Job Menu:
					VendorMenu(Client, X, false, true);
					
					//Return:
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
			
			//Load:
			LoadString(Vault, "5", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{	
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					
					//Job Menu:
					VendorMenu(Client, X, true, true);
					
					//Return:
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
			
			if(StrContains(Job[Client], "Gang", false) != -1 || IsCombine(Client))
			{
				//Load:
				LoadString(Vault, "7", NPCId, "Null", Props);
				
				//Found in DB:
				if(StrContains(Props, "Null", false) == -1)
				{    
					//Explode:
					ExplodeString(Props, " ", Buffer, 5, 32);
					
					//Origin:
					GetClientAbsOrigin(Client, ClientOrigin);
					Origin[0] = StringToFloat(Buffer[1]);
					Origin[1] = StringToFloat(Buffer[2]);
					Origin[2] = StringToFloat(Buffer[3]);
					
					//Distance:
					Dist = GetVectorDistance(ClientOrigin, Origin);
					
					//Check:
					if(Dist <= 150)
					{
						
						//Job Menu:
						VendorMenu(Client, X, false, false);
						
						//Return:
						CloseHandle(Vault);
						return Plugin_Handled;
					}
				}
			}
			
			//Load:
			LoadString(Vault, "8", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					if(GetConVarInt(TaxiCrime) == 0 && Crime[Client] != 0)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You cannot use the taxi when you have crime");
						return Plugin_Handled;
					}
					//Taxi Menu:
					TaxiMenu(Client);
					//Return:
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
			
			//Load:
			LoadString(Vault, "9", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					if(!IsCombine(Client))
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You are not a cop.");
						return Plugin_Handled;
					}
					if(EquipSpam[Client] == 1)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} Please wait a couple seconds before resupplying.");
						return Plugin_Handled;
					}
					ReEquip(Client);
					CloseHandle(Vault);
					return Plugin_Handled;
				}
			}
		}
		
		//Close:
		CloseHandle(Vault);
	}
	
	//Tele and Drug Checking!
	for(new T = 0; T <= 32; T++)
	{
		decl Float:TeleClient[3];
		GetClientAbsOrigin(Client, TeleClient);
		if(TeleStartOrigin[T][0] != 0.0 && TeleEndOrigin[T][0] != 0.0)
		{	
			decl Float:TeleDist;
			TeleDist = GetVectorDistance(TeleStartOrigin[T], TeleClient);
			if(TeleDist < 100.0)
			{
				if(T == Client)
				{
					CPrintToChat(Client, "{white}|RP| -{grey} Using teleporter....");
					TeleportEntity(Client, TeleEndOrigin[T], NULL_VECTOR, NULL_VECTOR);
					ClientCommand(Client, "play ambient/machines/teleport1.wav");
					return Plugin_Handled;
				}
				if(Money[Client] > 199)
				{
					CPrintToChat(Client, "{white}|RP| -{grey} Using teleporter....");
					CPrintToChat(T, "{white}|RP-Scientist| -{grey}  A player has used your teleporter.  Received $200.");
					Money[Client] = Money[Client] - 200;
					Money[T] = Money[T] + 200;
					Save(Client);
					Save(T);
					TeleportEntity(Client, TeleEndOrigin[T], NULL_VECTOR, NULL_VECTOR);
					ClientCommand(Client, "play ambient/machines/teleport1.wav");
					return Plugin_Handled;
				}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You do not have $200.");
					return Plugin_Handled;
				}
			}
		}
		for(new D = 0; D < GetConVarInt(MaxPlants); D++)
		{
			//T = 32 possible players
			//D = 5 possible plants
			//XOrigins = Player Origin
			//Looping through all players in this loop to see other drug origins!
			
			if(DrugPlant[T][D][0] != 0.0)
			{
				decl Float:DrugDist;
				DrugDist = GetVectorDistance(DrugPlant[T][D], TeleClient);
				if(DrugDist < 50 && DrugPlant[T][D][0] != 0.0)
				{
					if(Client == T)
					{
						CPrintToChat(Client, "{white}|RP-Drug|{darkgrey} -  You collected %d grams of drugs. You can sell drugs to any vendor.", DrugPlantWorth[T][D]);
						Grams[Client] += DrugPlantWorth[T][D];
						DestroyDrugPlant(T, D);
						AddCrime(Client, 100);
						return Plugin_Handled;
					}
					else
					{
						if(!IsCombine(Client) && !IsFirefighter(Client))
						{
							CPrintToChat(T, "{white}|RP-Drug|{darkgrey} -  A player has collected drugs from a plant of yours!");
							CPrintToChat(Client, "{white}|RP| -{grey} You've collected %d grams of drugs! Sell drugs for cash at any vendor!", DrugPlantWorth[T][D]);
							Grams[Client] += DrugPlantWorth[T][D];
							DestroyDrugPlant(T, D);
							AddCrime(Client, 200);
							return Plugin_Handled;
						}
						else if(IsCombine(Client) && !IsFirefighter(Client))
						{
							DestroyDrugPlant(T, D);
							CPrintToChat(T, "{white}|RP-Drug|{darkgrey} -  A cop has destroyed your drug plant!");
							CPrintToChat(Client, "{white}|RP| -{grey} You have received $100 for destroying a drug plant.");
							Money[Client] += 100;
							return Plugin_Handled;
						}
						else if(!IsCombine(Client) && IsFirefighter(Client))
						{
							DestroyDrugPlant(T, D);
							CPrintToChat(T, "{white}|RP-Drug|{darkgrey} -  A firefighter has destroyed your drug plant!");
							CPrintToChat(Client, "{white}|RP| -{grey} You have received $100 for destroying a drug plant.");
							Money[Client] += 100;
							return Plugin_Handled;
						}
					}
				}
			}
		}
		
		if(MoneyPrinterUse(Client, T, TeleClient))
			return Plugin_Handled;
	}
	
	//Return:
	return Plugin_Handled;
}

public Action:BankMenu1(Client)
{
	decl LevelUp;
	LevelUp = RoundToCeil(Pow(float(Wages[Client]), 3.0)) - Minutes[Client];
	
	new Handle:BankMain = CreateMenu(AtBank);
	SetMenuTitle(BankMain, "Bank\n=============\nCash: $%d\nBank: $%d\nWage: $%d\nRaise: %d min\n\nChecks: %d", Money[Client], Bank[Client], Wages[Client], LevelUp, NumChecks[Client]);
	
	AddMenuItem(BankMain, "1", "-|Withdraw|-");
	AddMenuItem(BankMain, "2", "-|Deposit|-");
	AddMenuItem(BankMain, "6", "-|Write a Check|-");
	AddMenuItem(BankMain, "3", "-|Cash in Check(s)|-");
	AddMenuItem(BankMain, "4", "-|Buy Check Book $10|-");
	SetMenuPagination(BankMain, 7);
	DisplayMenu(BankMain, Client, 20);
}

public Action:BankMenu2(Client)
{
	new Handle:BankMain = CreateMenu(AtBank);
	SetMenuTitle(BankMain, "Bank\n=============\nYour bank is in debt of:\n$%d", Bank[Client]);
	
	AddMenuItem(BankMain, "5", "-|Pay Back Debt|-");
	AddMenuItem(BankMain, "3", "-|Cash in Check(s)|-");
	AddMenuItem(BankMain, "4", "-|Buy Check Book $10|-");
	SetMenuPagination(BankMain, 7);
	DisplayMenu(BankMain, Client, 20);
}

public Action:TaxiMenu(Client)
{
	new Handle:menu = CreateMenu(TaxiMenu2);
	SetMenuTitle(menu, "Taxi Service");
	
	decl Handle:Taxi;
	Taxi = CreateKeyValues("Taxi");
	FileToKeyValues(Taxi, TaxiPath);
	
	decl Float:ClientOrigin2[3];
	GetClientAbsOrigin(Client, ClientOrigin2);
	
	for(new Y = 1; Y < 20; Y++)
	{
		decl String:IdNum[255], String:NameId[255], String:MenuString[255], String:InfoString[255];
		decl Float:Origin2[3];
		new Float:Dist;
		IntToString(Y, IdNum, 255);
		KvJumpToKey(Taxi, IdNum, false);
		KvGetString(Taxi, "Name", NameId, 255, ERROR);
		if(StrContains(NameId, "Error", false))
		{
			KvGetVector(Taxi, "Origin", Origin2);
			
			Dist = GetVectorDistance(ClientOrigin2, Origin2);
			
			if(Dist <= 1000)
			{
				Format(InfoString, 255, "%s,5", IdNum);
				Format(MenuString, 255, "%s - $5", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 1000) && (Dist <= 2000))
			{
				Format(InfoString, 255, "%s,10", IdNum);
				Format(MenuString, 255, "%s - $10", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 2000) && (Dist <= 3000))
			{
				Format(InfoString, 255, "%s,15", IdNum);
				Format(MenuString, 255, "%s - $15", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 3000) && (Dist <= 4000))
			{
				Format(InfoString, 255, "%s,20", IdNum);
				Format(MenuString, 255, "%s - $20", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 4000) && (Dist <= 5000))
			{
				Format(InfoString, 255, "%s,30", IdNum);
				Format(MenuString, 255, "%s - $30", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 5000) && (Dist <= 6000))
			{
				Format(InfoString, 255, "%s,35", IdNum);
				Format(MenuString, 255, "%s - $35", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 6000) && (Dist <= 7000))
			{
				Format(InfoString, 255, "%s,40", IdNum);
				Format(MenuString, 255, "%s - $40", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 8000) && (Dist <= 9000))
			{
				Format(InfoString, 255, "%s,45", IdNum);
				Format(MenuString, 255, "%s - $45", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if((Dist > 9000) && (Dist <= 10000))
			{
				Format(InfoString, 255, "%s,50", IdNum);
				Format(MenuString, 255, "%s - $50", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
			else if(Dist > 10000)
			{
				Format(InfoString, 255, "%s,55", IdNum);
				Format(MenuString, 255, "%s - $55", NameId);
				AddMenuItem(menu, InfoString, MenuString);
			}
		}
		KvRewind(Taxi);
	}
	CloseHandle(Taxi);
	
	SetMenuPagination(menu, 7);
	DisplayMenu(menu, Client, 20);
}

public TaxiMenu2(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info2[64];
		GetMenuItem(menu, param2, info2, sizeof(info2));
		decl String:Buffer[2][32];
		ExplodeString(info2, ",", Buffer, 2, 32);
		decl Cost;
		Cost = StringToInt(Buffer[1]);
		if(Money[param1] < Cost)
		{
			CPrintToChat(param1, "{white}|RP| -{grey} You do not have enough money for the taxi ride");
		}
		else
		{
			Money[param1] = Money[param1] - Cost;
			
			decl Handle:Taxi;
			decl Float:TaxiOrigin[3];
			Taxi = CreateKeyValues("Taxi");
			FileToKeyValues(Taxi, TaxiPath);
			KvJumpToKey(Taxi, Buffer[0], false);
			KvGetVector(Taxi, "Origin", TaxiOrigin);
			TeleportEntity(param1, TaxiOrigin, NULL_VECTOR, NULL_VECTOR);
			KvRewind(Taxi);
			CloseHandle(Taxi);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

public Action:ReEquip(Client)
{
	CPrintToChat(Client, "{white}|RP| -{grey} Press <escape> to access the resupply menu");
	new Handle:menu = CreateMenu(Equip);
	SetMenuTitle(menu, "Police Equipment/Resupply\n=============");
	AddMenuItem(menu, "68", "Resupply");
	SetMenuPagination(menu, 7);
	DisplayMenu(menu, Client, 15);
}

public Equip(Handle:menu, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info2[64];
		GetMenuItem(menu, param2, info2, sizeof(info2));
		if(StringToInt(info2) == 68 && IsCombine(Client))
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Resupplying weapons/health...");
			CreateTimer(0.5, RemoveWeapons, Client);
			CreateTimer(1.5, CombineWeapons, Client);
			EquipSpam[Client] = 1;
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

//Shift Key:
public Action:CommandSpeed(Client)
{
	//Cuffed:
	if(IsCuffed[Client])
	{
		
		//Print:
		CPrintToChat(Client, "{white}|RP| -{grey} You may not do this while cuffed");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl Ent;
	
	//Initialize:
	Ent = GetClientAimTarget(Client, false);
	
	//Check:
	if(Ent != -1)
	{
		if(OwnsCar[Client][CarEntity[Ent]] == 1)
		{
			decl String:ClassName[255];
			GetEdictClassname(Ent, ClassName, 255);
			if(StrEqual(ClassName, "prop_vehicle_airboat"))
			{
				decl Float:ClientOriginC[3], Float:EntOrigin[3];
				decl Float:Dist2;
				GetClientAbsOrigin(Client, ClientOriginC);
				GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", EntOrigin);
				Dist2 = GetVectorDistance(ClientOriginC, EntOrigin);
				
				if(Dist2 <= 100)
				{
					if(LockedCar[Ent] == 0)
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You unlock the car.");
						AcceptEntityInput(Ent, "Unlock", Client);
						LockedCar[Ent] = 1;
					}
					else
					{
						CPrintToChat(Client, "{white}|RP| -{grey} You lock the car.");
						AcceptEntityInput(Ent, "Lock", Client);
						LockedCar[Ent] = 0;
					}
				}
			}
		}
		
		//Declare:	
		decl Handle:Vault;
		decl Float:Dist, Float:ClientOrigin[3], Float:Origin[3];
		decl String:NPCId[255], String:Props[255], String:Buffer[5][32];
		
		//Vault:
		Vault = CreateKeyValues("Vault");
		
		//Retrieve:
		FileToKeyValues(Vault, NPCPath);
		
		//Loop:
		for(new X = 0; X < 100; X++)
		{
			
			//Convert:
			IntToString(X, NPCId, 255);
			
			//Load:
			LoadString(Vault, "1", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					if(lastpressedSH[Client] >= GetGameTime()-3)
					{
						//Save
						RobOrigin[Client] = Origin;
						//Rob:
						if(StrEqual(Job[Client], "Robber", false))
						{
							BeginRob(Client, "Banker", 300, 1, StringToInt(NPCId));
						}
						else
						{
							BeginRob(Client, "Banker", 150, 1, StringToInt(NPCId));
						}
					}
					else
					{
						CPrintToChat(Client, "{white}|RP| -{grey} Press Sprint again to start robbery");
					}
					lastpressedSH[Client] = GetGameTime();
				}
			}
			
			//Load:
			LoadString(Vault, "2", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					if(lastpressedSH[Client] >= GetGameTime()-3)
					{
						//Save
						RobOrigin[Client] = Origin;
						
						//Rob:
						if(StrEqual(Job[Client], "Robber", false))
						{
							BeginRob(Client, "Vendor", 200, 2, StringToInt(NPCId));
						}
						else
						{
							BeginRob(Client, "Vendor", 100, 2, StringToInt(NPCId));
						}
					}
					else
					{
						CPrintToChat(Client, "{white}|RP| -{grey} Press Sprint again to start robbery");
					}
					lastpressedSH[Client] = GetGameTime();
				}
			}
			
			//Load:
			LoadString(Vault, "3", NPCId, "Null", Props);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 5, 32);
				
				//Origin:
				GetClientAbsOrigin(Client, ClientOrigin);
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				//Distance:
				Dist = GetVectorDistance(ClientOrigin, Origin);
				
				//Check:
				if(Dist <= 150)
				{
					if(lastpressedSH[Client] >= GetGameTime()-3)
					{
						//Save
						RobOrigin[Client] = Origin;
						
						//Rob:
						BeginRob(Client, "Auctionator", 100, 2, StringToInt(NPCId));
					} else
					{
						CPrintToChat(Client, "{white}|RP| -{grey} Press Sprint again to start robbery");
					}
					lastpressedSH[Client] = GetGameTime();
				}
			}
		}
		
		//Close:
		CloseHandle(Vault);
	}
	
	//Return:
	return Plugin_Handled;
}

public Action:Command_Bank(Client, Args)
{
	BankMenu1(Client);
	return Plugin_Handled;
}
//Information:
public Plugin:myinfo =
{
	
	//Initialize:
	name = "Comax Roleplay Mod + Roleplay_Remixed",
	author = "Reloaded(Comax RP Mod) & EasSide[-ZZ-] (Roleplay_Remixed)",
	description = "Best roleplay mods combined.",
	version = RPVERSION,
	url = "matisuploads.com.ar"
}

//Map Start:
public OnMapStart()
{
	/************** Comax Mod **************/
	ComaxMapStart();
	//LOADVIPDOORS GETS CALLED AT THE END OF THIS FORWARD!!!!
		
	g_fTimer = 0.0;
	g_iMaxClients = GetMaxClients();
	PrecacheSound(g_sSound, true);
	//Team Names:
	if(GetConVarInt(FindConVar("mp_teamplay")) == 1)
	{
		for(new X = 0; X < GetMaxEntities(); X++)
		{
			if(IsValidEntity(X))
			{
				decl String:Name[255];
				GetEdictClassname(X, Name, sizeof(Name));
				if(StrEqual(Name, "team_manager", true))
				{
					decl TeamIndex;
					TeamIndex = GetEntProp(X, Prop_Send, "m_iTeamNum");
					//Combines:
					if(TeamIndex == 2)
					{
						decl String:TeamName[255];
						GetConVarString(CombineTeam, TeamName, sizeof(TeamName));
						SetEntPropString(X, Prop_Send, "m_szTeamname", TeamName);
						ChangeEdictState(X, GetEntSendPropOffs(X, "m_szTeamname", true));
					}
					//Rebels:
					else if(TeamIndex == 3)
					{
						decl String:TeamName[255];
						GetConVarString(RebelTeam, TeamName, sizeof(TeamName));
						SetEntPropString(X, Prop_Send, "m_szTeamname", TeamName);
						ChangeEdictState(X, GetEntSendPropOffs(X, "m_szTeamname", true));
					}
				}
			}
		}
	}
	
	//Multi-Map Capable
	decl String:MapName[128];
	GetCurrentMap(MapName, 128);
	WeaponOffset = FindSendPropOffs("CHL2MP_Player", "m_hMyWeapons");
	decl String:NewDir[255];
	Format(NewDir, sizeof(NewDir), "addons/sourcemod/data/roleplay/%s/", MapName);
	CreateDirectory(NewDir, 511);
	
	//Saving:
	BuildPath(Path_SM, SavePath, 64, "data/roleplay/save.txt");
	
	//Starter Pack:
	BuildPath(Path_SM, StarterPath, 64, "data/roleplay/starterpack.txt");
	
	//Rules
	BuildPath(Path_SM, RulesPath, 64, "data/roleplay/rules.txt");
	
	//Player of the Week Database:
	BuildPath(Path_SM, PlayerWeekPath, 128, "data/roleplay/playeroftheweek.txt");
	/*
	//Donator Models Database:
	BuildPath(Path_SM, ModelsPath, 128, "data/roleplay/donatormodels.txt");
	
	decl Handle:Models;
	Models = CreateKeyValues("Donator Models");
	FileToKeyValues(Models, ModelsPath);
	
	decl String:ModelNumber[255], String:ModelMDL[255];
	for(new X = 1; X < 50; X++)
	{
		IntToString(X, ModelNumber, 255);
		LoadString(Models, "model", ModelNumber, "Null", ModelMDL);
		if(!StrEqual(ModelMDL, "Null"))
		{
			PrecacheModel(ModelMDL, true);
		}
	}
	CloseHandle(Models);
	*/
	//Name DB:
	BuildPath(Path_SM, NamePath, 64, "data/roleplay/names.txt");
	
	
	decl String:GamblingString[128];
	Format(GamblingString, sizeof(GamblingString), "data/roleplay/%s/gambling.txt", MapName);
	BuildPath(Path_SM, RouletteOrigins, 128, GamblingString);
	
	//Gambling:
	BuildPath(Path_SM, RoulettePath, 128, "data/roleplay/roulette.txt");
	LoadWheel();
	
	//Job DB:
	BuildPath(Path_SM, JobPath, 64, "data/roleplay/jobs.txt");
	BuildPath(Path_SM, JobAttributesPath, 64, "data/roleplay/jobs_setup.txt");
	
	//Weapons:
	BuildPath(Path_SM, WeaponidsPath, 64, "data/roleplay/weaponids.txt");
	
	if(FileExists(JobPath) == false) SetFailState("-|SM] ERROR: Missing file '%s'", JobPath);
	if(FileExists(WeaponidsPath) == false) SetFailState("-|SM] ERROR: Missing file '%s'", WeaponidsPath);
	if(FileExists(JobAttributesPath) == false) SetFailState("-|SM] ERROR: Missing file '%s'", JobAttributesPath);
	
	decl Handle:Weapons;
	Weapons = CreateKeyValues("Vault");
	FileToKeyValues(Weapons, WeaponidsPath);
	
	decl String:Value[255], String:WeaponNum[255];
	for(new X = 1; X < 26; X++)
	{
		IntToString(X, WeaponNum, 255);
		LoadString(Weapons, "WeaponsID", WeaponNum, "Null", Value);
		if(!StrEqual(Value, "Null"))
		{
			WeaponArray[X] = Value;
		}
	}
	CloseHandle(Weapons);
	
	//NPCS DB: 
	decl String:FinalPath[64];
	Format(FinalPath, sizeof(FinalPath), "data/roleplay/%s/npcs.txt", MapName);
	BuildPath(Path_SM, NPCPath, 128, FinalPath);
	CreateTimer(1.0, DrawNPCs);
	
	//Config DB:
	decl String:FinalPath2[128];
	Format(FinalPath2, sizeof(FinalPath2), "data/roleplay/%s/config.txt", MapName);
	BuildPath(Path_SM, ConfigPath, 128, FinalPath2);
	
	//Lock DB:
	decl String:FinalPath3[128];
	Format(FinalPath3, sizeof(FinalPath3), "data/roleplay/%s/lock.txt", MapName);
	BuildPath(Path_SM, LockPath, 128, FinalPath3);
	
	//Config DB:
	BuildPath(Path_SM, ItemPath, 64, "data/roleplay/items.txt");
	if(FileExists(ItemPath) == false) SetFailState("-|SM] ERROR: Missing file '%s'", ItemPath);
	
	//Config DB:
	BuildPath(Path_SM, DownloadPath, 64, "data/roleplay/download.txt");
	
	//Opened:
	//if(SaveVault != INVALID_HANDLE) CloseHandle(SaveVault);
	SaveVault = CreateKeyValues("Vault");
	//PrintToServer("\n\n\n\n\n'%s -- %d'\n\n\n\n\n", SaveVault, SaveVault);
	if(!FileToKeyValues(SaveVault, SavePath)) SetFailState("-|SM] ERROR: Missing File '%s'", SavePath);
	
	//================================
	//Check DBs:
	decl String:FinalPath4[128];
	Format(FinalPath4, sizeof(FinalPath4), "data/roleplay/%s/notice.txt", MapName);
	BuildPath(Path_SM, Noticeadd, 128, FinalPath4);
	
	for(new X = 0; X < MAXDOORS; X++)
	{
		Notice[X] = "null";
	}
	
	decl String:FinalPath5[128];
	Format(FinalPath5, sizeof(FinalPath5), "data/roleplay/%s/doors.txt", MapName);
	BuildPath(Path_SM, DoorPathadd, 128, FinalPath5);
	
	//Door Buy DB:
	decl String:FinalPath6[128];
	Format(FinalPath6, sizeof(FinalPath6), "data/roleplay/%s/doorsbuyable.txt", MapName);
	BuildPath(Path_SM, DoorBuyPath, 128, FinalPath6);
	//if(FileExists(DoorBuyPath) == false) PrintToConsole(0, "[SM] ERROR: Missing file '%s'", DoorBuyPath);
	
	//No kill Zones:
	decl String:FinalPath7[128];
	Format(FinalPath7, sizeof(FinalPath7), "data/roleplay/%s/zones.txt", MapName);
	BuildPath(Path_SM, ZonesPath, 128, FinalPath7);
	
	decl String:FinalPath7b[128];
	Format(FinalPath7b, sizeof(FinalPath7b), "data/roleplay/%s/crimezones.txt", MapName);
	BuildPath(Path_SM, CrimeZonesPath, 128, FinalPath7b);
	
	//Taxi:
	decl String:FinalPath8[128];
	Format(FinalPath8, sizeof(FinalPath8), "data/roleplay/%s/taxi.txt", MapName);
	BuildPath(Path_SM, TaxiPath, 128, FinalPath8);
	
	//Notices DB:
	decl String:FinalPathN[128];
	Format(FinalPathN, sizeof(FinalPathN), "data/roleplay/%s/notice.txt", MapName);
	BuildPath(Path_SM, NoticePath, 128, FinalPathN);
	LoadM();
	
	//Cars DB:
	decl String:FinalPathCar[128];
	Format(FinalPathCar, sizeof(FinalPathCar), "data/roleplay/%s/cars.txt", MapName);
	BuildPath(Path_SM, CarPath, 128, FinalPathCar);
	
	for(new C = 1; C <= 2000; C++)
	{
		CarEntity[C] = 0;
		LockedCar[C] = 0;
	}
	CreateTimer(2.0, CreateCars);
	
	//Door DB:
	decl String:FinalPathDoorc[128];
	Format(FinalPathDoorc, sizeof(FinalPathDoorc), "data/roleplay/%s/customdoors.txt", MapName);
	BuildPath(Path_SM, DoorPath, 128, FinalPathDoorc);
	
	CreateTimer(2.0, CreateDoors);
	
	//================================
	
	decl Float:UnknownCoordTest[3] = {69.0, 69.0, 69.0};
	
	//Declare:
	decl Handle:Vault;
	decl String:Key[32];
	
	//Initialize:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, ConfigPath);
	
	AnyJail = 0;
	AnySui1 = 0;
	AnySui2 = 0;
	AnyExit = 0;
	AnyVip = 0;
	AnyAfk = 0;
	
	GarbageAmount = 0;
	
	//Load:
	for(new X = 1; X <= 10; X++)
	{
		
		//Convert:
		IntToString(X, Key, 32);
		
		//Find:
		KvJumpToKey(Vault, "Jail", false);
		KvGetVector(Vault, Key, JailOrigin[X], UnknownCoordTest);
		KvRewind(Vault);
		
		if(JailOrigin[X][0] != 69.0)
		{
			AnyJail = 1;
		}
	}
	
	KvJumpToKey(Vault, "General", false);
	KvGetVector(Vault, "vipjail", VIPJailOrigin, UnknownCoordTest);
	if(VIPJailOrigin[0] != 69.0)
	{
		AnyVip = 1;
	}
	KvGetVector(Vault, "exit", ExitOrigin, UnknownCoordTest);
	if(ExitOrigin[0] != 69.0)
	{
		AnyExit = 1;
	}
	KvGetVector(Vault, "suicide", OrderOrigin, UnknownCoordTest);
	if(OrderOrigin[0] != 69.0)
	{
		AnySui1 = 1;
	}
	KvGetVector(Vault, "suicide2", OrderOrigin2, UnknownCoordTest);
	if(OrderOrigin2[0] != 69.0)
	{
		AnySui2 = 1;
	}
	KvGetVector(Vault, "afkroom", AFKOrigin, UnknownCoordTest);
	if(AFKOrigin[0] != 69.0)
	{
		AnyAfk = 1;
	}
	KvGetVector(Vault, "garbage", GarbageOrigin, UnknownCoordTest);
	if(GarbageOrigin[0] != 69.0)
	{
		AnyGarbage = 1;
	}
	
	//Close:
	CloseHandle(Vault);
	
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, LockPath);
	decl String:ReferenceString[255], String:ItemId[255];
	
	//Loop:
	for(new X = 0; X < 2050; X++)
	{
		//Convert:
		IntToString(X, ItemId, sizeof(ItemId));
		//Load:
		LoadString(Vault, "1", ItemId, "Null", ReferenceString);
		//Check:
		if(!StrEqual(ReferenceString, "Null"))
		{
			DoorLocked[X] = true;
		}
	}
	
	//Loop:
	for(new X = 0; X < 2000; X++)
	{
		//Convert:
		IntToString(X, ItemId, sizeof(ItemId));
		//Load:
		LoadString(Vault, "2", ItemId, "Null", ReferenceString);
		//Check:
		if(!StrEqual(ReferenceString, "Null"))
		{
			DoorLocks[X] = StringToInt(ReferenceString);
		}
	}
	//Misc:
	LoadItems();
	//Clear Buffers:
	for(new X = 0; X < 3; X++) for(new Y = 0; Y < 100; Y++) RobTimerBuffer[X][Y] = GetGameTime();
	
	//Auto Downloader
	new Handle:fileh = OpenFile(DownloadPath, "r");
	new String:buffer[256];
	while (ReadFileLine(fileh, buffer, sizeof(buffer)))
	{
		new len = strlen(buffer);
		if (buffer[len-1] == '\n')
		{
			buffer[--len] = '\0';
		}
		
		if (FileExists(buffer))
		{
			AddFileToDownloadsTable(buffer);
		}
		
		if(StrContains(buffer, ".mdl", false) != -1)
		{
			PrecacheModel(buffer, true);
		}
		
		if (IsEndOfFile(fileh))
		{
			break;
		} 
	}
	
	//Models:
	PrecacheModel("models/airboat.mdl", true);
	PrecacheModel("models/buggy.mdl", true);
	PrecacheModel("models/alyx.mdl", true);
	PrecacheModel("models/eli.mdl", true);
	PrecacheModel("models/breen.mdl", true);
	PrecacheModel("models/kleiner.mdl", true);
	PrecacheModel("models/barney.mdl", true);
	PrecacheModel("models/mossman.mdl", true);
	PrecacheModel("models/player/snake.mdl", true);
	PrecacheModel("models/monk.mdl", true);
	PrecacheModel("models/gman.mdl", true);
	PrecacheModel("models/combine_soldier.mdl", true);
	PrecacheModel("models/Humans/Group03m/male_07.mdl", true);
	PrecacheModel("models/Humans/Group01/male_02.mdl", true);
	PrecacheModel("models/Humans/Group02/Male_04.mdl", true);
	PrecacheModel("models/vortigaunt.mdl", true);
	
	//Money Models:
	PrecacheModel("models/money/broncoin.mdl", true);
	PrecacheModel("models/money/silvcoin.mdl", true);
	PrecacheModel("models/money/goldcoin.mdl", true);
	PrecacheModel("models/money/note3.mdl", true);
	PrecacheModel("models/money/note2.mdl", true);
	PrecacheModel("models/money/note.mdl", true);
	PrecacheModel("models/money/goldbar.mdl", true);
	PrecacheModel("models/legobrick.mdl", true);
	
	//Garbage Models:
	PrecacheModel("models/props_junk/garbage_glassbottle001a.mdl", true);
	PrecacheModel("models/props_junk/garbage_metalcan001a.mdl", true);
	PrecacheModel("models/props_junk/garbage_plasticbottle003a.mdl", true);
	PrecacheModel("models/props_junk/garbage_milkcarton001a.mdl", true);
	PrecacheModel("models/props_junk/garbage_takeoutcarton001a.mdl", true);
	PrecacheModel("models/props_junk/garbage_bag001a.mdl", true);
	PrecacheModel("models/props_junk/garbage_newspaper001a.mdl", true);
	PrecacheModel("models/props_junk/garbage_metalcan002a.mdl", true);
	
	
	//Plant:
	PrecacheModel("models/props_lab/cactus.mdl", true);
	g_BeamSprite = PrecacheModel("materials/sprites/laser.vmt", true);
	g_HaloSprite = PrecacheModel("materials/sprites/halo01.vmt", true);
	Smoke = PrecacheModel("effects/redflare.vmt", true);
	Water = PrecacheModel("materials/sprites/blueglow2.vmt", true);
	LaserCache = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	
	//Printer
	PrecacheModel("models/props_lab/reciever01a.mdl", true);
	
	
	ServerCommand("sm_refreshzones");
	ServerCommand("sm_refreshcrimezones");
	
	//COMAX:
	LoadVIPDoors(); //We want to load after the paths have been defined.
}

//Map End:
public OnMapEnd()
{
	
	CloseHandle(SaveVault);	
	ComaxMapEnd();
}


public Action:Command_pushplayer(Client,Args)
{
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	
	if(Ent < 33 && Ent > 0 && !IsCuffed[Client])
	{
		decl Float:ClientOrigin[3], Float:EntOrigin[3], Float:Dist;
		
		//Initialize:
		GetClientAbsOrigin(Client, ClientOrigin);
		GetClientAbsOrigin(Ent, EntOrigin);
		Dist = GetVectorDistance(ClientOrigin, EntOrigin);
		
		if(Dist <= 100)
		{
			decl Float:Push[3];
			decl Float:EyeAngles[3];
			GetClientEyeAngles(Client, EyeAngles);
			Push[0] = (500.0 * Cosine(DegToRad(EyeAngles[1])));
			Push[1] = (500.0 * Sine(DegToRad(EyeAngles[1])));
			Push[2] = (-50.0 * Sine(DegToRad(EyeAngles[0])));
			TeleportEntity(Ent, NULL_VECTOR, NULL_VECTOR, Push);
		}
	}
	return Plugin_Handled;
}

public Action:Command_getLocks(Client, Args)
{
	decl DoorEnt;
	decl String:ClassName[255];
	//Initialize:
	DoorEnt = GetClientAimTarget(Client, false);
	//ClassName:
	GetEdictClassname(DoorEnt, ClassName, 255);

	if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
	{
		decl Handle:BuyDoor;
		BuyDoor = CreateKeyValues("Buyable Doors");
		decl String:Owner[255];
		KvGetString(BuyDoor, "Owner", Owner, 255, ERROR);
		decl String:Ste[255];
		GetClientAuthString(Client, Ste, 255);
		if(StrEqual(Ste, Owner, false))
		{
			if(DoorLocks[DoorEnt] > 0)
			{
				Item[Client][100] += DoorLocks[DoorEnt];
				DoorLocks[DoorEnt] = 0;
				KvRewind(BuyDoor);
				CloseHandle(BuyDoor);
				Save(Client);
				return Plugin_Handled;
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} There must be a lock on the door!");
				return Plugin_Handled;
			}
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Access Denied.");
			return Plugin_Handled;
		}
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Target!");
		return Plugin_Handled;
	}
}

//Initation:
public OnPluginStart()
{
	SolidGroup = FindSendPropOffs("CBaseEntity", "m_CollisionGroup");
	
	
	
	//RESTRICTION TO RUN ON SERVER - Comax Mod
	new String:g_ServerIp [32];
	new String:g_ServerPort [16];
	new String:FIP [23];
	new Handle:cvar = FindConVar( "hostip" );
	new hostip = GetConVarInt( cvar );
	FormatEx( g_ServerIp, sizeof(g_ServerIp), "%u.%u.%u.%u",
	(hostip >> 24) & 0x000000FF, (hostip >> 16) & 0x000000FF, (hostip >> 8) & 0x000000FF, hostip & 0x000000FF );
	
	cvar = FindConVar( "hostport" );
	GetConVarString( cvar, g_ServerPort, sizeof(g_ServerPort) );
	
	Format(FIP, sizeof(FIP), "%s:%s", g_ServerIp, g_ServerPort);
	
	if(StrEqual(FIP, Ò<yourserveriphere>Ó))
	{
		PrintToServer("[Comax] Starting load process...");
		AllowedServer = 1;
	} else {
		
		PrintToServer("\n\n\n\n\n[Comax] This server is NOT allowed to run the Comax RP Mod. Unloading... %s\n\n\n\n\n\n", FIP);
		AllowedServer = 0;
	}
	
	CreateDirectory("addons/sourcemod/A_COMAX_ERRORS", 3);
	BuildPath(Path_SM,COMAX_ERRORS, sizeof(COMAX_ERRORS), "A_COMAX_ERRORS/Errors.txt");
	
	//If we're debugging allow anywhere
	new vdebug;
	vdebug = DEBUG;
	if(vdebug == 1) AllowedServer = 1;
	
	if(AllowedServer == 0)
	{	
		LogToFile(COMAX_ERRORS, "Comax RolePlay Mod cannot run on ip %s. Please contact Reloaded.", FIP);
		SetFailState("\n\n\n Comax RolePlay Mod cannot run on ip %s. Please contact Reloaded. \n\n\n", FIP);
		return; // This should never happen.
	}
	
	
	/* * * Comax RolePlay Mod Related * * */
	ComaxStart();
	startConnection();
	/*			     Comax  			 */
	
	
	//Comax:
	RegConsoleCmd("sm_vip", CommandVipSwitch, "Basic VIP");
	RegConsoleCmd("sm_svip", CommandSVipSwitch, "Super VIP");
	cv_printer_max = CreateConVar("sm_printer_max_worth", "7500", "Set how much money a printer can make.", FCVAR_PLUGIN, true, 0.0);
	
	//Comax: Random
	
	//CreateDirectory("addons/sourcemod/data/roleplay/Comax/Logs", 3);
	h_showhud = CreateConVar("sm_showhud", "1", "RP HUD Toggler. 1 = on. 0 = off.", FCVAR_PLUGIN);
	RegAdminCmd("sm_restartmap", commandrestartmap, ADMFLAG_CUSTOM5,"Restart the map");
	RegAdminCmd("sm_restartmap_eas", Command_RestartMap, ADMFLAG_CUSTOM3, "Quick restart map");
	
	//Comax: Restart stability
	
	
	
	//Comax: Debug
	RegAdminCmd("sm_jail", CommandDebugJail, ADMFLAG_ROOT, "set crime to 3000, cuff and jail. testing purposes ONLY.");
	
	
	//Comax RolePlay Mod - General
	RegConsoleCmd("sm_about", Command_ModAbout);
	

	//Rules
	//RegConsoleCmd("sm_rules", Command_Rules, "Rules List");
	RegConsoleCmd("sm_rphelp", Command_Help, "Roleplay Remixed Guide");
	
	//Admin Commands:
	/* NICK FLAGS
	RegAdminCmd("sm_createjob", CommandCreateJob, ADMFLAG_CUSTOM6, "<Id> <Job> <0|1> - Creates a job (public|admin)");
	RegAdminCmd("sm_bank", Command_Bank, ADMFLAG_CUSTOM2, "Remote Access to the Bank Menus");
	RegAdminCmd("sm_removejob", CommandRemoveJob, ADMFLAG_CUSTOM6, "<Id> <0|1> - Removes a job from the database (public|admin)");
	RegAdminCmd("sm_joblist", CommandListJobs, ADMFLAG_CUSTOM1, "- Lists jobs from the database");
	RegAdminCmd("sm_employ", CommandEmploy, ADMFLAG_CUSTOM2, "<Name> <Id> - Employs admin-only jobs");
	RegAdminCmd("sm_setlevel", Command_SetExpLevel, ADMFLAG_CUSTOM3, "<Name> <Level> - Sets the Level of a player");
	RegAdminCmd("sm_setplanted", Command_SetPlanted, ADMFLAG_CUSTOM3, "<Name> <Amount> - Sets the Total Plants of a player");
	RegAdminCmd("sm_setcuffs", Command_SetCuffs, ADMFLAG_CUSTOM3, "<Name> <Amount> - Sets the Cuff Count of a player");
	RegAdminCmd("sm_dlcheck", CommandDLCHECK, ADMFLAG_CUSTOM2, "<Name> <Id> - Employs admin-only jobs");  
	RegAdminCmd("sm_crime", CommandCrime, ADMFLAG_CUSTOM2, "<Name> <Crime #> - Sets crime");
	RegAdminCmd("sm_name", CommandName, ADMFLAG_CUSTOM2, "<Name> <New Name> - Sets name");
	RegAdminCmd("sm_createitem", CommandCreateItem, ADMFLAG_CUSTOM6, "<Id> <Name> <Type> <Variable> <cost> - Creates an Item");
	RegAdminCmd("sm_removeitem", CommandRemoveItem, ADMFLAG_CUSTOM6, "<Id> - Removes an Item");
	RegConsoleCmd("sm_itemlist", CommandListItems, "- Lists items from the database");
	RegAdminCmd("sm_noticelist", CommandListNotices, ADMFLAG_CUSTOM1, "- Lists notices from the database");
	RegAdminCmd("sm_additem", CommandAddItem, ADMFLAG_CUSTOM3, "<Name> <Id> <Amount> - Gives an item to a player");
	RegAdminCmd("sm_takeitem", CommandTakeItem, ADMFLAG_CUSTOM3, "<Name> <Id> <Amount> - Takes an item to a player");
	RegAdminCmd("sm_addvendoritem", CommandAddVendorItem, ADMFLAG_CUSTOM6, "<Vendor Id> <Item Id> - Add's Item to a vendor");
	RegAdminCmd("sm_removevendoritem", CommandRemoveVendorItem, ADMFLAG_CUSTOM6, "<Vendor Id> <Item Id> - Remove's Item from a vendor");
	RegAdminCmd("sm_status", CommandStatus, ADMFLAG_CUSTOM1, "- Lists status of all players");
	RegAdminCmd("sm_setmoneybank", Command_setMoneyBank, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Sets the Bank of the Client");
	RegAdminCmd("sm_setmoney", Command_setMoney, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Sets the money of the Client");
	RegAdminCmd("sm_addmoneybank", Command_addMoneyBank, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Adds money to the Bank of the Client");
	RegAdminCmd("sm_addmoney", Command_addMoney, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Adds money to the Client");
	RegAdminCmd("sm_setincome", Command_SetIncome,ADMFLAG_CUSTOM1, "- <Name> <Amount> - Sets the income of the Client");
	RegAdminCmd("sm_listitem", Command_listItems, ADMFLAG_CUSTOM1, "- <Name> - Lists all Items the player owns");
	RegAdminCmd("sm_getitem", CommandRemoveItemPly, ADMFLAG_CUSTOM3, "<Name> <Id> <Amount> - Removes an item from a player");
	RegAdminCmd("sm_setpropsused", Command_SetUsage, ADMFLAG_CUSTOM2, "<Target> <Amount> - Sets used props.");
	RegAdminCmd("sm_bountyall", Command_bountyall, ADMFLAG_CUSTOM1, ""); 
	RegAdminCmd("sm_boersenschluss", Command_boersenschluss, ADMFLAG_CUSTOM1, ""); 
	RegAdminCmd("sm_boersencrash", Command_boersencrash, ADMFLAG_CUSTOM1, ""); 
	RegAdminCmd("sm_gpsbug", Command_setGPSBug, ADMFLAG_CUSTOM1, "");
	RegConsoleCmd("sm_kickdoor", CommandKickOpen, "Cops can kick open doors");
	*/
	RegAdminCmd("sm_setlevel", Command_SetExpLevel, ADMFLAG_CUSTOM3, "<Name> <Level> - Sets the Level of a player");
	RegAdminCmd("sm_createjob", CommandCreateJob, ADMFLAG_CUSTOM6, "<Id> <Job> <0|1> - Creates a job (public|admin)");
	RegAdminCmd("sm_removejob", CommandRemoveJob, ADMFLAG_CUSTOM6, "<Id> <0|1> - Removes a job from the database (public|admin)");
	RegAdminCmd("sm_joblist", CommandListJobs, ADMFLAG_CUSTOM6, "- Lists jobs from the database"); //CHANGED TO CUSTOM 5 AS OF CMXMOD
	RegAdminCmd("sm_employ", CommandEmploy, ADMFLAG_CUSTOM6, "<Name> <Id> - Employs admin-only jobs");
	RegAdminCmd("sm_dlcheck", CommandDLCHECK, ADMFLAG_CUSTOM1, "Checks DL stuff");  
	RegAdminCmd("sm_crime", CommandCrime, ADMFLAG_CUSTOM1, "<Name> <Crime #> - Sets crime");
	RegAdminCmd("sm_name", CommandName, ADMFLAG_CUSTOM1, "<Name> <New Name> - Sets name");
	RegAdminCmd("sm_createitem", CommandCreateItem, ADMFLAG_CUSTOM6, "<Id> <Name> <Type> <Variable> <cost> - Creates an Item");
	RegAdminCmd("sm_removeitem", CommandRemoveItem, ADMFLAG_CUSTOM6, "<Id> - Removes an Item");
	RegAdminCmd("sm_itemlist", CommandListItems, ADMFLAG_CUSTOM1, "- Lists items from the database");
	RegAdminCmd("sm_noticelist", CommandListNotices, ADMFLAG_CUSTOM1, "- Lists notices from the database");
	RegAdminCmd("sm_additem", CommandAddItem, ADMFLAG_CUSTOM3, "<Name> <Id> <Amount> - Gives an item to a player");
	RegAdminCmd("sm_takeitem", CommandTakeItem, ADMFLAG_CUSTOM3, "<Name> <Id> <Amount> - Takes an item to a player");
	RegAdminCmd("sm_addvendoritem", CommandAddVendorItem, ADMFLAG_CUSTOM6, "<Vendor Id> <Item Id> - Add's Item to a vendor");
	RegAdminCmd("sm_removevendoritem", CommandRemoveVendorItem, ADMFLAG_CUSTOM6, "<Vendor Id> <Item Id> - Remove's Item from a vendor");
	RegAdminCmd("sm_status", CommandStatus, ADMFLAG_CUSTOM1, "- Lists status of all players");
	RegAdminCmd("sm_setmoneybank", Command_setMoneyBank, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Sets the Bank of the Client");
	RegAdminCmd("sm_setmoney", Command_setMoney, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Sets the money of the Client");
	RegAdminCmd("sm_addmoneybank", Command_addMoneyBank, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Adds money to the Bank of the Client");
	RegAdminCmd("sm_addmoney", Command_addMoney, ADMFLAG_CUSTOM1, "- <Name> <Amount> - Adds money to the Client");
	RegAdminCmd("sm_setincome", Command_SetIncome,ADMFLAG_CUSTOM1, "- <Name> <Amount> - Sets the income of the Client");
	RegAdminCmd("sm_listitem", Command_listItems, ADMFLAG_CUSTOM1, "- <Name> - Lists all Items the player owns");
	RegAdminCmd("sm_getitem", CommandRemoveItemPly, ADMFLAG_CUSTOM3, "<Name> <Id> <Amount> - Removes an item from a player");
	RegAdminCmd("sm_bountyall", Command_bountyall, ADMFLAG_CUSTOM1, ""); 
	RegAdminCmd("sm_boersenschluss", Command_boersenschluss, ADMFLAG_CUSTOM1, ""); 
	RegAdminCmd("sm_boersencrash", Command_boersencrash, ADMFLAG_CUSTOM1, ""); 
	RegAdminCmd("sm_gpsbug", Command_setGPSBug, ADMFLAG_CUSTOM1, "");
	
	//RegConsoleCmd("sm_collectlocks", Command_getLocks, "Collect locks from a door");
	
	//THIS COMMAND BELOW HAS BEEN DISABLE BECAUSE OF SECRUITY REASONS
	//RegAdminCmd("sm_initnotice", Command_initnotice, ADMFLAG_CUSTOM1, ""); 
	
	RegAdminCmd("sm_setnotice", CommandSetOwner, ADMFLAG_CUSTOM3, "<ent> <Name> - Sets the main owner of a door");
	RegAdminCmd("sm_looknotice", CommandSetOwner2, ADMFLAG_CUSTOM3, "<0|1> <Name> - Sets the main owner of a door");
	
	RegAdminCmd("sm_createnpc", CommandCreateNPC, ADMFLAG_CUSTOM6, "<id> <NPC> <type> - Types: 0 = Job Lister, 1 = Banker, 2 = Vendor");
	RegAdminCmd("sm_removenpc", CommandRemoveNPC, ADMFLAG_CUSTOM6, "<id> - Removes an NPC from the database");
	RegAdminCmd("sm_npclist", CommandListNPCs, ADMFLAG_CUSTOM1, "- Lists all the NPCs in the database");
	RegAdminCmd("sm_npcnotice", CommandSetNotice, ADMFLAG_CUSTOM1, "- Lists all the NPCs in the database");
	RegAdminCmd("sm_npcwho", CommandNPCWho, ADMFLAG_CUSTOM1, "- Lists all the NPCs in the database");
	
	RegAdminCmd("sm_addjail", CommandAddJail, ADMFLAG_CUSTOM3, "<Id>");
	RegAdminCmd("sm_removejail", CommandRemJail, ADMFLAG_CUSTOM3, "<Id>");
	RegAdminCmd("sm_listjails", CommandListJail, ADMFLAG_CUSTOM3, "List Jail Cells");
	RegAdminCmd("sm_setexit", CommandSetExit, ADMFLAG_CUSTOM3, "Set exit coord.");
	RegAdminCmd("sm_setsuicide", CommandSetSui, ADMFLAG_CUSTOM3, "Set suicide coord.");
	RegAdminCmd("sm_removesuicide", CommandRemSui, ADMFLAG_CUSTOM3, "Set suicide coord.");
	RegAdminCmd("sm_listsuicide", CommandListSui, ADMFLAG_CUSTOM3, "List the 2 suicide coords.");
	RegAdminCmd("sm_setvipjail", CommandSetVip, ADMFLAG_CUSTOM3, "Set vipjail coord.");
	RegAdminCmd("sm_setafk", CommandSetAfk, ADMFLAG_CUSTOM3, "Set afk coord.");
	RegAdminCmd("sm_setgarbagezone", CommandSetGarbage, ADMFLAG_CUSTOM3, "Set garbage coord.");
	RegAdminCmd("sm_setdooramount", CommandDoorAmount, ADMFLAG_CUSTOM3, "- <Amount> - Set a door up so its buyable");
	RegAdminCmd("sm_resetdoor", CommandResetDoor, ADMFLAG_CUSTOM3, "- Reset a door so then its buyable. Owner of this house will lose keys");
	RegAdminCmd("sm_deletedoor", CommandDeleteDoor, ADMFLAG_CUSTOM3, "- Delete a door totally from being buyable or sellable");
	RegAdminCmd("sm_doorrights", CommandDoorRight, ADMFLAG_CUSTOM3, "- If a person is a cop, they will receive the default cop doors.");
	
	RegAdminCmd("sm_createnokillzone", CommandCreateNokill, ADMFLAG_CUSTOM3, "- Create No Kill Zone");
	RegAdminCmd("sm_removenokillzone", CommandRemoveNokill, ADMFLAG_CUSTOM3, "- Remove No Kill Zone");
	RegAdminCmd("sm_listnokillzones", CommandListZone, ADMFLAG_CUSTOM3, "- List No Kill Zones that are used");
	RegAdminCmd("sm_refreshzones", CommandRefreshZones, ADMFLAG_CUSTOM3, "- Refresh No Kill Zones");
	
	RegAdminCmd("sm_createnocrimezone", CommandCreateNocrime, ADMFLAG_CUSTOM3, "- Create No Crime Zone");
	RegAdminCmd("sm_removenocrimezone", CommandRemoveNocrime, ADMFLAG_CUSTOM3, "- Remove No Crime Zone");
	RegAdminCmd("sm_listnocrimezones", CommandListCrimeZone, ADMFLAG_CUSTOM3, "- List No Crime Zones that are used");
	RegAdminCmd("sm_refreshcrimezones", CommandRefreshCrimeZones, ADMFLAG_CUSTOM3, "- Refresh No Crime Zones");
	
	RegAdminCmd("sm_addtaxizone", CommandAddZone, ADMFLAG_CUSTOM3, "- <id> <Name of Place - put in quotes>");
	RegAdminCmd("sm_removetaxizone", CommandRemZone, ADMFLAG_CUSTOM3, "- <id>");
	RegAdminCmd("sm_listtaxizones", CommandListTaxi, ADMFLAG_CUSTOM3, "- <No Args>");
	
	RegAdminCmd("sm_addgamblingzone", CommandAddGambling, ADMFLAG_CUSTOM3, "- <zone id>");
	RegAdminCmd("sm_removegamblingzone", CommandRemGambling, ADMFLAG_CUSTOM3, "- <zone id>");
	RegAdminCmd("sm_listgamblingzones", CommandListGambling, ADMFLAG_CUSTOM3, "- List Gambling Zones that are used");
	RegAdminCmd("sm_setgamblingowner", CommandAddOwnerGam, ADMFLAG_CUSTOM3, "- <name> <zone id>");
	RegAdminCmd("sm_removegamblingowner", CommandRemOwnerGam, ADMFLAG_CUSTOM3, "- <zone id>");
	RegConsoleCmd("sm_mycasinos", CommandListOwnedCasinos);
	RegConsoleCmd("sm_givecasinomoney", CommandAddCasinoBalance);
	RegConsoleCmd("sm_takecasinomoney", CommandSubtractCasinoBalance);
	RegConsoleCmd("sm_opencasino", CommandOpenCasino);
	RegConsoleCmd("sm_closecasino", CommandCloseCasino);
	RegConsoleCmd("sm_bet", CommandCasinoBet);
	RegConsoleCmd("sm_bettypes", CommandCasinoBetTypes);
	RegConsoleCmd("sm_maxbet", CommandCasinoMaxBet);
	RegConsoleCmd("sm_casinocommands", CommandCasinoCmds);
	
	//Ragequit function
	/*RegConsoleCmd("impulse 101", AntiCheat, "");
	RegConsoleCmd("buddha", AntiCheat, "");
	RegConsoleCmd("noclip", AntiCheat, "");
	RegConsoleCmd("god", AntiCheat, "");
	RegConsoleCmd("give", AntiCheat, "");
	RegConsoleCmd("impulse", AntiCheat, "");
	*/
	RegConsoleCmd("sm_job", CommandJobInformation);
	
	RegConsoleCmd("sm_withdraw", CommandWithdraw);
	RegConsoleCmd("sm_deposit", CommandDeposit);
	
	RegAdminCmd("sm_weapon", GiveWeapon, ADMFLAG_CUSTOM2, "- sm_weapon <player> <weaponclass>");
	RegAdminCmd("sm_createcopdoor", CommandCreateCopDoor, ADMFLAG_CUSTOM3, "- <1-64> - Create a default cop door.");
	RegAdminCmd("sm_removecopdoor", CommandRemCopDoor, ADMFLAG_CUSTOM3, "- <1-64> - Remove a default cop door.");
	RegAdminCmd("sm_listcopdoors", CommandListCopDoor, ADMFLAG_CUSTOM3, "- <No Args> - List the default cop doors.");
	RegAdminCmd("sm_createfirefighterdoor", CommandCreateFireDoor, ADMFLAG_CUSTOM3, "- <1-64> - Create a default firefighter door.");
	RegAdminCmd("sm_removefirefighterdoor", CommandRemFireDoor, ADMFLAG_CUSTOM3, "- <1-64> - Remove a default firefighter door.");
	RegAdminCmd("sm_listfirefighterdoors", CommandListFireDoor, ADMFLAG_CUSTOM3, "- <No Args> - List the default firefighter doors.");
	
	//RegAdminCmd("sm_createcar", Command_MakeCoord, ADMFLAG_CUSTOM3, "- <1-50> - Create a car.");
	//RegAdminCmd("sm_removecar", Command_DeleteCoord, ADMFLAG_CUSTOM3, "- <1-50> - Remove a car.");
	//RegAdminCmd("sm_carlist", Command_ListCoords, ADMFLAG_CUSTOM3, "- <No Args> - List the cars");
	//RegAdminCmd("sm_carid", Command_CarID, ADMFLAG_CUSTOM3, "- <No Args> - Get Car Id.");
	//RegAdminCmd("sm_givecarkeys", Command_GiveCarKeys, ADMFLAG_CUSTOM3, "- <Name> - Give keys to the car.");
	//RegAdminCmd("sm_takecarkeys", Command_TakeCarKeys, ADMFLAG_CUSTOM3, "- <Name> - Take away keys to the car.");
	//RegAdminCmd("sm_setnoticecar", Command_TakeCarKeys, ADMFLAG_CUSTOM3, "- <1-50> - Set a notice on the car.);
	
	RegAdminCmd("sm_convertitem", CommandItemConvert, ADMFLAG_ROOT, "- Change item ids in the save database");
	
	RegAdminCmd("sm_lockit", CommandLock, ADMFLAG_CUSTOM1, "- Superlock a door"); 
	RegAdminCmd("sm_unlockit", CommandUnLock, ADMFLAG_CUSTOM1, "- Unlock a Superlock"); 
	RegAdminCmd("sm_cuff", Command_cuff, ADMFLAG_CUSTOM1, "- Lists status of all players");
	RegAdminCmd("sm_uncuff", Command_uncuff, ADMFLAG_CUSTOM1, "- Lists status of all players");
	RegAdminCmd("sm_auct", Command_auctis, ADMFLAG_CUSTOM1, "- Lists status of all players"); 
	RegConsoleCmd("sm_bounty", command_Kopfgeld);
	RegConsoleCmd("sm_vipjail", Command_vipjail);
	RegConsoleCmd("sm_switch", Command_switchStealth);
	RegConsoleCmd("sm_locks", Command_NumberLocks, "Number of locks on a door.");
	RegConsoleCmd("sm_push", Command_pushplayer, "- Push a player");
	
	RegAdminCmd("sm_spawndoor", CommandSpawnDoor, ADMFLAG_CUSTOM3, "- <1-14> - Spawn a door. (Temp)");
	RegAdminCmd("sm_tempremovedoor", CommandRemoveDoor, ADMFLAG_CUSTOM3, "- Remove a door. (Temp)");
	RegAdminCmd("sm_permremovedoor", CommandRemoveDoorP, ADMFLAG_CUSTOM3, "- Remove a door. (From Database)");
	RegAdminCmd("sm_savedoor", CommandSaveDoor, ADMFLAG_CUSTOM3, "- <1-100> - Save a door to database. (Perm)");
	RegAdminCmd("sm_listdoors", CommandListDoors, ADMFLAG_CUSTOM3, "- <1-100> - List custom doors.");
	RegAdminCmd("saveowner", SaveOwnerDoor, ADMFLAG_ROOT, "- Server use only.");
	RegAdminCmd("sm_setlocks", Command_setLocks, ADMFLAG_CUSTOM5, "-Set the doorlocks of a targeted door.");
	RegConsoleCmd("sm_kill", Command_Suicide);
	RegConsoleCmd("sm_freedomcard", Command_UseFreedomCard, "Uses a freedomcard");
	//RegConsoleCmd("explode", Command_Suicide);
	
	RegAdminCmd("sm_freezeprop", FreezeProp, ADMFLAG_CUSTOM3, "- Freeze an object");
	RegAdminCmd("sm_unfreezeprop", UnfreezeProp, ADMFLAG_CUSTOM3, "- Unfreeze an object");
	RegAdminCmd("sm_delete", Delete, ADMFLAG_CUSTOM3, "- Delete an object");
	RegAdminCmd("sm_angles", SetAngles, ADMFLAG_CUSTOM3, "- Changes the Angles on an object");
	RegAdminCmd("sm_origin", SetOrigin, ADMFLAG_CUSTOM3, "- Changes the Origin on an object");
	
	RegAdminCmd("sm_setexp", SetExp, ADMFLAG_CUSTOM3, "- <name> <exp>");
	
	
	RegAdminCmd("sm_playeroftheweek", PlayerWeek, ADMFLAG_ROOT, "- <name> - Reward the player of the week!");
	RegAdminCmd("sm_takedoorall", CommandTakeDoorAll, ADMFLAG_ROOT, " - Take Everyones key from the door you look at");
	
	RegConsoleCmd("sm_doorname", DoorMessage);
	RegConsoleCmd("sm_givekeys", GiveKeys);
	RegConsoleCmd("sm_deletekeys", DeleteKeys);
	RegConsoleCmd("sm_listkeys", ListKeys);
	
	//Events:
	HookEvent("player_death", EventDeath);
	HookEvent("player_hurt", EventDamage);
	HookEvent("player_spawn", EventSpawn, EventHookMode_Pre);
	
	//Data Transfer From rp_door:
	RegAdminCmd("sm_doormenu", DrawDoorMenu, ADMFLAG_CUSTOM3, "- <id> <doorent> <locked> <own>");
	
	RegServerCmd("sv_rpmotd", ServerTitle);
	
	//Commands:
	RegConsoleCmd("say", HandleSay);
	
	//Disable Cheats:
	SetCommandFlags("r_screenoverlay", (GetCommandFlags("r_screenoverlay") - FCVAR_CHEAT));
	
	//User Messages:
	FadeID = GetUserMessageId("Fade");
	ShakeID = GetUserMessageId("Shake");
	
	//Precache:
	PrecacheModel("models/Items/BoxMRounds.mdl", true);
	
	for(new X = 0; X < MAXDOORS; X++)
	{
		Notice[X] = "null";
	}
	
	for(new x = 0; x < 2048; x++)
	{
		DroppedMoneyValue[x] = 0;
	}
	
	//Server Variable:
	//CreateConVar("roleplay_version", "3.2.6", "Roleplay Version",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	//CreateConVar("roleplay_version", "3.2.6", "Roleplay Version Revised",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	//CreateConVar("roleplay_remixed_edition", "1.4", "Eas Roleplay Version",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	ExperienceMode = CreateConVar("sv_rpexperience", "1", "{white}|RP| -{grey} Activate experience/respect for players. 0 = off, 1 = on", FCVAR_PLUGIN);
	CuffCrime = CreateConVar("sv_crimetocuff", "400", "{white}|RP| -{grey} Minimum crime to cuff a person. 400 = default", FCVAR_PLUGIN);
	CrimeJail = CreateConVar("sv_crimepermin", "300", "{white}|RP| -{grey} Amount of crime a person should be in jail per minute. 300/min = default", FCVAR_PLUGIN);
	TaxiCrime = CreateConVar("sv_taximode", "1", "{white}|RP| -{grey} Modes: 0 = Use Taxi Only with 0 crime, 1 = Use Taxi with Crime", FCVAR_PLUGIN);
	RobMode = CreateConVar("sv_robmode", "1", "{white}|RP| -{grey} Modes: 0 = Rebels can rob with no cops online, 1 = Rebels can only rob if cops are online", FCVAR_PLUGIN);
	StarterPackMode = CreateConVar("sv_starterpacks", "1", "{white}|RP| -{grey} Modes: 0 = No starter packs will be given, 1 = Starter packs will be given", FCVAR_PLUGIN);
	FireFighterMode = CreateConVar("sv_firefightermode", "0", "{white}|RP| -{grey} Modes: 0 = Easy mode with Menus, 1 = Hard mode with no Menus", FCVAR_PLUGIN);
	FireFighterChiefMode = CreateConVar("sv_firefighterchiefmode", "0", "{white}|RP| -{grey} Modes: 0 = Chief is not a cop, 1 = Chief is a cop", FCVAR_PLUGIN);
	FireFighterTeam = CreateConVar("sv_firefighterteam", "1", "{white}|RP| -{grey} Modes: 1 = Combine, 2 = Rebel (CHIEF IS NOT INCLUDED)", FCVAR_PLUGIN);
	PlayerWeekMode = CreateConVar("sv_playeroftheweek", "1", "{white}|RP| -{grey} Modes: 0 = Disabled, 1 = Enable", FCVAR_PLUGIN);
	Locks = CreateConVar("sv_commandlocks", "1", "{white}|RP| -{grey} Modes: 0 = Disabled, 1 = Enable", FCVAR_PLUGIN);
	CrimeMenuAmt = CreateConVar("sv_crimehudamt", "0", "{white}|RP| -{grey} How much crime is needed until the person's crime shows on menu. Default: 0 (Shows Everyone That has Crime)", FCVAR_PLUGIN);
	CrimeMenuSet = CreateConVar("sv_crimehudsetting", "0", "{white}|RP| -{grey} Modes: 0 = Disabled when joined, 1 = Enable when joined", FCVAR_PLUGIN);
	CombineTeam = CreateConVar("sv_combineteamname", "Police", "{white}|RP| -{grey} Combine Team Name", FCVAR_PLUGIN);
	RebelTeam = CreateConVar("sv_rebelteamname", "Civilians", "{white}|RP| -{grey} Rebel Team Name", FCVAR_PLUGIN);
	Deduction = CreateConVar("sv_selldoordeduction", "10", "{white}|RP| -{grey} Deduction Percentage off Original Price", FCVAR_PLUGIN);
	CategoryInv = CreateConVar("sv_inventorycategories", "1", "{white}|RP| -{grey} Enable Categories For Inventory", FCVAR_PLUGIN);
	SaveClientJobs = CreateConVar("sv_savejobs", "0", "{white}|RP| -{grey} Modes: 0 = Disable, 1 = Enable", FCVAR_PLUGIN);
	AllowSwitch = CreateConVar("sv_jobswitch", "1", "{white}|RP| -{grey} Modes: 0 = Disable, 1 = Enable (Allow combines to go to rebels)", FCVAR_PLUGIN);
	DrugWorth = CreateConVar("sv_gramworth", "5", "{white}|RP| -{grey} Worth of each gram planted when selling (Default 5)", FCVAR_PLUGIN);
	DrugProb = CreateConVar("sv_gramgrowth", "5", "{white}|RP| -{grey} Gram growth rate (Default 5 Percent)", FCVAR_PLUGIN);
	RebelKillRebel = CreateConVar("sv_crimerebelkill", "400", "{white}|RP| -{grey} Crime added when a rebel is killed (Default 400)", FCVAR_PLUGIN);
	RebelKillCombine = CreateConVar("sv_crimecombinekill", "400", "{white}|RP| -{grey} Crime added when a cop is killed (Default 400)", FCVAR_PLUGIN);
	MaxPlants = CreateConVar("sv_maxdrugplants", "5", "{white}|RP| -{grey} Max Plants To be Spawned", FCVAR_PLUGIN);
	
	
	sm_jetpack = CreateConVar("sm_jetpack", "1", "", FCVAR_PLUGIN | FCVAR_REPLICATED | FCVAR_NOTIFY);
	//sm_jetpack_sound = CreateConVar("sm_jetpack_sound", g_sSound, "", FCVAR_PLUGIN);
	sm_jetpack_speed = CreateConVar("sm_jetpack_speed", "100", "", FCVAR_PLUGIN);
	sm_jetpack_volume = CreateConVar("sm_jetpack_volume", "0.5", "", FCVAR_PLUGIN);
	
	// Create ConCommands
	RegConsoleCmd("+sm_jetpack", JetpackP, "", FCVAR_GAMEDLL);
	RegConsoleCmd("-sm_jetpack", JetpackM, "", FCVAR_GAMEDLL);
	
	// Find SendProp Offsets
	if((g_iLifeState = FindSendPropOffs("CBasePlayer", "m_lifeState")) == -1)
		LogError("Could not find offset for CBasePlayer::m_lifeState");
	
	if((g_iMoveCollide = FindSendPropOffs("CBaseEntity", "movecollide")) == -1)
		LogError("Could not find offset for CBaseEntity::movecollide");
	
	if((g_iMoveType = FindSendPropOffs("CBaseEntity", "movetype")) == -1)
		LogError("Could not find offset for CBaseEntity::movetype");
	
	if((g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]")) == -1)
		LogError("Could not find offset for CBasePlayer::m_vecVelocity[0]");
}

public Action:ServerTitle(Args)
{
	decl String:Arg[512];
	GetCmdArg(1, Arg, sizeof(Arg));
	JoinMessage = Arg;
}

public Action:Command_RestartMap(Client, Args)
{
	decl String:MapName[64];	
	GetCurrentMap(MapName, sizeof(MapName));
	ServerCommand("sm_map %s", MapName);
}
//==========================================================================================
//==========================================================================================
//PLAYER OF THE WEEK:
//==========================================================================================
//==========================================================================================

public Action:PlayerWeek(Client, Args)
{
	if(GetConVarInt(PlayerWeekMode) == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Server Owner disabled this command.");
		return Plugin_Handled;
	}
	if(Args < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_playeroftheweek <name>");
		return Plugin_Handled;
	}
	decl MaxPlayers, Player;
	decl String:PlayerName[32];
	decl String:Name[32];
	
	Player = -1;
	GetCmdArg(1, PlayerName, sizeof(PlayerName));
	MaxPlayers = GetMaxClients();
	for(new X = 1; X <= MaxPlayers; X++)
	{
		if(!IsClientConnected(X)) continue;
		GetClientName(X, Name, sizeof(Name));
		if(StrContains(Name, PlayerName, false) != -1) Player = X;
	}
	if(Player == -1)
	{
		PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
		return Plugin_Handled;
	}
	
	decl String:PlayerFullName[60];
	GetClientName(Player, PlayerFullName, sizeof(PlayerFullName));
	
	for(new P = 1; P <= MaxPlayers; P++)
	{
		if(P != Player && IsClientConnected(P))
		{
			CPrintToChat(P, "\x01\x04{white}|RP| -{grey} %s has been awarded as the player of the week!\x01", PlayerFullName);
		}
	}
	
	CPrintToChat(Player, "\x01\x04{white}|RP| -{grey} You've been awarded as the player of the week!\x01");
	
	decl Handle:Start;
	Start = CreateKeyValues("Vault");
	FileToKeyValues(Start, PlayerWeekPath);
	KvJumpToKey(Start, "Data", false);
	
	decl BonusCash, String:ItemId[32], ItemAmountB;
	BonusCash = KvGetNum(Start, "Cash", 0);
	Bank[Player] += BonusCash;
	if(BonusCash > 0) CPrintToChat(Player, "{white}|RP| -{grey} Cash: $%d", BonusCash);
	
	for(new I; I < MAXITEMS; I++)
	{
		IntToString(I, ItemId, 32);
		ItemAmountB = KvGetNum(Start, ItemId, 0);
		Item[Player][I] += ItemAmountB;
		if(ItemAmountB != 0) CPrintToChat(Player, "{white}|RP| -{grey} %dx of %s", ItemAmountB, ItemName[I]);
	}
	KvRewind(Start);
	CloseHandle(Start);
	Save(Player);
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//CHECK MOD:
//==========================================================================================
//==========================================================================================

public Action:Command_Suicide(Client, Arguments)
{
	//PrintToConsole(Client, "|RP| - Cheater!");
	ForcePlayerSuicide(Client);
	return Plugin_Handled;
}

public Action:Command_UseFreedomCard(Client, Args)
{
	if(Item[Client][203] > 0 && IsCuffed[Client])
	{
		decl String:Player[MAX_NAME_LENGTH];
		GetClientName(Client, Player, sizeof(Player));
		if(IsCuffed[Client])
		{					
			if(AnyExit == 1)
			{
				TeleportEntity(Client, ExitOrigin, NULL_VECTOR, NULL_VECTOR);  
			}
			Uncuff(Client);
			CPrintToChatAll("{white}|RP|{grey} - %s has used a {green}Freedom Card{grey}, and is now out of jail.", Player);
		}
		Item[Client][203] -= 1;
		Save(Client);
		return Plugin_Handled;
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You do not have a {green}Freedom Card {grey}to use, or you aren't cuffed.");
		return Plugin_Handled;
	}
}
public Action:Command_setLocks(Client,Args)
{
	decl Ent;
	Ent = GetClientAimTarget(Client,false);
	if(Args != 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_setlocks <amount>");
		return Plugin_Handled;
	}
	
	new LockA = 0; 
	decl String:LockB[32];
	
	GetCmdArg(1, LockB, sizeof(LockB));
	LockA = StringToInt(LockB);  
	decl Handle:Vault;
	decl String:DoorId[255];
	decl String:LockNr[255];
	
	DoorLocks[Ent] = LockA;		
	Vault = CreateKeyValues("Vault");
	IntToString(Ent,DoorId,20);
	IntToString(DoorLocks[Ent],LockNr,20);
	FileToKeyValues(Vault, LockPath); 
	SaveString(Vault, "2", DoorId, LockNr);
	KeyValuesToFile(Vault, LockPath);
	CloseHandle(Vault);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Locks have been set to: {green}%d{grey}.", LockA);
	return Plugin_Handled;
}

public Action:CheckMenu(Client, bank)
{
	new Handle:Check = CreateMenu(WriteCheck);
	SetMenuTitle(Check, "Bank > Write a Check\n=============\n\nBank: $%d", Bank[Client]);
	AddMenuItem(Check, "5-107", "$5");
	AddMenuItem(Check, "10-108", "$10");
	AddMenuItem(Check, "25-109", "$25");
	AddMenuItem(Check, "50-110", "$50");
	AddMenuItem(Check, "100-111", "$100");
	AddMenuItem(Check, "500-112", "$500");
	AddMenuItem(Check, "1000-113", "$1000");
	AddMenuItem(Check, "5000-114", "$5000");
	AddMenuItem(Check, "10000-115", "$10000");
	
	if(bank == 1)
	{
		AddMenuItem(Check, "99-99", "-|Back to Bank Menu|-");
	}
	
	SetMenuPagination(Check, 7);
	DisplayMenu(Check, Client, 30);
}

public WriteCheck(Handle:Check, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(Check, param2, info, sizeof(info));
		
		decl String:SEP[2][255];
		ExplodeString(info, "-", SEP, 2, 32);
		
		decl Cost;
		Cost = StringToInt(SEP[0]);
		decl ItemId;
		ItemId = StringToInt(SEP[1]);
		if(Cost == 99 && ItemId == 99)
		{
			if(Neg[Client] == 0)
			{
				BankMenu1(Client);
			}
			else
			{
				BankMenu2(Client);
			}
		}
		else if(Bank[Client] >= Cost)
		{
			NumChecks[Client] = NumChecks[Client] - 1;
			Bank[Client] -= Cost;
			Item[Client][ItemId] += 1;
			
			CPrintToChat(Client, "{white}|RP| -{grey} You have written a check for $%d [%d check(s) left|-", Cost, NumChecks[Client]);
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You do not have enough money in the bank to write this check");
		}
		Save(Client);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Check);
	}
	return 0;
}

public Action:ListChecks(Client)
{
	decl Error;
	Error = 1;
	new Handle:CheckL = CreateMenu(List);
	SetMenuTitle(CheckL, "Bank > Cash in Checks\n=============");
	
	for(new X = 107; X < 116; X++)
	{
		if(Item[Client][X] > 0)
		{
			Error = 2;
			decl String:CheckNum[32], String:BackG[32];
			Format(CheckNum, 32, "-|%d|- x %s", Item[Client][X], ItemName[X]);
			Format(BackG, 32, "%d", X);
			AddMenuItem(CheckL, BackG, CheckNum);
		}	
	}
	if(Error == 2)
	{
		AddMenuItem(CheckL, "123123", "-|Back to Bank Menu|-");
		SetMenuPagination(CheckL, 7);
		DisplayMenu(CheckL, Client, 30);
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Found no checks");
		CloseHandle(CheckL);
		if(Neg[Client] == 0)
		{
			BankMenu1(Client);
		}
		else
		{
			BankMenu2(Client);
		}
	}
}

public List(Handle:CheckL, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(CheckL, param2, info, sizeof(info));
		decl ItemN;
		ItemN = StringToInt(info);
		
		if(ItemN == 123123)
		{
			if(Neg[Client] == 0)
			{
				BankMenu1(Client);
			}
			else
			{
				BankMenu2(Client);
			}
		}
		else
		{
			Bank[Client] += ItemCost[ItemN];
			Item[Client][ItemN] = Item[Client][ItemN] - 1;
			
			CPrintToChat(Client, "{white}|RP| -{grey} You have cashed in a check worth $%d", ItemCost[ItemN]);
			Save(Client);
			ListChecks(Client);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(CheckL);
	}
	return 0;
}






//==========================================================================================
//==========================================================================================
//BUYDOOR STUFF:
//==========================================================================================
//==========================================================================================


public Action:CommandDoorAmount(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_setdooramount <Amount>");
		
		//Return:
		return Plugin_Handled;
	}
	decl String:Amount[32];
	GetCmdArg(1, Amount, sizeof(Amount));
	
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	if(SkinDoor[Entdoor] > 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This is a custom door. You can only use sm_givedoor and sm_takedoor on this.");
		return Plugin_Handled;
	}
	
	decl String:ClassName[255];
	GetEdictClassname(Entdoor, ClassName, 255);
	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;
	}
	
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl Handle:SetDoor;
	SetDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(SetDoor, DoorBuyPath);
	KvJumpToKey(SetDoor, DoorStringN, true);
	decl test;
	test = KvGetNum(SetDoor, "Buyable", 1);
	if(test != 1 && test < 10)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This door is already set up in buyable and sellable mode");
		KvRewind(SetDoor);
		CloseHandle(SetDoor);
		return Plugin_Handled;
	}
	KvSetNum(SetDoor, "Buyable", BUYABLE);
	KvSetString(SetDoor, "Amount", Amount);
	KvRewind(SetDoor);
	KeyValuesToFile(SetDoor, DoorBuyPath);
	CloseHandle(SetDoor);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Door #%d is now buyable. Cost set to $%s", Entdoor, Amount);
	
	decl String:SaleMess[255];
	Format(SaleMess, 255, "Door Price l $%s", Amount);
	decl Handle:Mess;
	Mess = CreateKeyValues("Vault");
	FileToKeyValues(Mess, Noticeadd);
	KvJumpToKey(Mess, "Owner", true);
	KvSetString(Mess, DoorStringN, SaleMess);
	KvRewind(Mess);
	KeyValuesToFile(Mess, Noticeadd);
	CloseHandle(Mess);
	ApplyMessage(Entdoor, SaleMess);
	return Plugin_Handled;
}

//Reset Door CMD
public Action:CommandResetDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_resetdoor <NO ARGS>");
		
		return Plugin_Handled;
	}
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl Handle:SetDoor;
	SetDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(SetDoor, DoorBuyPath);
	KvJumpToKey(SetDoor, DoorStringN, false);
	decl Buyable;
	Buyable = KvGetNum(SetDoor, "Buyable", 99);
	if(Buyable == 99 || Buyable == 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Found no owner of this door.");
		KvRewind(SetDoor);
		CloseHandle(SetDoor);
		return Plugin_Handled;
	}
	KvSetNum(SetDoor, "Buyable", BUYABLE);
	decl String:Owner[255], String:Worth[255];
	KvGetString(SetDoor, "Owner", Owner, 255, ERROR);
	KvGetString(SetDoor, "Amount", Worth, 255, ERROR);
	
	decl String:SaleMess[255];
	Format(SaleMess, 255, "Door Price l $%s", Worth);
	decl Handle:Mess;
	Mess = CreateKeyValues("Vault");
	FileToKeyValues(Mess, Noticeadd);
	KvJumpToKey(Mess, "Owner", true);
	KvSetString(Mess, DoorStringN, SaleMess);
	KvRewind(Mess);
	KeyValuesToFile(Mess, Noticeadd);
	CloseHandle(Mess);
	ApplyMessage(Entdoor, SaleMess);
	
	decl Handle:SetupDoor;
	SetupDoor = CreateKeyValues("Vault");
	FileToKeyValues(SetupDoor, DoorPathadd);
	KvJumpToKey(SetupDoor, DoorStringN, true);
	KvDeleteKey(SetupDoor, Owner);
	
	KvSetString(SetDoor, "Owner", "12345");
	
	decl String:Temp1[255];
	for(new X = 1; X <= 50; X++)
	{
		decl String:IdKey[10];
		IntToString(X, IdKey, 10);
		KvDeleteKey(SetDoor, IdKey);
		KvGetString(SetDoor, IdKey, Temp1, 255, NOONE);
		if(!StrEqual(Temp1, "noone", false))
		{
			KvDeleteKey(SetupDoor, Temp1);
		}
	}
	
	KvRewind(SetupDoor);
	KeyValuesToFile(SetupDoor, DoorPathadd);
	CloseHandle(SetupDoor);
	
	KvRewind(SetDoor);
	KeyValuesToFile(SetDoor, DoorBuyPath);
	CloseHandle(SetDoor);
	ServerCommand("sm_refreshdoors");
	
	CPrintToChat(Client, "{white}|RP| -{grey} Owner[%s] of door number %s has lost their keys. This door is now back up for sale at: $%s", Owner, DoorStringN, Worth);
	return Plugin_Handled;
}

//Delete Door CMD
public Action:CommandDeleteDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_deletedoor <NO ARGS>");
		
		return Plugin_Handled;
	}
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl Handle:SetDoor;
	SetDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(SetDoor, DoorBuyPath);
	KvJumpToKey(SetDoor, DoorStringN, false);
	decl Buyable;
	Buyable = KvGetNum(SetDoor, "Buyable", 99);
	if(Buyable == 99)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This door ain't part of the buyable and sellable mode.");
		KvRewind(SetDoor);
		CloseHandle(SetDoor);
		return Plugin_Handled;
	}
	if(Buyable != 1)
	{
		decl String:Owner[255];
		KvGetString(SetDoor, "Owner", Owner, 255, ERROR);
		decl Handle:SetupDoor;
		SetupDoor = CreateKeyValues("Vault");
		FileToKeyValues(SetupDoor, DoorPathadd);
		KvJumpToKey(SetupDoor, DoorStringN, true);
		KvDeleteKey(SetupDoor, Owner);
		
		decl String:Temp1[255];
		for(new X = 1; X <= 50; X++)
		{
			decl String:IdKey[10];
			IntToString(X, IdKey, 10);
			KvGetString(SetDoor, IdKey, Temp1, 255, NOONE);
			if(!StrEqual(Temp1, "noone", false))
			{
				KvDeleteKey(SetupDoor, Temp1);
			}
		}
		KvRewind(SetupDoor);
		KeyValuesToFile(SetupDoor, DoorPathadd);
		CloseHandle(SetupDoor);
	}
	decl String:SaleMess[255];
	Format(SaleMess, 255, " ");
	decl Handle:Mess;
	Mess = CreateKeyValues("Vault");
	FileToKeyValues(Mess, Noticeadd);
	KvJumpToKey(Mess, "Owner", true);
	KvSetString(Mess, DoorStringN, SaleMess);
	KvRewind(Mess);
	KeyValuesToFile(Mess, Noticeadd);
	CloseHandle(Mess);
	ApplyMessage(Entdoor, SaleMess);
	
	KvDeleteThis(SetDoor);
	KvRewind(SetDoor);
	KeyValuesToFile(SetDoor, DoorBuyPath);
	CloseHandle(SetDoor);
	CPrintToChat(Client, "{white}|RP| -{grey} This door has been deleted from the database.");
	ServerCommand("sm_refreshdoors");
	
	return Plugin_Handled;
}

public Action:CommandTakeDoorAll(Client, Arguments)
{
	if(Arguments > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_takedoorall <NO ARGS>");
		return Plugin_Handled;
	}
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	
	if(Ent <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	decl String:ClassName[255];
	GetEdictClassname(Ent, ClassName, 255);
	
	if(!(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating")))
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;
	}
	
	decl String:DoorStringN[255];
	IntToString(Ent, DoorStringN, 255);
	
	decl Handle:SetDoor;
	SetDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(SetDoor, DoorBuyPath);
	KvJumpToKey(SetDoor, DoorStringN, false);
	decl Buyable;
	Buyable = KvGetNum(SetDoor, "Buyable", 99);
	if(Buyable != 99)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This door is set up with the buydoor system. Use the command sm_deletedoor to delete this door.");
		KvRewind(SetDoor);
		CloseHandle(SetDoor);
		return Plugin_Handled;
	}
	KvRewind(SetDoor);
	CloseHandle(SetDoor);
	
	decl Handle:DeleteDoor;
	DeleteDoor = CreateKeyValues("Vault");
	FileToKeyValues(DeleteDoor, DoorPathadd);
	KvJumpToKey(DeleteDoor, DoorStringN);
	KvDeleteThis(DeleteDoor);
	KvRewind(DeleteDoor);
	KeyValuesToFile(DeleteDoor, DoorPathadd);
	CloseHandle(DeleteDoor);
	ServerCommand("sm_refreshdoors");
	CPrintToChat(Client, "{white}|RP| -{grey} Successfully deleted everyone's keys from door #%d", Ent);
	return Plugin_Handled;
}

public Action:DoorMessage(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_doorname <message>");
		return Plugin_Handled;
	}
	
	if(Client == 0) return Plugin_Handled;
	
	decl String:Arg[255];
	
	GetCmdArgString(Arg, sizeof(Arg));
	
	if(StrContains(Arg, "\\", false) != -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot put a backslash in a notice");
		return Plugin_Handled;
	}
	
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;
	}
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl Handle:BuyDoor, Buyable;
	BuyDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(BuyDoor, DoorBuyPath);
	KvJumpToKey(BuyDoor, DoorStringN, false);
	Buyable = KvGetNum(BuyDoor, "Buyable", 99);
	if(Buyable == 99 || Buyable == 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	decl String:Owner[255];
	KvGetString(BuyDoor, "Owner", Owner, 255, ERROR);
	decl String:Ste[255];
	GetClientAuthString(Client, Ste, 255);
	if(StrEqual(Ste, Owner, false))
	{
		decl String:SaleMess[255];
		Format(SaleMess, 255, "%s", Arg);
		decl Handle:Mess;
		Mess = CreateKeyValues("Vault");
		FileToKeyValues(Mess, Noticeadd);
		KvJumpToKey(Mess, "Owner", true);
		KvSetString(Mess, DoorStringN, SaleMess);
		KvRewind(Mess);
		KeyValuesToFile(Mess, Noticeadd);
		CloseHandle(Mess);
		ApplyMessage(Entdoor, SaleMess);
		CPrintToChat(Client, "{white}|RP| -{grey} Door Message Changed To:");
		CPrintToChat(Client, "{white}|RP| -{grey} %s", Arg);
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
	KvRewind(BuyDoor);
	CloseHandle(BuyDoor);
	return Plugin_Handled;
}

public Action:GiveKeys(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_givekeys <1 - 50> <name>");
		return Plugin_Handled;
	}
	
	if(Client == 0) return Plugin_Handled;
	
	decl String:Arg1[255], String:Arg2[255];
	
	GetCmdArg(1, Arg1, sizeof(Arg1));
	GetCmdArg(2, Arg2, sizeof(Arg2));
	
	decl Var;
	Var = StringToInt(Arg1);
	if(Var > 50 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_givekeys <1 - 50> <name>");
		return Plugin_Handled;
	}
	
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl Handle:BuyDoor;
	BuyDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(BuyDoor, DoorBuyPath);
	KvJumpToKey(BuyDoor, DoorStringN, false);
	decl String:Owner[255];
	KvGetString(BuyDoor, "Owner", Owner, 255, ERROR);
	decl String:Ste[255];
	GetClientAuthString(Client, Ste, 255);
	if(!StrEqual(Ste, Owner, false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	decl String:Check[255];
	KvGetString(BuyDoor, Arg1, Check, 255, NOONE);
	if(!StrEqual(Check, "noone", false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} ID #%d has been used. Use a different ID number or delete the ID (sm_deletekeys)", Var);
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	
	new Max, Target = -1;
	Max = GetMaxClients();
	for(new i=1; i <= Max; i++)
	{
		if(!IsClientConnected(i))
			continue;
		new String:Other[32];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Arg2, false) != -1)
			Target = i;
	}
	if(Target == -1)
	{
		PrintToConsole(Client, "|RP| - Could not find client %s.", Arg2);
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	decl String:Ste2[255];
	GetClientAuthString(Target, Ste2, 255);
	if(StrEqual(Ste, Ste2, false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You already have the keys.");
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	KvSetString(BuyDoor, Arg1, Ste2);
	KvRewind(BuyDoor);
	KeyValuesToFile(BuyDoor, DoorBuyPath);
	CloseHandle(BuyDoor);
	
	decl Handle:SetupDoor;
	SetupDoor = CreateKeyValues("Vault");
	FileToKeyValues(SetupDoor, DoorPathadd);
	KvJumpToKey(SetupDoor, DoorStringN, true);
	KvSetNum(SetupDoor, Ste2, 1);
	KvRewind(SetupDoor);
	KeyValuesToFile(SetupDoor, DoorPathadd);
	CloseHandle(SetupDoor);
	
	new String:NameSo[255];
	GetClientName(Client, NameSo, 255);
	new String:NameS[255];
	GetClientName(Target, NameS, 255);
	ServerCommand("sm_refreshdoors");
	
	CPrintToChat(Target, "{white}|RP| -{grey} You have been given keys by %s", NameSo);
	CPrintToChat(Client, "{white}|RP| -{grey} You given keys to %s", NameS);
	
	return Plugin_Handled;
}

public Action:DeleteKeys(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_deletekeys <1 - 50>");
		
		return Plugin_Handled;
	}
	
	if(Client == 0) return Plugin_Handled;
	
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;
	}
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl String:Arg1[255];
	GetCmdArg(1, Arg1, sizeof(Arg1));
	
	decl Var;
	Var = StringToInt(Arg1);
	if(Var > 50 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_deletekeys <1 - 50>");
		return Plugin_Handled;
	}
	
	decl Handle:BuyDoor;
	BuyDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(BuyDoor, DoorBuyPath);
	KvJumpToKey(BuyDoor, DoorStringN, false);
	decl String:Owner[255];
	KvGetString(BuyDoor, "Owner", Owner, 255, NOONE);
	decl String:Ste[255];
	GetClientAuthString(Client, Ste, 255);
	if(!StrEqual(Ste, Owner, false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	
	decl String:Ste2[255];
	KvGetString(BuyDoor, Arg1, Ste2, 255, NOONE);
	if(StrEqual(Ste2, "noone", false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Noone has keys with that id");	
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	KvDeleteKey(BuyDoor, Arg1);
	
	decl Handle:SetupDoor;
	SetupDoor = CreateKeyValues("Vault");
	FileToKeyValues(SetupDoor, DoorPathadd);
	KvJumpToKey(SetupDoor, DoorStringN, true);
	KvDeleteKey(SetupDoor, Ste2);
	KvRewind(SetupDoor);
	KeyValuesToFile(SetupDoor, DoorPathadd);
	CloseHandle(SetupDoor);
	
	KvRewind(BuyDoor);
	KeyValuesToFile(BuyDoor, DoorBuyPath);
	CloseHandle(BuyDoor);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Steamid [%s] has lost keys to this house", Ste2);
	
	ServerCommand("sm_refreshdoors");
	return Plugin_Handled;
}

public Action:ListKeys(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listkeys <No Args>");
		
		return Plugin_Handled;
	}
	
	if(Client == 0) return Plugin_Handled;
	
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	decl String:DoorStringN[255];
	IntToString(Entdoor, DoorStringN, 255);
	
	decl Handle:BuyDoor;
	BuyDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(BuyDoor, DoorBuyPath);
	KvJumpToKey(BuyDoor, DoorStringN, false);
	decl String:Owner[255];
	KvGetString(BuyDoor, "Owner", Owner, 255, ERROR);
	decl String:Ste[255];
	GetClientAuthString(Client, Ste, 255);
	if(!StrEqual(Ste, Owner, false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
		KvRewind(BuyDoor);
		CloseHandle(BuyDoor);
		return Plugin_Handled;
	}
	
	CPrintToChat(Client, "{white}|RP| -{grey} List of keys are printed in console.");
	PrintToConsole(Client, "|RP| - [ID] [NAME]");
	
	decl String:List1[255], String:KeyName[255];
	decl Handle:VaultD;
	VaultD = CreateKeyValues("Vault");
	FileToKeyValues(VaultD, NamePath);
	KvJumpToKey(VaultD, "name", true);
	
	for(new X = 1; X <= 50; X++)
	{
		decl String:IdKey[10];
		IntToString(X, IdKey, 10);
		KvGetString(BuyDoor, "1", List1, 255, NOONE);
		KvGetString(VaultD, List1, KeyName, 255, "Not Given");
		PrintToConsole(Client, "%d - %s", X, KeyName);
	}
	KvRewind(VaultD);
	CloseHandle(VaultD);
	KvRewind(BuyDoor);
	CloseHandle(BuyDoor);
	return Plugin_Handled;
}

public Action:CommandDoorRight(Client, Args)
{
	decl MaxPlayers;
	MaxPlayers = GetMaxClients();
	for(new i = 1; i <= MaxPlayers; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			if(IsCombine(i))
			{
				decl ClientID;
				ClientID = GetClientUserId(i);
				ServerCommand("sm_copdoor #%d 1", ClientID);
				
			}
			if(IsFirefighter(i))
			{
				decl ClientID;
				ClientID = GetClientUserId(i);
				ServerCommand("sm_firedoor #%d 1", ClientID);
			}
			else
			{
				decl ClientID;
				ClientID = GetClientUserId(i);
				ServerCommand("sm_copdoor #%d 0", ClientID);
				ServerCommand("sm_firedoor #%d 0", ClientID);
			}
		}
	}
	return Plugin_Handled;
}



//==========================================================================================
//==========================================================================================
//NO KILL ZONES:
//==========================================================================================
//==========================================================================================


public Action:CommandCreateNokill(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_createnokillzone <id>");
		return Plugin_Handled;
	}
	decl String:Pos[32];
	GetCmdArg(1, Pos, sizeof(Pos));
	
	decl Var;
	Var = StringToInt(Pos);
	if(Var > 100 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_createnokillzone <id 1-100>");
		return Plugin_Handled;
	}
	decl Handle:AddZone;
	AddZone = CreateKeyValues("Zones");
	FileToKeyValues(AddZone, ZonesPath);
	KvJumpToKey(AddZone, Pos, true);
	
	KvSetString(AddZone, "Name", "Used");
	
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	KvSetVector(AddZone, "Origin", Origin);
	KvRewind(AddZone);
	KeyValuesToFile(AddZone, ZonesPath);
	CloseHandle(AddZone);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Added No Kill Zone [ID: %s] [%f %f %f]", Pos, Origin[0], Origin[1], Origin[2]);
	ServerCommand("sm_refreshzones");
	return Plugin_Handled;
}

public Action:CommandRemoveNokill(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_deletenokillzone <id>");
		return Plugin_Handled;
	}
	decl String:Pos[32];
	GetCmdArg(1, Pos, sizeof(Pos));
	decl Var;
	Var = StringToInt(Pos);
	if(Var > 100 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_removenokillzone <id 1-100>");
		return Plugin_Handled;
	}
	decl Handle:DelZone;
	DelZone = CreateKeyValues("Zones");
	FileToKeyValues(DelZone, ZonesPath);
	KvJumpToKey(DelZone, Pos, false);
	KvDeleteThis(DelZone);
	KvRewind(DelZone);
	KeyValuesToFile(DelZone, ZonesPath);
	CloseHandle(DelZone);
	CPrintToChat(Client, "{white}|RP| -{grey} Deleted No Kill Zone [ID: %s]", Pos);
	ServerCommand("sm_refreshzones");
	return Plugin_Handled;
}

public Action:CommandListZone(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listnokillzones <No Args>");
		return Plugin_Handled;
	}
	
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Look in console for output");
	PrintToConsole(Client, "-|No Kill Zone] IDs Used [%s]:", MapName);
	PrintToConsole(Client, "=========================");
	
	decl Handle:DelZone;
	decl Float:DefOrg[3];
	decl Float:ShowCoords[3];
	DefOrg[0] = 9999.0;
	DefOrg[1] = 9999.0;
	DefOrg[2] = 9999.0;
	DelZone = CreateKeyValues("Zones");
	FileToKeyValues(DelZone, ZonesPath);
	for(new Zonesd = 1; Zonesd <= 100; Zonesd++)
	{
		decl String:ZonesdS[255];
		IntToString(Zonesd, ZonesdS, 255);
		KvJumpToKey(DelZone, ZonesdS, false);
		
		KvGetVector(DelZone, "Origin", ShowCoords, DefOrg);
		if(ShowCoords[0] != 9999.0) PrintToConsole(Client, "%d) %f %f %f", Zonesd, ShowCoords[0], ShowCoords[1], ShowCoords[2]);
		KvRewind(DelZone);
	}
	KvRewind(DelZone);
	CloseHandle(DelZone);
	return Plugin_Handled;
}

public Action:CommandRefreshZones(Client, Args)
{
	decl Handle:DelZone;
	decl Float:DefOrg[3];
	DefOrg[0] = 9999.0;
	DefOrg[1] = 9999.0;
	DefOrg[2] = 9999.0;
	DelZone = CreateKeyValues("Zones");
	FileToKeyValues(DelZone, ZonesPath);
	for(new Zonesd = 1; Zonesd <= 100; Zonesd++)
	{
		decl String:ZonesdS[255];
		IntToString(Zonesd, ZonesdS, 255);
		KvJumpToKey(DelZone, ZonesdS, false);
		
		KvGetVector(DelZone, "Origin", NoKillZones[Zonesd], DefOrg);
		KvRewind(DelZone);
	}
	KvRewind(DelZone);
	CloseHandle(DelZone);
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//NO CRIME ZONES:
//==========================================================================================
//==========================================================================================

public Action:CommandCreateNocrime(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_createnocrimezone <id>");
		return Plugin_Handled;
	}
	decl String:Pos[32];
	GetCmdArg(1, Pos, sizeof(Pos));
	
	decl Var;
	Var = StringToInt(Pos);
	if(Var > MAXCRIMEZONES || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_createnocrimezone <id 1-%d>", MAXCRIMEZONES);
		return Plugin_Handled;
	}
	decl Handle:AddZone;
	AddZone = CreateKeyValues("Zones");
	FileToKeyValues(AddZone, CrimeZonesPath);
	KvJumpToKey(AddZone, Pos, true);
	
	KvSetString(AddZone, "Name", "Used");
	
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	KvSetVector(AddZone, "Origin", Origin);
	KvRewind(AddZone);
	KeyValuesToFile(AddZone, CrimeZonesPath);
	CloseHandle(AddZone);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Added No Crime Zone [ID: %s] [%f %f %f]", Pos, Origin[0], Origin[1], Origin[2]);
	ServerCommand("sm_refreshcrimezones");
	return Plugin_Handled;
}

public Action:CommandRemoveNocrime(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_removenocrimezone <id>");
		return Plugin_Handled;
	}
	decl String:Pos[32];
	GetCmdArg(1, Pos, sizeof(Pos));
	decl Var;
	Var = StringToInt(Pos);
	if(Var > MAXCRIMEZONES || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_removenocrimezone <id 1-%d>", MAXCRIMEZONES);
		return Plugin_Handled;
	}
	decl Handle:DelZone;
	DelZone = CreateKeyValues("Zones");
	FileToKeyValues(DelZone, CrimeZonesPath);
	KvJumpToKey(DelZone, Pos, false);
	KvDeleteThis(DelZone);
	KvRewind(DelZone);
	KeyValuesToFile(DelZone, CrimeZonesPath);
	CloseHandle(DelZone);
	CPrintToChat(Client, "{white}|RP| -{grey} Deleted No Crime Zone [ID: %s]", Pos);
	ServerCommand("sm_refreshcrimezones");
	return Plugin_Handled;
}

public Action:CommandListCrimeZone(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listnocrimezones <No Args>");
		return Plugin_Handled;
	}
	
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Look in console for output");
	PrintToConsole(Client, "-|No Crime Zones] IDs Used [%s]:", MapName);
	PrintToConsole(Client, "=========================");
	
	decl Handle:DelZone;
	decl Float:DefOrg[3];
	decl Float:ShowCoords[3];
	DefOrg[0] = 9999.0;
	DefOrg[1] = 9999.0;
	DefOrg[2] = 9999.0;
	DelZone = CreateKeyValues("Zones");
	FileToKeyValues(DelZone, CrimeZonesPath);
	for(new Zonesd = 1; Zonesd <= 100; Zonesd++)
	{
		decl String:ZonesdS[255];
		IntToString(Zonesd, ZonesdS, 255);
		KvJumpToKey(DelZone, ZonesdS, false);
		
		KvGetVector(DelZone, "Origin", ShowCoords, DefOrg);
		if(ShowCoords[0] != 9999.0) PrintToConsole(Client, "%d) %f %f %f", Zonesd, ShowCoords[0], ShowCoords[1], ShowCoords[2]);
		KvRewind(DelZone);
	}
	KvRewind(DelZone);
	CloseHandle(DelZone);
	return Plugin_Handled;
}

public Action:CommandRefreshCrimeZones(Client, Args)
{
	decl Handle:DelZone;
	decl Float:DefOrg[3];
	DefOrg[0] = 9999.0;
	DefOrg[1] = 9999.0;
	DefOrg[2] = 9999.0;
	DelZone = CreateKeyValues("Zones");
	FileToKeyValues(DelZone, CrimeZonesPath);
	for(new Zonesd = 1; Zonesd <= 100; Zonesd++)
	{
		decl String:ZonesdS[255];
		IntToString(Zonesd, ZonesdS, 255);
		KvJumpToKey(DelZone, ZonesdS, false);
		
		KvGetVector(DelZone, "Origin", NoCrimeOrigin[Zonesd], DefOrg);
		KvRewind(DelZone);
		
	}
	KvRewind(DelZone);
	CloseHandle(DelZone);
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//TAXI STUFF:
//==========================================================================================
//==========================================================================================


public Action:CommandAddZone(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_addtaxizone <id> <Name of Place - put in quotes>");
		return Plugin_Handled;
	}
	decl String:Tax1[32], String:Tax2[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	GetCmdArg(2, Tax2, sizeof(Tax2));
	
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 20 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_addtaxizone <1 - 20> <Name of Place - put in quotes>");
		return Plugin_Handled;
	}
	decl Handle:AddZone;
	AddZone = CreateKeyValues("Taxi");
	FileToKeyValues(AddZone, TaxiPath);
	KvJumpToKey(AddZone, Tax1, true);
	KvSetString(AddZone, "Name", Tax2);
	
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	KvSetVector(AddZone, "Origin", Origin);
	KvRewind(AddZone);
	KeyValuesToFile(AddZone, TaxiPath);
	CloseHandle(AddZone);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Added Taxi Position [ID: %s] at coordinate [%f %f %f]", Tax1, Origin[0], Origin[1], Origin[2]);
	return Plugin_Handled;
}

public Action:CommandRemZone(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_removetaxizone <id>");
		return Plugin_Handled;
	}
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 20 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_removetaxizone <1 - 20>");
		return Plugin_Handled;
	}
	decl Handle:DelZone;
	DelZone = CreateKeyValues("Taxi");
	FileToKeyValues(DelZone, TaxiPath);
	KvJumpToKey(DelZone, Tax1, false);
	KvDeleteThis(DelZone);
	KvRewind(DelZone);
	KeyValuesToFile(DelZone, TaxiPath);
	CloseHandle(DelZone);
	CPrintToChat(Client, "{white}|RP| -{grey} Deleted Taxi Position [ID: %s]", Tax1);
	return Plugin_Handled;
}

public Action:CommandListTaxi(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listtaxizones <No Args>");
		return Plugin_Handled;
	}
	decl Handle:DelZone;
	DelZone = CreateKeyValues("Taxi");
	FileToKeyValues(DelZone, TaxiPath);
	
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Look in console for output");
	PrintToConsole(Client, "-|Taxi Zones] IDs Used [%s]:", MapName);
	PrintToConsole(Client, "=========================");
	
	for(new Taxid = 1; Taxid <= 20; Taxid++)
	{
		decl String:TaxidS[255];
		IntToString(Taxid, TaxidS, 255);
		KvJumpToKey(DelZone, TaxidS, false);
		decl String:TaxName[255];
		KvGetString(DelZone, "Name", TaxName, 255, ERROR);
		if(!StrContains(TaxName, "Error", false))
		{
			PrintToConsole(Client, "%d) Zone Not Used", Taxid);
			KvRewind(DelZone);
		}
		if(StrContains(TaxName, "Error", false))
		{
			PrintToConsole(Client, "%d) %s", Taxid, TaxName);
			KvRewind(DelZone);
		}
	}
	KvRewind(DelZone);
	CloseHandle(DelZone);
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//CONFIG FILE SETUP:
//==========================================================================================
//==========================================================================================


public Action:CommandAddJail(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_addjail <1-10>");
		return Plugin_Handled;
	}
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 10 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_addjail <1-10>");
		return Plugin_Handled;
	}
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "Jail", true);
	
	KvSetVector(Fig, Tax1, Origin);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	JailOrigin[Var][0] = Origin[0];
	JailOrigin[Var][1] = Origin[1];
	JailOrigin[Var][2] = Origin[2];
	
	CPrintToChat(Client, "{white}|RP| -{grey} Jail Cell [ID: %s] has been edited for coord [%f %f %f]", Tax1, Origin[0], Origin[1], Origin[2]);
	ReloadJails();
	return Plugin_Handled;
}

public Action:CommandRemJail(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_removejail <1-10>");
		return Plugin_Handled;
	}
	decl Float:Remove[3] = {69.0, 69.0, 69.0};
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 10 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_removejail <1-10>");
		return Plugin_Handled;
	}
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "Jail", true);
	
	KvSetVector(Fig, Tax1, Remove);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	JailOrigin[Var][0] = 69.0;
	JailOrigin[Var][1] = 69.0;
	JailOrigin[Var][2] = 69.0;
	
	CPrintToChat(Client, "{white}|RP| -{grey} Jail Cell [ID: %s] has been removed.", Tax1);
	ReloadJails();
	return Plugin_Handled;
}

public Action:CommandListJail(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listjails <NO ARGS>");
		return Plugin_Handled;
	}
	
	decl Float:Ran[3] = {69.0, 69.0, 69.0};
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);
	
	//Header:
	PrintToConsole(Client, "Jail Cells [%s]:", MapName);
	
	decl Handle:Vault;
	decl String:Key[32];
	
	Vault = CreateKeyValues("Vault");
	
	FileToKeyValues(Vault, ConfigPath);
	
	for(new X = 1; X <= 10; X++)
	{
		
		//Convert:
		IntToString(X, Key, 32);
		
		//Find:
		KvJumpToKey(Vault, "Jail", false);
		KvGetVector(Vault, Key, JailOrigin[X], Ran);
		KvRewind(Vault);
		
		if(JailOrigin[X][0] != 69.0)
		{
			PrintToConsole(Client, "%s: <%f, %f, %f>", Key, JailOrigin[X][0], JailOrigin[X][1], JailOrigin[X][2]);
		}
		else
		{
			PrintToConsole(Client, "%s: Not Used", Key);
		}
		
	}
	CloseHandle(Vault);
	return Plugin_Handled;
}


public Action:CommandSetSui(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_setsuicide <1-2>");
		return Plugin_Handled;
	}
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 2 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_setsuicide <1-2>");
		return Plugin_Handled;
	}
	
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "General", true);
	
	if(Var == 1)
	{
		OrderOrigin[0] = Origin[0];
		OrderOrigin[1] = Origin[1];
		OrderOrigin[2] = Origin[2];
		KvSetVector(Fig, "suicide", Origin);
	}
	if(Var == 2)
	{
		OrderOrigin2[0] = Origin[0];
		OrderOrigin2[1] = Origin[1];
		OrderOrigin2[2] = Origin[2];
		KvSetVector(Fig, "suicide2", Origin);
	}
	
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Suicide Cell #%s has been edited for coord [%f %f %f]", Tax1, Origin[0], Origin[1], Origin[2]);
	ReloadJails();
	return Plugin_Handled;
}

public Action:CommandRemSui(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_removesuicide <1-2>");
		return Plugin_Handled;
	}
	decl Float:Del[3] = {69.0, 69.0, 69.0};
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 2 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_removesuicide <1-2>");
		return Plugin_Handled;
	}
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "General", true);
	
	if(Var == 1)
	{
		OrderOrigin[0] = 69.0;
		OrderOrigin[0] = 69.0;
		OrderOrigin[0] = 69.0;
		KvSetVector(Fig, "suicide", Del);
	}
	if(Var == 2)
	{
		OrderOrigin2[0] = 69.0;
		OrderOrigin2[0] = 69.0;
		OrderOrigin2[0] = 69.0;
		KvSetVector(Fig, "suicide2", Del);
	}
	
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Suicide Cell #%s has been removed.", Tax1);
	ReloadJails();
	return Plugin_Handled;
}

public Action:CommandListSui(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listsuicide <NO ARGS>");
		return Plugin_Handled;
	}
	decl Float:Checker[3] = {69.0, 69.0, 69.0};
	decl Float:Vip1[3], Float:Vip2[3];
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "General", true);
	KvGetVector(Fig, "suicide", Vip1, Checker);
	KvGetVector(Fig, "suicide2", Vip2, Checker);
	KvRewind(Fig);
	CloseHandle(Fig);
	
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);
	PrintToConsole(Client, "Suicide Cells [%s]:", MapName);
	
	if(Vip1[0] != 69.0)
	{
		PrintToConsole(Client, "1: <%f, %f, %f>", Vip1[0], Vip1[0], Vip1[0]);
	}
	else
	{
		PrintToConsole(Client, "1: Not Used");
	}
	
	if(Vip2[0] != 69.0)
	{
		PrintToConsole(Client, "2: <%f, %f, %f>", Vip2[0], Vip2[0], Vip2[0]);
	}
	else
	{
		PrintToConsole(Client, "2: Not Used");
	}
	return Plugin_Handled;
}



public Action:CommandSetExit(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_setexit <NO ARGS>");
		return Plugin_Handled;
	}
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "General", true);
	
	KvSetVector(Fig, "exit", Origin);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	ExitOrigin[0] = Origin[0];
	ExitOrigin[1] = Origin[1];
	ExitOrigin[2] = Origin[2];
	
	CPrintToChat(Client, "{white}|RP| -{grey} Exit has been edited for coord [%f %f %f]", Origin[0], Origin[1], Origin[2]);
	ReloadJails();
	return Plugin_Handled;
}

public Action:CommandSetVip(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_setvipjail <NO ARGS>");
		return Plugin_Handled;
	}
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "General", true);
	
	KvSetVector(Fig, "vipjail", Origin);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	VIPJailOrigin[0] = Origin[0];
	VIPJailOrigin[1] = Origin[1];
	VIPJailOrigin[2] = Origin[2];
	
	CPrintToChat(Client, "{white}|RP| -{grey} VipJail has been edited for coord [%f %f %f]", Origin[0], Origin[1], Origin[2]);
	ReloadJails();
	return Plugin_Handled;
}

public Action:CommandSetAfk(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_setafk <NO ARGS>");
		return Plugin_Handled;
	}
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "General", true);
	
	KvSetVector(Fig, "afkroom", Origin);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	AFKOrigin[0] = Origin[0];
	AFKOrigin[1] = Origin[1];
	AFKOrigin[2] = Origin[2];
	
	CPrintToChat(Client, "{white}|RP| -{grey} Afk Room has been edited for coord [%f %f %f]", Origin[0], Origin[1], Origin[2]);
	ReloadJails();
	return Plugin_Handled;
}

public Action:CommandSetGarbage(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_setgarbage <NO ARGS>");
		return Plugin_Handled;
	}
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "General", true);
	
	Origin[2] += 20.0;
	KvSetVector(Fig, "garbage", Origin);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	GarbageOrigin[0] = Origin[0];
	GarbageOrigin[1] = Origin[1];
	GarbageOrigin[2] = Origin[2];
	
	CPrintToChat(Client, "{white}|RP| -{grey} Garbage Zone has been edited for coord [%f %f %f]", Origin[0], Origin[1], Origin[2]);
	ReloadJails();
	return Plugin_Handled;
}

public Action:ReloadJails()
{
	AnyJail = 0;
	AnySui1 = 0;
	AnySui2 = 0;
	AnyExit = 0;
	AnyVip = 0;
	AnyAfk = 0;
	AnyGarbage = 0;
	
	for(new X = 1; X <= 10; X++)
	{
		if(JailOrigin[X][0] != 69.0)
		{
			AnyJail = 1;
		}
	}
	if(VIPJailOrigin[0] != 69.0)
	{
		AnyVip = 1;
	}
	if(ExitOrigin[0] != 69.0)
	{
		AnyExit = 1;
	}
	if(OrderOrigin[0] != 69.0)
	{
		AnySui1 = 1;
	}
	if(OrderOrigin2[0] != 69.0)
	{
		AnySui2 = 1;
	}
	if(AFKOrigin[0] != 69.0)
	{
		AnyAfk = 1;
	}
	if(GarbageOrigin[0] != 69.0)
	{
		AnyGarbage = 1;
	}
	return Plugin_Handled;
}

public Action:CommandCreateCopDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_createcopdoor <0-64>");
		return Plugin_Handled;
	}
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 64 || Var < 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_createcopdoor <0-64>");
		return Plugin_Handled;
	}
	
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "PoliceDoor", true);
	KvSetNum(Fig, Tax1, Entdoor);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Door #%d has been added to the default cop door database", Entdoor);
	ServerCommand("sm_refreshdoors");
	return Plugin_Handled;
}

public Action:CommandCreateFireDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_createfirefighterdoor <0-64>");
		return Plugin_Handled;
	}
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 64 || Var < 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_createfirefighterdoor <0-64>");
		return Plugin_Handled;
	}
	
	decl Entdoor;
	Entdoor = GetClientAimTarget(Client, false);
	if(Entdoor <= 1)
	{
		PrintToConsole(Client, "|RP| - Invalid Door.");
		return Plugin_Handled;	
	}
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "FirefighterDoor", true);
	KvSetNum(Fig, Tax1, Entdoor);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Door #%d has been added to the default firefighter door database", Entdoor);
	ServerCommand("sm_refreshdoors");
	return Plugin_Handled;
}

public Action:CommandRemCopDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_removecopdoor <0-64>");
		return Plugin_Handled;
	}
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 64 || Var < 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_removecopdoor <0-64>");
		return Plugin_Handled;
	}
	
	decl Handle:Fig, Doorid;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "PoliceDoor", true);
	Doorid = KvGetNum(Fig, Tax1, 0);
	KvSetNum(Fig, Tax1, 0);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Door #%d has been deleted to the default cop door database", Doorid);
	ServerCommand("sm_refreshdoors");
	return Plugin_Handled;
}

public Action:CommandRemFireDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_removefirefighterdoor <0-64>");
		return Plugin_Handled;
	}
	decl String:Tax1[32];
	GetCmdArg(1, Tax1, sizeof(Tax1));
	decl Var;
	Var = StringToInt(Tax1);
	if(Var > 64 || Var < 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_removefirefighterdoor <0-64>");
		return Plugin_Handled;
	}
	
	decl Handle:Fig, Doorid;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	KvJumpToKey(Fig, "FirefighterDoor", true);
	Doorid = KvGetNum(Fig, Tax1, 0);
	KvSetNum(Fig, Tax1, 0);
	KvRewind(Fig);
	KeyValuesToFile(Fig, ConfigPath);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Door #%d has been deleted to the default firefighter door database", Doorid);
	ServerCommand("sm_refreshdoors");
	return Plugin_Handled;
}

public Action:CommandListCopDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listcopdoors <NO ARGS>");
		return Plugin_Handled;
	}
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	
	for(new ID = 0; ID <= 64; ID++)
	{
		KvJumpToKey(Fig, "PoliceDoor", true);
		
		decl String:Door[255], Num;
		IntToString(ID, Door, 255);
		
		Num = KvGetNum(Fig, Door, 0);
		PrintToConsole(Client, "%d - %d", ID, Num);
		KvRewind(Fig);
	}
	KvRewind(Fig);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Open console for output.");
	return Plugin_Handled;
}

public Action:CommandListFireDoor(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listfirefighterdoors <NO ARGS>");
		return Plugin_Handled;
	}
	
	decl Handle:Fig;
	Fig = CreateKeyValues("Vault");
	FileToKeyValues(Fig, ConfigPath);
	
	for(new ID = 0; ID <= 64; ID++)
	{
		KvJumpToKey(Fig, "FirefighterDoor", true);
		
		decl String:Door[255], Num;
		IntToString(ID, Door, 255);
		
		Num = KvGetNum(Fig, Door, 0);
		PrintToConsole(Client, "%d - %d", ID, Num);
		KvRewind(Fig);
	}
	KvRewind(Fig);
	CloseHandle(Fig);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Open console for output.");
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//CAR ADDONS (Airboats)
//==========================================================================================
//==========================================================================================

public Action:Command_MakeCoord(Client, Arguments)
{
	if(Client == 0) return Plugin_Handled;
	if(Arguments < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_createcar <id 1-50>");
		return Plugin_Handled;
	}
	
	decl String:Arg1[255];
	
	GetCmdArg(1, Arg1, sizeof(Arg1));
	
	decl Var;
	Var = StringToInt(Arg1);
	if(Var > MAXCARS || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_createcar <id 1-50>");
		return Plugin_Handled;
	}
	
	decl Handle:AddCar;
	AddCar = CreateKeyValues("Vault");
	FileToKeyValues(AddCar, CarPath);
	KvJumpToKey(AddCar, Arg1, true);
	
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	decl Float:Angles[3];
	GetClientAbsAngles(Client, Angles);
	Angles[0] = 0.0;
	Angles[2] = 0.0;
	
	KvSetVector(AddCar, "Origin", Origin);
	KvSetVector(AddCar, "Angle", Angles);
	
	KvRewind(AddCar);
	KeyValuesToFile(AddCar, CarPath);
	CloseHandle(AddCar);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Added Car [ID: %s] [ORIGIN: %f %f %f]", Arg1, Origin[0], Origin[1], Origin[2]);
	CPrintToChat(Client, "{white}|RP| -{grey} Restart map for car to spawn.");
	return Plugin_Handled;
}


public Action:Command_DeleteCoord(Client, Arguments)
{
	if(Client == 0) return Plugin_Handled;
	if(Arguments < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_removecar <id 1-50>");
		return Plugin_Handled;
	}
	
	decl String:Arg1[255];
	
	GetCmdArg(1, Arg1, sizeof(Arg1));
	
	decl Var;
	Var = StringToInt(Arg1);
	if(Var > MAXCARS || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_removecar <id 1-50>");
		return Plugin_Handled;
	}
	
	decl Handle:AddCar;
	AddCar = CreateKeyValues("Vault");
	FileToKeyValues(AddCar, CarPath);
	KvJumpToKey(AddCar, Arg1, false);
	KvDeleteThis(AddCar);
	KvRewind(AddCar);
	KeyValuesToFile(AddCar, CarPath);
	CloseHandle(AddCar);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Deleted Car [ID: %s] from the database", Arg1);
	CPrintToChat(Client, "{white}|RP| -{grey} Restart map for car to delete.");
	return Plugin_Handled;
}


public Action:Command_ListCoords(Client, Arguments)
{
	if(Client == 0) return Plugin_Handled;
	if(Arguments > 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_carlist <NO ARGS>");
		return Plugin_Handled;
	}
	decl Handle:AddCar;
	AddCar = CreateKeyValues("Vault");
	FileToKeyValues(AddCar, CarPath);
	
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Look in console for output");
	PrintToConsole(Client, "-|Cars] IDs Used [%s]:", MapName);
	PrintToConsole(Client, "=========================");
	
	decl Float:DefOrg[3];
	decl Float:ShowCoords[3];
	DefOrg[0] = 9999.0;
	DefOrg[1] = 9999.0;
	DefOrg[2] = 9999.0;
	
	for(new car = 1; car <= MAXCARS; car++)
	{
		decl String:cars[255];
		IntToString(car, cars, 255);
		KvJumpToKey(AddCar, cars, false);
		
		KvGetVector(AddCar, "Origin", ShowCoords, DefOrg);
		PrintToConsole(Client, "%d) %f %f %f", car, ShowCoords[0], ShowCoords[1], ShowCoords[2]);
		KvRewind(AddCar);
	}
	KvRewind(AddCar);
	CloseHandle(AddCar);
	return Plugin_Handled;
}

public Action:Command_GiveCarKeys(Client, Arguments)
{
	if(Client == 0) return Plugin_Handled;	
	if(Arguments < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_givecarkeys <Name>");
		return Plugin_Handled;
	}
	
	decl String:Arg2[255];
	GetCmdArg(1, Arg2, sizeof(Arg2));
	new Max, Player = -1;
	Max = GetMaxClients();
	for(new i = 1; i <= Max; i++)
	{
		if(!IsClientConnected(i))
			continue;
		new String:Other[32];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Arg2, false) != -1)
			Player = i;
	}
	if(Player == -1)
	{
		PrintToConsole(Client, "|RP| - Could not find client %s.", Arg2);
		return Plugin_Handled;
	}
	//==================
	//==================
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	
	if(Ent <= 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Entity.");
		return Plugin_Handled;
	}
	//=================
	//=================
	decl String:CarClassname[255];
	GetEdictClassname(Ent, CarClassname, 255);
	if(!StrEqual(CarClassname, "prop_vehicle_airboat"))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Look at an airboat.");
		return Plugin_Handled;
	}
	//=================
	//=================
	if(CarEntity[Ent] == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Error. This airboat has been created by something other than sm_createcar.");
		return Plugin_Handled;
	}
	if(OwnsCar[Player][CarEntity[Ent]] == 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This client already has the keys.");
		return Plugin_Handled;
	}
	OwnsCar[Player][CarEntity[Ent]] = 1;
	
	decl String:Name[32];
	GetClientName(Player, Name, 32);
	CPrintToChat(Client, "{white}|RP| -{grey} %s has got keys to car #%d.", Name, CarEntity[Ent]);
	CPrintToChat(Player, "{white}|RP| -{grey} You have got keys to car #%d.", CarEntity[Ent]);
	
	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, CarPath);
	
	decl String:SteamId[200];
	GetClientAuthString(Player, SteamId, 200);
	decl String:CarNum[10];
	IntToString(CarEntity[Ent], CarNum, 10);
	
	KvJumpToKey(Vault, CarNum, false);
	KvSetNum(Vault, SteamId, 1);
	KvRewind(Vault);
	KeyValuesToFile(Vault, CarPath);
	CloseHandle(Vault);
	return Plugin_Handled;
}

public Action:Command_TakeCarKeys(Client, Arguments)
{
	if(Client == 0) return Plugin_Handled;
	if(Arguments < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_takecarkeys <Name>");
		return Plugin_Handled;
	}
	
	decl String:Arg2[255];
	GetCmdArg(1, Arg2, sizeof(Arg2));
	new Max, Player = -1;
	Max = GetMaxClients();
	for(new i = 1; i <= Max; i++)
	{
		if(!IsClientConnected(i))
			continue;
		new String:Other[32];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Arg2, false) != -1)
			Player = i;
	}
	if(Player == -1)
	{
		PrintToConsole(Client, "|RP| - Could not find client %s.", Arg2);
		return Plugin_Handled;
	}
	//==================
	//==================
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	
	if(Ent <= 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Entity.");
		return Plugin_Handled;
	}
	//=================
	//=================
	decl String:CarClassname[255];
	GetEdictClassname(Ent, CarClassname, 255);
	if(!StrEqual(CarClassname, "prop_vehicle_airboat"))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Look at an airboat.");
		return Plugin_Handled;
	}
	//=================
	//=================
	if(CarEntity[Ent] == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Error. This airboat has been created by something other than sm_createcar.");
		return Plugin_Handled;
	}
	if(OwnsCar[Player][CarEntity[Ent]] == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This client doesn't have the keys anyway.");
		return Plugin_Handled;
	}
	OwnsCar[Player][CarEntity[Ent]] = 0;
	
	decl String:Name[32];
	GetClientName(Player, Name, 32);
	CPrintToChat(Client, "{white}|RP| -{grey} %s has lost keys to car #%d.", Name, CarEntity[Ent]);
	CPrintToChat(Player, "{white}|RP| -{grey} You have lost keys to car #%d.", CarEntity[Ent]);
	
	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, CarPath);
	
	decl String:SteamId[200];
	GetClientAuthString(Player, SteamId, 200);
	decl String:CarNum[10];
	IntToString(CarEntity[Ent], CarNum, 10);
	
	KvJumpToKey(Vault, CarNum, false);
	KvDeleteKey(Vault, SteamId);
	KvRewind(Vault);
	KeyValuesToFile(Vault, CarPath);
	CloseHandle(Vault);
	return Plugin_Handled;
}

public Action:Command_CarID(Client, Arguments)
{
	if(Client == 0) return Plugin_Handled;
	if(Arguments > 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_carid <NO ARGS>");
		return Plugin_Handled;
	}
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	
	if(Ent <= 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Entity.");
		return Plugin_Handled;
	}
	//=================
	//=================
	decl String:CarClassname[255];
	GetEdictClassname(Ent, CarClassname, 255);
	if(!StrEqual(CarClassname, "prop_vehicle_airboat"))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Look at an airboat.");
		return Plugin_Handled;
	}
	//=================
	//=================
	if(CarEntity[Ent] == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Error. This airboat has been created by something other than sm_createcar.");
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} Car Id: #%d", CarEntity[Ent]);
	return Plugin_Handled;
}

public Action:CreateCars(Handle:Timer, any:Value)
{
	decl Handle:AddCar;
	AddCar = CreateKeyValues("Vault");
	FileToKeyValues(AddCar, CarPath);
	
	for(new X = 1; X <= MAXCARS; X++)
	{
		decl Float:Checker[3] = {101.0, 101.0, 101.0};
		decl Float:CarOrigin[3];
		decl Float:Angles[3];
		
		decl String:CarString[255];
		IntToString(X, CarString, 255);
		KvJumpToKey(AddCar, CarString, false);
		
		KvGetVector(AddCar, "Origin", CarOrigin, Checker);
		KvGetVector(AddCar, "Angle", Angles);
		
		if(CarOrigin[0] != 101.0)
		{
			decl String:OriginString[255], String:AngleString[255];
			Format(OriginString, sizeof(OriginString), "%f %f %f", CarOrigin[0], CarOrigin[1], CarOrigin[2]);
			Format(AngleString, sizeof(AngleString), "0 %f 0", Angles[1]);
			
			new ent  = CreateEntityByName("prop_vehicle_airboat");
			DispatchKeyValue(ent, "vehiclescript", "scripts/vehicles/airboat.txt");
			DispatchKeyValue(ent, "model", "models/airboat.mdl");
			DispatchKeyValue(ent, "origin", OriginString);
			DispatchKeyValue(ent, "angles", AngleString);
			DispatchKeyValue(ent, "solid", "2");
			DispatchKeyValue(ent, "skin", "0");
			DispatchKeyValue(ent, "actionScale","1");
			DispatchKeyValue(ent, "EnableGun", "0");
			DispatchKeyValue(ent, "Collisions", "1");
			DispatchKeyValue(ent, "ignorenormals", "0");
			DispatchKeyValue(ent, "fadescale", "1");
			DispatchKeyValue(ent, "fademindist", "-1");
			DispatchKeyValue(ent, "VehicleLocked", "0");
			DispatchKeyValue(ent, "screenspacefade", "0");
			DispatchKeyValue(ent, "spawnflags", "256");
			DispatchSpawn(ent);
			ActivateEntity(ent);
			AcceptEntityInput(ent, "Lock", -1);
			TeleportEntity(ent, CarOrigin, Angles, NULL_VECTOR);
			CarEntity[ent] = X;
		}
		
		KvRewind(AddCar);
	}
	KvRewind(AddCar);
	CloseHandle(AddCar);
}


//==========================================================================================
//==========================================================================================
//CUSTOM DOORS ADDON
//==========================================================================================
//==========================================================================================

public Action:CommandSpawnDoor(Client, args)
{
	if(Client == 0) return Plugin_Handled;
	
	if(args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_spawndoor <1-14 skin>");
		return Plugin_Handled;
	}
	decl String:Arg1[255];
	
	GetCmdArg(1, Arg1, sizeof(Arg1));
	
	decl Var;
	Var = StringToInt(Arg1);
	if(Var > 14 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_spawndoor <1-14 skin>");
		return Plugin_Handled;
	}
	
	decl Float:eOrigin[3], Float:eAngles[3], Float:AAngles[3], Float:looking[3];
	
	GetClientEyePosition(Client, eOrigin);
	GetClientEyeAngles(Client, eAngles);
	GetClientAbsAngles(Client, AAngles);
	
	new Handle:trace = TR_TraceRayFilterEx(eOrigin, eAngles, MASK_SOLID, RayType_Infinite, TraceEntity);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(looking, trace);
		CloseHandle(trace);
		looking[2] += 52;
		
		decl NewDoor;
		NewDoor = CreateEntityByName("prop_door_rotating");
		TeleportEntity(NewDoor, looking, AAngles, NULL_VECTOR);	
		DispatchKeyValue(NewDoor, "model", "models/props_c17/door01_left.mdl");
		DispatchKeyValue(NewDoor, "skin", Arg1);
		DispatchKeyValue(NewDoor, "hardware","1");
		DispatchKeyValue(NewDoor, "distance","90");
		DispatchKeyValue(NewDoor, "speed","100");
		DispatchKeyValue(NewDoor, "returndelay","-1");
		DispatchKeyValue(NewDoor, "spawnflags","8192");
		DispatchKeyValue(NewDoor, "axis", "131.565 1302.86 2569, 131.565 1302.86 2569");
		DispatchSpawn(NewDoor);
		ActivateEntity(NewDoor);
		SkinDoor[NewDoor] = Var;
		ServerCommand("customdoorarray %d 2", NewDoor);
		
		CPrintToChat(Client, "{white}|RP| -{grey} You spawned a door with skin #%d", Var);
		return Plugin_Handled;
	}
	CloseHandle(trace);
	return Plugin_Handled;
}

public bool:TraceEntity(entity, contentsMask)
{
	return entity > MaxClients;
}

public Action:CommandRemoveDoor(Client, args)
{
	if(Client == 0) return Plugin_Handled;
	
	decl Ent;
	decl String:ClassName[255];
	Ent = GetClientAimTarget(Client, false);
	
	GetEdictClassname(Ent, ClassName, 255);
	if(StrEqual(ClassName, "prop_door_rotating"))
	{
		if(SkinDoor[Ent] > 0)
		{
			AcceptEntityInput(Ent, "Kill", Client);
			CPrintToChat(Client, "{white}|RP| -{grey} You removed a custom door");
			SkinDoor[Ent] = 0;
			ServerCommand("customdoorarray %d 0", Ent);
			return Plugin_Handled;
		}
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot remove a map door");
		return Plugin_Handled;
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You can only remove custom made doors");
		return Plugin_Handled;
	}
}

public Action:CommandRemoveDoorP(Client, args)
{
	if(Client == 0) return Plugin_Handled;
	
	decl Ent;
	decl String:ClassName[255];
	Ent = GetClientAimTarget(Client, false);
	
	GetEdictClassname(Ent, ClassName, 255);
	if(StrEqual(ClassName, "prop_door_rotating"))
	{
		if(SkinDoor[Ent] > 0)
		{
			AcceptEntityInput(Ent, "Kill", Client);
			CPrintToChat(Client, "{white}|RP| -{grey} You permanently removed a custom door");
			SkinDoor[Ent] = 0;
			ApplyMessage(Ent, " ");
			ServerCommand("customdoorarray %d 0", Ent);
			
			decl String:DoorDel[25];
			IntToString(CatalogDoor[Ent], DoorDel, 25);
			
			decl Handle:Vault;
			Vault = CreateKeyValues("Vault");
			FileToKeyValues(Vault, DoorPath);
			KvJumpToKey(Vault, DoorDel, true);
			KvDeleteThis(Vault);
			KvRewind(Vault);
			KeyValuesToFile(Vault, DoorPath);
			CloseHandle(Vault);
			return Plugin_Handled;
		}
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot remove a map door");
		return Plugin_Handled;
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You can only remove custom made doors");
		return Plugin_Handled;
	}
}

public Action:CommandSaveDoor(Client, args)
{
	if(Client == 0) return Plugin_Handled;
	
	if(args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_savedoor <id 1-100>");
		return Plugin_Handled;
	}
	decl String:Arg1[255];
	
	GetCmdArg(1, Arg1, sizeof(Arg1));
	
	decl Var;
	Var = StringToInt(Arg1);
	if(Var > 100 || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_savedoor <id 1-100>");
		return Plugin_Handled;
	}
	
	decl Ent;
	decl String:ClassName[255];
	Ent = GetClientAimTarget(Client, false);
	
	GetEdictClassname(Ent, ClassName, 255);
	if(StrEqual(ClassName, "prop_door_rotating") && SkinDoor[Ent] > 0)
	{
		decl Float:DoorOrigin[3], Float:DoorAngles[3];
		GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", DoorOrigin);
		GetEntPropVector(Ent, Prop_Data, "m_angRotation", DoorAngles);
		
		decl Handle:Vault;
		Vault = CreateKeyValues("Vault");
		FileToKeyValues(Vault, DoorPath);
		KvJumpToKey(Vault, Arg1, true);
		
		decl Check;
		Check = KvGetNum(Vault, "Skin", 0);
		if(Check > 0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} This id number is already used. Use a different id");
			KvRewind(Vault);
			CloseHandle(Vault);
			return Plugin_Handled;
		}
		
		KvSetNum(Vault, "Skin", SkinDoor[Ent]);
		KvSetVector(Vault, "Origin", DoorOrigin);
		KvSetVector(Vault, "Angles", DoorAngles);
		KvRewind(Vault);
		KeyValuesToFile(Vault, DoorPath);
		CloseHandle(Vault);
		CPrintToChat(Client, "{white}|RP| -{grey} This door has been successfully saved");
		ServerCommand("customdoorarray %d 1", Ent);
		CatalogDoor[Ent] = Var;
		return Plugin_Handled;
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You can only save custom made doors");
		return Plugin_Handled;
	}
}

public Action:CommandListDoors(Client, args)
{
	if(Client == 0) return Plugin_Handled;
	
	CPrintToChat(Client, "{white}|RP| -{grey} Look in console for output");
	PrintToConsole(Client, "Custom Doors Used:");
	decl Handle:AddDoor;
	AddDoor = CreateKeyValues("Vault");
	FileToKeyValues(AddDoor, DoorPath);
	for(new X = 1; X <= 100; X++)
	{
		decl String:DoorString[255], String:SkinString[25];
		IntToString(X, DoorString, 255);
		KvJumpToKey(AddDoor, DoorString, false);
		decl SkinNum;
		SkinNum = KvGetNum(AddDoor, "Skin", 0);
		IntToString(SkinNum, SkinString, 25);
		
		if(SkinNum > 0)
		{
			PrintToConsole(Client, "%d", X);
			KvRewind(AddDoor);
		}
		KvRewind(AddDoor);
	}
	KvRewind(AddDoor);
	CloseHandle(AddDoor);
	return Plugin_Handled;
}


public Action:CreateDoors(Handle:Timer, any:Value)
{
	decl Handle:AddDoor;
	AddDoor = CreateKeyValues("Vault");
	FileToKeyValues(AddDoor, DoorPath);
	
	for(new X = 1; X <= 100; X++)
	{
		decl String:DoorString[255], String:SkinString[25];
		IntToString(X, DoorString, 255);
		KvJumpToKey(AddDoor, DoorString, false);
		
		decl Float:DoorOrigin[3];
		decl Float:DoorAngles[3];
		
		decl SkinNum;
		SkinNum = KvGetNum(AddDoor, "Skin", 0);
		IntToString(SkinNum, SkinString, 25);
		KvGetVector(AddDoor, "Origin", DoorOrigin);
		KvGetVector(AddDoor, "Angles", DoorAngles);
		
		if(SkinNum > 0)
		{
			decl NewDoor;
			NewDoor = CreateEntityByName("prop_door_rotating");
			TeleportEntity(NewDoor, DoorOrigin, DoorAngles, NULL_VECTOR);	
			DispatchKeyValue(NewDoor, "model", "models/props_c17/door01_left.mdl");
			DispatchKeyValue(NewDoor, "skin", SkinString);
			DispatchKeyValue(NewDoor, "hardware","1");
			DispatchKeyValue(NewDoor, "distance","90");
			DispatchKeyValue(NewDoor, "speed","100");
			DispatchKeyValue(NewDoor, "returndelay","-1");
			DispatchKeyValue(NewDoor, "spawnflags","8192");
			DispatchKeyValue(NewDoor, "axis", "131.565 1302.86 2569, 131.565 1302.86 2569");
			DispatchSpawn(NewDoor);
			ActivateEntity(NewDoor);
			SkinDoor[NewDoor] = SkinNum;
			CatalogDoor[NewDoor] = X;
			CatalogDoorInverse[X] = NewDoor;
			KvGetString(AddDoor, "Notice", Notice[NewDoor], 255, " ");
			ServerCommand("customdoorarray %d 1", NewDoor);
			KvRewind(AddDoor);
		}
	}
	KvRewind(AddDoor);
	CloseHandle(AddDoor);
}

public Action:SaveOwnerDoor(Client, args)
{
	if(Client != 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Access Denied.");
		return Plugin_Handled;
	}
	decl String:User[25];
	GetCmdArg(1, User, sizeof(User));
	decl String:UserDoor[25];
	GetCmdArg(2, UserDoor, sizeof(UserDoor));
	decl String:Mode[25];
	GetCmdArg(3, Mode, sizeof(Mode));
	decl Num1;
	Num1 = StringToInt(User);
	decl Num2;
	Num2 = StringToInt(UserDoor);
	decl Num3;
	Num3 = StringToInt(Mode);
	
	decl String:auth[40];
	GetClientAuthString(Num1, auth, 40);
	
	decl String:DatabaseNum[255];
	IntToString(CatalogDoor[Num2], DatabaseNum, 255);
	
	if(Num3 == 11)
	{	
		decl Handle:AddDoor;
		AddDoor = CreateKeyValues("Vault");
		FileToKeyValues(AddDoor, DoorPath);
		KvJumpToKey(AddDoor, DatabaseNum, false);
		KvSetNum(AddDoor, auth, 1);
		KvRewind(AddDoor);
		KeyValuesToFile(AddDoor, DoorPath);
		CloseHandle(AddDoor);
		
		CPrintToChat(Num1, "{white}|RP| -{grey} You have been given ownership to custom door #%d [Ent: %d]", CatalogDoor[Num2], Num2);
	}
	else
	{
		decl Handle:AddDoor;
		AddDoor = CreateKeyValues("Vault");
		FileToKeyValues(AddDoor, DoorPath);
		KvJumpToKey(AddDoor, DatabaseNum, false);
		KvDeleteKey(AddDoor, auth);
		KvRewind(AddDoor);
		KeyValuesToFile(AddDoor, DoorPath);
		CloseHandle(AddDoor);
		CPrintToChat(Num1, "{white}|RP| -{grey} You have lost ownership to custom door #%d [Ent: %d]", CatalogDoor[Num2], Num2);
	}
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//RP_NOTICES SCRIPT - NO MORE SERVERCOMMAND() AND RP_NOTICE SP FILE
//==========================================================================================
//==========================================================================================

stock LoadM()
{
	
	//Declare:
	decl Handle:Vault;
	
	Vault = CreateKeyValues("Vault");
	
	//Load:
	FileToKeyValues(Vault, NoticePath);
	
	
	//Declare:
	decl String:DoorId[255];
	decl String:Text[255];
	//Loop:
	for(new X = 0; X < MAXDOORS; X++)
	{
		//Convert:
		IntToString(X, DoorId, 255);
		LoadString(Vault, "owner", DoorId, "null", Text);
		if(!StrEqual(Text, "null", false))	
		{
			ApplyMessage(X, Text);
		}
	}
	
	//Close:
	CloseHandle(Vault);
}

stock ApplyMessage(DoorNumber, String:Message[255])
{
	Notice[DoorNumber] = Message;
}

public Action:CommandSetOwner(Client, Arguments)
{
	decl Ent;
	//Arguments:
	if(Arguments < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_setnotice <Ent> <1|0 Save> <String>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl String:Text[255],String:EntName[32],String:Saven[2],SavenBuffer;
	
	//Initialize:
	GetCmdArg(1, EntName, sizeof(EntName));
	GetCmdArg(2, Saven, sizeof(Saven));     
	GetCmdArg(3, Text, sizeof(Text));
	SavenBuffer = StringToInt(Saven);
	Ent = StringToInt(EntName);
	
	if(StrContains(Text, "\\", false) != -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot put a backslash in a notice");
		return Plugin_Handled;
	}
	
	if(SkinDoor[Ent] > 0 )
	{
		if(CatalogDoor[Ent] > 0)
		{
			ApplyMessage(Ent, Text);
			decl Handle:AddDoor;
			AddDoor = CreateKeyValues("Vault");
			FileToKeyValues(AddDoor, DoorPath);
			decl String:DoorNumString[25];
			IntToString(CatalogDoor[Ent], DoorNumString, 255);
			KvJumpToKey(AddDoor, DoorNumString, false);
			KvSetString(AddDoor, "Notice", Text);
			KvRewind(AddDoor);
			KeyValuesToFile(AddDoor, DoorPath);
			CloseHandle(AddDoor);
			
			CPrintToChat(Client, "Notice '%s' has been saved on Custom Door #%d.", Text, CatalogDoor[Ent]);
			return Plugin_Handled;
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} This custom door is made temporary made.  Save this door to allow notices on it!");
			return Plugin_Handled;
		}
	}
	
	ApplyMessage(Ent, Text);
	
	//Declare:
	decl Handle:Vault;
	new String:KeyBuffer[255];
	IntToString(Ent, KeyBuffer, 255);
	
	//Initialize:
	Vault = CreateKeyValues("Vault");
	
	if(StrEqual(Text, "null"))
	{
		FileToKeyValues(Vault, NoticePath);
		//Delete:
		KvJumpToKey(Vault, "owner", false);
		KvDeleteKey(Vault, KeyBuffer); 
		KvRewind(Vault);
		KeyValuesToFile(Vault, NoticePath);
		if(Client > 0)
			CPrintToChat(Client, "{white}|RP| -{grey} Notice has been removed from Entity #%d.", Ent); 
	}
	else
	{
		if(SavenBuffer == 1)
		{
			//Retrieve:
			FileToKeyValues(Vault, NoticePath);
			SaveString(Vault, "owner", KeyBuffer, Text);
			//Store:
			KeyValuesToFile(Vault, NoticePath);
			
			if(Client > 0)
				CPrintToChat(Client, "{white}|RP| -{grey} Notice '%s' has been saved on Entity #%d.", Text, Ent);  
		} else 
		{
			if(Client > 0)
				CPrintToChat(Client, "{white}|RP| -{grey} Notice '%s' has been temporary set on Entity #%d. %s %d", Text, Ent,Saven,SavenBuffer); 
		}
	}
	CloseHandle(Vault);
	return Plugin_Handled;
}

public Action:CommandSetOwner2(Client, Arguments)
{
	decl Ent;
	//Arguments:
	if(Arguments < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_looknotice <1|0 Save> <String>");
		
		//Return:
		return Plugin_Handled;
	}
	
	Ent = GetClientAimTarget(Client, false);
	if(Ent == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You must look at an entity!");
		return Plugin_Handled;
	}
	if(Ent < GetMaxClients())
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot name a person!");
		return Plugin_Handled;
	}
	
	decl String:Saven[2], String:Message[255];
	GetCmdArg(1, Saven, sizeof(Saven));
	GetCmdArg(2, Message, sizeof(Message));
	
	if(StrContains(Message, "\\", false) != -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot put a backslash in a notice");
		return Plugin_Handled;
	}
	
	new String:EntString[255];
	IntToString(Ent, EntString, 255);
	decl SaveNum;
	SaveNum = StringToInt(Saven);
	
	if(SkinDoor[Ent] > 0 )
	{
		if(CatalogDoor[Ent] > 0)
		{
			ApplyMessage(Ent, Message);
			decl Handle:AddDoor;
			AddDoor = CreateKeyValues("Vault");
			FileToKeyValues(AddDoor, DoorPath);
			decl String:DoorNumString[25];
			IntToString(CatalogDoor[Ent], DoorNumString, 255);
			KvJumpToKey(AddDoor, DoorNumString, false);
			KvSetString(AddDoor, "Notice", Message);
			KvRewind(AddDoor);
			KeyValuesToFile(AddDoor, DoorPath);
			CloseHandle(AddDoor);
			
			CPrintToChat(Client, "Notice '%s' has been saved on Custom Door #%d.", Message, CatalogDoor[Ent]);
			return Plugin_Handled;
		}
		else
		{
			CPrintToChat(Client, "{white}|RP| -{grey} This custom door is made temporary made.  Save this door to allow notices on it!");
			return Plugin_Handled;
		}
	}
	
	ApplyMessage(Ent, Message);
	
	decl Handle:Vault;
	
	//Initialize:
	Vault = CreateKeyValues("Vault");
	
	if(StrEqual(Message, "null"))
	{
		FileToKeyValues(Vault, NoticePath);
		//Delete:
		KvJumpToKey(Vault, "owner", false);
		KvDeleteKey(Vault, EntString); 
		KvRewind(Vault);
		KeyValuesToFile(Vault, NoticePath);
		if(Client > 0)
			CPrintToChat(Client, "{white}|RP| -{grey} Notice has been removed from Entity #%d.", Ent);
	}
	
	else
	{
		if(SaveNum == 1)
		{
			//Retrieve:
			FileToKeyValues(Vault, NoticePath);
			SaveString(Vault, "owner", EntString, Message);
			//Store:
			KeyValuesToFile(Vault, NoticePath);
			
			if(Client > 0)
				CPrintToChat(Client, "{white}|RP| -{grey} Notice '%s' has been saved on Entity #%d.", Message, Ent);  
		} else 
		{
			if(Client > 0)
				CPrintToChat(Client, "{white}|RP| -{grey} Notice '%s' has been temporary set on Entity #%d.", Message, Ent); 
		}
	}
	CloseHandle(Vault);
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//RP_NPCS SCRIPT - NO MORE SERVERCOMMAND() AND RP_NPCS SP FILE
//==========================================================================================
//==========================================================================================

//Create NPC:
public Action:CommandCreateNPC(Client, Args)
{
	
	//Error:
	if(Args < 3)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_createnpc <id> <NPC> <type> <opt model>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:
	decl Handle:Vault;
	decl String:Buffers[7][32];
	decl Float:Origin[3], Float:Angles[3];
	decl String:SaveBuffer[255], String:NPCId[255];
	
	//Initialize:
	GetCmdArg(1, NPCId, 32);
	GetCmdArg(2, Buffers[0], 32);
	GetCmdArg(3, Buffers[6], 32);
	GetCmdArg(4, Buffers[5], 32);
	GetClientAbsOrigin(Client, Origin);
	GetClientAbsAngles(Client, Angles);
	IntToString(RoundFloat(Origin[0]), Buffers[1], 32);
	IntToString(RoundFloat(Origin[1]), Buffers[2], 32);
	IntToString(RoundFloat(Origin[2]), Buffers[3], 32);
	IntToString(RoundFloat(Angles[1]), Buffers[4], 32);
	
	//Implode:
	ImplodeStrings(Buffers, 6, " ", SaveBuffer, 255);
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Save:
	SaveString(Vault, Buffers[6], NPCId, SaveBuffer);
	
	//Store:
	KeyValuesToFile(Vault, NPCPath);
	
	//Print:
	PrintToConsole(Client, "|RP| - Added NPC %s, npc_%s <%s, %s, %s> ZAxis: %s", NPCId, Buffers[0], Buffers[1], Buffers[2], Buffers[3], Buffers[4]);
	
	//Close:
	CloseHandle(Vault);
	
	//Live Update!
	decl NPC, String:Classname[32], String:AnglesS[32], String:PrecacheString[256];
	
	Format(AnglesS, 32, "0 %f 0", Angles[1]);
	Format(Classname, 32, "npc_%s", Buffers[0]);
	if(strlen(Buffers[5][0]) > 0)
	{
		Format(PrecacheString, 256, "models/%s.mdl", Buffers[5]);
	}
	else
	{
		Format(PrecacheString, 256, "models/%s.mdl", Buffers[0]);
	}
	
	PrecacheModel(PrecacheString, true);
	NPC = CreateEntityByName(Classname);
	DispatchKeyValue(NPC, "angles", AnglesS);
	DispatchSpawn(NPC);
	
	SetEntProp(NPC, Prop_Data, "m_takedamage", 0, 1);
	SetEntData(NPC, SolidGroup, 2, 4, true);
	
	if(Buffers[5][0]) SetEntityModel(NPC, PrecacheString);
	
	decl X, Y;
	X = StringToInt(NPCId);
	Y = StringToInt(Buffers[6]); 
	NPCList[X] = NPC;
	NPCListInverse[NPC] = X;
	NPCLiveUpdate[Y][X] = NPC;
	
	TeleportEntity(NPC, Origin, NULL_VECTOR, NULL_VECTOR);
	
	return Plugin_Handled;
}

//NPC notice:
public Action:CommandSetNotice(Client, Args)
{
	
	//Error:
	if(Args < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_npcnotice <id> <text>");
		
		//Return:
		return Plugin_Handled;
	}
	decl String:Buffers[64],String:Buffers2[255],ID,Handle:Vault; 
	GetCmdArg(1, Buffers, 64);
	GetCmdArg(2, Buffers2, 255);  
	ID = StringToInt(Buffers);
	
	if(StrContains(Buffers2, "/n", false) == -1 || StrContains(Buffers2, "\n", false) == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot put a /n or \n in a notice");
		return Plugin_Handled;
	}
	
	if(NPCList[ID])
		ApplyMessage(NPCList[ID], Buffers2);
	
	//Save
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	new String:Buffers3[255];
	Buffers3 = Buffers;
	//Save:
	SaveString(Vault, "Notice", Buffers3, Buffers2);
	
	//Store:
	KeyValuesToFile(Vault, NPCPath);
	CloseHandle(Vault);
	CPrintToChat(Client, "{white}|RP| -{grey} Notice '%s' has been set to NPC #%d.", Buffers2, ID); 
	return Plugin_Handled;  
}

//Remove NPC:
public Action:CommandNPCWho(Client, Args)
{
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	
	if(Ent > 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} NPC Id: #%d",NPCListInverse[Ent]); 
	}
	return Plugin_Handled;
}

//Remove NPC:
public Action:CommandRemoveNPC(Client, Args)
{
	
	//Error:
	if(Args < 2)
	{
		
		//Print:
		PrintToConsole(Client, "|RP| - Usage: sm_removenpc <type> <id>");
		
		//Return:
		return Plugin_Handled;
	}
	
	//Declare:	
	decl Handle:Vault;
	decl String:NPCId[255], String:Type[255];
	
	//Initialize:
	GetCmdArg(1, Type, sizeof(Type));
	GetCmdArg(2, NPCId, sizeof(NPCId));
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Delete:
	KvJumpToKey(Vault, Type, false);
	KvDeleteKey(Vault, NPCId); 
	KvRewind(Vault);
	KvJumpToKey(Vault, "Notice", false);
	KvDeleteKey(Vault, NPCId);
	KvRewind(Vault);
	
	//Store:
	KeyValuesToFile(Vault, NPCPath);
	
	decl D, E;
	D = StringToInt(NPCId);
	E = StringToInt(Type);
	
	if(NPCLiveUpdate[E][D] > 0)
	{
		AcceptEntityInput(NPCLiveUpdate[E][D], "kill");
		NPCLiveUpdate[E][D] = 0;
		NPCList[D] = 0;
	}
	
	PrintToConsole(Client, "|RP| - Removed NPC %s (Type: %s) from the database", NPCId, Type);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//List NPCs:
public Action:CommandListNPCs(Client, Args)
{
	
	//Declare:	
	decl Handle:Vault;
	
	//Vault:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Header:
	PrintToConsole(Client, "NPCs:");
	
	//Null NPCs:
	PrintNPC(Client, Vault, "-0: (Employer)", "0", MAXNPCS);
	
	//Bankers:
	PrintNPC(Client, Vault, "-1: (Bankers)", "1", MAXNPCS);
	
	//Vendors:
	PrintNPC(Client, Vault, "-2: (Vendors)", "2", MAXNPCS);
	
	//Vendors:
	PrintNPC(Client, Vault, "-3: (Auction)", "3", MAXNPCS);
	
	//Vendors:
	PrintNPC(Client, Vault, "-4: (ReBuy)", "4", MAXNPCS);
	
	//Vendors:
	PrintNPC(Client, Vault, "-5: (AucBuy)", "5", MAXNPCS);
	
	//Vendors:
	PrintNPC(Client, Vault, "-6: (Decoration)", "6", MAXNPCS);
	
	//Vendors:
	PrintNPC(Client, Vault, "-7: (Gang Seller)", "7", MAXNPCS);
	
	//Taxi Npcs
	PrintNPC(Client, Vault, "-8: (Taxi Drivers)", "8", MAXNPCS);
	
	//Equipment Npcs
	PrintNPC(Client, Vault, "-9: (Equipment)", "9", MAXNPCS);
	
	//Black Market
	PrintNPC(Client, Vault, "-10: (Black Market)", "10", MAXNPCS);
	
	//Store:
	KeyValuesToFile(Vault, NPCPath);
	
	//Close:
	CloseHandle(Vault);
	
	//Return:
	return Plugin_Handled;
}

//Create NPCs:
public Action:DrawNPCs(Handle:Timer, any:Value)
{
	
	//Declare:
	decl Handle:Vault;
	decl String:Props[255],String:Notice2[255];
	
	//Initialize:
	Vault = CreateKeyValues("Vault");
	
	//Retrieve:
	FileToKeyValues(Vault, NPCPath);
	
	//Load:
	for(new X = 0; X < MAXNPCS; X++)
	{
		
		//Declare:
		decl String:NPCId[255];
		
		//Convert:
		IntToString(X, NPCId, 255);
		
		//Types:
		for(new Y = 0; Y < 10; Y++)
		{
			
			//Declare:
			decl String:NPCType[32];
			
			//Convert:
			IntToString(Y, NPCType, 32);
			
			//Extract:
			LoadString(Vault, NPCType, NPCId, "Null", Props);
			LoadString(Vault, "Notice", NPCId, "Null", Notice2);
			
			//Found in DB:
			if(StrContains(Props, "Null", false) == -1)
			{
				
				//Declare:
				decl NPC;
				decl Float:Origin[3];
				decl String:Classname[32], String:Angles[32], String:PrecacheString[64];
				new String:Buffer[6][32];
				
				//Explode:
				ExplodeString(Props, " ", Buffer, 6, 32);
				
				//Initialize:
				Format(Angles, 32, "0 %d 0", StringToInt(Buffer[4]));
				Format(Classname, 32, "npc_%s", Buffer[0]);
				if(Buffer[5][0])
					Format(PrecacheString, 64, "models/%s.mdl", Buffer[5]);
				else
				Format(PrecacheString, 64, "models/%s.mdl", Buffer[0]); 
				
				//Precache:
				PrecacheModel(PrecacheString, true);
				
				//Initialize:
				NPC = CreateEntityByName(Classname);
				
				//Key Values:
				DispatchKeyValue(NPC, "angles", Angles);
				
				//Spawn & Send:
				DispatchSpawn(NPC);
				
				//Invincible:
				SetEntProp(NPC, Prop_Data, "m_takedamage", 0, 1);
				SetEntData(NPC, SolidGroup, 2, 4, true);
				
				//Origin:
				Origin[0] = StringToFloat(Buffer[1]);
				Origin[1] = StringToFloat(Buffer[2]);
				Origin[2] = StringToFloat(Buffer[3]);
				
				if(Buffer[5][0])
					SetEntityModel(NPC, PrecacheString);
				
				ApplyMessage(NPC, Notice2); 
				NPCList[X] = NPC;   
				NPCListInverse[NPC] = X;
				NPCLiveUpdate[Y][X] = NPC;
				
				//Teleport:
				TeleportEntity(NPC, Origin, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
	
	//Close:
	CloseHandle(Vault);
}


//==========================================================================================
//==========================================================================================
//PROP BUILDING OPTIONS:
//==========================================================================================
//==========================================================================================


public Action:FreezeProp(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	if(Ent == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You must look at an entity!");
		return Plugin_Handled;
	}
	if(Ent < GetMaxClients())
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot freeze a person!");
		return Plugin_Handled;
	}
	SetEntProp(Ent, Prop_Data, "m_takedamage", 0, 1);
	AcceptEntityInput(Ent, "DisableMotion");
	CPrintToChat(Client, "{white}|RP| -{grey} [Entity: %d] Motion disabled.", Ent);
	return Plugin_Handled;
}

public Action:UnfreezeProp(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	if(Ent == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You must look at an entity!");
		return Plugin_Handled;
	}
	if(Ent < GetMaxClients())
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot unfreeze a person!");
		return Plugin_Handled;
	}
	AcceptEntityInput(Ent, "EnableMotion");
	CPrintToChat(Client, "{white}|RP| -{grey} [Entity: %d] Motion enabled.", Ent);
	return Plugin_Handled;
}

public Action:Delete(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	
	if(Ent == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You must look at an entity!");
		return Plugin_Handled;
	}
	
	if(Ent < GetMaxClients())
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot delete a person!");
		return Plugin_Handled;
	}
	
	CheckPropOwnership(Ent);
	
	AcceptEntityInput(Ent, "Kill");
	CPrintToChat(Client, "{white}|RP| -{grey} [Entity: %d] Deleted.", Ent);
	return Plugin_Handled;
}

public Action:SetAngles(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	if(Ent == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You must look at an entity!");
		return Plugin_Handled;
	}
	if(Ent < GetMaxClients())
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot change angles on a person!");
		return Plugin_Handled;
	}
	decl String:Xaxis[5], String:Yaxis[5], String:Zaxis[5];
	GetCmdArg(1, Xaxis, sizeof(Xaxis));
	GetCmdArg(2, Yaxis, sizeof(Yaxis));
	GetCmdArg(3, Zaxis, sizeof(Zaxis));
	decl Var1, Var2, Var3;
	Var1 = 0;
	Var2 = 0;
	Var3 = 0;
	Var1 = StringToInt(Xaxis);
	Var2 = StringToInt(Yaxis);
	Var3 = StringToInt(Zaxis);
	
	new Float:Angles2[3];
	GetEntPropVector(Ent, Prop_Data, "m_angRotation", Angles2);
	Angles2[0] += Var1;
	Angles2[1] += Var2;
	Angles2[2] += Var3;
	
	TeleportEntity(Ent, NULL_VECTOR, Angles2, NULL_VECTOR);
	AcceptEntityInput(Ent, "DisableMotion");
	CPrintToChat(Client, "{white}|RP| -{grey} [Entity: %d] [Angles] %f %f %f", Ent, Angles2[0], Angles2[1], Angles2[2]);
	return Plugin_Handled;
}

public Action:SetOrigin(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	decl Ent;
	Ent = GetClientAimTarget(Client, false);
	if(Ent == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You must look at an entity!");
		return Plugin_Handled;
	}
	if(Ent < GetMaxClients())
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot change origin on a person!");
		return Plugin_Handled;
	}
	decl String:Xaxis[5], String:Yaxis[5], String:Zaxis[5];
	GetCmdArg(1, Xaxis, sizeof(Xaxis));
	GetCmdArg(2, Yaxis, sizeof(Yaxis));
	GetCmdArg(3, Zaxis, sizeof(Zaxis));
	decl Var1, Var2, Var3;
	Var1 = 0;
	Var2 = 0;
	Var3 = 0;
	Var1 = StringToInt(Xaxis);
	Var2 = StringToInt(Yaxis);
	Var3 = StringToInt(Zaxis);
	
	new Float:Origin2[3];
	GetEntPropVector(Ent, Prop_Data, "m_vecOrigin", Origin2);
	Origin2[0] += Var1;
	Origin2[1] += Var2;
	Origin2[2] += Var3;
	
	TeleportEntity(Ent, Origin2, NULL_VECTOR, NULL_VECTOR);
	AcceptEntityInput(Ent, "DisableMotion");
	CPrintToChat(Client, "{white}|RP| -{grey} [Entity: %d] [Origin] %f %f %f", Ent, Origin2[0], Origin2[1], Origin2[2]);
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//BOMB AND FIREFIGHTER FUNCTIONS:
//==========================================================================================
//==========================================================================================

//================================================
//PLAYER CLICKING E ON BOMB
//================================================
public Action:Bomb(Client, Bomb)
{
	if(IsCombine(Client) && !IsFirefighter(Client))
	{
		if(BombData[Bomb][1] == 0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You have found a bomb thats not armed. Contact a local firefighter to dispose it!");
		}
		else if(BombData[Bomb][1] == 1)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You have found a bomb thats going to blow up in less then 30 seconds.");
			CPrintToChat(Client, "{white}|RP| -{grey} Take cover or call a firefighter over to diffuse it!");
		}
		else if(BombData[Bomb][1] == 2)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} A bomb has exploded. Call a firefighter over to put the fire out.");
		}
		return Plugin_Handled;
	}
	if(IsFirefighter(Client) && GetConVarInt(FireFighterMode) == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Press <Escape> to access the firefighter menu");
		FireMenu(Client, Bomb);
		return Plugin_Handled;
	}
	if(IsFirefighter(Client) && GetConVarInt(FireFighterMode) == 1)
	{
		return Plugin_Handled;
	}
	decl Float:ClientOrigin[3], Float:BombOrigin[3], Float:Dist;
	GetEntPropVector(Bomb, Prop_Send, "m_vecOrigin", BombOrigin);
	GetClientAbsOrigin(Client, ClientOrigin);
	Dist = GetVectorDistance(ClientOrigin, BombOrigin);
	if(Dist > 100)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You are to far away from the bomb to activate.");
		return Plugin_Handled;
	}
	if(BombData[Bomb][1] > 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Bomb is already activated. Run or call for help!");
		return Plugin_Handled;
	}
	if(BombData[Bomb][5] == 2555)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Bomb has already been diffused by a firefighter.  Cannot arm again.");
		return Plugin_Handled;
	}
	if(BombData[Bomb][3] != 9999)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This is not an actual bomb. (Saved Prop)");
		return Plugin_Handled;
	}
	BombData[Bomb][1] = 1;
	CreateTimer(30.0, Explode, Bomb);
	CreateTimer(1.0, BombTick, Bomb);
	
	//EmitAmbientSound("buttons/button18.wav", BombOrigin, Bomb, SNDLEVEL_HOME);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Bomb will explode in 30 seconds.");
	SetEntityRenderColor(Bomb, 255, 0, 0, 255);
	SetEntityRenderFx(Bomb, RENDERFX_PULSE_FAST);
	AcceptEntityInput(Bomb, "disablemotion");
	AddCrime(Client, 1000);
	return Plugin_Handled;
}

//================================================
//FIREFIGHTER EASY MODE MENU
//================================================
public FireMenu(Client, Bomb)
{
	if(BombData[Bomb][1] == 0)
	{
		decl String:BombNumber[10];
		IntToString(Bomb, BombNumber, 10);
		new Handle:menu1 = CreateMenu(FireMenu1);
		SetMenuTitle(menu1, "Firefighter Actions:");
		AddMenuItem(menu1, BombNumber, "Dispose Bomb");
		SetMenuPagination(menu1, 7);
		DisplayMenu(menu1, Client, 20);
	}
	else if(BombData[Bomb][1] == 1)
	{
		decl String:BombNumber[10];
		IntToString(Bomb, BombNumber, 10);
		new Handle:menu2 = CreateMenu(FireMenu2);
		SetMenuTitle(menu2, "Firefighter Actions:");
		AddMenuItem(menu2, BombNumber, "Diffuse Bomb");
		SetMenuPagination(menu2, 7);
		DisplayMenu(menu2, Client, 20);
	}
	else if(BombData[Bomb][1] == 2)
	{
		decl String:BombNumber[10];
		IntToString(Bomb, BombNumber, 10);
		new Handle:menu3 = CreateMenu(FireMenu3);
		SetMenuTitle(menu3, "Firefighter Actions:");
		AddMenuItem(menu3, BombNumber, "Turn On Water");
		SetMenuPagination(menu3, 7);
		DisplayMenu(menu3, Client, 20);
	}
}

public FireMenu1(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		new String:BombEntNumber[64], BombNum;
		GetMenuItem(menu, param2, BombEntNumber, sizeof(BombEntNumber));
		BombNum = StringToInt(BombEntNumber);
		if(BombNum == BombNum)
		{
			if(BombData[BombNum][1] == 0)
			{
				BombEvent1(BombNum, param1);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

public FireMenu2(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		new String:BombEntNumber[64], BombNum;
		GetMenuItem(menu, param2, BombEntNumber, sizeof(BombEntNumber));
		BombNum = StringToInt(BombEntNumber);
		if(BombNum == BombNum)
		{
			if(BombData[BombNum][1] == 1)
			{
				BombEvent2(BombNum, param1);
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

public FireMenu3(Handle:menu, MenuAction:action, param1, param2)
{
	if(action == MenuAction_Select)
	{
		new String:BombEntNumber[64], BombNum;
		GetMenuItem(menu, param2, BombEntNumber, sizeof(BombEntNumber));
		BombNum = StringToInt(BombEntNumber);
		if(BombNum == BombNum)
		{
			if(BombData[BombNum][1] == 2)
			{
				WaterOn(param1);
				CPrintToChat(param1, "{white}|RP| -{grey} Type in chat /off to turn off water gun");
			}
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	return 0;
}

//================================================
//FIREFIGHTER FUNCTIONS
//================================================
//BOMB EVENT 1 - Dispose
public Action:BombEvent1(Entity, Client)
{
	if(BombData[Entity][3] != 9999)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This is not an actual bomb. (Saved Prop)");
		return Plugin_Handled;
	}
	
	decl Float:BombOrigin[3], Float:ClientOrigin[3], Float:Dist;
	GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", BombOrigin);
	GetClientAbsOrigin(Client, ClientOrigin);
	Dist = GetVectorDistance(ClientOrigin, BombOrigin);
	if(Dist <= 100 && IsBombModel(Entity))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You've disposed a bomb!");
		CPrintToChat(Client, "{white}|RP-Firefighter| -{grey}  You have received $1000 from the government.");
		Money[Client] += 1000;
		TE_SetupBeamRingPoint(BombOrigin, 1.0, 100.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TickerColor3, 10, 0);
		TE_SendToAll();
		AcceptEntityInput(Entity, "kill");
		BombData[Entity][1] = 0;
		BombData[Entity][3] = 0;
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You are to far away from the bomb to dispose.");
	return Plugin_Handled;
}

//BOMB EVENT 2 - Diffuse
public Action:BombEvent2(Entity, Client)
{
	decl Float:BombOrigin[3], Float:ClientOrigin[3], Float:Dist;
	GetEntPropVector(Entity, Prop_Send, "m_vecOrigin", BombOrigin);
	GetClientAbsOrigin(Client, ClientOrigin);
	Dist = GetVectorDistance(ClientOrigin, BombOrigin);
	if(Dist <= 100 && IsBombModel(Entity))
	{
		SetEntityMoveType(Client, MOVETYPE_NONE);
		CPrintToChat(Client, "{white}|RP| -{grey} Diffusing bomb...");
		CPrintToChat(Client, "{white}|RP| -{grey} Keep looking at the bomb to diffuse it!");
		new Handle:DataPack = CreateDataPack();
		WritePackCell(DataPack, Entity);
		WritePackCell(DataPack, Client);
		CreateTimer(0.1, DiffuseChallenge, DataPack);
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You are to far away from the bomb to diffuse.");
	return Plugin_Handled;
}

public Action:DiffuseChallenge(Handle:Timer, Handle:DataPack)
{
	ResetPack(DataPack);
	decl Player, Ent;
	Ent = ReadPackCell(DataPack);
	Player = ReadPackCell(DataPack);
	if(IsClientConnected(Player) && IsClientInGame(Player))
	{
		if(BombData[Ent][1] != 2 && BombData[Ent][4] < 100)
		{
			BombData[Ent][4] += 5;
			PrintCenterText(Player, "Bomb Diffused: %d %", BombData[Ent][4]);
			CreateTimer(0.1, DiffuseChallenge, DataPack);
			return Plugin_Handled;
		}
		if(BombData[Ent][1] == 2)
		{
			SetEntityMoveType(Player, MOVETYPE_WALK);
			PrintCenterText(Player, "You Failed To Diffuse The Bomb!");
			CloseHandle(DataPack);
			return Plugin_Handled;
		}
		if(BombData[Ent][4] == 100)
		{
			BombData[Ent][1] = 0;
			BombData[Ent][4] = 0;
			BombData[Ent][5] = 2555;
			SetEntityMoveType(Player, MOVETYPE_WALK);
			SetEntityRenderColor(Ent, 255, 255, 255, 255);
			SetEntityRenderFx(Ent, RENDERFX_NONE);
			AcceptEntityInput(Ent, "enablemotion");
			PrintCenterText(Player, "You Successfully Diffused The Bomb!");
			CPrintToChat(Player, "{white}|RP-Firefighter| -{grey}  You have received $2000 from the government.");
			Money[Player] += 2000;
			decl Float:BombOrigin[3];
			GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", BombOrigin);
			TE_SetupBeamRingPoint(BombOrigin, 1.0, 100.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TickerColor2, 10, 0);
			TE_SendToAll();
			CloseHandle(DataPack);
			return Plugin_Handled;
		}
		return Plugin_Handled;
	}
	CloseHandle(DataPack);
	return Plugin_Handled;
}

//BOMB EVENT 3 - WaterGun!
public Action:WaterOn(Client)
{
	if(WaterGun[Client] == 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Your water gun is already on");
		return Plugin_Handled;
	}
	WaterGun[Client] = 1;
	CPrintToChat(Client, "{white}|RP| -{grey} Water Gun is turning on...");
	CreateTimer(1.0, WaterGunFunc, Client);
	return Plugin_Handled;
}
public Action:WaterOff(Client)
{
	if(WaterGun[Client] == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Your water gun is already off");
		return Plugin_Handled;
	}
	WaterGun[Client] = 0;
	CPrintToChat(Client, "{white}|RP| -{grey} Water Gun is turning off.");
	return Plugin_Handled;
}

public Action:WaterGunFunc(Handle:Timer, any:Client)
{
	if(IsClientConnected(Client) && IsClientInGame(Client) && WaterGun[Client] == 1)
	{
		decl Float:eOrigin[3], Float:eAngles[3], Float:looking[3];
		
		GetClientEyePosition(Client, eOrigin);
		GetClientEyeAngles(Client, eAngles);
		
		new Handle:trace2 = TR_TraceRayFilterEx(eOrigin, eAngles, MASK_SOLID, RayType_Infinite, TraceEntity);
		
		if(TR_DidHit(trace2))
		{
			TR_GetEndPosition(looking, trace2);
			
			decl Float:ClientOrigin[3], Float:Dist, Ent;
			GetClientAbsOrigin(Client, ClientOrigin);
			ClientOrigin[2] += 30;
			Dist = GetVectorDistance(ClientOrigin, looking);
			
			Ent = GetClientAimTarget(Client, false);
			if(Ent > 1 && Dist <= 800 && IsBombModel(Ent))
			{
				if(BombData[Ent][4] > 0 && BombData[Ent][1] == 2)
				{
					PrintCenterText(Client, "Fire Health: %d", BombData[Ent][4]);
					BombData[Ent][4] -= 1;
				}
				if(BombData[Ent][4] == 0 && BombData[Ent][1] == 2)
				{
					decl Float:BombOrigin[3];
					GetEntPropVector(Ent, Prop_Send, "m_vecOrigin", BombOrigin);
					TE_SetupBeamRingPoint(BombOrigin, 1.0, 300.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TickerColor3, 10, 0);
					TE_SendToAll();
					BombData[Ent][1] = 0;
					AcceptEntityInput(Ent, "kill");
					AcceptEntityInput(BombData[Ent][2], "kill");
					AcceptEntityInput(BombData[Ent][3], "kill");
					PrintCenterText(Client, "You Successfully Cleared A Fire!");
					CPrintToChat(Client, "{white}|RP-Firefighter| -{grey}  You have received $3000 from the government.");
					Money[Client] += 3000;
				}
			}
			if(Dist <= 800)
			{
				//TE_SetupBeamPoints(ClientOrigin, looking, LaserCache, 0, 0, 50, 0.12, 5.0, 5.0, 1, 1.0, WaterColor, 0);
				//TE_SendToAll();
				TE_SetupBeamRingPoint(looking, 1.0, 150.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, WaterColor, 10, 0);
				TE_SendToAll();
				TE_SetupSmoke(looking, Water, 5.0, 50);
				TE_SendToAll();
			}
			if(Dist > 800)
			{
				PrintCenterText(Client, "Out of Range For Water Gun");
			}
			
			CloseHandle(trace2);
			CreateTimer(0.1, WaterGunFunc, Client);
		}
		else
		{
			CloseHandle(trace2);
			CreateTimer(0.1, WaterGunFunc, Client);
		}
	}
	return Plugin_Handled;
}

//================================================
//30 SECOND TICKER
//================================================
public Action:BombTick(Handle:Timer, any:Bomb)
{
	if(BombData[Bomb][1] == 1)
	{
		decl Float:BombOrigin[3];
		GetEntPropVector(Bomb, Prop_Send, "m_vecOrigin", BombOrigin);
		TE_SetupBeamRingPoint(BombOrigin, 1.0, 100.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TickerColor, 10, 0);
		TE_SendToAll();
		EmitAmbientSound("buttons/button17.wav", BombOrigin, Bomb, SNDLEVEL_HOME);
		CreateTimer(1.0, BombTick, Bomb);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

//================================================
//EXPLOSION
//================================================
public Action:Explode(Handle:Timer, any:Bomb)
{
	if(BombData[Bomb][1] != 0)
	{
		BombData[Bomb][1] = 2;
		decl Float:BombOrigin[3];
		GetEntPropVector(Bomb, Prop_Send, "m_vecOrigin", BombOrigin);
		TE_SetupBeamRingPoint(BombOrigin, 1.0, 300.0, g_BeamSprite, g_HaloSprite, 0, 10, 0.6, 5.0, 0.5, TickerColor2, 10, 0);
		TE_SendToAll();
		TE_SetupSparks(BombOrigin, NULL_VECTOR, 5, 5);
		TE_SendToAll();
		TE_SetupExplosion(BombOrigin, Smoke, 10.0, 1, 0, 100, 5000);
		TE_SendToAll();
		
		decl String:OriginString[255];
		Format(OriginString, sizeof(OriginString), "%f %f %f", BombOrigin[0], BombOrigin[1], BombOrigin[2]);
		
		new ent = CreateEntityByName("env_fire");
		
		//2 minutes on fire.
		DispatchKeyValue(ent, "origin", OriginString);
		DispatchKeyValue(ent, "health", "180");
		DispatchKeyValue(ent, "firesize", "500");
		DispatchKeyValue(ent, "fireattack", "0");
		DispatchKeyValue(ent, "firetype", "Natural");
		DispatchKeyValue(ent, "ignitionpoint", "1");
		DispatchKeyValue(ent, "damagescale", "0");
		DispatchSpawn(ent);
		AcceptEntityInput(ent, "enable");
		AcceptEntityInput(ent, "startfire");
		//TeleportEntity(ent, BombOrigin, NULL_VECTOR, NULL_VECTOR);
		BombData[Bomb][2] = ent;
		
		new ent2 = CreateEntityByName("point_hurt");
		DispatchKeyValue(ent2, "origin", OriginString);
		DispatchKeyValue(ent2, "damageradius", "95");
		DispatchKeyValue(ent2, "damage", "5");
		DispatchKeyValue(ent2, "damagedelay", "0.5");
		DispatchKeyValue(ent2, "damagetype", "8");
		DispatchSpawn(ent2);
		AcceptEntityInput(ent2, "turnon");
		//TeleportEntity(ent2, BombOrigin, NULL_VECTOR, NULL_VECTOR);
		BombData[Bomb][3] = ent2;
		
		//Health HUD: (Default 300)
		BombData[Bomb][4] = 300;
		
		CreateTimer(180.0, DeleteEnt, Bomb);
	}
	return Plugin_Handled;
}

//Kill Fire and Hurt Ents After 2 Min
public Action:DeleteEnt(Handle:Timer, any:Bomb)
{
	if(BombData[Bomb][1] == 2 && IsBombModel(Bomb))
	{
		AcceptEntityInput(Bomb, "kill");
		AcceptEntityInput(BombData[Bomb][2], "kill");
		AcceptEntityInput(BombData[Bomb][3], "kill");
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//LOCKS:
//==========================================================================================
//==========================================================================================

public Action:Command_NumberLocks(Client, Args)
{
	if(GetConVarInt(Locks) == 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Server Owner disabled this command.");
		return Plugin_Handled;
	}
	decl DoorEnt;
	decl String:ClassName[255];
	DoorEnt = GetClientAimTarget(Client, false);
	if(DoorEnt == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} No Door Selected.");
		return Plugin_Handled;
	}
	
	GetEdictClassname(DoorEnt, ClassName, 255);
	
	if(DoorEnt > 1)
	{
		if(StrEqual(ClassName, "func_door") || StrEqual(ClassName, "func_door_rotating") || StrEqual(ClassName, "prop_door_rotating"))
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Door #%d has %d Locks", DoorEnt, DoorLocks[DoorEnt]);
		}
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} No Door Selected.");
	}
	return Plugin_Handled;
}

//==========================================================================================
//==========================================================================================
//ROULETTE:
//==========================================================================================
//==========================================================================================

stock LoadWheel()
{
	decl Handle:Vault;
	Vault = CreateKeyValues("Vault");
	FileToKeyValues(Vault, RoulettePath);
	
	decl String:NumberSpot[20];
	
	for(new X = 1; X < 38; X++)
	{
		IntToString(X, NumberSpot, 20);
		KvJumpToKey(Vault, "WheelNumbers", false);
		WheelNumber[X] = KvGetNum(Vault, NumberSpot, 0);
		KvRewind(Vault);
		
		KvJumpToKey(Vault, "WheelColor", false);
		WheelColor[X] = KvGetNum(Vault, NumberSpot, 0);
		KvRewind(Vault);
		
		KvJumpToKey(Vault, "WheelNumberType", false);
		WheelNumberType[X] = KvGetNum(Vault, NumberSpot, 0);
		KvRewind(Vault);
		
		//PrintToServer("%d-%d-%d", WheelNumber[X], WheelColor[X], WheelNumberType[X]);
	}
	CloseHandle(Vault);
	
	decl Handle:Vault2;
	Vault2 = CreateKeyValues("Gambling");
	FileToKeyValues(Vault2, RouletteOrigins);
	
	decl Float:Err[3] = {69.0, 69.0, 69.0};
	for(new Y = 1; Y < MAXGAMBLING; Y++)
	{
		decl String:GamidS[25];
		IntToString(Y, GamidS, 25);
		KvJumpToKey(Vault2, GamidS, true);
		KvGetVector(Vault2, "Origin", GamblingOrigin[Y], Err);
		KvGetString(Vault2, "Owner", GamblingOwner[Y], 255, "Error");
		RouletteBalance[Y] = KvGetNum(Vault2, "Balance", 0);
		Casino[Y] = KvGetNum(Vault2, "Operation", 0);
		CasinoMaxBet[Y] = KvGetNum(Vault2, "MaxBet", 0);
		KvRewind(Vault2);
	}
	KvRewind(Vault2);
	CloseHandle(Vault2);
	
	decl Handle:Vault3;
	Vault3 = CreateKeyValues("Vault");
	FileToKeyValues(Vault3, NamePath);
	KvJumpToKey(Vault3, "name", true);
	for(new Z = 1; Z < MAXGAMBLING; Z++)
	{
		KvGetString(Vault3, GamblingOwner[Z], GamblingOwnerName[Z], 255, "No Owner");
	}
	KvRewind(Vault3);
	CloseHandle(Vault3);
}

public Action:CommandAddGambling(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_addgamblingzone <id>");
		return Plugin_Handled;
	}
	decl String:Gam1[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	decl Var;
	Var = StringToInt(Gam1);
	if(Var > MAXGAMBLING || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_addgamblingzone <1 - %d>", MAXGAMBLING);
		return Plugin_Handled;
	}
	if(GamblingOrigin[Var][0] != 69.0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} This gambling zone has already been made");
		return Plugin_Handled;
	}
	
	decl Handle:GamZone;
	GamZone = CreateKeyValues("Gambling");
	FileToKeyValues(GamZone, RouletteOrigins);
	
	decl Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	
	KvJumpToKey(GamZone, Gam1, true);
	KvSetVector(GamZone, "Origin", Origin);
	KvRewind(GamZone);
	KeyValuesToFile(GamZone, RouletteOrigins);
	CloseHandle(GamZone);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Added Gambling Position [ID: %s] at coordinate [%f %f %f]", Gam1, Origin[0], Origin[1], Origin[2]);
	GamblingOrigin[Var][0] = Origin[0];
	GamblingOrigin[Var][1] = Origin[1];
	GamblingOrigin[Var][2] = Origin[2];
	GamblingOwner[Var] = "Error";
	GamblingOwnerName[Var] = "No Owner";
	Casino[Var] = 0;
	CasinoMaxBet[Var] = 0;
	RouletteBalance[Var] = 0;
	
	return Plugin_Handled;
}

public Action:CommandRemGambling(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_removegamblingzone <id>");
		return Plugin_Handled;
	}
	decl String:Gam1[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	decl Var;
	Var = StringToInt(Gam1);
	if(Var > MAXGAMBLING || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_removegamblingzone <1 - %d>", MAXGAMBLING);
		return Plugin_Handled;
	}
	
	CPrintToChat(Client, "{white}|RP| -{grey} Deleted Gambling Position [ID: %s]", Gam1);
	
	decl Handle:GamZone;
	GamZone = CreateKeyValues("Gambling");
	FileToKeyValues(GamZone, RouletteOrigins);
	KvJumpToKey(GamZone, Gam1, true);
	
	decl String:SteamId[255];
	KvGetString(GamZone, "Owner", SteamId, 255, "Error");
	decl Balance;
	Balance = KvGetNum(GamZone, "Balance", 0);
	KvDeleteThis(GamZone);
	KvRewind(GamZone);
	KeyValuesToFile(GamZone, RouletteOrigins);
	CloseHandle(GamZone);
	
	GamblingOrigin[Var][0] = 69.0;
	GamblingOrigin[Var][1] = 69.0;
	GamblingOrigin[Var][2] = 69.0;
	GamblingOwner[Var] = "Error";
	GamblingOwnerName[Var] = "No Owner";
	Casino[Var] = 0;
	CasinoMaxBet[Var] = 0;
	RouletteBalance[Var] = 0;
	
	if(StrEqual(SteamId, "Error", false))
	{
		return Plugin_Handled;
	}
	
	CPrintToChat(Client, "{white}|RP| -{grey} Located Owner of Gambling Zone #%d and casino balance has been added to owner's bank.", Var);
	
	decl MaxPlayers;
	MaxPlayers = GetMaxClients();
	for(new i = 1; i <= MaxPlayers; i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			decl String:SteamIdi[200];
			GetClientAuthString(i, SteamIdi, 200);
			if(StrEqual(SteamIdi, SteamId, false))
			{
				Bank[i] += Balance;
				i = 999;
				return Plugin_Handled;
			}
		}
	}
	//Person is not in server:
	decl Refresh;
	Refresh = LoadInteger(h_database, "Bank", SteamId, DEFAULTBANK);
	Refresh += Balance;
	SaveInteger(Client, h_database, "Bank", SteamId, Refresh);
	return Plugin_Handled;
}

public Action:CommandListGambling(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args > 0)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_listgamblingzones <No Args>");
		return Plugin_Handled;
	}
	decl Handle:GamZone;
	GamZone = CreateKeyValues("Gambling");
	FileToKeyValues(GamZone, RouletteOrigins);
	
	decl String:MapName[64];
	GetCurrentMap(MapName, 64);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Look in console for output");
	PrintToConsole(Client, "-|Gambling Zones] IDs Used [%s]:", MapName);
	PrintToConsole(Client, "=========================");
	
	decl Float:Err[3] = {69.0, 69.0, 69.0};
	
	for(new Gamid = 1; Gamid <= MAXGAMBLING; Gamid++)
	{
		decl String:GamidS[255];
		IntToString(Gamid, GamidS, 255);
		
		KvJumpToKey(GamZone, GamidS, true);
		KvGetVector(GamZone, "Origin", GamblingOrigin[Gamid], Err);
		if(GamblingOrigin[Gamid][0] == 69.0)
		{
			PrintToConsole(Client, "%d) Zone Not Used", Gamid);
			KvRewind(GamZone);
		}
		else
		{
			PrintToConsole(Client, "%d) %f %f %f", Gamid, GamblingOrigin[Gamid][0], GamblingOrigin[Gamid][1], GamblingOrigin[Gamid][2]);
			KvRewind(GamZone);
		}
	}
	KvRewind(GamZone);
	CloseHandle(GamZone);
	return Plugin_Handled;
}

public Action:CommandAddOwnerGam(Client,Args)
{
	decl Player; 
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_setgamblingowner <name> <zone id>");
		return Plugin_Handled;     
	}
	if(Args == 2)
	{
		decl String:PlayerName[32];
		decl MaxPlayers; 
		decl String:Name[32];
		new Zone; 
		decl String:ZoneS[32];
		
		GetCmdArg(1, PlayerName, sizeof(PlayerName));
		GetCmdArg(2, ZoneS, sizeof(ZoneS));
		Zone = StringToInt(ZoneS); 
		if(Zone > MAXGAMBLING || Zone < 1)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} sm_setgamblingowner <name> <1 - %d>", MAXGAMBLING);
			return Plugin_Handled;
		} 
		
		//Find:
		MaxPlayers = GetMaxClients();
		for(new X = 1; X <= MaxPlayers; X++)
		{
			
			//Connected:
			if(!IsClientConnected(X)) continue;
			//Initialize:
			GetClientName(X, Name, sizeof(Name));
			
			//Save:
			if(StrContains(Name, PlayerName, false) != -1) Player = X;
		}
		
		//Invalid Name:
		if(Player == -1)
		{
			
			//Print:
			PrintToConsole(Client, "|RP| - Could not find client %s", PlayerName);
			
			//Return:
			return Plugin_Handled;
		}
		
		if(GamblingOrigin[Zone][0] == 69.0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You must make a gambling zone first before setting up an owner.");
			return Plugin_Handled;
		}
		
		GetClientName(Client, Name, sizeof(Name));
		GetClientName(Player, PlayerName, sizeof(PlayerName));
		
		decl String:SteamId[200];
		GetClientAuthString(Player, SteamId, 200);
		
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, ZoneS, true);
		
		decl String:SteamId2[255];
		KvGetString(GamZone, "Owner", SteamId2, 255, "Error");
		if(!StrEqual(SteamId2, "Error", false))
		{
			CPrintToChat(Client, "{white}|RP| -{grey} There is already an owner for this gambling zone.");
			KvRewind(GamZone);
			CloseHandle(GamZone);
			return Plugin_Handled;
		}
		
		KvSetString(GamZone, "Owner", SteamId);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		
		GamblingOwner[Zone] = SteamId;
		GamblingOwnerName[Zone] = PlayerName;
		Casino[Zone] = 0;
		CasinoMaxBet[Zone] = 0;
		RouletteBalance[Zone] = 0;
		
		PrintToConsole(Client, "|RP| - Gave ownership of gambling zone [%d] to %s", Zone, PlayerName);
		CPrintToChat(Player, "{white}|RP| -{grey} You received ownership of gambling zone #%d", Zone);
		return Plugin_Handled;
	}
	return Plugin_Handled;
}

public Action:CommandRemOwnerGam(Client,Args)
{
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_removegamblingowner <zone id>");
		return Plugin_Handled;     
	}
	if(Args == 1)
	{
		new Zone; 
		decl String:ZoneS[32];
		
		GetCmdArg(1, ZoneS, sizeof(ZoneS));
		Zone = StringToInt(ZoneS); 
		if(Zone > MAXGAMBLING || Zone < 1)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} sm_removegamblingowner <1 - %d>", MAXGAMBLING);
			return Plugin_Handled;
		}
		
		if(GamblingOrigin[Zone][0] == 69.0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} This gambling zone does not exist.");
			return Plugin_Handled;
		}
		
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, ZoneS, true);
		decl String:SteamId[255];
		KvGetString(GamZone, "Owner", SteamId, 255, "Error");
		KvSetNum(GamZone, "Operation", 0);
		
		if(StrEqual(SteamId, "Error", false))
		{
			CPrintToChat(Client, "{white}|RP| -{grey} No owner is found with this id.");
			KvRewind(GamZone);
			CloseHandle(GamZone);
			return Plugin_Handled;
		}
		CPrintToChat(Client, "{white}|RP| -{grey} Owner has been removed and casino balance has been added to owner's bank.");
		
		decl Balance;
		Balance = KvGetNum(GamZone, "Balance", 0);
		
		KvDeleteKey(GamZone, "Owner");
		KvDeleteKey(GamZone, "Balance");
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		
		GamblingOwner[Zone] = "Error";
		GamblingOwnerName[Zone] = "No Owner";
		Casino[Zone] = 0;
		CasinoMaxBet[Zone] = 0;
		RouletteBalance[Zone] = 0;
		
		decl MaxPlayers;
		MaxPlayers = GetMaxClients();
		for(new i = 1; i <= MaxPlayers; i++)
		{
			if(IsClientConnected(i) && IsClientInGame(i))
			{
				decl String:SteamIdi[200];
				GetClientAuthString(i, SteamIdi, 200);
				if(StrEqual(SteamIdi, SteamId, false))
				{
					Bank[i] += Balance;
					i = 999;
					return Plugin_Handled;
				}
			}
		}
		//Person is not in server:
		decl Refresh;
		Refresh = LoadInteger(h_database, "Bank", SteamId, DEFAULTBANK);
		Refresh += Balance;
		SaveInteger(Client, h_database, "Bank", SteamId, Refresh);
		
		return Plugin_Handled;
	}
	PrintToConsole(Client, "|RP| - Wrong Parameter. Usage: sm_removegamblingowner <zone id>");
	return Plugin_Handled;
}

//Owner of Casino Commands:

public Action:CommandListOwnedCasinos(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	decl String:Owner[200];
	GetClientAuthString(Client, Owner, 200);
	
	CPrintToChat(Client, "{white}|RP| -{grey} Your Casinos:");
	CPrintToChat(Client, "{white}|RP| -{grey} [ID] [BALANCE] [MAXBETTING] [STATUS]");
	
	for(new Find = 1; Find <= MAXGAMBLING; Find++)
	{
		if(StrEqual(Owner, GamblingOwner[Find], false))
		{
			if(Casino[Find] == 1)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} #%d - $%d - $%d - Opened", Find, RouletteBalance[Find], CasinoMaxBet[Find]);
			}
			else
			{
				CPrintToChat(Client, "{white}|RP| -{grey} #%d - $%d - $%d - Closed", Find, RouletteBalance[Find], CasinoMaxBet[Find]);
			}
		}
	}
	return Plugin_Handled;
}

public Action:CommandAddCasinoBalance(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_givecasinomoney <id> <amount>");
		return Plugin_Handled;
	}
	decl String:Gam1[32], String:Gam2[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	GetCmdArg(2, Gam2, sizeof(Gam2));
	decl Var, Var2;
	Var = StringToInt(Gam1);
	Var2 = StringToInt(Gam2);
	if(Var > MAXGAMBLING || Var < 1 || Var2 <= 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_givecasinomoney <1 - %d> <amount>", MAXGAMBLING);
		return Plugin_Handled;
	}
	decl String:Owner[200];
	GetClientAuthString(Client, Owner, 200);
	if(StrEqual(Owner, GamblingOwner[Var], false))
	{
		decl Check;
		Check = Bank[Client] - Var2;
		if(Check < 0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You cannot have your bank go into a negative balance with casinos.");
			return Plugin_Handled;
		}
		CPrintToChat(Client, "{white}|RP| -{grey} You've given $%d to Casino #%d", Var2, Var);
		Bank[Client] -= Var2;
		RouletteBalance[Var] += Var2;
		Save(Client);
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, Gam1, true);
		KvSetNum(GamZone, "Balance", RouletteBalance[Var]);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You do not own casino #%d", Var);
	return Plugin_Handled;
}

public Action:CommandSubtractCasinoBalance(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_takecasinomoney <id> <amount>");
		return Plugin_Handled;
	}
	decl String:Gam1[32], String:Gam2[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	GetCmdArg(2, Gam2, sizeof(Gam2));
	decl Var, Var2;
	Var = StringToInt(Gam1);
	Var2 = StringToInt(Gam2);
	if(Var > MAXGAMBLING || Var < 1 || Var2 <= 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_takecasinomoney <1 - %d> <amount>", MAXGAMBLING);
		return Plugin_Handled;
	}
	decl String:Owner[200];
	GetClientAuthString(Client, Owner, 200);
	if(StrEqual(Owner, GamblingOwner[Var], false))
	{
		decl Check;
		Check = RouletteBalance[Var] - Var2;
		if(Check < 0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You cannot have a casino go into a negative balance");
			return Plugin_Handled;
		}
		CPrintToChat(Client, "{white}|RP| -{grey} You've taken $%d from Casino #%d", Var2, Var);
		Bank[Client] += Var2;
		RouletteBalance[Var] -= Var2;
		Save(Client);
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, Gam1, true);
		KvSetNum(GamZone, "Balance", RouletteBalance[Var]);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You do not own casino #%d", Var);
	return Plugin_Handled;
}

public Action:CommandOpenCasino(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_opencasino <casino id>");
		return Plugin_Handled;
	}
	decl String:Gam1[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	decl Var;
	Var = StringToInt(Gam1);
	if(Var > MAXGAMBLING || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_opencasino <1 - %d>", MAXGAMBLING);
		return Plugin_Handled;
	}
	decl String:Owner[200];
	GetClientAuthString(Client, Owner, 200);
	if(StrEqual(Owner, GamblingOwner[Var], false))
	{
		if(Casino[Var] == 1)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Casino #%d is already opened", Var);
			return Plugin_Handled;
		}
		CPrintToChat(Client, "{white}|RP| -{grey} You've opened Casino #%d", Var);
		Casino[Var] = 1;
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, Gam1, true);
		KvSetNum(GamZone, "Operation", 1);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You do not own casino #%d", Var);
	return Plugin_Handled;
}

public Action:CommandCloseCasino(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_closecasino <casino id>");
		return Plugin_Handled;
	}
	decl String:Gam1[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	decl Var;
	Var = StringToInt(Gam1);
	if(Var > MAXGAMBLING || Var < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_closecasino <1 - %d>", MAXGAMBLING);
		return Plugin_Handled;
	}
	decl String:Owner[200];
	GetClientAuthString(Client, Owner, 200);
	if(StrEqual(Owner, GamblingOwner[Var], false))
	{
		if(Casino[Var] == 0)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} Casino #%d is already closed", Var);
			return Plugin_Handled;
		}
		CPrintToChat(Client, "{white}|RP| -{grey} You've closed Casino #%d", Var);
		Casino[Var] = 0;
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, Gam1, true);
		KvSetNum(GamZone, "Operation", 0);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You do not own casino #%d", Var);
	return Plugin_Handled;
}

public Action:CommandCasinoMaxBet(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 2)
	{
		PrintToConsole(Client, "|RP| - Usage: sm_maxbet <casino id> <amount>");
		return Plugin_Handled;
	}
	decl String:Gam1[32], String:Gam2[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	GetCmdArg(2, Gam2, sizeof(Gam2));
	decl Var, Var2;
	Var = StringToInt(Gam1);
	Var2 = StringToInt(Gam2);
	if(Var > MAXGAMBLING || Var < 1 || Var2 < 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} sm_maxbet <1 - %d> <amount>", MAXGAMBLING);
		return Plugin_Handled;
	}
	decl String:Owner[200];
	GetClientAuthString(Client, Owner, 200);
	if(StrEqual(Owner, GamblingOwner[Var], false))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Max betting amount on Casino #%d is now $%d", Var, Var2);
		CasinoMaxBet[Var] = Var2;
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, Gam1, true);
		KvSetNum(GamZone, "MaxBet", Var2);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		return Plugin_Handled;
	}
	CPrintToChat(Client, "{white}|RP| -{grey} You do not own casino #%d", Var);
	return Plugin_Handled;
}

public Action:CommandCasinoBetTypes(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	CPrintToChat(Client, "{white}|RP| -{grey} Casino Betting Types:");
	CPrintToChat(Client, "red, black, odd, even, 1-12, 13-24, 25-36, 1-18, 19-36, or any number (ex. 20 [1 to 37 chance])");
	return Plugin_Handled;
}

public Action:CommandCasinoCmds(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	CPrintToChat(Client, "{white}|RP| -{grey} Casino Commands:");
	CPrintToChat(Client, "sm_mycasinos - list your casinos");
	CPrintToChat(Client, "sm_opencasino - open a casino");
	CPrintToChat(Client, "sm_closecasino - close a casino");
	CPrintToChat(Client, "sm_maxbet - maximum someone could bet");
	CPrintToChat(Client, "sm_givecasinomoney - give casino money");
	CPrintToChat(Client, "sm_takecasinomoney - take casino money");
	return Plugin_Handled;
}

public Action:CommandCasinoBet(Client,Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_bet <type> <amount> (Use sm_bettypes for help)");
		return Plugin_Handled;
	}
	decl String:Gam1[32], String:Gam2[32];
	GetCmdArg(1, Gam1, sizeof(Gam1));
	GetCmdArg(2, Gam2, sizeof(Gam2));
	decl Var, VarOneNumber;
	VarOneNumber = StringToInt(Gam1);
	Var = StringToInt(Gam2);
	if(Var <= 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_bet <type> <amount> (Use sm_bettypes for help)");
		return Plugin_Handled;
	}
	
	if(BettingProtection[Client] == 1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot bet while the roulette wheel is spinning.");
		return Plugin_Handled;
	}
	if(!IsGambling(Client))
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You are not in a gambling zone.");
		return Plugin_Handled;
	}
	if(IsCuffed[Client])
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot gamble when your cuffed.");
		return Plugin_Handled;
	}
	decl Check;
	Check = Money[Client] - Var;
	if(Check < 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You cannot have negative money with betting.");
		return Plugin_Handled;
	}
	
	decl Float:Check2, Float:YourOrigin[3];
	GetClientAbsOrigin(Client, YourOrigin);
	YourOrigin[2] += 40.0;
	for(new GamZones = 1; GamZones <= MAXGAMBLING; GamZones++)
	{
		Check2 = GetVectorDistance(GamblingOrigin[GamZones], YourOrigin);
		if(Check2 <= 150 && GamblingOrigin[GamZones][0] != 69.0)
		{
			if(Casino[GamZones] == 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} This Casino is closed.");
				GamZones = 9999;
				return Plugin_Handled;
			}
			if(RouletteBalance[GamZones] == 0)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} This Casino has no money.");
				GamZones = 9999;
				return Plugin_Handled;
			}
			if(Var > CasinoMaxBet[GamZones])
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You are betting more than the max bet limit (Betting is limited to a maximum of $%d for this zone)", CasinoMaxBet[GamZones]);
				GamZones = 9999;
				return Plugin_Handled;
			}
			if(RouletteBalance[GamZones] < Var)
			{
				CPrintToChat(Client, "{white}|RP| -{grey} You cannot bet more then what the casino has (This Casino has $%d)", RouletteBalance[GamZones]);
				GamZones = 9999;
				return Plugin_Handled;
			}
			if(StrEqual(Gam1, "red", false)) BettingFunction(Client, Var, GamZones, 1, 0);
			else if(StrEqual(Gam1, "black", false)) BettingFunction(Client, Var, GamZones, 2, 0);
			else if(StrEqual(Gam1, "even", false)) BettingFunction(Client, Var, GamZones, 3, 0);
			else if(StrEqual(Gam1, "odd", false)) BettingFunction(Client, Var, GamZones, 4, 0);
			else if(StrEqual(Gam1, "1-12", false)) BettingFunction(Client, Var, GamZones, 5, 0);
			else if(StrEqual(Gam1, "13-24", false)) BettingFunction(Client, Var, GamZones, 6, 0);
			else if(StrEqual(Gam1, "25-36", false)) BettingFunction(Client, Var, GamZones, 7, 0);
			else if(StrEqual(Gam1, "1-18", false)) BettingFunction(Client, Var, GamZones, 8, 0);
			else if(StrEqual(Gam1, "19-36", false)) BettingFunction(Client, Var, GamZones, 9, 0);
			else
			{
				BettingFunction(Client, Var, GamZones, VarOneNumber, 1);
			}
			BettingProtection[Client] = 1;
			GamZones = 9999;
		}
	}
	return Plugin_Handled;
}

stock BettingFunction(Client, BettingMoney, ZoneId, Mode, Opt)
{
	if(Opt == 1 && Mode <= 37 && Mode >= 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} You are betting #%d for $%d.", Mode, BettingMoney);
		new Handle:DataPack = CreateDataPack();
		WritePackCell(DataPack, ZoneId);
		WritePackCell(DataPack, BettingMoney);
		WritePackCell(DataPack, Client);
		WritePackCell(DataPack, Mode);
		WritePackCell(DataPack, Opt);
		WheelMode[Client] = 0;
		Money[Client] -= BettingMoney;
		RouletteBalance[ZoneId] += BettingMoney;
		
		decl String:IdS[20];
		IntToString(ZoneId, IdS, sizeof(IdS));
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, IdS, true);
		KvSetNum(GamZone, "Balance", RouletteBalance[ZoneId]);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		
		CreateTimer(0.1, BettingLive, DataPack);
	}
	else if(Opt == 0)
	{
		if(Mode == 1) CPrintToChat(Client, "{white}|RP| -{grey} You are betting red for $%d.", BettingMoney);
		else if(Mode == 2) CPrintToChat(Client, "{white}|RP| -{grey} You are betting black for $%d.", BettingMoney);
		else if(Mode == 3) CPrintToChat(Client, "{white}|RP| -{grey} You are betting even for $%d.", BettingMoney);
		else if(Mode == 4) CPrintToChat(Client, "{white}|RP| -{grey} You are betting odd for $%d.", BettingMoney);
		else if(Mode == 5) CPrintToChat(Client, "{white}|RP| -{grey} You are betting 1-12 for $%d.", BettingMoney);
		else if(Mode == 6) CPrintToChat(Client, "{white}|RP| -{grey} You are betting 13-24 for $%d.", BettingMoney);
		else if(Mode == 7) CPrintToChat(Client, "{white}|RP| -{grey} You are betting 25-36 for $%d.", BettingMoney);
		else if(Mode == 8) CPrintToChat(Client, "{white}|RP| -{grey} You are betting 1-18 for $%d.", BettingMoney);
		else if(Mode == 9) CPrintToChat(Client, "{white}|RP| -{grey} You are betting 19-36 for $%d.", BettingMoney);
		new Handle:DataPack = CreateDataPack();
		WritePackCell(DataPack, ZoneId);
		WritePackCell(DataPack, BettingMoney);
		WritePackCell(DataPack, Client);
		WritePackCell(DataPack, Mode);
		WritePackCell(DataPack, Opt);
		WheelMode[Client] = 0;
		Money[Client] -= BettingMoney;
		RouletteBalance[ZoneId] += BettingMoney;
		
		decl String:IdS[20];
		IntToString(ZoneId, IdS, sizeof(IdS));
		decl Handle:GamZone;
		GamZone = CreateKeyValues("Gambling");
		FileToKeyValues(GamZone, RouletteOrigins);
		KvJumpToKey(GamZone, IdS, true);
		KvSetNum(GamZone, "Balance", RouletteBalance[ZoneId]);
		KvRewind(GamZone);
		KeyValuesToFile(GamZone, RouletteOrigins);
		CloseHandle(GamZone);
		
		CreateTimer(0.1, BettingLive, DataPack);
	}
	else
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Unknown Betting Typing. Use sm_bettypes for more information.");
	}
}

public Action:BettingLive(Handle:Timer, Handle:DataPack)
{
	ResetPack(DataPack);
	decl Client, BetMoney, Id, Mode, Opt;
	Id = ReadPackCell(DataPack);
	BetMoney = ReadPackCell(DataPack);
	Client = ReadPackCell(DataPack);
	Mode = ReadPackCell(DataPack);
	Opt = ReadPackCell(DataPack);
	
	if(IsClientConnected(Client) && IsClientInGame(Client))
	{
		if(WheelMode[Client] == 0)
		{
			WheelPosition[Client] = GetRandomInt(0, 37);
			RandomTiming[Client] = GetRandomInt(50, 125);
			WheelMode[Client] = 1;
		}
		if(WheelMode[Client] > 0 && WheelMode[Client] < RandomTiming[Client])
		{
			WheelMode[Client] += 1;
			
			decl Left, Right;
			WheelPosition[Client] += 1;
			Left = WheelPosition[Client] - 1;
			Right = WheelPosition[Client] + 1;
			
			if(WheelPosition[Client] == 37)
			{
				Right = 1;
			}
			else if(WheelPosition[Client] == 38)
			{
				WheelPosition[Client] = 1;
				Left = 37;
				Right = 2;
			}
			PrintCenterText(Client, "Roulette: %d [%d] %d", WheelNumber[Left], WheelNumber[WheelPosition[Client]], WheelNumber[Right]);
			CreateTimer(0.1, BettingLive, DataPack);
			return Plugin_Handled;
		}
		if(WheelMode[Client] == RandomTiming[Client])
		{
			decl Earnings;
			if(Opt == 0)
			{
				if(Mode == 1 && WheelColor[WheelPosition[Client]] == 1)
				{
					Earnings = BetMoney*2;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 2 && WheelColor[WheelPosition[Client]] == 2)
				{
					Earnings = BetMoney*2;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 3 && WheelNumberType[WheelPosition[Client]] == 2)
				{
					Earnings = BetMoney*2;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 4 && WheelNumberType[WheelPosition[Client]] == 1)
				{
					Earnings = BetMoney*2;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 5 && WheelNumber[WheelPosition[Client]] > 0 && WheelNumber[WheelPosition[Client]] <= 12)
				{
					Earnings = BetMoney*3;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 6 && WheelNumber[WheelPosition[Client]] > 12 && WheelNumber[WheelPosition[Client]] <= 24)
				{
					Earnings = BetMoney*3;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 7 && WheelNumber[WheelPosition[Client]] > 24 && WheelNumber[WheelPosition[Client]] <= 36)
				{
					Earnings = BetMoney*3;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 8 && WheelNumber[WheelPosition[Client]] > 0 && WheelNumber[WheelPosition[Client]] <= 18)
				{
					Earnings = BetMoney*2;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else if(Mode == 9 && WheelNumber[WheelPosition[Client]] > 18 && WheelNumber[WheelPosition[Client]] <= 36)
				{
					Earnings = BetMoney*2;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You lost the bet");
				}
			}
			if(Opt == 1)
			{
				if(WheelNumber[WheelPosition[Client]] == Mode)
				{
					Earnings = BetMoney*37;
					if(RouletteBalance[Id] >= Earnings)
					{
						RouletteBalance[Id] -= Earnings;
						Money[Client] += Earnings;
						CPrintToChat(Client, "{white}|RP| -{grey} You've won $%d!", Earnings);
					}
					else
					{
						Money[Client] += RouletteBalance[Id];
						Money[Client] += BetMoney;
						CPrintToChat(Client, "{white}|RP| -{grey} You've took all the money from the gambling zone! ($%d)", RouletteBalance[Id]);
						RouletteBalance[Id] = 0;
					}
				}
				else
				{
					CPrintToChat(Client, "{white}|RP| -{grey} You lost the bet");
				}
			}
			BettingProtection[Client] = 0;
			Save(Client);
			CloseHandle(DataPack);
			
			decl String:Color[30], String:Type[30];
			if(WheelColor[WheelPosition[Client]] == 1) Color = "-|Red|-";
			if(WheelColor[WheelPosition[Client]] == 2) Color = "-|Black|-";
			if(WheelColor[WheelPosition[Client]] == 0) Color = "-|Zero|-";
			if(WheelNumberType[WheelPosition[Client]] == 2) Type = "-|Even|-";
			if(WheelNumberType[WheelPosition[Client]] == 1) Type = "-|Odd|-";
			if(WheelNumberType[WheelPosition[Client]] == 0) Type = "-|Zero|-";
			
			PrintCenterText(Client, "Landed On: %d - %s - %s", WheelNumber[WheelPosition[Client]], Color, Type);
			CPrintToChat(Client, "{white}|RP| -{grey} Landed On: %d - %s - %s", WheelNumber[WheelPosition[Client]], Color, Type);
			
			decl String:IdS[20];
			IntToString(Id, IdS, sizeof(IdS));
			decl Handle:GamZone;
			GamZone = CreateKeyValues("Gambling");
			FileToKeyValues(GamZone, RouletteOrigins);
			KvJumpToKey(GamZone, IdS, true);
			KvSetNum(GamZone, "Balance", RouletteBalance[Id]);
			KvRewind(GamZone);
			KeyValuesToFile(GamZone, RouletteOrigins);
			CloseHandle(GamZone);
			
			return Plugin_Handled;
		}
	}
	CloseHandle(DataPack);
	return Plugin_Handled;
}

public Action:CommandItemConvert(Client, Args)
{
	if(Client != 0)
	{
		PrintToConsole(Client, "|RP| - This command can only be ran using the server console or rcon.");
		return Plugin_Handled;
	}
	for(new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsClientConnected(i) && IsClientInGame(i))
		{
			PrintToConsole(Client, "|RP| - This command can only be ran when >NO ONE< is in the server!  This is to prevent the save database from getting messed up.");
			return Plugin_Handled;
		}
	}
	if(Args < 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_convertitem <original id> <new id>");
		return Plugin_Handled;
	}
	decl String:Arg1[32], String:Arg2[32];
	GetCmdArg(1, Arg1, sizeof(Arg1));
	GetCmdArg(2, Arg2, sizeof(Arg2));
	
	decl Handle:Converter;
	Converter = CreateKeyValues("Gambling");
	FileToKeyValues(Converter, SavePath);
	KvJumpToKey(Converter, Arg1, false);
	decl String:CurrentKey[32];
	KvGetSectionName(Converter, CurrentKey, 32);
	if(StrEqual(CurrentKey, Arg1, false))
	{
		KvSetSectionName(Converter, Arg2);
	}
	KvRewind(Converter);
	KeyValuesToFile(Converter, SavePath);
	CloseHandle(Converter);
	PrintToConsole(Client, "|RP| - ID %s has been changed to ID %s", Arg1, Arg2);
	return Plugin_Handled;
}


//Set Exp Points:
public Action:SetExp(Client, Args)
{
	if(Client == 0) return Plugin_Handled;
	if(Args < 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_setexp <name> <exp>");
		return Plugin_Handled;
	}
	if(GetConVarInt(ExperienceMode) == 0)
	{
		PrintToConsole(Client, "|RP| - Experience points are disabled");
		return Plugin_Handled;
	}
	
	decl String:Arg1[255], String:Arg2[50];
	GetCmdArg(1, Arg1, sizeof(Arg1));
	GetCmdArg(2, Arg2, sizeof(Arg2));
	
	decl Exp;
	Exp = StringToInt(Arg2);
	if(Exp < 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Usage: sm_setexp <name> <exp>");
		return Plugin_Handled;
	}
	
	new Max, Player = -1;
	Max = GetMaxClients();
	for(new i = 1; i <= Max; i++)
	{
		if(!IsClientConnected(i))
			continue;
		new String:Other[32];
		GetClientName(i, Other, sizeof(Other));
		if(StrContains(Other, Arg1, false) != -1)
			Player = i;
	}
	if(Player == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Could not find client %s.", Arg1);
		return Plugin_Handled;
	}
	
	decl String:ClientName[200], String:PlayerName[200];
	GetClientName(Client, ClientName, 200);
	GetClientName(Client, PlayerName, 200);
	
	if(IsCombine(Player))
	{
		ExpCombine[Player] = Exp;
		CPrintToChat(Client, "{white}|RP| -{grey} You set %s's combine exp to %d", PlayerName, Exp);
		CPrintToChat(Client, "{white}|RP| -{grey} %s has set your combine exp to %d", ClientName, Exp);
		Save(Player);
	}
	if(!IsCombine(Player))
	{
		ExpRebel[Player] = Exp;
		CPrintToChat(Client, "{white}|RP| -{grey} You set %s's rebel exp to %d", PlayerName, Exp);
		CPrintToChat(Client, "{white}|RP| -{grey} %s has set your rebel exp to %d", ClientName, Exp);
		Save(Player);
	}
	return Plugin_Handled;
}

public Action:Command_SetExpLevel(Client, Args)
{

	if(Args < 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Syntax: sm_setlevel <player> <level>");
		return Plugin_Handled;
	}

	decl String:TargetName[MAX_NAME_LENGTH];
	decl String:ClientName[MAX_NAME_LENGTH];
	
	decl String:LevelA[206];
	decl String:TargetBuffer[MAX_NAME_LENGTH];
	
	GetCmdArg(1, TargetBuffer, sizeof(TargetBuffer));
	new Target = FindTarget(Client, TargetBuffer);
	
	if(Target == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Target.");
		return Plugin_Handled;
	}
	
	GetCmdArg(2, LevelA, sizeof(LevelA));
	new LevelB = StringToInt(LevelA);
	ExpLevel[Target] = LevelB;
	
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Target, TargetName, sizeof(TargetName));
	CPrintToChat(Target, "{white}|RP| -{grey} %s set your level to {green}%d{grey}.", ClientName, LevelB);
	CPrintToChat(Client, "{white}|RP| -{grey} Set the level of {green}%s {grey}to {green}%d", TargetName, LevelB);
	
/*	if(Args != 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Syntax: sm_setlevel <player> <level>");
		return Plugin_Handled;
	}
	if(Target == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Target.");
		return Plugin_Handled;
	}*/
	Save(Target);
	return Plugin_Handled;
}
	
public Action:Command_SetPlanted(Client, Args)
{
	decl String:TargetName[MAX_NAME_LENGTH];
	decl String:ClientName[MAX_NAME_LENGTH];
	decl String:PlantA[206];
	decl String:TargetBuffer[MAX_NAME_LENGTH];
	GetCmdArg(1, TargetBuffer, sizeof(TargetBuffer));
	new Target = FindTarget(Client, TargetBuffer);
	
	GetCmdArg(2, PlantA, sizeof(PlantA));
	new PlantB = StringToInt(PlantA);
	Planted[Client] = PlantB;
	
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Target, TargetName, sizeof(TargetName));
	CPrintToChat(Target, "{white}|RP| -{grey} %s set your Total Plants to {green}%d{grey}.", ClientName, PlantB);
	CPrintToChat(Client, "{white}|RP| -{grey} Set the Plants of {green}%s {grey}to {green}%d", TargetName, PlantB);
	
	if(Args > 2 || Args < 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Syntax: sm_setplanted <player> <amount>");
		return Plugin_Handled;
	}
	if(Target == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Target.");
		return Plugin_Handled;
	}
	Save(Target);
	return Plugin_Handled;
}

public Action:Command_SetCuffs(Client, Args)
{
	decl String:TargetName[MAX_NAME_LENGTH];
	decl String:ClientName[MAX_NAME_LENGTH];
	decl String:LevelA[206];
	decl String:TargetBuffer[MAX_NAME_LENGTH];
	GetCmdArg(1, TargetBuffer, sizeof(TargetBuffer));
	new Target = FindTarget(Client, TargetBuffer);
	
	GetCmdArg(2, LevelA, sizeof(LevelA));
	new LevelB = StringToInt(LevelA);
	CuffCount[Client] = LevelB;
	
	GetClientName(Client, ClientName, sizeof(ClientName));
	GetClientName(Target, TargetName, sizeof(TargetName));
	CPrintToChat(Target, "{white}|RP| -{grey} %s set your Cuffs to {green}%d{grey}.", ClientName, LevelB);
	CPrintToChat(Client, "{white}|RP| -{grey} Set the Cuff Count of {green}%s {grey}to {green}%d", TargetName, LevelB);
	
	if(Args != 2)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Syntax: sm_setcuffs <player> <cuffs>");
		return Plugin_Handled;
	}
	if(Target == -1)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Invalid Target.");
		return Plugin_Handled;
	}
	Save(Target);
	return Plugin_Handled;
}

public Action:DrawDoorMenu(Client, Args)
{
	if(Client != 0)
	{
		CPrintToChat(Client, "{white}|RP| -{grey} Access Denied");
		return Plugin_Handled;
	}
	decl RunitNow;
	RunitNow = 1;
	decl String:Arg1[255], String:Arg2[50], String:Arg3[50], String:Arg4[50];
	GetCmdArg(1, Arg1, sizeof(Arg1));
	GetCmdArg(2, Arg2, sizeof(Arg2));
	GetCmdArg(3, Arg3, sizeof(Arg3));
	GetCmdArg(4, Arg4, sizeof(Arg4));
	decl SendTo, String:Stats[15];
	Stats = "Locked";
	SendTo = StringToInt(Arg1);
	
	SelectedItem[SendTo] = StringToInt(Arg2);
	
	new Handle:DoorMen = CreateMenu(DoorSettings);
	if(StringToInt(Arg3) == 0) Stats = "Unlocked";
	
	decl Handle:BuyDoor, Buyable, String:DoorValue[15];
	BuyDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(BuyDoor, DoorBuyPath);
	KvJumpToKey(BuyDoor, Arg2, false);
	Buyable = KvGetNum(BuyDoor, "Buyable", 99);
	KvGetString(BuyDoor, "Amount", DoorValue, 15, ERROR);
	if(Buyable == 1)
	{
		//No one bought house but has keys or does not.
		if(StringToInt(Arg4) == 1)
		{
			SetMenuTitle(DoorMen, "Door #%s\n=============\nStatus: %s\n\nDoor is up for sale!\nPrice: $%s", Arg2, Stats, DoorValue);
			AddMenuItem(DoorMen, "3", "-|Buydoor|-");
			AddMenuItem(DoorMen, "1", "-|Lock|-");
			AddMenuItem(DoorMen, "2", "-|Unlock|-");
		}
		else
		{
			SetMenuTitle(DoorMen, "Door #%s\n=============\nStatus: %s\n\nDoor is up for sale!\nPrice: $%s", Arg2, Stats, DoorValue);
			AddMenuItem(DoorMen, "3", "-|Buydoor|-");
		}
	}
	else if(Buyable == 0)
	{
		//Someone bought it but tell if its owner or not.
		decl String:Owner[255];
		KvGetString(BuyDoor, "Owner", Owner, 255, ERROR);
		decl String:Ste[255];
		GetClientAuthString(SendTo, Ste, 255);
		
		//Its the owner asking for menu.
		if(StrEqual(Ste, Owner, false))
		{
			SetMenuTitle(DoorMen, "Door #%s\n=============\nStatus: %s\n\nValue of %s:\n$%s", Arg2, Stats, Notice[StringToInt(Arg2)], DoorValue);
			AddMenuItem(DoorMen, "1", "-|Lock|-");
			AddMenuItem(DoorMen, "2", "-|Unlock|-");
			AddMenuItem(DoorMen, "5", "-|Keys Given|-");
			AddMenuItem(DoorMen, "4", "-|Selldoor|-");
		}
		//Owned door from cmd givedoor or Key From Owner
		else if(StringToInt(Arg4) == 1)
		{
			decl Wh;
			Wh = 0;
			decl String:ListSteam[255];
			for(new X = 1; X <= 50; X++)
			{
				decl String:IdNum[25];
				IntToString(X, IdNum, 25);
				KvGetString(BuyDoor, IdNum, ListSteam, 255, "Not Given");
				if(StrEqual(ListSteam, Ste, false))
				{
					SetMenuTitle(DoorMen, "Door #%s\n=============\nStatus: %s\n\n%s\nKey Access", Arg2, Stats, Notice[StringToInt(Arg2)]);
					AddMenuItem(DoorMen, "1", "-|Lock|-");
					AddMenuItem(DoorMen, "2", "-|Unlock|-");
					X = 99;
					Wh = 99;
				}
			}
			if(Wh != 99)
			{
				SetMenuTitle(DoorMen, "Door #%s\n=============\nStatus: %s\n\n%s", Arg2, Stats, Notice[StringToInt(Arg2)]);
				AddMenuItem(DoorMen, "1", "-|Lock|-");
				AddMenuItem(DoorMen, "2", "-|Unlock|-");
			}
		}
	}
	else
	{
		//Door is not part of buydoor system & person owns door.
		if(StringToInt(Arg4) == 1)
		{
			SetMenuTitle(DoorMen, "Door #%s\n=============\nStatus: %s", Arg2, Stats);
			AddMenuItem(DoorMen, "1", "-|Lock|-");
			AddMenuItem(DoorMen, "2", "-|Unlock|-");
		}
		else
		{
			//CPrintToChat(SendTo, "{white}|RP| -{grey} You do not own this door nor is for sale.");
			RunitNow = 2;
		}
	}
	KvRewind(BuyDoor);
	CloseHandle(BuyDoor);
	if(RunitNow == 1)
	{
		SetMenuPagination(DoorMen, 7);
		DisplayMenu(DoorMen, SendTo, 30);
	}
	return Plugin_Handled;
}

public DoorSettings(Handle:DoorMen, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(DoorMen, param2, info, sizeof(info));
		if(StringToInt(info) == 1)
		{
			ServerCommand("sm_autodoorlock %d", SelectedItem[Client]);
			CPrintToChat(Client, "{white}|RP| -{grey} Door #%d is now locked.", SelectedItem[Client]);
		}
		else if(StringToInt(info) == 2)
		{
			ServerCommand("sm_autodoorunlock %d", SelectedItem[Client]);
			CPrintToChat(Client, "{white}|RP| -{grey} Door #%d is now unlocked.", SelectedItem[Client]);
		}
		else if(StringToInt(info) == 3)
		{
			BuyDoorFunction(Client, SelectedItem[Client]);
		}
		else if(StringToInt(info) == 4)
		{
			new Handle:Caution = CreateMenu(AreYouSure);
			if(GetConVarInt(Deduction) > 0)
			{
				SetMenuTitle(Caution, "Sell Door #%d?\n=============\nRemember that %d percent\nis deducted from price\nof house.", SelectedItem[Client], GetConVarInt(Deduction));
			}
			else if(GetConVarInt(Deduction) == 0)
			{
				SetMenuTitle(Caution, "Sell Door #%d?\n=============\nThere are no deductions.", SelectedItem[Client]);
			}
			AddMenuItem(Caution, "1", "-|Yes|-");
			AddMenuItem(Caution, "2", "-|No|-");
			SetMenuPagination(Caution, 7);
			DisplayMenu(Caution, Client, 30);
		}
		else if(StringToInt(info) == 5)
		{
			KeysGivenFunc(Client, 1, 10, SelectedItem[Client]);
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(DoorMen);
	}
	return 0;
}

public AreYouSure(Handle:Caution, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(Caution, param2, info, sizeof(info));
		if(StringToInt(info) == 1)
		{
			SellDoorFunction(Client, SelectedItem[Client]);
			ServerCommand("sm_autodoorunlock %d", SelectedItem[Client]);
		}
		else if(StringToInt(info) == 2)
		{
			CPrintToChat(Client, "{white}|RP| -{grey} You have cancelled sell door.");
		}
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(Caution);
	}
	return 0;
}

public Action:KeysGivenFunc(Client, Start, End, Door)
{
	decl String:DoorString[25];
	new String:Steam[51][255], String:NameRaw[51][255];
	IntToString(Door, DoorString, 25);
	decl Handle:BuyDoor;
	BuyDoor = CreateKeyValues("Buyable Doors");
	FileToKeyValues(BuyDoor, DoorBuyPath);
	KvJumpToKey(BuyDoor, DoorString, false);
	
	decl Handle:VaultD;
	VaultD = CreateKeyValues("Vault");
	FileToKeyValues(VaultD, NamePath);
	KvJumpToKey(VaultD, "name", true);
	
	for(new X = Start; X <= End; X++)
	{
		decl String:Inteval[25];
		IntToString(X, Inteval, 25);
		KvGetString(BuyDoor, Inteval, Steam[X], 255, "Not Given");
		KvGetString(VaultD, Steam[X], NameRaw[X], 255, "Not Given");
	}
	KvRewind(BuyDoor);
	CloseHandle(BuyDoor);
	KvRewind(VaultD);
	CloseHandle(VaultD);
	
	new String:Name[10][255];
	for(new Z = 0; Z < 10; Z++)
	{
		decl Current;
		Current = Z + Start;
		Format(Name[Z], 255, "%d. %s", Current, NameRaw[Current]);
	}
	
	new Handle:KeysGiven = CreateMenu(KeyList);
	
	SetMenuTitle(KeysGiven, "Keys Given -|%d - %d|-\n=============\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s", Start, End, Name[0], Name[1], Name[2], Name[3], Name[4], Name[5], Name[6], Name[7], Name[8], Name[9]);
	AddMenuItem(KeysGiven, "1", "-|1 - 10|-");
	AddMenuItem(KeysGiven, "2", "-|11 - 20|-");
	AddMenuItem(KeysGiven, "3", "-|21 - 30|-");
	AddMenuItem(KeysGiven, "4", "-|31 - 40|-");
	AddMenuItem(KeysGiven, "5", "-|41 - 50|-");
	AddMenuItem(KeysGiven, "6", "-|Back to Door|-");
	
	SetMenuPagination(KeysGiven, 7);
	DisplayMenu(KeysGiven, Client, 40);
}

public KeyList(Handle:KeysGiven, MenuAction:action, Client, param2)
{
	if(action == MenuAction_Select)
	{
		new String:info[64];
		GetMenuItem(KeysGiven, param2, info, sizeof(info));
		if(StringToInt(info) == 1) KeysGivenFunc(Client, 1, 10, SelectedItem[Client]);
		else if(StringToInt(info) == 2) KeysGivenFunc(Client, 11, 20, SelectedItem[Client]);
		else if(StringToInt(info) == 3) KeysGivenFunc(Client, 21, 30, SelectedItem[Client]);
		else if(StringToInt(info) == 4) KeysGivenFunc(Client, 31, 40, SelectedItem[Client]);
		else if(StringToInt(info) == 5) KeysGivenFunc(Client, 41, 50, SelectedItem[Client]);
		else if(StringToInt(info) == 6) ServerCommand("sm_backtodoor %d %d", Client, SelectedItem[Client]);
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(KeysGiven);
	}
	return 0;
}

//Jetpack Functions - Knagg0

public Action:JetpackP(client, args)
{
	if(GetConVarBool(sm_jetpack) && !g_bJetpacks[client] && IsAlive(client) && PermitJetpack[client] == true)
	{
		new Float:vecPos[3];
		GetClientAbsOrigin(client, vecPos);
		EmitSoundToAll(g_sSound, client, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, GetConVarFloat(sm_jetpack_volume), SNDPITCH_NORMAL, -1, vecPos, NULL_VECTOR, true, 0.0);
		SetMoveType(client, MOVETYPE_FLYGRAVITYJETPACK, MOVECOLLIDE_FLY_BOUNCEJETPACK);
		g_bJetpacks[client] = true;
	}
	
	return Plugin_Continue;
}

public Action:JetpackM(client, args)
{
	StopJetpack(client);
	return Plugin_Continue;
}

StopJetpack(client)
{
	if(g_bJetpacks[client])
	{
		if(IsAlive(client)) SetMoveType(client, MOVETYPE_WALKJETPACK, MOVECOLLIDE_DEFAULTJETPACK);
		StopSound(client, SNDCHAN_AUTO, g_sSound);
		g_bJetpacks[client] = false;
	}
}

SetMoveType(client, movetype, movecollide)
{
	if(g_iMoveType == -1) return;
	SetEntData(client, g_iMoveType, movetype);
	if(g_iMoveCollide == -1) return;
	SetEntData(client, g_iMoveCollide, movecollide);
}

AddVelocity(client, Float:speed)
{
	if(g_iVelocity == -1) return;
	
	new Float:vecVelocity[3];
	GetEntDataVector(client, g_iVelocity, vecVelocity);
	
	vecVelocity[2] += speed;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
}

bool:IsAlive(client)
{
	if(g_iLifeState != -1 && GetEntData(client, g_iLifeState, 1) == LIFE_ALIVE)
		return true;
	
	return false;
}

//ANY EXPLOITS OR PROBLEMS PLEASE POST ON WEBSITE. THANK YOU
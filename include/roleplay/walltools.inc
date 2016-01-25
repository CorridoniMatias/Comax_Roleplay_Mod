/************************************************
 * Roflcopter Roleplay
 *----------------------------------------------*
 * Copyright (C) 2012 SpaceBass
 *----------------------------------------------*
 * Original Roleplay idea and realisation by Joe 'PinkFairie' Maley.
 * Updated and expanded by Krim, Alm and SpaceBass
 * Code optimized and improoved by Monkeys
 *----------------------------------------------*
 * Licence: Creative Commons BY-NC-SA
 * http://creativecommons.org/licenses/by-nc-sa/3.0/
************************************************/
static ClientFrom;

public bool:TraceEntityFilterEntity(entity, contentsMask)
{
	return entity > 0 && entity != ClientFrom;
}

public bool:TraceEntityFilterWall(entity, contentsMask)
{
	return !entity;
}

stock LookingAtWall(Client)
{
	decl Float:Origin[3];
	decl Float:Angles[3];
	decl Float:EndPos[3];
	
	GetClientEyePosition(Client, Origin);
	GetClientEyeAngles(Client, Angles);

	decl Float:dist1;
	dist1 = 0.0;
	decl Float:dist2;
	dist2 = 0.0;

	ClientFrom = Client;

	new Handle:Trace1 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterEntity);
   	 	
	if(TR_DidHit(Trace1))
	{
		TR_GetEndPosition(EndPos, Trace1);
	
		dist1 = GetVectorDistance(Origin, EndPos);
	}
	else
	{
		dist1 = -1.0;
	}

	CloseHandle(Trace1);

	new Handle:Trace2 = TR_TraceRayFilterEx(Origin, Angles, MASK_SHOT, RayType_Infinite, TraceEntityFilterWall);
   	 	
	if(TR_DidHit(Trace2))
	{
		TR_GetEndPosition(EndPos, Trace2);
	
		dist2 = GetVectorDistance(Origin, EndPos);
	}
	else
	{
		dist2 = -1.0;
	}

	CloseHandle(Trace2);

	ClientFrom = -1;

	if(dist1 >= dist2)
	{
		return true;
	}
	else
	{
		return false;
	}
}
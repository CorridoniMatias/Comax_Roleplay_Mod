/*	Game Description extension for Comax RP Mod.
*	@author	Reloaded.
*/

public Action:OnGetGameDescription(String:gameDesc[64])
{
	if(IZMapRunning)
	{
		new String:GameInfo[64];
		Format(GameInfo, sizeof(GameInfo), "Comax RP Mod v%s + EasSidez's Mod", RPVERSION);
		
		strcopy(gameDesc, sizeof(gameDesc), GameInfo);
		return Plugin_Changed;
	}
	return Plugin_Continue;
}
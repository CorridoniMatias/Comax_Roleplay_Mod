//Variables that have to be global for some reason. Example: another extension needs to read those vars yet the current extension needs vars from the other extension.

//Cars
new String:CarsPluginPath[PLATFORM_MAX_PATH];
new bool:HasCar[32];
new String:EntTnameCar[32][20];
new String:CarList[20][2][100];
new String:Cars[32][100];
new String:CarName[32][32];

//Gas Stations
new Float:GasStation[10][3];
new Float:GSTICK = 0.5;
new GasPrice = 3;
new Handle:g_gassationrange = INVALID_HANDLE; 
new GasClient[32];
new TotalGas[5000];
new OldTime[32];

//Game Desc
new bool: IZMapRunning = false;
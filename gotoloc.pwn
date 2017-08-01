/* -------------------------------------------------------------------------- */
/* Filterscript created by Zoneo. (zoneo.conker.me / contactzoneo@gmail.com)  */
/* For support, email contactzoneo@gmail.com                                  */
/* -------------------------------------------------------------------------- */

#define FILTERSCRIPT

#define COLOR_INFO 0xAFAFAF00
#define COLOR_WHITE 0xFFFFFFFF

#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <a_mysql>

#define MYSQL_HOST "localhost" //*** Change this to whereever your database is hosted.
#define MYSQL_USER "root" //*** Change this to the username used to access the database.
#define MYSQL_PASS "" //*** Change this to the password of the user used to access the database.
#define MYSQL_DB "gotoloc" //*** Don't change this unless you've changed the name of the database.

new handlesql;

public OnFilterScriptInit()
{
	sqlconnect();
	print("\n--------------------------------------");
	print(" GotoLoc by Zoneo loaded.");
	print("--------------------------------------\n");
	return 1;
}

public OnFilterScriptExit()
{
	mysql_close(handlesql);
	print("\n--------------------------------------");
	print(" GotoLoc by Zoneo closed.");
	print("--------------------------------------\n");
	return 1;
}

sqlconnect()
{
    handlesql = mysql_connect(MYSQL_HOST,MYSQL_USER,MYSQL_DB,MYSQL_PASS);
    if(handlesql) printf("[GotoLoc] SUCCESS: Connected To MySQL!");
    else printf("[GotoLoc] ERROR: Failed to connect to MySQL!");
    return 1;
}

COMMAND:gotoloc(playerid, params[]) { // Teleport to one of the locations. (params = [location name (String)])
	if(true /* If you want to restrict the command to certain players, such as admins, remove true and place the crtieria here. (Contact me for more information if needed) */) {
		new pLoc[50], query[256], targetid = playerid;
		if(sscanf(params, "s[50]", pLoc)) {
			SendClientMessage(playerid, COLOR_INFO, "[Syntax] /gotoloc [Location name].");
			SendClientMessage(playerid, COLOR_INFO, "For more information, use /gotolochelp");
			//mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `gotoloclocations`");
			//mysql_tquery(handlesql, query, "GotoLocHelpFunction", "i", playerid);
			return 1;
		}
		if(CheckIfLocationNameExists(pLoc)) return SendClientMessage(playerid, COLOR_INFO, "[Error] This location does not exist.");
		mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `gotoloclocations` WHERE `Name` = '%s'", pLoc);
		mysql_tquery(handlesql, query, "GotoLocFunction", "iis", playerid, targetid, pLoc);
	}
	return 1;
}

COMMAND:sendtoloc(playerid, params[]) { // Send another player to the location. (params = [playerid] [location name (String)])
	if(true /* If you want to restrict the command to certain players, such as admins, remove true and place the crtieria here. (Contact me for more information if needed) */) {
		new pLoc[50], query[256], targetid;
		if(sscanf(params, "us[50]", targetid, pLoc)) {
			SendClientMessage(playerid, COLOR_INFO, "[Syntax] /sendtoloc [Playerid] [Location name].");
			SendClientMessage(playerid, COLOR_INFO, "For more information, use /gotolochelp");
			//mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `gotoloclocations`");
			//mysql_tquery(handlesql, query, "GotoLocHelpFunction", "i", playerid);
			return 1;
		}
		if(CheckIfLocationNameExists(pLoc)) return SendClientMessage(playerid, COLOR_INFO, "[Error] This location does not exist.");
		mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `gotoloclocations` WHERE `Name` = '%s'", pLoc);
		mysql_tquery(handlesql, query, "GotoLocFunction", "iis", playerid, targetid, pLoc);
	}
	return 1;
}

forward GotoLocFunction(playerid, targetid, name[]);
public GotoLocFunction(playerid, targetid, name[]) { // Send the player to the location and update the database accordingly.
	new rows, fields, tarMsg[128];
	cache_get_data(rows, fields);
	if(rows > 0) {
		new Float:px, Float:py, Float:pz, pi, pv, query[128];
		px = cache_get_row_float(0, 3);
		py = cache_get_row_float(0, 4);
		pz = cache_get_row_float(0, 5);
		pi = cache_get_row_int(0, 6);
		pv = cache_get_row_int(0, 7);
		SetPlayerPos(targetid, px, py, pz);
		SetPlayerInterior(targetid, pi);
		SetPlayerVirtualWorld(targetid, pv);
		format(tarMsg, sizeof(tarMsg), "You have been teleported to %s.", name);
		mysql_format(handlesql, query, sizeof(query), "UPDATE `gotoloclocations` SET `TimesUsed` = `TimesUsed` + 1 WHERE `Name` = '%s'", name);
		mysql_query(handlesql, query);
	} else {
		format(tarMsg, sizeof(tarMsg), "[Error] %s is not a valid location name. Use /gotolochelp for more information.", name);
	}
	if(targetid != playerid) {
		new admMsg[128], plyName[MAX_PLAYER_NAME];
		GetPlayerName(targetid, plyName, sizeof(plyName));
		format(admMsg, sizeof(admMsg), "You have teleported %s (ID: %d) to %s", plyName, targetid, name);
		SendClientMessage(playerid, COLOR_INFO, admMsg);
		SendClientMessage(targetid, COLOR_INFO, tarMsg);
	} else {
		SendClientMessage(targetid, COLOR_INFO, tarMsg);
	}
	return 1;
}

COMMAND:gotolochelp(playerid) { // Calls GotoLocHelpFunction which lists the locations and commands.
	if(true /* If you want to restrict the command to certain players, such as admins, remove true and place the crtieria here. (Contact me for more information if needed) */) {
		new query[128];
		mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `gotoloclocations`");
		mysql_tquery(handlesql, query, "GotoLocHelpFunction", "i", playerid);
	}
	return 1;
}

COMMAND:locations(playerid) {
	return cmd_gotolochelp(playerid);
}

forward GotoLocHelpFunction(playerid);
public GotoLocHelpFunction(playerid) { // List the locations and commands.
	new rows, fields, lines[128], curName[50], locFormat[70], noLines;
	cache_get_data(rows, fields);
	SendClientMessage(playerid, COLOR_INFO, "__________________________________________________ /gotoloc Help __________________________________________________");
	SendClientMessage(playerid, COLOR_INFO, "/createloc - Creates a location. | /deleteloc - Deletes a location | /gotoloc - Teleports to a location ");
	SendClientMessage(playerid, COLOR_INFO, "/sendtoloc - Teleports another player to a location | /gotolochelp - Shows this help screen | /locstats - Shows stats for a location.");
	for(new i = 0; i < rows; i++) {
		if(strlen(lines) < 100) {
			cache_get_field_content(i, "Name", curName);
			format(locFormat, sizeof(locFormat), "| %s ", curName);
			strcat(lines, locFormat);
		} else {
			SendClientMessage(playerid, COLOR_WHITE, lines);
			format(lines, sizeof(lines), "");
			noLines += 1;
		}
	}
	SendClientMessage(playerid, COLOR_WHITE, lines);
	return 1;
}

COMMAND:createloc(playerid, params[]) { // Create a new location to teleport to.
	if(true /* If you want to restrict the command to certain players, such as admins, remove true and place the crtieria here. (Contact me for more information if needed) */) {
		new Float:px, Float:py, Float:pz, msg[128], query[256], locName[28], playerName[MAX_PLAYER_NAME], int, vw;
		if(sscanf(params, "s[28]", locName)) return SendClientMessage(playerid, COLOR_INFO, "[Syntax] /createloc [Location name]");
		if(!CheckIfLocationNameExists(locName)) return SendClientMessage(playerid, COLOR_INFO, "[Error] This name already exists.");
		if(strlen(locName) > 27) return SendClientMessage(playerid, COLOR_INFO, "The length of the name cannot be more than 27 characters.");
		if(strfind(locName, " ") != -1) return SendClientMessage(playerid, COLOR_INFO, "The name of a location must not contain a space.");
		GetPlayerPos(playerid, px, py, pz);
		int = GetPlayerInterior(playerid);
		vw = GetPlayerVirtualWorld(playerid);
		GetPlayerName(playerid, playerName, sizeof(playerName));
		mysql_format(handlesql, query, sizeof(query), "INSERT INTO `gotoloclocations` (`Name`, `Creator`, `X`, `Y`, `Z`, `Interior`, `Vw`, `TimesUsed`) VALUES ('%s', '%s', '%f', '%f', '%f', '%i', '%i', '%i')", locName, playerName, px, py, pz, int, vw, 0);
		mysql_query(handlesql, query);
		format(msg, sizeof(msg), "You have created the location %s at X: %f, Y: %f, Z: %f", locName, px, py, pz);
		SendClientMessage(playerid, COLOR_WHITE, msg);
	}
	return 1;
}

forward CheckIfLocationNameExists(name[]);
public CheckIfLocationNameExists(name[]) { // make sure that 2 locations with the same name aren't created.
	new query[128], rows;
	mysql_format(handlesql, query, sizeof(query), "SELECT `Name` FROM `gotoloclocations` WHERE `Name` = '%s'", name);
	mysql_query(handlesql, query);
	rows = cache_get_row_count(handlesql);
	if(rows > 0) {
		return 0; // Location exists.
	} else {
		return 1;
	}
}

COMMAND:deleteloc(playerid, params[]) { // deletes a location.
	if(true /* If you want to restrict the command to certain players, such as admins, remove true and place the crtieria here. (Contact me for more information if needed) */) {
		new locName[28], query[128], message[128];
		if(sscanf(params, "s[28]", locName)) return SendClientMessage(playerid, COLOR_INFO, "[Syntax] /deleteloc [Location name]");
		if(CheckIfLocationNameExists(locName)) return SendClientMessage(playerid, COLOR_INFO, "[Error] This location does not exist.");
		mysql_format(handlesql, query, sizeof(query), "DELETE FROM `gotoloclocations` WHERE `Name` = '%s'", locName);
		mysql_query(handlesql, query);
		format(message, sizeof(message), "You have deleted the location %s", locName);
		SendClientMessage(playerid, COLOR_INFO, message);
	}
	return 1;
}

COMMAND:locstats(playerid, params[]) { // check the stats of a location.
	if(true /* If you want to restrict the command to certain players, such as admins, remove true and place the crtieria here. (Contact me for more information if needed) */) {
		new locName[28], query[128];
		if(sscanf(params, "s[28]", locName)) return SendClientMessage(playerid, COLOR_INFO, "[Syntax] /locstats [Location name]");
		if(CheckIfLocationNameExists(locName)) return SendClientMessage(playerid, COLOR_INFO, "[Error] This location does not exist.");
		mysql_format(handlesql, query, sizeof(query), "SELECT * FROM `gotoloclocations` WHERE `Name` = '%s'", locName);
		mysql_tquery(handlesql, query, "GetLocStats", "si", locName, playerid);
	}
	return 1;
}

forward GetLocStats(name[], userid);
public GetLocStats(name[], userid) {  // Get the stats from the db.
	new rows, fields;
	cache_get_data(rows, fields);
	if(rows > 0) {
		new msg[128], locid, creator[MAX_PLAYER_NAME], Float:px, Float:py, Float:pz, int, vw, timesUsed;
		locid = cache_get_field_content_int(0, "ID");
		cache_get_field_content(0, "Creator", creator);
		px = cache_get_field_content_float(0, "X");
		py = cache_get_field_content_float(0, "Y");
		pz = cache_get_field_content_float(0, "Z");
		int = cache_get_field_content_int(0, "Interior");
		vw = cache_get_field_content_int(0, "Vw");
		timesUsed = cache_get_field_content_int(0, "TimesUsed");
		format(msg, sizeof(msg), "[Stats] ID: %i | Name: %s | Creator: %s | X: %f | Y: %f | Z: %f | Int: %i | Vw: %i | Times used: %i", locid, name, creator, px, py, pz, int, vw, timesUsed);
		SendClientMessage(userid, COLOR_WHITE, msg);
	}
	return 1;
}

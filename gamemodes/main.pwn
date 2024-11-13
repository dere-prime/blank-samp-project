/*
    _Blank Gamemode

    Este programa es software libre; puedes redistribuirlo y/o modificarlo bajo los términos de la Licencia Pública General de GNU (GPL) versión 3, tal como ha sido publicada por la Free Software Foundation.
    Este programa se distribuye con la esperanza de que sea útil, pero SIN NINGUNA GARANTÍA; sin incluso la garantía implícita de COMERCIABILIDAD o IDONEIDAD PARA UN PROPÓSITO PARTICULAR. Consulta los detalles de la Licencia Pública General de GNU para obtener más información.
    Deberías haber recibido una copia de la Licencia Pública General de GNU junto con este programa. Si no, consulta <https://www.gnu.org/licenses/>.

    Gamemode creada por: dere.prime
    portfolio: https://dere-prime.github.io/ 

    Puedes contratar mis servicios para crear tu servidor de SA-MP.
    Contactame via discord, todas mis redes estan en mi portfolio.

    Metodos de pago Global (pagas comision)
    Paypal
    Remitly
    MoneyGram
    Western Union

    Metodos de pago Republica dominicana
    Banco de Reservas
    Banco BHD
    Asociación Popular
*/

/* Compiler */
#pragma option -d3
#pragma warning disable 239
#pragma tabsize 4

/* Secure script */
AntiDeAMX()
{
    new a[][] =
    {
        "Unarmed (Fist)",
        "Brass K"
    };
    #pragma unused a
}

/* Max Players */
const MAX_PLAYERS = 25;
#define MAX_PLAYERS 25

/* Core */
#include <a_samp>
#include <a_mysql>

/* Crypto (Only Scrypt) */
#define SCRYPT_HASH_LEN 100
#define SCRYPT_COST 15
#define SCRYPT_RAM 1
#define SCRYPT_CPU 1

#include <samp-crypto>

/* YSI Includes */
#define YSI_NO_HEAP_MALLOC
#include <YSI_Coding\y_va>
#include <YSI_Extra\y_inline_mysql>

/* Includes */
#include <logger> /* Spanish Description: Errores imposibles de pasar se muestran en la consola. */
#include <easyDialog>

/* Others */
#define seconds(%0) (%0*1000)
#define minutes(%0) (%0*1000*60)

/* Login / Register - Config */
#define LOGIN_TIMER minutes(3)
#define MAX_LOGIN_ATTEMPS 3
#define MAX_PASSWORD_LENGTH 32
#define MIN_PASSWORD_LENGTH 3

/* Server */
#define SPAWN_X 0.0
#define SPAWN_Y 0.0
#define SPAWN_Z 5.0
#define SPAWN_ANGLE 0.0

/* Entry Point */
main() {}

/* Header */
enum e_player_data { /* Enum data style: <initial>name */
    pId,
    pPass[SCRYPT_HASH_LEN],
    pName[24]
}

enum e_player_temp_data {
    tLoginTimer,
    tLoginAttemps,
    bool: tClassed,
    bool: tConnected,
    bool: tSpawned,
    bool: tRegistered,
    bool: tLoggedIn
}

new 
    MySQL: handle_db, //database
    PlayerData[MAX_PLAYERS][e_player_data], //player data <DB>
    PlayerTemp[MAX_PLAYERS][e_player_temp_data]
;

/* Impl */
forward OnPlayerLoginTimeOut(const playerid);

//...
ResetPlayerData(const playerid) {
    static const tmp_PlayerData[e_player_data];
    static const tmp_PlayerTemp[e_player_temp_data];

    PlayerData[playerid] = tmp_PlayerData;
    PlayerTemp[playerid] = tmp_PlayerTemp;
    return;
}

ConnectToMainDatabase() {
    handle_db = mysql_connect_file();

    if (mysql_errno(handle_db) != 0) {
        printf("Error al conectar la base de datos (handle_db). Codigo de error %d.", mysql_errno(handle_db));
        SendRconCommand("exit");
    } else {
        printf("La base de datos (handle_db) se ha conectado correctamente.");
    }
}

RegisterNewPlayerAccount(const playerid) {
    inline OnPlayerInsert() {
        PlayerData[playerid][pId] = cache_insert_id();
        SetPlayerRegisterData(playerid);
    }
    MySQL_TQueryInline(handle_db, using inline OnPlayerInsert, "INSERT INTO player (pass, name) VALUES ('%e', '%e');", PlayerData[playerid][pPass], PlayerData[playerid][pName]);
    return 1;
}

SetPlayerRegisterData(const playerid) {
    if (PlayerTemp[playerid][tLoginTimer] != -1) {
        KillTimer(PlayerTemp[playerid][tLoginTimer]);
        PlayerTemp[playerid][tLoginTimer] = -1;
    }

    PlayerTemp[playerid][tRegistered] = true;
    PlayerTemp[playerid][tLoggedIn] = true;

    TogglePlayerSpectating(playerid, false);
    TogglePlayerControllable(playerid, true);

    SetSpawnInfo(playerid, NO_TEAM, 0 /* Skin Data Array */, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_ANGLE, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    return 1;
}

SetPlayerLoggedData(const playerid) {
    if (PlayerTemp[playerid][tLoginTimer] != -1) {
        KillTimer(PlayerTemp[playerid][tLoginTimer]);
        PlayerTemp[playerid][tLoginTimer] = -1;
    }

    /* Podrias poner algun tipo de carga de datos en este apartado. */
    //LoadPlayerData(playerid); 

    PlayerTemp[playerid][tRegistered] = true;
    PlayerTemp[playerid][tLoggedIn] = true;

    TogglePlayerSpectating(playerid, false);
    TogglePlayerControllable(playerid, true);
                                                        /* Podrias poner los datos de posicion aqui */
    SetSpawnInfo(playerid, NO_TEAM, 0 /* Skin Data Array */, SPAWN_X, SPAWN_Y, SPAWN_Z, SPAWN_ANGLE, 0, 0, 0, 0, 0, 0);
    SpawnPlayer(playerid);
    return 1;
}

public OnPlayerConnect(playerid) {
    ResetPlayerData(playerid);

    /* Preload Main Data */
    PlayerTemp[playerid][tLoginTimer] = -1;
    PlayerTemp[playerid][tLoginAttemps] = 0;
    PlayerTemp[playerid][tClassed] = false;
    PlayerTemp[playerid][tConnected] = true;
    PlayerTemp[playerid][tSpawned] = false;

    GetPlayerName(playerid, PlayerData[playerid][pName], 24);

    PlayerTemp[playerid][tLoginTimer] = SetTimerEx("OnPlayerLoginTimeOut", LOGIN_TIMER, false, "d", playerid);
    return 1;
}

public OnPlayerDisconnect(playerid, reason) {
    if (PlayerTemp[playerid][tLoginTimer] != -1) {
        KillTimer(PlayerTemp[playerid][tLoginTimer]);
        PlayerTemp[playerid][tLoginTimer] = -1;
    }

    if (PlayerData[playerid][pId] != 0) {
        if (PlayerTemp[playerid][tRegistered]) {
            if (PlayerTemp[playerid][tLoggedIn]) {
                //Podrias poner algun guardado de datos aqui.
            }
        }
    }

    PlayerTemp[playerid][tRegistered] = false;
    PlayerTemp[playerid][tLoggedIn] = false;

    ResetPlayerData(playerid);
    return 1;
}

public OnPlayerRequestClass(playerid, classid) {
    if (PlayerTemp[playerid][tConnected]) {
        TogglePlayerControllable(playerid, false);
        TogglePlayerSpectating(playerid, true);

        PlayerTemp[playerid][tClassed] = true;
        
        inline OnPlayerRequestData() {

            PlayerTemp[playerid][tRegistered] = false;
            
            if (cache_num_rows() > 0) {
                cache_get_value_name_int(0, "id", PlayerData[playerid][pId]);
                cache_get_value_name(0, "pass", PlayerData[playerid][pPass], SCRYPT_HASH_LEN);
                cache_get_value_name(0, "name", PlayerData[playerid][pName], 24);

                PlayerTemp[playerid][tRegistered] = true;
            }

            if (PlayerTemp[playerid][tRegistered]) {
                Dialog_Show(playerid, "OnPlayerLoginResponse", DIALOG_STYLE_PASSWORD, "Ingresar", "{d1d1d1}Bienvenido de nuevo, %s\nEscribe tu clave para ingresar a tu cuenta:", "Continuar", "Cerrar", PlayerData[playerid][pName]);
            } else {
                Dialog_Show(playerid, "OnPlayerRegisterResponse", DIALOG_STYLE_PASSWORD, "Registrarse", "{d1d1d1}Bienvenido %s, no tienes una cuenta registrada\nEscribe una clave para registrar tu cuenta:", "Continuar", "Cerrar", PlayerData[playerid][pName]);
            }
        }

        MySQL_TQueryInline(handle_db, using inline OnPlayerRequestData, "SELECT id, name, pass FROM player WHERE name = '%e' LIMIT 1;", PlayerData[playerid][pName]);
    } else {
        Logger_Log("request class bug.", Logger_S("name registered", PlayerData[playerid][pName]), Logger_I("playerid", playerid));
        Kick(playerid);
    }
    return 1;
}

public OnPlayerRequestSpawn(playerid) { return CallLocalFunction("OnPlayerRequestClass", "dd", playerid, 0); }
public OnPlayerLoginTimeOut(const playerid) { return Kick(playerid); }

public OnPlayerSpawn(playerid) {
    PlayerTemp[playerid][tSpawned] = true;
    return 1;
}

//...
Dialog:OnPlayerRegisterResponse(playerid, response, listitem, inputtext[]) {
    if (response) {
        if (strlen(inputtext) > MAX_PASSWORD_LENGTH) return Dialog_Show(playerid, "OnPlayerRegisterResponse", DIALOG_STYLE_PASSWORD, "Registrarse", "{d1d1d1}Bienvenido %s, no tienes una cuenta registrada\nEscribe una clave para registrar tu cuenta:\n\nCaracteres maximos: "#MAX_PASSWORD_LENGTH"", "Continuar", "Cerrar", PlayerData[playerid][pName]);
        if (strlen(inputtext) < MIN_PASSWORD_LENGTH) return Dialog_Show(playerid, "OnPlayerRegisterResponse", DIALOG_STYLE_PASSWORD, "Registrarse", "{d1d1d1}Bienvenido %s, no tienes una cuenta registrada\nEscribe una clave para registrar tu cuenta:\n\nCaracteres minimos: "#MIN_PASSWORD_LENGTH"", "Continuar", "Cerrar", PlayerData[playerid][pName]);

        if (scrypt_hash(inputtext, PlayerData[playerid][pPass], SCRYPT_HASH_LEN) == 1) {
            RegisterNewPlayerAccount(playerid);
        } else {
            Dialog_Show(playerid, "OnPlayerRegisterResponse", DIALOG_STYLE_PASSWORD, "Registrarse", "{d1d1d1}Bienvenido %s, no tienes una cuenta registrada\nEscribe una clave para registrar tu cuenta:", "Continuar", "Cerrar", PlayerData[playerid][pName]);
        }
    } else {
        Kick(playerid);
    }
    return 1;
}

Dialog:OnPlayerLoginResponse(playerid, response, listitem, inputtext[]) {
    if (response) {
        if (strlen(inputtext) <= 0) return Dialog_Show(playerid, "OnPlayerLoginResponse", DIALOG_STYLE_PASSWORD, "Ingresar", "{d1d1d1}Bienvenido de nuevo, %s\nEscribe tu clave para ingresar a tu cuenta:", "Continuar", "Cerrar", PlayerData[playerid][pName]);
    
        if (scrypt_verify(inputtext, PlayerData[playerid][pPass]) == 1) {
            SetPlayerLoggedData(playerid);
        } else {
            PlayerTemp[playerid][tLoginAttemps] ++;
            if (PlayerTemp[playerid][tLoginAttemps] >= 3) {
                Kick(playerid);
            }
            else {
                Dialog_Show(playerid, "OnPlayerLoginResponse", DIALOG_STYLE_PASSWORD, "Ingresar", "{d1d1d1}Bienvenido de nuevo, %s\nEscribe tu clave para ingresar a tu cuenta:", "Continuar", "Cerrar", PlayerData[playerid][pName]);
            }
        }
    } else {
        Kick(playerid);
    }
    return 1;
}

//...
public OnGameModeInit() {
    AntiDeAMX();

    ConnectToMainDatabase();

    UsePlayerPedAnims();
    ManualVehicleEngineAndLights();
    DisableInteriorEnterExits();
	EnableStuntBonusForAll(false);
    return 1;
}

public OnGameModeExit() {
    AntiDeAMX();
    return 1;
}
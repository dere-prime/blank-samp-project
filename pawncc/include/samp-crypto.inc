// NOTE:change the name of include to samp-crypto
// remove built-in include guard
#if defined _inc_samp_crypto
	#undef _inc_samp_crypto
#endif
// custom include-guard
#if defined _samp_crypto_included
	#endinput
#endif
#define _samp_crypto_included

// general
#define CRYPTO_UNSUCCESSFUL 0
#define CRYPTO_SUCCESSFUL   1

#define CRYPTO_ERROR_PARAMS -1
#define CRYPTO_ERROR_FATAL  -2

// scrypt related
#if !defined SCRYPT_HASH_LEN
	#define SCRYPT_HASH_LEN 100
#endif
#if !defined SCRYPT_COST
	#define SCRYPT_COST 15
#endif
#if !defined SCRYPT_RAM
	#define SCRYPT_RAM 8
#endif
#if !defined SCRYPT_CPU
	#define SCRYPT_CPU 1
#endif

/*  scrypt_hash()
	Parameters:
	* password - The password to be hashed. (Must be 1 char at minimum)
	* dest - Where the hashed password is stored.
	* size - The size of dest.
	* N - The CPU & RAM cost (you should only ever need to modify this value at most)
	* R - RAM cost
	* P - CPU cost

	Returns:
	* 1 - Hash successful.
	* 0 - Salt or password are insufficient.
	* -1 - One of the parameters (Nrp) do not meet the minimum criteria of 1. You should leave them as default.
*/
native scrypt_hash(const password[], const dest[], size = sizeof dest, n = SCRYPT_COST, r = SCRYPT_RAM, p = SCRYPT_CPU);

/*  scrypt_verify()
	Parameters:
	* password - The password entered by the player.
	* hashedpass - The password retrieved from database.

	Returns:
	* 0 - Passwords do not match.
	* 1 - Passwords match.
*/
native scrypt_verify(const password[], const hashed_value[]);

/*  random_int()
    Parameters:
	* min
	* max

	Returns:
	- The randomly generated number.
	- 1000000 - The min value is above the max value. You will get a console error with a solution.

	Notes:
	If you specify 1 as your min and 10 as your max, you will get a number between 1-10.
*/
native random_int(min, max);
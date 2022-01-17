#include "tospatch.h"

char ctry_code;

#ifdef __atarist__
#define ae "\204"
#define oe "\224"
#define ue "\201"
#define Ae "\216"
#define Oe "\231"
#define Ue "\232"
#define ss "\236"
#else
#define ae "\303\244"
#define oe "\303\266"
#define ue "\303\274"
#define Ae "\303\204"
#define Oe "\303\226"
#define Ue "\303\234"
#define ss "\303\237"
#endif


/**********************************************************************
 *
 * All messages are organized as:
 * char n1,n2,...,-1      countries for 1st string
 * char s1[]              1st string
 * char n3,n4,...,-1      countries for 2nd string
 * char s2[]              2nd string
 * char -1                terminator
 * char defs[]            default string (usually english)
 *
 **********************************************************************/

char const abort_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Abbruch durch <ESC>...\n\0"
	"\377"
	"Cancelled by <ESC>\n";

char const usage_error[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Ung" ue "ltiger Schalter!\n\n"
	"TOSPATCH [-qmK] patchfile\n"
	" -q   Ausgaben unterdr" ue "cken\n"
	" -m   Nicht Nachfragen\n"
	" -l   Alle Ausgaben ins Logfile TOS.LOG schreiben\n"
	" -a   Alle gepatchten Adressen ausgeben\n"
	" -K   Akustisches Signal bei Beendigung\n\0"
	"\377"
	"Illegal option!\n\n"
	"TOSPATCH [-qmK] patchfile\n"
	" -q   Suppress messages\n"
	" -m   Do not ask\n"
	" -l   Write all messages to logfile TOS.LOG\n"
	" -a   Print all patched addresses\n"
	" -K   Acoustic signal upon termination\n";

char const init_text[] =
	"\377"
#ifdef __atarist__
	"\033v\n\033p"
#else
	"\n\033[7m"
#endif
	" TOS-Patch V" VERSION " "
#ifdef __atarist__
	"\033q"
#else
	"\033[m"
#endif
	"\n\n"
	COPY_S "1990      " SIGMA_S "-soft, Markus Fritze\n"
	COPY_S "1992-1999 Markus Heiden\n"
	COPY_S "2022      Thorsten Otto\n"
	"\n";

char const ok_text[] =
	"\377"
	"...OK\n";

char const error_txt[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"\nFehler: \0"
	"\377"
	"\nError: ";

char const error_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"...Fehler\n\0"
	"\377"
	"...Error\n";

char const read_1st_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Lese Hauptbatchdatei\n\0"
	"\377"
	"Reading main batchfile\n";

char const read_2nd_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Lese Unterbatchdatei\n\0"
	"\377"
	"Reading sub batchfile\n";

char const batch_end_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Ende der Unterbatchdatei.\n\0"
	"\377"
	"End of sub batchfile\n";

char const read_tos[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Lese TOS\n\0"
	"\377"
	"Reading TOS\n";

char const write_tos[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Schreibe TOS\n\0"
	"\377"
	"Writing TOS\n";

char const logopen_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"" Oe "ffne LOG-Datei\n\0"
	"\377"
	"Opening LOG file\n";

char const logclose_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Schlie" ss "e LOG-Datei\n\0"
	"\377"
	"Closing LOG file\n";

char const key_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"\nEnde! Taste dr" ue "cken.\0"
	"\377"
	"End! Press any key\n";

char const key2_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"--> Bitte Taste dr" ue "cken! ( <ESC>: Abbruch )\n\0"
	"\377"
	"--> Press any key! ( <ESC>: Cancel )\n";

char const line_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	" in Zeile %ld\0"
	"\377"
	" in line %ld";

char const batch_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	" der %d. Unterbatchdatei\0"
	"\377"
	" in sub batch file %d";

char const log_patch[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	" PATCH: $%08lx\0"
	"\377"
	" PATCH: $%08lx";

char const log_reloc[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	" RELOC: \0"
	"\377"
	" RELOC: ";

char const log_crc[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	" CRC: \0"
	"\377"
	" CRC: ";

char const path_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Setze Pfad auf \"%s\"\n\0"
	"\377"
	"setting path to \"%s\"\n";

char const read_rom_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Lese das TOS aus dem ROM\n\0"
	"\377"
	"Reading TOS from ROM\n";

char const no_read_rom_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Lesen aus ROM nicht unterst" ue "tzt\n\0"
	"\377"
	"Reading TOS from ROM unsupported\n";

char const reloc_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Reloziere TOS nach $%08lx\0"
	"\377"
	"relocating TOS to $%08lx";

char const cksum_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Bilde CRC-Pr" ue "fsumme\0"
	"\377"
	"calculating CRC checksum";

/*
 * error messages
 */
char const enomem_text[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Speicher voll!\0"
	"\377"
	"out of memory!";

char const illegal_name_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Illegale Verkn" ue "pfung\0"
	"\377"
	"illegal name";

char const toomany_files_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Zu viele TOS-Dateien zum Splitten!\0"
	"\377"
	"too many TOS files to split!";

char const missing_var_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"TOS-Daten (BASE/LENGTH/WIDTH) nicht angegeben!\0"
	"\377"
	"variables (BASE/LENGTH/WIDTH) not defined!";

char const illegal_width_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Illegale Breite\0"
	"\377"
	"illegal width";

char const width_mismatch_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"TOS-Breite passt nicht zur Anzahl der TOS-Dateien!\0"
	"\377"
	"TOS width does not match number of output files!";

char const length_mismatch_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"TOS-L" ae "nge passt nicht zur TOS-Breite!\0"
	"\377"
	"TOS length does not match TOS width!";

char const machine_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Unerlaubter Maschinentyp f" ue "rs Abspeichern!\0"
	"\377"
	"illegal machine type for saving!";

char const unknown_machine_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Unbekannter Maschinentyp\0"
	"\377"
	"unknown machine type";

char const machine_bank_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Angegebener Maschinentyp unterst" ue "tzt nur eine Bank!\0"
	"\377"
	"machine type only supports a single bank!";

char const missing_endif_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"IF ohne ENDIF\0"
	"\377"
	"IF without ENDIF";

char const missing_endswitch_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"SWITCH ohne ENDSWITCH\0"
	"\377"
	"SWITCH without ENDSWITCH";

char const missing_endselect_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"SELECT ohne ENDSELECT\0"
	"\377"
	"SELECT without ENDSELECT";

char const unexpected_eof_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Unerwartetes Zeilen- oder Dateiende\0"
	"\377"
	"unexpected end of line or file";

char const multiple_assign_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Mehrfachzuweisung ohne Selektor\0"
	"\377"
	"multiple assignment without selector";

char const garbage_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"M" ue "ll am Ende eines Ausdrucks\0"
	"\377"
	"garbage at end of expression";

char const selector_too_large_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Zu gro" ss "er Selektor f" ue "r Zuweisung\0"
	"\377"
	"selector too large for assignment";

char const no_argument_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Kein Argument f" ue "r Selektor\0"
	"\377"
	"no argument for selector";

char const toomany_batch_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Nur 256 Unterbatchdateien m" oe "glich!\0"
	"\377"
	"batch files nested too deeply!";

char const illegal_delimiter_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Falsches Trennzeichen\0"
	"\377"
	"illegal delimiter";

char const table_exceeded_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Interner Variablenspeicher zu klein!\0"
	"\377"
	"internal variable buffer too small!";

char const range_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"1. Adresse gr" oe "" ss "er als 2. Adresse\0"
	"\377"
	"1st address larger than 2nd address";

char const tos_too_long_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Das TOS ist l" ae "nger als der Puffer!\0"
	"\377"
	"the TOS file is larger than LENGTH";

char const tos_too_short_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	">>> Das TOS ist k" ue "rzer als angegeben!\0"
	"\377"
	">>> the TOS file is shorter than LENGTH";

char const wrong_date_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Falsches Datumformat\0"
	"\377"
	"wrong date format";

char const tos_not_loaded_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"TOS noch nicht geladen\0"
	"\377"
	"TOS not yet loaded";

char const wrong_tos_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	">>> Falsche TOS-Version!\0"
	"\377"
	">>> wrong TOS version!";

char const wrong_country_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	">>> Falsche TOS-Nationalit" ae "t!\0"
	"\377"
	">>> wrong TOS country!";

char const illegal_offset_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Illegaler Patchoffset\0"
	"\377"
	"illegal patch offset";

char const undocumented_use_of_colon_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Undokumentierte Verwendung von ':'\0"
	"\377"
	"undocumented use of ':'";

char const patches_too_large_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Patches sind l" ae "nger als das TOS\0"
	"\377"
	"patches are larger than TOS";

char const bad_extension_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Falsche Erweiterung (.B,.W,.L)\0"
	"\377"
	"bad extension (.B,.W,.L)";

char const bad_variable_extension_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Falsche Erweiterung der Variable #\0"
	"\377"
	"bad extension of variable #";

char const illegal_cmd_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Falscher Befehl\0"
	"\377"
	"illegal command";

char const too_many_if_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"IF zu tief verschachtelt\0"
	"\377"
	"IF nested too deeply";

char const too_many_sw_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"SWITCH zu tief verschachtelt\0"
	"\377"
	"SWITCH nested too deeply";

char const too_many_sel_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"SELECT zu tief verschachtelt\0"
	"\377"
	"SELECT nested too deeply";

char const no_bool_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Kein Bool'scher Wert\0"
	"\377"
	"not a boolean value";

char const else_without_if_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"ELSE ohne IF\0"
	"\377"
	"ELSE without IF";

char const endif_without_if_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"ENDIF ohne IF\0"
	"\377"
	"ENDIF without IF";

char const error_cmd_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"ERROR-Befehl\0"
	"\377"
	"ERROR command";

char const too_many_fill_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Zu viele Argumente f" ue "r _FILL\0"
	"\377"
	"too many arguments for _FILL";

char const case_without_switch_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"CASE ohne SWITCH\0"
	"\377"
	"CASE without SWITCH";

char const case_after_default_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"CASE nach DEFAULT\0"
	"\377"
	"CASE after DEFAULT";

char const no_colon_after_case_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Kein ':' nach CASE-Wert\0"
	"\377"
	"no ':' after CASE value";

char const default_without_switch_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"DEFAULT ohne SWITCH\0"
	"\377"
	"DEFAULT without SWITCH";

char const no_colon_after_default_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Kein ':' nach DEFAULT\0"
	"\377"
	"no ':' after DEFAULT";

char const duplicate_default_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Doppeltes DEFAULT\0"
	"\377"
	"duplicate DEFAULT";

char const endswitch_without_switch_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"ENDSWITCH ohne SWITCH\0"
	"\377"
	"ENDSWITCH without SWITCH";

char const endselect_without_select_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"ENDSELECT ohne SELECT\0"
	"\377"
	"ENDSELECT without SELECT";

char const missing_value_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Wert fehlt\0"
	"\377"
	"missing value";

char const undefined_variable_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Undefinierte Variable\0"
	"\377"
	"undefined variable";

char const set_not_first_argument_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Menge kann nicht 1. Argument sein\0"
	"\377"
	"a set cannot be 1st argument";

char const no_set_operation_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Keine Mengenoperation vor Menge\0"
	"\377"
	"no set-operation before set";

char const expression_too_complex_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Ausdruck zu komplex\0"
	"\377"
	"expression too complex";

char const div_by_zero_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Division durch 0\0"
	"\377"
	"division by 0";

char const missing_paren_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Klammer auf fehlt\0"
	"\377"
	"missing open parenthesis";

char const set_not_terminated_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	"Menge nicht abgeschlossen\0"
	"\377"
	"set not terminated";

char const overflow_err[] =
	COUNTRY_DE_S COUNTRY_SG_S "\377"
	Ue "berlauf\0"
	"\377"
	"overflow";



/*
 * strings that don't need to be translated.
 */
char const space_text[] = " ";
char const comma_text[] = ",";
char const lf_text[] = "\n";

/******************************************************************************/
/*** ---------------------------------------------------------------------- ***/
/******************************************************************************/

const char *translate_msg(const char *str)
{
	signed char c;

	if (strchr(str, '\377') == NULL)
		return str;
	for (;;)
	{
		if ((c = *str++) < 0)
			break;
		for (;;)
		{
			/* our country? */
			if (c == ctry_code)
			{
				/* found, skip over remaining countries */
				while (*str++ > 0)
					;
				return str;
			}
			if ((c = *str++) < 0)
				break;
		}
		/* not found, skip over string */
		while (*str++ != '\0')
			;
	}
	return str;
}

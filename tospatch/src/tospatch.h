#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#if (defined(__MINT__) || defined(__TOS__)) && !defined(__atarist__)
#define __atarist__
#endif

#ifdef __atarist__
#ifdef __PUREC__
#include <tos.h>
#else
#include <mint/osbind.h>
#include <mint/mintbind.h>
#endif
#endif

#include "country.h"

typedef int bool;
#define false 0
#define true  1

/* Versionsnummer */
#define VERSION  "3.0.0 (Jan 11 2022)"



#ifdef __atarist__
#define keypressed() Cconis()
#define readkey() ((int)Cnecin() & 0xff)
#define COPY_S "\275"
#define SIGMA_S "\344"
#else
#define keypressed() false
#define readkey() getchar()
#define COPY_S "\302\251"
#define SIGMA_S "\316\243"
#endif

typedef long memaddr;

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))
#define UNUSED(x) ((void)(x))

#define ISDIGIT(c) ((c) >= '0' && (c) <= '9')
#define ISLOWER(c) ((c) >= 'a' && (c) <= 'z')
#define ISUPPER(c) ((c) >= 'A' && (c) <= 'Z')
#define TOUPPER(c) ((c) - ('a' - 'A'))


/*
 * msgs.c
 */
extern char ctry_code;
extern char const abort_text[];
extern char const usage_error[];
extern char const init_text[];
extern char const space_text[];
extern char const comma_text[];
extern char const lf_text[];
extern char const ok_text[];
extern char const error_text[];
extern char const error_txt[];
extern char const read_1st_text[];
extern char const read_2nd_text[];
extern char const batch_end_text[];
extern char const read_tos[];
extern char const write_tos[];
extern char const logopen_text[];
extern char const logclose_text[];
extern char const key_text[];
extern char const key2_text[];
extern char const line_text[];
extern char const batch_text[];
extern char const batch_end_text[];
extern char const log_patch[];
extern char const log_reloc[];
extern char const log_crc[];
extern char const path_text[];
extern char const read_rom_text[];
extern char const no_read_rom_text[];
extern char const reloc_text[];
extern char const cksum_text[];

extern char const enomem_text[];
extern char const toomany_variables_err[];
extern char const illegal_name_err[];
extern char const toomany_files_err[];
extern char const missing_var_err[];
extern char const illegal_width_err[];
extern char const width_mismatch_err[];
extern char const length_mismatch_err[];
extern char const machine_err[];
extern char const unknown_machine_err[];
extern char const machine_bank_err[];
extern char const missing_endif_err[];
extern char const missing_endswitch_err[];
extern char const missing_endselect_err[];
extern char const unexpected_eof_err[];
extern char const multiple_assign_err[];
extern char const garbage_err[];
extern char const selector_too_large_err[];
extern char const no_argument_err[];
extern char const toomany_batch_err[];
extern char const illegal_delimiter_err[];
extern char const table_exceeded_err[];
extern char const range_err[];
extern char const tos_too_long_err[];
extern char const tos_too_short_err[];
extern char const wrong_date_err[];
extern char const tos_not_loaded_err[];
extern char const wrong_tos_err[];
extern char const wrong_country_err[];
extern char const illegal_offset_err[];
extern char const undocumented_use_of_colon_err[];
extern char const patches_too_large_err[];
extern char const bad_extension_err[];
extern char const bad_variable_extension_err[];
extern char const illegal_cmd_err[];
extern char const too_many_if_err[];
extern char const too_many_sw_err[];
extern char const no_bool_err[];
extern char const else_without_if_err[];
extern char const endif_without_if_err[];
extern char const error_cmd_err[];
extern char const too_many_fill_err[];
extern char const case_without_switch_err[];
extern char const case_after_default_err[];
extern char const no_colon_after_case_err[];
extern char const default_without_switch_err[];
extern char const no_colon_after_default_err[];
extern char const duplicate_default_err[];
extern char const endswitch_without_switch_err[];
extern char const too_many_sel_err[];
extern char const endselect_without_select_err[];
extern char const missing_value_err[];
extern char const undefined_variable_err[];
extern char const set_not_first_argument_err[];
extern char const no_set_operation_err[];
extern char const expression_too_complex_err[];
extern char const div_by_zero_err[];
extern char const missing_paren_err[];
extern char const set_not_terminated_err[];

const char *translate_msg(const char *str);


/*
 * log.c
 */
extern bool logflg;

void logline(const char *str);
void prline(void);
void openlog(void);
void closelog(void);
void setlog(void);
void print_str(const char *str, ...) __attribute__((format(printf, 1, 2)));
void print_line(const char *str, ...) __attribute__((format(printf, 1, 2)));
void print_point(void);


/*
 * var.c
 */
extern char const var_date[];
extern char const var_day[];
extern char const var_month[];
extern char const var_year[];
extern char const var_crc[];
extern char const var_base[];
extern char const var_length[];
extern char const var_reloc[];
extern char const var_width[];

#define MAX_VAR_LENGTH 16
typedef struct {
	char name[MAX_VAR_LENGTH];
	long value;
} VAR;

VAR *search_var(const char *name, bool *isnew);
void get_vname(char **batchptr);
void write_var(const char *name, long value);
long read_var(const char *name, bool *isnew);
long get_length(void);
memaddr get_base(void);
memaddr get_reloc_addr(void);
long get_width(void);
long get_crc(void);


/*
 * error.c
 */
#define ERR_NOLINENO 0x01
#define ERR_QUEST    0x02
#define ERR_CONTINUE 0x04

void mainexit(int code);
void error_handler(int code, const char *str);
void user_error(const char *str);
void unexpected_eof(void);
void illegal_delimiter(void);
void illegal_offset(void);


/*
 * expr.c
 */
long get_term(char **batchptr);
long get_extension(char **batchptr);


/*
 * parse.c
 */
int skip_space(char **batchptr);
void parse_init(void);
void parse_buffer(char *buffer);


/*
 * reloc.c
 */
#define MAX_RELOC_EXECPTIONS 1024
#define MAX_RELOC_RANGES     256
#define MAX_FORCED_RELOCS    256

struct reloc_range {
	uint32_t lo;
	uint32_t hi;
};
extern uint32_t reloc_exceptions[MAX_RELOC_EXECPTIONS + 1];
extern struct reloc_range reloc_range_exceptions[MAX_RELOC_RANGES + 1];
extern uint32_t forced_table[MAX_FORCED_RELOCS + 1];

void clraddr(void);
void lognl(void);
void reloc_it(void);


/*
 * crc.c
 */
void crc_checksum(void);


/*
 * main.c
 */
extern bool quiet;
extern bool allyes;
extern bool addrflag;
extern bool soundflg;
extern int filenr;
extern long lineno;
extern long output_format;
extern memaddr max_length;
extern long machine_type;
extern memaddr current_addr;
extern char *tos_buffer; /* TOS image buffer */
extern bool do_addr;
extern memaddr lastaddr;
extern bool wait_key_at_end;

void *xmalloc(size_t size);
void xfree(void *ptr);
size_t read_length(const char *filename);
void read_file(const char *filename, char *buffer, size_t size);
void write_file(const char *filename, const char *buffer, size_t size);

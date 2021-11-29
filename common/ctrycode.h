/*
 * ctrycode.h - a mere list of country codes
 *
 * Copyright (C) 2003-2016 The EmuTOS development team
 *
 * Authors:
 *  LVL     Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */

/*
 * The country codes were defined by Atari. They do not need to be contiguous.
 * They are used as the country identifier in the ROM header.
 * They are also used in NVRAM to select the UI language and keyboard layout.
 */

/* these are documented in the Compendium */
/* USA */
#define CTRY_US  0
#define CTRY_us  CTRY_US
/* Germany */
#define CTRY_DE  1
#define CTRY_de  CTRY_DE
/* France */
#define CTRY_FR  2
#define CTRY_fr  CTRY_FR
/* United Kingdom */
#define CTRY_UK  3
#define CTRY_uk  CTRY_UK
/* Spain */
#define CTRY_ES  4
#define CTRY_es  CTRY_ES
/* Italy */
#define CTRY_IT  5
#define CTRY_it  CTRY_IT
/* Sweden */
#define CTRY_SE  6
#define CTRY_se  CTRY_SE
/* Switzerland (French) */
#define CTRY_SF  7
#define CTRY_sf  CTRY_SF
/* Switzerland (German), NOT Singapore! */
#define CTRY_SG  8
#define CTRY_sg  CTRY_SG
/* Turkey */
#define CTRY_TR  9
#define CTRY_tr  CTRY_TR
/* Finland */
#define CTRY_FI 10
#define CTRY_fi CTRY_FI
/* Norway */
#define CTRY_NO 11
#define CTRY_no CTRY_NO
/* Denmark */
#define CTRY_DK 12
#define CTRY_dk CTRY_DK
/* Saudi Arabia */
#define CTRY_SA 13
#define CTRY_sa CTRY_SA
/* Holland */
#define CTRY_NL 14
#define CTRY_nl CTRY_NL
/* Czech Republic */
#define CTRY_CZ 15
#define CTRY_cz CTRY_CZ
/* Hungary */
#define CTRY_HU 16
#define CTRY_hu CTRY_HU
/* Poland */
#define CTRY_PL 17
#define CTRY_pl CTRY_PL

/*
 * The following country codes were not defined by Atari.
 * Before defining new ones, be sure to register them in tos.hyp:
 * http://toshyp.atari.org/en/003007.html#Cookie_2C_20_AKP
 * Note that those codes are also used in FreeMiNT/XaAES and must match:
 * https://github.com/freemint/freemint/blob/master/sys/keyboard.c
 * https://github.com/freemint/freemint/blob/master/xaaes/src.km/init.c
 */
/* Lithuania */
#define CTRY_LT 18
#define CTRY_lt CTRY_LT
/* Russia */
#define CTRY_RU 19
#define CTRY_ru CTRY_RU
/* Estonia */
#define CTRY_EE 20
#define CTRY_ee CTRY_EE
/* Belarus */
#define CTRY_BY 21
#define CTRY_by CTRY_BY
/* Ukraine */
#define CTRY_UA 22
#define CTRY_ua CTRY_UA
/* Slovak Republic */
#define CTRY_SK 23
#define CTRY_sk CTRY_SK
/* Romania */
#define CTRY_RO 24
#define CTRY_ro CTRY_RO
/* Bulgaria */
#define CTRY_BG 25
#define CTRY_bg CTRY_BG
/* Slovenia */
#define CTRY_SI 26
#define CTRY_si CTRY_SI
/* Croatia */
#define CTRY_HR 27
#define CTRY_hr CTRY_HR
/* Serbia */
#define CTRY_RS 28
#define CTRY_rs CTRY_RS
/* Montenegro */
#define CTRY_ME 29
#define CTRY_me CTRY_ME
/* Macedonia */
#define CTRY_MK 30
#define CTRY_mk CTRY_MK
/* Greece */
#define CTRY_GR 31
#define CTRY_gr CTRY_GR
/* Latvia */
#define CTRY_LV 32
#define CTRY_lv CTRY_LV
/* Israel */
#define CTRY_IL 33
#define CTRY_il CTRY_IL
/* South Africa */
#define CTRY_ZA 34
#define CTRY_za CTRY_ZA
/* Portugal */
#define CTRY_PT 35
#define CTRY_pt CTRY_PT
/* Belgium */
#define CTRY_BE 36
#define CTRY_ne CTRY_BE
/* Japan */
#define CTRY_JP 37
#define CTRY_jp CTRY_JP
/* China */
#define CTRY_CN 38
#define CTRY_cn CTRY_CN
/* Korea */
#define CTRY_KR 39
#define CTRY_kr CTRY_KR
/* Vietnam */
#define CTRY_VN 40
#define CTRY_vn CTRY_VN
/* India */
#define CTRY_IN 41
#define CTRY_in CTRY_IN
/* Iran */
#define CTRY_IR 42
#define CTRY_ir CTRY_IR
/* Mongolia */
#define CTRY_MN 43
#define CTRY_mn CTRY_MN
/* Nepal */
#define CTRY_NP 44
#define CTRY_np CTRY_NP
/* Lao People's Democratic Republic */
#define CTRY_LA 45
#define CTRY_la CTRY_LA
/* Cambodia */
#define CTRY_KH 46
#define CTRY_kh CTRY_KH
/* Indonesia */
#define CTRY_ID 47
#define CTRY_id CTRY_ID
/* Bangladesh */
#define CTRY_BD 48
#define CTRY_bd CTRY_BD

/* Mexico (Spanish) */
/* (unknown, checked for in sources, but never saw an official value for this) */
#define CTRY_MX 99
#define CTRY_mx CTRY_MX

/*
 * Special value of os_conf to indicate that the display and keyboard languages
 * will be read from the NVRAM. If the NVRAM is invalid, the default settings
 * will be inferred from the COUNTRY Makefile variable.
 */
#define OS_CONF_MULTILANG 0xff

#define CTRY_any OS_CONF_MULTILANG
#define CTRY_ANY OS_CONF_MULTILANG

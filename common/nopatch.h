/*
 * undef all TOS patches for BINEXACT mode
 */
#if BINEXACT
#undef TP_01
#undef TP_02
#undef TP_03
#undef TP_04
#undef TP_05
#undef TP_06
#undef TP_07
#undef TP_08
#undef TP_09
#undef TP_10
#undef TP_11
#undef TP_12
#undef TP_13
#undef TP_14
#undef TP_15
#undef TP_16
#undef TP_17
#undef TP_18
#undef TP_19
#undef TP_20
#undef TP_21
#undef TP_22
#undef TP_23
#undef TP_24
#undef TP_25
#undef TP_26
#undef TP_27
#undef TP_28
#undef TP_29
#undef TP_30
#undef TP_31
#undef TP_32
#undef TP_33
#undef TP_34
#undef TP_35_6
#undef TP_35_8
#undef TP_35_16
#undef TP_35_32
#undef TP_36
#undef TP_37_1
#undef TP_37_2
#undef TP_37_3
#undef TP_37_4
#undef TP_37_5
#undef TP_37_6
#undef TP_37_7
#undef TP_37_8
#undef TP_37_9
#undef TP_37_10
#undef TP_37_11
#undef TP_37_12
#undef TP_38_0
#undef TP_38_1
#undef TP_38_2
#undef TP_38_3
#undef TP_38_4
#undef TP_38_5
#undef TP_38_6
#undef TP_38_7
#undef TP_39_1
#undef TP_39_2
#undef TP_39_3
#undef TP_40
#undef TP_41
#undef TP_42
#undef TP_43
#undef TP_44
#undef TP_45
#undef TP_46
#undef TP_47
#undef TP_48
#undef TP_49
#undef TP_50
#undef TP_51
#undef TP_52
#undef TP_53
#undef TP_54
#undef TP_55
#undef TP_56
#undef TP_57
#undef TP_58
#undef TP_59
#undef TP_60
#undef TP_61
#undef TP_62
#undef TP_63
#undef TP_64
#undef TP_65
#undef TP_66
#undef TP_67
#undef TP_68
#undef TP_69
#undef TP_70
#undef TP_71
#undef TP_72
#undef TP_73
#undef TP_74
#undef TP_75
#undef TP_76

#define TP_01 0
#define TP_02 0
#define TP_03 0
#define TP_04 0
#define TP_05 0
#define TP_06 0
#define TP_07 0
#define TP_08 0
#define TP_09 0
#define TP_10 0
#define TP_11 0
#define TP_12 0
#define TP_13 (((OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_CZ)) & (TOSVERSION < 0x162))
#define TP_14 0
#define TP_15 (((OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_CZ)) & (TOSVERSION < 0x162))
#define TP_16 0
#define TP_17 0
#define TP_18 0
#define TP_19 0
#define TP_20 0
#define TP_21 0
#define TP_22 0
#define TP_23 (OS_COUNTRY == CTRY_CZ)
#define TP_24 0
#define TP_25 0
#define TP_26 0
#define TP_27 0
#define TP_28 0
#define TP_29 0
#define TP_30 0
#define TP_31 0
#define TP_32 0
#define TP_33 0
#define TP_34 0
#define TP_35_6 0
#define TP_35_8 0
#define TP_35_16 0
#define TP_35_32 0
#define TP_40 0
#define TP_41 0
#define TP_42 0
#define TP_46 0
#define TP_47 0
#define TP_48 0
#define TP_49 0
#define TP_50 0
#define TP_51 0
#define TP_52 0
#define TP_53 0
#define TP_54 0
#define TP_55 0
#define TP_56 0
#define TP_57 0
#define TP_58 0
#define TP_59 0
#define TP_60 0
#define TP_61 0
#define TP_62 0
#define TP_63 0
#define TP_64 0
#define TP_65 0
#define TP_66 0
#define TP_67 0
#define TP_68 0
#define TP_69 (((OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_CZ)) & (TOSVERSION < 0x162))
#define TP_70 (((OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_CZ)) & (TOSVERSION < 0x162))
#define TP_71 0
#define TP_72 0
#define TP_73 (((OS_COUNTRY == CTRY_SE) | (OS_COUNTRY == CTRY_CZ)) & (TOSVERSION < 0x162))
#define TP_74 0
#define TP_75 0
#define TP_76 0

#endif

/*
 * make sure the defaults are used for patches that are not activated
 */
#if !TP_07
#undef STEP_RATE
#endif
#if !TP_20
#undef PRNTIMEOUT
#endif
#if !TP_21
#undef CONTERM
#endif
#if !TP_75
#undef SPEED
#endif

/*
 * These are the defaults that are used for patches that are not activated
 */
#ifndef STEP_RATE
#define STEP_RATE 3
#endif
#ifndef FDC_COOKIE
/* FDC_1ATC */
#define FDC_COOKIE $01415443
#endif
#ifndef BOOT_TIME
#define BOOT_TIME 80
#endif
#ifndef PRNTIMEOUT
#define PRNTIMEOUT 30
#endif
#ifndef CONTERM
#define CONTERM 7
#endif
#ifndef FLOPDELAY
#define FLOPDELAY 281
#endif
#ifndef SPEED
#define SPEED 1
#endif


/* long multiply routine without floating point
 *  call with:
 *		two long values on stack
 *  returns:
 *		long value in R0 and R1
 *
 * warning:  no overflow checking or indication!!!!
 * struct {
 *	int hiword;
 *	int loword;
 * };
 * long lmul(l1,l2)
 * long l1,l2;
 * {
 * 
 * 	long t1;
 * 	register int sign;
 * 	register int t2;
 * 
 * 	sign = 0;
 * 	if(l1 < 0) {
 * 		l1 = -l1;	; make it positive
 * 		sign++;
 * 	}
 * 	if(l2 < 0) {
 * 		l2 = -l2;	; make it positive
 * 		sign++;
 * 	}
 * 	t1 = l1.loword*l2.loword;
 * 	t2 = l1.hiword*l2.loword + l2.hiword*l1.loword;
 * 	t1.hiword = t1.hiword + t2;
 * 	if(sign&1)
 * 		t1 = -t1;	; negate results
 * 	return(t1);
 * }
 */

#ifndef __GNUC__

	xdef	lmul
	text
lmul:
	link	a6,#-4
	clr.w	d2
	tst.l	8(a6)		/* is first arg negative? */
	bge L2
	neg.l	8(a6)		/* yes, negate it */
	addq.w  #1,d2			/*  increment sign flag */
L2:
	tst.l	12(a6)		/* is second arg negative? */
	bge L3
	neg.l	12(a6)		/* yes, make it positive */
	addq.w  #1,d2				/* increment sign flag */
L3:
	move	10(a6),d0		/* arg1.loword */
	mulu	14(a6),d0		/* arg2.loword */
	move.l	d0,-4(a6)	/* save in temp */
	move	8(a6),d0		/* arg1.hiword */
	mulu	14(a6),d0		/* arg2.loword */
	move	12(a6),d1		/* arg2.hiword */
	mulu.w	10(a6),d1		/* arg1.loword */
	add.w	d1,d0			/* form the sum of 2 lo-hi products */
	add.w	-4(a6),d0	/* add to temp hiword */
	move.w	d0,-4(a6)	/* store back in temp hiword */
	move.l	-4(a6),d0	/* long results */
	btst	#0,d2			/* test sign flag */
	beq L4
	neg.l	d0		/* complement the results */
L4:
	unlk	a6
	rts

#endif /* __GNUC__ */

%macro normality_test(dataset, var);
	Title 'Test normality';

	ods output moments = class_moments;
	PROC UNIVARIATE DATA=&dataset NORMAL noprint;
		VAR &var;
		HISTOGRAM &var/NORMAL;
		PROBPLOT &var/NORMAL;
		ODS OUTPUT TestsForNormality=NORMALITYTEST;
	RUN;
	ods output close;

	proc sql noprint;
		select cValue1 into:std
		from class_moments
		where Label1 = 'Std Deviation';
	run;
	proc sql noprint;
		select cValue1 into:Num
		from class_moments
		where Label1 = 'N';
	run;

	PROC PRINT DATA=NORMALITYTEST;
	RUN;

	Title 'Perform D’Agostino test';
	PROC RANK DATA=&dataset OUT=RANKS;
		VAR &var;
		RANKS K;
	RUN;

	DATA DAgos;
		SET RANKS;
		S = &std;
		N = &num;
		D_YK = &var*(K - 0.5*(N+1))/(S*SQRT(N**3*(N-1)));
	RUN;

	PROC PRINT DATA = DAgos;
	RUN;

	PROC MEANS DATA=DAgos SUM;
		VAR D_YK;
	RUN;
%mend normality_test;



/*
	usage: 
	DATA EXE4;
	INPUT OBS Y@@;
	DATALINES;
		1 	104.3 	6 	99.0 	11 	112.5 	16 	114.0 
		2 	132.4 	7 	109.4 	12 	98.8 	17 	98.9 
		3 	112.4 	8 	101.9 	13 	97.0 	18 	112.1 
		4 	100.7 	9 	100.5 	14 	114.8 	19 	100.6 
		5 	105.3 	10 	110.5 	15 	110.7 	20 	119.3 
		;
	RUN;


	%normality_test(EXE4, Y);

*/

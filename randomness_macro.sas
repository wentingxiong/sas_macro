%macro randomness_test(dataset, by, var);
proc sort data = &dataset;
	by &by;
run;

proc rank data = &dataset out=ranking;
	var &var;
	ranks R;
run;

data ranking;
	set ranking;
	R1 = LAG1(R);
run;

proc means data = ranking MEAN N;
	var &var;
	OUTPUT OUT = out1 MEAN(R)=MEANR N(R) = NUMR;
run;

proc sql noprint;
	select MEANR into: mean1
	from out1;
	select NUMR into: num
	from out1;
run;

%put &out1;
%put &num;

data ranking;
	set ranking;
	Z = R - &mean1;
	Z1= R1 - &mean1;
	COV = Z*Z1;
RUN;

proc print data = ranking;
run;

PROC MEANS DATA=ranking SUM CSS;
	VAR COV R;
	OUTPUT OUT=SERIAL SUM(COV)=SUMCOV CSS(COV)=CSSCOV SUM(R)=SUMR CSS(R)=CSSR; 
RUN;

DATA SERIAL;
	SET SERIAL;
	N = &num;
	ETA = SUMCOV/CSSR;
	MU  = -1/N;
	SIG = (5*n**4 - 24*n**3 + 29*n**2 + 54*n - 16)/(5*n**2*(n-1)**3 );
	STAT= (ETA - MU)/SQRT(SIG);
	C_Oneside= QUANTILE('NORMAL',1-0.05);
	C_Twoside= QUANTILE('NORMAL',1-0.05/2);
	KEEP ETA MU SIG STAT C_Oneside C_Twoside;
RUN;

PROC PRINT DATA=SERIAL;
RUN;

%mend randomness_test;

%macro auto_correlation(dataset, var);
DATA LAG;
	SET &dataset;
	Y1 = LAG1(&var);
RUN;

PROC MEANS DATA=LAG MEAN N;
	VAR &var;
	OUTPUT OUT = out2 MEAN(&var)=MEAN_VAR N(&var)=NUM;
RUN;

proc sql noprint;
	select MEAN_VAR into:mean2
	from out2;
	select NUM into: num
	from out2;
run;

DATA LAG;
	SET LAG;
	Z = &var  - &mean2;
	Z1= Y1 - &mean2;
	COV = Z*Z1;
RUN;

proc print data = LAG;
run;

PROC MEANS DATA=LAG SUM CSS;
	VAR COV &var;
	OUTPUT OUT=AUTOCOR SUM(COV)=SUMCOV CSS(COV)=CSSCOV SUM(&var)=SUM_ CSS(&var)=CSS_; 
RUN;

DATA AUTOCOR;
	SET AUTOCOR;
	N = &num;
	R = SUMCOV/CSS_;
	MU  = -1/N;
	SIG = (n-2)**2/(n**2*(n-1));
	STAT= (R - MU)/SQRT(SIG);
	C_Oneside= QUANTILE('NORMAL',1-0.05);
	C_Twoside= QUANTILE('NORMAL',1-0.05/2);
	KEEP R MU SIG STAT C_Oneside C_Twoside;
RUN;

PROC PRINT DATA=AUTOCOR;
RUN;
%mend auto_correlation;

/*
usage:
DATA e5;
	INPUT OBS Y@@;
	DATALINES;
	1 	104.3 	6 	99.0 	11 	112.5 	16 	114.0 
	2 	132.4 	7 	109.4 	12 	98.8 	17 	98.9 
	3 	112.4 	8 	101.9 	13 	97.0 	18 	112.1 
	4 	100.7 	9 	100.5 	14 	114.8 	19 	100.6 
	5 	105.3 	10 	110.5 	15 	110.7 	20 	119.3 
	;
RUN;

Title 'Serial correlation';
%randomness_test(e5,OBS,Y);
Title 'auto';
%auto_correlation(e5,Y);
*/


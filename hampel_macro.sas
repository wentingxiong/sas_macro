%macro hampel(dataset, by);
PROC SORT DATA = &dataset OUT = &dataset;
	BY &by;
RUN;

PROC MEANS DATA = &dataset MEDIAN noprint;
	VAR &by;
	OUTPUT OUT=out1  MEDIAN(&by)=MEDIAN1;
RUN;

proc sql noprint;
	select MEDIAN1 into: median1
	from out1;

data &dataset;
	set &dataset;
	Median_Y = &median1;
	D = ABS(&by-&median1);
run;

PROC MEANS DATA = &dataset MEDIAN noprint;
	VAR D;
	OUTPUT OUT=out2  MEDIAN(D)=MEDIAN2;
RUN;

proc sql noprint;
	select MEDIAN2 into: median2
	from out2;

data &dataset;
	set &dataset;
	Median_D = &median2;
	Z = ABS(&by-&median1)/&median2;
run;

%mend hampel;

/*
	usage:

DATA e3;
	INPUT Obs Y @@;
	DATALINES;
	1 	104.3 	6 	99.0 	11 	112.5 	16 	114.0 
	2 	132.4 	7 	109.4 	12 	98.8 	17 	98.9 
	3 	112.4 	8 	101.9 	13 	97.0 	18 	112.1 
	4 	100.7 	9 	100.5 	14 	114.8 	19 	100.6 
	5 	105.3 	10 	110.5 	15 	110.7 	20 	119.3 
	;
RUN;

%hampel(dataset = e3, by = Y);

*/


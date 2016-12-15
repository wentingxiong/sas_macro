
/*
	split data by site, sensor and hour
	usage: %split(Site1, 1, 1);
	then table Site1_sensor1_hour1 is created
*/

%macro split(dataset, site, sensor, hour);
proc sql;
	create table &site._sensor&sensor._hour&hour as 
	(select Site,Sensor,Hour,PPM
	from &dataset
	where Site = "&site." and Sensor = &sensor and Hour = &hour);
%mend split;

%macro loop_split(dataset);
%do i=1 %to 7;
	%do j = 1 %to 2;
		%do k = 1 %to 4;
			%split(&dataset, Site&i, &j, &k);
		%end;
	%end;
%end;
%mend loop_split;

/*
test usage

*/
/*
LIBNAME SASDATA 'D:\ProgramData\SasData';
DATA MYDATA;
	SET SASDATA.assignmentdata;
%loop_split(MYDATA);

%include "D:\ProgramData\SasProc\hampel_e3.sas";
%hampel(dataset = Site7_sensor2_hour4, by = PPM);

proc print data = Site7_sensor2_hour4;
run;
*/


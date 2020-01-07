
	clear all
	set more off, perm
	set maxvar 15000
	set varabbrev off

	* Root folders

	global in_DHS	"C:\Users\ROROXOM\Center for Global Development\Center For Global Development - NDrive\NB_Reproductive Ecosystem\DHS individual recode data files"
	global output	"C:\Users\ROROXOM\Center for Global Development\Global Health Policy - Health\Roxanne\UBF"
	global output	"C:\Users\ROROXOM\Documents"
	
	* Run do file to select which surveys to pull data from
	
*	do "$output\1 selection"
	
	* Run do file to extract data
	
*	do "$output\2 extraction"

	* Run do file to clean data

*	do "$output\3 clean"

	* Run do file to analyze data

*	do "$output\4 regressions"

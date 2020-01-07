
********************************************************************************
* Selection
********************************************************************************

	* all surveys listed by the DHS program at https://www.dhsprogram.com/data/available-datasets.cfm

	use "$output\DHS match" , clear

	* keep by data availability

	keep if sur_ir == "Data Available" // any data available
	drop if sur_recode == .m // typically signifies individual recode data not posted

	* keep by survey type
	keep if inlist(sur_type,"Standard DHS","Continuous DHS","Interim DHS")
	drop if inlist(sur,"Dominican Republic 2007","Dominican Republic 2013") // these surveys solely sample the population in sugar cane plantations

	* drop if country not in LAC, Africa, Asia
	drop if inlist(country,"Albania","Armenia","Azerbaijan","Moldova","Ukraine")

	* keep by number of surveys per country
	bysort country: egen ns = count(sur)
	drop if inlist(ns,1,2,3)
	drop ns

	* drop by sample of women
	merge 1:1 file_ir using "$output\DHS match sample of women"
	drop if _merge == 2
	drop _merge
	drop if v020_dec == "ever married sample"

	* save file names
	levelsof file_ir if !inlist(file_ir,"PEIR5A") , local(datafiles) clean
	global datafiles `datafiles'

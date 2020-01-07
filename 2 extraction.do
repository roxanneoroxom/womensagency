
********************************************************************************
* Extraction
********************************************************************************

	global mustkeep		isvar aidsex file_ir caseid v000 v001 v002 v003 v005 v007 v008 v012 v020 v024 v102
	global otherkeep 	v190 v133 v302 v310 v312 v384a v384b v384c v466 v467b v502 v610 v612 v743d v744* /*Roxanne*/ v149 v201 v218 v604 v602 v822 v613 v614 v627 v628 v629 v467d /*Mead*/ v130 v212 v011 
	
	***** create empty datasets as needed

	clear all
	input str10 file_ir
	"delete"
	end
	tempfile ir_data
	save `ir_data'
	
	****** extract, save and append
	
	foreach f of global datafiles {
	
		di "Starting work on `f'"
		
		* load and show file name
		
		use "$in_DHS//`f'fl", clear
		
		renvars, lower

		* create identifier for each survey file

		gen file_ir = "`f'"
		replace file_ir = upper(file_ir)

		* rename caseid (if needed)
		
		isvar case_id
		capture rename `r(varlist)' caseid
		
		* keep certain variables
		
		isvar $mustkeep $otherkeep
		keep `r(varlist)'


		* create string versions of anything with a label
		
		isvar $mustkeep $otherkeep
		ds `r(varlist)' , has(vallabel)
		local HasLabeledValues `r(varlist)'
		foreach variable of local HasLabeledValues {
			decode `variable', gen(`variable'_dec)
			replace `variable'_dec = strlower(`variable'_dec)
		}
		_strip_labels *

		* save data

		tempfile `f'_subset
		save ``f'_subset'
		
		* append
		
		use `ir_data' , clear
		append using ``f'_subset'
		save `ir_data' , replace

}

	***** remove delete

	drop if file_ir == "delete"

	***** correct file_ir for some continuous surveys
	
	replace file_ir = "PEIR5A" if inlist(v007,2007,2008) & file_ir == "PEIR51"
	
	***** drop duplicates in DRIR21 ". duplicates example file_ir caseid

//	drop if inlist(caseid,"7 62 1  2","127  8 1  2") & file_ir == "DRIR21"
	
	***** save
	
	save "$output\DHS output from extraction" , replace

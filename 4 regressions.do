
	cd "$output"
	use "DHS output from clean" , clear
	
	keep if inrange(age,15,49)
	
	* drop observations that are true duplicates
	drop if inlist(caseid,"7 62 1  2","127  8 1  2") & file_ir == "DRIR21"
	
	* list file_ir caseid aafb age agegap tkb if aafb > age & aafb != .
	* drop observations in which age at first birth is greater than current age
	drop if inlist(caseid,"   496 32 01  3") & file_ir == "PEIR31"
	drop if inlist(caseid,"  1247 68 01  4") & file_ir == "PEIR31"
	
	* confirm aspects of tkb variable
	assert inrange(tkb,0,27) & tkb != .
	
	gen byte touse = (inrange(aafb,12,50) | aafb == .)

	* make agegap positive
	assert agegap <= 0 | agegap == .
	replace agegap = agegap * -1
	
	* gen muslim
	gen muslim = 0 if religion != ""
	replace muslim = 1 if religion == "muslim"
	replace muslim = 0 if religion != "muslim" & religion != ""
	la var muslim "Muslim"
	
	save "base" , replace
	
	****************************************************************************
	***** GLOBALS
	****************************************************************************	

	* matching, norms, and other variables
	global matchvars	country_e urban ybfk abfk eduatt // muslim
	global normsvars	wbj_any	txp txd pwt hfp_any inkgrp // afcj
	global controlvars	age agegap aafb urban poor edusy country region cc_e by religion
	
	* remainder of collapse text... use "//" to hide if only want wbj
	global collmean		"txp_NK=txp			txd_NK=txd			pwt_NK=pwt 		hfp_NK=hfp_any		inkgrp_NK=inkgrp		" // afcj_NK=afcj
	global collcount	"ntxp_NK=txp 		ntxd_NK=txd 		npwt_NK=pwt 	nhfp_NK=hfp_any		ninkgrp_NK=inkgrp		" // nafcj_NK=afcj
	global collsum		"tottxp_NK=txp 		tottxd_NK=txd		totpwt_NK=pwt 	tothfp_NK=hfp_any	totinkgrp_NK=inkgrp		" // totafcj_NK=afcj
	global todrop		" & txp_NK == . 	 & txd_NK == .		& pwt_NK == . 	& hfp_NK == .		& inkgrp_NK == .		" // & afcj_NK == .

	* capture numbers for India and Peru
	summarize country_e if country == "India"
	return list
	global india = r(max)
	
	summarize country_e if country == "Peru"
	return list
	global peru = r(max)
	
	****************************************************************************
	***** DEP. VAR & INDEP. VARS FROM THE PRESENT
	****************************************************************************	
	
use "base" , clear

	keep if inrange(tkb,1,27) /*women who have at least one kid*/ /*count is 1,891,917, which is the same as "count if ybfk != ." and "count if abfk != ." */
	
	gen ybfk = iy - agegap - 1 // iy + (agegap) - 1 when agegap is negative
	la var ybfk "Year one year before birth of first child"
	
	gen abfk = aafb - 1
	lab var abfk "Age one year before birth of first child"
	
	keep ub1 aafb $normsvars $matchvars $controlvars
	
save "left" , replace

	****************************************************************************	
	***** INDEP. VARS FROM THE PAST - EXACT, MINUS 1, PLUS 1, MINUS 2
	****************************************************************************	
	
use "base" , clear

	renvars iy age \ ybfk abfk

	collapse ///
	(mean)	wbj_NK=wbj_any $collmean ///
	(count)	nwbj_NK=wbj_any	$collcount ///
	(sum)	totwbj_NK=wbj_any $collsum ///
	if touse & tkb == 0 , by($matchvars)
	
	summ $matchvars *wbj_NK if wbj_NK != .
	drop if wbj_NK == . $todrop
	
save "right_exact" , replace

	***** ****** *****

use "base" , clear

	renvars iy age \ ybfk abfk

	replace ybfk = ybfk - 1
	replace abfk = abfk - 1
	
	collapse ///
	(mean)	wbj_NK=wbj_any $collmean ///
	(count)	nwbj_NK=wbj_any	$collcount ///
	(sum)	totwbj_NK=wbj_any $collsum ///
	if touse & tkb == 0 , by($matchvars)
	
	summ $matchvars *wbj_NK if wbj_NK != .
	drop if wbj_NK == . $todrop
	
save "right_minus1" , replace	

	***** ****** *****
	
use "base" , clear

	renvars iy age \ ybfk abfk

	replace ybfk = ybfk - 2
	replace abfk = abfk - 2
	
	collapse ///
	(mean)	wbj_NK=wbj_any $collmean ///
	(count)	nwbj_NK=wbj_any	$collcount ///
	(sum)	totwbj_NK=wbj_any $collsum ///
	if touse & tkb == 0 , by($matchvars)
	
	summ $matchvars *wbj_NK if wbj_NK != .
	drop if wbj_NK == . $todrop
	
save "right_minus2" , replace

	****************************************************************************	
	*****  REGS
	****************************************************************************	

	***** LEFT X EXACT
/*	
	use "left" , clear
	merge m:1 $matchvars using "right_exact"
*/	
	
	**** LEFT X EXACT MINUS1 MINUS2
	
	use "right_exact", clear
	append using "right_minus1"
	append using "right_minus2"

	collapse (sum) tot* n* , by($matchvars)

	capture gen wbj_NK 		= totwbj_NK/nwbj_NK
	capture gen txp_NK  	= tottxp_NK/ntxp_NK
	capture gen txd_NK  	= tottxd_NK/ntxd_NK
	capture gen pwt_NK 		= totpwt_NK/npwt_NK
	capture gen hfp_NK  	= tothfp_NK/nhfp_NK
	capture gen fsvr_NK 	= totfsvr_NK/nfsvr_NK
	capture gen afcj_NK 	= totafcj_NK/nafcj_NK
	capture gen sp_NK		= totsp_NK/nsp_NK
	capture gen inkgrp_NK	= totinkgrp_NK/ninkgrp_NK

	save "right_3", replace
	
	use "left" , clear
	merge m:1 $matchvars using "right_3"

	local tag [historical cohort w/o kids]
	capture la var wbj_NK 		"Cites any reason as justifying wife-beating `tag'"
	capture la var txp_NK 		"Getting permission a big problem for medical care `tag'"
	capture la var txd_NK 		"Facility distance a big problem for medical care `tag'"
	capture la var pwt_NK 		"Preferred waiting time (within 0-6+ years) `tag'"
	capture la var hfp_NK 		"Number of media sources (0-3) heard of FP through `tag'"
	capture la var fsvr_NK		"Any final say on visits to relatives `tag'"
	capture la var afcj_NK 		"Wife justified to ask husband w/STI to use condom `tag'"
	capture la var inkgrp_NK	"Ideal # of kids `tag'"
	
	capture la var country_e	"Country"
	capture la var ybfk			"Year(s) before first kid"
	capture la var abfk			"Age(s) before first kid"
	capture la var inkgrp		"Ideal number of kids (0,1,2,3,4,5,6+)"
	capture la var agegap		"Age gap"
	capture la var txd			"Facility distance a big problem for medical care"
	capture la var aafb			"Age at first birth"
	capture la var pwt 			"Preferred waiting time (within 0-6+ years)"
	
	* save what variables we matched on in a text string
	global graph_text "Matched using "
	foreach var of varlist $matchvars {
		local var_text : var lab `var'
		global graph_text "$graph_text `var_text'..."
	}

********************************************************************************
* Friday, August 1
********************************************************************************

	gen log_aafb = log(aafb)
	
	global dep	 log_aafb
	global depT	 "DV = Log of age at first birth"
	
	capture drop keep_in_model
	eststo clear
	xi: eststo : ivreg2 $dep by wbj_NK inkgrp_NK agegap i.country_e				(ub1 = hfp_NK txd_NK) ,  small
	gen keep_in_model = e(sample)
	xi: eststo : ivreg2 $dep by wbj_NK inkgrp_NK i.country_e					(ub1 = hfp_NK txd_NK) if keep_in_model == 1 ,  small

	esttab est* using "IVREG2 $dep $cov matched with $matchvars.rtf" , replace label ///
	star brackets nobaselevels /*noomitted*/ stats(N r2_a F, fmt(%12.0fc 3)) compress onecell  indicate("Country FE = *country*")  ///
	title("$depT ; Sample = exact, minus 1, minus 2 matches") addnotes("$graph_text") ///
	nomtitles
	
********************************************************************************
* Wednesday, July 31
********************************************************************************	

	global dep	 ub1 // aafb
	global depT	 "DV = Used FP before first living kid (binary)" // "DV = Age at first birth"
	global cov	 wbj_NK hfp_NK txd_NK inkgrp_NK
	
	capture drop keep_in_model
	capture rm "$dep $cov matched with $matchvars.rtf"

	eststo : reg $dep by $cov agegap i.country_e
	gen keep_in_model = e(sample)
	
	* FIRST PAGE
	
	eststo clear
	eststo : reg $dep by 				   i.country_e		if keep_in_model == 1
	eststo : reg $dep by wbj_NK			   i.country_e		if keep_in_model == 1
	eststo : reg $dep by hfp_NK			   i.country_e		if keep_in_model == 1
	eststo : reg $dep by txd_NK		  	   i.country_e		if keep_in_model == 1
	eststo : reg $dep by inkgrp_NK 		   i.country_e		if keep_in_model == 1
	eststo : reg $dep by $cov			   i.country_e		if keep_in_model == 1
	eststo : reg $dep by $cov		agegap i.country_e		if keep_in_model == 1
	
	esttab est* using "$dep $cov matched with $matchvars.rtf" , replace label ///
	star brackets nobaselevels /*noomitted*/ stats(N r2_a F, fmt(%12.0fc 3)) compress onecell indicate("Country FE = *country*") ///
	title("$depT ; Sample = exact, minus 1, minus 2 matches") addnotes("$graph_text") ///
	nomtitles
		
	* X PAGES ONWARD
	
	foreach var of varlist $cov {
	
	eststo clear
	eststo : reg $dep by `var' 									if keep_in_model == 1
	eststo : reg $dep by `var' i.country_e						if keep_in_model == 1
	eststo : reg $dep by `var' agegap i.country_e				if keep_in_model == 1
	
	esttab est* using "$dep $cov matched with $matchvars.rtf" , append label ///
	star brackets nobaselevels /*noomitted*/ stats(N r2_a F, fmt(%12.0fc 3)) compress onecell indicate("Country FE = *country*") ///
	title("DV = $depT ; Sample = exact, minus 1, minus 2 matches") addnotes("$graph_text") ///
	nomtitles
		
	}
	
	* SEPARATE PAGE
	
	capture log close
	log using "$dep $cov matched with $matchvars BIVARIATE" , replace smcl
	
	capture bivariate $dep by $cov agegap , tabstat addstat(count variance)
	frmttable , statmat(r(bivariate))
	frmttable , statmat(r(TransposedST))
	
	corr $dep by $cov agegap
	
	capture log close
	
	translator set smcl2pdf logo off
	translator set smcl2pdf fontsize 8
	translator set smcl2pdf lmargin 0.4
	translator set smcl2pdf rmargin 0.4
	translator set smcl2pdf tmargin 0.4
	translator set smcl2pdf bmargin 0.4
	translator set smcl2pdf headertext "$dep $cov matched with $matchvars BIVARIATE.pdf"

	translate "$dep $cov matched with $matchvars BIVARIATE.smcl" "$dep $cov matched with $matchvars BIVARIATE.pdf" , trans(smcl2pdf) replace

********************************************************************************
* Monday, July 29
********************************************************************************	

	global dep	 ub1 // aafb
	global depT	 "DV = Used FP before first living kid (binary)" // "DV = Age at first birth"
	global cov	 wbj_NK hfp_NK txd_NK inkgrp_NK
	global cov2	 c.wbj_NK##c.agegap c.hfp_NK##c.agegap c.txd_NK##c.agegap c.inkgrp_NK##c.agegap 
	
	capture drop keep_in_model
	capture rm "$dep $cov $cov2 matched with $matchvars.rtf"

	eststo : reg $dep by $cov agegap i.country_e
	gen keep_in_model = e(sample)

	* FIRST PAGE
	
	eststo clear
	eststo : reg $dep by				   i.country_e		if keep_in_model == 1
	eststo : reg $dep by $cov $cov2 agegap i.country_e		if keep_in_model == 1
	eststo : reg $dep by $cov			   i.country_e		if keep_in_model == 1
	eststo : reg $dep by $cov		agegap i.country_e		if keep_in_model == 1
	eststo : reg $dep by      $cov2		   i.country_e		if keep_in_model == 1
	eststo : reg $dep by      $cov2 agegap i.country_e		if keep_in_model == 1
	
	esttab est* using "$dep $cov $cov2 matched with $matchvars.rtf" , replace label ///
	star brackets nobaselevels /*noomitted*/ stats(N r2_a F, fmt(%12.0fc 3)) compress onecell indicate("Country FE = *country*") ///
	title("DV = $depT ; Sample = exact, minus 1, minus 2 matches") addnotes("$graph_text") ///
	nomtitles
	
	* SECOND PAGE
	
	eststo clear
	eststo : reg $dep by 				if keep_in_model == 1
	eststo : reg $dep by i.country_e	if keep_in_model == 1

	esttab est* using "$dep $cov $cov2 matched with $matchvars.rtf" , append label ///
	star brackets nobaselevels /*noomitted*/ stats(N r2_a F, fmt(%12.0fc 3)) compress onecell indicate("Country FE = *country*") ///
	title("DV = $depT ; Sample = exact, minus 1, minus 2 matches") addnotes("$graph_text") ///
	nomtitles
	
	* THIRD PAGES ONWARD
	
	foreach var of varlist $cov {
	
	eststo clear
	eststo : reg $dep by `var' 									if keep_in_model == 1
	eststo : reg $dep by `var' i.country_e						if keep_in_model == 1
	eststo : reg $dep by `var' agegap i.country_e				if keep_in_model == 1
	eststo : reg $dep by c.`var'#c.agegap i.country_e			if keep_in_model == 1
	eststo : reg $dep by c.`var'#c.agegap agegap i.country_e	if keep_in_model == 1
		
	esttab est* using "$dep $cov matched with $matchvars.rtf" , append label ///
	star brackets nobaselevels /*noomitted*/ stats(N r2_a F, fmt(%12.0fc 3)) compress onecell indicate("Country FE = *country*") ///
	title("DV = $depT ; Sample = exact, minus 1, minus 2 matches") addnotes("$graph_text") ///
	nomtitles
		
	}
	
	* SEPARATE PAGE
	
	capture log close
	log using "$dep $cov $cov2 matched with $matchvars BIVARIATE" , replace smcl // text
	
	capture bivariate $dep by $cov $cov2 agegap , tabstat addstat(count variance) // don't forget to remove country
	frmttable , statmat(r(bivariate))
	frmttable , statmat(r(TransposedST))
	
	corr $dep by $cov agegap
	
	capture log close
	
	translator set smcl2pdf logo off
	translator set smcl2pdf fontsize 8
	translator set smcl2pdf lmargin 0.4
	translator set smcl2pdf rmargin 0.4
	translator set smcl2pdf tmargin 0.4
	translator set smcl2pdf bmargin 0.4
	translator set smcl2pdf headertext "$dep $cov matched with $matchvars BIVARIATE.pdf"

	translate "$dep $cov $cov2 matched with $matchvars BIVARIATE.smcl" "$dep $cov matched with $matchvars BIVARIATE.pdf" , trans(smcl2pdf) replace

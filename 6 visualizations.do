
********************************************************************************
* Preferred waiting time
********************************************************************************

	cd "$output"
	use "DHS output from clean" , clear
	
	keep if inrange(age,15,49)
	
	* drop observations that are true duplicates
	drop if inlist(caseid,"7 62 1  2","127  8 1  2") & file_ir == "DRIR21"
	
	* list file_ir caseid aafb age agegap tkb if aafb > age & aafb != .
	* drop observations in which age at first birth is greater than current age
	drop if inlist(caseid,"   496 32 01  3") & file_ir == "PEIR31"
	drop if inlist(caseid,"  1247 68 01  4") & file_ir == "PEIR31"

	* surveys with recode structure 1 and 2 asked PWT only of married/in union women
	drop if inlist(rec,.,1,2)

	* certain surveys asked PWT of only married/in union women
	// table file_ir if partner == 0 , c(count pwt)
	drop if inlist(file_ir,"HTIR31","TRIR41","TRIR61")
	
	* table shows that only a handful on never married women answered the question
	gen ans_nm_nk = 1 if pwt != . & partner == 0 & tkb == 0
	egen s_ans_nm_nk = total(ans_nm_nk) , by(file_ir)
	
	* other
	keep if tkb == 0
	
	gen pwtU = pwt if urban == 1
	gen pwtR = pwt if urban == 0
	
	* collapse
	collapse (mean) mean_pwt=pwt mean_pwtU=pwtU mean_pwtR=pwtR ///
	(median) med_pwt=pwt med_pwtU=pwtU med_pwtR=pwtR (max) s_ans_nm_nk [pw=sw] , by(country* sy file_ir rec)
	
	sort s_ans*
	
	preserve
	drop if s_ans_nm_nk < 300
	
	sort country sy
	
	twoway ///
	(scatter pwtU sy, connect(l) msize(*.65) mcolor("228 0 43"%50) lcolor("228 0 43"%50)) || ///
	(scatter pwtR sy, connect(l) msize(*.65) mcolor("255 191 63"%50) lcolor("255 191 63"%50)) || ///
	(scatter pwt sy, connect(l) msize(*.65)  mcolor(black) lcolor(black)) ///
	, by(country, compact title("Mean preferred waiting time among women 15-49 without kids", size(*.5)) note("") graphregion(color(white))) ///
	legend(label(1 "Urban") label(2 "Rural") label(3 "Urban & Rural") symysize(*.25) symxsize(*.25) size(*.5) row(1)) ///
	ylab(0(1)6 , angle(0) glcolor(gray*.25)) xlab(, angle(45) grid) xtitle("") scheme(s2mono)
	
	graph export "PWT urban rural NK.pdf" , replace
	
	twoway ///
	(scatter med_pwtU sy, connect(l) msize(*.65) mcolor("228 0 43"%50) lcolor("228 0 43"%50)) || ///
	(scatter med_pwtR sy, connect(l) msize(*.65) mcolor("255 191 63"%50) lcolor("255 191 63"%50)) || ///
	(scatter med_pwt sy, connect(l) msize(*.65)  mcolor(black) lcolor(black)) ///
	, by(country, compact title("Median preferred waiting time among women 15-49 without kids", size(*.5)) note("") graphregion(color(white))) ///
	legend(label(1 "Urban") label(2 "Rural") label(3 "Urban & Rural") symysize(*.25) symxsize(*.25) size(*.5) row(1)) ///
	ylab(0(1)6 , angle(0) glcolor(gray*.25)) xlab(, angle(45) grid) xtitle("") scheme(s2mono)
	
	
	
	restore
	
	
	cd "$output"
	use "DHS output from clean" , clear
	
	keep if inrange(age,15,49)
	
	keep if inlist(country,"Kenya","Rwanda")

	gen pwt_nk = pwt if tkb == 0
	gen pwt_nm = pwt if partner == 0
	gen pwt_cm = pwt if partner == 1
	
	mean pwt_cm count pwt_cm
	
	table file_ir urban if country == "Kenya" , ///
	c(mean pwt count pwt mean pwt_nm count pwt_nm) missing
	
	
	
/*
file_ir	country_e	rec	s_ans_nm_nk
GUIR41	Guatemala	3	12
GUIR34	Guatemala	3	21
NIIR31	Niger	3	30
NPIR51	Nepal	5	43
ZWIR31	Zimbabwe	3	186
BOIR31	Bolivia	3	204
DRIR41	Dominican Republic	3	292
BFIR31	Burkina Faso	3	308
*/	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	/*
	cd "$output"
	use "DHS output from clean" , clear
	
	keep if inrange(age,15,49)
	
	* drop observations that are true duplicates
	drop if inlist(caseid,"7 62 1  2","127  8 1  2") & file_ir == "DRIR21"
	
	* list file_ir caseid aafb age agegap tkb if aafb > age & aafb != .
	* drop observations in which age at first birth is greater than current age
	drop if inlist(caseid,"   496 32 01  3") & file_ir == "PEIR31"
	drop if inlist(caseid,"  1247 68 01  4") & file_ir == "PEIR31"

	* drop if survey ONLY posed question to women who were in union/married
	
	drop if inlist(rec,.,1,2) // see DHS recode manual
	// drop if inlist(file_ir,"HTIR31","TRIR41","TRIR61")	
	
	foreach var of varlist pwt /* wbj ptx1 hfp sp*/ {
		gen ans = 1 if `var' != .
		gen ans_nm_nk = 1 if `var' != . & partner == 0 & tkb == 0
	}
	
	collapse (sum) ans_nm_nk ans , by(sy file_ir country_e rec)
	
	rename ans_nm_nk s_ans_nm_nk
	sort s_ans_nm_nk
	
/*
file_ir	sy	rec	country_e	s_ans_nm_nk
TRIR41	1998	3	Turkey	0
HTIR31	1994	3	Haiti	0
TRIR61	2013	6	Turkey	0
GUIR41	1999	3	Guatemala	12
GUIR34	1995	3	Guatemala	21
NIIR31	1998	3	Niger	30
NPIR51	2006	5	Nepal	43
ZWIR31	1994	3	Zimbabwe	186
BOIR31	1994	3	Bolivia	204
DRIR41	1999	3	Dominican Republic	292
BFIR31	1999	3	Burkina Faso	308

*/
	
	
	
	
	
	
	*/
	

********************************************************************************
* Permission to seek treatment for self
********************************************************************************

	cd "$output"
	use "DHS output from clean" , clear
	
	keep if inrange(age,15,49)
	
	* drop observations that are true duplicates
	drop if inlist(caseid,"7 62 1  2","127  8 1  2") & file_ir == "DRIR21"
	
	* list file_ir caseid aafb age agegap tkb if aafb > age & aafb != .
	* drop observations in which age at first birth is greater than current age
	drop if inlist(caseid,"   496 32 01  3") & file_ir == "PEIR31"
	drop if inlist(caseid,"  1247 68 01  4") & file_ir == "PEIR31"

	* surveys with recode structure 1 and 2 asked PWT only of married/in union women
	keep if inlist(rec,4,5,6,7)

	* did any surveys pose question to only married/in union women
	table file_ir partner , c(count txd)
	
	* keep only if have no kids
	keep if tkb == 0
	
	local var txd
	global VarDesc : var lab `var'
	gen A = `var'
	gen U = `var' if urban == 1
	gen R = `var' if urban == 0
	
	* collapse
	collapse (mean) meanA=A meanU=U meanR=R (count) countA=A countU=U countR=R [pw=sw] , by(country* sy file_ir rec)
	
	drop if meanA == .
	
	foreach var of varlist mean* {
		replace `var' = `var' * 100
	}
	
	format mean* %8.0fc
	format countA countR countU %15.0fc
	
	twoway ///
	(scatter meanU sy, connect(l) msize(*.65) mcolor("228 0 43"%50) lcolor("228 0 43"%50)) || ///
	(scatter meanR sy, connect(l) msize(*.65) mcolor("255 191 63"%50) lcolor("255 191 63"%50)) || ///
	(scatter meanA sy, connect(l) msize(*.65)  mcolor(black) lcolor(black)) ///
	, by(country, compact title("$VarDesc", size(*.5)) note("") graphregion(color(white))) ///
	legend(label(1 "Urban") label(2 "Rural") label(3 "Urban & Rural") symysize(*.25) symxsize(*.25) size(*.5) row(1)) ///
	ylab(0(20)100 , angle(0) glcolor(gray*.25)) xlab(, angle(45)) xtitle("") scheme(s2mono)
	
	graph export "TXD urban rural NK.pdf" , replace
	
********************************************************************************
* Final say
********************************************************************************

	cd "$output"
	use "DHS output from clean" , clear
	
	keep if inrange(age,15,49)
	
	* drop observations that are true duplicates
	drop if inlist(caseid,"7 62 1  2","127  8 1  2") & file_ir == "DRIR21"
	
	* list file_ir caseid aafb age agegap tkb if aafb > age & aafb != .
	* drop observations in which age at first birth is greater than current age
	drop if inlist(caseid,"   496 32 01  3") & file_ir == "PEIR31"
	drop if inlist(caseid,"  1247 68 01  4") & file_ir == "PEIR31"
	
/*	
	table file_ir partner if rec == 4 , c(count fsvr_a)
	table file_ir partner if rec == 5 , c(count fsvr_a)
	table file_ir partner if rec == 6 , c(count fsvr_a)
	table file_ir partner if rec == 7 , c(count fsvr_a)
*/	

	drop if inlist(rec,.,1,2,3)
	
	* keep only if have no kids
	keep if tkb == 0
	
	local var fsvr_a
	gen A = `var'
	gen U = `var' if urban == 1
	gen R = `var' if urban == 0
	
	gen RESPNIU=1 if `var' != . & partner == 0
	gen RESPNK=1 if `var' != . & tkb==0
	
	* collapse
	collapse (mean) meanA=A meanU=U meanR=R (count) countA=A countU=U countR=R totRESPNIU=RESPNIU totRESPNK=RESPNK [pw=sw] , by(country* sy file_ir rec)
	
	drop if totRESPNIU == 0
	drop if totRESPNIU <= 250
	
	foreach var of varlist mean* {
		replace `var' = `var' * 100
	}
	
	format mean* %8.0fc
	format countA countR countU totRESPNIU %15.0fc
	
	twoway ///
	(scatter meanU sy, connect(l) msize(*.65) mcolor("228 0 43"%50) lcolor("228 0 43"%50)) || ///
	(scatter meanR sy, connect(l) msize(*.65) mcolor("255 191 63"%50) lcolor("255 191 63"%50)) || ///
	(scatter meanA sy, connect(l) msize(*.65)  mcolor(black) lcolor(black)) ///
	, by(country, compact title("% of women 15-49 without kids who say they have any final say on visits to relatives (%)", size(*.5)) note("") graphregion(color(white))) ///
	legend(label(1 "Urban") label(2 "Rural") label(3 "Urban & Rural") symysize(*.25) symxsize(*.25) size(*.5) row(1)) ///
	ylab(0(20)100 , angle(0) glcolor(gray*.25)) xlab(, angle(45)) xtitle("") scheme(s2mono)
	
	graph export "FSVR urban rural NK.pdf" , replace

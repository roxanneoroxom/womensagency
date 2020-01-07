
	use "$output\DHS output from extraction" , clear

********************************************************************************
* Core variables
********************************************************************************
	
***** generate variable for country code
	gen cc = substr(v000,1,2), after(v000)
	la var cc "Country code"

***** generate variable for survey recode phase
	gen rec = real(substr(v000,3,1)), after(cc)
	la var rec "Recode"
	
***** generate variable that adjusts the year of birth 	
	gen by = . , after(v011)
	replace by = (1900 + int(( v011 - 1)/12))      if !inlist(cc,"ET","NP")
	replace by = (1900 + int(((v011 + 92)-1)/12))  if cc == "ET"
	replace by = (1900 + int(((v011 - 681)-1)/12)) if cc == "NP" & !inlist(v007,52,53)
	replace by = (1900 + int(((v011 + 519)-1)/12)) if cc == "NP" & inlist(v007,52,53)	
	la var  by "Birth year"
	
***** generate variable that adjusts interview year cmc code variable to reflect the gregorian calendar
	gen iy = . , after(v007)
	replace iy = (1900 + int(( v008 - 1)/12))      if !inlist(cc,"ET","NP")
	replace iy = (1900 + int(((v008 + 92)-1)/12))  if cc == "ET"
	replace iy = (1900 + int(((v008 - 681)-1)/12)) if cc == "NP" & !inlist(v007,52,53)
	replace iy = (1900 + int(((v008 + 519)-1)/12)) if cc == "NP" & inlist(v007,52,53)
	la var  iy "Interview year"
	drop v007_dec
	
***** generate variable that assigns a single year to each survey
	egen sy = mode(iy) , by(file_ir)
	la var sy "Survey year"
	note sy: For surveys spanning more than one year, takes on value of year with largest number of respondents

***** generate variable that identifies clusters within countries across surveys
	egen uclust = group(file_ir v001)
	la var uclust "Survey ID + cluster"
	
***** generate variable that identifies regions within countries across surveys
	egen ureg = group(file_ir v024)
	la var ureg "Survey ID + region"
	
***** adjust variable for urban/rural status
	recode v102 (2=0)
	rename v102 urban
	la var urban "Urban"
	drop v102_dec
	
**** adjust variable for sample of women (ever married or all women)

	replace v020_dec = "all woman sample" if ///
	(inlist(file_ir,"BOIR01","COIR01","DRIR01","GHIR02","GUIR01","KEIR03") | inlist(file_ir,"MLIR01","PEIR01","SNIR02","UGIR01","ZWIR01")) & v020_dec == ""
	note: in all these cases, v020_str == "" , but information on DHS website of each survey says all women sample
	assert v020_dec == "all woman sample"
	rename v020_dec ems
	la var ems "Sample of women"
	drop v020*
	
***** adjust variable for age
	rename v012 age
	la var age "Age"
	
***** adjust variable for sample weight
	gen sw = v005 / 1000000 , after(v005)
	la var sw "v005/1000000"
	drop v005*
	
***** gen country variable
	gen country = ""
	replace country = "Afghanistan" if cc == "AF"
	replace country = "Albania" if cc == "AL"
	replace country = "Angola" if cc == "AO"
	replace country = "Armenia" if cc == "AM"
	replace country = "Azerbaijan" if cc == "AZ"
	replace country = "Bangladesh" if cc == "BD"
	replace country = "Benin" if cc == "BJ"
	replace country = "Bolivia" if cc == "BO"
	replace country = "Botswana" if cc == "BT"
	replace country = "Brazil" if cc == "BR"
	replace country = "Burkina Faso" if cc == "BF"
	replace country = "Burundi" if cc == "BU"
	replace country = "Cambodia" if cc == "KH"
	replace country = "Cameroon" if cc == "CM"
	replace country = "Cape Verde" if cc == "CV"
	replace country = "Central African Republic" if cc == "CF"
	replace country = "Chad" if cc == "TD"
	replace country = "Colombia" if cc == "CO"
	replace country = "Comoros" if cc == "KM"
	replace country = "Congo" if cc == "CG"
	replace country = "DRC" if cc == "CD"
	replace country = "Cote d'Ivoire" if cc == "CI"
	replace country = "Dominican Republic" if cc == "DR"
	replace country = "Ecuador" if cc == "EC"
	replace country = "Egypt" if cc == "EG"
	replace country = "El Salvador" if cc == "ES"
	replace country = "Equatorial Guinea" if cc == "EK"
	replace country = "Eritrea" if cc == "ER"
	replace country = "Ethiopia" if cc == "ET"
	replace country = "Gabon" if cc == "GA"
	replace country = "Gambia" if cc == "GM"
	replace country = "Ghana" if cc == "GH"
	replace country = "Guatemala" if cc == "GU"
	replace country = "Guinea" if cc == "GN"
	replace country = "Guyana" if cc == "GY"
	replace country = "Haiti" if cc == "HT"
	replace country = "Honduras" if cc == "HN"
	replace country = "India" if cc == "IA"
	replace country = "Indonesia" if cc == "ID"
	replace country = "Jordan" if cc == "JO"
	replace country = "Kazakhstan" if cc == "KK"
	replace country = "Kenya" if cc == "KE"
	replace country = "Kyrgyz Republic" if cc == "KY"
	replace country = "Lao People's Democratic Republic" if cc == "LA"
	replace country = "Lesotho" if cc == "LS"
	replace country = "Liberia" if cc == "LB"
	replace country = "Madagascar" if cc == "MD"
	replace country = "Malawi" if cc == "MW"
	replace country = "Maldives" if cc == "MV"
	replace country = "Mali" if cc == "ML"
	replace country = "Mauritania" if cc == "MR"
	replace country = "Mexico" if cc == "MX"
	replace country = "Moldova" if cc == "MB"
	replace country = "Morocco" if cc == "MA"
	replace country = "Mozambique" if cc == "MZ"
	replace country = "Myanmar" if cc == "MM"
	replace country = "Namibia" if cc == "NM"
	replace country = "Nepal" if cc == "NP"
	replace country = "Nicaragua" if cc == "NC"
	replace country = "Niger" if cc == "NI"
	replace country = "Nigeria" if cc == "NG"
	replace country = "Nigeria (Ondo State)" if cc == "OS"
	replace country = "Pakistan" if cc == "PK"
	replace country = "Paraguay" if cc == "PY"
	replace country = "Peru" if cc == "PE"
	replace country = "Philippines" if cc == "PH"
	replace country = "Rwanda" if cc == "RW"
	replace country = "Samoa" if cc == "WS"
	replace country = "Sao Tome and Principe" if cc == "ST"
	replace country = "Senegal" if cc == "SN"
	replace country = "Sierra Leone" if cc == "SL"
	replace country = "South Africa" if cc == "ZA"
	replace country = "Sri Lanka" if cc == "LK"
	replace country = "Sudan" if cc == "SD"
	replace country = "Swaziland" if cc == "SZ"
	replace country = "Tajikistan" if cc == "TJ"
	replace country = "Tanzania" if cc == "TZ"
	replace country = "Thailand" if cc == "TH"
	replace country = "Timor-Leste" if cc == "TL"
	replace country = "Togo" if cc == "TG"
	replace country = "Trinidad and Tobago" if cc == "TT"
	replace country = "Tunisia" if cc == "TN"
	replace country = "Turkey" if cc == "TR"
	replace country = "Turkmenistan" if cc == "TM"
	replace country = "Uganda" if cc == "UG"
	replace country = "Ukraine" if cc == "UA"
	replace country = "Uzbekistan" if cc == "UZ"
	replace country = "Vietnam" if cc == "VN"
	replace country = "Yemen" if cc == "YE"
	replace country = "Zambia" if cc == "ZM"
	replace country = "Zimbabwe" if cc == "ZW"
	
	encode country , gen(country_e)
	la var country_e "Country (numeric)"
	
***** gen country code + survey year identifier

	gen ccsy = cc + " " + string(sy)
	la var ccsy "Country code, survey year"
	
***** encode country, country code variables
	
	encode cc , gen(cc_e)
	la var cc_e "Country code (numeric)"
	
	encode ccsy , gen(ccsy_e)
	la var ccsy_e "Country code, survey year (numeric)"
	
********************************************************************************
* Additional variables
********************************************************************************

***** 140 - religion

	gen religion = ""
	replace religion = "no religion" if inlist(v130_dec,"no religion","no religion + other","no religion/none","none","not religion")
	replace religion = "buddhist" if inlist(v130_dec,"buddhist","buddhist/neo-buddhist")
	replace religion = "catholic" if inlist(v130_dec,"catholic","catholicism","catholique","roman catholic")
	replace religion = "muslim" if ///
		inlist(v130_dec,"islam","islamic","moslem","mulsim","muslem","muslim","muslim - alawi","muslim - sunni") | ///
		inlist(v130_dec,"muslin","muslman","other muslim")
	replace religion = "sikh" if inlist(v130_dec,"sikh")
	replace religion = "hindu" if inlist(v130_dec,"hindu")
	replace religion = "don't know" if inlist(v130_dec,"don't know","answered dk")
	replace religion = "jain" if v130_dec == "jain"
	replace religion = "jewish" if v130_dec == "jewish"
		replace religion = "traditional/spiritual" if regexm(v130_dec,"traditional") == 1 | ///
		inlist(v130_dec,"religion traditionelle","vaudou","vaudousant","vodoun","taditional","traditionnal/animist") | ///
		inlist(v130_dec,"indigenous spirituality","donyi polo","animist","animiste","nature worship") | ///
		inlist(v130_dec,"spiritual","spiritualist")
	replace religion = "other" if inlist(v130_dec,"mammon","kirat","mayan","new religions (eglises rebeillees)","other","autre","aucune") | ///
		inlist(v130_dec,"other religion","other religions","others","parsi/zoroastrian","salvation army","sect","baha'i") | ///
		inlist(v130_dec,"budu")
	replace religion = "christian" if religion == "" & v130_dec != "" // 505,522
	drop v130*
	
***** 149 - education attained

	replace v149 = .d if v149 == 8
	replace v149 = .  if v149 == 9
	label define eduatt 0 "no education" 1 "incomplete primary" 2 "complete primary" 3 "incomplete secondary" 4 "complete secondary" 5 "higher" .d "don't know"
	rename v149 eduatt
	la var eduatt "Education attained"
	drop v149*
	
***** 133 - single years of education

	recode v133 (95 96 97 98 99 = . )
	la var v133 "Education (single years)"
	rename v133 edusy
	drop v133*
	
***** 190 - poorest or poorer

	gen poor = v190
	recode poor (1 2 = 1) (3 4 5 = 0)
	la var poor "Poor"
	note poor : Poorest or poorer wealth quintile
	drop v190*
	
***** 212 - age at first birth
	
	rename v212 aafb
	drop v212*
	
***** NEW: # of years between age at first birth and age now

	gen agegap = aafb - age
	la var agegap "Number of years between age at first birth & current age"
	
***** 201 - total number of kids born

	rename v201 tkb
	
***** 302 - ever use of FP

	recode v302 (1 2 3 = 1)
	la var v302 "Ever used FP"
	rename v302 eu
	drop v302*
	
***** NEW: HAVE NO KIDS & HAVE USED FP BEFORE

	gen ua0 = 0
	replace ua0 = . if eu == . | tkb == .
	replace ua0 = 1 if eu == 1 & tkb == 0
	la var ua0 "Ever used FP & have no kids"
	
***** 310 - number of living kids at first use

	recode v310 (97 98 99 = .)
	rename v310 lkfu
	drop v310*

***** NEW: USED FP BEFORE FIRST LIVING KID / USED AFTER FIRST LIVING KID | NEVER USED
	
	gen ub1 = .
	replace ub1 = 0  if eu == 0
	replace ub1 = 0  if inrange(lkfu,1,50)
	recode ub1 (.=1) if lkfu == 0
	la var ub1 "Used FP before 1st living kid"
	note ub1 : 0 = used FP after 1st living kid or never used
	
***** 312 - using FP
/*
	replace v312 = . if v312 == 98
	replace v312 = 1 if inrange(v312,1,22)
	rename v312 ufp
	la var ufp "Using FP"
	drop v312*
*/
***** v384a v384b v384c - medium through which heard of FP

	replace v384a = . if v384a == 9
	replace v384b = . if v384b == 9
	replace v384c = . if v384c == 9
	egen hfp_any = rowtotal(v384a v384b v384c) if v384a != . & v384b != . & v384c != .
	renvars v384a v384b v384c \ hfp_radio hfp_tv hfp_newsmag
	la var hfp_tv 		"Heard of FP via TV"
	la var hfp_radio	"Heard of FP via radio"
	la var hfp_newsmag	"Heard of FP via newspaper or magazine"
	la var hfp_any		"Number of media sources (1-3) heard of FP through"
	drop v384*

***** 466 - can seek medical treatment for child
/*
	gen dtx = 0 if !inlist(v466_dec,"","child never ill","no children under 18")
	replace dtx = 1 if inlist(v466_dec,"yes","yes, both")
	la var dtx "Can decide to seek medical treatment for seriously ill child"
	drop v466*
*/
***** 467b - getting permission

	* 3 options: a big problem VS. a small problem VS. no problem *** 6 surveys
	* 3 options: a big problem VS. not a big problem VS. no problem *** 3 surveys
	* 2 options: a big problem VS. a small problem *** 8 surveys
	* 2 options: a big problem VS. not a big problem *** 52 surveys
	* 2 options: a big problem VS. no problem *** 11 surveys
	* 1 option: no problem *** DRIR4A only

	gen txp = 0 if !inlist(v467b_dec,"")
	recode txp (0=0) if inlist(v467b_dec,"no problem")
	recode txp (0=0) if inlist(v467b_dec,"not a big problem","a small problem","small problem")
	recode txp (0=1) if inlist(v467b_dec,"a big problem","big problem")
	replace txp = . if inlist(file_ir,"DRIR4A")
	la var txp "Getting permission a big problem for medical care"
	note txp : 0 = no problem, not a big problem, a small problem
	drop v467b*
	
***** 467d - distance to health facility
	
	gen txd = 0 if !inlist(v467d_dec,"")
	recode txd (0=0) if inlist(v467d_dec,"no problem")
	recode txd (0=0) if inlist(v467d_dec,"not a big problem","a small problem","small problem")
	recode txd (0=1) if inlist(v467d_dec,"a big problem","big problem")
	replace txd = . if inlist(file_ir,"DRIR4A")
	la var txd "Distance a big problem for medical care"
	note txd : 0 = no problem, not a big problem, a small problem
	drop v467d*

***** 502 - marital status

	replace v502 = 0 if v502 == 9
	label define partner 0 "Never in union" 1 "Currently in union/living together" 2 "Formerly in union/living together"
	label values v502 partner
	rename v502 partner
	drop v502*

***** 604 - preferred waiting time

	label define pwt 0 "<12 months" 1 "1 year" 2 "2 years" 3 "3 years" 4 "4 years" 5 "5 years" 6 "6+ years" .o "Other"
	replace v604 = .o if inlist(v604,7,8)
	replace v604 = .  if inlist(v604,9)
	label values v604 pwt
	rename v604 pwt
	la var pwt "Preferred waiting time (within 0,1,2,3,4,5,6+ years)"
	drop v604* v602*

***** 610 - approves of FP
/*
	gen ah = 0 if v610_dec != ""
	replace ah = 1 if v610_dec == "approves"
	la var ah "Thinks her partner approves of couples using FP"
	drop v610*

***** 612 - thinks her husband approves of FP

	gen ar = 0 if v612_dec != ""
	replace ar = 1 if v612_dec == "approves"
	la var ar "Approves of couples using FP"
	drop v612*

***** NEW: WOMEN APPROVE AND THINK HUSBAND APPROVES

	gen arh = 0 if ah != . & ar != .
	replace arh = 1 if ah == 1 & ar == 1
	la var arh "Approves & thinks her partner approves of couples using FP"

***** 613
*/
	gen ink = v613
	replace ink = . if inrange(v613,95,99) 
	replace ink = .o if v613_dec != ""
	drop v613*
	
***** 614

	label define inkgrp 6 "6+ kids" .o "non-numeric response"
	label values v614 inkgrp
	replace v614 = .o if v614 == 7
	rename v614 inkgrp
	drop v614*
	la var inkgrp "Ideal number of kids (0-6+)"
	
***** 627 628 629
	
	gen inb = v627
	replace inb = . if inlist(v627,99)
	replace inb = .o if v627_dec != ""
	la var inb "Ideal number of boys"
	
	gen sp = inb/ink
	replace sp = .o if sp > 1 & sp != . // ideal number of boys > ideal number of kids
	replace sp = 0 if sp >= 0 & sp <= .5 // 0 if ideal number of boys is 0 and .5 if boys:girl|any is equal
	replace sp = 1 if sp > .5 & sp <= 1 // 1 if ideal number of boys == ideal number of kids
	la var sp "Ideal # of boys is more than half of the ideal # of kids"
/*	
***** 743d - final say on visits

	tab v743d_dec, m
	gen fsvr_a  = 0 if v743d_dec != ""
	replace fsvr_a = . if regexm(v743d_dec,"decision not") == 1
	replace fsvr_a = . if inlist(v743d_dec,"not applicable","other (includes: decision not taken, not applicable)")
	replace fsvr_a = 1 if ///
		inlist(v743d_dec,"respondent & husband/partner jointly","respondent & someone else jointly") | ///
		inlist(v743d_dec,"respondent alone","respondent and husband","respondent and husband/partner","respondent and other person")

	la var fsvr_a  "Has any final say on visits to relatives"
	
	drop v743*
*/
***** 744* - wife beating

	replace v744a = . if v744a == 9 // blank string
	replace v744b = . if v744b == 9
	replace v744c = . if v744c == 9
	replace v744d = . if v744d == 9
	replace v744e = . if v744e == 9

	renvars v744a v744b v744c v744d v744e / wbj_lwt wbj_ntc wbj_awh wbj_rhs wbj_btf
	
	egen ea108  = anymatch(wbj*), v(1 0 8) // ever answered yes no or don't know (result is binary)
	egen   ea1  = anymatch(wbj*), v(1)     // ever answered yes (result is binary)
	
	gen wbj_any = 0 if ea108 == 1
	replace wbj_any = 1 if wbj_any == 0 & ea1 == 1
	
	note wbj_any : denominator is respondents who answered any of the WBJ questions
	la var wbj_any "Cites any reason as justifying wife-beating"
	
	drop ea1* wbj_lwt wbj_ntc wbj_awh wbj_rhs wbj_btf v744*

***** 822 - ask husband to use condom if he has an STI
/*	
	replace v822 = .d if inlist(v822,3,8)
	replace v822 = .m if inlist(v822,9)
	la var v822 "Wife justified to ask husband with STI to use condom"
	rename v822 afcj
	drop v822*
*/
********************************************************************************
* Variables by region and cluster
********************************************************************************

***** region

	gen region = ""
	replace region = "East Asia and Pacific" if inlist(country,"Cambodia","Indonesia","Philippines")
	replace region = "Europe and Central Asia" if inlist(country,"Turkey")
	replace region = "Latin America & the Caribbean" if inlist(country,"Bolivia","Colombia","Dominican Republic","Guatemala","Haiti","Peru")
	replace region = "South Asia" if inlist(country,"India","Nepal")
	replace region = "Sub-Saharan Africa" if ///
	inlist(country,"Benin","Burkina Faso","Cameroon","Ethiopia","Ghana","Kenya","Madagascar","Malawi") | ///
	inlist(country,"Mali","Namibia","Niger","Nigeria","Rwanda","Senegal","Tanzania","Uganda","Zambia") | ///
	inlist(country,"Zimbabwe")
	assert region != ""

***** SAVE

	order * , alpha
	order file_ir caseid cc* v0* sw iy sy uclust ureg
	compress

	save "$output\DHS output from clean" , replace


global in_FCP "C:\Users\ROROXOM\Center for Global Development\Center For Global Development - NDrive\NB_Reproductive Ecosystem\Finlay Canning and Po\Finlay RH Laws for Dataverse 4.0.dta"

use "$in_FCP" , clear

/*
iud_legal has 2,367 missing data points
pill_prescription has 2,427 missing data points 
pill_sale_purpose has 2,415 missing data points 
sterilization_legal has 6,208 missing data points
*/

keep ctr_name year pill_prescription pill_sale_purpose iud_legal

/*
pill_sale_purpose_lab:
           0 Pill is illegal
           1 Non-contraceptive
           2 Contaceptive

pill_prescription_lab:
           0 Pill is illegal
           1 Prescription Required
           2 Prescritpion not required

iud_legal_lab:
           0 Illegal
           1 Legal
*/

gen ps3 = pill_sale_purpose
label define ps3 0 "Illegal" 1 "Legal for non-contraceptive purposes" 2 "Legal for contraceptive purposes"
label values ps3 ps3

local var ps3
egen `var'_mean = mean(`var') , by(ctr_name)
egen `var'_max  = max(`var')  , by(ctr_name)
egen `var'_min  = min(`var')  , by(ctr_name)

capture drop country_e
encode ctr_name if !inlist(`var'_mean,0,1,2,.) , gen(country_e)
summarize country_e
global ymax = r(max)

twoway ///
(scatter country_e year if `var' == 2 , mcolor(green) msize(*.35)) || ///
(scatter country_e year if `var' == 1 , mcolor(gold) msize(*.35)) || ///
(scatter country_e year if `var' == 0 , mcolor(cranberry) msize(*.35)) ///
, ytitle("") xtitle("") legend(size(*.5) row(1)) ///
ylab(1(1) $ymax , valuelabel angle(0) labsize(*.35)) ///
graphregion(color(white))

drop country_e
label drop country_e
encode ctr_name if ///
inlist(ctr_name,"Cambodia","Colombia","Ethiopia","Ghana","Guatemala","Haiti","India","Indonesia") | ///
inlist(ctr_name,"Kenya","Malawi","Namibia","Nepal","Nigeria","Peru","Tanzania","Turkey") | ///
inlist(ctr_name,"Uganda","Zambia","Zimbabwe") , gen(country_e)
summarize country_e
global ymax = r(max)
global ymin = r(min)

local var ps3
twoway ///
(scatter country_e year if `var' == 2 , mcolor(green) msize(*.35)) || ///
(scatter country_e year if `var' == 1 , mcolor(gold) msize(*.35)) || ///
(scatter country_e year if `var' == 0 , mcolor(cranberry) msize(*.35)) ///
, ytitle("") xtitle("") legend(size(*.5) row(1)) ///
ylab($ymin(1) $ymax , valuelabel angle(0) labsize(*.35)) ///
graphregion(color(white))

drop country_e
label drop country_e
encode ctr_name if ///
inlist(ctr_name,"Benin","Bolivia","Burkina Faso","Cambodia","Cameroon","Colombia","Dominican Republic","Ethiopia") | ///
inlist(ctr_name,"Ghana","Guatemala","Haiti","India","Indonesia","Kenya","Madagascar","Malawi") | ///
inlist(ctr_name,"Mali","Namibia","Nepal","Niger","Nigeria","Peru","Philippines","Rwanda") | ///
inlist(ctr_name,"Senegal","Tanzania","Turkey","Uganda","Zambia","Zimbabwe") ///
, gen(country_e)

summarize country_e
global ymax = r(max)
global ymin = r(min)

local var ps3
twoway ///
(scatter country_e year if `var' == 2 , mcolor(green) msize(*.35)) || ///
(scatter country_e year if `var' == 1 , mcolor(gold) msize(*.35)) || ///
(scatter country_e year if `var' == 0 , mcolor(cranberry) msize(*.35)) ///
, xtitle("") ytitle("") ylab($ymin(1) $ymax , valuelabel angle(0) labsize(*.35)) ///
legend(size(*.5) row(1) label(1 "Legal for contraceptive purposes") label(2 "Legal for therapeutic purposes") label(3 "Illegal")) ///
graphregion(color(white)) title("Legality of Pill Sale by Purpose")

graph export "FCP legality for pill.pdf" , replace

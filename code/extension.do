********************************************************************************
* TITLE: extension.do
* AUTHOR: Zoë Arnaut
* DATE CREATED: 10/21/2024
********************************************************************************
clear all
set more off
set matsize 800
eststo clear
clear matrix

cd "/Users/zoearnaut-hull/EC 280/extension/"

* Load data
use ./raw/agg_data.dta, clear
sort time
gen counter = _n
tsset counter
keep if year >= 1979
keep if year <= 2017

// Fix format for the figures.
label var spf_cpi_lt "SPF CPI LT Inflation Expectations"
label var time "Time"
label var date "Time"

* Set kappa. Comes from Table 4.
global kappa3 0.0055 // Tradeable Demand IV estimate, pos 1990

// fix these figure.s
global kappa_rent 0.0243 // rent estimate, new sample

* Set value of beta
global beta 0.99
global truncate_length 20

* Create truncated present value of u rate
quietly generate u_sum_urate_cyc = urate_cyc
forvalues ii = 1/$truncate_length {
	quietly replace u_sum_urate_cyc = u_sum_urate_cyc + $beta^`ii'*F`ii'.urate_cyc
}

* Estimate scaling factor 
regress u_sum_urate_cyc urate_cyc, r
scalar zeta_urate_cyc = _b[urate_cyc]
set graphics on
constraint 1 lag_urate = - ${kappa3} * 4 * zeta_urate_cyc 
constraint 2 lag_urate = - (0.5839*${kappa3} * 4 * zeta_urate_cyc + (1-0.5839)*${kappa_rent} * 4 * zeta_urate_cyc) // 
cnsreg lhs_cpi_rs_core_lt  lag_urate, constraints(2)
predict cpi_rs_core_hat, xb
keep date cpi_rs_core_hat spf_cpi_lt
rename date yq

* Import cyclical/acyclical infation
preserve
	import excel using "./raw/cyclical-acyclical-core-pce-data.xlsx", firstrow sheet("Data") clear
	keep CyclicalcorePCEinflationyy AcyclicalcorePCEinflationy time_month
	rename CyclicalcorePCEinflationyy cyclical
	rename AcyclicalcorePCEinflationy acyclical
	gen year = substr(time_month,1,5)
	replace year = subinstr(year,"m","",.)
	destring year, replace
	gen month = substr(time_month,-2,2)
	replace month = subinstr(month,"m","",.)
	destring month, replace
	gen qtr = 1 if inrange(month,1,3)
	replace qtr = 2 if inrange(month,4,6)
	replace qtr = 3 if inrange(month,7,9)
	replace qtr = 4 if inrange(month,10,12)
	collapse (mean) cyclical acyclical, by(year qtr)
	gen yq = yq(year,qtr)
	format %tq yq
	keep yq cyclical acyclical
	order yq
	tempfile cyclicalSave
	save `cyclicalSave'
restore

* Merge datasets
merge 1:1 yq using `cyclicalSave', keep(3) nogen

* Subtract inflation expectations
gen cyclical_exp = cyclical - spf_cpi_lt
gen acyclical_exp = acyclical - spf_cpi_lt

* Graphs
graph tw (line cpi_rs_core_hat yq, lcolor("black") lwidth(0.75)) ///
		 (line cyclical_exp yq, lcolor("gs8") lwidth(0.65)), ///
		 xtitle("") ytitle("") ///
		 xlab(, format(%tqCCYY) nogrid) ylab(-3(1)2.5, nogrid) ///
		 plotregion(lcolor("black")) ///
		 note("FIGURE VI (a): Aggregate Phillips Curve and Cyclical Inflation") ///
		 legend(order(2 "Cyclical inflation less long-term inflation expectations" ///
		 1 "Phillips Curve Fit") pos(11) ring(0))
graph export "./graphs/figure6_cyc.png", replace 

graph tw (line cpi_rs_core_hat yq, lcolor("black") lwidth(0.75)) ///
		 (line acyclical_exp yq, lcolor("gs8") lwidth(0.65)), ///
		 xtitle("") ytitle("") ///
		 xlab(, format(%tqCCYY) nogrid) ylab(-3(1)2.5, nogrid) ///
		 plotregion(lcolor("black")) ///
		 note("FIGURE VI (b): Aggregate Phillips Curve and Acyclical Inflation") ///
		 legend(order(2 "Acyclical inflation less long-term inflation expectations" ///
		 1 "Phillips Curve Fit") pos(11) ring(0))
graph export "./graphs/figure6_acyc.png", replace 

************************************ FIN ***************************************

*******************************************************************************
** various levels of geographic or temporal aggregation. Set your path and it
** should run fine.
**


label var unconditional "Projects other than CERP-like programs"
gen irrf = (Program=="IRRF" | Program=="IRRF1")
compress
use maaws_using.dta, clear

* Generate duration within units
gen finishdate = Actual_Start + duration - 1
local unit "District"
local time "h"
foreach z of local time {
	foreach i of local unit {
		
		* First need to expand to the number of t units
		gen dur_`z' = `z'ofd(finishdate) - `z'ofd(Actual_Start) + 1
		expand dur_`z'
		bysort uri: gen timeunit = `z'ofd(Actual_Start) + _n - 1
		gen numdays = enddate - startdate + 1

		* Generate spending variables
		foreach x of varlist soi cerp-irrf_noncerp {
		* Now generate variable to count projects
		foreach x of varlist soi cerp-irrf_noncerp {
			replace `x' = `x'*tag_p
		
		* Prep for collapse
		compress
		gen year = year(dof`z'(timeunit))
		gen `z' = timeunit
		drop if year<2003 | year > 2009
		save "maws_precollapse_`i'_`z'.dta", replace
		ren tag_p np
		fillin `i' `z'
		qui foreach k of varlist spent* np* {
			replace `k' = 0 if _fillin==1
			}
			
		* Add in time variables
		if "`z'" == "y" {
			gen year = `z'
			}
		else if "`z'" == "h" {
			gen half = `z'
			gen year = yofd(dofh(`z'))
			}
		else if "`z'" == "q" {
			gen quarter = `z'
			gen half = hofd(dofq(`z'))
			gen year = yofd(dofq(`z'))
			}
		else if "`z'" == "m" {
			gen month = `z'
			gen quarter = qofd(dofm(`z'))
			gen half = hofd(dofm(`z'))
			gen year = yofd(dofm(`z'))
			}
		else if "`z'" == "w" {
			gen week = `z'
			gen month = mofd(dofw(`z'))
			gen quarter = qofd(dofw(`z'))
			gen half = hofd(dofw(`z'))
			gen year = yofd(dofw(`z'))
			}
		else {
			display "whoops!"
			}

		* Save the data
		compress
		label data "Spending by `i' `z'"
	}
}

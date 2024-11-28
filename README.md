**************************************************************************************
README: ECON 280 Replication Project

AUTHOR: zarnaut

DATE CREATED: 10/15/2024
**************************************************************************************

This repo contains the data, code, and output of an extension to the "The slope of the Phillips curve: Evidence from U.S. states" paper by Hazell et al. (_QJE_, 2022). The extension creates alternate versions of Figure VI, comparing the authors’ Phillips curve fit to various measures of inflation. For a descriptione of the extension, see Extension.pdf.

DATA
Phillips Curve Fit 
- (agg_data.dta)
- Jonathon Hazell, Juan Herreño, Emi Nakamura, and Jón Steinsson
- Publicly available from Oxford Academic.

Cyclical and Acyclical Core Inflation
- (cyclical-acyclical-core-pce-data.xlsx)
- Tim Mahedy and Adam Shapiro
- Publicly available from FRBSF Data & Indicators.

SOFTWARE
Stata 18
- No required packages needed
- 5-second runtime

SCRIPTS
extension.do 
Change path in line 12
- Imports, cleans, and merges the two datasets from /raw/
- Calculates the Phillips curve fit using results from Table 4
- Subtracts long-term inflation expectations from cyclical and acyclical rates
- Creates Figures VI (a) and (b)

GRAPHS
Figure VI (a) Aggregate Phillips Curve and Cyclical Inflation
(figure6_cyc.png)
Created in lines 87-94 of extension.do

Figures VI (b) Aggregate Phillips Curve and Acyclical Inflation
(figure6_acyc.png)
Created in lines 97-104 of extension.do

REFERENCES
Hazell, J., J. Herreño, E. Nakamura, and J. Steinsson. "The slope of the Phillips curve: Evidence from U.S. states." _The Quarterly Journal of Economics_ Vol. 137, Issue 3, August 2022, Pgs 1299–1344. Retrieved from [here](https://doi.org/10.1093/qje/qjac010).

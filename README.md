# blackmaRble
blackmaRble: retrieve, wrangle and plot VIIRS Black Marble nighttimelight data in R

Usage:

library(blackmaRble)
bm_initialize("username", "password")
bm_get_data( "2019-09-15", '2019-09-16', 'days', 'VNP46A2', "Gap_Filled_DNB_BRDF_Corrected_NTL")



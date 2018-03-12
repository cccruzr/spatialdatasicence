#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      cccru
#
# Created:     06/02/2018
# Copyright:   (c) cccru 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import arcpy
from arcpy import env

env.workspace = "C:/EsriPress/Python/Data/Exercise07"

in_fc = "airports.shp"
out_fc = "Results/airports_anchorage.shp"

delimitedField = arcpy.AddFieldDelimiters(in_fc, "COUNTY")

arcpy.Select_analysis(in_fc, out_fc, delimitedField + "= 'Anchorage Borough'")

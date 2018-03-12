#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      cccru
#
# Created:     06/02/2018
# Copyright:   (c) cccru 2018
# Licence:     MIT
#-------------------------------------------------------------------------------

# Challenge 1:
## Write a script that creates a 15,000-meter buffer around features in the
## airports.shp feature class classified as an airport ( based on the FEATURE
## field ) and a 7,500-meter buffer around features classified as a seaplane
## base. The results should be two separate feature classes, one for each
## airport type.

import arcpy
from arcpy import env

env.workspace = "C:/EsriPress/Python/Data/Exercise07/Results"
env.overwriteOutput = True

in_fc = "airportsCopy.shp"
out_fc1 = "airports_airports.shp"
out_fc2 = "airports_seaplane.shp"
out_fc1_buffer = "airports_airports_buffer.shp"
out_fc2_buffer = "airports_seaplane_buffer.shp"

delimitedField = arcpy.AddFieldDelimiters(in_fc, "FEATURE")

# Make layers from the feature class
arcpy.MakeFeatureLayer_management(in_fc, out_fc1, delimitedField + "= 'Airport'")
arcpy.MakeFeatureLayer_management(in_fc, out_fc2, delimitedField + "= 'Seaplane Base'")

# Make buffers according FEATURE
arcpy.Buffer_analysis(out_fc1, out_fc1_buffer, "15000 METERS")
arcpy.Buffer_analysis(out_fc2, out_fc2_buffer, "7500 METERS")
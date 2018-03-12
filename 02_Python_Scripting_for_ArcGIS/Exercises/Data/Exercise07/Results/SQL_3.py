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

fc = "airports.shp"
delimitedField = arcpy.AddFieldDelimiters(fc, "COUNTY")
arcpy.Selec
cursor = arcpy.da.SearchCursor(fc, ["NAME"], delimitedField + "= 'Anchorage Borough'")

for row in cursor:
    print row[0]

del row
del cursor

arcpy.MakeFeatureLayer_management
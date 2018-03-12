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
cursor = arcpy.da.SearchCursor(fc, ["NAME"])

for row in cursor:
    print("Airport name = {0}".format(row[0]))

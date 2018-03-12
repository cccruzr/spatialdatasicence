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

fc = "Results/airports.shp"
delimField = arcpy.AddFieldDelimiters(fc, "STATE")

cursor = arcpy.da.UpdateCursor(fc, ["STATE"], delimField + "<> 'AK'")

for row in cursor:
    row[0] = "AK"
    cursor.updateRow(row)

del row
del cursor
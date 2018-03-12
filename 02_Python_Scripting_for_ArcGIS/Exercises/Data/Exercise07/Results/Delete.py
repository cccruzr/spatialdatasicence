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
cursor = arcpy.da.UpdateCursor(fc, ["TOT_ENP"])

for row in cursor:
    if row[0] < 100000:
        cursor.deleteRow()
del row
del cursor
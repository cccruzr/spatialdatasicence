#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      cccru
#
# Created:     22/01/2018
# Copyright:   (c) cccru 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import arcpy

arcpy.env.workspace = "C:/EsriPress/Python/Data/Exercise06/"
arcpy.env.overwriteOutput = True

field_list = arcpy.ListFields("cities.shp")
for field in field_list :
    print(field.name + " | " + field.type)
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
from arcpy import env

env.workspace = "C:\EsriPress\Python\Data\Exercise06"

shape_exists = arcpy.Exists("cities.shp")
print shape_exists
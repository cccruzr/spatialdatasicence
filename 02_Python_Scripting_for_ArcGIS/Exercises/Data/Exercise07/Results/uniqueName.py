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

uniqueName = arcpy.CreateUniqueName("Results/buffer.shp")
arcpy.Buffer_analysis(fc, uniqueName, "5000 METERS")
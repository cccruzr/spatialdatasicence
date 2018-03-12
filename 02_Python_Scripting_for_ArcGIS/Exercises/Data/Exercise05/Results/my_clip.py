#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      cccru
#
# Created:     18/01/2018
# Copyright:   (c) cccru 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import arcpy
from arcpy import env

#Setting environment
env.workspace = "C:\EsriPress\Python\Data\Exercise05"
env.overwriteOutput = True

new_clip = arcpy.analysis.Clip("bike_routes.shp", "parks.shp", "Results\\bike_Clip.shp")
fCount = arcpy.management.GetCount(new_clip)

msgCount = arcpy.GetMessageCount()
print arcpy.GetMessage(msgCount - 1)

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
env.workspace = r"C:\EsriPress\Python\Data\Exercise05"

#Check for Spatial extension
if arcpy.CheckExtension("spatial") == "Available":
    arcpy.CheckOutExtension("spatial")
    out_dist = arcpy.sa.EucDistance("bike_routes.shp", cell_size=100)
    out_dist.save(r"C:\EsriPress\Python\Data\Exercise05\Results\bike_dist")
    arcpy.CheckInExtension("spatial")
    print arcpy.GetMessages()
else:
    print "Spatial Analyst license is not available."

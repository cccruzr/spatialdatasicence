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

in_fc = "parks.shp"
out_fc = "Results/parks_centroid.shp"


if arcpy.ProductInfo() == "ArcInfo":
    arcpy.management.FeatureToPoint(in_fc, out_fc)
else:
    print("An ArcInfo license (ArGIS Desktop Advanced) is not Available.")

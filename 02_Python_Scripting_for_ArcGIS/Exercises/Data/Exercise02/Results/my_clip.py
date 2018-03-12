#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      cccru
#
# Created:     10/01/2018
# Copyright:   (c) cccru 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import arcpy

arcpy.env.workspace = "C:\EsriPress\Python\Data\Exercise02"
arcpy.Clip_analysis("lakes.shp", "basin.shp", "results/lakes_myClip.shp")


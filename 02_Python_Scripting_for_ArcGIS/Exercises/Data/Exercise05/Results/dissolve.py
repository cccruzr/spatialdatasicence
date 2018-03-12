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

# Import system modules
import arcpy
from arcpy import env

#Setting workspace
env.workspace = r"C:\EsriPress\Python\Data\Exercise05"
env.overwriteOutput = True

# Set local variables
inFeatures = "parks.shp"
tempLayer = "Results/scratch/parks_dis_temp.shp"
#expression = arcpy.AddFieldDelimiters(inFeatures, "LANDUSE") + " <> ''"
outFeatureClass = "Results/parks_dissolved.shp"
dissolveFields = ["PARK_TYPE"]

# Execute MakeFeatureLayer and SelectLayerByAttribute.  This is only to exclude
# features that are not desired in the output.
##arcpy.MakeFeatureLayer_management(inFeatures, tempLayer)
##arcpy.SelectLayerByAttribute_management(tempLayer, "NEW_SELECTION", expression)

# Execute Dissolve using LANDUSE and TAXCODE as Dissolve Fields
arcpy.Dissolve_management(inFeatures, outFeatureClass, dissolveFields, "", "SINGLE_PART")
print arcpy.GetMessages()
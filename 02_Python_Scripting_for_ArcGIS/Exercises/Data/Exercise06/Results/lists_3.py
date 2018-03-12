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

env.workspace = "C:/EsriPress/Python/Data/Exercise06/"
env.overwriteOutput = True

fc_list = arcpy.ListFeatureClasses()
for fc in fc_list:
    arcpy.CopyFeatures_management(fc, "C:/EsriPress/Python/Data/Exercise06/Results/" + fc)
    print(arcpy.GetMessages())
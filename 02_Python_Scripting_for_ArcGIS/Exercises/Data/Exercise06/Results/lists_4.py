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

arcpy.CreateFileGDB_management("C:/EsriPress/Python/Data/Exercise06/Results/", "NM.gdb")

fc_list = arcpy.ListFeatureClasses()
for fc in fc_list:
    fc_desc = arcpy.Describe(fc)
    arcpy.CopyFeatures_management(fc, "C:/EsriPress/Python/Data/Exercise06/Results/NM.gdb/" + fc_desc.basename)
    print(arcpy.GetMessages())
    print("\n")
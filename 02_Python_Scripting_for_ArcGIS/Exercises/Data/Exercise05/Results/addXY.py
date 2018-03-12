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

# Set local variables
in_data= "hospitals.shp"
in_features = "hospitals_XY.shp"

# Copying data to preserve original dataset
# Execute Copy
arcpy.Copy_management(in_data, in_features)

# Execute AddXY
arcpy.AddXY_management(in_features)
print arcpy.GetMessages()

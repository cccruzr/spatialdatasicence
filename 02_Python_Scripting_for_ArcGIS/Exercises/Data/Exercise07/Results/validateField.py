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

env.workspace = "C:/EsriPress/Python/Data/Exercise07/Results"

fc = "roads.shp"

# Create and validate new field type
newField = "FERRY"
fieldType = "TEXT"
fieldName = arcpy.ValidateFieldName(newField)

fieldList = arcpy.ListFields(fc)
fieldNames = []

for field in fieldList:
    fieldNames.append(field.name)

if fieldName not in fieldNames:
    arcpy.AddField_management(fc, fieldName, fieldType, "", "", 10)
    print("New field {0} has been added.".format(fieldName))
else:
    print("New field {0} already exists.".format(fieldName))


#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      cccru
#
# Created:     06/02/2018
# Copyright:   (c) cccru 2018
# Licence:     MIT
#-------------------------------------------------------------------------------

# Challenge 2:
## Write a script that adds a text field to the roads.shp feature class called
## FERRY and populates this field with YES and NO values, depending on
## the value of the FEATURE field.

import arcpy
from arcpy import env

env.workspace = "C:/EsriPress/Python/Data/Exercise07/Results"
env.overwriteOutput = True

fc = "roads.shp"

# Create and validate new field type
newField = "FERRY"
fieldType = "TEXT"
fieldName = arcpy.ValidateFieldName(newField)

# Create field list and verify/add if new field exists
fieldList = arcpy.ListFields(fc)
fieldNames = []

for field in fieldList:
    fieldNames.append(field.name)

if fieldName not in fieldNames:
    arcpy.AddField_management(fc, fieldName, fieldType, "", "", 10)
    print("New field {0} has been added.".format(fieldName))
else:
    print("New field {0} already exists.".format(fieldName))

# Create delimiter on FEATURE
delimField = arcpy.AddFieldDelimiters(fc, "FEATURE")

# Create cursor
cursor = arcpy.da.UpdateCursor(fc, ["FEATURE", "FERRY"])

# Update rows based on FEATURE values
for row in cursor:
    if row[0] == "Ferry Crossing":
        row[1] = "YES"
        cursor.updateRow(row)
    else:
        row[1] = "NO"
        cursor.updateRow(row)

# Delete rows and cursor
del row
del cursor
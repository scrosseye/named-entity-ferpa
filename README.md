# named-entity-ferpa
An R script to pull out named entities from educational data to check for personal identifying information.

A script that reads in a series of text files, usually educational data, but it can be any type of data, and outputs all the named
entities per file into a .csv file. Named entities are output by file in row format for quick analysis to ensure that files do not contain
personal identifying information.

Script is used to analysis educational data for identifying information. It relies on named entity recognition, which is about 95% accurate.

Additional analyses of data may be necessary to ensure no personal identifying information is contained in the files.

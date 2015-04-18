#Load libraries
library(ggplot2) # For plotting
library(dplyr)  # for data manipulation
library(taxize) # for comparing names
library(stringr) # for text searches

##read in data
mydata<-read.csv("Data/my.csv",row.names=1)

west<-read.csv("Data/west.csv",row.names=1)

#view the data

head(mydata)
head(west)

#we want full names, lets remove the species that have just sp.
west<-west[!west$species %in% "sp.",]

#to check for mispellings and search for accepted names, create a column with combined genus and species

mydata$Double<-paste(mydata$genus,mydata$species,sep=" ")

west$Double<-paste(west$genus,west$species,sep=" ")

#remove species
#Search the Iplant Taxonomic name resolver for our list
tax<-tnrs(query=mydata$Double,splitby=30,source="iPlant_TNRS",sleep=1)

#Species with name changes
namechange<-tax[!tax$submittedname %in% tax$acceptedname,]
namechange

#looks like some genus changes, some spelling errors

#Search the Iplant Taxonomic name resolver for their list
tax_west<-tnrs(query=west$Double,splitby=30,source="iPlant_TNRS",sleep=1)

#add the Iplant names to each list, we will sort by these 'standardized names'.

#Merge command works by taking like columns and aligning them
#the by.x here says, what are the columns names in the first thing (mydata) and the by.y is the column names of the second thing (tax)
mydatam<-merge(mydata,tax,by.x="Double",by.y="submittedname")

#Do the same for the west list
westm<-merge(west,tax_west,by.x="Double",by.y="submittedname")

##Text matching##
#to directly match in R requires exact strings. Let's start by the hard way.

#Which levels are in my data and match the list
mat<-mydatam[mydatam$acceptedname %in% westm$acceptedname,]
#how many matches
nrow(mat)

#uncomment if you want to write to file belw
#write.csv(mat,"match.csv")

#Which names are not in the list
nomat<-mydatam[!mydatam$acceptedname %in% westm$acceptedname,]
nrow(nomat)

#uncomment if you want to write to file belw
#write.csv(nomat,"Nomatch.csv")

#Which names do not appear in out list
missing<-westm[!westm$acceptedname %in% mydatam$acceptname,]

paste("We are missing",nrow(missing),"species")
write.csv(missing,"missing.csv")




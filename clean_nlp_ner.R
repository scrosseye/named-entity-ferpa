#R script to read in educational data from dataframe and pull out named entities for visual examination.

rm(list=ls(all=TRUE)) #clear memory

#libraries needed for script
library(cleanNLP)
library(tidyr)
library(dplyr)
library(reshape2)


#read in df from with two required columns, doc_id (with document names) and text (text data)
essays <- read.csv(file = 'essays_only_5.csv')

#examine data
str(essays) #text not character but factor
typeof(essays)
essays$doc_id
essays$text <- as.character(essays$text) #change text to character


#use spacy on date frame. Will need to have cleanNLP package installed and spacy imported using Python
init_spaCy()
anno_essays <- run_annotators(essays) #annotates text for all kinds of things
names(anno_essays)#these are the things
#get_token(anno_essays) #the tokens
#get_dependency(anno_essays, get_token = TRUE) #dependency parses
get_entity(anno_essays) #grabs up entities. Location entities are specialized

#unique entity types 
uniq_ent_type <- get_entity(anno_essays) %>%
  group_by(entity_type)%>%
  summarise(Unique_entity_types = n_distinct(entity_type))


#unique entities (person) for entire corpus
uniq_entities_per <- get_entity(anno_essays) %>%
  group_by(entity)%>%
  filter(entity_type == "PERSON")%>%
  summarise(unique_entities = n_distinct(entity))


#unique entities (location) for entire corpus
uniq_entities_loc <- get_entity(anno_essays) %>%
  group_by(entity)%>%
  filter(entity_type == "LOC")%>%# & entity_type == "PERSON")%>%
  summarise(unique_entities_loc = n_distinct(entity))


#unique entities by text
entities_loc_by_text<-get_entity(anno_essays) %>% 
  group_by(id, entity) %>% 
  filter(entity_type == "LOC")%>%
  summarise(unique_entities = n_distinct(entity))%>% #creates types, but also creates column called unique_entities
  select(-unique_entities) #remove number of unique entries column (all 1s)


entities_per_by_text<-get_entity(anno_essays) %>% 
  group_by(id, entity) %>% 
  filter(entity_type == "PERSON")%>%
  summarise(unique_entities = n_distinct(entity))%>% #creates types, but also creates column called unique_entities
  select(-unique_entities) #remove number of unique entries column (all 1s)

#join two dfs together
all_loc_per_by_text <- full_join(entities_loc_by_text, entities_per_by_text, by = "id")
str(all_loc_per_by_text)

#need to change column names here

all_loc_per_by_text <- all_loc_per_by_text %>% dplyr::rename(Location = entity.x, Person = entity.y)
colnames(all_loc_per_by_text)

#melt loc and person columns into one and remove NAs HAVE TO USE RESHAPE2
stacked_df <- melt(all_loc_per_by_text, id.vars = "id")
stacked_df <- na.omit(stacked_df)#remove NAs
stacked_df

#add in grouping variable
all_loc_per_by_text2 <- stacked_df %>% group_by(id) %>% mutate(group = row_number())
str(all_loc_per_by_text2)

#spread into long format with separate rows for location and people
data_wide <- spread(all_loc_per_by_text2, group, value)
data_wide


#spreading into long format with no distinction between location and people
all_loc_per_by_text3 <- all_loc_per_by_text2 %>% select(-variable) #remove location and people categorical variable
data_wide2 <- spread(all_loc_per_by_text3, group, value) #spread into long again
data_wide2 <- na.omit(data_wide2)#remove NAs
data_wide2 #THIS IS WHAT WE WANT, but it still has NAs.

#write to a csv
write.csv(data_wide2, "NER_by_essay_ferpa_only_5.csv", row.names=FALSE) #writes it to a .csv




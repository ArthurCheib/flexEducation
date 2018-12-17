library(googledrive)
library(dbConnect)
library(RMariaDB)
library(tidyverse)
library(knitr)
library(rstudioapi)

#Conversão da data no R para a data em formato numérico do Excel (contagem em dias):
data_hoje <- Sys.Date()
data_last5 <- (Sys.Date() - 5)

# Conectando com o MySQL:
con <- dbConnect(RMariaDB::MariaDB(),
                 dbname = "db_ngi",
                 host = "10.23.185.10",
                 port = 3306,
                 user = "arthur_cheib",
                 password = rstudioapi::askForPassword("Database password"))

qry_01 <- paste0("SELECT * ", 
                "FROM TBL_MATRICULA ",
                "WHERE data ",
                "BETWEEN ", "'",data_last5, "'", " AND ", "'", data_hoje, "'", ";")

data <- dbSendQuery(con, qry_01)
df_mat_ent <- dbFetch(data)

# RENDERIZATION
rmarkdown::render(input = paste0(getwd(), "/relatorio_regional.Rmd"),
       output_file = "relatorio.html",
       output_dir = getwd())

dbClearResult(data)
dbDisconnect(con)
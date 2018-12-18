library(googledrive)
library(dbConnect)
library(RMariaDB)
library(tidyverse)
library(knitr)
library(rstudioapi)
library(grDevices)
library(colorRamps)

#Conversão da data no R para a data em formato numérico do Excel (contagem em dias):
data_hoje <- Sys.Date()
data_last5 <- (Sys.Date() - 5)
data_padrao_encerramento <- as.Date("2018-12-10")

# Conectando com o MySQL:
con <- dbConnect(RMariaDB::MariaDB(),
                 dbname = "db_ngi",
                 host = "10.23.185.10",
                 port = 3306,
                 user = "arthur_cheib",
                 password = rstudioapi::askForPassword("Database password"))

#### Query para df matrícula e enturmação:
qry_01 <- paste0("SELECT SRE, COD_ESCOLA, ESCOLA, NIVEL, QT_ALUNO_MATRICULADO, QT_ALUNO_ENTURMADO, DATA ", 
                "FROM TBL_MATRICULA ",
                "WHERE data ",
                "BETWEEN ", "'",data_last5, "'", " AND ", "'", data_hoje, "'", ";")

data_mt <- dbSendQuery(con, qry_01)
df_mat_ent <- dbFetch(data_mt)
dbClearResult(data_mt)

#### Query para df criação de turmas:
qry_02 <- paste0("SELECT SRE, COD_ESCOLA, ESCOLA, NIVEL, QT_TURMA_PA, QT_TURMA_CRIADA, QT_TURMA_AUTORIZADA, DATA ", 
                 "FROM TBL_CRIACAO ",
                 "WHERE data ",
                 "BETWEEN ", "'",data_last5, "'", " AND ", "'", data_hoje, "'", ";")

data_cr <- dbSendQuery(con, qry_02)
df_cri_aut <- dbFetch(data_cr)
dbClearResult(data_cr)

#### Query para df encerramento:
qry_03 <- paste0("SELECT SRE, COD_ESCOLA, ESCOLA, NIVEL, ETAPA, QT_ALUNO_ENTURMADO_ATIVO, QT_ALUNO_ENCERRADO, DATA ", 
                 "FROM TBL_ENCERRAMENTO ",
                 "WHERE data = ", "'",data_padrao_encerramento, "'", " OR data ",
                 "BETWEEN ", "'",data_last5, "'", " AND ", "'", data_hoje, "'", ";")

data_enc <- dbSendQuery(con, qry_03)
df_encer <- dbFetch(data_enc)
dbClearResult(data_enc)

# RENDERIZATION
rmarkdown::render(input = paste0(getwd(), "/relatorio_regional.Rmd"),
       output_file = "relatorio.html",
       output_dir = getwd())

dbDisconnect(con)

# Master renderization
regionais <- unique(df_mat_ent$SRE)

for (regional in regionais) {
  
  rmarkdown::render(input = paste0(getwd(), "/relatorio_regional.Rmd"),
                    output_file = str_c("Quadro de Monitoramento - ", regional, ".html"),
                    output_dir = getwd())
  }
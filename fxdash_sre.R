library(googledrive)
library(RODBC)
library(rmarkdown)
library(tidyverse)
library(knitr)
library(readxl)

#Conversao da data no R para a data em formato numérico do Excel (contagem em dias):
data_br_hoje <- format(Sys.Date(), format = "%d-%m-%Y")
data_br_last5 <- format(Sys.Date() - 5, format = "%d-%m-%Y")

# Conectando com o MySQL:
qry_01 <- paste0("SELECT * ", 
                "FROM base ",
                "WHERE data ",
                "BETWEEN ", data_br_last5, " AND ", data_br_hoje, ";")

df_mat_ent <- sqlQuery(ch, qry_01)

df_mat_ent <- df_mat_ent[, -14]

# Alterar o formato da coluna de Data início período e Data término período
df_mat_ent$DATA <- as.Date(df_mat_ent$DATA)

# Alterando nomes das datasets para R format:
real_names <- c("SRE", "COD_MUNICIPIO", "MUNICIPIO", "COD_ESCOLA", "ESCOLA", "ENDERECO", "NIVEL", "ETAPA",
                "TIPO_TURMA", "TURNO", "ALUNOS_MATRICULADOS", "ALUNOS_ENTURMADOS", "DATA")
colnames(df_mat_ent) <- real_names

# RENDERIZATION
rmarkdown::render(input = paste0(getwd(), "/relatorio_regional.Rmd"),
       output_file = "relatorio.html",
       output_dir = getwd())
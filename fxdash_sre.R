library(XLConnect)
library(readxl)
library(RODBC)
library(rmarkdown)
library(tidyverse)
library(knitr)
library(readxl)

#Conversão da data no R para a data em formato numérico do Excel (contagem em dias):

current_day_R_format <- format(Sys.Date(), format = "%Y-%m-%d")

current_day_SRE_format <- format(Sys.Date(), format = "%d-%m-%Y")

conversion <- as.numeric(as.Date(current_day_R_format)-as.Date("1899-12-30"))

responsavel <- c("ALUNOS MATRICULADOS E ENTURMADOS",
                 paste0(current_day_SRE_format, " - 08:00"),
                 "Responsável: Arthur Silva Cheib - Núcleo de Gestão da Informação (Subsecretaria de Informações e Tecnologias Educacionais - SI / SEE)")

# Criando o diretório (pasta) para armazenamento dos arquivos em excel caso ela ainda não exista:

dirSRE <- file.path(paste0("C:/Users/m7531338/OneDrive/Trabalho SEE/NGI - SI/1. Relatórios Diários/Flexdashboard/Regionais/", "Matrícula e Enturmação ", current_day_SRE_format))

if (dir.exists(dirSRE)) {
  setwd(dirSRE)
  
} else {
  
  dir.create((dirSRE), FALSE)
  setwd(dirSRE)
}

# Conectando com a BASE do Access (*. accdb) a ser trabalhada: antes a conexão deve ser feita pelo Painel de Controle

ch <- odbcConnect("BD_Matricula_2018")

qry_01 <- paste0("SELECT * ", 
                "FROM base ",
                "WHERE data = ", conversion)

df_mat_ent <- sqlQuery(ch, qry_01)

odbcClose(ch)

# Alterar a nomenclatura da primeira coluna para "SRE_Almenara"
df_mat_ent$SRE <- paste0("SRE ", df_mat_ent$SRE)

# Alterar o formato da coluna de Data início período e Data término período
df_mat_ent$DATA <- format(df_mat_ent$DATA, format = "%d.%m.%Y")
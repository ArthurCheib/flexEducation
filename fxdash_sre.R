library(XLConnect)
library(readxl)
library(RODBC)
library(rmarkdown)
library(tidyverse)
library(knitr)
library(readxl)

#Conversao da data no R para a data em formato numérico do Excel (contagem em dias):

current_day_R_format <- format(Sys.Date(), format = "%Y-%m-%d")

current_day_SRE_format <- format(Sys.Date(), format = "%d-%m-%Y")

conversion <- as.numeric(as.Date(current_day_R_format)-as.Date("1899-12-30"))

# Conectando com a BASE do Access (*. accdb) a ser trabalhada: antes a conexao deve ser feita pelo Painel de Controle

ch <- odbcConnect("BD_Matricula_2018")

qry_01 <- paste0("SELECT * ", 
                "FROM base")

df_mat_ent <- sqlQuery(ch, qry_01)

odbcClose(ch)

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


breaks <- unique(df_mat_ent %>% filter(SRE == regional, between(DATA, today() - days(90), today())) %>% .$DATA)

# Gráfico para retornar após solucionar problema
df_mat_ent %>%
  filter(SRE == regional,
         between(DATA, today() - days(90), today())) %>% 
  group_by(DATA) %>%
  summarize(TOTAL_MATRICULADOS = sum(ALUNOS_MATRICULADOS),
            TOTAL_ENTURMADOS = sum(ALUNOS_ENTURMADOS)) %>% 
  mutate(PERCENTUAL_ENTURMADOS = round((TOTAL_ENTURMADOS/TOTAL_MATRICULADOS)*100, digits = 2)) %>% 
  ggplot(aes(DATA, PERCENTUAL_ENTURMADOS)) +
  geom_line(size = 1.5) +
  geom_point(size=3) +
  theme_economist() +
  scale_x_date(breaks = breaks)

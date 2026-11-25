# División de Sit_Conc_raw en dos etapas de muestreo
# Se reparten participantes completos
# la seleción se hace dentro de cada lista de conceptos


# rutas 
input_file  <- "data/Sit_Conc_raw.csv"
output_s1   <- "data/Sit_Conc_raw_stage1.csv"
output_s2   <- "data/Sit_Conc_raw_stage2.csv"
prop_stage1 <- 0.7
seed        <- 42          # replica


# Lectura de datos
dfSitCog <- read.csv(input_file, sep = ";", fileEncoding = "windows-1252",
               stringsAsFactors = FALSE)


# Lista de conceptos por  cada participante

# la cpn tiene en total 72 concpetos. cada partipantes responde para 14. Es necesario identifacar la listas de concpetos para cada particpantres y agruparlas

concept_by_part <- tapply(dfSitCog$concept, dfSitCog$participant,
                       function(x) paste(sort(unique(x)), collapse = " | "))

dfparts <- data.frame(participant = as.integer(names(concept_by_part)),
                    list_id     = as.integer(factor(concept_by_part)))

table(dfparts$list_id)

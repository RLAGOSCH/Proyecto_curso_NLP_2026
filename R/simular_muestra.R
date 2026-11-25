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


# Sorteo de participantes dentro de cada lista

set.seed(seed)
dfparts$stage <- 2

for (l in unique(dfparts$list_id)) {
  ids_l <- dfparts$participant[dfparts$list_id == l]
  n_s1  <- round(length(ids_l) * prop_stage1)
  pick  <- sample(ids_l, n_s1)
  dfparts$stage[parts$participant %in% pick] <- 1
}

table(dfparts$list_id, dfparts$stage)


# Muestras de cada etapa
dfstage1 <- dfSitCog[dfSitCog$participant %in% dfparts$participant[dfparts$stage == 1], ]
dfstage2 <- dfSitCog[dfSitCog$participant %in% dfparts$participant[dfparts$stage == 2], ]


# Verificaciones

stopifnot(length(intersect(dfstage1$participant, dfstage2$participant)) == 0)
stopifnot(nrow(dfstage1) + nrow(dfstage2) == nrow(dfSitCog))
stopifnot(setequal(unique(dfstage1$concept), unique(dfstage2$concept)))


# Participantes por concepto en cada etapa

n_s1 <- tapply(dfstage1$participant, dfstage1$concept, function(x) length(unique(x)))
n_s2 <- tapply(dfstage2$participant, dfstage2$concept, function(x) length(unique(x)))

dfresumen <- data.frame(concept  = names(n_s1),
                      n_stage1 = as.vector(n_s1),
                      n_stage2 = as.vector(n_s2[names(n_s1)]))
print(dfresumen)


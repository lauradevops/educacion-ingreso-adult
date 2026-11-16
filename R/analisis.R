# =============================================================
# Educación e ingreso — Análisis de la base Adult (UCI)
# Autora: Laura Sofia Valencia
# © 2026 Laura Sofia Valencia. Todos los derechos reservados.
#
# Este script se ejecuta completo al generar la presentación
# (index.qmd). Cada bloque «## ---- nombre ----» es el fragmento
# que la presentación muestra en la diapositiva correspondiente:
# el código visible es exactamente el que produjo las tablas,
# los indicadores y los gráficos. Reproduce el procedimiento del
# informe original (Proyecto_Final_Adult.Rmd).
# =============================================================

## ---- paquetes ----
suppressPackageStartupMessages({
  library(readr)      # lectura de archivos de texto
  library(dplyr)      # manipulación de datos
  library(tidyr)      # reorganización de tablas
  library(knitr)      # tablas
  library(kableExtra) # formato de tablas HTML
  library(moments)    # asimetría (skewness)
})

## ---- formato ----
num <- function(x, d = 0)
  format(round(x, d), big.mark = ".", decimal.mark = ",", nsmall = d)
pct <- function(x, d = 1)
  paste0(format(round(100 * x, d), decimal.mark = ",", nsmall = d), "%")
mnum <- function(x, d = 3) gsub(",", "{,}", num(x, d))  # para fórmulas
# Paleta de la presentación (tonos tierra con acentos terracota y pino)
col_tinta <- "#2A2421"; col_terracota <- "#B5543A"; col_pino <- "#2F5A54"
resalte <- "#F6E4DA"     # fila destacada (terracota claro)
resalte2 <- "#E3ECE8"    # fila destacada secundaria (pino claro)
tabla <- function(df, caption = NULL, align = "c", ...) {
  kable(df, format = "html", caption = caption, align = align, ...) %>%
    kable_styling(bootstrap_options = "none", full_width = FALSE) %>%
    row_spec(0, bold = TRUE, color = col_tinta)
}

## ---- carga ----
columnas <- c("age", "workclass", "fnlwgt", "education",
              "education_num", "marital_status", "occupation",
              "relationship", "race", "sex", "capital_gain",
              "capital_loss", "hours_per_week", "native_country",
              "income")

entrenamiento <- read_csv("data/adult.data", col_names = columnas,
                          na = character(), trim_ws = TRUE)
prueba <- read_csv("data/adult.test", col_names = columnas,
                   skip = 1,  # la primera línea es un comentario
                   na = character(), trim_ws = TRUE)

# Base completa: 48.842 filas × 15 variables
datos_crudos <- bind_rows(entrenamiento, prueba)

## ---- faltantes ----
# Los faltantes vienen codificados como "?", no como NA
faltantes <- data.frame(
  Variable  = names(datos_crudos),
  `NA`      = colSums(is.na(datos_crudos)),
  `Signo ?` = sapply(datos_crudos, function(x) sum(x == "?")),
  check.names = FALSE, row.names = NULL)

filas_con_faltantes <- sum(apply(datos_crudos == "?", 1, any))

## ---- depuracion-filas ----
# Paso 1. Unificar etiquetas (en adult.test terminan en punto)
datos_crudos <- datos_crudos %>%
  mutate(income = sub("\\.$", "", income))
# Paso 2. Eliminar las filas con al menos un "?"
sin_faltantes <- datos_crudos %>%
  filter(if_all(everything(), ~ .x != "?"))
# Paso 3. Eliminar registros duplicados exactos
n_duplicados   <- sum(duplicated(sin_faltantes))
sin_duplicados <- distinct(sin_faltantes)

## ---- depuracion-variables ----
# Pasos 4 y 5. Agrupar la educación en 6 niveles y crear
# las variables de estudio
niveles_edu <- c("Primaria o menos", "Secundaria incompleta",
                 "Bachillerato", "Técnico / Univ. incompleta",
                 "Pregrado universitario", "Posgrado")

datos <- sin_duplicados %>%
  transmute(
    NIVEL_EDUCATIVO = cut(education_num,
                          breaks = c(0, 4, 8, 9, 12, 13, 16),
                          labels = niveles_edu,
                          ordered_result = TRUE),
    EDUCACION_ORIG = education,
    AÑOS_EDUC      = education_num,
    INGRESO        = factor(income, levels = c("<=50K", ">50K")),
    INGRESO_ALTO   = as.integer(income == ">50K"),  # 1 = >50K
    HORAS          = hours_per_week,
    EDAD           = age,
    SEXO           = factor(sex, levels = c("Female", "Male"),
                            labels = c("Mujer", "Hombre")))

## ---- funciones ----
estadisticos <- function(x) c(
  Media = mean(x), Mediana = median(x),
  Moda  = as.numeric(names(which.max(table(x)))),
  Q1 = quantile(x, .25, names = FALSE),
  Q3 = quantile(x, .75, names = FALSE),
  Mín = min(x), Máx = max(x), Rango = diff(range(x)),
  RIC = IQR(x), DE = sd(x), CV = sd(x) / mean(x) * 100,
  Asimetría = skewness(x))

# Atípicos (Tukey): fuera de [Q1 − 1,5·RIC ; Q3 + 1,5·RIC]
atipicos <- function(x) {
  li <- quantile(x, .25) - 1.5 * IQR(x)
  ls <- quantile(x, .75) + 1.5 * IQR(x)
  c(n = sum(x < li | x > ls), li = unname(li), ls = unname(ls))
}

## ---- uni-cualitativas ----
frecuencias <- function(v) datos %>%
  count({{ v }}) %>%
  mutate(Porcentaje = n / sum(n),
         Acumulado  = cumsum(Porcentaje))

tab_ingreso <- frecuencias(INGRESO)
tab_sexo    <- frecuencias(SEXO)
tab_edu     <- frecuencias(NIVEL_EDUCATIVO)

## ---- uni-cuantitativas ----
resumen_cuant <- sapply(datos[, c("EDAD", "AÑOS_EDUC", "HORAS")],
                        estadisticos)
at_edad  <- atipicos(datos$EDAD)
at_horas <- atipicos(datos$HORAS)

## ---- biv-contingencia ----
# Frecuencias absolutas nivel × ingreso
tab_cont <- table(datos$NIVEL_EDUCATIVO, datos$INGRESO)

# Indicador: proporción con ingreso >50K en cada nivel
prop_nivel <- datos %>%
  group_by(NIVEL_EDUCATIVO) %>%
  summarise(Personas   = n(),
            Con_alto   = sum(INGRESO_ALTO),
            Proporcion = mean(INGRESO_ALTO)) %>%
  mutate(Veces_promedio = Proporcion / mean(datos$INGRESO_ALTO))

## ---- biv-sexo ----
prop_sexo <- datos %>%
  group_by(SEXO) %>%
  summarise(Personas = n(), Proporcion = mean(INGRESO_ALTO))

prop_sexo_nivel <- datos %>%
  group_by(NIVEL_EDUCATIVO, SEXO) %>%
  summarise(Personas = n(), Proporcion = mean(INGRESO_ALTO),
            .groups = "drop")

## ---- biv-horas ----
horas_resumen <- function(...) datos %>%
  group_by(...) %>%
  summarise(n = n(), Media = mean(HORAS), Mediana = median(HORAS),
            DE = sd(HORAS), Mas_40 = mean(HORAS > 40),
            .groups = "drop") %>%
  # Intervalo de confianza del 95 % de la media
  mutate(IC_inf = Media - 1.96 * DE / sqrt(n),
         IC_sup = Media + 1.96 * DE / sqrt(n))

horas_ingreso <- horas_resumen(INGRESO)
horas_nivel   <- horas_resumen(NIVEL_EDUCATIVO)

## ---- biv-correlacion ----
# Pearson; con INGRESO_ALTO (0/1) equivale a la
# correlación punto-biserial
mat_cor <- cor(datos[, c("EDAD", "AÑOS_EDUC", "HORAS",
                         "INGRESO_ALTO")])

## ---- prob-marginales ----
# P(A): proporción con ingreso >50K
p_A  <- mean(datos$INGRESO_ALTO)
# P(B_i): proporción de personas en cada nivel educativo
p_B  <- prop.table(table(datos$NIVEL_EDUCATIVO))
# P(B_i ∩ ingreso): cada celda dividida por el total
conj <- prop.table(tab_cont)

## ---- prob-condicional ----
# P(A | B_i) = P(A ∩ B_i) / P(B_i)
p_cond <- conj[, ">50K"] / rowSums(conj)
p_pos  <- p_cond["Posgrado"]
p_bach <- p_cond["Bachillerato"]

odds <- function(p) p / (1 - p)
riesgo_relativo <- p_pos / p_bach
razon_odds      <- odds(p_pos) / odds(p_bach)

## ---- prob-bayes ----
# Ley de probabilidad total y teorema de Bayes
prob_total <- sum(p_cond * p_B)          # P(A)
bayes      <- p_cond * p_B / prob_total  # P(B_i | A)

# Verificación directa con los datos
p_pos_dado_A <- mean(
  datos$NIVEL_EDUCATIVO[datos$INGRESO_ALTO == 1] == "Posgrado")

## ---- prob-independencia ----
# Si fueran independientes: P(A ∩ B_i) = P(A) · P(B_i)
esperada_indep <- as.numeric(p_B) * p_A

chi <- chisq.test(tab_cont)              # prueba chi-cuadrado
v_cramer <- sqrt(chi$statistic /
                 (sum(tab_cont) * (min(dim(tab_cont)) - 1)))

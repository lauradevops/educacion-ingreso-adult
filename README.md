# Educación e ingreso

**¿El nivel educativo aumenta la probabilidad de ganar más de USD 50.000 al año?**
Análisis descriptivo y probabilístico de la base *Adult* (UCI), censo de Estados Unidos de 1994.

**Autora:** Laura Sofia Valencia · Proyecto final de Teoría de Probabilidad · 2026

---

## La presentación

La presentación es una página web interactiva de 25 diapositivas hecha con **Quarto**, **Reveal.js** y **Observable Plot**. Se abre en cualquier navegador, sin instalar nada (requiere conexión a internet para cargar las fuentes y la librería de gráficos).

| Acción | Cómo |
|:--|:--|
| Avanzar / retroceder | Flechas del teclado, barra espaciadora o flechas de la esquina inferior derecha |
| Pantalla completa | Tecla **F** o botón **Pantalla completa** (esquina superior derecha) |
| Índice de diapositivas | Menú ☰ (esquina inferior izquierda) o tecla **M** |
| Vista general | Tecla **O** o **Esc** |
| Ver cifras exactas de un gráfico | Pasar el cursor sobre barras, puntos o celdas |
| Cambiar la variable o la población de un gráfico | Selectores ubicados sobre el gráfico |
| Notas del orador | Tecla **S** |

## Contenido

La presentación sigue los seis requisitos del proyecto:

1. Pregunta de interés
2. Contextualización
3. Tipo, escala y categorías o valores de las 15 variables
4. Limpieza y depuración de los datos
5. Análisis estadístico: indicadores, gráficos y probabilidades (condicional, Bayes, independencia)
6. Presentación: esta presentación web, que cierra con la respuesta, los hallazgos y las limitaciones

## Organización de cada análisis

Cada diapositiva de análisis muestra, en este orden: **qué se analiza**, **por qué**, **procedimiento**, **código R** (el fragmento exacto de `R/analisis.R` que se ejecutó), **resultado** (tabla, indicador o gráfico) e **interpretación**.

## Estructura del repositorio

```
├── index.qmd                  Presentación (texto, tablas, gráficos y código)
├── R/analisis.R               Carga, depuración y cálculo de indicadores (fragmentos mostrados en las diapositivas)
├── data/                      Base Adult original (UCI)
├── assets/tema.scss           Diseño visual
├── assets/pantalla-completa.html  Botón de pantalla completa
├── assets/encabezado.html     Compatibilidad de las tablas
├── _quarto.yml                Configuración de Quarto y Reveal.js
├── _freeze/                   Resultados de R ya calculados (permiten publicar sin R)
└── .github/workflows/publicar.yml  Publicación automática en GitHub Pages
```

## Publicación

Cada vez que se sube un cambio a la rama `main`, GitHub Actions genera la presentación y la publica en GitHub Pages. Los resultados de R se guardan en `_freeze/`, por lo que el servidor no necesita instalar R.

Para actualizar el contenido, se edita `index.qmd` (o `R/analisis.R`), se genera la presentación en el computador con el botón **Render** de RStudio (o `quarto render`) y se suben los cambios, incluida la carpeta `_freeze/`.

## Datos

Becker, B. y Kohavi, R. (1996). *Adult* [Conjunto de datos]. UCI Machine Learning Repository. https://doi.org/10.24432/C5XW20 — licencia CC BY 4.0.

---

**© 2026 Laura Sofia Valencia. Todos los derechos reservados.**
El contenido académico, el análisis, el diseño y el desarrollo de esta presentación son de autoría de Laura Sofia Valencia. No está permitida su reproducción, distribución o copia sin autorización previa de la autora. Ver [LICENSE.md](LICENSE.md).

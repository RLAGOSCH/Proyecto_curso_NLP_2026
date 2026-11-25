# FACT "memory" codificación con "memoria"" entre etapas

FACT (Fully Automatic Codification Tool) codifica de forma automática datos de tareas de listado de propiedades (PLT). Pasa cada propiedad a un embedding, arma un grafo kNN con las propiedades de todos los conceptos, las agrupa con Louvain y se queda con los parámetros que dejan la cobertura de cada concepto (Chao2) más cerca de un valor objetivo.

Este repo parte de FACT 2.5 y se le agrega   la capacidad de "recordar"" lo que ya codificó.


## El problema

En los estudios de PLT (Property listing task) y en las CPNs derivadas de la agregación de estos, tipicamente se usa un tamaño de muestra de 30 particpans por conceto. 
Para solucionar esto Canessa et. all (2026) propone un muestreo de dos étapas. En la primera etapa se usaria para calcular el sample coverage (ver referencia ) y luego se determinaria cuantos partipantes falta para llegar a un sample coverage esperado.

Si embargo, al intentar replicar esta estrategia con FACT, al incluir los datos de la segunda muestra, este codifica todo de nuevo, produciendo en algunos casos que los sample coverage bajen. Para intentar solucionar este problema, el presente poryecto, pretende fija la codificación de la etapa 1 y codificar en la etapa 2 solo lo nuevo.
Si bien, la cobertura igual puede bajar si los nuevos participantes traen propiedades nuevas, este seria un  cambio real. No un cambio en los parametros de codificación


## Decisiones de diseño

- Un solo grafo para todos los conceptos, porque los códigos se comparten entre conceptos.
- Códigos congelados: lo que se codificó en una etapa no cambia después.
- Parámetros congelados: `k`, `sim_min` y `resolution` salen de la grilla de la etapa 1 y se reutilizan tal cual.
- Los mismos conceptos en todas las etapas. (condición clave)

## Hoja de ruta

Partimos en inglés, con Sit_Conc. Se escogio esta CPNs porque se utilizo en la fase de validación original (citar paper brm). Ademas porque es las mas pequeña de las dos CPNs disponibles en ingles, dismiyendo los tiempo de la etapa 1.

- [ ] **Paso 1.** Sorteo de las muestras de la primera y la segunda etapa 
- [ ] Los pasos siguientes se agregan a medida que avancemos.

## Paso 1. Sorteo de las muestras de cada etapa

### Datos

`data/Sit_Conc_raw.csv`: 9.399 propiedades, 72 conceptos y 120 participantes. Cada participante respondió 14 conceptos, así que cada concepto tiene entre 20 y 40 participantes.

### Prompt para la generacion del codigo python

"Escribe una version nueva de FACT (FACT 3.0) que recuerde la codificación de una etapa de muestreo a la siguiente. En la version acutal, si el muestreo se hace en dos etapas, la segunda obliga a codificar todo de nuevo  y la cobertura de algunos conceptos baja solo por haber recodificado. FACT 3.0 tiene que guardar lo que hizo en la etapa 1 y, en la etapa 2, codificar únicamente las propiedades nuevas.
Por ahora trabaja solo con la versión en inglés.
La versión base es src/FACT_2.5_en.ipynb, que usa el modelo intfloat/e5-base-v2 con el prefijo passage:. Los datos de prueba son data/CSLB_raw.csv y data/Sit_Conc_raw.csv, con columnas concept, participant y property. Los dos vienen separados por ;, y Sit_Conc_raw.csv está en Windows-1252. Los resultados de referencia de la 2.5 están en data/results/en/.
No las cambies:
Hay un solo grafo para todos los conceptos, porque los códigos se comparten entre conceptos.
Los códigos asignados en una etapa no cambian en las siguientes.
k, sim_min y resolution se eligen con la grilla en la etapa 1 y después se reutilizan.
Todas las etapas tienen los mismos conceptos."

Se ejecuto en claude con Opus 5.5 . Se cargaron los archivos de FACT 2.5. 


### Generación de las muestras simuladas 

Esto se realizo mediante un script en R `R/Simular_muesta-R`

- Se selecionara a nivel de partipantes, sin remplazo.
- Todos los conceptos tienen que quedar con participantes en las dos etapas. (paso clave)
- Cada sorteo genera dos CSV con las mismas columnas del original (`concept`, `participant`, `property`) 



## Resultados

Se codificaron los 72 conceptos de Sit_Conc en dos etapas. La etapa 1 tuvo 84 participantes y 6.545 propiedades. La etapa 2 tuvo 36 participantes y 2.854 propiedades. La búsqueda en grilla de la etapa 1 eligió k = 1, sim_min = 0,33 y resolution = 0,6. Los tres valores quedaron en el borde inferior de la grilla.

Ninguna de las 6.545 propiedades de la etapa 1 cambió de código. Las 2.854 propiedades nuevas se asignaron a códigos existentes y no se formó ningún código nuevo. El total se mantuvo en 1.197 códigos. La similitud de asignación fue de 0,80 como mínimo, con una mediana de 0,92 (figura `data/results/en/en_Sit_Conc_raw_stage2_stage2_coverage_by_stage.png`, panel derecho).

La cobertura media subió de 0,648 a 0,692. Subió en 63 conceptos y bajó en 9. El cambio fue de −0,044 (Waitress) a +0,151 (Working). Los conceptos con menor cobertura inicial tuvieron los aumentos más grandes (misma figura, panel izquierdo). El tamaño mediano de los códigos pasó de 4 a 6 propiedades (`data/results/en/en_Sit_Conc_raw_stage1_stage1_overall_cluster_size_hist.png` y `data/results/en/en_Sit_Conc_raw_stage2_stage2_overall_cluster_size_hist.png`).

La etapa 1 tardó 2.083 segundos, casi todo en la grilla. La etapa 2 tardó 3,4 segundos.

## Discusión

La memoria entre etapas funcionó: los códigos de la etapa 1 no cambiaron. Pero el método no pudo crear códigos nuevos y eso se explica por los parámetros. Con k = 1 cada propiedad nueva copia el código de su vecino más cercano. El umbral sim_min = 0,33 no filtra nada porque todas las similitudes fueron mayores que 0,80. Así toda propiedad nueva cae en un código viejo. Eso hace subir la cobertura aunque la propiedad sea distinta. Parte del aumento de cobertura sería entonces un efecto del método y no de los datos.

La grilla también da señales de alerta. Los tres parámetros quedaron en el borde inferior. Con k = 1 la pérdida es igual para cualquier valor de resolution, asi que ese parámetro no se eligió de verdad.

## Conclusión

Esta prueba usó la opción más simple: códigos e hiperparámetros congelados desde la etapa 1. Hay que evaluar otras variantes. Por ejemplo, ampliar la grilla, usar un k mayor para asignar en la etapa 2 o un umbral de similitud acorde con los valores de e5. También hacen falta otros criterios de comparación además de la cobertura. Por último, se necesita un estándar de referencia. Una codificación manual de las dos etapas permitiría ver si la baja de cobertura entre etapas también aparece cuando codifica una persona.


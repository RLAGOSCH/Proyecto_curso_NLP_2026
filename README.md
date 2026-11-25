# FACT "memory" codificación con "memoria"" entre etapas

FACT (Fully Automatic Codification Tool) codifica de forma automática datos de tareas de listado de propiedades (PLT). Pasa cada propiedad a un embedding, arma un grafo kNN con las propiedades de todos los conceptos, las agrupa con Louvain y se queda con los parámetros que dejan la cobertura de cada concepto (Chao2) más cerca de un valor objetivo.

Este repo parte de FACT 2.5 y le agrega una sola cosa, la capacidad de "recordar"" lo que ya codificó.


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

### Generación de las muestras simuladas 

- Se selecionara a nivel de partipantes, sin remplazo.
-  evalulara varios cirterios de corte (?)
- Todos los conceptos tienen que quedar con participantes en las dos etapas. (paso clave)
- Cada sorteo genera dos CSV con las mismas columnas del original (`concept`, `participant`, `property`) 

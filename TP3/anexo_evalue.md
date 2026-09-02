# El E-value en BLAST: parámetros, cálculo e interpretación
 
## ¿Qué pregunta responde el E-value?
 
Cuando BLAST encuentra un alineamiento entre tu secuencia (query) y una secuencia de la base de datos, siempre existe la posibilidad de que ese parecido haya surgido **por azar**, sin ninguna relación evolutiva o funcional real. El E-value (Expect value) responde exactamente esa pregunta:
 
> "Si buscara al azar en una base de datos de este tamaño, ¿cuántos alineamientos con este puntaje (o mejor) esperaría encontrar solo por casualidad?"
 
No es una probabilidad (aunque para valores chicos se comporta casi igual que una), sino un **número esperado de ocurrencias**. Por eso puede tomar cualquier valor entre 0 e infinito, y por eso mientras más chico, más confiable es el hit: un E-value de 2 significa "esperaría ver 2 alineamientos así de buenos por puro azar en esta búsqueda", lo cual no dice nada bueno sobre tu hit puntual.
 
## La fórmula: estadística de Karlin-Altschul
 
BLAST usa la teoría desarrollada por Samuel Karlin y Stephen Altschul, que demuestra que los puntajes de los mejores alineamientos locales entre secuencias aleatorias siguen una **distribución de valores extremos (Gumbel)**, no una distribución normal. A partir de esa teoría, la fórmula central es:
 
```
E = K · m · n · e^(−λS)
```
 
### Los parámetros, uno por uno
 
| Parámetro | Qué representa | De dónde sale |
|:---|:---|:---|
| **S** | El puntaje (score) crudo del alineamiento encontrado: la suma de los puntajes de sustitución (según la matriz usada) menos las penalidades por gaps. | Se calcula directamente a partir del alineamiento y la matriz de sustitución (ej. BLOSUM62). |
| **m** | La longitud (efectiva) de la secuencia query. | Longitud real de tu secuencia de entrada, ajustada (reducida) para corregir "efectos de borde": una alineación no puede empezar en cualquier posición sin dejar suficiente secuencia para extenderse. |
| **n** | La longitud (efectiva) de la base de datos: la suma de las longitudes de todas las secuencias que se están buscando. | Depende de qué base de datos elegiste (nr, Swiss-Prot, un genoma puntual, etc.) — es lo que hace que el mismo alineamiento tenga distinto E-value según dónde busques. |
| **λ (lambda)** | Factor de escala que normaliza el puntaje crudo a una escala "natural" para el sistema de puntuación usado. Se puede pensar como cuánta información (en nats o bits) aporta cada unidad de score. | Se calcula matemáticamente a partir de la matriz de sustitución y las penalidades de gap elegidas (para BLOSUM62 con gaps default, λ ≈ 0.267). |
| **K (kappa)** | Constante que ajusta la escala del E-value considerando que los puntajes óptimos de dos secuencias correlacionadas no son eventos totalmente independientes entre sí. | También se deriva de la matriz de sustitución y las penalidades de gap (para BLOSUM62 con gaps default, K ≈ 0.041). |

 
Los dos factores que determinan el E-value: **qué tan bueno es el alineamiento** (S', que solo crece si el alineamiento es genuinamente fuerte) y **qué tan grande es el espacio de búsqueda** (m·n, que solo depende del tamaño de tu query y de la base de datos, no de la biología del hit).
 
## Ejemplos: cómo cambia el E-value según cada parámetro
 
Fijate cómo el mismo puntaje de alineamiento puede dar E-values muy distintos según el contexto de la búsqueda:
 
| Escenario | S' (bit score) | m (long. query) | n (long. base de datos) | E-value resultante | Por qué |
|:---|---:|---:|---:|:---|:---|
| Hit fuerte, base de datos chica | 100 | 300 aa | 500.000 aa (un genoma bacteriano) | ≈ 1.18 × 10⁻²² | Puntaje alto y espacio de búsqueda chico → E-value extremadamente bajo, muy significativo. |
| El mismo hit, pero contra una base de datos gigante | 100 | 300 aa | 4 × 10¹⁰ aa (nr completa) | ≈ 9.47 × 10⁻¹⁸ | Mismo alineamiento, pero al buscar en una base ~100.000 veces más grande, sube el E-value proporcionalmente (aunque sigue siendo altamente significativo). |
| Hit débil, base de datos chica | 25 | 300 aa | 500.000 aa | ≈ 4.47 | Un puntaje bajo ya da un E-value mayor a 1, incluso en una base chica: no alcanza para ser significativo. |
| Hit débil, base de datos gigante | 25 | 300 aa | 4 × 10¹⁰ aa | ≈ 3.58 × 10⁵ | El mismo puntaje débil, en nr completo, da un E-value enorme — se esperarían cientos de miles de "hits" así de buenos por puro azar. |
| Query muy corto (ej. un péptido de 10 aa) | 25 | 10 aa | 500.000 aa | ≈ 0.149 | Con query corto, el espacio de búsqueda (m·n) es mucho menor, así que el mismo puntaje moderado da un E-value por debajo de 1 — pero ojo, con queries muy cortos las estadísticas de Karlin-Altschul son menos confiables (por eso BLASTP para péptidos cortos usa matrices y parámetros especiales). |
 
<div style="border-left: 6px solid #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>La idea clave de esta tabla</strong><br>
El E-value <em>no</em> es una propiedad fija del alineamiento en sí — es una propiedad del alineamiento <strong>en el contexto de una búsqueda particular</strong>. El mismo score puede ser "muy significativo" o "no significativo" dependiendo pura y exclusivamente del tamaño de la base de datos contra la que buscaste, sin que cambie nada de la biología del alineamiento. Por eso nunca hay que comparar E-values obtenidos en corridas contra bases de datos distintas como si fueran directamente equivalentes.
</div>

## Tabla de interpretación de resultados
 
Estos son los rangos de uso común (son convenciones prácticas, no hay un corte matemático "correcto" universal — depende del contexto biológico de lo que estés buscando):
 
| Rango de E-value | Interpretación típica |
|:---|:---|
| **E = 0** | BLAST redondea a 0 cuando el número es tan chico que no entra en la precisión de punto flotante (esto pasa típicamente con alineamientos idénticos o casi idénticos, largos). No significa "cero probabilidad matemática", significa "extremadamente cerca de cero". |
| **E < 1 × 10⁻¹⁰⁰** | Match prácticamente idéntico o casi idéntico — típico de la misma proteína en distintas bases de datos, o de ortólogos muy cercanos. |
| **1 × 10⁻¹⁰⁰ ≤ E < 1 × 10⁻²⁰** | Homología muy fuerte y confiable. Es el rango típico para proteínas homólogas bien conservadas entre especies relacionadas. |
| **1 × 10⁻²⁰ ≤ E < 1 × 10⁻⁵** | Homología significativa, buena confianza. Rango habitual para relaciones evolutivas más lejanas (mismo dominio, distinta familia dentro de una superfamilia) o proteínas ortólogas entre especies distantes. |
| **1 × 10⁻⁵ ≤ E < 0.01** | Zona de "posible relación, hay que revisar con cuidado". Puede ser un dominio compartido corto, o el comienzo de una relación real que necesita evidencia adicional (alineamiento completo, estructura, otras herramientas) antes de confiar en ella. |
| **0.01 ≤ E < 1** | Dudoso. Podría ser una coincidencia real débil o simplemente ruido estadístico — no alcanza como evidencia por sí solo. |
| **E ≥ 1** | Se espera encontrar al menos un hit así de bueno por puro azar en esta búsqueda. Generalmente se descarta como no significativo, salvo casos particulares (secuencias muy cortas, motivos de baja complejidad, donde el marco de referencia estadístico estándar no aplica igual). |
| **E ≥ 10 (default de BLASTP)** | Por convención, BLASTP ni siquiera reporta hits por encima de este umbral en su configuración por defecto — se consideran indistinguibles del ruido de fondo. |
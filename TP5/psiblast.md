# Cómo funciona PSI-BLAST (Position-Specific Iterated BLAST)

## 1. ¿Qué es PSI-BLAST?

**PSI-BLAST** es una variante de BLAST que busca secuencias homólogas de forma **iterativa**, construyendo en cada ronda una **PSSM** (perfil) a partir de los resultados de la búsqueda anterior, en lugar de usar siempre la misma matriz de sustitución fija (como BLOSUM62).

La idea clave: una PSSM construida a partir de homólogos ya encontrados captura mejor los patrones de conservación reales de una familia de proteínas que una matriz genérica. Esto permite detectar **homólogos remotos** (con poca identidad de secuencia) que un BLAST estándar no encontraría.

PSI-BLAST se usa típicamente para:

- Detectar dominios proteicos lejanamente relacionados.
- Encontrar toda una familia de proteínas a partir de una sola secuencia "semilla".
- Anotar función en proteínas poco caracterizadas, por homología remota.

---

## 2. Flujo general (bucle iterativo)

```
Iteración 0: BLAST estándar con la secuencia query (matriz BLOSUM62)
        │
        ▼
Seleccionar hits significativos (E-value < umbral, ej. 0.005)
        │
        ▼
Construir un alineamiento múltiple (MSA) con query + hits
        │
        ▼
Calcular una PSSM a partir del MSA (con pseudocounts)
        │
        ▼
Usar la PSSM como "query" para volver a buscar en la base de datos
        │
        ▼
¿Aparecieron hits nuevos que superan el umbral?
    │sí                              │no
    ▼                                 ▼
Repetir el ciclo                  Convergencia: FIN
(hasta un máximo de iteraciones,
 típicamente 5)
```

---

## 3. Ejemplo paso a paso

### Paso 1 — Iteración 0: BLAST estándar

Supongamos una secuencia query corta (proteína, 5 residuos):

```
Query: M K V L A
```

Se corre un BLAST normal contra una base de datos, usando BLOSUM62. Se obtienen 4 hits con E-value por debajo del umbral (0.005):

| Secuencia | 1 | 2 | 3 | 4 | 5 | E-value |
|-----------|---|---|---|---|---|---------|
| Query     | M | K | V | L | A | —       |
| Hit 1     | M | K | V | L | S | 0.0004  |
| Hit 2     | M | R | V | L | A | 0.0012  |
| Hit 3     | M | K | I | L | A | 0.0031  |
| Hit 4     | M | K | V | M | A | 0.0021  |

Todos superan el umbral (E-value < 0.005), así que se incluyen en el alineamiento.

### Paso 2 — Construir el alineamiento múltiple (MSA)

El MSA queda formado por la query + los 4 hits (5 secuencias en total), ya alineadas en el paso anterior:

| Pos | 1 | 2 | 3 | 4 | 5 |
|-----|---|---|---|---|---|
| Query | M | K | V | L | A |
| Hit 1 | M | K | V | L | S |
| Hit 2 | M | R | V | L | A |
| Hit 3 | M | K | I | L | A |
| Hit 4 | M | K | V | M | A |

### Paso 3 — Calcular la PSSM del perfil

**Conteos por posición:**

| Residuo | Pos 1 | Pos 2 | Pos 3 | Pos 4 | Pos 5 |
|---------|-------|-------|-------|-------|-------|
| M       | 5     | –     | –     | 1     | –     |
| K       | –     | 4     | –     | –     | –     |
| R       | –     | 1     | –     | –     | –     |
| V       | –     | –     | 4     | –     | –     |
| I       | –     | –     | 1     | –     | –     |
| L       | –     | –     | –     | 4     | –     |
| A       | –     | –     | –     | –     | 4     |
| S       | –     | –     | –     | –     | 1     |

Se agregan **pseudocounts** para evitar probabilidades cero (aquí, +1 sobre cada variante observada, de forma simplificada — PSI-BLAST real usa pseudocounts derivados de BLOSUM62, ponderados según cuántas secuencias hay en el perfil):

| Residuo | PPM Pos 1 | PPM Pos 2 | PPM Pos 3 | PPM Pos 4 | PPM Pos 5 |
|---------|-----------|-----------|-----------|-----------|-----------|
| M       | 6/6 = 1.000 | — | — | 2/7 = 0.286 | — |
| K       | — | 5/7 = 0.714 | — | — | — |
| R       | — | 2/7 = 0.286 | — | — | — |
| V       | — | — | 5/7 = 0.714 | — | — |
| I       | — | — | 2/7 = 0.286 | — | — |
| L       | — | — | — | 5/7 = 0.714 | — |
| A       | — | — | — | — | 5/7 = 0.714 |
| S       | — | — | — | — | 2/7 = 0.286 |

Convertimos a log-odds usando una frecuencia de fondo simplificada y uniforme de 0.05 por residuo (en la realidad, PSI-BLAST usa las frecuencias reales de cada aminoácido en las proteínas, no un valor uniforme):

```
PSSM(b, i) = log2( PPM(b, i) / 0.05 )
```

| Residuo | Pos 1 | Pos 2 | Pos 3 | Pos 4 | Pos 5 |
|---------|-------|-------|-------|-------|-------|
| M       | +4.32 | — | — | +2.51 | — |
| K       | — | +3.84 | — | — | — |
| R       | — | +2.51 | — | — | — |
| V       | — | — | +3.84 | — | — |
| I       | — | — | +2.51 | — | — |
| L       | — | — | — | +3.84 | — |
| A       | — | — | — | — | +3.84 |
| S       | — | — | — | — | +2.51 |

**Esta es la PSSM (perfil) tras la primera ronda.** A diferencia de BLOSUM62, ahora refleja específicamente que en la posición 2 se toleran K o R, en la 3 se toleran V o I, etc. — patrones propios de esta familia, no genéricos.

### Paso 4 — Iteración 1: volver a buscar con la PSSM

Ahora PSI-BLAST usa esta PSSM (en lugar de BLOSUM62) para volver a escanear la base de datos. Esto le da mayor sensibilidad: puede encontrar secuencias que BLAST estándar habría pasado por alto.

Por ejemplo, comparemos dos posibles secuencias candidatas de la base de datos:

**Candidata A:** `M K V L A` (idéntica a la query)

```
Score = 4.32 + 3.84 + 3.84 + 3.84 + 3.84 = 19.68
```

**Candidata B:** `M R I L S` (variante con residuos "tolerados" por el perfil en varias posiciones)

```
Score = 4.32 + 2.51 + 2.51 + 3.84 + 2.51 = 15.69
```

Con BLOSUM62 puro, la candidata B —al tener 3 de 5 residuos distintos de la query— probablemente habría quedado por debajo del umbral de significancia. Pero como el perfil "aprendió" que R, I y S son variantes aceptadas en esas posiciones, PSI-BLAST le asigna un score alto y la puede recuperar como hit válido en esta iteración.

### Paso 5 — Repetir hasta convergencia

Si la iteración 1 encuentra nuevos hits significativos (como la candidata B), estos se agregan al MSA, se recalcula la PSSM (ahora con 6 secuencias) y se vuelve a buscar. Este ciclo se repite hasta que:

- **No aparecen hits nuevos** por debajo del umbral de E-value → convergencia.
- Se alcanza el **número máximo de iteraciones** (por defecto, 5 en NCBI PSI-BLAST).

---

## 4. Notas importantes

- **Umbral de inclusión**: el E-value por defecto para incluir una secuencia en el perfil es 0.005 (más laxo que el umbral típico de "hit significativo" en BLAST simple).
- **Riesgo de corrupción del perfil**: si en alguna iteración se incluye por error una secuencia falsa (no homóloga real), el perfil puede "desviarse" y empezar a atraer aún más falsos positivos en iteraciones siguientes — un problema conocido como *profile drift* o *corrupción del perfil*.
- **Pseudocounts reales**: PSI-BLAST no usa pseudocounts simples (+1) como en este ejemplo didáctico; usa un esquema basado en BLOSUM62 que pondera cuánta "confianza" dar a los conteos observados según el tamaño del alineamiento.
- **Relación con HMMs de perfil**: PSI-BLAST y los HMM de perfil (como HMMER/Pfam) resuelven un problema similar —representar una familia de proteínas como un modelo probabilístico—, pero los HMM de perfil son más flexibles porque modelan explícitamente inserciones y deleciones con estados dedicados, mientras que la PSSM de PSI-BLAST asume posiciones fijas.
- **Salida útil**: además de la lista de hits, PSI-BLAST permite guardar la PSSM final para reutilizarla directamente en búsquedas futuras (opción `-out_pssm` en la versión de línea de comandos).

---

## 5. Resumen visual del flujo

```
Query inicial
     │
     ▼
BLAST estándar (BLOSUM62) ──► Hits con E-value < umbral
     │
     ▼
Alineamiento múltiple (query + hits)
     │
     ▼
Cálculo de la PSSM (con pseudocounts)
     │
     ▼
Nueva búsqueda en la base de datos usando la PSSM
     │
     ▼
¿Hits nuevos significativos?
   │ sí                    │ no
   ▼                        ▼
Actualizar MSA          Convergencia
y repetir el ciclo       (fin del proceso)
```

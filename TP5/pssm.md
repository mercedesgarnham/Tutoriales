# Cómo se calcula una PSSM (Position-Specific Scoring Matrix)

## 1. ¿Qué es una PSSM?

Una **PSSM** (también llamada PWM, *Position Weight Matrix*) es una matriz que resume, posición por posición, qué tan probable es encontrar cada símbolo (nucleótido o aminoácido) en un conjunto de secuencias alineadas. Se usa para:

- Buscar motivos de unión a factores de transcripción.
- Detectar dominios proteicos (como hace PSI-BLAST).
- Escanear genomas o proteínas en busca de nuevas coincidencias con un patrón conocido.

La idea central es convertir un alineamiento múltiple en una matriz de **puntajes log-odds**: cuánto más (o menos) probable es un símbolo en una posición dada, comparado con lo que esperaríamos por azar (frecuencia de fondo o *background*).

---

## 2. Pasos generales

1. **Alineamiento múltiple de secuencias (MSA)** — punto de partida.
2. **Matriz de frecuencias (PFM)** — contar cuántas veces aparece cada símbolo en cada posición.
3. **Matriz de probabilidades (PPM)** — normalizar los conteos, agregando *pseudocounts* para evitar probabilidades cero.
4. **PSSM (log-odds)** — comparar cada probabilidad contra la frecuencia de fondo esperada, usando logaritmo (habitualmente en base 2).
5. **Uso de la PSSM** — puntuar nuevas secuencias sumando los valores correspondientes a cada posición.

---

## 3. Ejemplo paso a paso (ADN)

### Paso 1 — Alineamiento múltiple

Supongamos que tenemos 5 secuencias de ADN de largo 6, ya alineadas (por ejemplo, sitios de unión conservados):

| Secuencia | 1 | 2 | 3 | 4 | 5 | 6 |
|-----------|---|---|---|---|---|---|
| Seq 1     | A | T | G | C | A | T |
| Seq 2     | A | T | G | C | A | A |
| Seq 3     | A | T | G | G | A | T |
| Seq 4     | A | T | C | C | A | T |
| Seq 5     | A | T | G | C | A | T |

### Paso 2 — Matriz de frecuencias (PFM)

Contamos cuántas veces aparece cada base (A, C, G, T) en cada posición:

| Base | Pos 1 | Pos 2 | Pos 3 | Pos 4 | Pos 5 | Pos 6 |
|------|-------|-------|-------|-------|-------|-------|
| A    | 5     | 0     | 0     | 0     | 5     | 1     |
| C    | 0     | 0     | 1     | 4     | 0     | 0     |
| G    | 0     | 0     | 4     | 1     | 0     | 0     |
| T    | 0     | 5     | 0     | 0     | 0     | 4     |

(Cada columna suma 5, que es el número de secuencias, *N*.)

### Paso 3 — Matriz de probabilidades (PPM) con pseudocounts

Si usáramos directamente frecuencia = conteo/N, cualquier base con 0 apariciones tendría probabilidad 0, lo que luego generaría un log(0) indefinido. Para evitarlo se añade un **pseudocount** (aquí usamos 1 por cada una de las 4 bases, un valor simple tipo Laplace).

Fórmula:

```
PPM(b, i) = ( conteo(b, i) + pseudocount ) / ( N + 4 × pseudocount )
```

Con N = 5 y pseudocount = 1, el denominador es 5 + 4 = 9.

| Base | Pos 1 | Pos 2 | Pos 3 | Pos 4 | Pos 5 | Pos 6 |
|------|-------|-------|-------|-------|-------|-------|
| A    | 6/9 = 0.667 | 1/9 = 0.111 | 1/9 = 0.111 | 1/9 = 0.111 | 6/9 = 0.667 | 2/9 = 0.222 |
| C    | 1/9 = 0.111 | 1/9 = 0.111 | 2/9 = 0.222 | 5/9 = 0.556 | 1/9 = 0.111 | 1/9 = 0.111 |
| G    | 1/9 = 0.111 | 1/9 = 0.111 | 5/9 = 0.556 | 2/9 = 0.222 | 1/9 = 0.111 | 1/9 = 0.111 |
| T    | 1/9 = 0.111 | 6/9 = 0.667 | 1/9 = 0.111 | 1/9 = 0.111 | 1/9 = 0.111 | 5/9 = 0.556 |

### Paso 4 — PSSM (log-odds)

Ahora comparamos cada probabilidad contra la frecuencia de fondo esperada. Para ADN, si asumimos que las 4 bases son igualmente probables al azar, el *background* es:

```
p(A) = p(C) = p(G) = p(T) = 0.25
```

La fórmula del PSSM es:

```
PSSM(b, i) = log2( PPM(b, i) / p(b) )
```

Aplicando esto a cada celda:

| Base | Pos 1 | Pos 2 | Pos 3 | Pos 4 | Pos 5 | Pos 6 |
|------|-------|-------|-------|-------|-------|-------|
| A    | +1.415 | −1.170 | −1.170 | −1.170 | +1.415 | −0.170 |
| C    | −1.170 | −1.170 | −0.170 | +1.152 | −1.170 | −1.170 |
| G    | −1.170 | −1.170 | +1.152 | −0.170 | −1.170 | −1.170 |
| T    | −1.170 | +1.415 | −1.170 | −1.170 | −1.170 | +1.152 |

**Esta es la PSSM final.** Los valores positivos indican que esa base es más frecuente de lo esperado por azar en esa posición (más "conservada"); los negativos indican que es menos frecuente.

Ejemplo de cálculo de una celda (posición 3, base G):

```
PPM(G,3) = 5/9 = 0.556
PSSM(G,3) = log2(0.556 / 0.25) = log2(2.222) ≈ 1.152
```

### Paso 5 — Puntuar una secuencia nueva

Para saber qué tan bien encaja una secuencia nueva con el patrón, se suman los valores de la PSSM correspondientes a cada base en cada posición.

**Ejemplo A:** secuencia `ATGCAT` (idéntica al consenso)

| Posición | Base | Valor PSSM |
|----------|------|------------|
| 1 | A | +1.415 |
| 2 | T | +1.415 |
| 3 | G | +1.152 |
| 4 | C | +1.152 |
| 5 | A | +1.415 |
| 6 | T | +1.152 |

Puntaje total = 1.415 + 1.415 + 1.152 + 1.152 + 1.415 + 1.152 = **7.701**

**Ejemplo B:** secuencia `ATCGAC` (varias bases distintas al consenso)

| Posición | Base | Valor PSSM |
|----------|------|------------|
| 1 | A | +1.415 |
| 2 | T | +1.415 |
| 3 | C | −0.170 |
| 4 | G | −0.170 |
| 5 | A | +1.415 |
| 6 | C | −1.170 |

Puntaje total = 1.415 + 1.415 − 0.170 − 0.170 + 1.415 − 1.170 = **2.735**

El puntaje mucho más alto de la secuencia A (7.70 frente a 2.74) confirma que encaja mucho mejor con el patrón conservado que la secuencia B.

---

## 4. Notas importantes

- **Pseudocounts**: el valor 1 usado aquí es solo ilustrativo. En la práctica se suelen usar pseudocounts proporcionales a `sqrt(N)` (regla de Sander & Schneider) u otros esquemas más sofisticados (por ejemplo, basados en matrices de sustitución como BLOSUM para proteínas).
- **Frecuencia de fondo**: para ADN a veces no se usa 0.25 uniforme, sino la composición real de bases del genoma (contenido GC, etc.). Para proteínas se usa la frecuencia natural de cada aminoácido.
- **Base del logaritmo**: log2 es común porque el resultado se interpreta en "bits" de información, pero también se usa log natural o log10 según la herramienta (BLAST, MEME, JASPAR, etc.).
- **PSI-BLAST**: construye su PSSM de forma iterativa a partir de los resultados de BLAST, refinando la matriz en cada ronda de búsqueda.
- **Umbral de decisión**: normalmente se define un puntaje mínimo (threshold) por encima del cual se considera que una secuencia "coincide" con el patrón representado por la PSSM.

---

## 5. Resumen visual del flujo

```
Secuencias alineadas (MSA)
        │
        ▼
Matriz de frecuencias (PFM)   → conteo de cada símbolo por posición
        │
        ▼
Matriz de probabilidades (PPM) → conteo + pseudocount, normalizado
        │
        ▼
PSSM (log-odds)                → log2( PPM / frecuencia de fondo )
        │
        ▼
Puntuación de nuevas secuencias → suma de valores según cada posición
```

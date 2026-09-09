# Cómo funciona un HMM (Hidden Markov Model) en bioinformática

## 1. ¿Qué es un HMM?

Un **HMM** (*Hidden Markov Model*, Modelo Oculto de Markov) es un modelo probabilístico que asume que una secuencia observada (por ejemplo, de nucleótidos o aminoácidos) fue generada por una secuencia de **estados ocultos**, que no vemos directamente, pero que determinan la probabilidad de cada símbolo observado.

Se usa mucho en bioinformática para:

- Detectar **islas CpG** en el genoma.
- Encontrar **genes** (modelos de exones/intrones, como GENSCAN).
- Alinear secuencias contra un dominio proteico (**HMM de perfil**, como en Pfam/HMMER).
- Predecir estructura secundaria o regiones transmembrana.

A diferencia de una PSSM (que puntúa posiciones fijas de un alineamiento), un HMM puede modelar secuencias de **longitud variable** y **transiciones entre distintos "contextos"** (estados) a lo largo de la secuencia.

---

## 2. Componentes de un HMM

Un HMM queda definido por:

1. **Estados ocultos** — por ejemplo, "región de alto GC" (H) y "región de bajo GC" (L).
2. **Probabilidades de transición** `a(j,k)` — probabilidad de pasar del estado *j* al estado *k*.
3. **Probabilidades de emisión** `e_k(x)` — probabilidad de observar el símbolo *x* estando en el estado *k*.
4. **Probabilidades iniciales** — probabilidad de comenzar en cada estado.

El objetivo típico es, dada una secuencia observada, encontrar la **secuencia de estados ocultos más probable** que la generó. Esto se resuelve con el **algoritmo de Viterbi**.

---

## 3. Ejemplo paso a paso: detección de islas CpG

### Paso 1 — Definir los estados y sus probabilidades

Modelo simple de 2 estados:

- **H** = región de alto contenido GC (posible isla CpG)
- **L** = región de bajo contenido GC (ADN "normal")

**Probabilidades iniciales:**

| Estado | Probabilidad inicial |
|--------|----------------------|
| H      | 0.5                  |
| L      | 0.5                  |

**Probabilidades de transición:**

| De \ A | H   | L   |
|--------|-----|-----|
| H      | 0.5 | 0.5 |
| L      | 0.4 | 0.6 |

(Es decir: si estoy en H, hay 50% de chance de seguir en H y 50% de pasar a L. Si estoy en L, hay 40% de pasar a H y 60% de quedarme en L.)

**Probabilidades de emisión:**

| Estado | A   | C   | G   | T   |
|--------|-----|-----|-----|-----|
| H      | 0.2 | 0.3 | 0.3 | 0.2 |
| L      | 0.3 | 0.2 | 0.2 | 0.3 |

(El estado H emite más C y G, como corresponde a una isla CpG; el estado L emite más A y T.)

### Paso 2 — La secuencia observada

Vamos a decodificar la secuencia:

```
G  C  G
```

### Paso 3 — Algoritmo de Viterbi

La idea de Viterbi es construir, para cada posición y cada estado, el mejor puntaje posible hasta ese punto:

```
V_k(i) = e_k(x_i) × max_j ( V_j(i-1) × a(j,k) )
```

donde `V_k(i)` es la probabilidad del mejor camino que termina en el estado *k* en la posición *i*, habiendo emitido correctamente los símbolos vistos hasta ahí.

#### Posición 1 (símbolo = G) — inicialización

```
V_H(1) = P_inicial(H) × e_H(G) = 0.5 × 0.3 = 0.15
V_L(1) = P_inicial(L) × e_L(G) = 0.5 × 0.2 = 0.10
```

| Estado | Valor |
|--------|-------|
| H      | 0.15  |
| L      | 0.10  |

#### Posición 2 (símbolo = C)

```
V_H(2) = e_H(C) × max( V_H(1)×a(H,H), V_L(1)×a(L,H) )
       = 0.3 × max( 0.15×0.5, 0.10×0.4 )
       = 0.3 × max( 0.075, 0.040 )
       = 0.3 × 0.075 = 0.0225   ← viene de H

V_L(2) = e_L(C) × max( V_H(1)×a(H,L), V_L(1)×a(L,L) )
       = 0.2 × max( 0.15×0.5, 0.10×0.6 )
       = 0.2 × max( 0.075, 0.060 )
       = 0.2 × 0.075 = 0.0150   ← viene de H
```

| Estado | Valor  | Mejor predecesor |
|--------|--------|-------------------|
| H      | 0.0225 | H |
| L      | 0.0150 | H |

#### Posición 3 (símbolo = G)

```
V_H(3) = e_H(G) × max( V_H(2)×a(H,H), V_L(2)×a(L,H) )
       = 0.3 × max( 0.0225×0.5, 0.0150×0.4 )
       = 0.3 × max( 0.01125, 0.00600 )
       = 0.3 × 0.01125 = 0.003375   ← viene de H

V_L(3) = e_L(G) × max( V_H(2)×a(H,L), V_L(2)×a(L,L) )
       = 0.2 × max( 0.0225×0.5, 0.0150×0.6 )
       = 0.2 × max( 0.01125, 0.00900 )
       = 0.2 × 0.01125 = 0.002250   ← viene de H
```

| Estado | Valor    | Mejor predecesor |
|--------|----------|--------------------|
| H      | 0.003375 | H |
| L      | 0.002250 | H |

### Paso 4 — Terminación y traceback

Se elige el estado final con mayor valor de Viterbi:

```
max( V_H(3), V_L(3) ) = V_H(3) = 0.003375  →  termina en H
```

Siguiendo los punteros de "mejor predecesor" hacia atrás:

```
Posición 3: H  (mejor final)
Posición 2: H  (predecesor de H en 3)
Posición 1: H  (predecesor de H en 2)
```

**Camino de estados más probable:** `H → H → H`

### Paso 5 — Interpretación

Para la secuencia `GCG`, el modelo concluye que lo más probable es que **toda la secuencia provenga del estado de alto GC (H)**, es decir, que forme parte de una isla CpG. Esto tiene sentido: G y C son justamente las bases que el estado H emite con mayor probabilidad.

---

## 4. Notas importantes

- **Viterbi vs. Forward**: Viterbi encuentra el *camino único más probable* de estados. El **algoritmo Forward** (muy similar, pero sumando en vez de tomar el máximo) calcula la probabilidad total de la secuencia considerando *todos* los caminos posibles, útil para comparar modelos completos.
- **Subflujo numérico**: en secuencias largas, multiplicar muchas probabilidades pequeñas genera números extremadamente chicos (*underflow*). Por eso en la práctica se trabaja en **log-espacio**, sumando logaritmos en vez de multiplicar probabilidades.
- **Entrenamiento del modelo**: las probabilidades de transición y emisión no se inventan a mano como en este ejemplo; se estiman a partir de datos reales usando algoritmos como **Baum-Welch** (un caso particular de Expectation-Maximization) cuando no se conocen los estados ocultos de antemano.
- **HMM de perfil**: para alinear secuencias contra una familia de proteínas (como en Pfam), se usan HMMs más complejos con estados de tipo *match*, *insert* y *delete* en cada posición del alineamiento, permitiendo modelar inserciones y deleciones además de sustituciones.

---

## 5. Resumen visual del flujo

```
Definir estados ocultos + probabilidades
 (iniciales, de transición, de emisión)
              │
              ▼
   Secuencia observada (ej: G C G)
              │
              ▼
  Algoritmo de Viterbi (o Forward)
   V_k(i) = e_k(x_i) × max_j( V_j(i-1) × a(j,k) )
              │
              ▼
   Traceback de punteros → camino de
   estados ocultos más probable
              │
              ▼
   Interpretación biológica del resultado
   (ej: región = isla CpG)
```

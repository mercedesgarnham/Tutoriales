# Ejercicio extra: De la información del alineamiento múltiple a un patrón de PROSITE

## Objetivo del ejercicio

Entender de dónde salen los patrones que catalogamos como "motivos lineales" en bases de datos como PROSITE: no son inventados, sino que se derivan de columnas conservadas (y variables) de un alineamiento múltiple de secuencias relacionadas. Vamos a practicar leer patrones reales de PROSITE, escribirlos como regex, y usarlos para escanear una proteína.

---

## Introducción: de un MSA a un patrón

<div style="border-left: 6px solid #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>¿Cómo nace un patrón de PROSITE?</strong><br><br>
Cuando varias proteínas relacionadas comparten una función bioquímica puntual (por ejemplo, todas son fosforiladas por la misma quinasa, o todas unen ATP de la misma manera), sus secuencias alrededor de ese sitio funcional suelen alinearse en una columna conservada dentro de un MSA. Al observar esa región en el alineamiento:
<ul>
<li>Las posiciones <strong>invariantes</strong> (el mismo aminoácido en todas las secuencias) se escriben como letras fijas.</li>
<li>Las posiciones <strong>parcialmente conservadas</strong> (un grupo reducido de aminoácidos posibles) se escriben como clases <code>[XYZ]</code>.</li>
<li>Las posiciones sin conservación relevante se escriben como <code>x</code> (equivalente al <code>.</code> que venimos usando).</li>
<li>Las posiciones que <strong>nunca</strong> aparecen (porque bioquímicamente impiden la función, como una prolina que rompe una hélice) se escriben como <code>{X}</code> (equivalente a <code>[^X]</code>).</li>
</ul>
El resultado es una expresión regular generalizada: el patrón de PROSITE. La base de datos no guarda "una secuencia ejemplo", guarda la regla derivada del alineamiento de todas las instancias conocidas.
</div>

---

## Paso 1: Leer patrones reales de PROSITE

La siguiente tabla muestra patrones reales tal como figuran en la base de datos PROSITE, con su sintaxis original (con guiones) y su equivalente en regex de estilo regex101 (con puntos):

| ID PROSITE | Nombre | Patrón original (PROSITE) | Regex equivalente |
|:---|:---|:---|:---|
| PS00001 | Sitio de N-glicosilación | `N-{P}-[ST]-{P}` | `N[^P][ST][^P]` |
| PS00005 | Sitio de fosforilación por PKC | `[ST]-x-[RK]` | `[ST].[RK]` |
| PS00006 | Sitio de fosforilación por caseína quinasa II | `[ST]-x(2)-[DE]` | `[ST].{2}[DE]` |
| PS00009 | Sitio de amidación | `x-G-[RK]-[RK]` | `.G[RK][RK]` |
| PS00017 | Motivo A de unión a ATP/GTP (P-loop, Walker A) | `[AG]-x(4)-G-K-[ST]` | `[AG].{4}GK[ST]` |

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Paso 1:</strong><br>
Para cada uno de los 5 patrones de la tabla, proponé (a mano, sin herramientas) una secuencia corta de aminoácidos que lo cumpla. Después verificá cada una en <a href="https://regex101.com" target="_blank">regex101</a> usando la columna "Regex equivalente".
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 1:</strong><br>
El P-loop (PS00017) tiene <code>x(4)</code> como único tramo no conservado, y aun así es uno de los motivos mejor caracterizados estructuralmente en biología. ¿Por qué un motivo con una región tan poco restrictiva puede seguir siendo funcionalmente muy específico? (Pensá en qué residuos SÍ están fijos y qué rol estructural cumplen: G, K y el [AG] inicial).
</div>

---


## Paso 2: Escanear una proteína real con ScanProsite
 
Vamos a retomar la p53 humana (UniProt **P04637**) que ya usaste en el Ejercicio 5, pero esta vez enfocándonos en los patrones de fosforilación de la tabla anterior.
 
<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Paso 2:</strong><br>
1. Entrá a <a href="https://prosite.expasy.org/scanprosite/" target="_blank">ScanProsite</a>.<br>
2. Pegá la secuencia de p53 (UniProt P04637) en formato FASTA.<br>
3. Antes de ejecutar, <strong>destildá</strong> la opción "Exclude motifs with a high probability of occurrence" (por defecto está tildada y oculta justamente los patrones cortos y degenerados como los que vamos a buscar).<br>
4. Ejecutá la búsqueda y, en la lista de resultados, buscá específicamente si aparecen hits para <strong>PS00005</strong> (PKC) y <strong>PS00006</strong> (caseína quinasa II).
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 2:</strong><br>
¿Cuántos hits obtuviste para PS00005 y para PS00006? Elegí uno de esos hits y anotá su posición exacta en la secuencia.
</div>

 
## Paso 3: Volver al alineamiento
 
<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Paso 3:</strong><br>
Elegí uno de los hits de PS00005 o PS00006 que encontraste en p53. Buscá (en UniProt o en literatura) si esa posición corresponde a un sitio de fosforilación experimentalmente confirmado y conservado entre ortólogos de p53 en otras especies (podés revisar la sección "Family & Domains" o "PTM/Processing" de la entrada P04637 en UniProt).
</div>
<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 4:</strong><br>
¿El sitio que elegiste está anotado como sitio de fosforilación real en UniProt? ¿Qué te dice esto sobre la relación entre "cumplir un patrón de PROSITE" y "ser un sitio funcional verificado"? Relacionalo con la idea de la Introducción: un patrón resume lo que se vio en un MSA de proteínas relacionadas, pero encontrar el patrón en una secuencia nueva es solo una hipótesis, no una confirmación.
</div>


---

## Cierre

<div style="border-left: 6px solid #28a745; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✅ Objetivos alcanzados</strong><br>
<ul>
<li>Entender que los patrones de PROSITE se derivan de columnas conservadas y variables de un MSA. (Sí / No)</li>
<li>Leer y convertir patrones de PROSITE (sintaxis con guiones) a regex de tipo regex101. (Sí / No)</li>
<li>Usar ScanProsite para encontrar motivos en una proteína real. (Sí / No)</li>
<li>Distinguir entre "cumplir un patrón" y "tener evidencia funcional confirmada" de un sitio. (Sí / No)</li>
</ul>
</div>

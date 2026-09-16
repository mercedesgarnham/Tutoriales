
# TP8: Mapeo de lecturas cortas (Short Read Mapping)

En este tutorial vamos a usar la plataforma **Galaxy** para mapear lecturas de secuenciación de segunda generación (Illumina) contra un genoma de referencia, y luego vamos a visualizar e interpretar los resultados con **JBrowse2**.

## Objetivos
1. Interpretar los formatos utilizados comúnmente en NGS (secuenciación de nueva generación).

2. Mapear secuencias al genoma de referencia.

3. Visualizar e interpretar alteraciones genéticas.

---

## Uso del mapeo de lecturas en bioinformática

La re-secuenciación consiste en secuenciar un individuo de una especie que ya fue secuenciada anteriormente. Su objetivo es capturar información sobre polimorfismos de una base (SNPs), variaciones en el número de copias (CNVs) e inserciones y deleciones (indels) en el individuo de interés.

Siempre que exista un genoma de referencia disponible, conviene *mapear* en lugar de *ensamblar* desde cero, ya que el genoma de referencia aporta mucha información acumulada sobre el organismo de interés. El mapeo tiene ventajas claras:

- **Aprovecha el conocimiento previo**: en lugar de reconstruir un genoma completo desde cero, usamos como andamiaje un genoma ya anotado y estudiado, lo que acelera enormemente el análisis.

- **Permite detectar variantes con precisión**: al alinear cada lectura contra una posición conocida del genoma, podemos identificar puntualmente SNPs, indels y otras variantes respecto a la referencia.

- **Requiere asumir menos incertidumbre estructural**: a diferencia del ensamblado *de novo*, no necesitamos reconstruir la arquitectura completa del genoma. Sin embargo, sí asumimos que el organismo de referencia y el analizado comparten una arquitectura genómica similar, algo que no siempre se cumple.

En este tutorial vas a experimentar el flujo de trabajo completo: desde los datos crudos de secuenciación hasta la visualización de variantes genéticas reales.

---
## Proyecto:

*Chlamydia trachomatis* es uno de los patógenos humanos de mayor prevalencia en el mundo, capaz de causar una variedad de cuadros clínicos. Las cepas de transmisión sexual pueden subdividirse en aquellas restringidas al tracto intestinal y en tipos más invasivos, como el ***linfogranuloma venéreo*** o **LGV biovar**. A pesar de las diferencias en la severidad de la enfermedad, hay pocas diferencias genéticas entre las distintas cepas de *C. trachomatis*: como veremos a continuación, la mayoría de las variaciones ocurren a nivel de **SNPs**.

En este trabajo práctico vamos a mapear lecturas producidas con Illumina de una nueva variante de *Chlamydia trachomatis* llamada **NV**, aislada del tracto genital, y compararla con la cepa de referencia **L2** y con otra cepa conocida, **L2b**.

La cepa **NV** causó una alerta sanitaria en Europa en el año 2006 y comenzó a diseminarse alrededor del mundo. La causa de su expansión fue que evadía la detección del test diagnóstico basado en una reacción de PCR. A lo largo de este trabajo práctico vamos a identificar la razón por la cual esta cepa evadió el ensayo diagnóstico.

**Flujo de trabajo de secuenciación y mapeo:**

- **Laboratorio húmedo**: el ADN de la cepa NV de *C. trachomatis* se cliva en fragmentos mediante enzimas o sonicación. Con Illumina se secuencian entre 75 y 100 bases de ambos extremos de cada fragmento, generando lecturas pareadas (*paired-end reads*).
- **_In silico_**: se obtienen archivos en formato `FASTQ` con las secuencias de cada fragmento (lecturas o *reads*) y sus valores de calidad por base. Luego, cada lectura se alinea y mapea contra el genoma de referencia, generando un archivo en formato `SAM` que contiene la secuencia, la calidad y las coordenadas de cada fragmento respecto al genoma de referencia.

![Flujo](images/flow.png)

**En este tutorial**, nuestro objetivo será:

1. Evaluar la calidad de las lecturas crudas de secuenciación.
2. Mapear las lecturas de la cepa NV contra el genoma de referencia L2.
3. Visualizar el mapeo e identificar variantes genéticas (SNPs e indels).
4. Comparar la cepa NV con la cepa L2b para entender por qué NV evadió el diagnóstico por PCR.

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Preparación: cuenta en Galaxy</strong><br>

En este TP vamos a usar **Galaxy**, una plataforma web que permite realizar análisis de datos biológicos sin necesidad de usar la línea de comandos.

Para evitar saturar el servidor público de Galaxy, antes de empezar el TP:

1. Creá una cuenta gratuita en [usegalaxy.org](https://usegalaxy.org/).
2. Cargá los archivos `NV_1.fastq.gz`, `NV_2.fastq.gz`, `mapping.sam` y `L2_cat.fasta` (disponibles en la carpeta de materiales). Para esto, una vez logueados, hacé clic en **Upload Data** (arriba a la izquierda) y luego en **Choose local files**. Seleccioná los archivos y hacé clic en **Start upload**. Una vez cargados, vas a poder verlos en el panel de la izquierda.

📁 [Materiales](https://drive.google.com/drive/folders/1rHIb8dwkg5cDMfkGBVa7CqBde1MlfK5V?usp=sharing) &nbsp;&nbsp;|&nbsp;&nbsp; 📊 [Slides](https://docs.google.com/presentation/d/1YCPBpHr6XpacCGO2Ko3MoDxhwCaXGAgXUVZMPXoWd2g/edit?usp=sharing)
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 1: Formato FASTQ

Siempre que sea posible, es una buena práctica visualizar los archivos de trabajo. Para comenzar, vamos a leer los archivos crudos de secuenciación de *Chlamydia trachomatis*, que tienen formato `FASTQ`.

---
### Pasos a seguir:

1. Abrí una terminal y cambiá el directorio al que contiene los materiales del TP.
2. Leé la primera línea del archivo `NV_1.fastq.gz` con el siguiente comando:

```bash
zcat NV_1.fastq.gz | head -4
```

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Estructura de un archivo FASTQ</strong><br>

Cada lectura ocupa 4 líneas:

- **1ra línea**: nombre de la lectura secuenciada, por ejemplo `IL7_1788:5:1:34:600/1`. Contiene la siguiente información:

| Elemento | Descripción |
| :---: | :---: |
| IL7_1788 | ID del instrumento y número de corrida |
| 5 | *flowcell lane* o carril |
| 1 | *tile* o casilla en la *flowcell lane* |
| 34 | coordenada 'x' |
| 600 | coordenada 'y' |
| /1 | sentido de la secuenciación |

![Flowcell](images/illumina_flowcell.png)

- **2da línea**: la secuencia.
- **3ra línea**: `+`, separador entre la secuencia y la calidad.
- **4ta línea**: calidad de la secuencia. Hay un carácter por cada nucleótido, asociado a un puntaje de calidad codificado según el código decimal [ASCII](https://elcodigoascii.com.ar/), donde la calidad se define como ese número menos 33. Esto se relaciona con la probabilidad de error (P) de la base asignada:

$$
Q = -10 \log_{10} P
$$

o bien:

$$
P = 10^{\frac{-Q}{10}}
$$

`(N° ASCII - 33) = calidad`

El número que representa la calidad va de 33 (calidad más baja, `!` en ASCII) a 126 (calidad más alta, `~` en ASCII). Estos son los caracteres de valor de calidad en orden creciente de izquierda a derecha:

```
 !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~
```
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 1</strong><br>

Identificá los componentes de la primera lectura del archivo `NV_1.fastq.gz`: nombre, secuencia, calidad y ubicación física de la lectura en la celda de flujo (lane, tile, x, y).
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 2</strong><br>

Usando el código [ASCII](https://elcodigoascii.com.ar/), determiná la calidad de las primeras 3 bases secuenciadas.
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 3</strong><br>

Leé la primera lectura del archivo `NV_2.fastq.gz`. ¿Qué similitudes y diferencias encontrás en **cada una** de las líneas de texto respecto a `NV_1.fastq.gz`? ¿A qué se deben?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 2: Control de calidad con FastQC

Dado que la secuenciación de segunda generación tiene una mayor tasa de error que la de primera generación (Sanger), es importante revisar la calidad de nuestras lecturas antes de continuar. Explorar y entender las características de los datos crudos nos da confianza en los análisis posteriores.

---
### FastQC

FastQC analiza los datos crudos y genera gráficas y tablas que muestran la calidad global de la secuenciación, permitiendo identificar problemas en distintos aspectos de los datos.

![fastQC](images/fastqc.png)

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Aspectos a evaluar en un reporte de FastQC</strong><br>

- **Calidad de secuencia por base**: indicador global que muestra la distribución de calidad (Phred score, eje y) por posición en la lectura (eje x). Los Phred scores por encima de 30 suelen considerarse de buena calidad en Illumina. Debería mantenerse, en líneas generales, dentro de la zona verde, aunque no hay que preocuparse si cae abruptamente en lecturas muy largas.
- **Calidad de secuencia según posición en la flowcell**: permite detectar problemas en regiones físicas específicas del secuenciador, como la formación de burbujas.
- **Contenido de base por secuencia**: la frecuencia de cada nucleótido debería ser más o menos constante a lo largo de la lectura (líneas horizontales paralelas).
- **Contenido de GC por secuencia**: permite identificar contaminaciones. Un perfil de GC que no se ajusta a una distribución normal podría indicar contaminantes.
- **Contenido de N por base**: el carácter **N** indica que la secuenciación no pudo asignar un nucleótido. Un exceso indica problemas.
- **Niveles de duplicación de secuencia**: duplicaciones excesivas pueden sugerir artefactos de la librería o de la PCR de amplificación.
- **Contenido de adaptadores**: presencia de adaptadores propios de la tecnología de secuenciación, que deben removerse antes de mapear.
</div>

### Pasos a seguir:

1. En **Galaxy**, buscá el programa **FastQC** en el panel **All Tools** (izquierda).
2. Seleccioná el programa y, en **FASTQ file**, cargá el archivo `NV_1.fastq.gz`. Dejá las demás opciones como están y hacé clic en **Run**.
3. Repetí los mismos pasos para el archivo `NV_2.fastq.gz`.

![fastqc-galaxy](images/fastqc-galaxy.png)

Cuando los trabajos se hayan ejecutado correctamente, van a aparecer en verde en el panel de la derecha. Cada análisis genera un archivo de datos crudos (`.raw`) y un archivo `.html`, que es el reporte a analizar. Hacé clic en el ícono del ojo para abrir cada reporte.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 4</strong><br>

¿Qué opinás de la calidad de los datos? ¿Continuarías trabajando con ellos? Compará con [este ejemplo](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/bad_sequence_fastqc.html) y justificá tu decisión.
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 3: Mapeo de secuencias al genoma de referencia

El formato **SAM** (*Sequence Alignment Map*) es un formato estandarizado para guardar secuencias de nucleótidos alineadas (más información en la [especificación SAM](https://samtools.github.io/hts-specs/SAMv1.pdf)). El formato **BAM** es su equivalente binario y comprimido, desarrollado para aumentar la velocidad en procesamientos intensivos de datos.

---

<div style="border-left: 6px solid  #6f42c1; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>¿Cómo se crea el archivo SAM? (¡No ejecutar, es de muestra!)</strong><br>

Ustedes **no** deben ejecutar los siguientes comandos: el resultado ya está disponible en su directorio de trabajo. Se muestran solo para entender el proceso, o por si quieren reproducir el análisis con secuencias propias más adelante.

El software para mapear las lecturas es BWA:

```bash
# NO ejecutar
sudo apt install bwa
```

La secuencia de referencia para este ejercicio es la cepa LGV de *C. trachomatis*, llamada **L2**, en el archivo `L2_cat.fasta` (contiene concatenadas la secuencia del genoma y de un plásmido). Antes de mapear, hay que indexar la referencia:

```bash
# NO ejecutar
bwa index L2_cat.fasta
```

Y luego mapear las lecturas crudas con el algoritmo BWA-MEM:

```bash
# NO ejecutar
bwa mem L2_cat.fasta NV_1.fastq.gz NV_2.fastq.gz > mapping.sam
```

En **Galaxy**, el programa de mapeo equivalente es **BWA-MEM2**, y el que construye el índice es **BWA-MEM2 indexer**.
</div>

### Pasos a seguir:

1. Revisá de qué se trata el archivo `.sam` abriéndolo en Galaxy, o visualizando las primeras líneas por consola:

```bash
head mapping.sam
```

![sambam](images/sambam.png)

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 5</strong><br>

¿Podés identificar las distintas partes del archivo SAM (mostradas en la imagen anterior)?
</div>

2. Convertí el alineamiento de formato SAM a formato BAM usando `Samtools view` en Galaxy. Seleccioná el archivo `mapping.sam` como entrada, dejá las demás opciones como están y hacé clic en **Run**.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 6</strong><br>

Comparen el tamaño de los archivos SAM y BAM y determinen el factor de compresión.
</div>

3. Ordená las lecturas mapeadas por cromosoma y/o coordenada con `Samtools sort` en Galaxy. Seleccioná el archivo `mapping.bam` como entrada, dejá las demás opciones como están y hacé clic en **Run**.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 7</strong><br>

¿Por qué las secuencias no están ordenadas y tenemos que ordenarlas en un paso adicional?
</div>

`Samtools sort` genera dos archivos: uno con extensión `.bam` y otro con extensión `.bai` (un índice que permite acceder rápidamente a las posiciones del `.bam`). Si quisieran indexar el `.bam` por consola, el comando sería:

```bash
# NO es necesario correr esto
samtools index NV.bam
```

4. Descargá los archivos `.bam` (el dataset) y `.bai` (el índice) a tu computadora: hacé clic en el resultado de `Samtools sort` y luego en el símbolo de guardar. Renombralos como `NV.bam` y `NV.bai`.

![download](images/samtools1.png) ![download2](images/samtools2.png)

<div style="page-break-after: always;"></div>

## Ejercicio 4: Visualización de secuencias mapeadas

JBrowse2 permite visualizar datos de secuenciación de tecnologías de nueva generación como Illumina, 454 o Solid. Se puede descargar e instalar desde la [página oficial](https://jbrowse.org/jb2/download/).

---
### Instalación de JBrowse2

1. Dentro de la carpeta de materiales, vas a encontrar el ejecutable `jbrowse-desktop-v3.6.5-linux.AppImage` y dos archivos `.sh`.
2. Abrí una terminal, cambiá el directorio a la carpeta donde se encuentra este archivo, y ejecutá los siguientes scripts para dar permisos de ejecución y abrir la aplicación:

```bash
bash instalar_jbrowse.sh
bash ejecutar_jbrowse.sh
```

### Exploración de la vista básica

1. Abrí JBrowse2 y cargá la secuencia de referencia `L2_cat.fasta`: hacé clic en `OPEN SEQUENCE FILE(S)` y seleccioná el archivo. En `assembly name` elegí un nombre representativo, y en `Type` elegí `FastaAdapter`.
2. Presioná `submit`, elegí `Linear genome view` y luego `LAUNCH VIEW`.
3. La ventana va a mostrar dos entradas del multifasta: una para el ADN cromosomal y otra para el ADN plasmídico. Para ver ambas a la vez, seleccioná `SHOW ALL REGIONS IN ASSEMBLY`.

![jbrowse-view](images/JBROWSE_1.jpg)

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Componentes de la interfaz</strong><br>

- **Barra de herramientas** (menúes desplegables arriba): acceso a abrir archivos, agregar tracks, descargar *plugins*, etc.
- **Tracks cargados**: en `OPEN TRACK SELECTOR` (botón azul abajo) podés ver los tracks disponibles y elegir cuál visualizar. Asegurate de que `Reference sequence (l2_cat)` esté tildado.
- **Panel de visualización principal**: muestra la secuencia de referencia, con las hebras positiva y negativa representadas por líneas, los marcos de lectura, codones stop, y características (genes, dominios) como cajas coloreadas.
- **Desplazarse y hacer zoom**: el deslizador horizontal permite moverse a lo largo de la secuencia. Al hacer zoom se pueden ver las bases de ambas hebras y los residuos en los seis marcos de lectura.
</div>

### Carga de anotaciones y del mapeo

1. Abrí los archivos de anotación `L2_genomic.gff` y `L2_plasmid.gff3`: desde `Available tracks`, hacé clic en <kbd>+</kbd> `Add track`, cargá el archivo en `Main file`, presioná `Next`, elegí `GFF3` en `Adapter type`, dejá el resto por defecto y presioná `ADD`. Repetí para ambos archivos.
2. Cargá el mapeo de lecturas en formato BAM: desde `Available tracks`, hacé clic en <kbd>+</kbd> `Add track` y abrí `NV.bam`. En `Index file` cargá el `.bai` descargado de Galaxy. Presioná `Next`, elegí `BAM adapter` en `Adapter type`, dejá el resto por defecto y presioná `ADD`.

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
Recordá que estas lecturas son de la cepa **NV** mapeadas contra el genoma de referencia de la cepa **L2**.
</div>

Ahora deberías ver las lecturas en la parte inferior de la pantalla principal:

![JBrowse2](images/JBROWSE_2.jpg)

Por defecto, la vista de las lecturas tiene dos secciones:

- **Sección superior**: profundidad de cobertura de las lecturas en cada posición del genoma, con líneas de colores marcando discrepancias entre el genoma leído y el de referencia.
- **Sección inferior**: lecturas apiladas, que también muestran discrepancias de base con líneas de colores.

Si querés más información sobre una lectura, hacé clic sobre ella: vas a ver a la derecha una ventana con `Feature details` (posición, nombre, largo, secuencia, calidad de cada base, entre otras).

### Calidad de mapeo

La calidad de mapeo depende de la precisión de la lectura y del número de *mismatches* respecto a la secuencia de referencia. Un valor de 0 indica que la lectura mapea igual de bien en al menos otro lugar, por lo que **su mapeo no es confiable**. El valor máximo posible de *Mapping quality* es 60.

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
JBrowse2 no permite (por el momento) definir un intervalo de valores directamente en la interfaz. Si querés quedarte con lecturas entre dos valores de calidad, podés filtrar el archivo `NV.bam` por consola.
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 8</strong><br>

Según tus conocimientos de biología y bioinformática, ¿qué aspectos considerás que podrían influir en la calidad de mapeo?
</div>

### Modalidades de visualización de archivos BAM

JBrowse2 tiene varias modalidades de visualización para archivos BAM. Para explorarlas, hacé clic en los tres puntos del panel BAM y seleccioná `Display types`:

- **'Alignments display (combination)'** (vista por defecto): combina la cobertura y las lecturas sobre la secuencia. A mayor cobertura, mayor confianza en la detección de variantes.
- **'Pileup display'**: simplificación de la anterior, donde solo se muestran las lecturas.
- **'SNPCoverage display'**: muestra la frecuencia de cada nucleótido y, si no coincide con la referencia, la colorea. Una columna completamente coloreada indica un SNP real (no un error de secuenciación, ya que todas las lecturas presentan la misma variación).
- **'Arc display'**: muestra la relación entre lecturas pareadas mapeadas en posiciones diferentes del genoma de referencia, conectadas por un arco. Útil para detectar lecturas no alineadas de forma esperada (posibles variaciones estructurales, problemas de ensamblado, etc.).
- **'Read cloud display'**: similar a 'Arc display', pero usa etiquetas de ciertos tipos de secuenciación. Es especialmente útil para detectar variaciones estructurales.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 9</strong><br>

¿Por qué podrían generarse lecturas duplicadas? ¿Todas las lecturas duplicadas son útiles?
</div>

### Comparando vistas y explorando el plásmido

1. Creá una copia del track seleccionando `Copy track` en los tres puntos del panel de `NV.bam` (si no se activa un nuevo track, verificá que esté tildado en `Available Tracks`).
2. Seleccioná la vista `Read cloud display` en un panel `bam` y `Pileup display` en el otro.
3. Posicionate en la secuencia `AM886278.1` (el ADN plasmídico), ya sea escribiéndola o seleccionándola desde el panel junto al zoom. Compará la cobertura del plásmido con la región genómica de **NV**.

![inferredsize](images/JBROWSE_3.jpg)

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 10</strong><br>

a) ¿Qué aspectos considerás que pueden influir en la cobertura, en general y en este caso en particular?

b) A simple vista, ¿notás alguna región diferente?
</div>

4. Copiá y pegá lo siguiente en el selector de secuencias: `AM886278.1:5,000..6,000`. Esto va a mostrar las **posiciones 5000 a 6000** de la secuencia `AM886278.1`.

![cover](images/JBROWSE_4.jpg)

Vas a observar que no hay lecturas alineadas sobre esa región, y que las lecturas adyacentes están conectadas entre sí (también visible con 'Arc display'). Esto es indicativo de una **deleción** en la cepa secuenciada respecto a la referencia.

### Visualización de múltiples archivos BAM

También se pueden visualizar varios archivos BAM al mismo tiempo. Recordá que un archivo BAM es un grupo procesado de lecturas alineadas de un organismo contra una secuencia de referencia, así que en principio podríamos observar distintos aislamientos bacterianos mapeados contra la misma referencia.

Vamos a incluir ahora la cepa **L2b** de *C. trachomatis*, filogenéticamente más cercana a la cepa de referencia que la que analizamos hasta el momento (de ahí el nombre similar).

1. No es necesario repetir el mapeo: ya procesamos los datos crudos por ustedes. El archivo se llama `L2b.bam`.
2. Para cargarlo, andá a `Track selector`, presioná <kbd>+</kbd> y cargá el archivo. Recordá que el tipo es `Bam adapter`; dejá el resto de las opciones por defecto.
3. Volvé a la región no mapeada que analizaste antes (posiciones 5000 a 6000) y compará los distintos tipos de visualización entre ambas cepas.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 11</strong><br>

Volvé a leer en la sección "Proyecto" la razón por la cual la cepa **NV** causó una alerta sanitaria en Europa en 2006. Considerando lo que acabamos de ver, ¿por qué creés que la cepa **NV** no es detectada por el ensayo diagnóstico estándar, pero sí lo es la cepa **L2b**?
</div>

![cover](images/JBROWSE_5.jpg)

<div style="page-break-after: always;"></div>

## Ejercicio 5: Detección de variantes (SNP e indel)

Volvamos a la visualización de lecturas apiladas (**Pileup display**).

---
### Analizando SNPs

Observá las distintas líneas de colores que aparecen en algunas lecturas: representan los SNPs respecto a la referencia, y el color corresponde a la base presente en la lectura (C = celeste, G = naranja, T = rojo, A = verde, N = gris). Algunos SNPs están presentes en todas las lecturas, formando líneas verticales de color; otros se distribuyen más esporádicamente. Los primeros tienen mayor probabilidad de ser SNPs verdaderos, mientras que los segundos suelen ser errores de secuenciación.

![snips](images/JBROWSE_6.jpg)

Si acercás la visualización al máximo, podés observar las bases que difieren de la referencia con su color correspondiente.

![snips](images/JBROWSE_7.jpg)

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
Muchos SNPs son bastante claros, pero esto no siempre es así. ¿Qué pasa si la profundidad de lecturas es muy baja? Si solo hay dos lecturas mapeando en un sector, la referencia es T y ambas lecturas son C, ¿es evidencia suficiente para decir que hay un SNP? ¿Y si hay 100 lecturas mapeando una región y 50 tienen G y 50 tienen T en una posición particular? ¿Es un SNP? También podría tratarse de una coinfección o de una variación en un genoma diploide.
</div>

### Calculando los SNPs con más precisión

Hasta ahora vimos la variación como un grupo simple y homogéneo de SNPs. En realidad, se necesita más información para entender el efecto que un cambio en la secuencia puede tener, por ejemplo, en la capacidad codificante. Para eso usamos el formato **"variant call format" (VCF)**, que tiene su versión comprimida, **"binary variant call format" (BCF)**.

El formato VCF fue desarrollado para representar datos de variación del proyecto 1000 Genomas Humanos, y ya es ampliamente aceptado como el formato estándar para *SNP calling*.

### Generando el archivo VCF y BCF

Vamos a generar el archivo VCF a partir de `NV.bam` y visualizarlo en JBrowse2:

1. Para crear el archivo BCF, usá `bcftools mpileup` en Galaxy. Seleccioná el archivo `.bam` como entrada, en `Reference genome` seleccioná el archivo `L2_cat.fasta` (elegí `history` en el primer panel), dejá el resto por defecto y hacé clic en **Run Tool**.
2. Para crear el archivo VCF, buscá `bcftools call` en Galaxy. Seleccioná el `.bcf` generado en el paso anterior como entrada:
   - En `Consensus/variant calling options` → `Calling method`, elegí **Consensus caller**.
   - En `File format Options` → `Select predefined ploidy`, elegí **1 - Treat all samples as haploid** (estamos trabajando con una bacteria).
   - En `Input/Output options`, marcá `Output variant sites only` como `Yes`.
   - En `output_type`, elegí `uncompressed VCF`.
   - Hacé clic en **Run Tool**.
3. Una vez terminado, corré `VCFsort` usando como input el archivo `.vcf`. Descargá el archivo ordenado a tu computadora y renombralo como `NV.vcf`.
4. Visualizá el resultado con:

```bash
head -n 100 NV.vcf
```

5. Cargá el archivo VCF en JBrowse2: andá a `Track selector`, presioná <kbd>+</kbd> y cargá `NV.vcf`. Presioná `Next` y verificá que en `Adapter type` diga **VCF adapter**.
6. Para ver una región con variación genética interesante, andá al gen `CTL0578` (ADN cromosomal, posiciones 684021 a 685991).

![variants](images/JBROWSE_8.png)

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 12</strong><br>

¿Qué tipos de variantes podés identificar en el gen CTL0578?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 6: Comparando cepas (adicional)

En el directorio de trabajo tenés el archivo BAM de la cepa **L2b**. Con los comandos que ya usaste, calculá las variantes de esta cepa respecto al genoma de referencia L2.

---
### Pasos a seguir:

1. Generá el archivo VCF de la cepa L2b siguiendo el mismo procedimiento del Ejercicio 5 (`bcftools mpileup` → `bcftools call` → `VCFsort`).
2. Agregá el VCF resultante a la vista de JBrowse2, de la misma manera que hiciste con la cepa NV.
3. Compará ambas cepas (NV y L2b) en el visualizador.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 13</strong><br>

¿Qué cepa tiene mayor cantidad de variantes? ¿Por qué?
</div>

---
## Cierre:
1. ¿Qué tipo de experimentos hicimos hoy?
2. Completá la tabla con los temas vistos hoy:

| Tema | Algoritmo | Tipo de datos | Base de datos | Análisis del resultado |
| :--- | :--- | :--- | :--- | :--- |
| (completar) | (completar) | (completar) | (completar) | (completar) |

3. ¿Cumpliste con los objetivos del tutorial?

| Objetivo | ¿Se cumplió? |
| :--- | :--- |
| 1. Interpretar los formatos utilizados comúnmente en NGS. | Sí / No |
| 2. Mapear secuencias al genoma de referencia. | Sí / No |
| 3. Visualizar e interpretar alteraciones genéticas. | Sí / No |

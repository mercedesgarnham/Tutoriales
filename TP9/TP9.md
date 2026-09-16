
# TP9: Detección de variantes — SNVs, InDels y variantes estructurales (SVs)

En este tutorial vamos a aprender a detectar, filtrar, anotar y visualizar variantes genéticas a partir de datos de secuenciación de nueva generación (NGS), trabajando con dos casos reales: una enfermedad rara causada por una variante puntual y un tumor con reordenamientos cromosómicos complejos.

## Objetivos
1. Alinear lecturas de secuenciación contra un genoma de referencia y evaluar la calidad del alineamiento.

2. Detectar variantes puntuales (SNVs) e inserciones/deleciones (InDels), y filtrarlas según criterios de calidad.

3. Anotar y priorizar variantes candidatas en un caso de enfermedad rara.

4. Detectar, filtrar y visualizar variantes estructurales (SVs) germinales y somáticas en una muestra tumoral.

---

## Uso de la detección de variantes en bioinformática

Detectar variantes genéticas a partir de datos de secuenciación es uno de los pilares de la genómica clínica y de investigación. No alcanza con alinear las lecturas al genoma de referencia: hay que evaluar la calidad de esos datos, decidir qué diferencias respecto a la referencia son variantes reales y cuáles son errores técnicos, y finalmente interpretar el significado biológico de esas variantes.

Esto es así por varias razones:

- **La calidad de los datos condiciona todo el análisis**: métodos basados en lecturas pareadas se ven afectados por distribuciones de tamaño de inserto sesgadas, los métodos de profundidad de lectura por coberturas desparejas, y los métodos de *split-read* por altas tasas de error de secuenciación. Por eso siempre conviene hacer control de calidad antes de buscar variantes.

- **No todas las variantes son del mismo tipo**: existen variantes puntuales (SNVs), pequeñas inserciones/deleciones (InDels) y variantes estructurales de gran escala (SVs, como deleciones, duplicaciones, inversiones y translocaciones). Cada tipo requiere herramientas y estrategias de detección distintas.

- **La anotación y el filtrado son tan importantes como la detección**: un pipeline de llamado de variantes puede generar miles de candidatos. Usar información de calidad, frecuencia poblacional, efecto funcional y modelo de herencia permite reducir ese número a un puñado de variantes realmente relevantes.

En este tutorial vas a recorrer un flujo de trabajo completo, desde los datos crudos de secuenciación hasta la validación de una variante causante de enfermedad, y desde la detección de variantes estructurales hasta la reconstrucción de un evento de cromotripsis.

---
## Proyecto:

Vamos a trabajar con dos casos genómicos reales, ambos anonimizados y submuestreados para acelerar los análisis.

**Caso 1 — Enfermedad rara (SNVs e InDels):** un bebé de padres consanguíneos que padeció una inmunodeficiencia combinada grave. Vamos a mapear sus lecturas de secuenciación contra el cromosoma 7 humano (`chr7`), detectar variantes, filtrarlas y anotarlas para intentar identificar la mutación causante de la enfermedad, y finalmente validarla con secuenciación Sanger.

**Caso 2 — Cromotripsis en una muestra tumoral (SVs):** una muestra de cáncer que presenta ***cromotripsis***, un fenómeno en el que un cromosoma sufre decenas de rupturas y reordenamientos en un único evento catastrófico. Vamos a comparar el genoma tumoral (`tumor.bam`) contra el genoma control (`control.bam`) del mismo paciente, ambos filtrados al cromosoma 2 (`chr2`), para detectar variantes estructurales germinales y somáticas.

**En este tutorial**, nuestro objetivo será:

1. Preparar el entorno de trabajo y las herramientas necesarias.
2. Indexar el genoma de referencia y alinear las lecturas crudas.
3. Controlar la calidad del alineamiento y marcar lecturas duplicadas.
4. Llamar, filtrar, anotar y validar variantes puntuales en el caso de enfermedad rara.
5. Controlar la calidad, detectar, filtrar y visualizar variantes estructurales en la muestra tumoral.

<div style="page-break-after: always;"></div>

## Ejercicio 1: Preparar el entorno de trabajo

Antes de empezar necesitamos instalar las herramientas de línea de comandos que vamos a usar a lo largo de todo el tutorial, y descargar los datos del curso.

---

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Herramientas que vamos a usar</strong><br>

- **BWA**: alineador de lecturas cortas contra un genoma de referencia.
- **SAMtools**: manipulación de archivos SAM/BAM (ordenar, indexar, filtrar, ver estadísticas).
- **bedtools**: operaciones sobre intervalos genómicos (archivos BED).
- **Alfred**: cálculo de estadísticas de calidad de alineamiento (cobertura, tamaño de inserto, etc.).
- **FreeBayes / bcftools**: llamado, filtrado y consulta de variantes (formato VCF/BCF).
- **Delly**: detección de variantes estructurales (SVs).
- **wally / IGV**: visualización de alineamientos y variantes estructurales.
- **VEP**: anotación funcional de variantes.
- **Primer3Plus / Silica / Verdin / Indigo**: diseño de primers y análisis de trazas Sanger para validación de variantes.
</div>

### Pasos a seguir:

1. Instalá las librerías necesarias (el paquete depende de tu distribución de Linux; en Ubuntu):

```bash
apt-get update
apt-get install -y autoconf build-essential cmake g++ git libcurl4-gnutls-dev libbz2-dev libdeflate-dev libgl1-mesa-dev libncurses-dev liblzma-dev pkg-config zlib1g-dev
```

2. Cloná el repositorio del curso e instalá todas las dependencias con mamba:

```bash
git clone --recursive https://github.com/tobiasrausch/vc
cd vc
make all
```

3. Descargá los datos del curso:

```bash
make FILE=1nxzjQFt33ch1P_nWF66q1tkHv5gxTaKb download
```

4. Cargá el entorno de mamba con todas las herramientas necesarias:

```bash
if [ ! -z ${CONDA_PREFIX+x} ]; then conda deactivate; fi
export PATH=`pwd`/mamba/bin:${PATH}
```

<div style="page-break-after: always;"></div>

## Ejercicio 2: Indexado del genoma de referencia

Antes de poder mapear lecturas, tenemos que indexar el genoma de referencia. Vamos a trabajar con el caso de enfermedad rara, usando el cromosoma 7 humano (`chr7`).

---

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>¿Por qué indexar?</strong><br>

BWA usa un índice FM (*FM-Index*), construido a partir de la [transformada de Burrows-Wheeler](https://es.wikipedia.org/wiki/Transformada_de_Burrows-Wheeler), que permite alinear millones de lecturas contra el genoma de referencia de forma muy eficiente. SAMtools, por su parte, usa un índice `.fai` que permite extraer rápidamente subsecuencias de un archivo FASTA sin tener que leerlo completo.
</div>

### Pasos a seguir:

1. Ubicate en la carpeta de datos del caso de enfermedad rara e indexá el genoma de referencia con BWA:

```bash
cd /data/rd/
bwa index chr7.fa
ls -rt1 chr7.fa*
```

2. Indexá también el archivo FASTA con SAMtools:

```bash
samtools faidx chr7.fa
```

3. Extraé 50 pb a partir de la posición 10017:

```bash
samtools faidx chr7.fa chr7:10017-10067
```

4. Con `bedtools`, creá un archivo BED con el inicio y fin del cromosoma, y calculá su contenido de nucleótidos:

```bash
bedtools makewindows -g <(cut -f 1,2 chr7.fa.fai) -n 1 > chr7.bed
bedtools nuc -fi chr7.fa -bed chr7.bed
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 1</strong><br>

¿Cuál es la longitud de `chr7`?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 2</strong><br>

¿Cuál es el contenido de GC de `chr7`?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 3</strong><br>

¿Cuál es la proporción de Ns en `chr7`?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 3: Alineamiento de lecturas

Con el índice ya construido, podemos mapear las lecturas pareadas en formato `FASTQ` contra la referencia y convertir el resultado a formato `BAM`.

---
### Pasos a seguir:

1. Alineá las lecturas pareadas contra `chr7` y convertí directamente el resultado a BAM:

```bash
bwa mem chr7.fa read1.fq.gz read2.fq.gz | samtools view -bT chr7.fa - > rd.bam
```

2. Revisá el encabezado y los primeros registros del alineamiento:

```bash
samtools view -H rd.bam
samtools view rd.bam | head
```

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Formato BAM</strong><br>

Cada registro de alineamiento tiene los siguientes campos obligatorios:

| Col | Campo | Descripción |
|:---:|:---|:---|
| 1 | QNAME | Nombre de la lectura (*query template name*) |
| 2 | FLAG | *Flag* en formato binario |
| 3 | RNAME | Nombre de la secuencia de referencia |
| 4 | POS | Posición de mapeo más a la izquierda (base 1) |
| 5 | MAPQ | Calidad de mapeo |
| 6 | CIGAR | Cadena CIGAR |
| 7 | RNEXT | Nombre de referencia de la mate/siguiente lectura |
| 8 | PNEXT | Posición de la mate/siguiente lectura |
| 9 | TLEN | Largo observado del template |
| 10 | SEQ | Secuencia del segmento |
| 11 | QUAL | Calidad en ASCII (Phred + 33) |

El FLAG binario se puede decodificar con la herramienta [explain flag](https://broadinstitute.github.io/picard/explain-flags.html) de Picard.
</div>

3. Ordená el alineamiento e indexalo para permitir el acceso aleatorio a las lecturas:

```bash
samtools sort -o rd.srt.bam rd.bam
samtools index rd.srt.bam
```

<div style="page-break-after: always;"></div>

## Ejercicio 4: Marcado de duplicados y control de calidad

A menos que se use una librería libre de PCR, es común encontrar duplicados de PCR en datos de secuenciación de ADN, y hay que marcarlos antes de llamar variantes.

---
### Pasos a seguir:

1. Marcá los duplicados de PCR:

```bash
bammarkduplicates I=rd.srt.bam O=rd.rmdup.bam M=rd.metrics.tsv index=1 rmdup=0
```

2. Calculá estadísticas básicas de alineamiento (lecturas correctamente apareadas, *singletons*, etc.):

```bash
samtools flagstat rd.rmdup.bam
```

3. Usá `Alfred` para calcular la distribución del tamaño de inserto, la distribución de cobertura y las tasas de error de alineamiento:

```bash
alfred qc -r chr7.fa rd.rmdup.bam
```

4. El archivo de salida tiene varias secciones; la mayoría son matrices de datos para gráficos, pero también hay una sección con métricas resumen:

```bash
zcat qc.tsv.gz | grep ^ME | datamash transpose | column -t
```

5. Generá los gráficos de control de calidad con el script de R de Alfred, y convertí el PDF resultante a imágenes PNG:

```bash
Rscript /opt/alfred/R/stats.R qc.tsv.gz
convert qc.tsv.gz.pdf qc.png
# Distribución de contenido de bases
open qc-0.png
# Distribución de calidad de bases
open qc-1.png
# Cobertura
open qc-4.png
# Tamaño de inserto
open qc-5.png
```

6. Para el llamado de variantes exónicas nos interesa especialmente la distribución de cobertura sobre los exones. El archivo `exons.bed.gz` contiene las regiones codificantes CCDS para hg19; hay que restringirlo a la porción de `chr7` que estamos usando:

```bash
zcat exons.bed.gz | head
bedtools intersect -a <(zcat exons.bed.gz) -b chr7.bed | gzip -c > exons.chr7.bed.gz
zcat exons.chr7.bed.gz | head
```

7. Con las coordenadas exónicas, calculá la cobertura promedio por región blanco:

```bash
alfred qc -r chr7.fa -b exons.chr7.bed.gz rd.rmdup.bam
Rscript /opt/alfred/R/stats.R qc.tsv.gz
convert qc.tsv.gz.pdf qc.png
# Distribución de cobertura en exones
open qc-10.png
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 4</strong><br>

¿Cuál es la cobertura mediana del set de datos?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 5</strong><br>

¿Qué significan los distintos *library layouts* (F+, F-, R+, R-)?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 6</strong><br>

¿Cuál es la fracción de duplicados en la librería?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 7</strong><br>

¿Tendría sentido secuenciar esta librería más profundamente para alcanzar 30x de cobertura?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 5: Llamado de variantes puntuales (SNVs)

Una vez que el alineamiento está ordenado y los duplicados marcados, podemos correr un llamador de variantes como **FreeBayes** para buscar diferencias respecto a la referencia.

---
### Pasos a seguir:

1. Llamá variantes con FreeBayes:

```bash
freebayes --fasta-reference chr7.fa -b rd.rmdup.bam -v snv.vcf
```

2. Comprimí e indexá el VCF resultante, para acelerar el acceso aleatorio al archivo:

```bash
bgzip snv.vcf
tabix snv.vcf.gz
```

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Formato VCF</strong><br>

El formato [VCF](https://samtools.github.io/hts-specs) tiene varias líneas de encabezado que empiezan con `#`, seguidas de un registro por cada variante:

| Col | Campo | Descripción |
|:---:|:---|:---|
| 1 | CHROM | Nombre del cromosoma |
| 2 | POS | Posición (base 1). Para un indel, es la posición previa al indel. |
| 3 | ID | Identificador de la variante (generalmente el rsID de dbSNP). |
| 4 | REF | Secuencia de referencia en esa posición. Para un SNP, es una única base. |
| 5 | ALT | Lista de secuencias alternativas, separadas por comas. |
| 6 | QUAL | Probabilidad Phred de que todas las muestras sean homocigotas para la referencia. |
| 7 | FILTER | Lista de filtros que la variante no supera. |
| 8 | INFO | Información adicional sobre la variante. |
| 9 | FORMAT | Formato de los campos de genotipo de cada muestra. |
| 10+ | Muestras | Información de genotipo de cada muestra, según el campo FORMAT. |
</div>

3. Mirá el encabezado y el primer registro del VCF:

```bash
bcftools view snv.vcf.gz | grep "^#" -A 1
```

4. Generá estadísticas resumen, como la [relación transición/transversión](https://es.wikipedia.org/wiki/Transversi%C3%B3n):

```bash
bcftools stats snv.vcf.gz | grep "TSTV"
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 8</strong><br>

¿Cuántos SNPs se llamaron? (pista: `bcftools stats`, tag SN)
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 9</strong><br>

¿Cuántos InDels se llamaron? (pista: `bcftools stats`, tag SN)
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 10</strong><br>

¿Cuántas mutaciones C>T se llamaron? (pista: `bcftools stats`, tag ST)
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 6: Filtrado de variantes

En la mayoría de las aplicaciones se usan datos de referencia externos ("ground truth") para calibrar un pipeline de llamado de variantes. Como en este caso no contamos con eso, vamos a ilustrar algunas opciones de filtrado basadas en estadísticas resumen, como la relación transición/transversión. En humanos se espera una relación cercana a 2.

---
### Pasos a seguir:

1. Compará la relación TS/TV sin filtrar y aplicando distintos filtros de calidad:

```bash
bcftools stats snv.vcf.gz | grep "TSTV"
bcftools filter -i '%QUAL>20' snv.vcf.gz | bcftools stats | grep "TSTV"
bcftools filter -e '%QUAL<=20 || %QUAL/INFO/AO<=2 || SAF<=2 || SAR<=2' snv.vcf.gz | bcftools stats | grep "TSTV"
```

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
Otra métrica útil es el largo de los indels en regiones exónicas, ya que la mayoría de los polimorfismos tipo InDel deberían mantener el marco de lectura (*in-frame*). En estudios poblacionales con cientos de muestras, la [heterocigosidad](https://es.wikipedia.org/wiki/Cigosis) también es una métrica útil. En nuestro caso de una sola muestra, vamos a usar una estrategia simple de filtrado por umbral para quedarnos con las variantes exónicas.
</div>

2. Filtrá el VCF para quedarte solo con las variantes exónicas de buena calidad:

```bash
bcftools filter -O z -o exon.vcf.gz -R <(zcat exons.bed.gz) -e '%QUAL<=20 || %QUAL/INFO/AO<=2 || SAF<=2 || SAR<=2' snv.vcf.gz
bcftools stats exon.vcf.gz | egrep "^SN|TSTV"
```

3. `SAMtools` incluye un visor de alineamientos básico llamado `tview`, útil para revisar variantes manualmente en los datos crudos. Por ejemplo, para ver las primeras dos variantes exónicas:

```bash
bcftools view exon.vcf.gz | grep "^#" -A 2
samtools tview -d t -p chr7:299825 rd.rmdup.bam chr7.fa
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 11</strong><br>

¿Las primeras dos variantes exónicas son homocigotas o heterocigotas?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 12</strong><br>

¿Cuál es el genotipo y la profundidad alélica que FreeBayes reporta para ambas variantes?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 13</strong><br>

Revisá manualmente ("spot-check") algunas variantes heterocigotas usando `samtools tview`.
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 14</strong><br>

Graficá la distribución de largos de los InDels llamados (pista: `bcftools stats`, tag IDD).
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 7: Anotación de variantes

Anotar y clasificar variantes es un proceso desafiante.

---

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Fuentes de información para anotar variantes</strong><br>

- Anotaciones de transcriptos de Ensembl, UCSC o RefSeq.
- Herramientas de predicción de daño funcional, como PolyPhen, MutationTaster o SIFT.
- Información de frecuencia alélica poblacional de bases de datos como 1000 Genomes, ExAC o gnomAD.
- Datos de expresión génica en el tejido de interés, usando GTEx.
- Priorización de mutaciones en genes que interactúan con genes candidatos conocidos de la enfermedad.
- Clasificación de mutaciones conocidas en benignas y patogénicas usando ClinVar.
</div>

En los últimos años se desarrollaron varios pipelines que facilitan la anotación de variantes con esta información. En este tutorial vamos a usar [VEP](http://www.ensembl.org/info/docs/tools/vep/index.html), porque se puede correr directamente online.

### Pasos a seguir:

1. Generá un listado de todos los SNPs en formato compatible con VEP, para copiar y pegar en la aplicación web. Asegurate de usar la versión hg19/GRCh37, disponible [acá](http://grch37.ensembl.org/Homo_sapiens/Tools/VEP):

```bash
bcftools query -f "%CHROM\t%POS\t%ID\t%REF\t%ALT\n" exon.vcf.gz
```

Un pipeline de anotación y clasificación bien armado puede reducir un set inicial de varios miles de variantes exónicas a un puñado de candidatas. En un caso de enfermedad rara, se puede ganar poder adicional teniendo en cuenta el modelo de herencia sospechado (autosómico recesivo, autosómico dominante, etc.).

2. Generá el mismo listado, pero incluyendo el genotipo de cada variante:

```bash
bcftools query -f "%CHROM\t%POS\t%ID\t%REF\t%ALT\t[%GT]\n" exon.vcf.gz
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 15</strong><br>

¿Qué filtro adicional sería útil en nuestro caso, sabiendo que el paciente índice tiene padres consanguíneos?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 16</strong><br>

¿Cómo podríamos usar archivos de variación poblacional para seguir filtrando la lista de variantes exónicas?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 17</strong><br>

¿Qué características de anotación podrían usarse para priorizar la lista de mutaciones de cara a un médico clínico?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 8: Validación de variantes

Una vez identificada una variante causante candidata, es habitual validarla en el paciente índice mediante PCR y secuenciación Sanger. Si se sospecha un modelo de herencia específico, también se testean los padres.

---
### Pasos a seguir:

1. Para la variante causante candidata, se diseñan primers con [Primer3Plus](https://www.ncbi.nlm.nih.gov/pubmed/17485472). Estos primers son únicos a nivel local y tienen la Tm adecuada, pero no necesariamente son únicos en todo el genoma. Para chequear su unicidad a nivel genómico se puede usar [Silica](https://www.gear-genomics.com/silica), una herramienta de [PCR *in silico*](https://es.wikipedia.org/wiki/PCR_in_silico). Ambos métodos, Primer3Plus y Silica, están combinados en [Verdin](https://www.gear-genomics.com/verdin), que permite diseñar automáticamente primers tanto para variantes cortas como para variantes estructurales grandes.

No vamos a correr la PCR real ni secuenciar el punto de ruptura de la mutación, pero los archivos de validación Sanger del estudio original están en la carpeta de datos:

```bash
ls *.ab1
```

2. Analizá estos archivos de trazas con [Indigo](https://www.gear-genomics.com/indigo). Indigo está pensado principalmente para descubrir InDels en trazas Sanger, pero también alinea la traza contra el genoma de referencia, lo que permite comparar los alineamientos y las trazas del paciente índice con las de sus padres. Los archivos son `patient.ab1`, `mother.ab1` y `father.ab1`. Como referencia, hay una captura de las trazas Sanger en `sanger.png`:

```bash
open sanger.png
```

3. También podés revisar manualmente esta variante en el alineamiento crudo:

```bash
samtools tview -d t -p chr7:2954850 rd.rmdup.bam chr7.fa
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 18</strong><br>

¿Por qué no deberíamos poner los primers justo al lado de la mutación?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 19</strong><br>

¿Por qué tampoco seleccionamos primers a más de 1000 pb de distancia de la mutación?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 20</strong><br>

¿El gen de interés está en la hebra directa (forward) o reversa (reverse)?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 21</strong><br>

¿El gen candidato tiene sentido biológico para un paciente con inmunodeficiencia grave?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 22</strong><br>

¿El gen candidato interactúa con NFKB1?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 23</strong><br>

¿Podés identificar la mutación en las trazas y en el alineamiento contra la referencia?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 24</strong><br>

¿Cuál es el genotipo validado por secuenciación Sanger de la madre, el padre y el paciente para esta mutación?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 9: Control de calidad para el llamado de variantes estructurales

Vamos a cambiar de caso: ahora trabajamos con la muestra tumoral que presenta cromotripsis. Antes de buscar variantes estructurales, siempre hay que evaluar la calidad de los datos.

---
### Pasos a seguir:

1. Ubicate en la carpeta de datos del caso tumoral y calculá estadísticas de alineamiento del genoma tumoral:

```bash
cd data/sv/
samtools flagstat tumor.bam
alfred qc -r chr2.fa -o qc.tsv.gz -j qc.json.gz tumor.bam
zcat qc.tsv.gz | grep ^ME | datamash transpose
```

En vez de parsear el archivo separado por tabs, también podés subir el archivo JSON `qc.json.gz` a la [aplicación web de Alfred](https://www.gear-genomics.com/alfred/), disponible en [gear-genomics.com](https://www.gear-genomics.com/).

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Interpretando el control de calidad</strong><br>

Como vas a ver en los resultados, estos datos fueron submuestreados a 7x de cobertura para acelerar los análisis. Esto implica que algunas variantes estructurales van a tener soporte débil por la baja cobertura.

Algunas cosas generales a tener en cuenta al interpretar el QC:

- Porcentajes de mapeo por debajo del 70%.
- Más del 20% de duplicados.
- Múltiples picos en la distribución de tamaño de inserto.

Muchas estadísticas de alineamiento varían bastante según el protocolo usado, así que en general conviene comparar corridas de secuenciación del mismo protocolo (DNA-seq, RNA-seq, ChIP-seq, *paired-end*, *single-end* o *mate-pair*) para detectar valores atípicos.
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 25</strong><br>

¿Cuál es la cobertura mediana del set de datos?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 26</strong><br>

Dada la distribución del tamaño de inserto, ¿qué umbral sería adecuado para definir pares que soportan una deleción?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 10: Variantes estructurales germinales

Antes de meternos en el llamado de SVs, vamos a familiarizarnos con el aspecto que tienen las variantes estructurales en datos de secuenciación de lecturas cortas.

---
### Pasos a seguir:

1. Ya está preparado un [archivo BED](https://bedtools.readthedocs.io/) con algunas variantes estructurales germinales "simples" (deleciones) y algunos ejemplos más complejos:

```bash
cat svs.bed
```

2. Usando [IGV](http://software.broadinstitute.org/software/igv/) podemos explorar estas SVs de forma interactiva:

```bash
igv -g chr2.fa
```

3. Una vez que IGV arrancó, usá `File` → `Load from File` para cargar los archivos `tumor.bam` y `control.bam`. Luego importá el archivo `svs.bed` desde tu directorio de trabajo usando `Regions` → `Import Regions`.
4. Podés navegar fácilmente hasta cada variante estructural con `Regions` → `Region Navigator`. Seleccioná una variante y hacé clic en `View`, lo que va a centrar la vista de IGV en esa variante.
5. Podés hacer zoom con los signos `+` y `-` de la barra de herramientas superior.
6. Para resaltar los pares anómalos, hacé clic derecho sobre el archivo BAM en IGV y activá `View as pairs`. En el mismo menú, abrí `Color alignments by` y elegí `pair orientation` para inversiones y duplicaciones, o `insert size` para deleciones.
7. También podés visualizar lecturas recortadas (*clipped reads*) desde el menú `View` → `Preferences...` → pestaña `Alignments` → activar `Show soft-clipped reads`.
8. IGV también permite ver pares en pantalla dividida: hacé clic derecho sobre una lectura y seleccioná `View mate in split-screen`.

<div style="page-break-after: always;"></div>

## Ejercicio 11: Graficado de variantes estructurales

IGV es excelente para explorar de forma interactiva, pero cuando hay muchas SVs conviene usar herramientas de línea de comandos como [wally](https://github.com/tobiasrausch/wally) para graficarlas en lote.

---
### Pasos a seguir:

1. Graficá todas las variantes estructurales del archivo BED, comparando la muestra tumoral y el control:

```bash
wally region -R svs.bed -cp -g chr2.fa tumor.bam control.bam
```

<div style="page-break-after: always;"></div>

## Ejercicio 12: Variantes estructurales complejas

Incluso en genomas germinales podemos observar variantes estructurales complejas. El archivo `svs.bed` incluye dos regiones de ejemplo de este tipo.

---
### Pasos a seguir:

1. Filtrá las variantes marcadas como complejas:

```bash
cat svs.bed | grep "complex"
```

2. Como parte del [consorcio de SVs de 1000 Genomes](https://www.nature.com/articles/nature15394), estas variantes complejas fueron validadas usando PacBio. Las lecturas están en los archivos FASTA `pacbio.sv1.fa` y `pacbio.sv2.fa`. Para generar un dotplot de cada lectura PacBio contra la referencia, primero necesitamos extraer la subsecuencia correspondiente de la referencia con SAMtools:

```bash
samtools faidx chr2.fa chr2:18905691-18907969 | sed 's/^>.*$/>reference/' > sv1.fa
samtools faidx chr2.fa chr2:96210505-96212783 | sed 's/^>.*$/>reference/' > sv2.fa
```

3. Generá un dotplot de cada subsecuencia de referencia contra la lectura PacBio correspondiente, usando [wally](https://github.com/tobiasrausch/wally):

```bash
cat pacbio.sv1.fa >> sv1.fa
wally dotplot sv1.fa
cat pacbio.sv2.fa >> sv2.fa
wally dotplot sv2.fa
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 27</strong><br>

¿Qué tipo de variante estructural está presente en la región chr2:18905691-18907969?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 28</strong><br>

¿Qué tipo de variante estructural está presente en la región chr2:96210505-96212783?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 13: Llamado de variantes estructurales con Delly

[Delly](https://github.com/dellytools/delly) es un método para detectar variantes estructurales. Usando el alineamiento tumoral y el control, Delly calcula las SVs y las guarda en un archivo BCF (la codificación binaria de [VCF](https://samtools.github.io/hts-specs)).

---
### Pasos a seguir:

1. Corré Delly sobre las muestras tumoral y control. También se le puede pasar un archivo de texto con regiones a excluir del análisis; el mapa de exclusión por defecto de Delly remueve las regiones teloméricas y centroméricas de todos los cromosomas humanos, porque estas regiones repetitivas no se pueden analizar bien con datos de lectura corta:

```bash
delly call -q 20 -g chr2.fa -x hg19.ex -o sv.bcf tumor.bam control.bam
```

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>Codificación VCF de variantes estructurales</strong><br>

El formato VCF fue diseñado originalmente para variantes cortas, por eso los llamadores de SVs usan intensivamente los campos INFO del VCF para codificar información adicional, como el final de la variante estructural (`INFO:END`) y su tipo (`INFO:SVTYPE`).

Delly usa los campos INFO para la información a nivel de sitio (qué tan confiable es la predicción, qué tan precisos son los puntos de ruptura), mientras que los campos de genotipo contienen el genotipo de cada muestra, su calidad, las verosimilitudes de genotipo y varios conteos de lecturas que soportan la variante, la referencia y los pares que "saltan" el punto de ruptura.

Si recorrés el archivo VCF vas a notar que un subconjunto de las predicciones fueron refinadas usando *split-reads*: estas variantes precisas están marcadas con el tag `PRECISE`, y el resto figura como `IMPRECISE`. Recordá que este BCF contiene tanto variantes germinales como somáticas, además de falsos positivos causados por mal mapeo en regiones repetitivas o secuencias de referencia incompletas.
</div>

2. Mirá el encabezado del BCF (incluyendo las primeras dos variantes con `-A 2`):

```bash
bcftools view sv.bcf | grep "^#" -A 2
```

3. `bcftools` ofrece muchas formas de consultar y reformatear las SVs. Por ejemplo, para generar una tabla con cromosoma, inicio, fin, identificador y genotipo de cada variante:

```bash
bcftools query -f "%CHROM\t%POS\t%INFO/END\t%ID[\t%GT]\n" sv.bcf | head
```

4. Este llamado inicial no distingue entre variantes somáticas y germinales. Por ejemplo, las 2 variantes complejas que vimos antes siguen presentes en la salida de Delly. Una duplicación proximal genera 2 señales de tipo *paired-end* (tipo deleción y tipo duplicación):

```bash
bcftools view sv.bcf chr2:18905691-18907969 | awk '$2>=18905691 && $2<=18907969'
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 29</strong><br>

¿Qué fracción de las deleciones fue llamada de forma precisa (a resolución de un solo nucleótido) por Delly?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 30</strong><br>

¿La otra variante estructural compleja sigue presente en el archivo de salida de Delly?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 14: Filtrado somático de variantes estructurales

El filtrado somático de Delly requiere un archivo de muestra que liste los nombres de la muestra tumoral y control tal como figuran en el VCF.

---
### Pasos a seguir:

1. Revisá el archivo de muestras:

```bash
cat spl.tsv
```

2. Hay varios parámetros disponibles para ajustar el filtrado somático. A continuación exigimos una frecuencia alélica mínima del 25%, ningún soporte en el control pareado, y una predicción confiable en general (campo FILTER del VCF igual a PASS):

```bash
delly filter -p -f somatic -o somatic.bcf -a 0.25 -s spl.tsv sv.bcf
```

3. Como es esperable, las SVs somáticas tienen un genotipo homocigota para la referencia en la muestra control:

```bash
bcftools query -f "%CHROM\t%POS\t%INFO/END\t%ID[\t%GT]\n" somatic.bcf
```

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 31</strong><br>

¿Cuál es el tamaño promedio de las SVs somáticas?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong>✏️ Pregunta 32</strong><br>

¿Hay algún tipo de SV que esté enriquecido entre las variantes somáticas?
</div>

<div style="page-break-after: always;"></div>

## Ejercicio 15: Visualización de variantes estructurales complejas

[IGV](http://software.broadinstitute.org/software/igv/) y [wally](https://github.com/tobiasrausch/wally) permiten usar vistas divididas (*split views*) para visualizar los puntos de ruptura de SVs de largo alcance (mayores a 10.000 pb).

---
### Pasos a seguir:

1. Generá las coordenadas de los puntos de ruptura y graficalas con wally:

```bash
bcftools query -f "%CHROM\t%POS\t%INFO/END\t%ID\n" somatic.bcf | awk '$3-$2>10000 {print $1"\t"($2-500)"\t"($2+500)"\t"$4"L\n"$1"\t"($3-500)"\t"($3+500)"\t"$4"R";}' > somatic.bp.bed
wally region -R somatic.bp.bed -s 2 -cp -g chr2.fa tumor.bam control.bam
```

Este tipo de vista de puntos de ruptura no permite, por sí sola, detectar clases de SV de orden superior como la cromotripsis. Por eso necesitamos integrar la profundidad de lectura (*read-depth*) con las predicciones de variantes estructurales, para tener una visión más completa de los reordenamientos somáticos complejos.

2. Generá primero un gráfico simple de profundidad de lectura:

```bash
delly cnv -u -z 10000 -o cnv.bcf -c cnv.cov.gz -g chr2.fa -m chr2.map.fa tumor.bam
Rscript cnBafSV.R cnv.cov.gz
```

3. Superponé las variantes estructurales somáticas sobre la información de profundidad de lectura:

```bash
bcftools query -f "%CHROM\t%POS\t%INFO/END\t%INFO/SVTYPE\t%ID\n" somatic.bcf > svs.tsv
Rscript cnBafSV.R cnv.cov.gz svs.tsv
```

4. Por último, podemos complementar los gráficos con la profundidad alélica de SNPs. En amplificaciones, esperaríamos que la frecuencia alélica de las variantes se desvíe del 50% esperado para heterocigotas. Para acelerar el análisis, calculamos SNPs solo en la región 1-50 Mpb:

```bash
bcftools mpileup -d 50 -r chr2:1-50000000 -a FORMAT/AD -f chr2.fa tumor.bam | bcftools call -mv -Ob -o calls.bcf
bcftools view -g het -m2 -M2 -v snps calls.bcf | bcftools query -f "%POS,[%AD\n]" - | awk 'BEGIN {FS=","} $2+$3>10 {print $1"\t"$3/($2+$3);}' > baf.tsv
Rscript cnBafSV.R cnv.cov.gz svs.tsv baf.tsv
```

---
## Cierre:
1. ¿Qué tipos de experimentos hicimos hoy?
2. Completá la tabla con los temas vistos hoy:

| Tema | Algoritmo | Tipo de datos | Base de datos | Análisis del resultado |
| :--- | :--- | :--- | :--- | :--- |
| (completar) | (completar) | (completar) | (completar) | (completar) |

3. ¿Cumpliste con los objetivos del tutorial?

| Objetivo | ¿Se cumplió? |
| :--- | :--- |
| 1. Alinear lecturas de secuenciación contra un genoma de referencia y evaluar la calidad del alineamiento. | Sí / No |
| 2. Detectar variantes puntuales (SNVs) e InDels, y filtrarlas según criterios de calidad. | Sí / No |
| 3. Anotar y priorizar variantes candidatas en un caso de enfermedad rara. | Sí / No |
| 4. Detectar, filtrar y visualizar variantes estructurales (SVs) germinales y somáticas en una muestra tumoral. | Sí / No |

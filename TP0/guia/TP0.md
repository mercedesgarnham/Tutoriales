# TP0: Introducción a los tipos de datos biológicos y su almacenamiento

Este tutorial presenta una visión general que es la bioinformática, de los tipos de datos que se manejan y de donde obtenerlos. 

### Objetivos del Tutorial

1. Definir la bioinformática y distinguir los distintos roles y tareas que desempeña un bioinformático.

2. Aprender sobre los tipos de datos biológicos que se manejan en bioinformática y los formatos de archivo correspondientes.

3. Aprender dónde se almacenan esos datos, identificando las bases de datos de referencia.

---

## Definición y perfil del bioinformático

El término "bioinformático" es amplio y no refiere a un único perfil. Un bioinformático posee, de manera combinada:
- Conocimiento de un dominio biológico específico (genómica, proteómica, metabolómica).
- Habilidades informáticas (programación, análisis estadístico).

La formación habitual incluye un título en ciencias biológicas o computación, más un posgrado en bioinformática o experiencia equivalente.

Las tareas que realizan incluyen:
- Colaboración con investigadores.
- Asesoramiento en recolección, gestión y visualización de datos.
- Asesoramiento en diseño experimental.
- Procesamiento de datos y análisis estadístico.
- Desarrollo de pipelines de análisis a medida.

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> La bioinformática como ciencia experimental </strong><br>

El uso de cualquier método computacional (algoritmo, pipeline, herramienta) para responder una pregunta biológica constituye un experimento. Como todo experimento, requiere:

- **Controles positivos y negativos** adaptados al problema.
- **Registro de los parámetros** de ejecución.
- **Reproducibilidad**: tener en cuenta que las bases de datos y las versiones de los programas cambian, lo que puede impedir replicar exactamente un resultado.
- **Conocimiento de las limitaciones del método**, que se obtiene leyendo la documentación y los artículos originales.

**Ejemplos de controles aplicables a cualquier método:**

| Tipo de método | Control positivo | Control negativo |
| :--- | :--- | :--- |
| Comparación de secuencias | Usar secuencias que se sabe que están relacionadas evolutivamente; el algoritmo debe detectar la relación. | Usar secuencias sin relación (ej: secuencias aleatorias o de organismos muy distantes); el algoritmo no debe mostrar relación significativa. |
| Predicción de estructura | Usar una secuencia con estructura resuelta experimentalmente; la predicción debe aproximarse a esa estructura. | Usar una secuencia que se sabe que no tiene estructura estable (ej: región desordenada); la predicción debe reflejar incertidumbre o no dar una estructura confiable. |
| Clasificación o agrupamiento (clustering) | Usar un conjunto de datos con etiquetas conocidas; el algoritmo debe recuperar los grupos esperados. | Usar un conjunto de datos donde no hay grupos reales (ej: datos completamente aleatorios); el algoritmo no debe forzar grupos falsos. |

**Nota crítica:** la mayoría de los algoritmos devuelven un resultado aunque los datos de entrada no tengan sentido biológico. Por eso, el control negativo y el conocimiento de los límites del método son obligatorios antes de aceptar cualquier salida como válida.

## Tipos de experimentos en bioinformática

Los experimentos en bioinformática se clasifican en cuatro tipos según la operación principal que se realiza sobre los datos. Cada tipo requiere controles específicos y una comprensión clara de sus limitaciones.

### Búsqueda

La búsqueda consiste en recuperar información de una base de datos utilizando términos, identificadores o filtros. No implica modificar los datos ni establecer relaciones entre ellos; solo extraer registros que cumplan ciertos criterios.

#### Ejemplo de experimento
Encontrar las proteínas quinasa que (i) participan en una vía de reacción determinada y (ii) están sobreexpresadas en un estado patológico.

#### Posibles Controles
- Verificar que los términos de búsqueda no se mapeen a otras vías no relacionadas.
- Comprobar que los términos de búsqueda estén correctamente asociados a la entrada biológica (ej: buscar los mismos términos en entradas relacionadas).

### Comparación 

La comparación es un tipo de experimento que consiste en poner dos o más conjuntos de datos biológicos (secuencias, genomas, perfiles de expresión, estructuras, vías metabólicas, etc.) lado a lado para identificar similitudes, diferencias o relaciones. El objetivo es inferir evolución, función, conservación, divergencia o asociación entre entidades biológicas.

#### Ejemplo de experimento
Comparar la presencia/ausencia de genes de resistencia a antibióticos entre 25 genomas bacterianos de origen clínico y 25 de origen ambiental. Se anotan los genomas con una base de datos de resistencia y se compara la frecuencia de genes entre ambos grupos.

#### Posibles Controles
- Comparar con secuencias aleatorias.
- Evaluar la puntuación de secuencias no relacionadas.
- Considerar la herramienta utilizada (varían en velocidad, precisión y ámbito de aplicación).

### Modelado/Predicción

El modelado consiste en generar representaciones predictivas de sistemas, estructuras o procesos biológicos a partir de datos de entrada. 

#### Ejemplo de experimento
Querés modelar la vía de señalización de la insulina en células hepáticas. Construís un modelo matemático con ecuaciones diferenciales que represente las concentraciones y velocidades de cada reacción de la vía, usando datos de la literatura. 

#### Posibles Controles
- Comparar las predicciones del modelo con datos experimentales reales que no se usaron para construirlo. 
- Variar ligeramente los parámetros iniciales y ver si el modelo sigue comportándose igual. 
- Verificar que el modelo reproduzca fenómenos biológicos ya establecidos.

### Integración 

La integración es un experimento que combina datos de dos o más fuentes o dominios biológicos para responder una pregunta que no puede responderse con una sola fuente. El objetivo es reunir evidencia convergente que fortalezca o refute una hipótesis biológica.

#### Ejemplo de experimento
Tenés muestras de tumores de mama de 100 pacientes. Para cada muestra tenés datos de mutaciones somáticas (secuenciación de exoma completo), de expresión génica (RNA-seq) y de metilación (arrays de metilación). Querés identificar subtipos de tumores que tengan un perfil molecular similar y asociarlos con la supervivencia. 

#### Posibles Controles
- Incluir una cepa con gen de resistencia conocido.
- Incluir una cepa sin genes de resistencia documentados. 
- Tomar datos de dos bases de datos distintas. 

## ¿Necesito programar?

No es obligatorio. Existen plataformas web que permiten usar herramientas bioinformáticas sin escribir una línea de código.

Sin embargo, aprender a programar, aunque sea en un nivel elemental, se convierte en una habilidad muy poderosa. La línea de comandos (terminal) permite ejecutar tareas repetitivas y de procesamiento de datos con mucha más eficiencia que los entornos gráficos.
</div>

---
<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> Bases de datos de referencia en Bioinformática </strong><br>

Las bases de datos de referencia constituyen la infraestructura fundamental sobre la que se sostiene la bioinformática moderna. Estas plataformas no solo almacenan la información biológica generada a nivel mundial (secuencias, estructuras, variantes, expresiones y redes), sino que también la organizan, curan y estandarizan para garantizar su reproducibilidad y accesibilidad. Desde el descubrimiento de nuevos genes hasta el diagnóstico de enfermedades raras, pasando por el diseño de fármacos y la ecología microbiana, todas las ramas de la biología computacional dependen críticamente de la calidad, actualización e interoperabilidad de estos repositorios. A continuación, se presenta un catálogo estructurado por categorías funcionales, con las principales bases de datos que todo bioinformático debe conocer y saber utilizar.

### Bases de datos de secuencias primarias (ADN / ARN)

**Introducción:** 
Estas bases de datos son los archivos maestro donde se depositan las secuencias nucleotídicas crudas y ensambladas procedentes de proyectos de secuenciación de todo el mundo. Forman el núcleo del *International Nucleotide Sequence Database Collaboration (INSDC)*, lo que garantiza el intercambio diario de datos entre los tres grandes nodos continentales. Son la materia prima para cualquier análisis de alineamiento, búsqueda por homología (BLAST) o ensamblaje de novo.

| Nombre de la base de datos | Enlace (Link) | ¿Qué contiene? |
| :--- | :--- | :--- |
| **GenBank** | https://www.ncbi.nlm.nih.gov/genbank/ | Archivo primario del NCBI. Contiene todas las secuencias nucleotídicas enviadas directamente por los investigadores, con anotaciones originales. |
| **ENA (European Nucleotide Archive)** | https://www.ebi.ac.uk/ena | El archivo europeo de nucleótidos. Actúa como repositorio principal de secuencias para Europa y el Reino Unido. |
| **DDBJ (DNA Data Bank of Japan)** | https://www.ddbj.nig.ac.jp | Archivo japonés de nucleótidos. Intercambia datos a diario con GenBank y ENA para mantener la tríada INSDC. |
| **RefSeq (NCBI Reference Sequence)** | https://www.ncbi.nlm.nih.gov/refseq/ | Colección de secuencias de referencia curadas y no redundantes (genomas, transcritos y proteínas) con alta calidad de anotación. |
| **NCBI Nucleotide (nt)** | https://www.ncbi.nlm.nih.gov/nucleotide/ | Base de datos no redundante que integra todas las secuencias de GenBank, RefSeq, PDB y terceros; es la base por defecto para BLASTn. |
| **SRA (Sequence Read Archive)** | https://www.ncbi.nlm.nih.gov/sra | Mayor repositorio mundial de datos crudos de secuenciación masiva (reads de Illumina, PacBio, Oxford Nanopore). |

### Bases de datos de genomas completos y anotación estructural

**Introducción:** 
Una vez que las secuencias crudas se ensamblan, estas bases de datos proporcionan el contexto cromosómico completo, incluyendo la ubicación exacta de genes, elementos reguladores, repeticiones y regiones conservadas. Funcionan como auténticos navegadores genómicos que integran múltiples capas de información biológica en un solo mapa interactivo, permitiendo visualizar la arquitectura funcional de los organismos.

| Nombre de la base de datos | Enlace (Link) | ¿Qué contiene? |
| :--- | :--- | :--- |
| **Ensembl** | https://www.ensembl.org | Anotación genómica automática y visualización integrada para genomas de vertebrados y otros eucariotas modelo (incluye comparativa filogenética). |
| **UCSC Genome Browser** | https://genome.ucsc.edu | Navegador de genomas con cientos de *tracks* anotados (conservación, variantes, regulación, metilación) con alto rendimiento en visualización. |
| **NCBI Genome** | https://www.ncbi.nlm.nih.gov/genome/ | Catálogo curado de genomas completos y ensamblajes de referencia para todos los dominios de la vida (bacterias, arqueas, eucariotas). |
| **Ensembl Genomes** | https://ensemblgenomes.org | Extensión de Ensembl especializada en genomas de plantas, hongos, protistas, metazoos no vertebrados y bacterias. |

### Bases de datos de proteínas (secuencia y estructura)

**Introducción:** 
Las proteínas son las efectoras moleculares de la célula. Esta categoría cubre desde la información primaria de secuencia y su anotación funcional hasta la arquitectura tridimensional determinada experimentalmente o predicha por inteligencia artificial. Estas bases son cruciales para estudios de evolución molecular, predicción de función y diseño de fármacos basado en estructura.

| Nombre de la base de datos | Enlace (Link) | ¿Qué contiene? |
| :--- | :--- | :--- |
| **UniProt (Swiss-Prot + TrEMBL)** | https://www.uniprot.org | Recurso universal de proteínas. Swiss-Prot (curada manualmente con alta fiabilidad) y TrEMBL (anotación automática y rápida). |
| **NCBI Protein (nr)** | https://www.ncbi.nlm.nih.gov/protein/ | Base de datos no redundante de proteínas que aglutina secuencias de PDB, Swiss-Prot, RefSeq y otras fuentes. |
| **PDB (Protein Data Bank)** | https://www.rcsb.org | Archivo global de estructuras 3D de proteínas y ácidos nucleicos obtenidas por cristalografía, RMN y criomicroscopía electrónica. |
| **AlphaFold Protein Structure Database** | https://alphafold.ebi.ac.uk | Repositorio de estructuras 3D predichas por IA (DeepMind) para el proteoma humano y de más de 40 especies, con altos niveles de confianza. |
| **InterPro** | https://www.ebi.ac.uk/interpro/ | Sistema de clasificación funcional que integra múltiples firmas (dominios, familias y motivos) de proteínas en un solo buscador. |

### Otras bases de datos especializadas (literatura, ontologías y química)

**Introducción:** 
El análisis bioinformático no estaría completo sin el contexto biológico. Esta última categoría agrupa recursos indispensables para la búsqueda bibliográfica, la estandarización del lenguaje biológico (ontologías) y el estudio de moléculas pequeñas con actividad biológica. Estas bases conectan la genómica con la química medicinal y la evidencia experimental publicada.

| Nombre de la base de datos | Enlace (Link) | ¿Qué contiene? |
| :--- | :--- | :--- |
| **PubMed** | https://pubmed.ncbi.nlm.nih.gov | Base de datos primaria de citas y resúmenes de la literatura biomédica (más de 36 millones de referencias). |
| **Gene Ontology (GO)** | https://geneontology.org | Vocabulario controlado y jerárquico para describir funciones moleculares, procesos biológicos y componentes celulares de los genes. |
| **ChEMBL** | https://www.ebi.ac.uk/chembl | Base de datos de moléculas pequeñas bioactivas con actividades cuantitativas contra dianas terapéuticas (quimioinformática). |
| **PubChem** | https://pubchem.ncbi.nlm.nih.gov | Repositorio público de moléculas, ensayos de actividad biológica y datos de toxicología. |
| **KEGG (Kyoto Encyclopedia of Genes and Genomes)** | https://www.genome.jp/kegg | Enciclopedia de rutas metabólicas, vías de señalización, redes de interacción y mapas de enfermedades. |
| **IntAct** | https://www.ebi.ac.uk/intact | Repositorio curado de interacciones moleculares (proteína-proteína, proteína-ADN y proteína-ligando) extraídas de la literatura. |

</div>

---

## Proyecto: Producción de Insulina Humana Recombinante 

La insulina humana recombinante es uno de los productos biotecnológicos más exitosos de la historia. Desde su aprobación en 1982, ha salvado millones de vidas de personas con diabetes. 

La insulina es una hormona peptídica producida por las células beta del páncreas. El gen *INS* se encuentra en el cromosoma 11 humano (11p15.5) y su secuencia codificante (CDS) tiene 330 nucleótidos, que se traducen en una proteína de 110 aminoácidos (preproinsulina). Las mutaciones en este gen pueden causar diabetes mellitus neonatal, hiperinsulinemia hipoglucémica y otras enfermedades metabólicas.

El proceso de producción implica:

1. **Obtener la secuencia genética** de la insulina humana.
2. **Diseñar cebadores (primers)** para amplificar el gen.
3. **Clonar el gen** en un vector de expresión bacteriano (p.ej., pET-28a).
4. **Transformar *E. coli*** y seleccionar clones positivos.
5. **Inducir la expresión** y producir la proteína en un reactor (fermentador).
6. **Purificar y plegar** la proteína para obtener insulina activa.

Antes de poder hacer todo eso, necesitamos **la secuencia de referencia** del gen de la insulina humana y **la estructura de la proteína** para entender qué estamos produciendo y cómo verificaremos su correcto plegamiento.

### Objetivos

- Obtener la secuencia codificante y aminoacídica del gen de la insulina humana. 
- Identificar sus dominios funcionales y los residuos críticos para su actividad biológica.

### Ejercicio 1: Obtención de la secuencia 

1. Ingresá al [ENA Browser](https://www.ebi.ac.uk/ena/browser/home).

2. En el recuardo "Enter text search terms", escribi "insulin"

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 1:</strong><br> 
¿Cuántas secuencias se obtuvieron? ¿Cuántas de ellas son codificantes?
</div>

3. Ingresa a la sección de "Coding". 

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 2:</strong><br> 
¿Qué información contiene está sección? ¿Qué indica el "Accession"? ¿Qué información encontramos en "Description/Title"?
</div>

Podemos ver que aparecen secuencias de diferentes organisos, vamos a refinar la búsqueda.

4. En el recuardo "Enter text search terms", escribi "human insulin"

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 3:</strong><br> 
¿Cuántas secuencias aparecen ahora?
</div>

5. Ingresa a la sección de "Coding". 

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 4:</strong><br> 
¿Qué información contiene ahora la sección de "Description/Title"?
</div>

6. Del listado obtenido, dentro de la columna "Accession", seleccioná el código **`KAI2558110`**. 

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 5:</strong><br> 
¿Qué información proporciona esta entrada? ¿Que longitud tiene la secuencia? ¿De qué tipo celular se obtuvo?
</div>

7. Hacé clic en **"View -> FASTA"**.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 6:</strong><br> 
¿Qué información contiene? ¿Que indica la línea que comienza con "`>`"? 
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 7:</strong><br> 
¿Qué tipo de biomolécula está representada en este archivo?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 8:</strong><br> 
¿Con qué codón comienza la secuencia? ¿Qué codifica ese triplete?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 9:</strong><br> 
¿Con qué codón termina? ¿Es un codón de terminación?
</div>

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> Qué es un archivo FASTA?</strong><br>

El formato **FASTA** es el estándar universal para representar secuencias biológicas (ADN, ARN o proteínas) en archivos de texto plano. Fue desarrollado originalmente por William R. Pearson y David J. Lipman en 1985 como parte del programa de búsqueda de similitudes **FASTA** (de ahí su nombre). Con el tiempo, se convirtió en el formato más utilizado para almacenar e intercambiar secuencias, ya que es **sencillo, legible por humanos y fácilmente procesable por programas informáticos**.

A veces, los archivos FASTA contienen una **única secuencia** (como en nuestro caso), pero también pueden ser **archivos multifasta**, con varias entradas una tras otra. Por ejemplo, un archivo con 5 genes diferentes.

<strong>Estructura de un archivo FASTA</strong><br>

Un archivo FASTA tiene **dos partes bien diferenciadas**, que se repiten para cada secuencia:

1.  **Línea de cabecera (header)**: Comienza siempre con el carácter **`>`** (mayor que). Esta línea contiene el identificador único de la secuencia y, opcionalmente, metadatos como la especie, el nombre del gen, el tipo de molécula o cualquier otra información descriptiva.

2.  **Líneas de secuencia**: Inmediatamente después de la cabecera, una o varias líneas con la secuencia de letras (nucleótidos o aminoácidos). No hay un límite estricto, pero por convención se suelen escribir en bloques de **60 caracteres** para facilitar su lectura y manipulación.

##### Caracteres válidos en las secuencias

| Tipo de secuencia | Caracteres permitidos | Notas |
| :--- | :--- | :--- |
| **ADN** | `A`, `C`, `G`, `T` | También se aceptan letras ambigüas: `R` (A/G), `Y` (C/T), `N` (cualquiera), etc. |
| **ARN** | `A`, `C`, `G`, `U` | Se usa `U` en lugar de `T`. |
| **Proteína** | Las 20 letras del alfabeto de aminoácidos (p. ej., `A`, `R`, `N`, `D`, `C`, ...) | También se aceptan letras ambigüas (p. ej., `X` para cualquier aminoácido) y el símbolo `*` para codón de parada. |

##### ¿Para qué se usa el formato FASTA?

El formato FASTA es el **punto de partida** para prácticamente cualquier análisis bioinformático. Sus usos más comunes incluyen:

1.  **Búsqueda de similitud**: Las herramientas BLAST, DIAMOND, HHblitz, etc., aceptan secuencias en FASTA como entrada para buscar homólogos en bases de datos.
2.  **Alineamiento múltiple**: Programas como Clustal Omega, MAFFT o MUSCLE utilizan archivos FASTA para alinear secuencias de ADN, ARN o proteínas.
3.  **Ensamblaje de genomas**: Los ensambladores (SPAdes, SOAPdenovo) toman reads en FASTQ, pero los genomas ensamblados se exportan en FASTA.
4.  **Diseño de cebadores (primers)**: Los programas de diseño de primers (Primer3) aceptan secuencias en FASTA para identificar regiones amplificables.
5.  **Ingeniería genética**: Al clonar un gen, la secuencia de referencia en FASTA se usa para diseñar las estrategias de amplificación y clonaje.
6.  **Evolución molecular**: Los archivos FASTA de genes ortólogos son la base para construir árboles filogenéticos.

##### Buenas prácticas

- **No usar espacios** en los identificadores ni en la secuencia.
- **No dividir** la secuencia con espacios o guiones (a menos que sea para alineamientos, pero entonces no es FASTA estándar).
- **Usar caracteres ASCII** (sin tildes ni eñes) en la cabecera.
- **Respetar la extensión** `.fasta`, `.fa`, `.fna` (ADN), `.faa` (proteína), `.frn` (ARN).

</div>

8. Desde la página de la entrada `KAI2558110`, hacé clic en **"View"** y seleccioná **"EMBL"**.

9. Se abrirá una nueva vista con el registro completo de la secuencia en formato EMBL. Observalo con atención y respondé:

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 10:</strong><br> 
En la línea `ID` aparece el código de acceso. ¿Qué tipo de molécula indica (`linear` / `circular`) y qué tipo de ácido nucleico es (`genomic DNA`, `mRNA`, etc.)?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 11:</strong><br> 
En la línea `DE` (Description) dice *"Homo sapiens (human) insulin"*. Comparando con la cabecera del archivo FASTA (`>ENA|KAI2558110|KAI2558110.1 Homo sapiens (human) insulin`), ¿qué información nueva y más específica encontrás en la línea `OS` (Organism Species) y en la línea `OC` (Organism Classification)?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 12:</strong><br> 

Buscá la línea que comienza con `FT   source`.
    - ¿Entre qué posiciones de nucleótidos se encuentra esta secuencia en el genoma (`1..333`)?
    - ¿De qué **cromosoma** proviene?
    - ¿De qué **tipo celular** (`cell_type`) y **tejido** (`tissue_type`) se obtuvo?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 13:</strong><br>

Ahora buscá la línea que comienza con `FT   CDS` (región codificante).
    - ¿La secuencia está en la hebra *forward* o en la hebra *complementaria*? (Pista: mirá si dice `complement()`).
    - ¿En qué coordenadas del cromosoma 11 se encuentra este gen (buscá los números que acompañan a `CM034961.1`)?
    - ¿Cuál es el nombre del producto proteico que figura en `/product=`?
    - ¿Cuál es el `protein_id` asociado?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 14:</strong><br> 
¿Qué símbolo marca el final de la entrada en el archivo EMBL?
</div>

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> El formato EMBL </strong><br>

El **formato EMBL** es el formato nativo que utiliza el **European Nucleotide Archive (ENA)** para almacenar y mostrar secuencias de nucleótidos junto con todos sus metadatos. El formato EMBL es un **archivo de texto estructurado** con múltiples secciones etiquetadas que brindan información contextual completa (origen, referencias bibliográficas, anotación de genes, etc.).

##### Estructura de un archivo EMBL

Un archivo EMBL se divide en varias secciones, cada una identificada por un código de dos letras al inicio de la línea:

| Código | Significado | Ejemplo |
| :--- | :--- | :--- |
| `ID` | Identificación de la entrada (tipo de molécula, longitud, lineal/circular) | `ID   KAI2558110; SV 1; linear; mRNA; XXX; XXX;` |
| `AC` | **Número de acceso (Accession)**, identificador único y permanente | `AC   KAI2558110;` |
| `PR` | Proyecto de secuenciación al que pertenece | `PR   Project:PRJNAXXXXXX;` |
| `DE` | **Descripción completa** de la secuencia (organismo, nombre del gen o proteína) | `DE   Homo sapiens mRNA for reactive intermediate imine deaminase A-like protein` |
| `RN`, `RA`, `RL` | Referencias bibliográficas y autores | `RN   [1]`<br>`RA   Smith J., et al.;` |
| `FH` y `FT` | **Tabla de características (Feature Table)**. Anotación funcional: ubicación de genes, CDS, exones, etc. | `FT   CDS             join(1..435)`<br>`FT                   /gene="..."`<br>`FT                   /product="..."` |
| `SQ` | Resumen de la composición de la secuencia (número de A, C, G, T) y la secuencia en sí | `SQ   Sequence 435 BP; 120 A; 95 C; 110 G; 110 T;` |
| `//` | **Marcador de final** de la entrada | `//` |

##### Características importantes del formato EMBL

- **Líneas de cabecera con código de dos letras**: Cada línea comienza con un identificador de dos caracteres (mayúsculas) seguido de uno o más espacios.
- **Tabla de características (FT)**: Es la sección más valiosa para la biología. Utiliza calificadores entre barras (`/`) para agregar detalles como `/gene`, `/product`, `/organism`, `/tissue_type`, `/codon_start`, etc.
- **Secuencia con números de base**: La secuencia de nucleótidos suele presentarse en bloques de 10 nucleótidos separados por espacios, con numeración de posiciones al costado para facilitar la lectura.
- **Formato legible por máquinas y humanos**: Está diseñado para ser procesado por programas bioinformáticos pero también para que un científico pueda leerlo directamente.

##### ¿Para qué se usa el formato EMBL?

- **Consulta de metadatos**: Para saber de qué organismo proviene la secuencia, qué gen codifica, en qué tejido se expresó, etc.
- **Verificación de anotaciones**: Para confirmar dónde empieza y termina un gen (CDS), si tiene intrones, o si hay mutaciones anotadas.
- **Depósito de secuencias**: Es el formato estándar que se utiliza al enviar una nueva secuencia a las bases de datos internacionales (ENA, GenBank, DDBJ).
- **Intercambio de datos**: Permite transferir información completa y contextualizada entre distintos repositorios y herramientas.

</div>

---

### Ejercicio 2: Exploración de UniProt 

En el ejercicio anterior, obtuviste la secuencia nucleotídica del gen de la insulina humana. Ahora, en esta segunda parte, exploraremos **UniProt (Universal Protein Resource)**, la base de datos central de información sobre proteínas. Aquí encontraremos información fundamental sobre la proteína que vamos a producir: su función, estructura, dominios, modificaciones y su relación con enfermedades.

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ¿Qué es UniProt? </strong><br>

UniProt es una base de datos de libre acceso que recopila y organiza toda la información conocida sobre proteínas. Está compuesta por varias secciones, siendo la principal **UniProtKB (UniProt Knowledgebase)**, que a su vez se divide en dos niveles:

*   **Swiss-Prot**: Información curada y revisada manualmente por expertos. 
*   **TrEMBL**: Información automática, sin revisión manual.

</div>

1.  Ingresa a la página principal de UniProt: [https://www.uniprot.org/](https://www.uniprot.org/).

2.  En el recuadro de búsqueda, escribe "human insulin" y presiona Enter.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 1:</strong><br> 

¿Cuántos resultados aparecen? ¿Cuantas entradas corresponden a **Swiss-Prot** y cuantas a **TrEMBL**? ¿Cuantas entradas hay por cada "Popular organisms"?
</div>

3.  Haz clic en el resultado principal (el que tiene el código **`P01308`**) para acceder a la entrada completa. 
      
<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 2:</strong><br> 

¿Las otras entradas a qué corresponden? 
</div>

4.  Explora la sección superior de la entrada. 

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 3:</strong><br> 

¿Corresponde al organismo que buscamos? ¿Qué longitud tiene? ¿La entrada que usamos en que "Status" se encuentra?
</div>

5.  Explora la sección **"Function"** (Función). Lee la descripción.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 4:</strong><br> 

¿Cuál es la función principal de la insulina en el organismo?
</div>

6.  Desplázate hacia abajo hasta la sección **"Names & Taxonomy"** (Nombres y Taxonomía).

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 5:</strong><br> 

Además de "Insulin", ¿qué otros nombres se mencionan para esta proteína?
</div>

7.  Ahora, desplázate hasta la sección **"Subcellular location"**. 

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 6:</strong><br> 

Según UniProt, ¿la insulina madura se secreta al torrente sanguíneo o queda dentro de la célula? 
</div>

8.  Localiza la sección **"Disease & Variants"** (Patología y Enfermedad).

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 7:</strong><br> 

¿Con qué enfermedad se asocian las mutaciones en el gen de la insulina?
</div>

10.  Busca la sección **"PTM / Processing"** (Modificaciones Postraduccionales y Procesamiento).

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 8:</strong><br> 

La insulina activa (madura) está compuesta por dos cadenas polipeptídicas unidas por puentes disulfuro. Según los datos de la tabla, ¿cuáles son los nombres exactos de estas dos cadenas y en qué posiciones de aminoácidos se encuentran?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 9:</strong><br> 

La preproinsulina no se convierte directamente en insulina; primero se eliminan otras partes. ¿Qué dos elementos adicionales aparecen en la tabla (clasificados como *Signal* y *Propeptide*) que son recortados durante la maduración y que **no** forman parte de la insulina final?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 10:</strong><br> 

Observa las filas de la tabla que indican "Disulfide bond". La tabla muestra tres puentes disulfuro. ¿Cuáles son los dos puentes disulfuro que unen específicamente la cadena B con la cadena A?
</div>

11. Dirígete a la sección **"Structure"** (Secuencia e Isoforma). Aquí verás un resumen de las estructuras tridimensionales disponibles para la insulina humana, tanto experimentales (PDB) como predictivas (AlphaFold).

12. En la sección "Structure", buscá el visor interactivo. Debajo del visor, deberías ver una lista de **códigos PDB** (por ejemplo, `4EYN`, `2OM1`, `1MSO`). Estos son identificadores de estructuras experimentales depositadas en el Protein Data Bank.

13. Hacé clic en el primer código PDB de la lista. Esto te redirigirá automáticamente a la página de esa estructura en el **PDB** (Protein Data Bank).

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 11:</strong><br> 

¿Cuál es el **título** de la entrada?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 12:</strong><br> 

¿Qué **técnica experimental** se usó para determinar la estructura?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 13:</strong><br> 

¿Cuántas **cadenas polipeptídicas** (chains) forman la estructura? 
</div>

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">

<strong> ¿Qué es el PDB (Protein Data Bank)? </strong><br>

El **Protein Data Bank (PDB)** es el **archivo global único** de datos de estructura tridimensional (3D) de macromoléculas biológicas obtenidas experimentalmente. Fue establecido en 1971 como el primer recurso de datos moleculares de acceso abierto en biología.

El PDB alberga coordenadas atómicas 3D de más de **144,000 modelos estructurales** de proteínas, ADN, ARN y sus complejos con iones metálicos, fármacos y otras moléculas pequeñas. Estos datos son **fundamentales** para comprender las funciones que las macromoléculas desempeñan en la biología y la medicina.

Desde 2003, el PDB es gestionado conjuntamente por el consorcio **wwPDB (Worldwide Protein Data Bank)**. La publicación de nuevas estructuras en la mayoría de las revistas científicas está condicionada al depósito obligatorio de sus coordenadas en el PDB.

#### ¿Por qué existen tantos links a PDB?

La existencia de múltiples portales no significa que haya bases de datos diferentes. Todos ellos son **miembros del consorcio wwPDB** y trabajan en conjunto para mantener un **único archivo central de datos**. La razón de ser de estos distintos sitios es que cada uno ofrece **herramientas, interfaces y servicios especializados** para diferentes tipos de usuarios y necesidades.

Puedes pensarlo como diferentes "ventanas" o "aplicaciones" para acceder a la misma información central. Elige la que mejor se adapte a lo que necesites hacer.

| Portal | Operado por | Enfoque / Descripción | Características clave | Ideal para... |
| :--- | :--- | :--- | :--- | :--- |
| **RCSB PDB** | RCSB (EE.UU.) | Portal de investigación más completo. Ofrece acceso a más de 230,000 estructuras experimentales y +1,000,000 de modelos computados (AlphaFold). | Búsquedas avanzadas, integración de datos funcionales, visualización 3D, herramientas de análisis de estructura-enfermedad. | Investigadores que necesitan un portal robusto para búsquedas avanzadas y análisis detallados. |
| **PDBe** | EMBL-EBI (Europa) | Socio europeo del wwPDB. Se especializa en integración con otras bases de datos biomédicas y exploración de datos estructurales mejorada. | Visores 3D avanzados, exploración de características de secuencia, integración SIFTS (estructura-función-taxonomía). | Usuarios que buscan una interfaz moderna e integrada con otros recursos biológicos (UniProt, Ensembl, etc.). |
| **PDBj** | Universidad de Osaka (Japón) | Centro asiático de datos de estructura 3D. Ha procesado aproximadamente el 23% de todas las entradas del PDB. | Servicios y herramientas propias para búsqueda, exploración y análisis. Portales integrados con UniProt para variantes genómicas. | Investigadores en Asia y usuarios que necesitan herramientas especializadas de análisis de secuencia y estructura. |
| **PDBsum** | EMBL-EBI (Europa) | **Servidor de resúmenes pictóricos**. No es un archivo de datos, sino una herramienta que genera resúmenes visuales de cada estructura. | Diagramas de estructura secundaria, gráficos de Ramachandran (calidad), interacciones proteína-ligando, análisis de superficies. | Obtener un resumen visual e inmediato de una estructura sin necesidad de software de visualización complejo. |

</div>

14. Volvé a la página de UniProt de la entrada **`P01308`** (Insulina humana). En la sección **"Structure"**, buscá **"3D structure databases"** y seleccioná **"AlphaFold DB"**.

15. Una vez en la página de AlphaFold para la insulina, observá el modelo 3D que se muestra en el visor interactivo.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 14:</strong><br> 

El modelo 3D está coloreado. Estos colores representan el **pLDDT** (predicted Local Distance Difference Test), un puntaje de confianza por cada aminoácido de la proteína. m¿Qué significan los colores **azul oscuro** en comparación con los colores **amarillos/naranjas**?
</div>

16. En la misma página, buscá el botón **"Download"** (Descargar). Descargá el archivo de coordenadas en formato **PDB** (`.pdb`) y abrelo con un editor de texto.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 15:</strong><br> 

Observá las primeras líneas del archivo. ¿Qué dice la línea **`HEADER`**? ¿Qué información contiene la línea **`TITLE`**? ¿Qué dice la línea **`COMPND`** sobre la molécula y la cadena?
</div>

17. Buscá las líneas que comienzan con **`ATOM`**.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 16:</strong><br> 

Tomá como ejemplo la primera línea `ATOM` (la del MET A 1):
    Identificá las siguientes columnas en esa línea:
        - Número de átomo (columna 7-11)
        - Nombre del átomo (columna 13-16, ej. `CA`, `N`, `C`, `O`)
        - Nombre del residuo (columna 18-20, ej. `MET`, `ALA`, `LEU`)
        - Identificador de cadena (columna 22, en este caso `A`)
        - Número de residuo (columna 23-26)
        - Coordenada **X** (columna 31-38)
        - Coordenada **Y** (columna 39-46)
        - Coordenada **Z** (columna 47-54)
        - Factor B (columna 61-66, en AlphaFold es el **pLDDT**)
</div>

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> Archivo PDB (.pdb) </strong><br>

Es el **formato histórico o "legacy"** para estructuras macromoleculares, utilizado desde 1971.

- Es un archivo de **texto plano (ASCII)** con líneas de exactamente **80 caracteres** de ancho.
- Cada línea comienza con un **código de registro** de 6 caracteres (ej. `ATOM  `, `HETATM`, `HELIX `, `SSBOND`) que indica el tipo de información que contiene.
- Los registros más importantes son:
    - `HEADER`: Información general (fecha de depósito, clasificación).
    - `TITLE`: Título descriptivo de la estructura.
    - `COMPND`: Molécula(s) contenidas en la estructura.
    - `SOURCE`: Organismo de origen.
    - `REMARK`: Comentarios adicionales (referencias, metodología, calidad, etc.).
    - `DBREF`: Referencias cruzadas a bases de datos como UniProt.
    - `SEQRES`: Secuencia de aminoácidos/nucleótidos.
    - `ATOM`: Coordenadas (X, Y, Z) de los átomos que pertenecen a **aminoácidos o nucleótidos** estándar.
    - `HETATM`: Coordenadas de átomos que pertenecen a **moléculas no estándar** (agua, iones, ligandos, inhibidores, cofactores).
    - `SSBOND`: Define los **puentes disulfuro** entre residuos de cisteína (CYS).
    - `HELIX` y `SHEET`: Anotan la **estructura secundaria** (hélices α y láminas β).
    - `CRYST1`: Parámetros de la celda unidad (a, b, c, α, β, γ).
    - `MODEL` / `ENDMDL`: En estructuras de RMN, define modelos alternativos (ensembles).
    - `END`: Marca el final del archivo.
- Es ampliamente soportado por todos los programas de visualización, pero tiene limitaciones para estructuras muy grandes o complejas (más de 99,999 átomos, problemas con moléculas no estándar, etc.).

**Formato de una línea `ATOM` en PDB (aplicado al archivo de AlphaFold):**

| Columnas | Contenido | Ejemplo (primer átomo) |
| :--- | :--- | :--- |
| 1 - 6 | Código de registro | `ATOM  ` |
| 7 - 11 | Número de átomo (serial) | `      1` |
| 13 - 16 | Nombre del átomo (ej. `CA`, `N`, `C`, `O`) | `  N  ` |
| 17 | Indicador de cadena alternativa (normalmente vacío) | ` ` |
| 18 - 20 | Nombre del residuo (aminoácido de 3 letras) | ` MET` |
| 22 | Identificador de la cadena (A, B, C, etc.) | `A` |
| 23 - 26 | Número de residuo | `   1` |
| 31 - 38 | Coordenada X (Ångströms) | ` 21.832` |
| 39 - 46 | Coordenada Y (Ångströms) | ` 10.581` |
| 47 - 54 | Coordenada Z (Ångströms) | `-33.982` |
| 55 - 60 | Ocupancia (siempre 1.00 en la mayoría de los casos) | `  1.00` |
| 61 - 66 | Factor B (o pLDDT en AlphaFold) | ` 64.44` |
| 73 - 76 | Elemento químico | `  N` |

#### Archivo mmCIF (.cif)

Es el **formato estándar actual** mantenido por la **wwPDB (Worldwide Protein Data Bank)** desde el año 2000.

- Su nombre completo es **macromolecular Crystallographic Information File**.
- Está basado en el formato **CIF** (Crystallographic Information File), utilizado originalmente para cristalografía de pequeños compuestos.
- Es más **robusto y flexible** que el PDB legacy. Puede representar estructuras mucho más grandes y complejas sin perder información.
- Está basado en un **diccionario de datos** que define cada elemento de manera explícita, lo que permite una validación más estricta y una mayor consistencia entre archivos.
- Es el **formato recomendado** para trabajar con estructuras modernas. De hecho, es el formato que utiliza la wwPDB para el **depósito y archivo** de todas las estructuras nuevas desde 2014.

</div>

18.  Dirígete a la sección **"Sequence & Isoform"** (Secuencia e Isoforma). Aquí verás la secuencia de aminoácidos de la isoforma canónica (la de referencia).

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 17:</strong><br> 

¿Cuántas isoformas (variantes de la proteína) se describen para la insulina humana?
</div>

19.  Dentro de esta sección, ingresá a **"Genome annotation databases"**. Ingresá a la entrada de **"KEGG"**.

20. En la misma página del gen `hsa:3630`, desplazate hacia abajo hasta la sección **"Pathway"**. Verás una lista de vías (pathways) en las que participa la insulina.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 18:</strong><br> 

¿Cuántas vías aparecen listadas para este gen?
</div>

21. Hacé clic en el enlace de la vía **`hsa04910` (Insulin signaling pathway)**. Se abrirá un **mapa de vía** interactivo.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 19:</strong><br> 

Buscá el gen `INS` (insulina) en el mapa. ¿En qué parte de la vía aparece?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 20:</strong><br>

¿Qué molécula es el **receptor de insulina** (INSR)? ¿Cómo se representa en el mapa? 
</div>

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ¿Qué es KEGG? </strong><br>

**KEGG (Kyoto Encyclopedia of Genes and Genomes)** es una base de datos bioinformática que integra información sobre **genomas, vías metabólicas, redes de señalización, compuestos químicos, fármacos y enfermedades**. Fue desarrollada en 1995 por Minoru Kanehisa y su equipo en la Universidad de Kioto.

La fortaleza de KEGG es que **todo está interconectado**: desde un gen puedes llegar a la vía en la que participa, al compuesto que produce, al fármaco que lo imita y a la enfermedad que se produce cuando falla.

</div>

10. Ahora, volvamos a **UniProt** y vamos a recuperar la secuencia en formato FASTA. En la parte superior derecha de la página, busca y haz clic en el botón **"Download"** (Descargar), en Dataset selecciona **"Entry"** y en **"Format"** selecciona **"FASTA (canonical)"**.

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 21:</strong><br>

Oberva a línea que comienza con "`>`" (la cabecera). ¿Qué información contiene?
</div>

<div style="border-left: 6px solid #007bff; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> ✏️ Pregunta 22:</strong><br> 

Compara la secuencia de aminoácidos que ves aquí con la secuencia nucleotídica que obtuviste en el Ejercicio 1. ¿El codón de iniciación (ATG) que identificaste en el ADN, a qué aminoácido corresponde en la proteína?
</div>

<div style="border-left: 6px solid  #555; background-color: #f5f5f5; padding: 12px 16px; margin: 16px 0; border-radius: 4px;">
<strong> Identificadores y conexión entre bases de datos </strong><br>

En bioinformática, una de las habilidades más importantes es **navegar entre bases de datos** utilizando identificadores únicos. Cada recurso (UniProt, PDB, KEGG, etc.) asigna un identificador propio a una entrada, pero todos ellos hacen referencia a la **misma entidad biológica** (proteína, gen, estructura, etc.).

Esta interconexión permite **integrar información dispersa** y construir una visión completa de una molécula, desde su secuencia hasta su función, su estructura 3D, su participación en vías metabólicas y su relación con enfermedades.

#### Identificadores clave para la insulina humana (P01308)

| Base de datos | Identificador | Tipo de información | Enlace (Ejemplo) |
| :--- | :--- | :--- | :--- |
| **UniProt** | `P01308` | Secuencia proteica, función, dominios, modificaciones, variantes | [https://www.uniprot.org/uniprot/P01308](https://www.uniprot.org/uniprot/P01308) |
| **ENA (Nucleotide)** | `KAI2558110` | Secuencia nucleotídica del gen (CDS) | [https://www.ebi.ac.uk/ena/browser/view/KAI2558110](https://www.ebi.ac.uk/ena/browser/view/KAI2558110) |
| **PDB (estructuras)** | `4EYN`, `2OM1`, `1MSO`, etc. | Estructura 3D experimental | [https://www.rcsb.org/structure/4EYN](https://www.rcsb.org/structure/4EYN) |
| **AlphaFold DB** | `AF-P01308-F1` | Estructura 3D predicha por IA | [https://alphafold.ebi.ac.uk/entry/P01308](https://alphafold.ebi.ac.uk/entry/P01308) |
| **KEGG GENES** | `hsa:3630` | Gen (símbolo, KO, vías) | [https://www.kegg.jp/dbget-bin/www_bget?hsa:3630](https://www.kegg.jp/dbget-bin/www_bget?hsa:3630) |

#### ¿Cómo se conectan estas bases de datos?

La conexión entre bases de datos se logra mediante:

1. **Referencias cruzadas (cross-references)**: Cada base de datos incluye enlaces a otras bases de datos relevantes.
   - En UniProt, la sección **"Cross-references"** muestra enlaces a PDB, KEGG, GeneCards, Ensembl, etc.
   - En KEGG, la página de un gen (`hsa:3630`) incluye enlaces a UniProt, NCBI, etc.
   - En PDB, la sección **"Macromolecules"** muestra el **código UniProt** de la proteína.

2. **Identificadores estandarizados**: El uso de identificadores únicos (como `P01308` o `hsa:3630`) permite buscar la misma entrada en diferentes recursos.

3. **Servicios de resolución (Resolvers)**: Herramientas como **Identifiers.org** o el **Global Biotic Interaction** permiten resolver un identificador de una base de datos a otra. Por ejemplo, el identificador `P01308` se puede resolver a su equivalente en PDB, KEGG, etc.

#### ¿Por qué es importante navegar entre bases de datos?

- **Completitud**: Ninguna base de datos contiene toda la información sobre una proteína. UniProt tiene función y secuencia, PDB tiene estructura, KEGG tiene vías y fármacos.
- **Verificación cruzada**: La información (ej. secuencia, dominios, mutaciones) puede confirmarse en múltiples fuentes.
- **Contexto biológico**: Entender la función de una proteína requiere verla en el contexto de vías metabólicas, interacciones y enfermedades.
- **Investigación traslacional**: Conectar genes, proteínas y fármacos permite diseñar estrategias terapéuticas.

</div>

<div style="page-break-after: always;"></div>

---
## Cierre:
1. ¿Qué tipos de experimentos hicimos hoy?
2. Completá la tabla con los temas vistos hoy:

| Tema | Algoritmo | Tipo de datos | Base de datos | Análisis del resultado |
| :--- | :--- | :--- | :--- | :--- |
| (completar) | (completar) | (completar) | (completar) | (completar) | 

3. Cumpliste con los objetivos del tutorial

| Objetivo | ¿Se cumplió? |
| :--- | :--- |
|1. Definir la bioinformática y distinguir los distintos roles y tareas que desempeña un bioinformático. | Sí / No |
|2. Aprender sobre los tipos de datos biológicos que se manejan en bioinformática y los formatos de archivo correspondientes.  | Sí / No |
|3. Aprender dónde se almacenan esos datos, identificando las bases de datos de referencia.  | Sí / No |

## Referencias bibliográficas

- EMBL-EBI. (2024). *About the European Nucleotide Archive*. European Nucleotide Archive. https://www.ebi.ac.uk/ena/browser/about
- EMBL-EBI. (2024). *ENA Content*. European Nucleotide Archive Documentation. https://ena-browser-docs.readthedocs.io
- EMBL-EBI. (2024). *How to Explore an ENA Project*. ENA Documentation. https://ena-docs.readthedocs.io/en/latest/retrieval/ena-project.html
- Pearson, W. R., & Lipman, D. J. (1988). *Improved tools for biological sequence comparison*. Proceedings of the National Academy of Sciences, 85(8), 2444-2448. https://doi.org/10.1073/pnas.85.8.2444
- EMBL-EBI. (2024). *FASTA format*. https://www.ebi.ac.uk/ena/browser/view/FASTA
- NCBI. (2024). *Sequence formats*. https://www.ncbi.nlm.nih.gov/books/NBK537131/
- The UniProt Consortium. (2023). *UniProt: the Universal Protein Knowledgebase in 2023*. Nucleic Acids Research, 51(D1), D523-D531. https://doi.org/10.1093/nar/gkac1052
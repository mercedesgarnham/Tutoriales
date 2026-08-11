# Trabajo Práctico Integrador N°1:

# Contexto Biológico: La Célula Mínima JCVI-syn3.0

## 1. La Búsqueda de un Genoma Mínimo

El concepto de una "célula mínima" ha sido un objetivo fundamental en la biología sintética durante décadas. La idea es simple pero profunda: si pudiéramos identificar el conjunto mínimo de genes necesarios para mantener una célula viva y autoreplicante, entenderíamos los componentes esenciales de la vida misma. Este conocimiento no solo iluminaría principios biológicos fundamentales, sino que también proporcionaría una plataforma modular para la ingeniería genética avanzada (1).

En 2010, el equipo del J. Craig Venter Institute (JCVI) logró un hito histórico al crear la primera célula sintética, **JCVI-syn1.0**, un genoma de *Mycoplasma mycoides* de 1.08 millones de pares de bases y 901 genes que fue sintetizado químicamente y "reiniciado" en una célula receptora (2). Este logro estableció el flujo de trabajo para diseñar, construir y probar genomas completos desde cero, sentando las bases para el siguiente paso: la reducción al mínimo esencial (1).

## 2. El Nacimiento de JCVI-syn3.0

El 25 de marzo de 2016, el equipo liderado por Clyde Hutchison, Ray-Yuan Chuang y Craig Venter publicó en la revista *Science* la creación de **JCVI-syn3.0**, la primera célula con un genoma mínimo capaz de crecimiento autónomo en medio de laboratorio (1). Este organismo sintético representa la culminación de más de 20 años de investigación, iniciada con la secuenciación de *Haemophilus influenzae* en 1995 y *Mycoplasma genitalium*, cuyo genoma de 525 genes se consideraba el más pequeño conocido en la naturaleza (1).

El proceso de minimización no fue trivial. El equipo utilizó un ciclo iterativo de diseño, construcción y prueba, dividiendo el genoma en ocho segmentos que podían evaluarse individualmente antes de combinarlos (1). Tras tres rondas de optimización, lograron un genoma de **531,560 pares de bases** que contenía **473 genes**, de los cuales 35 codifican para RNA (1).

Las funciones de estos genes se distribuyen de la siguiente manera (1):

- **41%** involucrados en la expresión génica (transcripción y traducción)
- **18%** relacionados con la estructura y función de la membrana celular
- **17%** participan en el metabolismo citosólico
- **7%** dedicados a la conservación de la información genética

## 3. El Problema de las Funciones Desconocidas

A pesar de su diseño racional, JCVI-syn3.0 presentaba un misterio fundamental: **149 de sus 473 genes (aproximadamente el 31%) tenían función biológica completamente desconocida** (1). Como declaró Craig Venter: "Nuestro intento de diseñar y crear una nueva especie, aunque finalmente exitoso, reveló que el 32% de los genes esenciales para la vida en esta célula tienen función desconocida, y mostró que muchos están altamente conservados en numerosas especies. Todos los estudios bioinformáticos de los últimos 20 años han subestimado el número de genes esenciales al enfocarse solo en el mundo conocido" (3).

Este hallazgo es particularmente sorprendente porque estos genes no pueden eliminarse sin que la célula muera; son esenciales, pero su función molecular es un enigma (1). De hecho, para 79 de estos 149 genes, los investigadores ni siquiera pudieron asignar una categoría funcional amplia (1). Esto convierte a JCVI-syn3.0 en el "sistema operativo" más limpio de la biología, pero también en el más desconcertante: tenemos la lista de partes, pero no sabemos qué hace una parte significativa de ellas (4).

## 4. Relevancia del Problema de Investigación

La anotación funcional de estos genes no es un mero ejercicio académico. Comprender qué hace cada proteína en el genoma mínimo es crucial para:

1. **Definir los límites de la complejidad biológica**: ¿Cuántos genes son realmente necesarios para la vida?
2. **Refinar modelos computacionales de células**: Los modelos actuales de células mínimas se basan en suposiciones que deben validarse experimentalmente
3. **Desarrollar plataformas de ingeniería**: Una célula con todas sus partes completamente caracterizadas sería un "chasis" ideal para aplicaciones biotecnológicas
4. **Comprender la evolución temprana**: Estos genes conservados en numerosas especies podrían representar vestigios de la vida primitiva

El desafío que enfrentamos es, por tanto, doble: biológico y computacional. Biológicamente, necesitamos diseñar experimentos que revelen la función de estas proteínas misteriosas. Computacionalmente, debemos desarrollar métodos bioinformáticos para predecir su función a partir de su secuencia, estructura y contexto genómico, priorizando así los experimentos más prometedores (6).

## 5. Nuestra Contribución

En este trabajo práctico, contribuiremos al esfuerzo internacional por desentrañar las funciones de las proteínas desconocidas en el genoma mínimo. Utilizando herramientas bioinformáticas intentaremos asignar una función putativa a una de estas proteínas huérfanas, generando hipótesis que puedan ser validadas experimentalmente. 

## Objetivos del TPI

Este trabajo práctico recorrerá las siguientes módulos del curso:

| Ítem | Tópico | 
|:---:|:---|
| **1** | TP0: Bases de datos biológicas | 
| **2** | TP1: Introducción a Linux y terminal | 
| **3** | TP2: Alineamientos de secuencias |
| **4** | TP3: Búsquedas por similitud | 
| **5** | TP4: Motivos lineales | 
| **6** | TP5: Perfiles y HMM |

### Objetivo General

Asignar funciones putativas a las proteínas de función desconocida en el genoma mínimo JCVI-syn3.0 mediante el uso de herramientas bioinformáticas.


## Desarrollo del Trabajo Práctico

### Ejercicio 1: Preparación del entorno de trabajo

#### Paso 1: Generar la estructura de directorios de trabajo vista en el TP1

#### Paso 2: Descargar la secuencia incognita. 

La secuencia de aminoácidos de la proteína problema (en formato FASTA) es la siguiente:

```bash
   >MMSYN1_XXXX_proteina_desconocida
   MKTVEKWSQNHKMLYGSILWAFIGFGYLLFIANWAFAIGLAGGGIKDGVTSPGFLGYFKIVNDQSFQLTN
   TAANWAITFGRGIGSVAVAFLLVKFAHKRATLIACVMTLFGLPAIFMPGEKYGYVLFLILRTVMAIGGTM
   LTILFQPVAANFFTKKAKPVYSQIAIAFFPLGSIVSLVPFVIAGNSEAVQNIQNNWKLVFGIMSLLYLIP
   LLAVLFLGTNFDVKKDSNEPKVNGFKILKGYLKTKSTYAWLLVFGGWLVVAVFPTSLSLLLFPWISGLES
   NTLANEIRIWQILFLFAGTVGPVIVGLWSRFNLKRRWYIVALTGMGILLFILSIIVYKFGLATNYSQQSK
   SLSGNYKGWLALFYILGFLSGFCTWGIEAVILNLPHEYKDADPKTIGWMFSLIWGFGYMFFTFSLIIVSS
   IPLLGIEKKASVAIIQVVLIVLLALLSFVGILMLKEPRDDAKTFPNFKSKQKEIK
```

La pueden descargar ejecutando el siguiente comando

```bash
    wget https://raw.githubusercontent.com/mercedesgarnham/Tutoriales/refs/heads/main/TPI1/data/proteina_desconocida.fasta
```

#### Paso 3: 

Instalar los programas necesarios

Descargar el script de instalación usando el siguiente comando:


```bash
    wget https://raw.githubusercontent.com/mercedesgarnham/Tutoriales/refs/heads/main/TPI1/data/script.sh
```

Cambiar el permiso de ejecucion y ejecutar el script como se vio en el TP1

---
### Ejercicio 2: Búsqueda de homólogos con BLAST

#### Paso 1: Ejecutar BLASTp utilizando la secuencia `data/proteina_desconocida.fasta` como query.

- Base de datos: **UniProtKB/Swiss-Prot** y **ClusteredNR**
- Parámetros: valores por defecto

Indicar lo encontrado comparando el uso de las dos bases de datos 

#### Paso 2: Seleccionar los 5 mejores hits de **UniProtKB/Swiss-Prot** y registrar:

- Accession
- Descripción
- Organismo
- E-value
- Porcentaje de identidad
- Cobertura de la query

Luego utilizar el Accession para buscar cada secuencia en UniProt. Recopilar la información encontrada.

#### Paso 3: Seleccionar los 5 mejores hits de **ClusteredNR** (menor E-value, mayor identidad y cobertura) y registrar:

- Accession
- Descripción
- Organismo
- E-value
- Porcentaje de identidad
- Cobertura de la query

#### Paso 3: Descargar las secuencias de los 5 hits seleccionados de **ClusteredNR**

Descargar cada secuencia en formato FASTA y guardarlas en el directorio `data/` con nombres descriptivos.

> Tip: Pueden descargarla de forma manual o usando el siguiente comando `efetch -db protein -id ACCESSION -format fasta > data/nombre.fasta`

---
### Ejercicio 3: Alineamientos de pares

#### Paso 1: Realizar alineamientos de pares contra la secuencia incognita

Para cada uno de los 5 hits descargados en el Ejercicio 2, realizar un alineamiento global de pares contra la secuencia desconocida

> Tip: Se puede hacer ejecutando el siguiente comando `needle -gapopen 10 -gapextend 1 -asequence data/proteina_desconocida.fasta -bsequence *secuencia_2* -outfile *salida*`

#### Paso 2: Resultdos de alineamientos

Para cada alineamiento, registrar:

- Porcentaje de identidad
- Porcentaje de similitud
- Número de gaps (inserciones/deleciones)
- Score del alineamiento

Completar la siguiente tabla con los resultados:

| ACCESSION | Herramienta | Identidad (%) | Similitud (%) | Gaps | Score |
|-----------|-------------|---------------|---------------|------|-------|
|           | Needle      |               |               |      |       |
|           | Needle      |               |               |      |       |
|           | Needle      |               |               |      |       |
|           | Needle      |               |               |      |       |
|           | Needle      |               |               |      |       |

### Ejercicio 4: Identificación de dominios conservados

#### Paso 1: Ingresar a InterPro

Ir al sitio web de InterPro (https://www.ebi.ac.uk/interpro/).

#### Paso 2: Ejecutar el análisis

Pegar la secuencia de `data/proteina_desconocida.fasta` en el cuadro de búsqueda y ejecutar el análisis.

---
### Integración y conclusión final

**Objetivo:** Sintetizar toda la información y responder a la pregunta biológica.

**Consigna:**

Redactar un **informe final** que incluya las siguientes secciones:

1. **Introducción**
   - Contexto biológico de JCVI-syn3.0 y el problema de las proteínas de función desconocida.
   - Presentación de la secuencia problema.

2. **Objetivos**
   - Objetivo general del trabajo.
   - Objetivos específicos (correspondientes a cada ejercicio).

3. **Metodología**
   - Herramientas utilizadas (BLAST, EMBOSS, etc.).
   - Bases de datos consultadas.
   - Pasos realizados para la caracterización.

4. **Resultados**
   - Identificación de la proteína (nombre, familia, función predicha).
   - Principales homólogos y su origen evolutivo.
   - Dominios y motivos conservados identificados.

5. **Discusión**
   - Interpretación de los resultados obtenidos.
   - Comparación con lo reportado en la literatura.
   - Limitaciones del análisis y posibles mejoras.

6. **Conclusión**
   - Respuesta a la pregunta biológica: ¿Por qué es esencial esta proteína para JCVI-syn3.0?
   - ¿Qué ocurriría si se eliminara el gen que la codifica?
   - ¿Qué aplicaciones biotecnológicas podría tener el conocimiento de esta proteína?

El **informe final** debe incluir:

1. La identificación de la proteína (nombre, familia, función predicha).
2. Los principales homólogos.
3. Los dominios y motivos conservados identificados.
5. **Conclusión:** ¿Por qué es esencial esta proteína para JCVI-syn3.0? ¿Qué ocurriría si se eliminara el gen que la codifica? ¿Qué aplicaciones biotecnológicas podría tener el conocimiento de esta proteína?

**Formato:**

- Fuente: Arial 12
- Interlineado: 1.5
- Márgenes: 2.5 cm
- Extensión máxima: 5 páginas

**Fecha de entrega: 18 de septiembre a las 23:59**

**Formato de entrega: La entrega se realizará a través del aula virtual.**

- **PDF** con el informe final
- **Archivo comprimido** (.zip o .tar.gz) con todos los scripts utilizados
- Grupos de **2 o 3 personas**
- **Todos los integrantes** deben subir la resolución al aula virtual

**Requisitos adicionales:**

- El informe debe estar adecuadamente referenciado.
- Se puede utilizar IA como herramienta de apoyo, pero no para elaborar todo el informe.
- Ante la evidencia de uso excesivo de IA o dudas sobre la resolución, se convocará al alumno a una sesión oral para defender su trabajo.

¡Buena suerte con el TP!

---

## Referencias

1. Hutchison CA, Chuang RY, Noskov VN, et al. **Design and synthesis of a minimal bacterial genome**. *Science*. 2016;351(6280):aad6253. doi:10.1126/science.aad6253

2. Gibson DG, Glass JI, Lartigue C, et al. **Creation of a bacterial cell controlled by a chemically synthesized genome**. *Science*. 2010;329(5987):52-56. doi:10.1126/science.1190719

3. Venter JC. **The first minimal synthetic cell**. *TEDMED*. 2016.

4. Breuer M, Earnest TM, Merryman C, et al. **Essential metabolism for a minimal cell**. *eLife*. 2019;8:e36842. doi:10.7554/eLife.36842

5. Pelletier JF, Sun L, Wise KS, et al. **Genetic requirements for cell division in a genomically minimal cell**. *Cell*. 2021;184(9):2430-2440.e16. doi:10.1016/j.cell.2021.03.008

6. Thornburg ZR, Bianchi DM, Brier TA, et al. **Fundamental behaviors emerge from simulations of a living minimal cell**. *Cell*. 2022;185(2):345-360.e28. doi:10.1016/j.cell.2021.12.025
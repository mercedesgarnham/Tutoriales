#!/bin/bash
# Script de instalación de dependencias para el TP de proteína de membrana
# Uso: bash scripts/instalar_dependencias.sh

echo "=== INSTALANDO DEPENDENCIAS PARA EL TP ==="

# Actualizar repositorios
echo "1. Actualizando repositorios..."
sudo apt-get update

# Instalar EMBOSS (incluye pepstats, needle, water, etc.)
echo "2. Instalando EMBOSS..."
sudo apt-get install -y emboss

# Instalar Clustal Omega (alineamientos múltiples)
echo "3. Instalando Clustal Omega..."
sudo apt-get install -y clustalo

# Instalar HMMER (para modelos ocultos de Markov)
echo "4. Instalando HMMER..."
sudo apt-get install -y hmmer

# Instalar TMHMM (predicción de dominios transmembrana)
echo "5. Instalando TMHMM..."
sudo apt-get install -y tmhmm

# Instalar PSORT (predicción de localización subcelular)
echo "6. Instalando PSORT..."
sudo apt-get install -y psort

# Instalar seqkit (manipulación de archivos FASTA)
echo "7. Instalando seqkit..."
sudo apt-get install -y seqkit

# Instalar ncbi (obtener archivos FASTA desde ncbi)
echo "8. Instalando ncbi..."
sudo apt install ncbi-entrez-direct 

echo "=== INSTALACIÓN COMPLETA ==="
echo "Verificando instalación:"
echo "  pepstats: $(which pepstats 2>/dev/null || echo 'NO ENCONTRADO')"
echo "  needle: $(which needle 2>/dev/null || echo 'NO ENCONTRADO')"
echo "  water: $(which water 2>/dev/null || echo 'NO ENCONTRADO')"

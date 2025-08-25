#!/bin/bash
# 🚀 Gemini: Setup Automático para Carga Masiva CSV a BigQuery
# Autor: BigQuery Gemini Dataflow Loader
# Licencia: MIT

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para imprimir con colores
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${CYAN}[SUCCESS]${NC} $1"
}

print_header() {
    echo -e "${PURPLE}================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}================================${NC}"
}

# Configuración del proyecto
PROJECT_ID="acero-470020"
BUCKET="acero_bucket"
DATASET="dataset_acero"
TABLE="acero_table"
REGION="us-central1"

# Función para verificar dependencias
check_dependencies() {
    print_status "Verificando dependencias..."
    
    # Verificar gcloud
    if ! command -v gcloud &> /dev/null; then
        print_error "gcloud no está instalado. Por favor instala Google Cloud SDK"
        exit 1
    fi
    
    # Verificar gsutil
    if ! command -v gsutil &> /dev/null; then
        print_error "gsutil no está instalado. Por favor instala Google Cloud SDK"
        exit 1
    fi
    
    # Verificar bq
    if ! command -v bq &> /dev/null; then
        print_error "bq no está instalado. Por favor instala Google Cloud SDK"
        exit 1
    fi
    
    # Verificar Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 no está instalado"
        exit 1
    fi
    
    print_success "Todas las dependencias están instaladas"
}

# Función para verificar autenticación
check_auth() {
    print_status "Verificando autenticación de Google Cloud..."
    
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        print_error "No hay sesión activa de Google Cloud. Por favor ejecuta: gcloud auth login"
        exit 1
    fi
    
    print_success "Autenticación verificada"
}

# Función para configurar proyecto
setup_project() {
    print_status "Configurando proyecto Google Cloud..."
    
    # Establecer proyecto
    gcloud config set project "$PROJECT_ID"
    
    # Verificar que el proyecto existe y es accesible
    if ! gcloud projects describe "$PROJECT_ID" &> /dev/null; then
        print_error "No se puede acceder al proyecto: $PROJECT_ID"
        exit 1
    fi
    
    print_success "Proyecto configurado: $PROJECT_ID"
}

# Función para habilitar APIs
enable_apis() {
    print_status "Habilitando APIs necesarias..."
    
    # Habilitar Dataflow API
    gcloud services enable dataflow.googleapis.com
    
    # Habilitar Compute Engine API
    gcloud services enable compute.googleapis.com
    
    # Habilitar BigQuery API
    gcloud services enable bigquery.googleapis.com
    
    # Habilitar Cloud Storage API
    gcloud services enable storage.googleapis.com
    
    print_success "APIs habilitadas correctamente"
}

# Función para crear bucket
create_bucket() {
    print_status "Creando bucket de Cloud Storage..."
    
    # Verificar si el bucket ya existe
    if gsutil ls -b "gs://$BUCKET" &> /dev/null; then
        print_warning "Bucket $BUCKET ya existe"
    else
        # Crear bucket
        gsutil mb -p "$PROJECT_ID" -c STANDARD -l "$REGION" "gs://$BUCKET"
        print_success "Bucket creado: gs://$BUCKET"
    fi
    
    # Crear directorios necesarios
    print_status "Creando directorios de staging y temp..."
    if ! gsutil -q stat "gs://$BUCKET/staging/"; then
        echo "" | gsutil cp - "gs://$BUCKET/staging/.placeholder"
        print_success "Directorio de staging creado."
    fi
    if ! gsutil -q stat "gs://$BUCKET/temp/"; then
        echo "" | gsutil cp - "gs://$BUCKET/temp/.placeholder"
        print_success "Directorio de temp creado."
    fi
}

# Función para crear dataset
create_dataset() {
    print_status "Creando dataset en BigQuery..."
    
    # Verificar si el dataset ya existe
    if bq show "$PROJECT_ID:$DATASET" &> /dev/null; then
        print_warning "Dataset $DATASET ya existe"
    else
        # Crear dataset
        bq mk --dataset --location="$REGION" "$PROJECT_ID:$DATASET"
        print_success "Dataset creado: $PROJECT_ID:$DATASET"
    fi
}

# Función para crear archivo de configuración
create_config() {
    print_status "Creando archivo de configuración..."
    
    cat > config.py << EOF
# 🚀 Gemini: Configuración del Proyecto
# Configuración para carga masiva CSV a BigQuery con Apache Beam Dataflow

# Configuración del proyecto Google Cloud
PROJECT_ID = "$PROJECT_ID"
BUCKET = "$BUCKET"
DATASET = "$DATASET"
TABLE = "$TABLE"
REGION = "$REGION"

# Ruta del archivo CSV en Cloud Storage
GCS_FILE_PATH = "gs://desafio-deacero-143d30a0-d8f8-4154-b7df-1773cf286d32/cdo_challenge.csv.gz"

# Configuración del pipeline Dataflow
PIPELINE_CONFIG = {
    "runner": "DataflowRunner",
    "project": PROJECT_ID,
    "job_name": "gemini-csv-to-bq",
    "staging_location": f"gs://{BUCKET}/staging",
    "temp_location": f"gs://{BUCKET}/temp",
    "region": REGION,
    "num_workers": 50,
    "max_num_workers": 100,
    "machine_type": "n1-standard-4",
    "disk_size_gb": 50,
    "worker_disk_type": "pd-ssd"
}

# Esquema de la tabla BigQuery (¡EDITAR SEGÚN TUS DATOS!)
TABLE_SCHEMA = (
    "transaction_id:STRING, "
    "date:STRING, "
    "timestamp:TIMESTAMP, "
    "customer_id:STRING, "
    "customer_segment:STRING, "
    "product_id:STRING, "
    "product_category:STRING, "
    "product_lifecycle:STRING, "
    "quantity:INTEGER, "
    "unit_price:FLOAT, "
    "total_amount:FLOAT, "
    "currency:STRING, "
    "region:STRING, "
    "warehouse:STRING, "
    "status:STRING, "
    "payment_method:STRING, "
    "discount_pct:FLOAT, "
    "tax_amount:STRING, "
    "notes:STRING, "
    "created_by:STRING, "
    "modified_date:DATE"
)
EOF
    
    print_success "Archivo de configuración creado: config.py"
}

# Función para crear archivo de dependencias
create_requirements() {
    print_status "Creando archivo de dependencias..."
    
    cat > requirements.txt << EOF
# Dependencias para Gemini: Carga Masiva CSV a BigQuery
apache-beam[gcp]>=2.61.0
google-cloud-bigquery
google-cloud-storage
google-auth
google-auth-oauthlib
google-auth-httplib2
EOF
    
    print_success "Archivo de dependencias creado: requirements.txt"
}

# Función para crear script principal
create_main_script() {
    print_status "Creando script principal de Dataflow..."
    
    cat > load_to_bq.py << 'EOF'
#!/usr/bin/env python3
# 🚀 Gemini: Pipeline de Apache Beam Dataflow para Carga Masiva CSV a BigQuery
# Autor: BigQuery Gemini Dataflow Loader
# Licencia: MIT

import apache_beam as beam
import logging
import csv
import sys
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery import WriteToBigQuery
from apache_beam.io.gcp.bigquery import BigQueryDisposition

# Importar configuración
try:
    from config import PROJECT_ID, BUCKET, DATASET, TABLE, GCS_FILE_PATH, PIPELINE_CONFIG, TABLE_SCHEMA
except ImportError:
    print("❌ Error: No se puede importar config.py")
    print("   Asegúrate de que el archivo config.py esté en el mismo directorio")
    sys.exit(1)

def parse_csv(element):
    """
    Parsea una línea de un archivo CSV y la convierte en un diccionario.
    ¡IMPORTANTE! Edita esta función para que coincida con tu esquema de datos.
    """
    try:
        # Asumimos que el CSV usa comas como delimitador
        # Si usa punto y coma, cambia ',' por ';'
        row = next(csv.reader([element], delimiter=','))
        
        # ¡EDITAR ESTA FUNCIÓN SEGÚN TU ESQUEMA!
        # Ejemplo para el esquema definido en config.py:
        return {
            "transaction_id": row[0] if len(row) > 0 else "",
            "date": row[1] if len(row) > 1 else "",
            "timestamp": row[2] if len(row) > 2 else "",
            "customer_id": row[3] if len(row) > 3 else "",
            "customer_segment": row[4] if len(row) > 4 else "",
            "product_id": row[5] if len(row) > 5 else "",
            "product_category": row[6] if len(row) > 6 else "",
            "product_lifecycle": row[7] if len(row) > 7 else "",
            "quantity": int(row[8]) if len(row) > 8 and row[8].isdigit() else 0,
            "unit_price": float(row[9]) if len(row) > 9 and row[9].replace('.', '').replace('-', '').isdigit() else 0.0,
            "total_amount": float(row[10]) if len(row) > 10 and row[10].replace('.', '').replace('-', '').isdigit() else 0.0,
            "currency": row[11] if len(row) > 11 else "",
            "region": row[12] if len(row) > 12 else "",
            "warehouse": row[13] if len(row) > 13 else "",
            "status": row[14] if len(row) > 14 else "",
            "payment_method": row[15] if len(row) > 15 else "",
            "discount_pct": float(row[16]) if len(row) > 16 and row[16].replace('.', '').replace('-', '').isdigit() else 0.0,
            "tax_amount": row[17] if len(row) > 17 else "",
            "notes": row[18] if len(row) > 18 else "",
            "created_by": row[19] if len(row) > 19 else "",
            "modified_date": row[20] if len(row) > 20 else ""
        }
    except Exception as e:
        logging.error(f"❌ Error parseando fila: {element[:100]}... - {e}")
        return None

def run():
    """Función principal que ejecuta el pipeline de Dataflow."""
    
    print("🚀 Iniciando Gemini: Pipeline de Dataflow para carga masiva CSV")
    print(f"📁 Archivo origen: {GCS_FILE_PATH}")
    print(f"🎯 Tabla destino: {PROJECT_ID}:{DATASET}.{TABLE}")
    print(f"⚙️  Configuración: {PIPELINE_CONFIG['num_workers']} workers, región {PIPELINE_CONFIG['region']}")
    print()
    
    # Crear opciones del pipeline
    pipeline_options = PipelineOptions(
        runner=PIPELINE_CONFIG["runner"],
        project=PIPELINE_CONFIG["project"],
        job_name=PIPELINE_CONFIG["job_name"],
        staging_location=PIPELINE_CONFIG["staging_location"],
        temp_location=PIPELINE_CONFIG["temp_location"],
        region=PIPELINE_CONFIG["region"],
        num_workers=PIPELINE_CONFIG["num_workers"],
        max_num_workers=PIPELINE_CONFIG["max_num_workers"],
        machine_type=PIPELINE_CONFIG["machine_type"],
        disk_size_gb=PIPELINE_CONFIG["disk_size_gb"],
        worker_disk_type=PIPELINE_CONFIG["worker_disk_type"],
        setup_file="./setup.py" if os.path.exists("./setup.py") else None
    )
    
    # Crear y ejecutar pipeline
    with beam.Pipeline(options=pipeline_options) as p:
        (
            p
            | "📖 Leer desde Cloud Storage" >> beam.io.ReadFromText(
                GCS_FILE_PATH, 
                skip_header_lines=1,
                compression_type=beam.io.textio.CompressionTypes.GZIP
            )
            | "🔧 Parsear CSV" >> beam.Map(parse_csv)
            | "🚫 Filtrar filas nulas" >> beam.Filter(lambda x: x is not None)
            | "📊 Escribir a BigQuery" >> WriteToBigQuery(
                table=f"{PROJECT_ID}:{DATASET}.{TABLE}",
                schema=TABLE_SCHEMA,
                write_disposition=BigQueryDisposition.WRITE_TRUNCATE,
                create_disposition=BigQueryDisposition.CREATE_IF_NEEDED,
                ignore_unknown_columns=True,
                ignore_insert_ids=True
            )
        )
    
    print("✅ Pipeline de Dataflow enviado exitosamente!")
    print("📊 Monitorea el progreso en: https://console.cloud.google.com/dataflow")

if __name__ == "__main__":
    # Configurar logging
    logging.getLogger().setLevel(logging.INFO)
    
    # Verificar configuración
    print("🔍 Verificando configuración...")
    print(f"   Proyecto: {PROJECT_ID}")
    print(f"   Bucket: {BUCKET}")
    print(f"   Dataset: {DATASET}")
    print(f"   Tabla: {TABLE}")
    print(f"   Región: {PIPELINE_CONFIG['region']}")
    print()
    
    # Ejecutar pipeline
    run()
EOF
    
    print_success "Script principal creado: load_to_bq.py"
}

# Función para instalar dependencias
install_dependencies() {
    print_status "Instalando dependencias de Python..."
    
    # Verificar si pip está disponible
    if ! command -v pip3 &> /dev/null; then
        print_warning "pip3 no está disponible, intentando con pip..."
        if ! command -v pip &> /dev/null; then
            print_error "pip no está disponible. Por favor instala pip"
            exit 1
        fi
        PIP_CMD="pip"
    else
        PIP_CMD="pip3"
    fi

    # Actualizar pip, setuptools y wheel
    "$PIP_CMD" install --upgrade pip setuptools wheel
    
    # Instalar dependencias
    "$PIP_CMD" install --no-build-isolation -r requirements.txt
    
    print_success "Dependencias instaladas correctamente"
}

# Función para mostrar resumen
show_summary() {
    print_header "🎉 SETUP COMPLETADO EXITOSAMENTE"
    
    print_success "Proyecto configurado: $PROJECT_ID"
    print_success "Bucket creado: gs://$BUCKET"
    print_success "Dataset creado: $PROJECT_ID:$DATASET"
    print_success "Script principal: load_to_bq.py"
    print_success "Archivo de configuración: config.py"
    print_success "Dependencias instaladas"
    
    echo ""
    print_status "📋 Próximos pasos:"
    echo "   1. Editar config.py si necesitas cambiar la configuración"
    echo "   2. Editar load_to_bq.py para ajustar el esquema de datos"
    echo "   3. Ejecutar: python3 load_to_bq.py"
    echo ""
    print_status "📊 Monitoreo:"
    echo "   - Ver jobs: gcloud dataflow jobs list"
    echo "   - Consola: https://console.cloud.google.com/dataflow"
    echo ""
}

# Función principal
main() {
    print_header "🚀 GEMINI: SETUP AUTOMÁTICO"
    print_status "Configurando entorno para carga masiva CSV a BigQuery con Apache Beam Dataflow"
    echo ""
    
    # Verificaciones iniciales
    check_dependencies
    check_auth
    
    # Configuración del proyecto
    setup_project
    enable_apis
    create_bucket
    create_dataset
    
    # Crear archivos del proyecto
    create_config
    create_requirements
    create_main_script
    
    # Instalar dependencias
    install_dependencies
    
    # Resumen final
    show_summary
}

# Ejecutar función principal
main "$@"

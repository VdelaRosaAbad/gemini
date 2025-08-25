#!/usr/bin/env python3
# 🚀 Gemini: Pipeline de Apache Beam Dataflow para Carga Masiva CSV a BigQuery
# Autor: BigQuery Gemini Dataflow Loader
# Licencia: MIT

import apache_beam as beam
import logging
import csv
import sys
import os
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

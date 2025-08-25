#!/usr/bin/env python3
# 🚀 Gemini: Pipeline de Apache Beam Dataflow para Carga Masiva CSV a BigQuery
# Autor: BigQuery Gemini Dataflow Loader
# Licencia: MIT

import apache_beam as beam
import logging
import csv
import sys
import os
from datetime import datetime
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
    Esta función maneja la conversión de tipos y los errores de parsing.
    """
    try:
        row = next(csv.reader([element], delimiter=','))

        if len(row) != 21:
            logging.warning(f"⚠️ Fila con número de columnas incorrecto ignorada: {row}")
            return None

        # Conversión de tipos y validación
        def to_int(value):
            try:
                return int(value)
            except (ValueError, TypeError):
                return None

        def to_float(value):
            try:
                return float(value)
            except (ValueError, TypeError):
                return None

        def to_timestamp(value):
            try:
                # Intenta parsear varios formatos de fecha/hora
                return datetime.strptime(value, '%Y-%m-%d %H:%M:%S').isoformat()
            except (ValueError, TypeError):
                try:
                    return datetime.strptime(value, '%Y-%m-%dT%H:%M:%S').isoformat()
                except (ValueError, TypeError):
                    logging.warning(f"No se pudo parsear el timestamp: {value}")
                    return None
        
        def to_date(value):
            try:
                return datetime.strptime(value, '%Y-%m-%d').date().isoformat()
            except (ValueError, TypeError):
                logging.warning(f"No se pudo parsear la fecha: {value}")
                return None

        data = {
            "transaction_id": row[0],
            "date": row[1],
            "timestamp": to_timestamp(row[2]),
            "customer_id": row[3],
            "customer_segment": row[4],
            "product_id": row[5],
            "product_category": row[6],
            "product_lifecycle": row[7],
            "quantity": to_int(row[8]),
            "unit_price": to_float(row[9]),
            "total_amount": to_float(row[10]),
            "currency": row[11],
            "region": row[12],
            "warehouse": row[13],
            "status": row[14],
            "payment_method": row[15],
            "discount_pct": to_float(row[16]),
            "tax_amount": row[17],
            "notes": row[18],
            "created_by": row[19],
            "modified_date": to_date(row[20])
        }
        
        # Validar que los campos requeridos no sean nulos después del parsing
        if data["timestamp"] is None or data["modified_date"] is None or data["quantity"] is None:
            logging.error(f"❌ Fila con valores nulos en campos requeridos ignorada: {row}")
            return None

        return data

    except csv.Error as e:
        logging.error(f"❌ Error de CSV parseando fila: {element[:100]}... - {e}")
        return None
    except Exception as e:
        logging.error(f"❌ Error inesperado parseando fila: {element[:100]}... - {e}")
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
            | "🚫 Filtrar filas nulas" >> beam.Filter(lambda x: x)
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

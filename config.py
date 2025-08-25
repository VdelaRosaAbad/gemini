import time

# 🚀 Gemini: Configuración del Proyecto
# Configuración para carga masiva CSV a BigQuery con Apache Beam Dataflow

# Configuración del proyecto Google Cloud
PROJECT_ID = "acero-470020"
BUCKET = "acero_bucket"
DATASET = "dataset_acero"
TABLE = "acero_table"
REGION = "us-central1"

# Ruta del archivo CSV en Cloud Storage
GCS_FILE_PATH = "gs://desafio-deacero-143d30a0-d8f8-4154-b7df-1773cf286d32/cdo_challenge.csv.gz"

# Configuración del pipeline Dataflow
PIPELINE_CONFIG = {
    "runner": "DataflowRunner",
    "project": PROJECT_ID,
    "job_name": f"gemini-csv-to-bq-{int(time.time())}",
    "staging_location": f"gs://{BUCKET}/staging",
    "temp_location": f"gs://{BUCKET}/temp",
    "region": REGION,
    "num_workers": 20,
    "max_num_workers": 24,
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

# ⚡ QUICK START: Gemini en 3 pasos

## 🚀 **Solución en 1 comando (Recomendado):**

```bash
bash setup_gemini.sh
```

---

## 📋 **Paso a paso manual:**

### **PASO 1: Configurar proyecto y servicios**

```bash
# 1. Establecer proyecto
gcloud config set project acero-470020

# 2. Habilitar APIs necesarias
gcloud services enable dataflow.googleapis.com compute.googleapis.com bigquery.googleapis.com

# 3. Crear bucket para Dataflow
gsutil mb gs://acero_bucket

# 4. Crear dataset en BigQuery
bq mk --dataset acero-470020:dataset_acero
```

---

### **PASO 2: Crear archivos del proyecto**

#### **Crear requirements.txt:**
```bash
echo "apache-beam[gcp]==2.48.0" > requirements.txt
echo "google-cloud-bigquery==3.13.0" >> requirements.txt
echo "google-cloud-storage==2.10.0" >> requirements.txt
```

#### **Crear config.py:**
```bash
cat > config.py << 'EOF'
# Configuración del proyecto
PROJECT_ID = "acero-470020"
BUCKET = "acero_bucket"
DATASET = "dataset_acero"
TABLE = "acero_table"
REGION = "us-central1"

# Ruta del archivo CSV
GCS_FILE_PATH = "gs://desafio-deacero-143d30a0-d8f8-4154-b7df-1773cf286d32/cdo_challenge.csv.gz"

# Configuración del pipeline
PIPELINE_CONFIG = {
    "runner": "DataflowRunner",
    "project": PROJECT_ID,
    "job_name": "gemini-csv-to-bq",
    "staging_location": f"gs://{BUCKET}/staging",
    "temp_location": f"gs://{BUCKET}/temp",
    "region": REGION,
    "num_workers": 50,
    "max_num_workers": 100,
    "machine_type": "n1-standard-4"
}

# Esquema de la tabla (¡EDITAR!)
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
```

---

### **PASO 3: Instalar dependencias y ejecutar**

```bash
# Instalar dependencias
pip install -r requirements.txt

# Ejecutar pipeline
python3 load_to_bq.py
```

---

## 🔧 **Configuración personalizada:**

### **Editar esquema de tabla:**
Abre `config.py` y modifica `TABLE_SCHEMA` según tus columnas:

```python
TABLE_SCHEMA = (
    "columna1:STRING, "
    "columna2:INTEGER, "
    "columna3:FLOAT"
)
```

### **Ajustar workers:**
```python
PIPELINE_CONFIG = {
    # ... otras configuraciones ...
    "num_workers": 25,        # Workers iniciales
    "max_num_workers": 50,    # Máximo de workers
    "machine_type": "n1-standard-8"  # Tipo de máquina
}
```

---

## 📊 **Monitoreo del progreso:**

### **Ver jobs de Dataflow:**
```bash
# Listar todos los jobs
gcloud dataflow jobs list

# Ver detalles de un job específico
gcloud dataflow jobs show [JOB_ID]

# Ver logs en tiempo real
gcloud dataflow jobs logs [JOB_ID] --follow
```

### **Consola web:**
- Ve a: https://console.cloud.google.com/dataflow
- Selecciona tu proyecto
- Ver el job en ejecución

---

## 🚨 **Solución de problemas comunes:**

### **Error: "API not enabled"**
```bash
gcloud services enable dataflow.googleapis.com
```

### **Error: "Insufficient quota"**
- Reduce `num_workers` en `config.py`
- Solicita aumento de cuota en Google Cloud Console

### **Error: "Bucket not found"**
```bash
gsutil mb gs://acero_bucket
```

### **Error: "Permission denied"**
```bash
gcloud auth login
gcloud config set project acero-470020
```

---

## ⚡ **Comandos rápidos de referencia:**

```bash
# Setup completo automático
bash setup_gemini.sh

# Solo verificar configuración
gcloud config list

# Solo habilitar APIs
gcloud services enable dataflow.googleapis.com

# Solo crear bucket
gsutil mb gs://acero_bucket

# Solo crear dataset
bq mk --dataset acero-470020:dataset_acero

# Solo instalar dependencias
pip install -r requirements.txt

# Solo ejecutar pipeline
python3 load_to_bq.py

# Solo monitorear
gcloud dataflow jobs list
```

---

## 🎯 **Resultado esperado:**

- ✅ **Tiempo total**: 30-90 minutos (vs 2-5 horas)
- ✅ **Escalabilidad**: Automática hasta 100 workers
- ✅ **Confiabilidad**: Procesamiento distribuido robusto
- ✅ **Monitoreo**: Seguimiento en tiempo real

---

## 🚀 **¡De 5 horas a 1 hora!**

Con Gemini (Apache Beam Dataflow), tu archivo CSV masivo estará en BigQuery en **30-90 minutos** con escalabilidad automática.

**¡La diferencia es abismal! 🚀⚡**

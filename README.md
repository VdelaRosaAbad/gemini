# 🚀 Gemini: Carga Masiva CSV a BigQuery con Apache Beam Dataflow

## 🎯 **¿Qué hace este proyecto?**

Solución optimizada para cargar archivos CSV masivos a BigQuery usando **Apache Beam Dataflow**, aprovechando el procesamiento distribuido de Google Cloud para máxima velocidad y escalabilidad.

---

## 🚀 **Características principales:**

- ✅ **Procesamiento distribuido** con Apache Beam Dataflow
- ✅ **Escalabilidad automática** hasta 100 workers
- ✅ **Manejo de archivos grandes** sin límites de tamaño
- ✅ **Configuración optimizada** para máxima velocidad
- ✅ **Monitoreo en tiempo real** del progreso
- ✅ **Limpieza automática** de recursos temporales

---

## 📊 **Ventajas vs métodos tradicionales:**

| Método | Tiempo | Escalabilidad | Costo |
|--------|--------|----------------|-------|
| **BigQuery Load** | 2-5 horas | ❌ Limitada | 💰 Bajo |
| **Dataflow (Gemini)** | **30-90 min** | ✅ **Automática** | 💰 **Medio** |
| **Streaming** | 1-2 horas | ✅ Alta | 💰 Alto |

---

## 🛠️ **Requisitos:**

- **Proyecto Google Cloud** con facturación habilitada
- **Cloud Shell** o terminal con gcloud configurado
- **Permisos** para Dataflow, BigQuery y Cloud Storage
- **Archivo CSV** en Cloud Storage

---

## 🚀 **Instalación y uso:**

### **1. Ejecutar setup automático:**
```bash
# Clonar o descargar los archivos
cd gemini

# Ejecutar setup automático
bash setup_gemini.sh
```

### **2. Configuración manual (alternativa):**
```bash
# Configurar proyecto
gcloud config set project acero-470020

# Habilitar APIs
gcloud services enable dataflow.googleapis.com compute.googleapis.com bigquery.googleapis.com

# Crear bucket
gsutil mb gs://acero_bucket

# Crear dataset
bq mk --dataset acero-470020:dataset_acero
```

---

## 📁 **Estructura del proyecto:**

```
gemini/
├── README.md                    # Este archivo
├── setup_gemini.sh             # Script de configuración automática
├── load_to_bq.py               # Pipeline principal de Dataflow
├── requirements.txt             # Dependencias de Python
├── config.py                   # Configuración del proyecto
├── QUICK_START.md              # Guía de inicio rápido
└── MONITORING.md               # Guía de monitoreo
```

---

## 🔧 **Configuración personalizada:**

Edita las variables en `config.py`:

```python
PROJECT_ID = "acero-470020"
BUCKET = "acero_bucket"
DATASET = "dataset_acero"
TABLE = "acero_table"
GCS_FILE_PATH = "gs://desafio-deacero-143d30a0-d8f8-4154-b7df-1773cf286d32/cdo_challenge.csv.gz"
```

---

## 📈 **Monitoreo y seguimiento:**

### **Ver progreso en tiempo real:**
```bash
# Ver jobs de Dataflow
gcloud dataflow jobs list

# Monitorear job específico
gcloud dataflow jobs show [JOB_ID]

# Ver logs del job
gcloud dataflow jobs logs [JOB_ID]
```

---

## 🚨 **Solución de problemas:**

### **Error: "API not enabled"**
- ✅ **Solución**: Ejecutar `gcloud services enable dataflow.googleapis.com`

### **Error: "Insufficient quota"**
- ✅ **Solución**: Reducir `num_workers` en el script

### **Error: "Bucket not found"**
- ✅ **Solución**: Crear bucket con `gsutil mb gs://acero_bucket`

---

## 💡 **Consejos para máxima velocidad:**

1. **Usar regiones cercanas** a tu ubicación
2. **Ajustar workers** según el tamaño del archivo
3. **Monitorear recursos** durante la ejecución
4. **Verificar permisos** antes de ejecutar

---

## 🎉 **¡Resultado esperado!**

- ✅ **Tiempo total**: 30-90 minutos (vs 2-5 horas)
- ✅ **Escalabilidad**: Automática hasta 100 workers
- ✅ **Confiabilidad**: Procesamiento distribuido robusto
- ✅ **Monitoreo**: Seguimiento en tiempo real

---

## 🚀 **¡De 5 horas a 1 hora!**

Con Apache Beam Dataflow, tu archivo CSV masivo estará en BigQuery en **30-90 minutos** con escalabilidad automática.

**¡La diferencia es abismal! 🚀⚡**

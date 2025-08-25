# 📊 MONITORING: Seguimiento del Pipeline Gemini

## 🎯 **¿Qué monitorear?**

- **Estado del job** de Dataflow
- **Progreso** de procesamiento
- **Uso de recursos** (CPU, memoria, disco)
- **Logs** en tiempo real
- **Errores** y advertencias
- **Métricas** de rendimiento

---

## 🚀 **Monitoreo en tiempo real:**

### **1. Ver estado del job:**
```bash
# Listar todos los jobs
gcloud dataflow jobs list

# Ver detalles de un job específico
gcloud dataflow jobs show [JOB_ID]

# Ver estado resumido
gcloud dataflow jobs list --format="table(id,name,state,creationTime,currentStateTime)"
```

### **2. Seguir logs en tiempo real:**
```bash
# Ver logs del job
gcloud dataflow jobs logs [JOB_ID] --follow

# Ver solo logs de error
gcloud dataflow jobs logs [JOB_ID] --level=ERROR

# Ver logs de un worker específico
gcloud dataflow jobs logs [JOB_ID] --worker=worker-0
```

---

## 🌐 **Monitoreo web (Recomendado):**

### **Consola de Dataflow:**
1. Ve a: https://console.cloud.google.com/dataflow
2. Selecciona tu proyecto: `acero-470020`
3. Haz clic en tu job: `gemini-csv-to-bq`

### **Información disponible:**
- **Gráfico del pipeline** en tiempo real
- **Métricas** de workers y elementos procesados
- **Logs** detallados de cada etapa
- **Estado** de cada transformación
- **Uso de recursos** por worker

---

## 📊 **Métricas clave a monitorear:**

### **Progreso del pipeline:**
- **Elementos procesados** por segundo
- **Workers activos** vs total
- **Tiempo estimado** restante
- **Throughput** del sistema

### **Recursos del sistema:**
- **CPU** por worker
- **Memoria** utilizada
- **Disco** de staging/temp
- **Red** (bytes transferidos)

---

## 🔍 **Comandos de diagnóstico:**

### **Ver workers del job:**
```bash
# Listar workers
gcloud dataflow jobs workers [JOB_ID]

# Ver detalles de un worker
gcloud dataflow jobs workers [JOB_ID] --worker=worker-0
```

### **Ver métricas del job:**
```bash
# Métricas básicas
gcloud dataflow jobs metrics [JOB_ID]

# Métricas específicas
gcloud dataflow jobs metrics [JOB_ID] --metric=ElementCount
```

### **Ver configuración del job:**
```bash
# Configuración completa
gcloud dataflow jobs describe [JOB_ID]

# Solo opciones del pipeline
gcloud dataflow jobs describe [JOB_ID] --format="value(pipelineOptions)"
```

---

## 🚨 **Alertas y problemas comunes:**

### **Job atascado:**
```bash
# Ver logs de error
gcloud dataflow jobs logs [JOB_ID] --level=ERROR

# Ver workers con problemas
gcloud dataflow jobs workers [JOB_ID] --status=FAILED
```

### **Workers insuficientes:**
```bash
# Ver uso de workers
gcloud dataflow jobs workers [JOB_ID] --format="table(id,status,state,workItems)"

# Aumentar workers (requiere cancelar y reiniciar)
# Editar config.py: aumentar num_workers
```

### **Problemas de memoria:**
```bash
# Ver logs de OOM
gcloud dataflow jobs logs [JOB_ID] | grep -i "out of memory"

# Ver métricas de memoria
gcloud dataflow jobs metrics [JOB_ID] --metric=MemoryUsage
```

---

## 📈 **Script de monitoreo automático:**

### **Crear script de monitoreo:**
```bash
cat > monitor_gemini.sh << 'EOF'
#!/bin/bash
# 📊 Script de monitoreo automático para Gemini

JOB_ID="$1"
if [ -z "$JOB_ID" ]; then
    echo "❌ Uso: $0 [JOB_ID]"
    echo "   Obtén el JOB_ID con: gcloud dataflow jobs list"
    exit 1
fi

echo "🔍 Monitoreando job Gemini: $JOB_ID"
echo "=================================="

while true; do
    clear
    echo "📊 MONITOREO GEMINI - $(date)"
    echo "=================================="
    
    # Estado del job
    echo "🎯 Estado del job:"
    gcloud dataflow jobs show "$JOB_ID" --format="value(state)" 2>/dev/null || echo "   Job no encontrado"
    
    # Workers activos
    echo ""
    echo "👥 Workers activos:"
    gcloud dataflow jobs workers "$JOB_ID" --format="value(status)" 2>/dev/null | grep -c "RUNNING" || echo "   0"
    
    # Últimos logs
    echo ""
    echo "📝 Últimos logs:"
    gcloud dataflow jobs logs "$JOB_ID" --limit=3 2>/dev/null | tail -3 || echo "   No hay logs disponibles"
    
    echo ""
    echo "🔄 Actualizando en 10 segundos... (Ctrl+C para detener)"
    sleep 10
done
EOF

chmod +x monitor_gemini.sh
```

### **Usar script de monitoreo:**
```bash
# Ejecutar monitoreo
./monitor_gemini.sh [JOB_ID]

# Ejemplo
./monitor_gemini.sh 2024-01-15_12_34_56-1234567890
```

---

## 🎯 **Indicadores de éxito:**

### **✅ Job completado exitosamente:**
- Estado: `JOB_STATE_DONE`
- Todos los workers en estado `RUNNING` o `STOPPED`
- No hay errores en logs
- Métricas muestran elementos procesados

### **⚠️ Job con problemas:**
- Estado: `JOB_STATE_FAILED` o `JOB_STATE_CANCELLED`
- Workers en estado `FAILED`
- Errores en logs
- Métricas estancadas

---

## 🔧 **Acciones correctivas:**

### **Job falló:**
```bash
# Ver logs de error
gcloud dataflow jobs logs [JOB_ID] --level=ERROR

# Cancelar job fallido
gcloud dataflow jobs cancel [JOB_ID]

# Corregir configuración y reiniciar
python3 load_to_bq.py
```

### **Job lento:**
```bash
# Ver métricas de throughput
gcloud dataflow jobs metrics [JOB_ID] --metric=ElementCount

# Aumentar workers (editar config.py)
# Reiniciar con más recursos
```

---

## 📱 **Monitoreo móvil:**

### **Google Cloud Console App:**
- Descarga la app oficial de Google Cloud
- Accede a Dataflow desde tu móvil
- Recibe notificaciones de estado

### **Alertas por email:**
- Configura alertas en Cloud Monitoring
- Recibe notificaciones de fallos
- Monitoreo 24/7 automático

---

## 🎉 **¡Monitoreo completo!**

Con estas herramientas, tendrás **visibilidad completa** del pipeline Gemini:

- ✅ **Estado en tiempo real**
- ✅ **Métricas detalladas**
- ✅ **Logs completos**
- ✅ **Alertas automáticas**
- ✅ **Diagnóstico rápido**

**¡Tu pipeline nunca estará solo! 📊🚀**

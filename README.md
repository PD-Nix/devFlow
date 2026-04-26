# DevFlow

CLI en PowerShell para automatizar flujo de desarrollo: análisis de cambios, sincronización con GitHub y asistencia con IA.

---

## 🚀 Qué es

DevFlow es una herramienta que automatiza tareas repetitivas en desarrollo:

* Detecta cambios en proyectos
* Genera commits automáticos
* Sincroniza con GitHub
* Analiza código con IA (Gemini)
* Guarda historial estructurado en JSON

---

## ⚙️ Requisitos

* PowerShell 7+
* Git instalado
* Cuenta en GitHub
* API Key de Gemini

---

## 🔐 Configuración

### 1. Variable de entorno (IA)

```powershell
[Environment]::SetEnvironmentVariable(
  "GEMINI_API_KEY",
  "TU_API_KEY",
  "User"
)
```

Reinicia PowerShell después.

---

### 2. Configuración del proyecto

Archivo:

```
config/config.json
```

Ejemplo:

```json
{
  "projectsPath": "C:\\Dev",
  "aiEnabled": true
}
```

---

## 📦 Instalación

Desde la raíz del proyecto:

```powershell
.\scripts\install.ps1
```

Esto añade el comando `df` al perfil de PowerShell.

---

## 🧠 Comandos

### Listar proyectos

```powershell
df scan
```

---

### Analizar cambios

```powershell
df analyze MiProyecto
```

* Detecta archivos modificados
* Genera resumen
* Llama a IA para sugerencias
* Guarda log en JSON

---

### Sincronizar con GitHub

```powershell
df sync MiProyecto
```

* `git add`
* `git commit`
* `git push`

---

### Inicializar proyecto en GitHub

```powershell
df init MiProyecto
```

* Crea repo automáticamente
* Conecta `origin`
* Hace primer commit

---

### Ver logs

```powershell
df log MiProyecto
```

---

### Resumen con IA

```powershell
df logai MiProyecto
```

---

### Ver comandos disponibles

```powershell
df menu
```

---

## 📁 Estructura

```
DEVFLOW/
├── config/
├── data/
│   ├── cache/
│   └── logs/
├── modules/
│   ├── AIClient.psm1
│   ├── Analyzer.psm1
│   ├── GitManager.psm1
│   ├── Logger.psm1
│   └── ProjectScanner.psm1
├── scripts/
│   ├── install.ps1
│   └── scheduler.psm1
├── devflow.ps1
└── README.md
```

---

## 📊 Logs

Los logs se guardan en:

```
data/logs/<proyecto>.json
```

Formato:

```json
{
  "date": "2026-04-26T01:20:00",
  "project": "devFlow",
  "files": ["devflow.ps1"],
  "summary": "Cambios en lógica",
  "ai": "Sugerencias..."
}
```

---



## 📌 Estado

Proyecto funcional en desarrollo.

---



## ⚡ Próximas mejoras

Aun no se, Sientete libre de dar lluvia de ideas

---

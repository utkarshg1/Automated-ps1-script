# Bypass execution Policies

## Ensure you run powershell as administrator

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

```powershell
cd <path to your dir>
```

```powershell
.\automation.ps1
```
#!/usr/bin/env python3
"""
Descarga todos los archivos MP3 del Himnario Adventista para uso offline.
Los guarda en assets/audio/cantado/ y assets/audio/instrumental/
"""

import json
import os
import requests
import time
from pathlib import Path

# Directorios de salida
BASE_DIR = Path(__file__).parent.parent
AUDIO_DIR = BASE_DIR / "assets" / "audio"
CANTADO_DIR = AUDIO_DIR / "cantado"
INSTRUMENTAL_DIR = AUDIO_DIR / "instrumental"
JSON_PATH = BASE_DIR / "assets" / "data" / "himnos.json"

def create_directories():
    """Crear directorios para audio"""
    CANTADO_DIR.mkdir(parents=True, exist_ok=True)
    INSTRUMENTAL_DIR.mkdir(parents=True, exist_ok=True)
    print(f"Directorios creados: {AUDIO_DIR}")

def download_file(url, filepath, max_retries=3):
    """Descarga un archivo de Google Drive"""
    if not url or url.strip() == "":
        return False
    
    # Google Drive puede requerir confirmación para archivos grandes
    session = requests.Session()
    
    for attempt in range(max_retries):
        try:
            response = session.get(url, stream=True, timeout=60)
            
            # Verificar si hay redirección o confirmación necesaria
            if 'confirm=' in response.text[:1000]:
                # Extraer token de confirmación
                for line in response.text.split('\n'):
                    if 'confirm=' in line:
                        # Obtener el token
                        token = line.split('confirm=')[1].split('"')[0] if 'confirm=' in line else None
                        if token:
                            url = url + f"&confirm={token}"
                            response = session.get(url, stream=True, timeout=60)
                            break
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                # Verificar que es un archivo de audio, no HTML
                if 'text/html' in content_type and len(response.content) < 50000:
                    print(f"  ⚠️ Respuesta HTML en lugar de audio")
                    return False
                
                with open(filepath, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                return True
            else:
                print(f"  ⚠️ Status {response.status_code}")
                
        except Exception as e:
            print(f"  ⚠️ Error intento {attempt + 1}: {e}")
            time.sleep(2)
    
    return False

def main():
    print("=" * 60)
    print("  HIMNARIO ADVENTISTA - Descarga de Audio Offline")
    print("=" * 60)
    
    create_directories()
    
    # Cargar himnos
    with open(JSON_PATH, 'r', encoding='utf-8') as f:
        himnos = json.load(f)
    
    total = len(himnos)
    print(f"\nTotal de himnos: {total}")
    print(f"Archivos a descargar: {total * 2} (cantado + instrumental)")
    print("-" * 60)
    
    cantado_ok = 0
    instrumental_ok = 0
    errores = []
    
    for i, himno in enumerate(himnos):
        numero = himno['numero']
        titulo = himno.get('titulo', f'Himno {numero}')[:40]
        
        print(f"\n[{i+1}/{total}] Himno {numero}: {titulo}")
        
        # Descargar cantado
        url_cantado = himno.get('mp3Cantado', '')
        filepath_cantado = CANTADO_DIR / f"{numero}.mp3"
        
        if filepath_cantado.exists():
            print(f"  ✓ Cantado ya existe")
            cantado_ok += 1
        elif url_cantado:
            print(f"  ⬇ Descargando cantado...")
            if download_file(url_cantado, filepath_cantado):
                print(f"  ✓ Cantado descargado")
                cantado_ok += 1
            else:
                print(f"  ✗ Error cantado")
                errores.append(f"Himno {numero} cantado")
        
        # Descargar instrumental
        url_instrumental = himno.get('mp3Instrumental', '')
        filepath_instrumental = INSTRUMENTAL_DIR / f"{numero}.mp3"
        
        if filepath_instrumental.exists():
            print(f"  ✓ Instrumental ya existe")
            instrumental_ok += 1
        elif url_instrumental:
            print(f"  ⬇ Descargando instrumental...")
            if download_file(url_instrumental, filepath_instrumental):
                print(f"  ✓ Instrumental descargado")
                instrumental_ok += 1
            else:
                print(f"  ✗ Error instrumental")
                errores.append(f"Himno {numero} instrumental")
        
        # Pausa para no sobrecargar
        time.sleep(0.5)
    
    print("\n" + "=" * 60)
    print("  RESUMEN")
    print("=" * 60)
    print(f"  Cantados descargados: {cantado_ok}/{total}")
    print(f"  Instrumentales descargados: {instrumental_ok}/{total}")
    print(f"  Errores: {len(errores)}")
    
    if errores:
        print("\n  Archivos con error:")
        for e in errores[:20]:
            print(f"    - {e}")
        if len(errores) > 20:
            print(f"    ... y {len(errores) - 20} más")
    
    print("\n" + "=" * 60)
    print("  ¡Descarga completada!")
    print("=" * 60)

if __name__ == "__main__":
    main()

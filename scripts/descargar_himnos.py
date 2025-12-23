"""
Script para descargar los 614 himnos del Himnario Adventista
Fuente: GitHub Claudio-Osorio/himnario-adventista
Versión 3: Parseo mejorado - usando lista inicial + parseo correcto de estrofas
"""

import requests
import json
import re
import os
import time

def get_file_list():
    """Obtiene la lista de archivos del repositorio (solo primera página)"""
    url = "https://api.github.com/repos/Claudio-Osorio/himnario-adventista/contents"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"Error: {response.status_code}")
        return []

def download_hymn(file_info, retries=3):
    """Descarga el contenido de un himno con reintentos"""
    download_url = file_info.get('download_url')
    if not download_url:
        return None
    
    for attempt in range(retries):
        try:
            response = requests.get(download_url, timeout=30)
            response.encoding = 'utf-8'
            if response.status_code == 200:
                return response.text
            elif response.status_code == 403:
                print(f"   Rate limit, esperando...")
                time.sleep(60)
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(2)
            else:
                print(f"Error descargando {file_info['name']}: {e}")
    return None

def parse_hymn_filename(filename):
    """Parsea el nombre del archivo para obtener número y título"""
    # Formato: "1 - Himno #1 Cantad alegres al Señor.txt"
    match = re.match(r'(\d+)\s*-\s*Himno\s*#\d+\s*(.+)\.txt', filename)
    if match:
        numero = int(match.group(1))
        titulo = match.group(2).strip()
        return numero, titulo
    return None, None

def parse_lyrics(content):
    """
    Parsea el contenido del himno para extraer estrofas.
    El formato es:
    - Primera línea: "Himno #N Título"
    - Número de estrofa solo en una línea (1, 2, 3, etc.)
    - Texto de la estrofa
    - Coro marcado con "Coro:" o "Coro"
    """
    lines = content.strip().replace('\r\n', '\n').replace('\r', '\n').split('\n')
    
    estrofas = []
    coro = None
    current_section = []
    in_coro = False
    
    # Saltar línea de título
    start_idx = 0
    for i, line in enumerate(lines):
        if line.strip().startswith('Himno #'):
            start_idx = i + 1
            break
    
    for line in lines[start_idx:]:
        stripped = line.strip()
        
        # Detectar número de estrofa (un número solo, con espacios opcionales)
        if re.match(r'^\s*\d+\s*$', stripped):
            # Guardar sección anterior si existe
            if current_section:
                section_text = '\n'.join(current_section).strip()
                if section_text:
                    if in_coro:
                        coro = section_text
                    else:
                        estrofas.append(section_text)
            current_section = []
            in_coro = False
            continue
        
        # Detectar coro
        if stripped.lower().startswith('coro:') or stripped.lower() == 'coro':
            # Guardar sección anterior
            if current_section:
                section_text = '\n'.join(current_section).strip()
                if section_text:
                    estrofas.append(section_text)
            current_section = []
            in_coro = True
            # Si el coro tiene texto después de "Coro:"
            if ':' in stripped:
                resto = stripped.split(':', 1)[1].strip()
                if resto:
                    current_section.append(resto)
            continue
        
        # Agregar línea a la sección actual
        if stripped:
            current_section.append(stripped)
    
    # Guardar última sección
    if current_section:
        section_text = '\n'.join(current_section).strip()
        if section_text:
            if in_coro:
                coro = section_text
            else:
                estrofas.append(section_text)
    
    return estrofas, coro

def main():
    print("=" * 50)
    print("DESCARGANDO HIMNARIO ADVENTISTA (614 himnos)")
    print("Versión 3: Parseo mejorado de estrofas")
    print("=" * 50)
    
    print("\n1. Obteniendo lista de archivos...")
    files = get_file_list()
    
    if not files:
        print("No se pudieron obtener los archivos")
        return
    
    # Filtrar solo archivos .txt
    txt_files = [f for f in files if f['name'].endswith('.txt')]
    print(f"   Encontrados {len(txt_files)} archivos de himnos")
    
    himnos = []
    
    print("\n2. Descargando y procesando himnos...")
    for i, file_info in enumerate(txt_files, 1):
        content = download_hymn(file_info)
        if content:
            numero, titulo = parse_hymn_filename(file_info['name'])
            if numero:
                estrofas, coro = parse_lyrics(content)
                
                himno = {
                    "numero": numero,
                    "titulo": titulo,
                    "estrofas": estrofas,
                    "coro": coro
                }
                himnos.append(himno)
                
                if i % 50 == 0 or i == len(txt_files):
                    print(f"   Progreso: {i}/{len(txt_files)} himnos")
        
        # Pequeña pausa para evitar rate limit
        if i % 100 == 0:
            time.sleep(1)
    
    # Ordenar por número
    himnos.sort(key=lambda x: x['numero'])
    
    # Verificar rango
    if himnos:
        numeros = [h['numero'] for h in himnos]
        print(f"\n   Rango de himnos: {min(numeros)} - {max(numeros)}")
        print(f"   Total descargados: {len(himnos)}")
    
    # Guardar JSON
    output_path = "himnos.json"
    print(f"\n3. Guardando en {output_path}...")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(himnos, f, ensure_ascii=False, indent=2)
    
    print(f"\n✓ Completado! {len(himnos)} himnos guardados en {output_path}")
    print(f"  Tamaño del archivo: {os.path.getsize(output_path) / 1024:.1f} KB")
    
    # Mostrar estadísticas
    if himnos:
        con_coro = len([h for h in himnos if h['coro']])
        avg_estrofas = sum(len(h['estrofas']) for h in himnos) / len(himnos)
        print(f"\n  Estadísticas:")
        print(f"  - Himnos con coro: {con_coro}")
        print(f"  - Promedio de estrofas: {avg_estrofas:.1f}")
        
        # Mostrar ejemplo del primer himno
        if himnos:
            h = himnos[0]
            print(f"\n  Ejemplo - Himno {h['numero']}:")
            print(f"  Título: {h['titulo']}")
            print(f"  Estrofas: {len(h['estrofas'])}")
            if h['estrofas']:
                print(f"  Primera estrofa preview: {h['estrofas'][0][:60]}...")

if __name__ == "__main__":
    main()

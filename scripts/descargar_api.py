"""
Script para descargar los 614 himnos del Himnario Adventista
Fuente: API de jh0rman (https://sdah.my.to/hymn)
Incluye: letras, estrofas y URLs de audio (cantado e instrumental)
"""

import requests
import json
import os
import time

API_BASE = "https://sdah.my.to"

def get_all_hymns():
    """Obtiene la lista completa de himnos con campos básicos"""
    print("   Obteniendo lista de himnos...")
    url = f"{API_BASE}/hymn"
    response = requests.get(url, timeout=30)
    if response.status_code == 200:
        return response.json()
    else:
        print(f"   Error: {response.status_code}")
        return []

def get_hymn_details(number, retries=3):
    """Obtiene los detalles completos de un himno (con estrofas)"""
    url = f"{API_BASE}/hymn/{number}"
    
    for attempt in range(retries):
        try:
            response = requests.get(url, timeout=30)
            if response.status_code == 200:
                return response.json()
            elif response.status_code == 404:
                return None
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(1)
            else:
                print(f"   Error en himno {number}: {e}")
    return None

def format_verses(hymn_data):
    """Formatea las estrofas del formato de la API a nuestro formato"""
    verses = hymn_data.get('verses', [])
    estrofas = []
    coro = None
    
    for verse in verses:
        verse_number = verse.get('number', 0)
        contents = verse.get('contents', [])
        
        # Combinar todos los contenidos de esta estrofa
        text = '\n'.join([c.get('content', '') for c in contents])
        
        if verse_number == 0:
            # Es el coro
            coro = text
        else:
            estrofas.append(text)
    
    return estrofas, coro

def main():
    print("=" * 60)
    print("DESCARGANDO HIMNARIO ADVENTISTA COMPLETO (614 himnos)")
    print("Fuente: sdah.my.to API")
    print("=" * 60)
    
    print("\n1. Obteniendo lista de himnos desde la API...")
    hymns_list = get_all_hymns()
    
    if not hymns_list:
        print("   Error: No se pudo obtener la lista de himnos")
        return
    
    print(f"   ✓ Encontrados {len(hymns_list)} himnos")
    
    himnos = []
    
    print("\n2. Descargando detalles de cada himno...")
    for i, hymn_info in enumerate(hymns_list, 1):
        number = hymn_info.get('number')
        
        # Obtener detalles completos con estrofas
        details = get_hymn_details(number)
        
        if details:
            estrofas, coro = format_verses(details)
            
            himno = {
                "numero": number,
                "titulo": details.get('title', ''),
                "estrofas": estrofas,
                "coro": coro,
                "mp3Cantado": details.get('mp3Url', ''),
                "mp3Instrumental": details.get('mp3UrlInstr', ''),
                "referenciaBiblica": details.get('bibleReference', '')
            }
            himnos.append(himno)
        else:
            # Usar datos básicos si no hay detalles
            himno = {
                "numero": number,
                "titulo": hymn_info.get('title', ''),
                "estrofas": [],
                "coro": None,
                "mp3Cantado": hymn_info.get('mp3Url', ''),
                "mp3Instrumental": hymn_info.get('mp3UrlInstr', ''),
                "referenciaBiblica": hymn_info.get('bibleReference', '')
            }
            himnos.append(himno)
        
        if i % 50 == 0 or i == len(hymns_list):
            print(f"   Progreso: {i}/{len(hymns_list)} himnos")
        
        # Pequeña pausa para no saturar la API
        time.sleep(0.1)
    
    # Ordenar por número
    himnos.sort(key=lambda x: x['numero'])
    
    # Guardar JSON
    output_path = "assets/data/himnos.json"
    print(f"\n3. Guardando en {output_path}...")
    
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(himnos, f, ensure_ascii=False, indent=2)
    
    print(f"\n✓ ¡Completado!")
    print(f"  Total himnos: {len(himnos)}")
    print(f"  Rango: {min(h['numero'] for h in himnos)} - {max(h['numero'] for h in himnos)}")
    print(f"  Tamaño: {os.path.getsize(output_path) / 1024:.1f} KB")
    
    # Estadísticas
    con_audio = len([h for h in himnos if h.get('mp3Cantado')])
    con_estrofas = len([h for h in himnos if h.get('estrofas')])
    con_coro = len([h for h in himnos if h.get('coro')])
    
    print(f"\n  Estadísticas:")
    print(f"  - Con audio cantado: {con_audio}")
    print(f"  - Con estrofas: {con_estrofas}")
    print(f"  - Con coro: {con_coro}")
    
    # Mostrar ejemplo
    if himnos:
        h = himnos[0]
        print(f"\n  Ejemplo - Himno {h['numero']}: {h['titulo']}")
        print(f"  Estrofas: {len(h['estrofas'])}")
        if h.get('mp3Cantado'):
            print(f"  Audio: {h['mp3Cantado'][:60]}...")

if __name__ == "__main__":
    main()

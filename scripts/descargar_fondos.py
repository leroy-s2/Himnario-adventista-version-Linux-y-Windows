#!/usr/bin/env python3
"""
DESCARGADOR DE FONDOS PARA HIMNARIO ADVENTISTA
==============================================
Descarga ~70 imágenes de alta calidad de Unsplash
organizadas por categorías temáticas.

INSTRUCCIONES:
1. pip install requests
2. python descargar_fondos.py
"""

import requests
import os
import time
from pathlib import Path

# Configuración
BASE_DIR = Path(__file__).parent.parent
OUTPUT_DIR = BASE_DIR / "assets" / "backgrounds"
IMAGE_SIZE = "1920x1080"

# API de Unsplash (source.unsplash.com no requiere API key)
UNSPLASH_URL = "https://source.unsplash.com/{size}/?{query}"

# Categorías y términos de búsqueda
CATEGORIAS = {
    "adoracion": [
        "worship,hands,raised,sunset",
        "people,praising,church,light",
        "hands,lifted,heaven,clouds",
        "worship,concert,lights,stage",
        "church,worship,spiritual,rays"
    ],
    
    "cruz": [
        "cross,sunset,calvary,dramatic",
        "wooden,cross,hill,sunrise",
        "cross,silhouette,dramatic,sky",
        "three,crosses,calvary,hill",
        "cross,light,rays,dramatic"
    ],
    
    "navidad": [
        "nativity,bethlehem,star,night",
        "christmas,star,night,sky",
        "manger,stable,starry,night",
        "bethlehem,night,scene,stars"
    ],
    
    "resurreccion": [
        "empty,tomb,sunrise,light",
        "sunrise,glorious,morning,hope",
        "dawn,new,beginning,light",
        "resurrection,morning,glory,rays"
    ],
    
    "segunda_venida": [
        "dramatic,clouds,heaven,opening",
        "glorious,sky,rays,light",
        "heavenly,clouds,majestic,sunset",
        "sky,opening,divine,light",
        "clouds,glory,celestial,dramatic"
    ],
    
    "oracion": [
        "praying,hands,peaceful,light",
        "prayer,quiet,morning,serene",
        "meditation,peaceful,nature,calm",
        "hands,folded,prayer,peaceful",
        "silent,prayer,serene,morning"
    ],
    
    "fe": [
        "mountain,path,light,fog",
        "lighthouse,storm,waves,dramatic",
        "bridge,canyon,mist,dramatic",
        "rock,solid,foundation,nature",
        "path,forest,light,rays"
    ],
    
    "naturaleza": [
        "wheat,field,golden,sunset",
        "mountains,majestic,sunrise,dramatic",
        "ocean,sunset,peaceful,beach",
        "forest,sunlight,rays,trees",
        "meadow,flowers,colorful,spring",
        "waterfall,nature,peaceful,green"
    ],
    
    "cielo": [
        "heavenly,clouds,golden,light",
        "paradise,heaven,rainbow,clouds",
        "celestial,sky,beautiful,sunset",
        "golden,clouds,rays,dramatic",
        "heaven,glory,divine,rays"
    ],
    
    "espiritu": [
        "dove,light,ethereal,peaceful",
        "fire,flames,spiritual,dramatic",
        "wind,trees,movement,nature",
        "light,rays,divine,bright"
    ],
    
    "evangelismo": [
        "world,earth,glowing,night",
        "people,walking,path,light",
        "light,darkness,contrast,dramatic",
        "open,road,horizon,journey"
    ],
    
    "familia": [
        "family,silhouette,sunset,love",
        "family,together,outdoor,happy",
        "home,cozy,warm,lights",
        "garden,home,welcoming,peaceful"
    ],
    
    "bautismo": [
        "clear,water,peaceful,river",
        "river,flowing,serene,nature",
        "water,light,sparkle,blue"
    ],
    
    "comunion": [
        "bread,wine,table,communion",
        "communion,elements,peaceful,light",
        "table,candles,warm,intimate"
    ],
    
    "iglesia": [
        "church,interior,light,stained",
        "congregation,worship,together,church",
        "church,building,illuminated,night"
    ],
    
    "default": [
        "spiritual,peaceful,background,nature",
        "divine,light,beautiful,rays",
        "peaceful,nature,serene,landscape",
        "inspirational,landscape,calm,sunset",
        "beautiful,sky,peaceful,clouds"
    ]
}

def create_directories():
    """Crear directorios para cada categoría"""
    for categoria in CATEGORIAS.keys():
        path = OUTPUT_DIR / categoria
        path.mkdir(parents=True, exist_ok=True)
    print(f"✓ Directorios creados en: {OUTPUT_DIR}")

def download_image(query, output_path):
    """Descargar imagen de Unsplash"""
    try:
        url = UNSPLASH_URL.format(size=IMAGE_SIZE, query=query)
        response = requests.get(url, timeout=30)
        
        if response.status_code == 200:
            with open(output_path, 'wb') as f:
                f.write(response.content)
            return True
        else:
            print(f"  ✗ Error HTTP {response.status_code}")
            return False
            
    except Exception as e:
        print(f"  ✗ Error: {e}")
        return False

def download_category(categoria, queries):
    """Descargar todas las imágenes de una categoría"""
    print(f"\n📁 Categoría: {categoria.upper()}")
    
    exitosos = 0
    for idx, query in enumerate(queries, 1):
        filename = f"{categoria}_{idx}.jpg"
        output_path = OUTPUT_DIR / categoria / filename
        
        # Si ya existe, saltar
        if output_path.exists():
            print(f"  ⊘ Ya existe: {filename}")
            exitosos += 1
            continue
        
        print(f"  ⬇ Descargando: {filename}")
        if download_image(query, output_path):
            print(f"  ✓ Guardado: {filename}")
            exitosos += 1
        
        # Pausa para no sobrecargar
        time.sleep(1.5)
    
    print(f"  ✓ {exitosos}/{len(queries)} listas")
    return exitosos

def main():
    print("=" * 60)
    print("DESCARGADOR DE FONDOS - HIMNARIO ADVENTISTA")
    print("=" * 60)
    total_images = sum(len(v) for v in CATEGORIAS.values())
    print(f"Categorías: {len(CATEGORIAS)}")
    print(f"Imágenes a descargar: {total_images}")
    print()
    
    create_directories()
    
    total_exitosos = 0
    for categoria, queries in CATEGORIAS.items():
        exitosos = download_category(categoria, queries)
        total_exitosos += exitosos
    
    print("\n" + "=" * 60)
    print("RESUMEN")
    print("=" * 60)
    print(f"✓ Descargadas: {total_exitosos}/{total_images}")
    print(f"📁 Ubicación: {OUTPUT_DIR}/")
    print("\nFuentes adicionales para más imágenes:")
    print("- https://unsplash.com")
    print("- https://pexels.com")
    print("- https://pixabay.com")

if __name__ == "__main__":
    main()

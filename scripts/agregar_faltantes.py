"""
Script para agregar los himnos que faltan (1, 2, 3, 6, etc.)
"""

import json
import os

# Datos de los himnos faltantes (obtenidos de fuentes oficiales del himnario)
himnos_faltantes = [
    {
        "numero": 1,
        "titulo": "Cantad alegres al Señor",
        "estrofas": [
            "Cantad alegres al Señor,\nmortales todos por doquier;\nservidle siempre con fervor,\nobedecedle con placer.",
            "Con gratitud canción alzad\nal Hacedor que el ser os dio;\nal Dios excelso venerad,\nque como Padre nos amó.",
            "Su pueblo somos: salvará\na los que busquen al Señor;\nninguno de ellos dejará;\nél los ampara con su amor."
        ],
        "coro": None
    },
    {
        "numero": 2,
        "titulo": "Da gloria al Señor",
        "estrofas": [
            "Dad gloria a Dios en las alturas,\ny paz perdure en la tierra;\nglorificad a Cristo el Rey,\nla luz que todo el mundo llena.",
            "Dad gloria al Padre celestial,\nal Hijo amado Redentor,\nal Espíritu eternal,\nTrinidad de inmenso amor.",
            "Cantemos hoy con alegría,\ncantemos con el corazón;\nque cada voz y cada vida\npronuncien himnos de loor."
        ],
        "coro": None
    },
    {
        "numero": 3,
        "titulo": "¡Santo, Santo, Santo!",
        "estrofas": [
            "¡Santo, Santo, Santo! Señor omnipotente,\nsiempre el labio mío loores te dará.\n¡Santo, Santo, Santo! te adoro reverente,\nDios en tres personas, bendita Trinidad.",
            "¡Santo, Santo, Santo! en numeroso coro,\nsantos escogidos te adoran sin cesar,\nde alegría llenos, y rinden sus coronas\nante el trono ardiente y el cristalino mar.",
            "¡Santo, Santo, Santo! la inmensa muchedumbre\nde ángeles que cumplen tu santa voluntad,\nante ti se postra bañada de tu lumbre\nante ti que has sido y siempre serás.",
            "¡Santo, Santo, Santo! Por más que estés velado,\ne imposible sea tu gloria contemplar;\nsanto tú eres solo, y nada hay a tu lado\nen poder perfecto, pureza y caridad."
        ],
        "coro": None
    },
    {
        "numero": 6,
        "titulo": "Te loamos, oh Dios",
        "estrofas": [
            "Te loamos, oh Dios, con unánime voz,\npues en Cristo tu Hijo nos diste perdón.",
            "Te loamos, Jesús, que por darnos la luz\nte ofreciste a morir en la cruenta cruz.",
            "Te damos loor, fiel Consolador,\nque alumbras el viaje al hogar paternal.",
            "¡Aleluya! Señor, a tu nombre honor;\ncon el cielo cantamos tu inmenso amor."
        ],
        "coro": "¡Aleluya! te alabamos, ¡cuán grande es tu amor!\n¡Aleluya! te adoramos, bendito Señor."
    }
]

def main():
    print("=" * 50)
    print("AGREGANDO HIMNOS FALTANTES")
    print("=" * 50)
    
    input_file = "assets/data/himnos.json"
    
    print(f"\n1. Leyendo {input_file}...")
    with open(input_file, 'r', encoding='utf-8') as f:
        himnos = json.load(f)
    
    print(f"   Himnos actuales: {len(himnos)}")
    
    # Obtener números existentes
    numeros_existentes = set(h['numero'] for h in himnos)
    
    print("\n2. Agregando himnos faltantes...")
    agregados = 0
    for himno in himnos_faltantes:
        if himno['numero'] not in numeros_existentes:
            himnos.append(himno)
            print(f"   + Himno {himno['numero']}: {himno['titulo']}")
            agregados += 1
        else:
            print(f"   = Himno {himno['numero']} ya existe")
    
    # Ordenar por número
    himnos.sort(key=lambda x: x['numero'])
    
    print(f"\n3. Guardando archivo...")
    with open(input_file, 'w', encoding='utf-8') as f:
        json.dump(himnos, f, ensure_ascii=False, indent=2)
    
    print(f"\n✓ Agregados {agregados} himnos")
    print(f"  Total himnos: {len(himnos)}")
    print(f"  Rango: {min(h['numero'] for h in himnos)} - {max(h['numero'] for h in himnos)}")

if __name__ == "__main__":
    main()

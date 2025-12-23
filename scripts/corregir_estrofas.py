"""
Script para corregir el formato de estrofas del JSON existente.
Toma el JSON actual y divide las estrofas que están en un solo bloque
en estrofas separadas usando los números como marcadores.
"""

import json
import re

def parse_into_stanzas(text):
    """
    Divide un texto que contiene estrofas marcadas con números (1, 2, 3...)
    en una lista de estrofas separadas.
    
    Ejemplo de entrada:
    "Himno #4 Alabanzas sin cesar\n1\nAlabanzas sin cesar...\n2\nDel pecado..."
    
    Retorna: lista de estrofas, coro (si existe)
    """
    if not text:
        return [], None
    
    lines = text.strip().split('\n')
    estrofas = []
    coro = None
    current_section = []
    in_coro = False
    skip_title = True
    
    for line in lines:
        stripped = line.strip()
        
        # Saltar línea de título (Himno #...)
        if skip_title and stripped.startswith('Himno #'):
            skip_title = False
            continue
        
        skip_title = False
        
        # Detectar número de estrofa (un número solo en la línea)
        if re.match(r'^\d+$', stripped):
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
    print("CORRIGIENDO FORMATO DE ESTROFAS")
    print("=" * 50)
    
    input_file = "assets/data/himnos.json"
    output_file = "assets/data/himnos.json"
    
    print(f"\n1. Leyendo {input_file}...")
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            himnos = json.load(f)
    except FileNotFoundError:
        print(f"   Error: No se encuentra {input_file}")
        return
    
    print(f"   Encontrados {len(himnos)} himnos")
    
    print("\n2. Procesando estrofas...")
    
    corregidos = 0
    con_coro = 0
    total_estrofas = 0
    
    for himno in himnos:
        old_estrofas = himno.get('estrofas', [])
        
        # Si solo hay 1 estrofa y es muy larga, probablemente necesita parseo
        if len(old_estrofas) == 1 and len(old_estrofas[0]) > 200:
            new_estrofas, coro = parse_into_stanzas(old_estrofas[0])
            if len(new_estrofas) > 1:
                himno['estrofas'] = new_estrofas
                if coro and not himno.get('coro'):
                    himno['coro'] = coro
                corregidos += 1
        elif len(old_estrofas) == 0:
            # Intentar parsear cualquier texto que haya
            pass
        
        # También revisar si el coro estaba vacío pero había uno en el texto
        if not himno.get('coro') and himno.get('estrofas'):
            for i, est in enumerate(himno['estrofas']):
                if 'Coro:' in est or est.lower().startswith('coro'):
                    # Encontramos un coro oculto
                    pass
        
        if himno.get('coro'):
            con_coro += 1
        total_estrofas += len(himno.get('estrofas', []))
    
    # Ordenar por número
    himnos.sort(key=lambda x: x['numero'])
    
    print(f"\n   Corregidos: {corregidos} himnos")
    print(f"   Con coro: {con_coro} himnos")
    print(f"   Total estrofas: {total_estrofas}")
    avg_estrofas = total_estrofas / len(himnos) if himnos else 0
    print(f"   Promedio estrofas: {avg_estrofas:.1f}")
    
    print(f"\n3. Guardando en {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(himnos, f, ensure_ascii=False, indent=2)
    
    import os
    print(f"   Tamaño: {os.path.getsize(output_file) / 1024:.1f} KB")
    
    print("\n4. Mostrando ejemplos...")
    for h in himnos[:3]:
        print(f"\n   Himno {h['numero']}: {h['titulo']}")
        print(f"   Estrofas: {len(h['estrofas'])}")
        if h['estrofas']:
            print(f"   Estrofa 1: {h['estrofas'][0][:60]}...")
        if h.get('coro'):
            print(f"   Coro: {h['coro'][:40]}...")
    
    print("\n✓ ¡Completado!")

if __name__ == "__main__":
    main()

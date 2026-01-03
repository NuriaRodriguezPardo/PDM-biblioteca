import csv

def extraer_tags(ruta_archivo):
    tags_unicos = set()
    
    try:
        # Abrimos el archivo especificando el delimitador ';' que usa tu CSV
        with open(ruta_archivo, mode='r', encoding='utf-8') as f:
            reader = csv.DictReader(f, delimiter=';')
            
            for fila in reader:
                # Obtenemos la celda de la columna 'Tags'
                celda_tags = fila.get('Tags', '')
                
                if celda_tags:
                    # Separamos por coma, limpiamos espacios y añadimos al Set
                    lista_tags = [t.strip() for t in celda_tags.split(',')]
                    tags_unicos.update(lista_tags)
        
        # Ordenamos alfabéticamente
        lista_final = sorted(list(tags_unicos))
        
        print(f"Se han encontrado {len(lista_final)} tags únicos:")
        print(", ".join(lista_final))
        return lista_final

    except Exception as e:
        print(f"Error al leer el archivo: {e}")

# Ejecutar
extraer_tags('./dades/LibrosBD.csv')
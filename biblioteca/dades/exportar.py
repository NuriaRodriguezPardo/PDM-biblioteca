import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# 1. Configurar la conexión con Firebase
cred = credentials.Certificate("dades\serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

def export_collection_to_csv():
    print("Iniciando extracción de la colección 'libros'...")
    
    # 2. Obtener todos los documentos de la colección
    # Asegúrate de que el nombre coincide exactamente: 'libros'
    docs = db.collection('libros').stream()
    
    lista_libros = []

    for doc in docs:
        data = doc.to_dict()
        
        # 3. Mapear los datos tratando las listas con cuidado
        libro = {
            "ID": doc.id,
            "Títol": data.get('titulo', ''),
            "Autor": data.get('autor', ''),
            "Idioma": data.get('idioma', ''),
            "Stock": data.get('stock', 0),
            "URL_Imatge": data.get('url', ''),
            # Convertimos las listas a texto separado por comas para el CSV
            "Tags": ", ".join(data.get('tags', [])) if isinstance(data.get('tags', []), list) else data.get('tags', ''),
            "Playlist_IDs": ", ".join(data.get('playlist', [])) if isinstance(data.get('playlist', []), list) else data.get('playlist', ''),
            "Valoracions": ", ".join(data.get('valoraciones', [])) if isinstance(data.get('valoraciones', []), list) else data.get('valoraciones', '')
        }
        lista_libros.append(libro)

    if not lista_libros:
        print("No se han encontrado datos en la colección.")
        return

    # 4. Crear el DataFrame y exportar a CSV
    df = pd.DataFrame(lista_libros)
    nombre_archivo = "exportacion_firebase_libros.csv"
    
    # Usamos encoding 'utf-8-sig' para que Excel reconozca bien los acentos y la 'ç'
    df.to_csv(nombre_archivo, index=False, encoding='utf-8-sig', sep=';')
    
    print(f"¡Éxito! Archivo guardado como: {nombre_archivo}")
    print(f"Total de libros exportados: {len(lista_libros)}")

if __name__ == "__main__":
    export_collection_to_csv()
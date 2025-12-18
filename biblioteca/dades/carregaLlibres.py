import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import math

# 1. Configurar conexión con Firebase
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

# 2. Cargar el archivo CSV
# Asegúrate de que el nombre del archivo coincida exactamente
csv_file = "llibresBD.csv" 
df = pd.read_csv(csv_file)

print(f"Iniciando carga de {len(df)} libros...")

# 3. Recorrer cada fila y subirla a Firestore
for index, row in df.iterrows():
    # Limpiamos los tags: de "Drama, Amistad" a ["Drama", "Amistad"]
    tags_list = []
    if isinstance(row['tags'], str):
        tags_list = [tag.strip() for tag in row['tags'].split(',')]

    # Crear el diccionario de datos
    # Usamos nombres limpios para las variables de Flutter
    libro_data = {
        "titulo": row['titulo'],
        "autor": row['autor'],
        "idioma": row['idioma'],
        "tags": tags_list,
        "stock": int(row['stock']) if not math.isnan(row['stock']) else 0,
        "url": row['url'],
        "playlist": "", # Dejamos el campo listo para el futuro
        "valoraciones": "" # Dejamos el campo listo para el futuro
    }

    # Subir a la colección 'libros' usando el ID del CSV como ID del documento
    doc_id = str(row['id'])
    db.collection("libros").document(doc_id).set(libro_data)
    
    print(f"✅ Libro {doc_id} subido: {row['titulo']}")

print("\n--- ¡PROCESO COMPLETADO! ---")
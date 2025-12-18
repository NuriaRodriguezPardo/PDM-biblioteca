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
csv_file = "CanconsBD.csv" 
df = pd.read_csv(csv_file)

print(f"Iniciando carga de {len(df)} canciones...")

# 3. Recorrer cada fila y subirla a Firestore
for index, row in df.iterrows():
    # Limpiamos los tags: de "Drama, Amistad" a ["Drama", "Amistad"]
    tags_list = []
    if isinstance(row['tags'], str):
        tags_list = [tag.strip() for tag in row['tags'].split(',')]
    
    minutos_texto = str(row['minuts'])

    # Crear el diccionario de datos
    # Usamos nombres limpios para las variables de Flutter
    libro_data = {
        "titol": row['titol'],
        "autor": row['autor'],
        "minuts": minutos_texto,
        "lletra": row['lletra'],
        "urlImatge": row['urlImatge'],
        "tags": tags_list,
        "urlAudio": "" # Dejamos el campo listo para el futuro
    }


    # Subir a la colección 'libros' usando el ID del CSV como ID del documento
    doc_id = str(row['id'])
    db.collection("cançons").document(doc_id).set(libro_data)
    
    print(f"✅ Canción {doc_id} subido: {row['titol']}")

print("\n--- ¡PROCESO COMPLETADO! ---")
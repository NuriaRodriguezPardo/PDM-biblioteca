import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# 1. Configurar conexión con Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate("serviceAccountKey.json")
    firebase_admin.initialize_app(cred)
db = firestore.client()

# 2. Cargar los archivos CSV
df_libros = pd.read_csv("llibresBD.csv")
df_canciones = pd.read_csv("CanconsBD.csv")

print("Iniciando vinculación inteligente con búsqueda de respaldo...")

# Función para limpiar tags
def limpiar_tags(texto):
    if isinstance(texto, str):
        return set(t.strip().lower() for t in texto.split(','))
    return set()

# 3. Procesar cada libro
for _, libro in df_libros.iterrows():
    libro_id = str(libro['id'])
    libro_tags = limpiar_tags(libro['tags'])
    
    # --- PASO 1: Intentar buscar canciones con 2 o más coincidencias ---
    playlist_ids = []
    for _, cancion in df_canciones.iterrows():
        cancion_tags = limpiar_tags(cancion['tags'])
        coincidencias = libro_tags.intersection(cancion_tags)
        if len(coincidencias) >= 2:
            playlist_ids.append(str(cancion['id']))

    # --- PASO 2: Si no hay ninguna, buscar con al menos 1 coincidencia ---
    metodo = "Fuerte (>=2)"
    if not playlist_ids:
        metodo = "Mínimo (>=1)"
        for _, cancion in df_canciones.iterrows():
            cancion_tags = limpiar_tags(cancion['tags'])
            coincidencias = libro_tags.intersection(cancion_tags)
            if len(coincidencias) >= 1:
                playlist_ids.append(str(cancion['id']))

    # 4. Actualizar Firestore
    db.collection("libros").document(libro_id).update({
        "playlist": playlist_ids 
    })
    
    if playlist_ids:
        print(f"📖 '{libro['titulo']}': {len(playlist_ids)} canciones encontradas (Modo: {metodo}).")
    else:
        print(f"⚠️ '{libro['titulo']}': No se encontraron coincidencias ni siquiera con 1 tag.")

print("\n--- ¡VINCULACIÓN COMPLETADA! ---")
from fastapi import FastAPI, UploadFile, File
import shutil, os, cv2
import numpy as np
import tensorflow as tf
from sklearn.metrics.pairwise import cosine_similarity

app = FastAPI()

# ---------------- CONFIG ----------------
EMBEDDINGS_DIR = "embeddings"
TEMP_DIR = "temp"
IMAGE_HEIGHT, IMAGE_WIDTH = 128, 128
SEQUENCE_LENGTH = 20

os.makedirs(TEMP_DIR, exist_ok=True)

# ---------------- LOAD MODEL ----------------
base_model = tf.keras.applications.MobileNetV2(
    include_top=False,
    weights="imagenet",
    input_shape=(IMAGE_HEIGHT, IMAGE_WIDTH, 3),
    pooling="avg"
)
base_model.trainable = False

# ---------------- LOAD EMBEDDINGS ----------------
sign_names = []
sign_embeddings = []

for f in os.listdir(EMBEDDINGS_DIR):
    if f.endswith(".npy"):
        sign_names.append(f.replace(".npy", ""))
        sign_embeddings.append(np.load(os.path.join(EMBEDDINGS_DIR, f)))

sign_embeddings = np.vstack(sign_embeddings)

# ---------------- FRAME EXTRACTION ----------------
def extract_frames(video_path):
    frames = []
    cap = cv2.VideoCapture(video_path)
    total = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    skip = max(total // SEQUENCE_LENGTH, 1)

    for i in range(SEQUENCE_LENGTH):
        cap.set(cv2.CAP_PROP_POS_FRAMES, i * skip)
        ret, frame = cap.read()
        if not ret:
            break
        frame = cv2.resize(frame, (IMAGE_WIDTH, IMAGE_HEIGHT))
        frame = frame / 255.0
        frames.append(frame)

    cap.release()
    return np.array(frames)

# ---------------- EMBEDDING ----------------
def video_to_embedding(video_path):
    frames = extract_frames(video_path)
    if frames.shape[0] == 0:
        raise ValueError("No frames")

    if frames.shape[0] < SEQUENCE_LENGTH:
        last = frames[-1]
        while frames.shape[0] < SEQUENCE_LENGTH:
            frames = np.vstack([frames, last[np.newaxis, ...]])

    emb = base_model.predict(frames, verbose=0)
    return np.mean(emb, axis=0)

# ---------------- API ----------------
@app.post("/predict")
async def predict(video: UploadFile = File(...)):
    path = os.path.join(TEMP_DIR, video.filename)

    with open(path, "wb") as f:
        shutil.copyfileobj(video.file, f)

    emb = video_to_embedding(path)

    sims = cosine_similarity(emb.reshape(1, -1), sign_embeddings)[0]
    idx = int(np.argmax(sims))

    os.remove(path)

    return {
        "sign": sign_names[idx],
        "confidence": float(sims[idx])
    }

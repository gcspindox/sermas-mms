#!/bin/bash

MODEL_URL='https://dl.fbaipublicfiles.com/mms/asr/mms1b_all.pt'
MODEL_PATH='/app/model_new/mms1b_all.pt'

# Check if the file already exists
if [[ -f $MODEL_PATH ]]; then
    echo "Model file already exists at $MODEL_PATH. Skipping download."
else
    echo "Model file not found. Downloading from $MODEL_URL..."
    wget -P /app/model_new $MODEL_URL && echo "Download successful!" || echo "Download failed!"
fi

uvicorn webservice:app --host 0.0.0.0 --port 9000 --workers 1
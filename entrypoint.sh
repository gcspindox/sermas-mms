MODEL_URL='https://dl.fbaipublicfiles.com/mms/asr/mms1b_all.pt'
[-e $MODEL_URL] && wget -P ./model_new $MODEL_URL

uvicorn webservice:app --host 0.0.0.0 --port 9000 --workers 1
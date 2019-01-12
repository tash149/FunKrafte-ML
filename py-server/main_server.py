from google.cloud import firestore
from keras.models import load_model
from server import getEmotion
from sklearn.externals import joblib
from statistics import mode
from utils import preprocess_input
import cv2
import datetime
import json
import numpy as np
import os
import pandas as pd
import signal
import subprocess
import sys
import time
import urllib
import urllib.request

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "credentials.json"
db = firestore.Client()

def signal_handler(sig, frame):
        print('Exiting!')
        sys.exit(0)

def listener(doc_snapshot, changes, emo_time):
    print("Updating docs!")
    for doc in doc_snapshot:
        data = json.loads(json.dumps(doc.to_dict()))
        #print(data["photoUrl"])
        #print(getEmotion(data["photoUrl"]))
        emotion = getEmotion(data["photoUrl"])
        db.collection(u'users').document(u'{0}'.format(data['uid'])).set({u'emotion': emotion}, merge=True)
        print("Updated {0} with {1}".format(data['uid'], emotion))

emo_ref = db.collection(u'emotion')
emo_watch = emo_ref.on_snapshot(listener)

while True:
    signal.signal(signal.SIGINT, signal_handler)
    time.sleep(100)

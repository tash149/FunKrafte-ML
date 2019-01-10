from keras.models import load_model
import numpy as np
from statistics import mode
import os
import cv2
import pandas as pd
from sklearn.externals import joblib
from flask_restful import reqparse, abort, Api, Resource
from flask import Flask, jsonify, request
from utils import preprocess_input
from firebase import firebase
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
import datetime
import urllib
import urllib.request
import json


cred = credentials.Certificate("credentials.json")
app = firebase_admin.initialize_app(cred, {
    'storageBucket': 'fluttcam-108f4.appspot.com',
})
bucket = storage.bucket()
blob = bucket.blob('myimage.jpg')
#blob.upload_from_filename('/myimage.jpg')
img_url = blob.generate_signed_url(datetime.timedelta(seconds=300), method='GET')
print(blob.generate_signed_url(datetime.timedelta(seconds=300), method='GET'))


urllib.request.urlretrieve(img_url, "face.jpg")

detection_model_path = '../trained_models/haarcascade_frontalface_default.xml'
classification_model_path = '../trained_models/simple_CNN.hdf5'
emotion_labels = {0:'angry',1:'disgust',2:'sad',3:'happy',
                    4:'sad',5:'surprise',6:'neutral'}
frame_window = 10
face_detection = cv2.CascadeClassifier(detection_model_path)
emotion_classifier = load_model(classification_model_path)

img = cv2.imread('face.jpg')

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
faces = face_detection.detectMultiScale(gray, 1.3, 5)

for (x, y, w, h) in faces:
    #cv2.rectangle(gray, (x, y), (x + w, y + h), (255, 0, 0), 2)
    face = gray[y:y + h, x:x + w]
    try:
        face = cv2.resize(face, (48, 48))
    except:
      continue
    face = np.expand_dims(face, 0)
    face = np.expand_dims(face, -1)
    face = preprocess_input(face)

    emotion_arg = np.argmax(emotion_classifier.predict(face))
    emotion = emotion_labels[emotion_arg]

firebase = firebase.FirebaseApplication('https://fluttcam-108f4.firebaseio.com/predictions', None)
output = {'prediction': emotion}
#data = json.dumps(output)
result = firebase.post("/predictions", {'prediction': emotion})
print(emotion)

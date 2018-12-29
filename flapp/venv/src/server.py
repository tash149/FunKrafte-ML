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

app = Flask(__name__)
api = Api(app)

detection_model_path = '../trained_models/haarcascade_frontalface_default.xml'
classification_model_path = '../trained_models/simple_CNN.hdf5'
emotion_labels = {0:'angry',1:'disgust',2:'sad',3:'happy',
                    4:'sad',5:'surprise',6:'neutral'}

frame_window = 10

face_detection = cv2.CascadeClassifier(detection_model_path)
emotion_classifier = load_model(classification_model_path)

parser = reqparse.RequestParser()  #ap = argparse.ArgumentParser()
parser.add_argument("-i", "--image", help = "Path to the image")

emotion_window = []

class PredictEmotion(Resource):
    def get(self):
        img = cv2.imread('face2.jpg')
        #args = vars(parser.parse_args())
        #user_query = args['query']

        #img = cv2.imread(args["image"]) #'../images/face1.jpg'
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
            '''emotion_window.append(emotion)

            if len(emotion_window) >= frame_window:
                emotion_window.pop(0)
            try:
                emotion_mode = mode(emotion_window)
            except:
                continue
            cv2.putText(gray, emotion_mode, (x, y - 30), font, .7, (255, 0, 0), 1, cv2.LINE_AA)'''
        #cv2.imshow('window_frame', gray)
        #cv2.waitKey()

        output = {'prediction': emotion}
        return output

api.add_resource(PredictEmotion, '/')

if __name__ == '__main__':
    app.run(debug=True)

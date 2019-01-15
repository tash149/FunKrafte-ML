# FunKrafte

The social and registration service for FunKrafte. Also includes emotion recognition by face.
Developed by @AgentFabulous and @tash149

## Screenshots:relaxed:
<img src="https://user-images.githubusercontent.com/39271055/51160331-828cf800-18b3-11e9-9e1b-b09b1b7906a8.png" width="230" height="400"/>
<img src="https://user-images.githubusercontent.com/39271055/51160339-891b6f80-18b3-11e9-922d-ad9ce3cdf91f.png" width="230" height="400"/>
<img src="https://user-images.githubusercontent.com/39271055/51160203-f975c100-18b2-11e9-882b-e83f199e5303.png" width="230" height="400"/>
![](FunGif.gif)

## App
- To prepare the app for release, make sure you follow the instructions to setup firebase for your application.
- The app will create and manage required collections in Firestore database by itself, you just need to update the google-services.json.
  DO NOT use the one already present here. This is @AgentFabulous' personal api key file and runs the Firebase Spark package. Thus, quota is limited and WILL RUN OUT.


## Server
- For emotion recognition, you will need to run a python script with an active internet connection. The script is pretty efficient and will only update Firestore database when the emotion collection is changed. You will also need to generate a keyfile from google cloud (GCloud may ask you to create a billing account but it is NOT needed). The keyfile must be written to py-server/credential.json.
- To use the script, you will need Python 3.6 installed on your system (3.7 will NOT work).
- Once you have python and pip ready and working, run the following in this directory:
    ```
    cd py-server
    pip3 install -r requirements.txt
    python3 main_server.py
    ```

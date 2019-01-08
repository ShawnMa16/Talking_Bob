# Talking Bob

A 3D Object Detection AR chatbot built with Google's Dialogflow.

## Getting Started

These instructions will get you a copy of the project up and running on your iOS devices for development and testing purposes. See deployment for notes on how to deploy the project.

### Prerequisites

Environments and devices you will need

*  iOS 12
*  Xcode 10
*  Dialogflow(inclouding weather API request)

### Add to Dialogflow
To create this agent from google's template:

<a href="https://console.dialogflow.com/api-client/oneclick?templateUrl=https://oneclickgithub.appspot.com/dialogflow/fulfillment-weather-nodejs&agentName=WeatherSample" target="blank">
  <img src="https://dialogflow.com/images/deploy.png">
</a>

1. Get a WWO Local Weather REST API key from https://developer.worldweatheronline.com/api/
2. Replace <ENTER_WWO_API_KEY_HERE> with your WWO API key on line 20 of `functions/index.js`
3. Select **Deploy**.
4. In Dialogflow Console > **Settings** ⚙ > select **Google Cloud** link in Project ID section. From Google Cloud Platform > **menu** ☰ > **Enable Billing**.


### Upload files to Dialogflow

Files needed to be uploaed are in the folder **Dialogflow files**

1. Upload intents to Dialogflow from **Dialogflow files/Intents**
2. Upload Entities to Dialogflow from **Dialogflow files/Entities**


### Change client access token

You will need to use your own token from Dialogflow

1. Go to file **./Talkin_Bob/AppDelegate.swift**
2. Replace `"your token"` to your token from Dialogflow


### Build and run the app

1. Add more scanned 3D objects to folder `Assets.xcassets/ARObjects`
2. Go to file **./Talkin_Bob/ViewController.swift**
3. Replace `bob` in line 67 to your target object's name
4. Build and run the app

* Once you have launched the app, you should target your phone to your target object.

* Onece the object has been detected, a dialog will popup and you can hold the record button to start chatting.


**DO NOT ADD GAME OBJECT FOR NOW**

## Built With

* [SnapKit](http://snapkit.io) - For Auto Layout 
* [Dialogflow](https://dialogflow.com) - Cloud AI
* [WWO Weather](worldweatheronline.com) - Weather API requests

## Authors

* **Shawn Ma**  - [portfolio](https://xiaoma.space)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

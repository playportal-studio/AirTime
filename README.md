<div align="center">
<img src="https://gyazo.com/ddb0fef2c7821b73782deb0054d706a3.png = 1000x1000" width="200">


### [Airtime = playPORTAL + Apple Watch](https://www.playportal.io) 
</div>

### App Overview
<br/>
<p>AirTime is an app that brings the playPORTAL SDK and the Apple Watch together. It uses the on-board Apple Watch accelerometer to complete simple gesture recognition to count pogo stick jumps and airtime. Go outside, get your pogo stick and start jumping. Feel free to modify this code, and create your own playPORTAL Apple Watch app.</p>

[More Info: Apple Watch Core Motion (Accelerometer)](https://developer.apple.com/documentation/coremotion/cmmotionmanager)

### SDK Features Used
<img src="https://gyazo.com/93c92748a1f507be765aa8c8c2d41fae.png = 1500x1500" width="55%">



## Getting Started (playPORTAL setup)

* ### <b>Step 1:</b> Create playPORTAL Studio Account

	* Navigate to [playPORTAL Studio](https://studio.playportal.io)
	* Click on <b>Sign Up For FREE Account</b>
	* After creating your account, email us at accounts@playportal.io to introduce yourself and your project and we will consider you for early access.
 

* ### <b>Step 2:</b> Register your App with playPORTAL
   	* After confirmation, log in to the [playPORTAL Studio](https://studio.playportal.io)
  	* In the left navigation bar click on the <b>Apps</b> tab.
   	* In the <b>Apps</b> panel, click on the "+ Add App" button.
  	* Add an icon (example image [here](https://github.com/playportal-studio/AirTime/blob/master/AirTime/Assets.xcassets/AppIcon.appiconset/ItunesArtwork%402x.png)).
	* Enter a unique app <b>name</b> (you cannot use the name AirTime because it is already in use).
	* Enter a description for your app.
  	* For "Environment" leave "Sandbox" selected.
 	* Click "Add App"
	
<img src="https://gyazo.com/123d7d09cea8bb8cfc3d763709ddc8ba.png = 1500x1500" width="65%">

* ### <b>Step 3:</b> Setup your permission scopes.
	* Add permission scopes for each of the SDK features used in the app. Reference the image below.
<img src="https://gyazo.com/93c92748a1f507be765aa8c8c2d41fae.png = 1500x1500" width="55%">

* ### <b>Step 4:</b> Generate your Client ID and Client Secret

	* Tap "Client IDs & Secrets"
	* Tap "Generate Client ID"
	* The values generated will be used later.
	* CAUTION: Keep your Client ID & Secret private! Do not commit your credentials!
 
* ### <b>Step 5:</b> Clone the repository 
	* Open teminal and clone repository to Desktop
    ```
    cd Desktop
    git clone https://github.com/playportal-studio/AirTime.git
    ```
* ### <b>Step 6:</b> Install [Cocopods](https://cocoapods.org/) 
    * To install 
    ```
    sudo gem install cocoapods
    ```
    * After cocoapods is installed, follow these steps.
    ```
    cd AirTime
    pod install
    ```
* ### <b>Step 7:</b> Launch Xcode 
    * Open up the .xcworkspace file
    * Select a simulator that runs an iPhone and Apple Watch together 
    * Press the play button and run AirTime

* ### <b>Step 8:</b> Hide your keys.
	* The Client ID, & Secrets tied to your application <b>NEED</b> to be hidden
	* This can be done by creating a .gitignore file 
```
cd AirTime
touch .gitignore
```

* ### <b>Step 8.1:</b>Open up the project in a different IDE
	* To edit your .gitignore open the project in either [Atom](https://atom.io/) or [VSCode](https://code.visualstudio.com/)
	* After the project is open, add the file you stored keys in to the .gitignore
	
* ### <b>Step 9:</b> Develop! 
	* If you made it this far, great you are ready!!!
	* Good luck and have fun developing. 
    
    
* ### <b>Got Stuck?</b> If you did on any of the steps listed here are some links to help!
    * Here is another cocoapods installation directions [link](https://iosdevcenters.blogspot.com/2015/12/how-to-install-cocoapods-in-xcode.html)
    * Read [this](https://github.com/joshnh/Git-Commands) to get a refresher on Git commands 





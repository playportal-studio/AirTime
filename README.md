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
    sudo gem install cocoapods -v 1.6.0.beta.1
    ```
    * After cocoapods is installed, follow these steps
    ```
    cd AirTime
    pod install
    ```
* ### <b>Step 7:</b> Ensure AirTime Compiles
    * Open up the AirTime.xcworkspace file
    * Select a simulator or device that runs an iPhone and Apple Watch together 
    * Press the play button to run AirTime

* ### <b>Step 8:</b> Link playPORTAL Studio with AirTime
	
* ### <b>Step 8.1:</b> Insert Keys In An App File To Enable User Login
	* The Client ID, & Secrets tied to your application <b>NEED</b> to be hidden
	* Create a .gitignore file (if there isn't an existing one): 
	
	```
	cd AirTime
	touch .gitignore
	```
	
	* Create a Keys.swift file inside your project directory
	* Copy your <b>Client ID</b> and your <b>Client Secret</b> from playPORTAL Studio
	* Define your keys inside the Keys.swift using the format below
		```
		 let cid = "CLIENT ID GOES HERE"
    		 let cse = "CLIENT SECRET GOES HERE"
		 let redirectURI = "REDIRECT URL GOES HERE"
                 let env = "SANDBOX"
		```
* ### <b>Step 8.2:</b>Open up the project in a different IDE or text editor
	* To edit your .gitignore open the project in either [Atom](https://atom.io/) or [VSCode](https://code.visualstudio.com/)
	* Add the filename Keys.swift to the .gitignore
	* Now that your keys are in a file, return to playPORTAL Studio
	* Create a Redirect URL using the name of your Studio app 
		```
		appname://redirect
		```

* ### <b>Step 8.3:</b>SSO Integration in XCode
	* Open XCode
	* Navigate to your app level settings and click on the info tab.
	* Add a new URL under the URL types section.
	* Input your app name into the <b>Identifier</b> and <b>URL Schemes</b>. See the picture below for refrence
	
	<img src="https://gyazo.com/bd73716f685418251fd814a1662b5cb8.png = 1500x1500" width="65%">
	
* ### <b>Step 8.4:</b> Create Sandbox Users For App
	* Go back to [playPORTAL Studio](https://studio.playportal.io)
	* Click on Sandbox
	* Generate a few users
	Tip: You can create kids by creating a Parent and adding a Kid
		
	<img src="https://gyazo.com/76ec65dadd301ae7512304e80979323f.png = 1500x1500" width="55%">
	
* ### <b>Step 9:</b> Develop! 
	* If you made it this far, great you are ready!!!
	* Within XCode, build the App
	* Use username and PW from playPORTAL Studio Step 8.4 to login
	* Good luck and have fun developing 
    
    
* ### <b>Got Stuck?</b> If you did on any of the steps listed here are some links to help!
    * Here is another cocoapods installation directions [link](https://iosdevcenters.blogspot.com/2015/12/how-to-install-cocoapods-in-xcode.html)
    * Read [this](https://github.com/joshnh/Git-Commands) to get a refresher on Git commands 





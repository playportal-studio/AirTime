![](./readmeAssets/studio.png)
# <b> AirTime App</b></br>
##### This the log kept while building the AirTime app in a < 8 hour period.


## Getting Started (playPORTAL setup)

* ### <b>Step 1:</b> Create playPORTAL Studio Account

	* Navigate to [playPORTAL Studio](https://studio.playportal.io)
	* Click on <b>Sign Up For FREE Account</b>
	* After creating your account, email us at [info@playportal.io](mailto:info@playportal.io?subject=Developer%20Sandbox%20Access%20Request) to verify your account.
  </br>

* ### <b>Step 2:</b> Register your App with playPORTAL

	* After confirmation, log in to the [playPORTAL Studio](https://studio.playportal.io)
	* In the left navigation bar click on the <b>Apps</b> tab.
	* In the <b>Apps</b> panel, click on the "+ Add App" button.
	* Add an icon, <b>AirTime</b> & description for your app.
	* For "Environment" leave "Sandbox" selected.
	* Click "Add App"
  </br>

* ### <b>Step 3:</b> Generate your Client ID and Client Secret

	* Tap "Client IDs & Secrets"
	* Tap "Generate Client ID"
	* The values generated will be used later.
  </br>
*




### Setup github Repo
* Create master branch
* Clone master branch to your local machine
* enable gitflow
* Add develop branch to github HeroDetailComponent
* Add feature branch "feature/Step1"

### Fetch repo to all machines
* git checkout feature/Step1 branch

### Launch Xcode and open xcodeproj
* make sure xcode simulator runs
* make sure iOS device runs

### cocoapods
* If cocoapods not intalled on your machine go here https://cocoapods.org/






```aidl
target 'AirTime' do
  platform :ios, '8.0'
  use_frameworks!
  pod 'KontaktSDK', '~> 1.3'
end

```

```

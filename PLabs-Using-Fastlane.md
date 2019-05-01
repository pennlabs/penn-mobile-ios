# Using Fastlane
Docs: [Setup - fastlane docs](https://docs.fastlane.tools/getting-started/ios/setup/)
Contact **Dominic Holmes** with questions. Email:
	* hello [at] dominic [dot] land

### Lanes
I made 3 lanes (specified in `fastlane/Fastfile`)
1. **screenshots**
	* this generates screenshots for all of the devices listed in `Snapfile`, by using the UITest target `AutomatedScreenshotUITests`
2. **frame**
	* this lane frames all screenshots in the`fastlane/screenshots/en-US/` folder with the configuration listed under **Framing Screenshots**
3. **capture_and_frame**
	* this lane is basically just lane 1 + lane 2. It captures all new screenshots and frames them — takes about 9 minutes on a fast Mac.

### Getting started
1. Make sure you’re on the `fastlane` branch and you have pulled all changes
2. Run `pod install` and make sure the app launches normally
3. Install fastlane by running `sudo gem install fastlane -NV`
4. Run `sudo bundle update` & put in your password to make sure everything’s good
5. We’re ready! Run fastlane with `bundle exec fastlane [lane]` or `bundle exec fastlane` to have all lanes shown
6. You’ll need to follow the instructions under **Framing Screenshots** to get that lane to work.

### Framing Screenshots
The framing step will fail if you don’t have this set up.
Complete instructions here: [Screenshots - fastlane docs](https://docs.fastlane.tools/getting-started/ios/screenshots/#put-your-screenshots-into-device-frames)

1. Install imagemagick through homebrew: `brew install libpng jpeg imagemagick`
2. I have framing installed in the lane already, but you may need to update the screenshot tags.
	* For every screenshot that fastlane takes in, it gives it a tag like “01Dining”.  Change these in `AutomaticScreenshotUITests.swift`.
	* That tag is then used in `Framefile.json` to set parameters for each frame (such as color).
	* It is also used in `/screenshots/en-US/keyword.strings` and `/screenshots/en-US/title.strings` to define the titles and subtitles to go on the frame.
	* Additionally, the frame uses `background.png`, although this can be customized and set individually in `Framefile.json`
	* You can specify the devices in `Snapfile`
    
### Conditional Code
I added a way for us to check if Fastlane is currently taking screenshots. This is needed for things like Laundry preferences -- we want to return real preferences when testing the app and in production -- but NOT when running the Fastlane UI automation. Otherwise, we would have to start up each simulator and select the same user preferences.

You can check for conditional code anytime by calling `UIApplication.isRunningFastlaneTest`. This just checkings for a launch argument ("FASTLANE") I pass in at the beginning of the test.

### Perfect Status Bar
Last thing — I also installed PerfectStatusBar. It sets the time to be 9:41 and the battery to be full. The pod is only installed on the UITests target, so it doesn’t affect normal testing.

### Errors
1. Make sure fastlane is up to date (especially if there have been new iOS versions or Xcode versions) with `[sudo] bundle update fastlane`
2. If you encounter:  _[!] Could not determine installed iOS SDK version. Try running the _xcodebuild_ command manually to ensure it works._
	* Try running the following: `sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer`
    3. If some of the screenshots have loading indicators, then you need to give each screen more time :( This makes the test take longer. Just increase the `waitTime` variable at the top of `AutomatedScreenshotUITests.swift`. This variable is in seconds.

Generally — just follow whatever instructions Fastlane gives you, or google them if you’re unclear (they have great docs).

### Running Time
The following is the running time of screenshot capture + framing, in seconds, on a MBP 2018.

```
+------+---------------------+-------------+
|             fastlane summary             |
+------+---------------------+-------------+
| Step | Action              | Time (in s) |
+------+---------------------+-------------+
| 1    | update_fastlane     | 6           |
| 2    | default_platform    | 0           |
| 3    | capture_screenshots | 224         |
| 4    | frameit             | 282         |
+------+---------------------+-------------+
```

#  About Vendors folder

This folder contains any libraries and components that were added directly to the project and which should be maintained locally.

Ideally, this list is kept to a minimum, and the main dependencies managed via Cocoapods. However, since there are occasions where that's not possible, this README is a means to document any departures from the standard. If a library starts getting new updates or gets fixes for the issue that caused it to be added here, it is recommended that it's added back to the Podfile. 

Your own contributions and pull requests to the libraries in question that fix such issues are greatly encouraged. 

### List of current 3rd party contributors

* Recruit Lifestyle - SmileLock library

Added because the base library has somewhat irregular updates and has some version incompatibilities, so I decided to maintain it locally. This way I can maintain it based on my project needs, and keep it to the coding style in the same manner. 

All credit still goes to the authors of this library and all the license files are preserved as they appear on their Github repo at the 
time of integration

At the time of integration it supported minimum of iOS 9 and Swift Version was 4.0, resulting in compiler errors and warnings. 


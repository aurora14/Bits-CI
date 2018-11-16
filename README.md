#  Bitrise Unofficial Client for iOS

This app is intended to provide a modern, up-to-date interface for interacting with the Bitrise continuous integration system

## Authentication
Access to the functions provided by the API is via Bitrise Personal Access Token. As of version 1.1, the app can be locked down via passcode and biometric authentication. 

Personal Access Token is stored in the keychain once generated. 

## Design notes
Where possible, follow iOS 11/12 conventions. One notable exception is the tabbed views in Project Detail and Build Detail.

New build modal sheet is styled similar to Facebook and Music apps, can be dismissed by dragging down or tapping the chevron. 

Profile view is inspired by the Apple Music profile transitions

## Features
* User profile
* User's apps
* User's organisations
* App Builds
* Build logs (short and full)

For the app list, the flow would be something like App List or Grid-> [tap an app entry] -> Build List -> [tap a build] -> Logs/Artefacts


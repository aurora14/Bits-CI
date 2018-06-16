#  Bitrise Unofficial Client for iOS

This app is intended to provide a modern, up-to-date interface for interacting with the Bitrise continuous integration system

## Authentication
Login is via personal access token (future implementations may allow setting up pass code & touch ID)
Proposal to use WebKit to allow user to log into Bitrise to generate one, so they can copy and paste it seamlessly in the app
Token should be stored in Keychain

- Android app permits to get the token ("Don't have a token? Get it ~here!~") -> Opens web browser

## Design
Where possible, follow iOS 11/12 conventions
Style the app along the lines of Workflow, Moodee, Hear Mail and the standard Apple apps (Books, Music, Podcasts)
Take a base colour from each app icon and apply a light diagonal gradient

## Features
* User profile
* User's apps
* User's organisations
* App Builds
* Access to Logs & Artefacts from the build
* Save log as PDF? (subject to availability) or export or share extension (e.g. post log to a Trello card)

For the app list, the flow would be something like App List or Grid-> [tap an app entry] -> Build List -> [tap a build] -> Logs/Artefacts


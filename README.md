# urchin

[![Build Status](https://travis-ci.org/tidepool-org/urchin.png)](https://travis-ci.org/tidepool-org/urchin)

Urchin is an iOS notes client for Type-1 Diabetes (T1D) built on top of the [Tidepool](http://tidepool.org/) platform. It allows patients and their "care team" (family, doctors) to add context to their data in the form of notes.

## Requirements:

- Xcode 7.2 or higher
- Xcode's Command Line Tools. From Xcode, install via *Xcode → Preferences → Downloads*.
- xctool. Install using the following command:
		`brew install xctool`

## Running the project

This project uses CocoaPods. Clone this repo and open Urchin.xcworkspace in Xcode. Build and run in the iOS Simulator.

### To run tests:

Run the command:
`xctool test -workspace Urchin.xcworkspace -scheme Urchin -sdk iphonesimulator clean build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO`


### To change environment:

In `APIConnect.swift`, change the global state variable 'baseURL' to your preferred environment.

For development, use the dev environment: 'https://dev-api.tidepool.org'. You may need to create an account to test.

## Style and Formatting

For editing design related portions of application, see `ConstantsAndStyle.swift`.

Common design changes that can be made:
- Colors
- Fonts
- Label text
- Date formats
- UI element sizes
- and more!

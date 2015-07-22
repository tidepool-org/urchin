# urchin

Urchin is an iOS notes client for Type-1 Diabetes (T1D) built on top of the [Tidepool](http://tidepool.org/) platform. It allows patients and their "care team" (family, doctors) to add context to their data in the form of notes.

## Install

Requirements:

- [Swift 1.2](https://developer.apple.com/swift/blog/?id=22)

Clone this repo to run in the iOS Simulator.

### To change environment:

In 'APIConnect.swift', change the global state variable 'baseURL' to your preferred environment.

For development, use the dev environment: 'https://devel-api.tidepool.io'. You may need to create an account at [Blip-devel](blip-devel.tidepool.io).
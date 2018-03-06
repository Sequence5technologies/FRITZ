# Heartbeat by Fritz

Heartbeat by Fritz is a collection of experiences utilizing machine learning models built with Apple's Core ML framework. Each demo is instrumented using the [Fritz SDK](https://github.com/fritzlabs/swift-framework), which provides management and deployment tools, as well as real-time insights into model performance on-device.

## Getting Started

The steps below will guide you through downloading this project, getting it up, and running in a simulator or on device.

### Requirements

In order to run this project you need:

- Xcode 9.2 or later
- Cocoapods - [available here](https://cocoapods.org)

### Step 1 - Clone Project

First things first, [clone](https://github.com/fritzlabs/heartbeat-ios.git) or [download](https://github.com/fritzlabs/heartbeat-ios/archive/master.zip) the project to your Mac. We recommend cloning, but if you choose to download make sure you unzip the archive before proceeding.

### Step 2 - Install Dependencies

Open a terminal and `cd` to the project directory, then run:

```bash
pod install
```

### Step 3 - Open Workspace

Start Xcode and open the project from the workspace `Heartbeat.xcworkspace`.

### Step 4 - Build & Run

Build and run the project through the Xcode simulator, using any iOS mobile device you want.

## Integrate Fritz

If you're interested in using Fritz to manage models in your own project, request an account via Fritz [Early Access](https://app.fritz.ai/early-access). Then follow one of our integration guides:

- [Swift Integration](https://github.com/fritzlabs/swift-framework/wiki/Swift-Integration)
- [Objective-C Integration](https://github.com/fritzlabs/swift-framework/wiki/Objective-C-Integration)

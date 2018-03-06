# Heartbeat by Fritz

Heartbeat for iOS is a collection of demos that utilize machine learning models built with Apple's `CoreML` framework. Each demo is instrumented using the [Fritz SDK](https://github.com/fritzlabs/swift-framework), which provides real-time insights into your models' performance.

## Getting Started

The steps below will guide you through downloading this project, getting it up and running in a simulator or on device, and then logging into the Fritz web app to monitor model usage in real-time.

### Requirements

In order to run this project you need:

1. Xcode 9.2 or later
2. Cocoapods - Install [here](https://cocoapods.org)
3. A Fritz login - See instructione below for a shared login

### Step 1 - Clone Project

First things first, download or clone the project to your mac:

1. Clone - [https://github.com/fritzlabs/heartbeat-ios.git](https://github.com/fritzlabs/heartbeat-ios.git)
2. Download - [https://github.com/fritzlabs/heartbeat-ios/archive/master.zip](https://github.com/fritzlabs/heartbeat-ios/archive/master.zip)

### Step 2 - Install Dependencies

Open a terminal and `cd` to the project directory, then run:

```bash
pod install
```

### Step 3 - Open Workspace

Start Xcode and open the newly created `Heartbeat.xcworkspace`

### Step 4 - Build & Run

Build and run the project on a simulator or devide of your choosing

### Step 5 - Login to Fritz Dashboard

Login to the Fritz real-time dashboard: [https://app.fritz.ai](https://app.fritz.ai)

You can login with shared credentials: `demo@friz.ai:123456789`

## Integrate Fritz

If you're ready to integrate the Fritz SDK into your own project, follow one of our integration guides:

1. [Swift Integration](https://github.com/fritzlabs/swift-framework/wiki/Swift-Integration)
2. [Objective-C Integration](https://github.com/fritzlabs/swift-framework/wiki/Objective-C-Integration)

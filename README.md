# Heartbeat by Fritz

Heartbeat by Fritz is a collection of experiences utilizing machine learning models built with Apple's Core ML framework. Each demo is instrumented using the [Fritz SDK](https://github.com/fritzlabs/swift-framework), which provides management and deployment tools, as well as real-time insights into model performance on-device.

If you want to try it out, you can download and use Heartbeat by Fritz from the [App Store](https://itunes.apple.com/us/app/heartbeat-by-fritz/id1325206416).

## Getting Started

The steps below will guide you through downloading this project, getting it up, and running in a simulator or on device.

### Requirements

In order to run this project you need:

- Swift 4.1, Xcode 9.3 or later
- Git Large File Storage (LFS) - [available here](https://git-lfs.github.com)
- Cocoapods - [available here](https://cocoapods.org)

### Step 1 - Clone Project

In order to clone the project, you must first install Git Large File Storage (LFS), [available here](https://git-lfs.github.com). The `MLModel` files are checked into the repo using LFS and will not clone properly otherwise.

After installing LFS, [clone](https://github.com/fritzlabs/heartbeat-ios.git) or [download](https://github.com/fritzlabs/heartbeat-ios/archive/master.zip) the project to your Mac. We recommend cloning, but if you choose to download make sure you unzip the archive before proceeding.

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

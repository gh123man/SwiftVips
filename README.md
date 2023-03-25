## A lightning fast image processing and resizing library for Swift

This package wraps the core functionality of [libvips](https://github.com/libvips/libvips) image processing library. This library is still under development and only exposes a subset of the vips API. It works on both Mac and Linux. 

## Dependencies

### MacOS

Use [homebrew](https://brew.sh/) to install vips and pkg-config:

```bash
brew install vips pkg-config
```

### Ubuntu

```bash
apt install libvips-dev -y 
```

## Usage

```swift
import SwiftVips

let testPng: Data = // load data

let png = try VImage(from: testPng)
try png.resize(scale: 0.5)
let jpgData = try png.toJpeg(quality: 50)

```
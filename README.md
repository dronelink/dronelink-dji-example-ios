# DronelinkDJIExample - iOS

## Requirements

- DJISDK key: https://developer.dji.com/
- Mapbox access token: https://account.mapbox.com/access-tokens/create
- Microsoft maps credentials key: https://www.bingmapsportal.com/
- Dronelink environment key: https://www.dronelink.com/
- Dronelink Kernel (dronelink-kernel.js): https://github.com/dronelink/dronelink-kernel-js
- Mission plan JSON: Export from any mission plan on https://app.dronelink.com/

## Setup

- pod install
- Update bundle identifier to match what was registered with DJI
- Provide DJISDK key and Mapbox access token in info.plist
- Provide Dronelink environment key and Microsoft maps credentials key in AppDelegate
- Add dronelink-kernel.js to the project's root folder

## Author

Dronelink, dev@dronelink.com

## License

DronelinkDJIExample is available under the MIT license. See the LICENSE file for more info.

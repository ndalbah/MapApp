# MapNavigatorTransport

A SwiftUI + MapKit iOS application that allows users to search for a destination, select a transport mode, and display a route starting from the user's current location.

---

## Overview

MapNavigatorTransport is a modern iOS app built with **SwiftUI**, **MapKit**, and **CoreLocation**.

The app launches centered on the user's current location. If the user's location isn't available, the app launches centered on:

```
Collège LaSalle Montréal
Latitude: 45.4919
Longitude: -73.5794
```

It enables destination search, multi-mode routing, and dynamic map interaction with real-time updates.

---

## Features

### 🗺 Default Map Setup

* Map centered on user's location at launch
* Red marker: **“Collège LaSalle”**
* Blue marker: **“You”** (when location permission is granted)

### 🔍 Destination Search

* Natural language search using `MKLocalSearch`
* Green marker: **“Destination”**
* Error handling for:

  * No results
  * Search failure
  * Location unavailable

### 🚗 Transport Modes

Segmented picker with:

* Automobile (default)
* Walking
* Transit
* Cycling

Changing the transport mode automatically recalculates the route using `MKDirectionsTransportType`.

### 🛣 Route Drawing

* Route rendered using `MapPolyline`
* Camera automatically fits entire route
* Displays:

  * Distance (km)
  * Estimated travel time (hours, minutes)

### 🔎 Custom Zoom Controls

* Floating Zoom In / Zoom Out buttons
* Uses `onMapCameraChange` for precise control

### 📍 Location Management

Custom `LocationManager`:

* Requests location permission
* Publishes live user coordinates
* Handles authorization changes and errors

---

## Tech Stack

* SwiftUI
* MapKit
* CoreLocation
* Combine
* Swift Concurrency (`async/await`)
* iOS 17 Map APIs (`MapCameraPosition`, `MapPolyline`)

---

## Screenshots

<p align="center">
  <img src="screenshots/home.png" width="250"/>
  <img src="screenshots/route-driving.png" width="250"/>
  <img src="screenshots/route-walking.png" width="250"/>
</p>

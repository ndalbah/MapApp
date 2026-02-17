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


<p align="center" >
  <img width="301" height="655" alt="home" src="https://github.com/user-attachments/assets/1f2dd55b-3a52-4499-95ee-26292320af62" />
  <img width="301" height="655" alt="route-driving" src="https://github.com/user-attachments/assets/694409cb-7cac-46fb-9e41-4640dc03d71c" />
  <img width="301" height="655" alt="route-walking" src="https://github.com/user-attachments/assets/a16ac21f-a2b2-421a-a6d5-8a9134d708af" />
</p>

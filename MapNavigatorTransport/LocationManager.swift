//
//  LocationManager.swift
//  MapNavigatorTransport
//
//  Created by NRD on 17/02/2026.
//

import Foundation
import MapKit
import CoreLocation // is responsible for all gps related queries
import Combine // obs obj

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    
    private let LocationManager = CLLocationManager()
    
    // user location (lat, long) ---> published var
    @Published var userLocation: CLLocationCoordinate2D?
    
    // init --> implementing 3 classes, we need to initialize all of them
    override init() {
        super.init() // initialize the 3 classes
        LocationManager.delegate = self
        LocationManager.requestWhenInUseAuthorization() // popup ---> location permission
        LocationManager.startUpdatingLocation() // access gps
    }
    
    // MARK: In-builts -- override
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            self.userLocation = latestLocation.coordinate
        }
    }
    
    // check if the permissions are revoked.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            manager.stopUpdatingLocation()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
    
    // handle map errors -- run async
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
        manager.stopUpdatingLocation()
    }
}

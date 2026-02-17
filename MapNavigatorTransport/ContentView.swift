//
//  ContentView.swift
//  MapNavigatorTransport
//
//  Created by NRD on 17/02/2026.
//

import SwiftUI
import MapKit

enum TransportMode: String, CaseIterable {
    case driving = "Driving"
    case walking = "Walking"
    case transit = "Transit"
    case cycling = "Cycling"
    
    var mkType: MKDirectionsTransportType {
        switch self {
        case .driving: return .automobile
        case .walking: return .walking
        case .transit: return .transit
        case .cycling: return .cycling
        }
    }
}

struct ContentView: View {
    
    @StateObject private var locationManager = LocationManager()
    @State private var camera: MapCameraPosition = .automatic
    @State private var zoomLevel: Double = 2000
    
    @State private var searchText: String = ""
    @State private var destination: CLLocationCoordinate2D?
    @State private var route: MKRoute?
    
    // flags
    @State private var isSearching: Bool = false
    @State private var errorMessage: String?
    
    // flag to autocenter the camera, in the route
    @State private var didAutoCenter: Bool = false
    
    // flag to get the camera focus
    @State private var currentCenter: CLLocationCoordinate2D?
    @State private var transportMode: TransportMode = .driving
    
    // marker -- montreal(lat, long)
    let lasalle = CLLocationCoordinate2D(
        latitude: 45.4919,
        longitude: -73.5794
    )
    
    private var formattedTravelTime: String {
        guard let route = route else { return "" }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime) ?? ""
    }
    
    var body: some View {
        ZStack {
            
            // maps
            Map(position: $camera){
                Marker("Collège LaSalle", coordinate: lasalle)
                    .tint(.red)
                
                // place marker on default/current location
                if let userLocation = locationManager.userLocation {
                    Marker("You", coordinate: userLocation)
                        .tint(.blue)
                }
                
                if let destination {
                    Marker("Destination", coordinate: destination)
                        .tint(.green)
                }
                
                // route
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(.blue, lineWidth: 4)
                }
            }
            .mapStyle(.standard)
            .onMapCameraChange {
                context in
                currentCenter = context.region.center
            }
            
            
            // get location button
            // top right corner
            VStack{
                HStack{
                    Spacer()
                    VStack(spacing: 10){
                        Button(action: goToUserLocation) {
                            Image(systemName: "location.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }.shadow(radius: 4)
                    }.padding()
                }
                Spacer() // push everything to the bottom
            }
            
            
            // buttons ---> zoom control
            // bottom right side of the screen
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    VStack(spacing: 10) {
                        Button(action: zoomIn) {
                            Image(systemName: "plus.magnifyingglass")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }.shadow(radius: 4)
                        
                        Button(action: zoomOut) {
                            Image(systemName: "minus.magnifyingglass")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }.shadow(radius: 4)
                    }.padding()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            // view to search a destination
            VStack(spacing: 10){
                
                Picker("Transport Mode", selection: $transportMode) {
                    ForEach(TransportMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: transportMode) {
                    runSearch()
                }
                
                HStack(spacing: 10){
                    TextField("Search for a place...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .submitLabel(.search)
                    
                    Button {
                        runSearch()
                    } label: {
                        if isSearching {
                            ProgressView()
                                .tint(.white)
                                .frame(width: 24, height: 24)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        } else {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.white)
                                .frame(width: 24, height: 24)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 14)
                                .background(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .disabled(isSearching || searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                

                
                if let route = route {
                    HStack(spacing: 20) {
                        // 1. Travel Time
                        VStack(alignment: .leading) {
                            Text("Travel Time")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(formattedTravelTime)
                                .bold()
                        }
                        
                        // 2. Distance
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(Measurement(value: route.distance, unit: UnitLength.meters)
                                .converted(to: .kilometers)
                                .formatted(.measurement(width: .abbreviated)))
                            .bold()
                        }
                    }
                    .padding(.top, 5)
                }
                
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .onReceive(locationManager.$userLocation) {
            newValue in
            guard !didAutoCenter, route == nil, let loc = newValue else { return }
            
            didAutoCenter = true
            
            camera = .camera(
                MapCamera(
                    centerCoordinate: loc,
                    distance: zoomLevel
                )
            )
        }
        
    }
    
    // MARK: Search
    
    // run the search
    private func runSearch() {
        // run in a separate thread
        Task{
            @MainActor in
            errorMessage = nil
            
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard !query.isEmpty else { return }
            
            guard let userLocation = locationManager.userLocation else {
                errorMessage = "User location is not available yet"
                return
            }
            
            // flag the progress view
            isSearching = true
            defer { isSearching = false }
            
            do{
                let dest = try await searchCoordinate(for: query)
                destination = dest
                
                // calculate the route
                let newRoute = try await calculateRoute(
                    from: userLocation,
                    to: dest
                )
                
                route = newRoute
                
                // fit the camera to capture the whole route
                let rect = newRoute.polyline.boundingMapRect
                let region = MKCoordinateRegion(rect)
                
                camera = .region(region)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    // search the coordinate --> query to convert to lat, long
    private func searchCoordinate(for query: String) async throws -> CLLocationCoordinate2D {
        // help us run the func in parts
        try await withCheckedThrowingContinuation { continuation in
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query // comment
            MKLocalSearch(request: request).start {
                response,
                error in
                // error ---> throw
                
                if let error { continuation.resume(throwing: error); return }
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Search",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "No result found for query: \(query)"]
                        )
                    )
                    
                    return
                }
                // data ---> it continue
                continuation.resume(returning: coordinate)
            }
        }
    }
    
    
    // calculate the route
    private func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) async throws -> MKRoute {
        try await withCheckedThrowingContinuation { continuation in
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
            
            request.destination = MKMapItem(
                placemark: MKPlacemark(
                    coordinate: destination
                )
            )
            
            // route --> vehicle, transit, walking, or cycling
            request.transportType = transportMode.mkType
            
            
            // calculate the route
            MKDirections(request: request).calculate {
                response,
                error in
                if let error { continuation.resume(throwing: error); return }
                
                guard let route = response?.routes.first else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "Directions",
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "No route found."]
                        )
                    )
                    return
                }
                
                continuation.resume(returning: route)
            }
        }
    }

    
    // zoom in
    private func zoomIn() {
        guard let center = currentCenter else { return }
        if let userLocation = locationManager.userLocation{
            withAnimation {
                zoomLevel *= 0.8
                camera = .camera(
                    MapCamera(
                        centerCoordinate: center,
                        distance: zoomLevel
                    )
                )
            }
        }
    }
    
    // zoom out
    private func zoomOut() {
        guard let center = currentCenter else { return }
        if let userLocation = locationManager.userLocation{
            withAnimation {
                zoomLevel *= 1.2
                camera = .camera(
                    MapCamera(
                        centerCoordinate: center,
                        distance: zoomLevel
                    )
                )
            }
        }
    }
    
    // go to the user location
    private func goToUserLocation() {
        if let userLocation = locationManager.userLocation{
            withAnimation {
                camera = .camera(
                    MapCamera(
                        centerCoordinate: userLocation,
                        distance: zoomLevel
                    )
                )
            }
        }
    }
}

#Preview {
    ContentView()
}

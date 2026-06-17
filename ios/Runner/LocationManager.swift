import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let manager = CLLocationManager()

    private var isTrackingStarted = false

    // =====================================================
    // INIT
    // =====================================================

    private override init() {

        super.init()

        manager.delegate = self

        // BETTER STABILITY FOR IOS
        manager.desiredAccuracy =
            kCLLocationAccuracyNearestTenMeters

        // REDUCE BATTERY DRAIN
        manager.distanceFilter = 20

        // BETTER FOR BACKGROUND TRACKING
        manager.activityType =
            .otherNavigation

        // DO NOT AUTO PAUSE
        manager.pausesLocationUpdatesAutomatically = false

        // REQUIRED FOR BACKGROUND LOCATION
        manager.allowsBackgroundLocationUpdates = true

        // SHOW BLUE LOCATION BAR
        if #available(iOS 11.0, *) {

            manager.showsBackgroundLocationIndicator = true
        }
    }

    // =====================================================
    // START TRACKING
    // =====================================================

    func startTracking() {

        // PREVENT MULTIPLE STARTS
        if isTrackingStarted {

            print("Tracking already started")
            return
        }

        print("START TRACKING")

        // CHECK IF LOCATION SERVICES ENABLED
        guard CLLocationManager.locationServicesEnabled() else {

            print("Location Services Disabled")
            return
        }

        if #available(iOS 14.0, *) {

            switch manager.authorizationStatus {

            case .notDetermined:

                print("Requesting Always Permission")

                manager.requestAlwaysAuthorization()

                return

            case .authorizedWhenInUse:

                print("Upgrading To Always Permission")

                manager.requestAlwaysAuthorization()

                return

            case .authorizedAlways:

                print("Always Permission Available")

                break

            default:

                print("Location Permission Denied")

                return
            }
        }

        startLocationServices()
    }

    // =====================================================
    // START SERVICES
    // =====================================================

    private func startLocationServices() {

        if isTrackingStarted {
            return
        }

        isTrackingStarted = true

        // STANDARD LOCATION UPDATES
        manager.startUpdatingLocation()

        // SIGNIFICANT LOCATION CHANGES
        manager.startMonitoringSignificantLocationChanges()

        print("Location services started")
    }

    // =====================================================
    // STOP TRACKING
    // =====================================================

    func stopTracking() {

        isTrackingStarted = false

        manager.stopUpdatingLocation()

        manager.stopMonitoringSignificantLocationChanges()

        print("Tracking stopped")
    }

    // =====================================================
    // AUTHORIZATION CHANGED
    // =====================================================

    func locationManager(
        _ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus
    ) {

        switch status {

        case .authorizedAlways:

            print("Always Permission Granted")

            startLocationServices()

        case .authorizedWhenInUse:

            print("When In Use Permission Granted")

        case .denied:

            print("Location Permission Denied")

        case .restricted:

            print("Location Restricted")

        case .notDetermined:

            print("Permission Not Determined")

        @unknown default:

            print("Unknown Authorization Status")
        }
    }

    // =====================================================
    // LOCATION UPDATE
    // =====================================================

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            return
        }

        // INVALID GPS
        if location.horizontalAccuracy < 0 {
            return
        }

        let latitude =
            location.coordinate.latitude

        let longitude =
            location.coordinate.longitude

        let speed =
            max(location.speed, 0)

        let accuracy =
            location.horizontalAccuracy

        let altitude =
            location.altitude

        let timestamp =
            Date().timeIntervalSince1970

        print("""
              =========================
              LOCATION UPDATE
              LAT: \(latitude)
              LNG: \(longitude)
              SPEED: \(speed)
              ACCURACY: \(accuracy)
              ALTITUDE: \(altitude)
              TIME: \(timestamp)
              =========================
              """)

        // =========================================
        // SAVE API / DATABASE HERE
        // =========================================
    }

    // =====================================================
    // ERROR
    // =====================================================

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        print("LOCATION ERROR: \(error.localizedDescription)")
    }

    // =====================================================
    // DEFERRED UPDATE ERROR
    // =====================================================

    func locationManager(
        _ manager: CLLocationManager,
        didFinishDeferredUpdatesWithError error: Error?
    ) {

        if let error = error {

            print("Deferred Update Error: \(error.localizedDescription)")
        }
    }
}
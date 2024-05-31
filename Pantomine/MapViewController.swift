//
//  MapViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 5/2/21.
//

import UIKit
import GeoFire
import Kingfisher
import Firebase

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let viewSlideUp = UIView()
    let locationManager = CLLocationManager()
    var isOut = false
    var addedKeys = [String]()
    var places = [Place]()
    var events = [Event]()
    var firstSave = false
    var firstSavedLoc = CLLocationCoordinate2D()
    var timerEveryTwo = false
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = kCLDistanceFilterNone
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        //uploadLocation()
        checkLocationStuff()
        // Do any additional setup after loading the view.
    }
    
    
    func checkLocationStuff() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    self.grabNearbyPins(location: locationManager.location!)
                    self.grabNearbyEvents(location: locationManager.location!)
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    self.places.removeAll()
                    self.grabNearbyPins(location: locationManager.location!)
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
        }
      }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.mapView.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotationCoordinate = view.annotation?.coordinate
        {
            let long = annotationCoordinate.longitude
            let lat = annotationCoordinate.latitude
            let key = "\(long)-\(lat)"
            let place = getPlaceForCoord(cl: key)
            if place.titler != nil {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "selectedPlaceVC") as! UINavigationController
                let datavc = vc.viewControllers.first as! SelectedPlaceViewController
                datavc.place = place
                datavc.key = place.key
                datavc.configure(place: place)
                self.present(vc, animated: true, completion: {
                self.mapView.deselectAnnotation(view.annotation, animated: true)
                    
            })
            }
        }

    }
    
    func grabNearbyPins(location: CLLocation) {
        self.timerEveryTwo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.timerEveryTwo = false
        }
        let geofireRef = Database.database().reference().child("PinsLocs")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        var keys = [String]()
        if CLLocationManager.locationServicesEnabled() {
            print("here grabbing")
            
            //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
            // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters\\
            let circleQuery = geoFire.query(at: location, withRadius: 100)
            circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                keys.append(key)
            })
            circleQuery.observeReady({
                self.loadPinsFromKeys(keys: keys)
            })
        }
    }
    
    func loadPinsFromKeys(keys: [String]) {
        for each1 in keys {
            let ref = Database.database().reference().child("Pins").child(each1)
            ref.queryOrderedByKey().observeSingleEvent(of: .value, with: {(snap) in
                let value = snap.value as? [String : AnyObject]
                        if let name = value?["name"] as? String, let key = value?["key"] as? String, let long = value?["long"] as? Double, let lat = value?["lat"] as? Double {
                            let newObject = Place()
                            newObject.titler = name
                            newObject.key = key
                            if let descript = value?["des"] as? String {
                                newObject.desc = descript
                            }
                            if let ratio = value?["ratio"] as? Double {
                                newObject.ratio = ratio
                            }
                            if let urlImg = value?["urlImage"] as? String {
                                newObject.imageUrl = urlImg
                            }
                            if let filters = value?["filters"] as? [String] {
                                newObject.filters = filters
                            }
                            if let types = value?["types"] as? [String] {
                                newObject.types = types
                            }
                            newObject.hasHours = false
                            if let openHour = value?["openHour"] as? Int, let openMin = value?["openMin"] as? Int, let closeHour = value?["closeHour"] as? Int, let closeMin = value?["closeMin"] as? Int {
                                newObject.hasHours = true
                                newObject.openHour = openHour
                                newObject.openMin = openMin
                                newObject.closeHour = closeHour
                                newObject.closeMin = closeMin
                            }
                            if let closedDays = value?["daysClose"] as? [Int] {
                                newObject.closedDays = closedDays
                            }
                            let myLocation = CLLocation(latitude:  self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude)

                            //My buddy's location
                            let myBuddysLocation = CLLocation(latitude: lat, longitude: long)
                            let distanceInMeters = myLocation.distance(from: myBuddysLocation)
                            let distanceInMiles = distanceInMeters/1609.344
                            let fixedDouble = distanceInMiles.rounded(toPlaces: 2)
                            newObject.distanceAway = fixedDouble
                            newObject.longLatKey = "\(long)-\(lat)"
                            newObject.long = long
                            newObject.lat = lat
                            if !self.addedKeys.contains(each1) {
                                self.places.append(newObject)
                                self.addObjectToMap(obj: newObject)
                                self.addedKeys.append(each1)
                                print("ADDED MAP")
                            }
                        }
            })
        }
    }
    
    func addObjectToMap(obj: Place) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: obj.lat!, longitude: obj.long!)
        annotation.title = "Place"
        mapView.addAnnotation(annotation)
    }
    
    func grabNearbyEvents(location: CLLocation) {
        self.timerEveryTwo = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.timerEveryTwo = false
        }
        let geofireRef = Database.database().reference().child("EventLocs")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        var keys = [String]()
        if CLLocationManager.locationServicesEnabled() {
            print("here grabbing")
            
            //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
            // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters\\
            let circleQuery = geoFire.query(at: location, withRadius: 100)
            circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                keys.append(key)
            })
            circleQuery.observeReady({
                self.loadEventsFromKeys(keys: keys)
            })
        }
    }
    
    func loadEventsFromKeys(keys: [String]) {
        for each1 in keys {
            let ref = Database.database().reference().child("Events").child(each1)
            ref.queryOrderedByKey().observeSingleEvent(of: .value, with: {(snap) in
                let value = snap.value as? [String : AnyObject]
                        if let name = value?["name"] as? String, let key = value?["key"] as? String, let long = value?["long"] as? Double, let lat = value?["lat"] as? Double {
                            let newObject = Event()
                            newObject.titler = name
                            newObject.key = key
                            if let descript = value?["des"] as? String {
                                newObject.descript = descript
                            }
                            if let urlImg = value?["urlImage"] as? String {
                                newObject.urlImage = urlImg
                            }
                            if let filters = value?["filters"] as? [String] {
                                newObject.filters = filters
                            }
                            
    
                            let myLocation = CLLocation(latitude:  self.locationManager.location!.coordinate.latitude, longitude: self.locationManager.location!.coordinate.longitude)

                            //My buddy's location
                            let myBuddysLocation = CLLocation(latitude: lat, longitude: long)
                            let distanceInMeters = myLocation.distance(from: myBuddysLocation)
                            let distanceInMiles = distanceInMeters/1609.344
                            let fixedDouble = distanceInMiles.rounded(toPlaces: 2)
                            newObject.distanceAway = fixedDouble
                            newObject.longLatKey = "\(long)-\(lat)"
                            newObject.long = long
                            newObject.lat = lat
                            if !self.addedKeys.contains(each1) {
                                self.events.append(newObject)
                                self.addEventToMap(obj: newObject)
                                self.addedKeys.append(each1)
                                print("ADDED MAP")
                            }
                        }
            })
        }
    }
    
    func addEventToMap(obj: Event) {
        let annotation = MKPointAnnotation()
        annotation.title = "Event"
        annotation.coordinate = CLLocationCoordinate2D(latitude: obj.lat!, longitude: obj.long!)
        mapView.addAnnotation(annotation)
    }
    
    
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // Check for type here, not for the Title!!!
            guard !(annotation is MKUserLocation) else {
                // we do not want to return a custom View for the User Location
                return nil
            }
            let identifier = "Identifier for this annotation"
            let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        if annotation.title == "Event" {
            annotationView.image = UIImage(named: "pin")
        } else {
            annotationView.image = UIImage(named: "mapIcon")
        }
           
            annotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)

            annotationView.canShowCallout = false
            return annotationView
        }
    
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    func getPlaceForCoord(cl: String) -> Place {
        if let firstInd = places.firstIndex(where: { $0.longLatKey == cl }) {
            let place = places[firstInd]
            return place
        }
        return Place()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("\(mapView.region.center.latitude) lattt")
        if firstSave == false {
            firstSavedLoc = mapView.region.center
            firstSave = true
            return
        }
        let locationOriginal = CLLocation(latitude: firstSavedLoc.latitude, longitude: firstSavedLoc.longitude)
        let locationNow = CLLocation(latitude: mapView.region.center.latitude, longitude: mapView.region.center.longitude)
        let distanceInMeters = locationOriginal.distance(from: locationNow)
        let distanceInMiles = distanceInMeters/1609.344
        if distanceInMiles > 60 && timerEveryTwo == false {
            self.firstSavedLoc = mapView.region.center
            self.grabNearbyPins(location: locationNow)
        }
    }
    
    
    
}
private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 100
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

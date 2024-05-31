//
//  PostPhotoViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 4/2/22.
//

import UIKit
import GeoFire
import Kingfisher
import Firebase
import MapKit

class PostPhotoViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var addedKeys = [String]()
    var places = [Place]()
    var selectedImages: [UIImage]?
    var miniViewSpot = UIView()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "Select Spot"
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = kCLDistanceFilterNone
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        self.mapView.addSubview(miniViewSpot)
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
                   self.grabNearbyPins()
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
                   self.grabNearbyPins()
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
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.navigationItem.rightBarButtonItem = nil
        self.selectedPlace = nil
    }
    
    var selectedPlace: Place?
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotationCoordinate = view.annotation?.coordinate
        {
            let long = annotationCoordinate.longitude
            let lat = annotationCoordinate.latitude
            let key = "\(long)-\(lat)"
            let place = getPlaceForCoord(cl: key)
            if place.titler != nil {
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(postTapped))
                selectedPlace = place
//                miniViewSpot = UIView(frame: CGRect(x: 15, y: view.frame.height - 200, width: view.frame.width - 30, height: 185))
//                let miniImageView = UIImageView()
//                let miniTitle = UILabel()
//                let miniDeny = UIButton(frame: CGRect(x: 40, y: 155, width: miniViewSpot.frame.width - 80, height: 40))
//                let miniConfirm = UIButton(frame: CGRect(x: 40, y: 105, width: miniViewSpot.frame.width - 80, height: 40))
//                miniImageView.frame = CGRect(x: 15 , y: 15, width: 60, height: 60)
//                if let url = URL(string: place.imageUrl ?? "") {
//                    miniImageView.kf.setImage(with: url)
//                }
//                miniImageView.layer.cornerRadius = 4
//                miniTitle.frame = CGRect(x: 95, y: 15, width: miniViewSpot.frame.width - 110, height: 80)
//                miniTitle.numberOfLines = 0
//                miniTitle.textAlignment = .center
//                miniTitle.font = UIFont(name: "Helvetica-Bold", size: 17)
//                miniTitle.text = place.titler
//
//                miniConfirm.setTitle("Post To This Spot", for: .normal)
//                miniConfirm.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
//                miniConfirm.titleLabel?.textColor = .white
//                miniConfirm.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 16)
//                miniConfirm.layer.cornerRadius = 8
//
//                miniDeny.setTitle("Cancel", for: .normal)
//                miniDeny.backgroundColor = .white
//                miniDeny.titleLabel?.textColor = .lightGray
//                miniDeny.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 16)
//
//                miniViewSpot.layer.cornerRadius = 4
//                miniViewSpot.addSubview(miniImageView)
//                miniViewSpot.addSubview(miniTitle)
//                miniViewSpot.addSubview(miniConfirm)
//                miniViewSpot.addSubview(miniDeny)
                
//                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "selectedPlaceVC") as! UINavigationController
//                let datavc = vc.viewControllers.first as! SelectedPlaceViewController
//                datavc.place = place
//                datavc.key = place.key
//                datavc.configure(place: place)
//                self.present(vc, animated: true, completion: {
//                self.mapView.deselectAnnotation(view.annotation, animated: true)
//            })
            }
        }
    }
    
    @objc func postTapped() {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        if let images = self.selectedImages, let place = selectedPlace {
            var count = 0;
            let activity = UIActivityIndicatorView()
            activity.frame = view.frame
            activity.color = .black
            activity.backgroundColor = .white
            activity.startAnimating()
            view.addSubview(activity)
            for each in images {
                count+=1
                let key = random(digits: 20)
                if CLLocationManager.locationServicesEnabled() {
                    print("at least here 3")
                    if let uid = Auth.auth().currentUser?.uid, let lat = place.lat, let long = place.long, let placeId = place.key {
                    let storage = Storage.storage().reference().child("photos").child(key)
                    if let uploadData = each.jpegData(compressionQuality: 0.6) {
                        storage.putData(uploadData, metadata: nil, completion:
                            { (metadata, error) in
                                print("at least here")
                                guard let metadata = metadata else {
                                    // Uh-oh, an error occurred!
                                    print(error!)
                                    return
                                }
                                let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
                                    storage.downloadURL { url, error in
                                    guard let downloadURL = url else {
                                        print("erroor downl")
                                        return
                                    }

                                    let urlLoad = downloadURL.absoluteString
                                        let locat = CLLocation(latitude: lat, longitude: long)
                                    let geofireRef = Database.database().reference().child("PhotosLocs")
                                    let geoFire = GeoFire(firebaseRef: geofireRef)
                                    if CLLocationManager.locationServicesEnabled() {
                                        geoFire.setLocation(locat, forKey: key)
                                    }
                                        let result = ["urlPhoto" : urlLoad, "time" : timeStamp, "key" : key, "long" : long, "lat" : lat, "postedByUid" : uid, "views" : 1, "keyPlace" : placeId] as [String : Any]
                                    let update = [key : result]
                                        Database.database().reference().child("Pins").child(placeId).child("photos").updateChildValues(update)
                                        Database.database().reference().child("Pins").child(placeId).child("pinPhotos").updateChildValues([urlLoad : urlLoad])
                                        Database.database().reference().child("Photos").updateChildValues(update)
                                       
                                        if count == images.count {
                                            activity.stopAnimating()
                                            self.dismiss(animated: true, completion: nil)
                                        }
                                    }
                                    
                                })
                            }
                        }
                    }
            }
        }
    }
    
    @IBAction func exitAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getPlaceForCoord(cl: String) -> Place {
        if let firstInd = places.firstIndex(where: { $0.longLatKey == cl }) {
            let place = places[firstInd]
            return place
        }
        return Place()
    }
    
    func grabNearbyPins() {
        let geofireRef = Database.database().reference().child("PinsLocs")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        var keys = [String]()
        if CLLocationManager.locationServicesEnabled() {
            print("here grabbing")
            
            //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
            // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters\\
            let circleQuery = geoFire.query(at: locationManager.location!, withRadius: 100)
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
        annotation.title = obj.titler
        mapView.addAnnotation(annotation)
        
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
}

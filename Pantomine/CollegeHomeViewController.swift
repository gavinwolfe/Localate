//
//  CollegeHomeViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 5/13/22.
//

import UIKit
import Firebase
import Kingfisher
import GeoFire
import YPImagePicker

class CollegeHomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {

    var all = [homeObject]()
    var events = [Event]()
    var spots = [Place]()
    
    var images = [UIImage(named: "ventureIn1"), UIImage(named: "ventureIn2"), UIImage(named: "ventureIn3"), UIImage(named: "ventureIn4"), UIImage(named: "ventureIn5"), UIImage(named: "ventureIn6"), UIImage(named: "ventureIn7"), UIImage(named: "ventureIn8")]
    var currentPhoto = UIImage()
    var kind = ""
    var activeFilters = [String]()
    var showPublicLocalateItems = false
    let collectionViewHeaderFooterReuseIdentifier = "collegeHomeReuseView"
    let collectionViewHeaderFooterReuseIdentifierDummy = "DummyHomeCollectionReusableView"
    private var numberOfItemsInRow = 2
    private var minimumSpacing = 4
    private var edgeInsetPadding = 10
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var collectionView: UICollectionView!
    let buttonCam = UIButton()
    var timer = Timer()
    var interval = 1
    
    var segmentIndex = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.register(UINib(nibName: collectionViewHeaderFooterReuseIdentifier, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:collectionViewHeaderFooterReuseIdentifier)
        
        collectionView.register(UINib(nibName: collectionViewHeaderFooterReuseIdentifierDummy, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:collectionViewHeaderFooterReuseIdentifierDummy)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        checkAnnon()
        checkLocationStuff()
        uiInitialization()
        currentPhoto = UIImage(named: "photoProtect1") ?? UIImage()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    func checkAnnon () {
        if Auth.auth().currentUser?.isAnonymous == true {
            //all good
        } else {
            Auth.auth().signInAnonymously() { (authResult, error) in
                if (authResult != nil) {
                    print("Annoymously logged in")
                } else {
                    print("Login Error")
                }
            }
        }
    }
    
    func checkLocationStuff() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    locationManager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
//                    fetchNearbyEvents()
//                    fetchNearbyPhotos()
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
                    locationManager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
//                    fetchNearbyEvents()
//                    fetchNearbyPhotos()
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
        }
      }
    
    func uiInitialization() {
        buttonCam.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 190, width: 90, height: 90)
        buttonCam.setImage(#imageLiteral(resourceName: "createIcon"), for: .normal)
        buttonCam.layer.shadowRadius = 1.5
        buttonCam.layer.shadowColor = UIColor.black.cgColor
        buttonCam.layer.shadowOpacity = 0.5
        buttonCam.addTarget(self, action: #selector(self.postImage), for: .touchUpInside)
        view.addSubview(self.buttonCam)
    }
    
    @objc func fadeInAndOut () {
        let indexPath = IndexPath(item: 0, section: 0)
        if let cell = collectionView.supplementaryView(forElementKind: kind, at: indexPath)  as? CollegeCollectionReusableView {
           // cell.imageView.fadeOut()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                cell.imageView.image = self.images[self.interval]
                self.currentPhoto = self.images[self.interval] ?? UIImage()
                //cell.imageView.fadeIn()
                if self.interval == 7 {
                    self.interval = 0
                } else {
                    self.interval += 1
                }
            })
        }
    }
    
    @objc func postImage() {
        let alert = UIAlertController(title: "Select an Option", message: "", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "Add Photo to Spot", style: .default, handler: { (action : UIAlertAction!) -> Void in
            self.openPicker()
        })
        let action2 = UIAlertAction(title: "Create New Spot", style: .default, handler: { (action : UIAlertAction!) -> Void in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "selectLocationVC") as! UINavigationController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        })
        let action3 =  UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        self.present(alert, animated: true, completion: nil)
    }
    
    func openPicker() {
        var config = YPImagePickerConfiguration()
        config.library.maxNumberOfItems = 3
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.showsPhotoFilters = true
        config.shouldSaveNewPicturesToAlbum = true
        config.startOnScreen = YPPickerScreen.photo
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        let picker = YPImagePicker(configuration: config)
        present(picker, animated: true, completion: nil)
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                print("cancelled")
            }
            var photosPicked = [UIImage]()
            for item in items {
                switch item {
                case .photo(let photo):
                    photosPicked.append(photo.originalImage)
                case .video(let video):
                    print(video)
                }
            }
            picker.dismiss(animated: true, completion: {
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "postPhotoVC") as! UINavigationController
                let datavc = vc.viewControllers.first as! PostPhotoViewController
                datavc.selectedImages = photosPicked
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            })
        }
    }
    
    //COLLECTIONVIEW
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        if segmentIndex == 1 {
            return events.count
        }
        if segmentIndex == 2 {
            return spots.count
        }
        return all.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section == 0 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCollegeHomeCell", for: indexPath) as! emptyCollegeHomeCell
            return cell
        }
        if segmentIndex == 0 {
            if all[indexPath.item].type == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollegeHome", for: indexPath) as! collegeHomeEventCell
                if let source = self.all[indexPath.item].imageUrl, let url = URL(string: source), let source2 = self.all[indexPath.item].urlImage2, let url2 = URL(string: source2) {
                    cell.imageView1.kf.setImage(with: url)
                    cell.imageView2.kf.setImage(with: url2)
                    if let source3 = self.all[indexPath.item].urlImage3, let url3 = URL(string: source3) {
                        cell.imageView3.kf.setImage(with: url3)
                    } else {
                        cell.imageView3.image = UIImage(named: "gallery")
                    }
                }
                cell.titleLab.text = self.all[indexPath.item].titler
                if self.all[indexPath.item].annonymousPost == true {
                    if let time = self.all[indexPath.item].timeCreated {
                        cell.creatorLab.text = returnTimeString(time: time)
                    }
                } else {
                    cell.creatorLab.text = "by \(self.all[indexPath.item].creatorUn ?? "")"
                }
                cell.distanceLabel.text = "\(self.all[indexPath.item].distanceAway) miles away"
                cell.timeLabel.text = eventTimeString(start: self.all[indexPath.item].startDate, end: self.all[indexPath.item].endDate)
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollegePlace", for: indexPath) as! collegeHomeSpotCell
                cell.distanceLabel.text = "\(self.all[indexPath.item].distanceAway) miles away"
                if let source = self.all[indexPath.item].imageUrl, let url1 = URL(string: source) {
                    cell.imageView.kf.setImage(with: url1)
                    if let source2 = self.all[indexPath.item].urlImage2, let source3 = self.all[indexPath.item].urlImage3, let url2 = URL(string: source2), let url3 = URL(string: source3) {
                        cell.moreThanTwoImages = true
                        cell.imageView2.kf.setImage(with: url2)
                        cell.imageView3.kf.setImage(with: url3)
                    }
                }
                cell.titleLabel.text = self.all[indexPath.item].titler
                cell.percentLikeLabel.text = "\(self.all[indexPath.item].ratio)% liked"
                return cell
            }
        } else if segmentIndex == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollegeHome", for: indexPath) as! collegeHomeEventCell
            if let source = self.events[indexPath.item].urlImage, let url = URL(string: source), let source2 = self.events[indexPath.item].urlImage2, let url2 = URL(string: source2) {
                cell.imageView1.kf.setImage(with: url)
                cell.imageView2.kf.setImage(with: url2)
                if let source3 = self.events[indexPath.item].urlImage3, let url3 = URL(string: source3) {
                    cell.imageView3.kf.setImage(with: url3)
                } else {
                    cell.imageView3.image = UIImage(named: "gallery")
                }
            }
            cell.titleLab.text = self.events[indexPath.item].titler
            if self.events[indexPath.item].isAnnonymous == true {
                if let time = self.events[indexPath.item].timeCreated {
                    cell.creatorLab.text = returnTimeString(time: time)
                }
            } else {
                cell.creatorLab.text = "by \(self.events[indexPath.item].creatorUn ?? "")"
            }
            cell.distanceLabel.text = "\(self.events[indexPath.item].distanceAway) miles away"
            cell.timeLabel.text = eventTimeString(start: self.all[indexPath.item].startDate, end: self.all[indexPath.item].endDate)
        } else if segmentIndex == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellCollegePlace", for: indexPath) as! collegeHomeSpotCell
            cell.distanceLabel.text = "\(self.spots[indexPath.item].distanceAway) miles away"
            if let source = self.spots[indexPath.item].imageUrl, let url1 = URL(string: source) {
                cell.imageView.kf.setImage(with: url1)
                if let source2 = self.spots[indexPath.item].urlImage2, let source3 = self.spots[indexPath.item].urlImage3, let url2 = URL(string: source2), let url3 = URL(string: source3) {
                    cell.moreThanTwoImages = true
                    cell.imageView2.kf.setImage(with: url2)
                    cell.imageView3.kf.setImage(with: url3)
                }
            }
            cell.titleLabel.text = self.spots[indexPath.item].titler
            cell.percentLikeLabel.text = "\(self.spots[indexPath.item].ratio)% liked"
            return cell
        }
        return UICollectionViewCell()
    }
    func fetchSequence() {
        if let college = UserDefaults.standard.string(forKey: "college") {
           getGeoEvents(college: college)
            getGeoPlaces(college: college)
        } else {
            getGeoEvents(college: "")
            getGeoPlaces(college: "")
        }
        //fetch events
        
        //then fetch places
    }
    func getGeoEvents(college: String) {
        if college == "" {
            let geofireRef = Database.database().reference().child("EventsLocs")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            var keys = [String]()
            if CLLocationManager.locationServicesEnabled() {
                //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
                // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
                let circleQuery = geoFire.query(at: locationManager.location!, withRadius: 50)
                circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    keys.append(key)
                })
                circleQuery.observeReady({
                    self.getEventsFromKeys(keys: keys) {
                    }
                })
            } else {
                //self.activityOne.stopAnimating()
            }
        } else {
            let geofireRef = Database.database().reference().child("EventsLocs\(college)")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            var keys = [String]()
            if CLLocationManager.locationServicesEnabled() {
                //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
                // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
                let circleQuery = geoFire.query(at: locationManager.location!, withRadius: 50)
                circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    keys.append(key)
                })
                circleQuery.observeReady({
                    self.getEventsFromKeys(keys: keys) {
                        if self.showPublicLocalateItems {
                            var keys2 = [String]()
                            let geofireRef2 = Database.database().reference().child("EventsLocs")
                            let geoFire2 = GeoFire(firebaseRef: geofireRef2)
                            let circleQuery2 = geoFire2.query(at: self.locationManager.location!, withRadius: 50)
                            circleQuery2.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                                keys2.append(key)
                            })
                            circleQuery.observeReady({
                                self.getEventsFromKeys(keys: keys2) {
                                }
                            })
                            
                        }
                    }
                })
            }
        }
    }
    
    func getEventsFromKeys(keys: [String], finished: @escaping () -> Void) {
        let dispatch = DispatchGroup()
        for each1 in keys {
            dispatch.enter()
            let ref = Database.database().reference().child("Events").child(each1)
            ref.queryOrderedByKey().observeSingleEvent(of: .value, with: {(snap) in
                let value = snap.value as? [String : AnyObject]
                if let name = value?["name"] as? String, let key = value?["key"] as? String, let long = value?["long"] as? Double, let lat = value?["lat"] as? Double, let des = value?["des"] as? String, let postedByUid = value?["postedByUid"] as? String, let time = value?["time"] as? String {
                    let newObject = Event()
                    newObject.titler = name
                    newObject.key = key
                    newObject.descript = des
                    newObject.postedId = postedByUid
                    if let urlImg = value?["urlImage"] as? String {
                        newObject.urlImage = urlImg
                    }
                    newObject.long = long
                    newObject.lat = lat
                    newObject.dateStart = time
                    if !self.events.contains(where: {$0.key == each1}) && self.events.count < 20 {
                        self.events.append(newObject)
                    }
                }
                dispatch.leave()
            })
        }
        dispatch.notify(queue: DispatchQueue.main) {
//            self.collectionView.reloadData()
//            self.activityOne.stopAnimating()
//            print("reloadedevents\(self.events.count)")
            finished()
            
        }
    }
    func getGeoPlaces(college: String) {
        if college == "" {
        let geofireRef = Database.database().reference().child("PinsLocs")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        var keys = [String]()
        if CLLocationManager.locationServicesEnabled() {
            //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
            // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
            let circleQuery = geoFire.query(at: locationManager.location!, withRadius: 35)
            circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                keys.append(key)
            })
            circleQuery.observeReady({
               /// self.loadPinsFromKeys(keys: keys)
            })
        }
        
        } else {
            let geofireRef = Database.database().reference().child("PinsLocs")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            var keys = [String]()
            if CLLocationManager.locationServicesEnabled() {
                //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
                // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
                let circleQuery = geoFire.query(at: locationManager.location!, withRadius: 35)
                circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                    keys.append(key)
                })
                circleQuery.observeReady({
                   // self.loadPinsFromKeys(keys: keys)
                })
            } else {
               // self.activity2.stopAnimating()
            }
        }
    }
    
    var addedKeys = [String]()
    func loadPinsFromKeys(keys: [String], finished: @escaping () -> Void)  {
        let dispatch = DispatchGroup()
        for each1 in keys {
            dispatch.enter()
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
                            newObject.sortRank = Int.random(in: 0 ... 10)
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
                                //self.places.append(newObject)
                                self.addedKeys.append(each1)
                                print(key)
                                print("ADDED MAP")
                            }
                        }
                dispatch.leave()
            })
        }
        dispatch.notify(queue: DispatchQueue.main) {
            self.collectionView.reloadData()
            //self.places = self.places.sorted(by: { $0.sortRank > $1.sortRank })
           // self.allPlaces = self.places
            //self.activity2.stopAnimating()
          //  print("reloaded\(self.places.count)")
            finished()
        }
    }
   
    
    func returnTimeString(time: Int) -> String {
        let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
        let timer = timeStamp - time
        
        if timer <= 59 {
            return "\(timer)s ago"
        }
        
        if timer > 59 && timer < 3600 {
            let minuters = timer / 60
            if minuters == 1 {
                return "\(minuters) min ago"
            }
            return "\(minuters) mins ago"
            
        }
        if timer > 59 && timer >= 3600 && timer < 86400 {
            let hours = timer / 3600
            if hours == 1 {
                return "\(hours) hr ago"
            } else {
                return "\(hours) hrs ago"
            }
        }
        if timer > 86400 {
            let days = timer / 86400
            if days == 1 {
                return "\(days)day ago"
            }
            return "\(days)days ago"
        }
        return ""
    }
    
    func eventTimeString(start: Date, end: Date) -> String {
        let currentDate = Date()
        let startHour = Calendar.current.component(.hour, from: start)
        let startMin = Calendar.current.component(.minute, from: start)
        let endHour = Calendar.current.component(.hour, from: end)
        if Calendar.current.isDate(currentDate, inSameDayAs:start) {
            if startHour >= Calendar.current.component(.hour, from: Date()) {
                if startHour == Calendar.current.component(.hour, from: Date()) {
                    if startMin > Calendar.current.component(.minute, from: Date()) {
                        if startHour > 14 {
                            return "Tonight at \(startHour):\(startMin) pm"
                        } else if startHour >= 12 && startHour <= 14 {
                            return "Today at \(startHour):\(startMin) pm"
                        } else {
                            return "Today at \(startHour):\(startMin) am"
                        }
                    } else {
                        if endHour >= 12 {
                            return "Happening till \(startHour):\(startMin) pm"
                        } else {
                            return "Happening till \(startHour):\(startMin) am"
                        }
                    }
                }
                if startHour > 14 {
                    return "Tonight at \(startHour):\(startMin) pm"
                } else if startHour >= 12 && startHour <= 14 {
                    return "Today at \(startHour):\(startMin) pm"
                } else {
                    return "Today at \(startHour):\(startMin) am"
                }
            } else {
                let endHour = Calendar.current.component(.hour, from: end)
                if endHour >= 12 {
                    return "Happening till \(startHour):\(startMin) pm"
                } else {
                    return "Happening till \(startHour):\(startMin) am"
                }
            }
        } else {
            
        }
        return ""
    }
    
    
    
    
}

extension CollegeHomeViewController: selectSearch {
    func search() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "searchVC") as! UINavigationController
        if let viewCon = vc.viewControllers[0] as? SearchViewController {
            viewCon.delRes = spots
        }
        self.present(vc, animated: true, completion: nil)
    }
}
  

class collegeHomeEventCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLab: UILabel!
    
    @IBOutlet weak var creatorLab: UILabel!
    
    @IBOutlet weak var activeIcon: UIImageView!
    
    @IBOutlet weak var viewsLabel: UILabel!
    
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var goButton: UIButton!
    
    
    override func layoutSubviews() {
        titleLab.frame = CGRect(x: 5, y: 6, width: contentView.frame.width - 12, height: 70)
        creatorLab.frame = CGRect(x: 5, y: 76, width: contentView.frame.width - 10, height: 25)
        activeIcon.frame = CGRect(x: contentView.frame.width - 20, y: 5, width: 15, height: 15)
        imageView1.frame = CGRect(x: 0, y: 100, width: contentView.frame.width/3, height: contentView.frame.width/3)
        imageView2.frame = CGRect(x: contentView.frame.width/3, y: 100, width: contentView.frame.width/3, height: contentView.frame.width/3)
        imageView3.frame = CGRect(x: contentView.frame.width/3 + contentView.frame.width/3, y: 100, width: contentView.frame.width/3, height: contentView.frame.width/3)
        timeLabel.frame = CGRect(x: 5, y: 110 + contentView.frame.width/3, width: contentView.frame.width - 10, height: 30)
        goButton.frame = CGRect(x: 20, y: contentView.frame.height - 40, width: contentView.frame.width - 40, height: 35)
        
    }
    
}

class collegeHomeSpotCell: UICollectionViewCell {
    
    var moreThanTwoImages = false
    
    @IBOutlet weak var distanceLabel: UILabel!
    var photoCount: Int?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var percentLikeLabel: UILabel!
    
    @IBOutlet weak var outlineView: UIView!
    
    @IBOutlet weak var backView: UIView!
    
    
    override func layoutSubviews() {
        var smallScale = false
        if let photoCount = photoCount {
            if photoCount <= 2 {
                smallScale = true
            }
        }
        backView.frame = CGRect(x: 0, y: 20, width: contentView.frame.width, height: contentView.frame.width - 70)
        if smallScale {
            imageView.frame = CGRect(x: 5, y: 0, width: contentView.frame.width - 10, height: backView.frame.height / 2)
            imageView2.frame = CGRect(x: 5, y: backView.frame.height / 2, width: contentView.frame.width - 10, height: backView.frame.height / 2)
        } else {
            imageView.frame = CGRect(x: 5, y: 0, width: contentView.frame.width - 10, height: backView.frame.height / 2)
            imageView2.frame = CGRect(x: 5, y: backView.frame.height / 2, width: (backView.frame.width - 10)/2, height: (backView.frame.width - 10)/2)
            imageView3.frame = CGRect(x: 5 + backView.frame.width/2, y: backView.frame.height / 2, width: (backView.frame.width - 10)/2, height: (backView.frame.width - 10)/2)
            
        }
    }
}

class emptyCollegeHomeCell: UICollectionViewCell {
    
}
    


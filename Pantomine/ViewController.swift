//
//  ViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 4/7/21.
//

import UIKit
import GeoFire
import Kingfisher
import Firebase
import YPImagePicker

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate, UICollectionViewDelegateFlowLayout, selectedFilter, selectSearch {
    
    var images = [UIImage(named: "ventureIn1"), UIImage(named: "ventureIn2"), UIImage(named: "ventureIn3"), UIImage(named: "ventureIn4"), UIImage(named: "ventureIn5"), UIImage(named: "ventureIn6"), UIImage(named: "ventureIn7"), UIImage(named: "ventureIn8")]
    var currentPhoto = UIImage()
    var kind = ""
    private var numberOfItemsInRow = 2
    private var minimumSpacing = 4
    private var edgeInsetPadding = 10
    
    let collectionViewHeaderFooterReuseIdentifier = "HeaderCollectionReusableView"
    let collectionViewHeaderFooterReuseIdentifierDummy = "DummyHomeCollectionReusableView"
    var isAdmin = false
    let buttonCam = UIButton()

    @IBOutlet weak var collectionView: UICollectionView!
    
    let locationManager = CLLocationManager()
    var events = [Event]()
    var places = [Place]()
    var photos = [PhotoPost]()
    var allPlaces = [Place]()
    var filterOut = false
    var filterType = 0
    var defaultFilters = ["Outdoor", "Shopping", "Food And Drink", "Scenic", "Experiences", "Nightlife"]
    var activeFilters = [String]()
    var timer = Timer()
    let viewShowCollege = UIView()
    
    func checkAnnon () {
        if Auth.auth().currentUser?.isAnonymous == true {
            //all good
        } else {
            Auth.auth().signInAnonymously() { (authResult, error) in
            
            }
        }
    }
    
    func checkAddedCollege () {
        if let shownAddCollege = UserDefaults.standard.string(forKey: "showAddCollege") {
            //all good
        } else {
            showCollegeView()
        }
    }
    
    func search() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "searchVC") as! UINavigationController
        if let viewCon = vc.viewControllers[0] as? SearchViewController {
            viewCon.delRes = self.allPlaces
        }
        self.present(vc, animated: true, completion: nil)
    }
    
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
        checkAddedCollege()
        //collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        checkLocationStuff()
        buttonCam.frame = CGRect(x: self.view.frame.width - 100, y: self.view.frame.height - 190, width: 90, height: 90)
        buttonCam.setImage(#imageLiteral(resourceName: "createIcon"), for: .normal)
        buttonCam.layer.shadowRadius = 1.5
        buttonCam.layer.shadowColor = UIColor.black.cgColor
        buttonCam.layer.shadowOpacity = 0.5
        buttonCam.addTarget(self, action: #selector(self.postImage), for: .touchUpInside)
        activityOne.backgroundColor = .clear
        activityOne.color = .white
        activityOne.frame = CGRect(x: 0, y: view.frame.height / 2 - 150, width: view.frame.width, height: 100)
        activity2.backgroundColor = .clear
        activity2.color = .white
        activity2.frame = CGRect(x: 0, y: view.frame.height / 2 + 150, width: view.frame.width, height: 100)
        view.addSubview(self.buttonCam)
        let value = UserDefaults.standard.string(forKey: "isAdmin")
        if value != "" && value != nil {
            isAdmin = true
        }
      
        currentPhoto = UIImage(named: "photoProtect1") ?? UIImage()
            
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if CLLocationManager.locationServicesEnabled() {
        }
    }
    
    var interval = 1
    @objc func fadeInAndOut () {
        let indexPath = IndexPath(item: 0, section: 0)
        if let cell = collectionView.supplementaryView(forElementKind: kind, at: indexPath)  as? HeaderCollectionReusableView {
            //cell.imageView.fadeOut()
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

    
    func checkLocationStuff() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    print("No access")
                    locationManager.requestWhenInUseAuthorization()
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    self.places.removeAll()
                    self.events.removeAll()
                    self.photos.removeAll()
                    fetchNearbyPlaces()
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
                    self.activityOne.stopAnimating()
                    self.activity2.stopAnimating()
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                    self.places.removeAll()
                    self.events.removeAll()
                    self.photos.removeAll()
                    fetchNearbyPlaces()
//                    fetchNearbyEvents()
//                    fetchNearbyPhotos()
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
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

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return self.places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard indexPath.section == 1 else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dummyHomeCell", for: indexPath) as! dummyHomeCell
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellHome", for: indexPath) as! collectionViewCell
        if let source = self.places[indexPath.item].imageUrl, let url = URL(string: source) {
            cell.imageView.kf.setImage(with: url)
        }
        cell.titleLabel.text = self.places[indexPath.row].titler
        cell.likeLabel.text = "\(Int(self.places[indexPath.row].ratio ?? 100))% Liked"
        return cell
    }
    var oneTimeTimerAdd = true
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if indexPath.section == 1 {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionViewHeaderFooterReuseIdentifierDummy, for: indexPath) as! DummyHomeCollectionReusableView
            return view
        }
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: collectionViewHeaderFooterReuseIdentifier, for: indexPath) as! HeaderCollectionReusableView
        self.kind = kind
        view.delegate = self
        view.delegate2 = self
        if oneTimeTimerAdd == true {
            timer = Timer.scheduledTimer(timeInterval: 8, target: self, selector: #selector(fadeInAndOut), userInfo: nil, repeats: true)
            oneTimeTimerAdd = false
        }
        view.imageView.image = currentPhoto
        view.overView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        if filterOut == false {
            view.collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 0)
            view.isFilterOut = false
            view.titles.removeAll()
        } else {
            view.isFilterOut = true
            view.overView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        }
        view.collectionView.register(collectionViewFilterCell.self, forCellWithReuseIdentifier: "cellFilterCV")
        view.filterButton.addTarget(self, action: #selector(toggleFilter), for: .touchUpInside)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize(width: view.frame.width, height: 1)
        }
        if filterOut == true {
            return CGSize(width: view.frame.width, height: view.frame.height / 1.9)
        }
        return CGSize(width: view.frame.width, height: view.frame.height / 2.3)
    }
    
    @objc func toggleFilter() {
        if self.filterOut == true {
            self.filterOut = false
        } else {
            filterOut = true
        }
        self.collectionView.reloadSections([0])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            let inset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        edgeInsetPadding = Int(inset.left+inset.right)
            return inset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(minimumSpacing)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(minimumSpacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 {
            return CGSize(width: view.frame.width, height: 1)
        }
            let width = (Int(UIScreen.main.bounds.size.width) - (numberOfItemsInRow - 1) * minimumSpacing - edgeInsetPadding) / numberOfItemsInRow
            return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.places.count != 0 {
            guard let long = places[indexPath.row].long, let lat = places[indexPath.row].lat else { return }
            let key = "\(long)-\(lat)"
            let place = getPlaceForCoord(cl: key)
            place.titler = places[indexPath.row].titler
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "selectedPlaceVC") as! UINavigationController
            let datavc = vc.viewControllers.first as! SelectedPlaceViewController
            datavc.place = place
            datavc.key = place.key
            datavc.configure(place: places[indexPath.row])
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func getPlaceForCoord(cl: String) -> Place {
        if let firstInd = places.firstIndex(where: { $0.longLatKey == cl }) {
            let place = places[firstInd]
            return place
        }
        return Place()
    }
    

    let activityOne = UIActivityIndicatorView()
    func fetchNearbyEvents() {
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
                self.loadEventsFromKeys(keys: keys)
            })
        } else {
            self.activityOne.stopAnimating()
        }
    }

    
    func loadEventsFromKeys(keys: [String]) {
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
            
        }
    }
    
    func filterEventsOut(events: [Event]) {
        var filters = self.activeFilters
        if activeFilters.count == 0 {
            filters = defaultFilters
        }
        for each in events {
            var containsFilter = false
            for one in each.filters {
                if filters.contains(where: { $0 == one }) {
                    if let savedTypes = UserDefaults.standard.value(forKey: one) as? [String], let subfilters = each.subfilters {
                        for loop in subfilters {
                            if savedTypes.contains(where: { $0 == loop }) {
                                containsFilter = true
                                break
                            }
                        }
                    } else {
                        break
                    }
                    if containsFilter == true {
                        break
                    }
                }
            }
            if containsFilter == true {
                self.events.append(each)
            }
        }
    }
    
    let activity2 = UIActivityIndicatorView()
    func fetchNearbyPlaces() {
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
                self.loadPinsFromKeys(keys: keys)
            })
        } else {
            self.activity2.stopAnimating()
        }
    }
    var addedKeys = [String]()
    func loadPinsFromKeys(keys: [String]) {
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
                                self.places.append(newObject)
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
            self.places = self.places.sorted(by: { $0.sortRank > $1.sortRank })
            self.allPlaces = self.places
            self.activity2.stopAnimating()
            print("reloaded\(self.places.count)")
        }
    }
    
    func filters(selected: [String]) {
        self.activeFilters = selected
        filterPlacesOut(places: self.places)
    }
    
    func filterPlacesOut(places: [Place]) {
        var localPlaceExt = [Place]()
        if activeFilters.count == 0 {
            self.places = allPlaces
            collectionView.reloadData()
        }
        for each in places {
            if each.filters?.count != 0 {
                for filter in activeFilters {
                    if each.filters?.contains(filter) ?? false {
                        guard !localPlaceExt.contains(where: { $0.key == each.key }) else {
                            break
                        }
                        localPlaceExt.append(each)
                    }
                }
            }
        }
        if localPlaceExt.count >= 1 {
            self.places = localPlaceExt
            self.collectionView.reloadSections([1])
        }
    }
    
    func noResultsOrLocation () {
        
    }
    
    func showCollegeView() {
        self.viewShowCollege.frame = CGRect(x: 15, y: view.frame.height - 290, width: view.frame.width - 30, height: 190)
        self.buttonCam.isHidden = true
        self.view.addSubview(viewShowCollege)
        self.viewShowCollege.clipsToBounds = true
        self.viewShowCollege.layer.cornerRadius = 12
        self.viewShowCollege.backgroundColor = .systemBackground
        let titleL = UILabel(frame: CGRect(x: 15, y: 5, width: viewShowCollege.frame.width - 30, height: 50))
        titleL.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        titleL.textAlignment = .center
        titleL.numberOfLines = 2
        titleL.text = "Join your College Localate"
        let buttonYes = UIButton()
        buttonYes.frame = CGRect(x: 15, y: 55, width: self.viewShowCollege.frame.width-30, height: 50)
        buttonYes.clipsToBounds = true
        buttonYes.setTitle("Yes", for: .normal)
        buttonYes.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        buttonYes.layer.cornerRadius = 6.0
        buttonYes.backgroundColor = .systemBlue
        let buttonNo = UIButton(frame: CGRect(x: 15, y: 115, width: viewShowCollege.frame.width - 30, height: 50))
        buttonNo.setTitle("No thanks", for: .normal)
        buttonNo.layer.cornerRadius = 6.0
        buttonNo.setTitleColor(.black, for: .normal)
        buttonNo.clipsToBounds = true
        buttonNo.backgroundColor = UIColor(red: 1, green: 0.9098, blue: 0.8275, alpha: 1.0)
        buttonNo.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        self.viewShowCollege.addSubview(titleL)
        self.viewShowCollege.addSubview(buttonYes)
        self.viewShowCollege.addSubview(buttonNo)
    }

}

extension UIView {
    func fadeOut(_ duration: TimeInterval? = 0.1, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0.3 },
                       completion: { (value: Bool) in
                          // self.isHidden = true
                           if let complete = completion { complete() }
        })
        }
    }
    func fadeIn(_ duration: TimeInterval? = 0.1, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = completion { complete() }
                        
        })
        }
    }
    func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: bounds.minX, y: bounds.midY, width: bounds.width, height: bounds.height / 2)
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.opacity = 1.0
        self.layer.insertSublayer(gradientLayer, at: 1)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


class collectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func layoutSubviews() {
        backView.layer.cornerRadius = 12
        backView.clipsToBounds = true
        
    }
    
}

class dummyHomeCell: UICollectionViewCell {
    
}

extension ViewController {
   
//        print("image picker selected \(images.count) photos")
//        imagePicker.dismiss(animated: true, completion: {
//            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "postPhotoVC") as! UINavigationController
//            let datavc = vc.viewControllers.first as! PostPhotoViewController
//            datavc.selectedImages = images
//            vc.modalPresentationStyle = .fullScreen
    
}






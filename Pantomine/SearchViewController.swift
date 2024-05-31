//
//  SearchViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 12/2/21.
//

import UIKit
import Firebase
import Kingfisher
import GeoFire

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var tablerView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var results = [Place]()
    var filteredResults = [Place]()
    var allStuff = [Place]()
    var delRes: [Place]?
    var resultsString = [String]()
    var isSearching = false
    let locationManager = CLLocationManager()
    var stringRes = [String]()
    var tags = [String]()
    var allPlacesInArea = [Place]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tablerView.delegate = self
        tablerView.dataSource = self
        searchBar.delegate = self
        if let delResus = delRes {
            self.filteredResults = delResus
            self.results = delResus
            tablerView.reloadData()
        }
        let database = Database.database().reference()
        database.child("allTags").observeSingleEvent(of: .value, with: { snapshot in
            if let vals = snapshot.value as? [String : String] {
                for (_,each) in vals {
                    self.tags.append(each)
                    print("added tag")
                }
            }
           
        })
        tablerView.keyboardDismissMode = .onDrag
        tablerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: view.frame.height - 20)
        //definesPresentationContext = true
        tablerView.allowsSelectionDuringEditing = true
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        checkLocationStuff()
       DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                 // self.allowCancel = true
              })
       
        // Do any additional setup after loading the view.
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if CLLocationManager.locationServicesEnabled() {
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
                    getAllPlacesInArea()
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
        }
    }
    var addedKeys = [String]()
    func getAllPlacesInArea() {
        let geofireRef = Database.database().reference().child("PinsLocs")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        var keys = [String]()
        if CLLocationManager.locationServicesEnabled() {
            //let center = CLLocation(latitude: 37.7832889, longitude: -122.4056973)
            // Query locations at [37.7832889, -122.4056973] with a radius of 600 meters
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
                    if let searchTags = value?["searchTags"] as? [String: String] {
                        newObject.searchFilters = searchTags.values.map({$0})
                    } else {
                        newObject.searchFilters = ["none"]
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
                        self.allPlacesInArea.append(newObject)
                        self.addedKeys.append(each1)
                        print(key)
                        print("ADDED MAP")
                    }
                }
                dispatch.leave()
            })
        }
        dispatch.notify(queue: DispatchQueue.main) {
        
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    locationManager.requestWhenInUseAuthorization()
                   
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Access")
                   
                @unknown default:
                break
            }
            } else {
                print("Location services are not enabled")
        }
      }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var stillOn = false
    override func viewWillAppear(_ animated: Bool) {
        if stillOn == false {
            print("still on")
            
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tablerView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! searchCell
        let image = UIImage(named: "defaultPin")
        if results.count > 0 {
            if let urli = results[indexPath.row].imageUrl {
                let url = URL(string: urli)
                cell1.placeImageView.kf.setImage(with: url, placeholder: image)
            } else {
                cell1.placeImageView.image = image
            }
        }
        cell1.titleLabel.text = results[indexPath.row].titler
        cell1.percentLabel.text = "\(Int(results[indexPath.row].ratio ?? 100))% Liked"
        if Int(results[indexPath.row].ratio ?? 100) < 50 {
            cell1.percentLabel.textColor = .red
        }
        cell1.milesAwayLabel.text = "\(results[indexPath.row].distanceAway!) miles away"
        return cell1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.width / 2
    }
    
//    func updateSearchResults(for searchController: UISearchController) {
//        print("reloadin")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            if (!self.tablerView.isDragging && !self.tablerView.isDecelerating) {
//            if searchController.searchBar.text == "" {
//                self.results = self.filteredResults
//                if self.refresher == true || self.viewJustLoad == false {
//                    self.tablerView.reloadData()
//                    self.viewJustLoad = true
//                } else {
//                    print("dont reload")
//                }
//
//            }
//            else {
//                guard !self.justTapped && searchController.searchBar.text != self.lastLoadedText else {
//                    return
//                }
//                self.viewJustLoad = true
//                let texter = searchController.searchBar.text!
//                if texter.count > 1 {
//                    if self.inSearch != true {
//                        self.lastLoadedText = texter
//                        self.pullPlacesByName(input: texter)
//                    }
//                    print("running")
//                }
//
//            }
//        }
//        }
//
//    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            isSearching = false
            results = filteredResults
            tablerView.reloadData()
        } else {
            isSearching = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.pullPlacesByName(input: searchText)
            }
        }
    }
    
    func pullPlacesByName(input: String) {
        guard allPlacesInArea.count != 0 else { return }
        results.removeAll()
        stringRes.removeAll()
        var dataInput = input
        if let index = self.tags.firstIndex(where: { $0 == input.lowercased() }) {
            dataInput = tags[index].lowercased()
            searchTagFound(string: dataInput)
            return
        }
        var maxAdd = 0
        for each in allPlacesInArea where each.titler.lowercased().contains(input.lowercased()) {
            if !stringRes.contains(each.key) && maxAdd < 10 {
                maxAdd+=1
                self.results.append(each)
            }
        }
        tablerView.reloadData()
    }
    
    func searchTagFound(string: String) {
        var maxAdd = 0
        for each in allPlacesInArea where each.searchFilters.contains(string) {
            if !stringRes.contains(each.key) && maxAdd < 10 {
                maxAdd+=1
                self.results.append(each)
            }
        }
        tablerView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let place = results[indexPath.row]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "selectedPlaceVC") as! UINavigationController
            let datavc = vc.viewControllers.first as! SelectedPlaceViewController
            datavc.place = place
            datavc.key = place.key
            datavc.configure(place: place)
            self.present(vc, animated: true, completion: {
               
            })
    }

}

class searchCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
   
    @IBOutlet weak var percentLabel: UILabel!
    
    @IBOutlet weak var placeImageView: UIImageView!
    
    @IBOutlet weak var milesAwayLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        placeImageView.frame = CGRect(x: 5, y: 5, width: contentView.frame.width / 2, height: contentView.frame.width / 2 - 10)
        titleLabel.frame = CGRect(x: contentView.frame.width / 2 + 10, y: 10, width: contentView.frame.width / 2 - 15, height: contentView.frame.width / 2 - 40)
        
        milesAwayLabel.frame = CGRect(x: contentView.frame.width / 2 + 10, y: contentView.frame.width / 2 - 35, width: contentView.frame.width / 2 - 15, height: 25)
        
        percentLabel.frame = CGRect(x: 10, y: contentView.frame.height - 35, width: 150, height: 30)
        
        
    }
}

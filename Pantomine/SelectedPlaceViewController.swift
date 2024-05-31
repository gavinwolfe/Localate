//
//  SelectedPlaceViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 6/30/21.
//

import UIKit
import MapKit
import Firebase
import Kingfisher
import GeoFire

class SelectedPlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photos = [PhotoPost]()
    @IBOutlet weak var tableView: UITableView!
    var object: Place?
    let buttonNewEvent = UIButton()
    var segmentIndex = 1
    var reviews = [reviewObject]()
    var likeDislike = 0
    let segmentItems = ["Reviews", "Info", "Photos"]
    var timer = Timer()
    var control = UISegmentedControl()
    var isAdmin = false
    var img = ""
    var titler = ""
    var place: Place?
    var key: String?
    var long: Double?
    var lat: Double?
    var desc = ""
    var oneTimeTimerAdd = true
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 20)
        if let placer = self.place {
            self.title = "\(placer.distanceAway ?? 0) miles away"
            self.img = placer.imageUrl ?? ""
            self.titler = placer.titler
            self.long = placer.long
            self.lat = placer.lat
            self.desc = placer.desc ?? ""
            tableView.reloadData()
        }
        
        if let key = self.key {
            DispatchQueue.main.async {
                self.fetchPhotos(key: key)
                self.fetchReviews(key: key)
            }
        }
        control = UISegmentedControl(items: segmentItems)
        tableView.estimatedRowHeight = 250.0
        tableView.rowHeight = UITableView.automaticDimension
        buttonNewEvent.frame = CGRect(x: self.view.frame.width - 85, y: self.view.frame.height - 180, width: 75, height: 75)
        buttonNewEvent.setImage(#imageLiteral(resourceName: "eventPost"), for: .normal)
        buttonNewEvent.setTitle("", for: .normal)
        buttonNewEvent.addTarget(self, action: #selector(self.createEvent), for: .touchUpInside)
        let value = UserDefaults.standard.string(forKey: "isAdmin")
        if value != "" && value != nil {
            isAdmin = true
        }
        view.addSubview(buttonNewEvent)
        // Do any additional setup after loading the view.
    }
    
    func configure(place: Place) {
        self.object = place
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if segmentIndex == 1 {
            return 2
        }
        if segmentIndex == 0 {
            return 2
        }
        if segmentIndex == 2 {
            if photos.count == 0 {
                return 2
            }
            return photos.count + 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentIndex == 0 && section == 1 {
            if reviews.count == 0 {
                return 1
            }
            return reviews.count
        } else if segmentIndex == 1 {
            return 1
        } else if segmentIndex == 2 {
            return 1
        }
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dummycell") as! dummyCell
            return cell
        }
        if indexPath.section == 1 && segmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFirstSelectedPin") as! tableViewSelectedPinCell
            cell.labelDesc.text = self.desc
            return cell
        }
        if indexPath.section == 1 && segmentIndex == 0 {
            guard reviews.count > 0 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptySpot") as! emptyCellSpot
                cell.config = 0
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell") as! tableViewReviewsCell
            cell.reviewLabel.text = reviews[indexPath.row].descrpt
            if let time = reviews[indexPath.row].timePosted {
                let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
                let timer = timeStamp - time
                
                if timer <= 59 {
                    cell.reviewTime.text = "\(timer)s ago"
                }
                
                if timer > 59 && timer < 3600 {
                    let minuters = timer / 60
                    cell.reviewTime.text = "\(minuters) mins ago"
                    if minuters == 1 {
                        cell.reviewTime.text = "\(minuters) min ago"
                    }
                }
                if timer > 59 && timer >= 3600 && timer < 86400 {
                    let hours = timer / 3600
                    if hours == 1 {
                        cell.reviewTime.text = "\(hours) hr ago"
                    } else {
                        cell.reviewTime.text = "\(hours) hrs ago"
                    }
                }
                if timer > 86400 {
                    let days = timer / 86400
                    cell.reviewTime.text = "\(days)days ago"
                    if days == 1 {
                        cell.reviewTime.text = "\(days)day ago"
                    }
                }
            }
            return cell
        }
        if indexPath.section >= 1 && segmentIndex == 2 {
            guard photos.count > 0 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptySpot") as! emptyCellSpot
                cell.config = 1
                return cell
            }
            let cellphotos = tableView.dequeueReusableCell(withIdentifier: "photoCell") as! photoTableViewCellPin
            if photos.count != 0 {
                let urli = photos[indexPath.section-1].urlImage
                if let url = URL(string: urli ?? "") {
                    let img = #imageLiteral(resourceName: "gallery")
                    cellphotos.imagerView.kf.setImage(with: url, placeholder: img, options: nil, progressBlock: nil, completionHandler: { completion in
                        
                    })
                }
            }
            return cellphotos
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "dummycell") as! dummyCell
        return cell
    }
    var defaultImage = UIImage()
    var imageViewSlide = UIImageView()
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHead = UIView()
        imageViewSlide = UIImageView()
        if section == 0 {
            if self.img == "" {
                imageViewSlide.image = UIImage(named: "defaultPin")
            } else if interval == 0 {
                if let url = URL(string: img) {
                    imageViewSlide.kf.setImage(with: url)
                    defaultImage = imageViewSlide.image ?? UIImage()
                }
            } else if interval != 0 {
                imageViewSlide.image = self.currentImg
            }
            if imageViewSlide.image == nil {
                imageViewSlide.image = defaultImage
            }
            imageViewSlide.addGradient()
            imageViewSlide.isUserInteractionEnabled = true
            imageViewSlide.clipsToBounds = true
            imageViewSlide.contentMode = .scaleAspectFill
            imageViewSlide.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width / 1.5)
            let height = view.frame.width / 1.5
            if oneTimeTimerAdd == true && photos.count != 0 {
                //DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.slideInOtherImages), userInfo: nil, repeats: true)
                    self.oneTimeTimerAdd = false
                //}
            }
            
            let backView = UIView()
            backView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height + 90)
            backView.backgroundColor = #colorLiteral(red: 0.2596039474, green: 0.2575624585, blue: 0.2611683309, alpha: 0.5748916937)
            
            let titleLabel = UILabel()
            let fontForTitleLabel = UIFont(name: "HelveticaNeue-Bold", size: 30) ?? UIFont()
            titleLabel.numberOfLines = 0
            var text = "Place"
            if titler == "" {
            } else {
                text = titler
            }
            titleLabel.layer.shadowColor = UIColor.black.cgColor
            titleLabel.layer.shadowRadius = 3.0
            titleLabel.layer.shadowOpacity = 1.0
            titleLabel.layer.shadowOffset = CGSize(width: 4, height: 4)
            titleLabel.layer.masksToBounds = false
            let labelTime = UILabel(frame: CGRect(x: view.frame.width - 115, y: height + 14, width: 100, height: 20))
            labelTime.textAlignment = .right
            if let object = object {
                if object.hasHours {
                    let openClose = self.getOpenClose(startHour: object.openHour, startMin: object.openMin, endHour: object.closeHour, endMin: object.closeMin, dayClosed: object.closedDays ?? [Int]())
                    if openClose {
                        labelTime.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
                        labelTime.text = "Open"
                    } else {
                        labelTime.textColor = #colorLiteral(red: 0.8160782456, green: 0.1199558601, blue: 0, alpha: 1)
                        labelTime.text = "Closed"
                    }
                } else {
                    labelTime.text = "Hours: N/A"
                    labelTime.textColor = .lightGray
                }
            }
            labelTime.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            let hoursLabel = UILabel(frame: CGRect(x: view.frame.width - 265, y: height + 38, width: 250, height: 20))
            hoursLabel.textColor = .lightGray
            hoursLabel.textAlignment = .right
            hoursLabel.text = "----"
            if let object = object, object.hasHours {
                hoursLabel.text = getTimeString(startHour: object.openHour, startMin: object.openMin, endHour: object.closeHour, endMin: object.closeMin, dayClosed: object.closedDays ?? [Int]())
            }
            hoursLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            let tagLabel = UILabel(frame: CGRect(x: 15, y: height + 38, width: 200, height: 20))
            tagLabel.textColor = .lightGray
            if let tag = self.place?.filters {
                if tag.count == 1 {
                    tagLabel.text = "Tags: \(tag[0])"
                }
                if tag.count == 2 {
                    tagLabel.text = "Tags: \(tag[0]), \(tag[1])"
                }
                if tag.count == 3 {
                    tagLabel.text = "Tags: \(tag[0]), \(tag[1]), \(tag[2])"
                }
                if tag.count == 4 {
                    tagLabel.text = "Tags: \(tag[0]), \(tag[1]), \(tag[2]), \(tag[3])"
                }
                if tag.count == 5 {
                    tagLabel.text = "Tags: \(tag[0]), \(tag[1]), \(tag[2]), \(tag[3]), \(tag[4])"
                }
            } else {
                tagLabel.text = "No Tags"
            }
            tagLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            let labelHeight = heightForView(text: text, font: fontForTitleLabel, width: view.frame.width - 55)
            titleLabel.frame = CGRect(x: 10, y: height - (labelHeight + 10), width: view.frame.width - 55, height: labelHeight)
            print(labelHeight)
            titleLabel.textColor = .white
            titleLabel.font = fontForTitleLabel
            titleLabel.text = text
            let buttonOpenInmaps = UIButton(frame: CGRect(x: view.frame.width - 50, y: height - 50, width: 40, height: 40))
            //buttonOpenInmaps.backgroundColor = UIColor(red: 1, green: 0.2471, blue: 0, alpha: 1.0)
            buttonOpenInmaps.setImage(UIImage(named: "imageSet"), for: .normal)
            buttonOpenInmaps.layer.shadowColor = UIColor.black.cgColor
            buttonOpenInmaps.layer.shadowRadius = 3.0
            buttonOpenInmaps.layer.shadowOpacity = 1.0
            buttonOpenInmaps.layer.shadowOffset = CGSize(width: 4, height: 4)
            buttonOpenInmaps.setTitle("", for: .normal)
            buttonOpenInmaps.imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
            buttonOpenInmaps.layer.cornerRadius = 17.5
            buttonOpenInmaps.addTarget(self, action: #selector(self.openInMaps), for: .touchUpInside)
            let labelThingsHere = UILabel(frame: CGRect(x: 15, y: height + 14, width: 90, height: 20))
            labelThingsHere.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            if let placeratio = self.place?.ratio {
                labelThingsHere.text = "\(Int(placeratio))% liked"
                if placeratio < 50 {
                    labelThingsHere.textColor = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
                }
            } else {
                labelThingsHere.text = "100% liked"
            }
            
            labelThingsHere.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
            viewHead.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: (view.frame.width / 1.5) + 185)
            control.backgroundColor = .systemBackground
            control.frame = CGRect(x: (view.frame.width / 2) - 130, y: (view.frame.width / 1.5) + 130, width: 260, height: 45)
            control.addTarget(self, action: #selector(segmentControl), for: .valueChanged)
            control.selectedSegmentIndex = segmentIndex
            control.setImage(UIImage(named: "review"), forSegmentAt: 0)
            control.setImage(UIImage(named: "info"), forSegmentAt: 1)
            control.setImage(UIImage(named: "photos"), forSegmentAt: 2)
            viewHead.addSubview(control)
            let directionsButton = UIButton()
            directionsButton.frame = CGRect(x: (view.frame.width / 2) - 100, y: height + 70, width: 200, height: 40)
            directionsButton.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            //directionsButton.clipsToBounds = true
            directionsButton.imageView?.contentMode = .scaleAspectFill
            directionsButton.setTitleColor(.white, for: .normal)
            directionsButton.layer.cornerRadius = 18.0
            directionsButton.setTitle("DIRECTIONS", for: .normal)
            directionsButton.addTarget(self, action: #selector(self.openInMaps), for: .touchUpInside)
            directionsButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
            viewHead.addSubview(backView)
            viewHead.addSubview(labelTime)
            viewHead.addSubview(hoursLabel)
            viewHead.addSubview(tagLabel)
            //viewHead.addSubview(labelPhotosHere)
            viewHead.addSubview(imageViewSlide)
            viewHead.addSubview(labelThingsHere)
            viewHead.addSubview(directionsButton)
            viewHead.addSubview(titleLabel)
            //viewHead.addSubview(buttonOpenInmaps)
        }
        if section == 1 && segmentIndex == 0 {
            
        }
        if section == 1 && segmentIndex == 2 {
            let labelPhotosHere = UILabel(frame: CGRect(x: 10, y: 10, width: view.frame.width - 20, height: 20))
            labelPhotosHere.textAlignment = .center
            labelPhotosHere.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
            labelPhotosHere.text = "Photos Posted Here"
            labelPhotosHere.textColor = UIColor(red: 0, green: 0.8667, blue: 1, alpha: 1.0)
            viewHead.addSubview(labelPhotosHere)
            viewHead.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 40)
        }
        return viewHead
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return ((self.view.frame.width / 1.5) + 195)
        }
        if section == 1 && segmentIndex == 2 {
            return 45
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFoot = UIView()
        let labelTime = UILabel()
        let viewLabel = UILabel()
        if section >= 1 && segmentIndex == 2 && photos.count > 0 {
            viewFoot.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40)
            labelTime.font = UIFont(name: "HelveticaNeue-Medium", size: 17)
            viewLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
            labelTime.textColor = .white
            viewLabel.textColor = .white
            viewLabel.text = "\(photos[section-1].views ?? 0) views"
            if let time = photos[section-1].timePosted {
                let timeStamp: Int = Int(NSDate().timeIntervalSince1970)
                let timer = timeStamp - time
                
                if timer <= 59 {
                    labelTime.text = "\(timer)s ago"
                }
                
                if timer > 59 && timer < 3600 {
                    let minuters = timer / 60
                    labelTime.text = "\(minuters) mins ago"
                    if minuters == 1 {
                        labelTime.text = "\(minuters) min ago"
                    }
                }
                if timer > 59 && timer >= 3600 && timer < 86400 {
                    let hours = timer / 3600
                    if hours == 1 {
                        labelTime.text = "\(hours) hr ago"
                    } else {
                        labelTime.text = "\(hours) hrs ago"
                    }
                }
                if timer > 86400 {
                    let days = timer / 86400
                    labelTime.text = "\(days)days ago"
                    if days == 1 {
                        labelTime.text = "\(days)day ago"
                    }
                }
            }
            labelTime.frame = CGRect(x: 10, y: 10, width: 150, height: 20)
            viewLabel.frame = CGRect(x: viewFoot.frame.width - 150, y: 10, width: 130, height: 20)
            viewLabel.textAlignment = .right
            viewFoot.backgroundColor = #colorLiteral(red: 0.2938472331, green: 0.2939023972, blue: 0.2938399315, alpha: 0.3592099472)
            viewFoot.addSubview(labelTime)
            viewFoot.addSubview(viewLabel)
        }
        return viewFoot
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section >= 1 && segmentIndex == 2 {
            return 40
        }
        return 0.0001
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 0
        }
        if indexPath.section == 1 && segmentIndex == 1 {
            if let font = UIFont(name: "HelveticaNeue-Medium", size: 17) {
                let height = heightForView(text: self.desc, font: font, width: view.frame.width - 60)
                return height
            }
            //return UITableView.automaticDimension
        }
        if indexPath.section == 1 && segmentIndex == 0 {
            return UITableView.automaticDimension
        }
        return view.frame.width
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section >= 3 {
            if self.isAdmin == true {
                let pageAlert = UIAlertController(title: "Admin", message: "", preferredStyle: UIAlertController.Style.actionSheet)
                let camera = UIAlertAction(title: "Code303", style: .default, handler: { (action : UIAlertAction!) -> Void in
                    if let uid = self.photos[indexPath.section-2].postById {
                        if let key = self.photos[indexPath.section-2].key {
                            if let keyPlace = self.photos[indexPath.section-2].keyPlace {
                                let ref = Database.database().reference()
                                ref.child("PhotosLocs").child(key).removeValue()
                                ref.child("Photos").child(key).removeValue()
                                ref.child("Pins").child(keyPlace).child("photos").child(key).removeValue()
                                let update = [uid : "goodbye"]
                                ref.child("banned").updateChildValues(update)
                                return
                            }
                        }
                    }
                    
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                pageAlert.addAction(camera)
                pageAlert.addAction(cancel)
                self.present(pageAlert, animated: true, completion: nil)
            }
        }
    }
    var interval = 0
    var currentImg = UIImage()
    @objc func slideInOtherImages() {
        guard interval != photos.count else {
            imageViewSlide.image = self.defaultImage
            interval = 0
            currentImg = imageViewSlide.image ?? UIImage()
            return
        }
        if photos.count != 0 {
            if let url = URL(string: photos[interval].urlImage) {
                imageViewSlide.kf.setImage(with: url)
                interval+=1
                currentImg = imageViewSlide.image ?? UIImage()
            }
        }
    }
    
    @IBAction func openMore(_ sender: Any) {
        let alert = UIAlertController(title: "Select an option", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Save", style: .default, handler: nil)
        let action2 = UIAlertAction(title: "Add Search Tags", style: .default, handler: { (action : UIAlertAction!) -> Void in
            let alertController = UIAlertController(title: "Add Tags", message: "Please add one tag at a time, clicking done after you type one into the text field. These tags make it easier to find this place in the search area.", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter a search tag..."
                textField.autocorrectionType = .default
                textField.keyboardType = .twitter
                textField.keyboardAppearance = .dark
                textField.autocapitalizationType = .sentences
                textField.tintColor = .blue
            }
           
            let attributedString = NSAttributedString(string: "Add Tags", attributes: [
                NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 18)!, //your font here
                NSAttributedString.Key.foregroundColor : UIColor.blue
                ])
            alertController.setValue(attributedString, forKey: "attributedTitle")
            
            
            
            let saveAction = UIAlertAction(title: "Done", style: UIAlertAction.Style.default, handler: { alert -> Void in
                if let text = alertController.textFields?[0].text {
                    let string1 = text.lowercased()
                    if  string1.contains("penis") || string1.contains("vagina")  || string1.contains(" fag") || string1.contains("anal")  || string1.contains("cunt") ||  string1.contains("porn") || string1.contains("nigger") || string1.contains("beaner") || string1.contains(" coon ") || string1.contains("spic") || string1.contains("wetback") || string1.contains("chink") || string1.contains("gook") ||  string1.contains("twat") || string1.contains(" darkie ") || string1.contains("god hates") || string1.contains("    ") ||  string1.contains("nigga") || string1.contains("kike") {
                        return
                    }
                    if text.count < 32 && text.count > 2 {
                        let database = Database.database().reference()
                        database.child("Pins").child(self.place?.key ?? "").child("searchTags").updateChildValues([text.lowercased() : text.lowercased()])
                        database.child("allTags").updateChildValues([text.lowercased() : text.lowercased()])
                        print("added")
                    }
                }
            })
            
            let cancel4 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            saveAction.setValue(UIColor.blue, forKey: "titleTextColor")
            alertController.addAction(saveAction)
            alertController.addAction(cancel4)
            self.present(alertController, animated: true, completion: nil)
        })
        let action3 = UIAlertAction(title: "Report", style: .default, handler: nil)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func postTag() {
        
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    @objc func segmentControl(sender: UISegmentedControl) {
        if segmentIndex == 2 && sender.selectedSegmentIndex == 0 {
            segmentIndex = sender.selectedSegmentIndex
            tableView.reloadData()
            return
        }
        segmentIndex = sender.selectedSegmentIndex
        if segmentIndex == 0 {
            tableView.reloadSections([1], with: .automatic)
        } else {
            tableView.reloadData()
        }
    }
    
    @IBAction func doneAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func openInMaps() {
        if let long = self.long {
            if let lat = self.lat {
                let coordinate = CLLocationCoordinate2DMake(lat,long)
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
                mapItem.name = "Target location"
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            }
        }
    }
    
    let textviewA = UITextView()
    let exitButtonComment = UIButton()
    let divideViewComment = UIView()
    func setUpComment () {
        
        textviewA.font = UIFont(name: "HelveticaNeue-Medium", size: 18)
        
        textviewA.frame = CGRect(x: 0, y: 51, width: self.view.frame.width, height: 100)
        divideViewComment.frame = CGRect(x: 0, y: 0, width: commentingView.frame.width , height: 50)
        divideViewComment.backgroundColor = UIColor(red: 0.8863, green: 0.8706, blue: 0.898, alpha: 1.0)
        commentingView.layer.shadowColor = UIColor.gray.cgColor
        commentingView.layer.shadowOpacity = 1
        commentingView.layer.shadowOffset = CGSize.zero
        commentingView.layer.shadowRadius = 2
        commentingView.layer.cornerRadius = 8.0
        divideViewComment.roundCorners([.topLeft, .topRight], radius: 8.0)
        commentingView.addSubview(divideViewComment)
        commentingView.backgroundColor = .white
        exitButtonComment.frame = CGRect(x: 10, y: 5, width: 40, height: 40)
        exitButtonComment.setTitle("Exit", for: .normal)
        exitButtonComment.addTarget(self, action: #selector(self.closeComment), for: .touchUpInside)
        exitButtonComment.setTitleColor(.gray, for: .normal)
        let postButton = UIButton()
        postButton.frame = CGRect(x: self.commentingView.frame.width - 95, y: 8, width: 80, height: 34)
        postButton.backgroundColor = UIColor(red: 0, green: 0.5608, blue: 0.9373, alpha: 1.0)
        postButton.setTitleColor(.white, for: .normal)
        postButton.setTitle("Post", for: .normal)
        postButton.layer.cornerRadius = 10.0
        postButton.clipsToBounds = true
        postButton.addTarget(self, action: #selector(self.initialPost), for: .touchUpInside)
        self.commentingView.addSubview(postButton)
        self.commentingView.addSubview(exitButtonComment)
        self.commentingView.addSubview(textviewA)
    }
    var commentOpen = false
    let commentingView = UIView()
    @objc func openComment () {
        if Auth.auth().currentUser?.uid != nil {
            commentingView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
            self.view.addSubview(commentingView)
            setUpComment()
            commentOpen = true
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseIn, animations: {
                self.commentingView.frame = CGRect(x: 0, y: self.view.frame.height / 3.4, width: self.view.frame.width, height: self.view.frame.height - self.view.frame.height / 3.4)
                self.textviewA.becomeFirstResponder()
            }, completion: nil)
        } else {
            let alertMore = UIAlertController(title: "Error!", message: "Sorry you cannot comment unless you create or sign into an account.", preferredStyle: .alert)
            let cancel2 = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
            
            alertMore.addAction(cancel2)
            self.present(alertMore, animated: true, completion: nil)
        }
    }
    
    @objc func initialPost() {
        let pageAlert = UIAlertController(title: "DID YOU LIKE OR DISLIKE THIS SPOT?", message: "", preferredStyle: UIAlertController.Style.alert)
        let like = UIAlertAction(title: "Like", style: .default, handler: { (action : UIAlertAction!) -> Void in
            self.likeDislike = 0
            self.postComment()
            return
        })
        let dislike = UIAlertAction(title: "Dislike", style: .default, handler: { (action : UIAlertAction!) -> Void in
            self.likeDislike = 1
            self.postComment()
            return
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action :
            UIAlertAction!) -> Void in
            return
        })
        pageAlert.addAction(like)
        pageAlert.addAction(dislike)
        pageAlert.addAction(cancel)
        self.present(pageAlert, animated: true, completion: nil)
    }
    
    var oncep = false
    @objc func postComment() {
        if let message = self.textviewA.text {
            if message.count > 2 {
                let string1 = message.lowercased()
                if  string1.contains("penis") || string1.contains("vagina")  || string1.contains(" fag") || string1.contains("anal")  || string1.contains("cunt") ||  string1.contains("porn") || string1.contains("nigger") || string1.contains("beaner") || string1.contains(" coon ") || string1.contains("spic") || string1.contains("wetback") || string1.contains("chink") || string1.contains("gook") ||  string1.contains("twat") || string1.contains(" darkie ") || string1.contains("god hates") || string1.contains("    ") ||  string1.contains("nigga") || string1.contains("kike")
                
                {
                    let alertMore = UIAlertController(title: "Error!", message: "This has a word or character that violates our reviews policy. Please remove any vulgar words or characters, then post the comment (:", preferredStyle: .alert)
                    let cancel2 = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
                    
                    alertMore.addAction(cancel2)
                    self.present(alertMore, animated: true, completion: nil)
                    return
                } else {
                    let time = Int(NSDate().timeIntervalSince1970)
                    if self.oncep == false {
                        self.oncep = true
                        if let aid = self.place?.key {
                            if let uid = Auth.auth().currentUser?.uid {
                                    let ref = Database.database().reference()
                                    
                                    let key = Auth.auth().currentUser?.uid
                                    let feedLi = ["message" : message, "sender" : uid, "timeStamp" : time, "key" : key!, "likeDislike" : likeDislike] as [String : Any]
                                    let mySetup = [key : feedLi]
                                    
                                    ref.child("Pins").child(aid).child("reviews").updateChildValues(mySetup)
                                    self.oncep = false
                                    let review = reviewObject()
                                review.creator = uid
                                review.key = key
                                review.descrpt = message
                                review.timePosted = time
                                review.likeDislike = likeDislike
                                if let firstInd = self.reviews.firstIndex(where: { $0.key == key }){
                                    self.reviews[firstInd] = review
                                } else {
                                    self.reviews.append(review)
                                }
                                    self.textviewA.text = ""
                                    self.closeComment()
                                self.updateRating(key: aid)
                                    // sendNotification()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateRating(key: String) {
        var neg = 0
        var pos = 0
        for each in reviews {
            if each.likeDislike == 0 {
                pos+=1
            } else {
                neg+=1
            }
        }
        var percent = 0
        
        if neg == 0 && pos >= 1 {
            percent = 100
        }
        if pos == 0 && neg >= 1 {
            percent = 0
        }
        if percent != 0  && pos != 0 && neg != 0 {
            if (pos / neg) <= 1 {
                percent = (pos / neg) * 100
            } else if (pos / neg) > 1 && (pos / neg) < 10 {
                percent = (pos / neg) * 10
            } else if (pos / neg) >= 10 {
                percent = (pos / neg) * 5
            }
        }
        let ref = Database.database().reference()
        let mySetup = ["ratio" : percent]
        ref.child("Pins").child(key).updateChildValues(mySetup)
        return 
    }
    
    @objc func closeComment () {
        textviewA.resignFirstResponder()
        commentOpen = false
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut, animations: {
            self.commentingView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 0)
        }, completion: { finished in
            self.commentingView.removeFromSuperview()
            self.exitButtonComment.removeFromSuperview()
            self.divideViewComment.removeFromSuperview()
            self.textviewA.removeFromSuperview()
        })
        
    }
    
    func fetchPhotos(key: String) {
        let ref = Database.database().reference().child("Pins")
        ref.child(key).child("photos").queryOrderedByKey().observeSingleEvent(of: .value, with: {(snap) in
            if let values = snap.value as? [String : AnyObject] {
                for (_,each) in values {
                    if let imgUrl = each["urlPhoto"] as? String, let views = each["views"] as? Int, let timePosted = each["time"] as? Int, let key = each["key"] as? String, let postedBy = each["postedByUid"] as? String, let keyPlace = each["keyPlace"] as? String {
                        let photoObj = PhotoPost()
                        photoObj.urlImage = imgUrl
                        photoObj.views = views
                        photoObj.key = key
                        photoObj.keyPlace = keyPlace
                        photoObj.timePosted = timePosted
                        photoObj.postById = postedBy
                        if !self.photos.contains(where: { $0.key == key}) {
                            self.photos.append(photoObj)
                        }
                    }
                }
            }
            print("called2")
            self.tableView.reloadData()
        })
    }
    
    func fetchReviews(key: String) {
        let ref = Database.database().reference().child("Pins")
        ref.child(key).child("reviews").queryOrderedByKey().observeSingleEvent(of: .value, with: {(snap) in
            if let values = snap.value as? [String : AnyObject] {
                for (_,each) in values {
                    if let message = each["message"] as? String, let timePosted = each["timeStamp"] as? Int, let key = each["key"] as? String, let postedBy = each["sender"] as? String, let likeDislike = each["likeDislike"] as? Int {
                       let review = reviewObject()
                        review.descrpt = message
                        review.timePosted = timePosted
                        review.key = key
                        review.creator = postedBy
                        review.likeDislike = likeDislike
                        if !self.reviews.contains(where: { $0.key == key}) {
                            self.reviews.append(review)
                        }
                    }
                }
            }
            print("called3")
            self.tableView.reloadData()
        })
    }
    
    @objc func createEvent() {
        let pageAlert = UIAlertController(title: "Add Review or Photo to this place.", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let review = UIAlertAction(title: "Review", style: .default, handler: { (action : UIAlertAction!) -> Void in
            self.openComment()
            return
        })
        let photo = UIAlertAction(title: "Photo", style: .default, handler: { (action : UIAlertAction!) -> Void in
            self.postImage()
            return
        })
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        pageAlert.addAction(review)
        pageAlert.addAction(photo)
        pageAlert.addAction(cancel)
        self.present(pageAlert, animated: true, completion: nil)
    }
    
    @objc func postImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let pageAlert = UIAlertController(title: "Add Photo", message: "", preferredStyle: UIAlertController.Style.actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default, handler: { (action : UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.present(imagePicker, animated: true, completion: nil)
            
        })
        let photoLib = UIAlertAction(title: "Library", style: .default, handler: { (action : UIAlertAction!) -> Void in
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
            
        })
        pageAlert.addAction(photoLib)
        pageAlert.addAction(camera)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        pageAlert.addAction(cancel)
        self.present(pageAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Error: \(info)")
            return
        }
        
        picker.dismiss(animated: true, completion: {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "uploadVC") as! uploadVC
            vc.img = selectedImage
            vc.lat = self.place?.lat
            vc.long = self.place?.long
            vc.placeID = self.place?.key
            self.present(vc, animated: true, completion: nil)
        })
        
        
    }
    
    func getTimeString(startHour: Int, startMin: Int, endHour: Int, endMin: Int, dayClosed: [Int]) -> String {
        if let day = Date().dayNumberOfWeek() {
            if dayClosed.contains(day) {
                return "----"
            }
            var startMinString = ""
            if startMin == 0 {
                startMinString = "00"
            } else {
                startMinString = "\(startMin)"
            }
            var endMinString = ""
            if endMin == 0 {
                endMinString = "00"
            } else {
                endMinString = "\(endMin)"
            }
            var hourStartString = startHour
            var endHourString = endHour
            var startHourZone = "am"
            var endHourZone = "am"
            if hourStartString > 12 {
                hourStartString-=12
                startHourZone = "pm"
            }
            if endHourString > 12 {
                endHourString-=12
                endHourZone = "pm"
            }
            if startHour == 0 {
                hourStartString = 12
            }
            return "\(hourStartString):\(startMinString) \(startHourZone) - \(endHourString):\(endMinString) \(endHourZone)"
        }
        return ""
    }
    
    func getOpenClose(startHour: Int, startMin: Int, endHour: Int, endMin: Int, dayClosed: [Int]) -> Bool {
        if let day = Date().dayNumberOfWeek() {
            if dayClosed.contains(day) {
                return false
            }
            let hour = Calendar.current.component(.hour, from: Date())
            if hour >= startHour && hour <= endHour {
                return true
            }
        }
        return false
    }
    
}

class tableViewSelectedPinCell: UITableViewCell {
    
    @IBOutlet weak var labelDesc: UILabel!
    
}

class dummyCell: UITableViewCell {
    
}

class photoTableViewCellPin: UITableViewCell {
    
    @IBOutlet weak var imagerView: UIImageView!
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //aspectConstraint = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    
}

class tableViewReviewsCell: UITableViewCell {
    
    @IBOutlet weak var reviewTime: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func layoutSubviews() {
        super.layoutSubviews()
        backView.layer.cornerRadius = 12.0 
    }
}

class emptyCellSpot: UITableViewCell {
    let label = UILabel()
    var config = 0
    override func layoutSubviews() {
        label.frame = CGRect(x: 15, y: 10, width: contentView.frame.width - 30, height: 30)
        label.textAlignment = .center
        label.font = UIFont(name: "Helvetica", size: 18)
        if config == 0 {
            label.text = "No Reviews Yet"
        } else {
            label.text = "No Photos Yet"
        }
        contentView.addSubview(label)
    }
}



class tableViewInfoCell: UITableViewCell {
    @IBOutlet weak var imageView1: UIImageView!
    
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var imageView4: UIImageView!
    override func layoutSubviews() {
        
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

extension UIView {
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

class uploadVC: UIViewController {
    
    var placeID: String?
    var img: UIImage?
    var long: Double?
    var lat: Double?
    override func viewDidLoad() {
        if let img = self.img {
            self.imageView.image = img
        }
    }
    
    public func didset(key: String, img: UIImage, long: Double, lat: Double) {
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var uploadButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func uploadAction(_ sender: Any) {
        if let placeID = placeID, let img = self.img, let lat = self.lat, let long = self.long {
                let key = random(digits: 20)
                let activity = UIActivityIndicatorView()
                activity.frame = view.frame
                activity.color = .black
                activity.backgroundColor = .white
                activity.startAnimating()
                view.addSubview(activity)
                if CLLocationManager.locationServicesEnabled() {
                    if let uid = Auth.auth().currentUser?.uid {
                    let storage = Storage.storage().reference().child("photos").child(key)
                    if let uploadData = img.jpegData(compressionQuality: 0.50) {
                        storage.putData(uploadData, metadata: nil, completion:
                            { (metadata, error) in
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
                                        let result = ["urlPhoto" : urlLoad, "time" : timeStamp, "key" : key, "long" : long, "lat" : lat, "postedByUid" : uid, "views" : 1, "keyPlace" : placeID] as [String : Any]
                                    let update = [key : result]
                                        Database.database().reference().child("Pins").child(placeID).child("photos").updateChildValues(update)
                                        Database.database().reference().child("Photos").updateChildValues(update)
                                        activity.stopAnimating()
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                })
                            }
                        }
                    }
            }
    }
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    
    
}

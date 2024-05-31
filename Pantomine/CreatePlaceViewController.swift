//
//  CreatePlaceViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 6/2/21.
//

import UIKit
import GeoFire
import Firebase

class CreatePlaceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, changedTitle, changedDesc, UITextViewDelegate, UITextFieldDelegate, changedStartTime, changedEndTime, changedDays, changedDaysEvents, changedDateEvent {
   
    
    
    func startDate(date: Date) {
        self.startDate = date
    }
    
    func endDate(date: Date) {
        self.endDate = date
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var selectedImg: UIImage?
    var titleString: String?
    var descript: String?
    var location: MKPointAnnotation?
    var openTimeHour: Int?
    var openTimeMinutes: Int?
    var closedTimeHour: Int?
    var closedTimeMinutes: Int?
    var closedDays: [String]?
    var openText = true
    var oneCall = true
    var titles = ["Outdoor", "Shopping", "Food/Drink", "Scenic", "Experiences", "Nightlife", "Event"]
    var selected = [String]()
    var eventRepeat: Int?
    var closedInts = [Int]()
    var selectedAddHours = false
    var creatingEvent = false
    var startDate: Date?
    var endDate: Date?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section <= 2 {
            return 1
        }
        if section > 3 {
            return 1
        }
        return 7
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createCell1", for: indexPath) as! tableViewCreate1
            cell.delegate = self
            if openText {
                cell.inputTitle.becomeFirstResponder()
                openText = false
            }
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createCell2", for: indexPath) as! tableViewCreate2
            cell.delegate = self
            return cell
        }
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "createCell3", for: indexPath) as! tableViewCreate3
            if let img = self.selectedImg {
                cell.imagerView.image = img
            }
            return cell
        }
        if indexPath.section == 4 && selectedAddHours == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "hoursCell", for: indexPath) as! tableViewCreate5
            if self.creatingEvent == true {
                cell.hoursLabel.text = "Select Date"
                cell.hoursLabel.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            }
            return cell
        }
        if indexPath.section > 4 && selectedAddHours == false {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCellCreate", for: indexPath) as! tableViewCreate9
            return cell
        }
        if indexPath.section == 4 && selectedAddHours == true {
            if self.creatingEvent == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "selectDateEvent", for: indexPath) as! tableViewCell11
                cell.delegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "hourPickerCell1", for: indexPath) as! tableViewCreate6
            cell.delegate = self
            return cell
        }
        if indexPath.section == 5 && selectedAddHours == true {
            if self.creatingEvent == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "eventDaysPicker", for: indexPath) as! tableViewCreate10
                cell.delegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "hourPickerCell2", for: indexPath) as! tableViewCreate7
            cell.delegate = self
            return cell
        }
        if indexPath.section == 6 && selectedAddHours == true {
            if self.creatingEvent == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "emptyCellCreate", for: indexPath) as! tableViewCreate9
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "hourPickerCell3", for: indexPath) as! tableViewCreate8
            cell.delegate = self
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "createCell4", for: indexPath) as! tableViewCreate4
        cell.labelTitle.text = titles[indexPath.row]
        if let selected = selected.firstIndex(where: { $0 == titles[indexPath.row]}) {
            cell.selectView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            if indexPath.row == 6 {
                cell.selectView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
        } else {
            cell.selectView.backgroundColor = .clear
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
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
        } else if indexPath.section == 3 {
//            if creatingEvent == true {
//                if indexPath.row == 6 {
//                    selected = selected.filter({ $0 != titles[indexPath.row]})
//                    tableView.reloadSections([3], with: .automatic)
//                    creatingEvent = false
//                }
//                return
//            }
          
            if let contains = selected.firstIndex(where: { $0 == titles[indexPath.row] }) {
                selected = selected.filter({ $0 != titles[indexPath.row]})
                tableView.reloadSections([3], with: .automatic)
            } else {
                selected.append(titles[indexPath.row])
                tableView.reloadSections([3], with: .automatic)
            }
            if indexPath.row == 6 {
                creatingEvent = !creatingEvent
                if creatingEvent == true {
                    tableView.reloadSections([4,5,6], with: .automatic)
                } else {
                    tableView.reloadSections([4,5,6], with: .automatic)
                }
            }
        } else if indexPath.section == 4 && selectedAddHours == false {
            selectedAddHours = true
            tableView.reloadSections([4,5,6], with: .automatic)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Error: \(info)")
            return
        }
        picker.dismiss(animated: true, completion: {
            self.selectedImg = selectedImage
            self.tableView.reloadSections([0], with: .automatic)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            return 40
        }
        if indexPath.section == 2 {
            return 100
        }
        if indexPath.section == 0 {
            return view.frame.width - 120
        }
        if indexPath.section == 3 {
            return 30
        }
        if indexPath.section == 4 && selectedAddHours == false {
           return 80
        }
        if indexPath.section == 4 && selectedAddHours == true {
            if self.creatingEvent == true {
                return 320
            }
            return 150
        }
        if indexPath.section > 4 && selectedAddHours == false {
            return 40
        }
        if indexPath.section == 5 && selectedAddHours == true {
            return 150
        }
        if indexPath.section == 6 && selectedAddHours == true {
            if self.creatingEvent == true {
               return 150
            }
            return 220
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 40
        }
        if section > 3 && selectedAddHours == true {
            return 40
        }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        view.backgroundColor = .systemBackground
        let labelHeaderTitle = UILabel(frame: CGRect(x: 10, y: 5, width: 250, height: 30))
        labelHeaderTitle.font = UIFont(name: "Helvetica-Bold", size: 18)
        labelHeaderTitle.text = "Select Filters:"
        if section == 4 && selectedAddHours == true {
            labelHeaderTitle.text = "Select Opening Time:"
            if creatingEvent == true {
                labelHeaderTitle.text = "Select Start And End Dates"
            }
        }
        if section == 5 && selectedAddHours == true {
            labelHeaderTitle.text = "Select Closing Time:"
            if creatingEvent == true {
                labelHeaderTitle.text = "Select How Often"
            }
        }
        if section == 6 && selectedAddHours == true {
            labelHeaderTitle.text = "Select Days Closed:"
            if creatingEvent == true {
                labelHeaderTitle.text = ""
            }
        }
        view.addSubview(labelHeaderTitle)
        return view
    }
    
    @IBAction func doneAct(_ sender: Any) {
        guard self.selectedImg != nil, let title = self.titleString, self.descript != nil, let coord = self.location, selected.count != 0, oneCall == true else {
            if self.descript == nil {
                showAlert2(string: "Description")
            }
            if title == nil {
                showAlert2(string: "Title")
            }
            if self.selectedImg == nil {
                showAlert2(string: "Photo")
            }
            if selected.count == 0 {
                showAlert2(string: "Filter")
            }
            return
        }
        if creatingEvent == true {
            showAlert3()
            return
        }
        if selectedAddHours == true {
            if openTimeHour == nil && closedTimeHour == nil {
                showAlert1()
                return
            }
            if openTimeHour == nil {
                self.openTimeHour = Calendar.current.component(.hour, from: Date())
            }
            if openTimeMinutes == nil {
                let nonRounded = Calendar.current.component(.minute, from: Date())
                self.openTimeMinutes = roundToTens(x: Double(nonRounded))
            }
            if closedTimeHour == nil {
                self.closedTimeHour = Calendar.current.component(.hour, from: Date())
            }
            if closedTimeMinutes == nil {
                let nonRounded = Calendar.current.component(.minute, from: Date())
                self.closedTimeMinutes = roundToTens(x: Double(nonRounded))
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.createPlace(long: coord.coordinate.longitude, lat: coord.coordinate.latitude, title: title)
        }
    }
    
    func roundToTens(x : Double) -> Int {
        return 10 * Int(round(x / 10.0))
    }
    
    func titleChange(title: String) {
        self.titleString = title
    }
    
    func descChange(des: String) {
        self.descript = des
    }
    
    func days(day: Int) {
        self.eventRepeat = day
    }
    
    func showAlert1() {
        let alert = UIAlertController(title: "Please Select Hours", message: "Please make sure that opening hours, closing hours and days closed are set.", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    func showAlert2(string: String) {
        let alert = UIAlertController(title: "Please add a \(string)", message: "Please make sure that a title, description, photo and filter(s) are all added", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    func showAlert3() {
        let alert = UIAlertController(title: "You are creating an Event!", message: "You are creating an event which is not a place! It will show up differently on the map and is not timeless. Also in this update the developer has limited this action, please remove event tag", preferredStyle: .alert)
        let action2 = UIAlertAction(title: "Proceed", style: .default, handler: { (action : UIAlertAction!) -> Void in
            if let eventRepeat = self.eventRepeat, let startDate = self.startDate, let endDate = self.endDate, let coord = self.location, let title = self.titleString {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.createEvent(long: coord.coordinate.longitude, lat: coord.coordinate.latitude, title: title, startDate: startDate, endDate: endDate, repeatDays: eventRepeat)
                }
            }
        })
        let cancel = UIAlertAction(title: "Cancel Creation", style: .cancel, handler: nil)
        alert.addAction(cancel)
        alert.addAction(action2)
        self.present(alert, animated: true, completion: nil)
    }
    
    func datesView () {
        let viewer = UIView(frame: CGRect(x: 10, y: 100, width: view.frame.width - 20, height: view.frame.height - 200))
        let startlabel = UILabel(frame: CGRect(x: 15, y: 30, width: 200, height: 30))
        startlabel.text = "Start date"
        viewer.addSubview(startlabel)
        let datepicker = UIDatePicker(frame: CGRect(x: 15, y: 80, width: view.frame.width - 30, height: 200))
        viewer.addSubview(datepicker)
        self.view.addSubview(viewer)
    }
    
    func createPlace(long: Double, lat: Double, title: String) {
        oneCall = false
        let key = random(digits: 20)
        let geofireRef = Database.database().reference().child("PinsLocs")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let location = CLLocation(latitude: lat, longitude: long)
        if CLLocationManager.locationServicesEnabled() {
            print("long \(long)")
            geoFire.setLocation(location, forKey: key)
        }
        let storage = Storage.storage().reference().child("RegionsPlacesPhotots").child(key)
        if let uploadData = selectedImg!.jpegData(compressionQuality: 0.60) {
            storage.putData(uploadData, metadata: nil, completion:
                { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print(error!)
                        return
                    }
                        storage.downloadURL { url, error in
                        guard let downloadURL = url else {
                            print("erroor downl")
                            return
                        }
                        let urlLoad = downloadURL.absoluteString
                        let result = ["name" : title, "key" : key, "des" : self.descript!, "urlImage" : urlLoad, "long" : long, "lat" : lat, "filters" : self.selected] as [String : Any]
                        let update = [key : result]
                            Database.database().reference().child("Pins").updateChildValues(update)
                            if self.selectedAddHours == true {
                                let update2 = ["openHour" : self.openTimeHour!, "openMin" : self.openTimeMinutes!, "closeHour" : self.closedTimeHour!, "closeMin" : self.closedTimeMinutes!, "daysClose" : self.closedInts] as [String : Any]
                                Database.database().reference().child("Pins").child(key).updateChildValues(update2)
                                print(self.closedInts.count)
                                print(key)
                            }
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                    
            })
        }
    }
    
    func createEvent(long: Double, lat: Double, title: String, startDate: Date, endDate: Date, repeatDays: Int) {
        oneCall = false
        let key = random(digits: 20)
        let geofireRef = Database.database().reference().child("EventLocs")
        let geoFire = GeoFire(firebaseRef: geofireRef)
        let location = CLLocation(latitude: lat, longitude: long)
        if CLLocationManager.locationServicesEnabled() {
            print("long \(long)")
            geoFire.setLocation(location, forKey: key)
        }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm"
        let dateInt1 = startDate.timeIntervalSince1970
        let dateInt2 = endDate.timeIntervalSince1970
        let storage = Storage.storage().reference().child("EventPhotots").child(key)
        if let uploadData = selectedImg!.jpegData(compressionQuality: 0.60) {
            storage.putData(uploadData, metadata: nil, completion:
                { (metadata, error) in
                    guard let metadata = metadata else {
                        // Uh-oh, an error occurred!
                        print(error!)
                        return
                    }
                        storage.downloadURL { url, error in
                        guard let downloadURL = url else {
                            print("erroor downl")
                            return
                        }
                        
                        let urlLoad = downloadURL.absoluteString
                        
                            let result = ["name" : title, "key" : key, "des" : self.descript!, "urlImage" : urlLoad, "long" : long, "lat" : lat, "filters" : self.selected] as [String : Any]
                        let update = [key : result]
                            Database.database().reference().child("Events").updateChildValues(update)
                                let update2 = ["startDate" : dateInt1, "EndDate" : dateInt2, "repeatDays" : repeatDays] as [String : Any]
                                Database.database().reference().child("Events").child(key).updateChildValues(update2)
                                print(self.closedInts.count)
                                print(key)
                        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                    }
                    
            })
        }
    }
    
    func random(digits:Int) -> String {
        var number = String()
        for _ in 1...digits {
           number += "\(Int.random(in: 1...9))"
        }
        return number
    }
    
    func changedTime(time: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        if let hour = components.hour, let mins = components.minute {
            self.openTimeHour = hour
            self.openTimeMinutes = mins
        }
    }
    
    func changedEndTime(time: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        if let hour = components.hour, let mins = components.minute {
            self.closedTimeHour = hour
            self.closedTimeMinutes = mins
        }
    }
    
    func intForValue(string: String) -> Int {
        if string == "Sunday" {
            return 1
        }
        if string == "Monday" {
            return 2
        }
        if string == "Tuesday" {
            return 3
        }
        if string == "Wednesday" {
            return 4
        }
        if string == "Thursday" {
            return 5
        }
        if string == "Friday" {
            return 6
        }
        if string == "Saturday" {
            return 7
        }
        
        return 0
    }
    
    
    func times(times: [String]) {
        self.closedInts.removeAll()
        for each in times {
            let val = intForValue(string: each)
            self.closedInts.append(val)
            print("vals")
        }
    }

}

class tableViewCreate1: UITableViewCell, UITextFieldDelegate {
    @IBOutlet weak var inputTitle: UITextField!
    var delegate: changedTitle?
    override func layoutSubviews() {
        inputTitle.delegate = self
        inputTitle.frame = CGRect(x: 20, y: 5, width: contentView.frame.width - 40, height: 30)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
       textField.resignFirstResponder()
       return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.titleChange(title: textField.text ?? "")
    }
}
class tableViewCreate2: UITableViewCell, UITextViewDelegate {
    
    var delegate: changedDesc?
    @IBOutlet weak var textViewDes: UITextView!
    
    override func layoutSubviews() {
        textViewDes.delegate = self
        textViewDes.frame = CGRect(x: 20, y: 10, width: contentView.frame.width - 40, height: contentView.frame.height - 20)
        textViewDes.layer.cornerRadius = 8.0
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.descChange(des: textView.text ?? "")
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description" {
            textView.text = ""
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        if textView.text != "" {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            return newText.count < 1000
        }
        return true
    }
}
class tableViewCreate3: UITableViewCell {
   
    @IBOutlet weak var imagerView: UIImageView!
    
    override func layoutSubviews() {
    }
    
}
class tableViewCreate4: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var selectView: UIView!
    
    override func layoutSubviews() {
        labelTitle.frame = CGRect(x: 20, y: 5, width: 200, height: 25)
        selectView.frame = CGRect(x: contentView.frame.width - 40, y: 6, width: 22, height: 22)
        selectView.layer.cornerRadius = 11
    }
}

class tableViewCreate5: UITableViewCell {
    
    @IBOutlet weak var hoursLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        hoursLabel.layer.cornerRadius = 12.0
        hoursLabel.clipsToBounds = true
    }
}
class tableViewCreate6: UITableViewCell {
    
    var delegate: changedStartTime?
    override func layoutSubviews() {
        super.layoutSubviews()
        timePickerPicker.addTarget(self, action: #selector(self.selectedTime(sender:)), for: UIControl.Event.valueChanged)
    }
    @IBOutlet weak var timePickerPicker: UIDatePicker!
    @objc func selectedTime(sender: UIDatePicker) {
        delegate?.changedTime(time: sender.date)
    }
    
}

class tableViewCreate7: UITableViewCell {
    
    var delegate: changedEndTime?
    override func layoutSubviews() {
        super.layoutSubviews()
        timePicker.addTarget(self, action: #selector(self.selectedTime(sender:)), for: UIControl.Event.valueChanged)
    }
    @IBOutlet weak var timePicker: UIDatePicker!
    @objc func selectedTime(sender: UIDatePicker) {
        delegate?.changedEndTime(time: sender.date)
    }
}
class tableViewCreate8: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
  
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: changedDays?
    var data = ["None", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var selectedStrings = [String]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInnerCreate", for: indexPath) as! tableViewCellSelectDay
        cell.titleLabel.text = data[indexPath.row]
        if selectedStrings.contains(data[indexPath.row]) {
            cell.selectView.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        } else {
            cell.selectView.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedStrings.contains(data[indexPath.row]) {
            if let firstIndex = selectedStrings.firstIndex(of: data[indexPath.row]) {
                selectedStrings.remove(at: firstIndex)
            }
        } else {
            selectedStrings.append(data[indexPath.row])
        }
        delegate?.times(times: selectedStrings)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.delegate = self
        tableView.dataSource = self
    }
}

class tableViewCellSelectDay: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 20, y: 5, width: 200, height: 25)
        selectView.frame = CGRect(x: contentView.frame.width - 40, y: 6, width: 22, height: 22)
        selectView.layer.cornerRadius = 11
    }
    
}

class tableViewCreate10: UITableViewCell, UITableViewDelegate, UITableViewDataSource {
    //eventDaysPicker
    @IBOutlet weak var tablerView: UITableView!
    var delegate: changedDaysEvents?
    var data = ["Once", "Daily", "Weekly", "Monthly"]
    var selectedRepeat: Int?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventDaysCreationCell", for: indexPath) as! tableViewCellEventDays
        cell.titleLabel.text = data[indexPath.row]
        if selectedRepeat == indexPath.row {
            cell.selectView.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        } else {
            cell.selectView.backgroundColor = .clear
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedRepeat = indexPath.row
        delegate?.days(day: indexPath.row)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tablerView.delegate = self
        tablerView.dataSource = self
    }
    
}

class tableViewCell11: UITableViewCell {
    //selectDateEvent
    
    var delegate: changedDateEvent?
    
    @IBOutlet weak var labelStart: UILabel!
    
    @IBOutlet weak var dateStart: UIDatePicker!
    
    @IBOutlet weak var labelEnd: UILabel!
    
    @IBOutlet weak var dateEnd: UIDatePicker!
    
    override func layoutSubviews() {
        labelStart.frame = CGRect(x: 15, y: 10, width: 200, height: 30)
        dateStart.frame = CGRect(x: 15, y: 50, width: contentView.frame.width - 30, height: 120)
        labelEnd.frame = CGRect(x: 15, y: 180, width: 200, height: 30)
        dateEnd.frame = CGRect(x: 15, y: 220, width: contentView.frame.width - 30, height: 120)
        dateStart.addTarget(self, action: #selector(changedPicker1), for: .valueChanged)
        dateEnd.addTarget(self, action: #selector(changedPicker2), for: .valueChanged)
    }

    @objc func changedPicker1 () {
        delegate?.startDate(date: dateStart.date)
    }
    @objc func changedPicker2 () {
        delegate?.endDate(date: dateEnd.date)
    }
    
    
}

class tableViewCellEventDays: UITableViewCell {
    // eventDaysCreationCell
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectView: UIView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 20, y: 5, width: 200, height: 25)
        selectView.frame = CGRect(x: contentView.frame.width - 40, y: 6, width: 22, height: 22)
        selectView.layer.cornerRadius = 11
    }
}



class tableViewCreate9: UITableViewCell {
    @IBOutlet weak var viewBack: UIView!
}

protocol changedTitle {
    func titleChange(title: String)
}

protocol changedDesc {
    func descChange(des: String)
}
protocol changedStartTime {
    func changedTime(time: Date)
}
protocol changedEndTime {
    func changedEndTime(time: Date)
}
protocol changedDays {
    func times(times: [String])
}
protocol selectTBDay {
    func selectTimes(times: [String])
}
protocol changedDaysEvents {
    func days(day: Int)
}
protocol changedDateEvent {
    func startDate(date: Date)
    func endDate(date: Date)
}


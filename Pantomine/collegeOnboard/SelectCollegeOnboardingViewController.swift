//
//  SelectCollegeOnboardingViewController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 8/2/22.
//

import UIKit

class SelectCollegeOnboardingViewController: UIViewController {

    @IBOutlet weak var textEnterSchool: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var schoolEmailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

class selectCollegeTBCell: UITableViewCell {
    
    @IBOutlet weak var imagerView: UIImageView!
    
    @IBOutlet weak var selectView: UIView!
    
    @IBOutlet weak var nextButton: UILabel!
}

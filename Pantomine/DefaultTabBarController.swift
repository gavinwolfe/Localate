//
//  DefailtTabBarController.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 7/6/22.
//

import UIKit

class DefaultTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let college = UserDefaults.standard.string(forKey: "college") {
            if college != "" {
                let vc1 = storyboard.instantiateViewController(withIdentifier: "collegeVC") as! CollegeHomeViewController
                vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), tag: 0)
                let vc2 = storyboard.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
                vc2.tabBarItem = UITabBarItem(title: "Map", image: UIImage(named: "mapIcon"), tag: 1)
                self.viewControllers = [vc1, vc2]
                
            } else {
                let vc1 = storyboard.instantiateViewController(withIdentifier: "vc") as! ViewController
                vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), tag: 0)
                let vc2 = storyboard.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
                vc2.tabBarItem = UITabBarItem(title: "Map", image: UIImage(named: "mapIcon"), tag: 1)
                self.viewControllers = [vc1, vc2]
            }
        } else {
            let vc1 = storyboard.instantiateViewController(withIdentifier: "vc") as! ViewController
            vc1.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "homeIcon"), tag: 0)
            let vc2 = storyboard.instantiateViewController(withIdentifier: "mapVC") as! MapViewController
            vc2.tabBarItem = UITabBarItem(title: "Map", image: UIImage(named: "mapIcon"), tag: 1)
            self.viewControllers = [vc1, vc2]
        }

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

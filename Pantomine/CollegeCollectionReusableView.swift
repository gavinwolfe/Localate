//
//  CollegeCollectionReusableView.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 5/17/22.
//

import UIKit

class CollegeCollectionReusableView: UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var localateLabel: UILabel!
    @IBOutlet weak var segmentBar: UISegmentedControl!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var overView: UIView!
    
    @IBOutlet weak var labelShowPublic: UILabel!
    @IBOutlet weak var toggleDefaultLoc: UISwitch!
    
    @IBOutlet weak var defaultLocView: UIView!
    
    
    var filterIsOut = false
    var filters = ["Party", "Concert", "Kickback", "Scenic", "Experiences", "Nightlife", "Outdoor", "Smokespot", "Food/Drinks"]
    var selected = [String]()
    var delegate: selectedFilter?
    var delegate2: selectSearch?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        searchButton.addTarget(self, action: #selector(self.openSearch), for: .touchUpInside)
        localateLabel.frame = CGRect(x: 15, y: 5, width: overView.frame.width - 100, height: 30)
        searchButton.frame = CGRect(x: overView.frame.width - 70, y: 5, width: 25, height: 25)
        imageView.frame = CGRect(x: 0, y: 40, width: overView.frame.width, height: overView.frame.width / 1.9)
        let additionalHeight = 40 + overView.frame.width / 1.9
        filterButton.frame = CGRect(x: 45, y: additionalHeight - 25, width: overView.frame.width - 90, height: 50)
        
        segmentBar.frame = CGRect(x: 45, y: additionalHeight + 45, width: overView.frame.width - 90, height: 30)
        if filterIsOut == true {
            collectionView.frame = CGRect(x: 0, y: additionalHeight + 45, width: overView.frame.width, height: 80)
            defaultLocView.frame = CGRect(x: 45, y: additionalHeight + 125, width: overView.frame.width - 90, height: 60)
            segmentBar.frame = CGRect(x: 45, y: additionalHeight + 130, width: overView.frame.width - 90, height: 30)
            toggleDefaultLoc.frame = CGRect(x: 5, y: 10, width: 35, height: 35)
            labelShowPublic.frame = CGRect(x: 45, y: 10, width: 200, height: 35)
        }
        filterButton.layer.cornerRadius = 12.0
    }
    
    @objc func openSearch() {
        delegate2?.search()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 - 15, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selected.contains(filters[indexPath.row]) {
            selected = selected.filter({ $0 != filters[indexPath.row]})
        } else {
            selected.append(filters[indexPath.row])
        }
        collectionView.reloadSections([0])
        delegate?.filters(selected: selected)
    }
    
}

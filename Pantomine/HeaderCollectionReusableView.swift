//
//  HeaderCollectionReusableView.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 5/2/21.
//

import UIKit

protocol selectedFilter {
    func filters(selected: [String])
}
protocol selectSearch {
    func search()
}

class HeaderCollectionReusableView: UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var buttonClickedSearch: UIButton!
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var magnifyImageView: UIImageView!
    @IBOutlet weak var exploreLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var delegate: selectedFilter?
    var delegate2: selectSearch?
    var titles = ["Outdoor", "Shopping", "Food/Drink", "Scenic", "Experiences", "Nightlife"]
    var selected = [String]()
    var timer = Timer()
    var oneTimeSet = true
    var isFilterOut = false
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var segmentBar: UISegmentedControl!
    var midPoint = CGFloat(2.1)
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        var orgHeight = overView.frame.height
        if isFilterOut {
            orgHeight = ((overView.frame.height * 1.9) / 2.3)
            imageView.frame = CGRect(x: 0, y: 0, width: Int(overView.frame.width), height: Int(orgHeight / midPoint))
        } else {
            imageView.frame = CGRect(x: 0, y: 0, width: Int(overView.frame.width), height: Int(overView.frame.height / midPoint))
        }
        searchView.frame = CGRect(x: 30, y: orgHeight/midPoint - 20, width: overView.frame.width - 60, height: 40)
        filterButton.frame = CGRect(x: 45, y: orgHeight/midPoint + 45, width: overView.frame.width - 90, height: 50)
        segmentBar.frame = CGRect(x: 45, y: orgHeight/midPoint + 115, width: overView.frame.width - 90, height: 30)
        if isFilterOut == true {
            collectionView.frame = CGRect(x: 0, y: orgHeight/midPoint + 115, width: overView.frame.width, height: 80)
            segmentBar.frame = CGRect(x: 45, y: orgHeight/midPoint + 200, width: overView.frame.width - 90, height: 30)
        }
        buttonClickedSearch.frame = CGRect(x: 30, y: orgHeight/midPoint - 20, width: overView.frame.width - 60, height: 40)
        searchView.isUserInteractionEnabled = true
        filterButton.layer.cornerRadius = 12.0
        searchView.layer.cornerRadius = 12.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @objc func searchBarClicked() {
        delegate2?.search()
        print("fires")
    }
    
    @IBAction func actionSearch(_ sender: Any) {
        delegate2?.search()
        print("fires")
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellFilterCV", for: indexPath) as? collectionViewFilterCell {
            cell.labelTitle.text = titles[indexPath.row]
            if selected.contains(titles[indexPath.row]) {
                cell.dotView.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            } else {
                cell.dotView.backgroundColor = .clear
            }
            return cell
        }
        return UICollectionViewCell()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 - 15, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selected.contains(titles[indexPath.row]) {
            selected = selected.filter({ $0 != titles[indexPath.row]})
        } else {
            selected.append(titles[indexPath.row])
        }
        collectionView.reloadSections([0])
        delegate?.filters(selected: selected)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.purple

     }

     required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

     }
    
}

class collectionViewFilterCell: UICollectionViewCell {
    let dotView = UIView()
    let labelTitle = UILabel()
    
    override func layoutSubviews() {
        dotView.frame = CGRect(x: 15, y: 8, width: 15, height: 15)
        labelTitle.frame = CGRect(x: 35, y: 5, width: 100, height: 20)
        labelTitle.font = UIFont(name: "Helvetica", size: 12)
        dotView.layer.cornerRadius = 2.0
        dotView.clipsToBounds = true 
        dotView.layer.borderColor = UIColor.label.cgColor
        dotView.layer.borderWidth = 1.0
        contentView.addSubview(dotView)
        contentView.addSubview(labelTitle)
    }
}


//
//  HomeFilterCollectionViewCell.swift
//  Pantomine
//
//  Created by Gavin Wolfe on 5/15/21.
//

import UIKit

class HomeFilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        dotView.frame = CGRect(x: 5, y: 8, width: 15, height: 15)
        labelTitle.frame = CGRect(x: 20, y: 5, width: 60, height: 20)
    }

}

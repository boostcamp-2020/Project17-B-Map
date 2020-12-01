//
//  DetailCollectionViewCell.swift
//  BoostClusteringMaB
//
//  Created by 조정래 on 2020/12/01.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var storeImageView: UIImageView!
    
    func configure(poi: ManagedPOI) {
        nameLabel.text = poi.name
        categoryLabel.text = poi.category
        storeImageView.loadImage(contentsOf: poi.imageURL)
    }
    
}

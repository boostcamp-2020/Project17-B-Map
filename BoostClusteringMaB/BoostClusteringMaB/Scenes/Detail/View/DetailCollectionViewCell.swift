//
//  DetailCollectionViewCell.swift
//  BoostClusteringMaB
//
//  Created by 조정래 on 2020/12/01.
//

import UIKit

class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var storeImageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!

    override func prepareForReuse() {
        storeImageView.image = UIImage(named: "icon")
    }

    func configure(poi: ManagedPOI) {
        nameLabel.text = poi.name
        categoryLabel.text = poi.category
        addressLabel.text = poi.address
        storeImageView.loadImage(contentsOf: poi.imageURL)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCell()
    }
    
    func configureCell() {
        layer.borderWidth = 1
        layer.cornerRadius = 10
    }
}

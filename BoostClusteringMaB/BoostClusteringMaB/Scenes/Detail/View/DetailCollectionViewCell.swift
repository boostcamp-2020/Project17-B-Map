//
//  DetailCollectionViewCell.swift
//  BoostClusteringMaB
//
//  Created by 조정래 on 2020/12/01.
//

import UIKit

final class DetailCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var storeImageView: UIImageView! {
        didSet {
            storeImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var latLng: LatLng?
    private weak var imageTask: URLSessionTask?
    private weak var addressTask: URLSessionTask?

    override func prepareForReuse() {
        storeImageView.image = UIImage(systemName: "slash.circle")
        addressLabel.text = nil
        activityIndicator.startAnimating()
        imageTask?.cancel()
        addressTask?.cancel()
    }
    
    func configure(poi: ManagedPOI) {
        self.latLng = LatLng(lat: poi.latitude, lng: poi.longitude)
        nameLabel.text = poi.name
        categoryLabel.text = poi.category
        
        addressTask = AddressAPI.shared.address(lat: poi.latitude, lng: poi.longitude) { [weak self] result in
            let address = try? JsonParser.shared.parse(address: result.get())
            self?.addressLabel.text = address
        }
        
        guard let imageURL = poi.imageURL else {
            self.activityIndicator.stopAnimating()
            return
        }
        
        imageTask = ImageDownloader.shared.fetch(imageURL: imageURL) { [weak self] result in
            self?.activityIndicator.stopAnimating()
            guard let image = try? result.get() else {
                return
            }
            
            self?.storeImageView.image = image
        }
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

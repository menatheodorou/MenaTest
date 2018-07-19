//
//  RestaurantDetailViewController.swift
//  MenaTest
//
//  Created by Mena on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import SDWebImage

class RestaurantDetailViewController: BaseViewController {

    @IBOutlet weak var venueImageView: UIImageView!
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueCategoryNameLabel: UILabel!
    @IBOutlet weak var venueCategoryIdLabel: UILabel!
    
    var venueItem: VenueItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func setupUI() {
        venueNameLabel.text = venueItem.venueName
        venueCategoryNameLabel.text = venueItem.categoryId
        venueCategoryNameLabel.text = venueItem.categoryName
        if let iconUrl = venueItem.categoryIconUrl, let url = URL(string: iconUrl) {
            venueImageView.sd_setImage(with: url, completed: nil)
        }
    }

    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

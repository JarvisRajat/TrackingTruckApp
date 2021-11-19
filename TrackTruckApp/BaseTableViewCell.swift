//
//  BaseTableViewCell.swift
//  TrackTruckApp
//
//  Created by Rajat Raj on 17/11/21.
//

import UIKit
import Foundation

class BaseTableViewCell<A>: UITableViewCell {
    var datasource: A!
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }
}

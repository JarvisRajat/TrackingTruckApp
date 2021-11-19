//
//  TruckDetailsTableViewCell.swift
//  TrackTruckApp
//
//  Created by Rajat Raj on 17/11/21.
//

import UIKit

class TruckDetailsTableViewCell: BaseTableViewCell<TruckData> {

    @IBOutlet weak var cellParentView: UIView!
    @IBOutlet private weak var trucknumberLabel: UILabel!
    @IBOutlet private weak var truckStatusLabel: UILabel!
    @IBOutlet private weak var truckSpeedLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override var datasource: TruckData! {
            didSet {
                configureUI(data: datasource)
            }
        }
    private func configureUI(data: TruckData) {
        trucknumberLabel.text = data.truckNumber
        if data.lastRunningState?.truckRunningState == 0 {
            truckStatusLabel.text = "Stopped since last \(Constants.conversionToTimestamp(myMilliseconds: data.lastRunningState?.stopStartTime ?? 0))."
            truckSpeedLabel.isHidden = true
        } else {
            truckStatusLabel.text = "Running since last \(Constants.conversionToTimestamp(myMilliseconds: data.lastRunningState?.stopStartTime ?? 0))."
            truckSpeedLabel.isHidden = false
        }
        let attrs1 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.red]
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.lightGray]
        let obj = Constants.splitDuration(durationText: Constants.conversionToTimestamp(myMilliseconds: data.lastWaypoint?.createTime ?? 0))
        configureCellStyle(val: obj.val, unit: obj.unit)
        let attributedString1 = NSMutableAttributedString(string: "\(obj.val)", attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:" \(obj.unit) ago.", attributes:attrs2)
        let numerics = NSMutableAttributedString(string: "\(data.lastWaypoint?.speed ?? 0)", attributes:attrs1)
        let units = NSMutableAttributedString(string:" k/h.", attributes:attrs2)
        attributedString1.append(attributedString2)
        numerics.append(units)
        durationLabel.attributedText = attributedString1
        truckSpeedLabel.attributedText = numerics
    }
    
    private func configureCellStyle(val: Int, unit: String) {
        cellParentView.layer.cornerRadius = 18
        if Constants.isInErrorState(val: val, unit: unit) {
            cellParentView.layer.borderWidth = 1
          cellParentView.layer.borderColor = UIColor.red.cgColor
        } else {
        cellParentView.layer.borderWidth = 0.5
        cellParentView.layer.borderColor = UIColor.systemGray.cgColor
        }
    }
}

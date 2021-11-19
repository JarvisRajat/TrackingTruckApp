//
//  ViewController.swift
//  TrackTruckApp
//
//  Created by Rajat Raj on 16/11/21.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    
    @IBOutlet weak var google_map: GMSMapView!
    @IBOutlet weak var sideButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var refreshRightAnchor: NSLayoutConstraint!
    @IBOutlet weak var refreshLowPriorityRightAnchor: NSLayoutConstraint!
    @IBOutlet weak var truckList: UITableView!
    var listIsVisible = false
    var responseData: [TruckData]?
    var originalData: [TruckData]?
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "https://api.mystral.in/tt/mobile/logistics/searchTrucks?auth-company=PCH&companyId=33&deactivated=false&key=g2qb5jvucg7j8skpu5q7ria0mu&q-expand=true&q-include=lastRunningState,lastWaypoint"
        getData(from: url)
        registerCell()
    }
    
    private func registerCell() {
        truckList.register(UINib(nibName: "TruckDetailsTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "TruckDetailsTableViewCell")
    }
    
    private func fetchData(data: [TruckData]) {
        originalData = data
        responseData = originalData
        responseData = responseData?.sorted(by: {(($0.lastWaypoint?.createTime ?? 0) > ($1.lastWaypoint?.createTime ?? 0))})
    }
    
    private func mapSetup(response: TruckData) {
        let latitude = response.lastWaypoint?.lat ?? 0.0
        let longitude = response.lastWaypoint?.lng ?? 0.0
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 6.0)
        google_map.camera = camera
        self.showMarker(position: google_map.camera.target, data: response)
    }
    private func showMarker(position: CLLocationCoordinate2D, data: TruckData) {
        let marker = GMSMarker()
        let lastRunningState = data.lastRunningState?.truckRunningState ?? 0
        let duration = Constants.splitDuration(durationText: Constants.conversionToTimestamp(myMilliseconds: data.lastWaypoint?.createTime ?? 0))
        if Constants.isInErrorState(val: duration.val, unit: duration.unit) {
            marker.icon = GMSMarker.markerImage(with: UIColor.systemRed)
        } else if lastRunningState == 0 {
            if (data.lastWaypoint?.ignitionOn ?? false) {
                marker.icon = GMSMarker.markerImage(with: UIColor.systemYellow)
            } else {
                marker.icon = GMSMarker.markerImage(with: UIColor.systemBlue)
            }
        } else {
            marker.icon = GMSMarker.markerImage(with: UIColor.systemGreen)
        }
        marker.position = position
        marker.map = google_map
    }
    
    private func getData(from url: String) {
        let task = URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("Something went wrong")
                return
            }
            var result: TruckDataRuleEngine?
            do {
                result = try JSONDecoder().decode(TruckDataRuleEngine.self, from: data)
            }
            catch {
                print("Failed on conversion \(error.localizedDescription)")
            }
            guard let jsonData = result else {
                return
            }
            DispatchQueue.main.async {
                let truckData = jsonData.data ?? []
                self.fetchData(data: truckData)
                for data in truckData {
                    self.mapSetup(response: data)
                }
            }
        })
        task.resume()
    }
    @IBAction func sideButtonAction(_ sender: UIButton) {}
    
    @IBAction func listButtonAction(_ sender: Any) {
        listIsVisible = !listIsVisible
        if listIsVisible {
            refreshRightAnchor.priority = UILayoutPriority(250)
            refreshLowPriorityRightAnchor.priority = UILayoutPriority(750)
            listButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
            searchButton.isHidden = false
            truckList.isHidden = false
        } else {
            refreshRightAnchor.priority = UILayoutPriority(1000)
            refreshLowPriorityRightAnchor.priority = UILayoutPriority(750)
            listButton.setImage(UIImage(systemName: "list.dash"), for: .normal)
            searchButton.isHidden = true
            truckList.isHidden = true
            if !searchBar.isHidden { searchButtonAction(self) }
        }
        responseData = originalData
        truckList.reloadData()
    }
    
    @IBAction func searchButtonAction(_ sender: Any) {
        if searchBar.isHidden  {
            headerLabel.isHidden = true
            refreshButton.isHidden = true
            searchBar.isHidden = false
        } else {
            headerLabel.isHidden = false
            refreshButton.isHidden = false
            searchBar.isHidden = true
        }
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (responseData?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TruckDetailsTableViewCell", for: indexPath) as? TruckDetailsTableViewCell
                    else { return UITableViewCell() }
        cell.datasource = responseData?[indexPath.row]
        return cell
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        responseData = searchText.isEmpty ? originalData : originalData?.filter({data -> Bool in
            return data.truckNumber?.range(of: searchText, options: .caseInsensitive) != nil
        })
        truckList.reloadData()
    }
}

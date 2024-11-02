//
//  ViewController.swift
//  Weather
//
//  Created by Nguyễn Văn Hiếu on 2/11/24.
//

import UIKit
import CoreLocation

class ResultsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemCyan
    }
}

class ViewController: UIViewController {
    
    //MARK: - Properties
    let searchController = UISearchController(searchResultsController: ResultsVC())
    @IBOutlet weak var datesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var imageViewWeather: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel! //Nhiệt độ
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var sundownLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel! //Độ ẩm
    @IBOutlet weak var windLabel: UILabel! //Tốc độ gió
    var locationManager = CLLocationManager()

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Thời tiết"
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Thành phố bạn muốn tìm?"
        navigationItem.searchController = searchController
        configuration()
    }

}

//MARK: - UISearchResultsUpdating
extension ViewController:  UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        
        let vc = searchController.searchResultsController as? ResultsVC
        vc?.view.backgroundColor = .yellow
        print(text)
    }
}

//MARK: - CLLocationManagerDelegate
extension ViewController: CLLocationManagerDelegate {
    
    // Cấu hình cơ bản của đối tượng vị trí
    func configuration() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // lấy ra vị trí chính xác nhất
        locationManager.requestWhenInUseAuthorization() // yêu cầu khi người dùng xác thực
        locationManager.startUpdatingLocation() // bắt đầu cập nhật vị trí
        
    }
    
    // Hàm delegate để lấy kết quả cập nhật vị trí
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
        } else {
            print("Không có vị trí nào được cập nhật.")
        }
    }
    
    // Xử lý khi cập nhật vị trí thất bại
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Faild location: ",error.localizedDescription)
    }
}


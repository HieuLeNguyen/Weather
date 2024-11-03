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

//MARK: - ViewController
extension ViewController {
    
    // Fetch Weather with latitude, longitude
    func fetchWeather(latitude: Double, longitude: Double) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        config.timeoutIntervalForRequest = 200
        config.timeoutIntervalForResource = 200
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&unit=metric&lang=vi&appid=98f3513b4f659e05cfe66afe8dc0b037") else {return}
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("Failed to fetch data: \(String(describing: error))")
                return
            }
            
            do {
                let weatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.async {
                    self.displayWeather(weatherData)
                }
            } catch {
                print("Error handle \(error)")
            }
        }
        task.resume()
    }
    
    // display inside UI
    func displayWeather(_ weatherData: WeatherModel) {
        let date = Date(timeIntervalSince1970: TimeInterval(weatherData.dt))
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale(identifier: "vi_VN")
        dateFormatter.dateFormat = "EEEE, dd/MM/yyyy"
        
        let formatterDate = dateFormatter.string(from: date)
        let hour = formatterHour(weatherData.dt)
        
        let tem = weatherData.main.temp - 273.15
        let formatterTem  = String(format: "%.1f", tem)
        let desc = weatherData.weather.first?.description ?? "Không có mô tả"
        let humidity = weatherData.main.humidity
        let wind = weatherData.wind.speed
        
        let city = weatherData.name
        let sunrise = formatterHour(weatherData.sys.sunrise)
        let sunset = formatterHour(weatherData.sys.sunset)
        
        datesLabel.text = formatterDate
        timeLabel.text = hour
        cityLabel.text = city
        temperatureLabel.text = "\(String(formatterTem))°"
        descLabel.text = desc
        sunriseLabel.text = "MT mọc: \(sunrise)"
        sundownLabel.text = "MT lặn: \(sunset)"
        humidityLabel.text = "Độ ẩm: \(String(humidity))"
        windLabel.text = "Gió: \(String(wind))"
        
        if let lastIcon = weatherData.weather.last?.icon {
            loadImage(from: getWeatherIcon(icon: lastIcon), imageView: imageViewWeather)
        }
    }
    
    // load image icon
    func loadImage(from url: String, imageView: UIImageView) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error loading image: \(error)")
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load image data")
                return
            }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task.resume()
    }
    
    // formatter hour
    func formatterHour(_ timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let formatterHour = formatter.string(from: date)
        return formatterHour
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
            //call method fecthWeather
            fetchWeather(latitude: lat, longitude: lon)
        } else {
            print("Không có vị trí nào được cập nhật.")
        }
    }
    
    // Xử lý khi cập nhật vị trí thất bại
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Faild location: ",error.localizedDescription)
    }
}


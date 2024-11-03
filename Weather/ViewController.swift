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
                    self.changeBackground(weatherData.dt, weatherData.sys.sunrise, weatherData.sys.sunset)
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
    
    // real time background change
    func changeBackground(
        _ datetime: Int,
        _ sunrise: Int,
        _ sunset: Int
    ){
        switch datetime {
            
        case sunrise..<(sunrise + 1800), (sunset - 1800)...sunset:
            // Gradient color sunrise and sunset
            setGradientBackground(color: [
                UIColor(red: 4.0/255.0, green: 64.0/255.0, blue: 204.0/255.0, alpha: 1.0).cgColor, // màu xanh nước biển
                UIColor(red: 179.0/255.0, green: 149.0/255.0, blue: 220.0/255.0, alpha: 1.0).cgColor, // màu tím nhạt
                UIColor(red: 244.0/255.0, green: 174.0/255.0, blue: 94.0/255.0, alpha: 1.0).cgColor, // màu vàng
                UIColor(red: 175.0/255.0, green: 61.0/255.0, blue: 54.0/255.0, alpha: 1.0).cgColor // màu cam
            ], location: [0.0, 0.5, 0.88, 1.0])
            
        case (sunrise + 1800)..<(sunset - 1800):
            // Gradient color day
            setGradientBackground(color: [
                UIColor(red: 135.0/255.0, green: 206.0/255.0, blue: 235.0/255.0, alpha: 1.0).cgColor, // Xanh trời nhạt
                UIColor(red: 255.0/255.0, green: 223.0/255.0, blue: 186.0/255.0, alpha: 1.0).cgColor, // Vàng sáng
                UIColor(red: 70.0/255.0, green: 130.0/255.0, blue: 180.0/255.0, alpha: 1.0).cgColor // Xanh da trời
            ], location: [0.0, 0.5 , 1.0])
            
        default:
            // Gradient color night
            setGradientBackground(color: [
                UIColor(red: 11.0/255.0, green: 61.0/255.0, blue: 145.0/255.0, alpha: 1.0).cgColor, // Xanh đậm
                UIColor(red: 44.0/255.0, green: 22.0/255.0, blue: 84.0/255.0, alpha: 1.0).cgColor, // Tím đậm
                UIColor(red: 18.0/255.0, green: 32.0/255.0, blue: 47.0/255.0, alpha: 1.0).cgColor // Màu đêm tối
            ], location: [0.0, 0.5 , 1.0])
        }
    }
    
    // Helper function to set the gradient background
    func setGradientBackground(color: [CGColor], location: [NSNumber]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = color
        gradientLayer.locations = location
        //set the start and end point for the gradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1.0)
        
        //set the frame tho the layer
        gradientLayer.frame = view.frame
        
        //add the gradient layer as as sublayer to the background view
        view.layer.insertSublayer(gradientLayer, at: 0)
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


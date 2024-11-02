//
//  Constrant.swift
//  Weather
//
//  Created by Nguyễn Văn Hiếu on 2/11/24.
//

import Foundation

let appID = "98f3513b4f659e05cfe66afe8dc0b037"
let baseUrl = "https://api.openweathermap.org/data/2.5/weather?"

//MARK: - Lấy theo toạ độ (default)
func getWeatherByCoordinates(lat: Double, lon: Double) -> String {
    return "\(baseUrl)lat=\(lat)&lon=\(lon)&unit=metric&lang=vi&appid=\(appID)"
}

//MARK: - Lấy theo tên địa điểm
func getWeatherByCityName(cityName: String) -> String {
    return "\(baseUrl)q=\(cityName)&unit=metric&lang=vi&appid=\(appID)"
}

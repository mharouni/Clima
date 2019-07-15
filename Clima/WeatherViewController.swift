//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "cb7f82b19354e56c7155ccb0a421705c"

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
	let weatherDatamodel = WeatherDataModel()
    @IBOutlet weak var weatherIcon: UIImageView!
	@IBOutlet weak var cToF: UISwitch!
	@IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
	@IBAction func hii(_ sender: UISwitch) {
		if cToF.isOn {
			weatherDatamodel.temperature = weatherDatamodel.temperature * 9 / 5 + 32
		}
		else {
			weatherDatamodel.temperature = (weatherDatamodel.temperature - 32) * (5 / 9)
		}
		updateUIWithWeatherData()
	}
	override func viewDidLoad() {
        super.viewDidLoad()
        //TODO:Set up the location manager here.
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
		locationManager.requestWhenInUseAuthorization()
		locationManager.startUpdatingLocation()
		cToF.setOn(false, animated: false)
    }
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
	func getWeatherData( url : String, parameters : [String : String]){
		Alamofire.request(url, method: .get, parameters : parameters).responseJSON {
			response in
			if response.result.isSuccess {
				//print("Yaaaaay")
				let weatherJSON = JSON(response.result.value!)
				print(weatherJSON)
				self.updateWeatherData(json: weatherJSON)
				
			}
			else {
				print("Error \(response.result.error)")
				self.cityLabel.text = "Connection Issue"
			}
			
		}
	}
	
    //MARK: - JSON Parsing
    /***************************************************************/
    //Write the updateWeatherData method here:
	func updateWeatherData(json : JSON) {
		if let temperature = json["main"]["temp"].double {
		//print(temperature)
			weatherDatamodel.temperature = Int(temperature - 273.15)
			weatherDatamodel.city = json ["name"].stringValue
			weatherDatamodel.condition = json ["weather"][0]["id"].intValue
			weatherDatamodel.westherIconName = weatherDatamodel.updateWeatherIcon(condition: weatherDatamodel.condition)
			updateUIWithWeatherData()
		}
		else {
			cityLabel.text = " Weather Unavailable"
		}
	}
    //MARK: - UI Updates
    /***************************************************************/
    //Write the updateUIWithWeatherData method here:
    
	func updateUIWithWeatherData() {
		cityLabel.text = weatherDatamodel.city
		//print(weatherDatamodel.temperature)
		temperatureLabel.text = "\(weatherDatamodel.temperature)°"
		print(weatherDatamodel.westherIconName)
		print(weatherDatamodel.condition)
		weatherIcon.image = UIImage(named: weatherDatamodel.westherIconName)
	}
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations [ locations.count  - 1]
		if location.horizontalAccuracy > 0 {
			locationManager.stopUpdatingLocation()
		}
		let lon = String(location.coordinate.longitude)
		let lat = String( location.coordinate.latitude)
		let param : [String : String] = [ "lat" : lat, "lon" : lon , "appid" : APP_ID]
		getWeatherData(url: WEATHER_URL, parameters: param)
	}
    
    
    //Write the didFailWithError method here:
    
    
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print(error)
		cityLabel.text = "Location Unavailable"
	}

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
	func userEnteredNewCityName(city: String) {
		let params : [String:String] = ["q" : city, "appid" : APP_ID]
		getWeatherData(url: WEATHER_URL, parameters: params)
	}
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "changeCityName" {
			let destinationVC = segue.destination as! ChangeCityViewController
			destinationVC.delegate = self
		}
	}
    
    
    
}



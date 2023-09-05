//
//  ViewController.swift
//  YAWA - Yet Another Weather App
//
//  Created by Jai Nijhawan on 10/07/20.
//  Copyright © 2020 Jai Nijhawan. All rights reserved.
//

import UIKit
import SwiftyGif
import MapKit
import SwiftCSV
import RealmSwift

class CurrentLocationViewController: UIViewController, CAAnimationDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var currentWeatherGIF: UIImageView!
    @IBOutlet weak var skyView: UIView!
    @IBOutlet weak var toggleImage: UIImageView!
    @IBOutlet weak var qualityIndexLabel: UILabel!
    @IBOutlet weak var daysCollectionview: UICollectionView!
    @IBOutlet weak var cityCollectionView: UICollectionView!
    @IBOutlet weak var placesLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var dayOfTheWeek: UILabel!
    @IBOutlet weak var currentDate: UILabel!
    @IBOutlet weak var aqiLabel: UILabel!
    @IBOutlet weak var aqiComment: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var metricLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var bg: UIImageView!
    @IBOutlet weak var tempViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var weatherDescriptionTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hourlyCollectionView: UICollectionView!
    @IBOutlet weak var daysCollectionViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var placesView: UIView!
    @IBOutlet weak var addtoFavView: UIView!
    @IBOutlet weak var addToFavsLabel: UILabel!
    @IBOutlet weak var addToFavButton: UIButton!
    @IBOutlet weak var addToFavImageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    
    // MARK: - Variabels
    var currentIndexPath = IndexPath(item: 0, section: 0)
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var viewModel = CurrentLocationViewModel()
    let gradientLayer = CAGradientLayer()
    var savedCities: [CityData] = []
    var savedCitiesData: [(temprature: String, id: Int, lat: Double, lon: Double)] = []
    var isPresentedFromCurrentLocationVC = false
    var getDataAfterInternetSetting = false
    var isPresentedFromSearch = false
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFirebaseRemoteConfig()
        if citiesData.count == 0 {
            loadDataFromRealm()
        }
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.isConnectedToNetwork() {
            showNoNetworkPopup()
        }
    }
    func configureFirebaseRemoteConfig() {
        FirebaseManager.setupFirebaseDefaultValues()
        FirebaseManager.fetchAndActivate { [weak self] in
            guard let self = self,
                  !self.isPresentedFromCurrentLocationVC,
                  !self.isPresentedFromSearch else { return }
            self.getCurrentLocationWeather()
        }
    }
    
    func getAllSavedCities() {
        let savedCitiesResult = realmObject.objects(SavedCities.self)
        let count = savedCitiesResult.count
        var currentCount = 0
        for city in savedCitiesResult {
            savedCities.append((city: city.cityName!,
                                country: "",
                                lat: city.lat!,
                                lon: city.lon!))
            
            viewModel.getCurrentCityData(lat: Double(city.lat!)!, lon: Double(city.lon!)!) { [weak self] (data) in
                currentCount += 1
                self?.savedCitiesData.append((temprature: data.current.temp.getTempInCelcius(),
                                              id: data.current.weather.first!.id,
                                              lat: data.lat, lon: data.lon))
                if currentCount == count {
                    self?.sortTempratureData()
                }
            }
        }
    }
    
    func loadDataFromCSV() {
        DispatchQueue.global(qos: .userInteractive).async {
            let path =  Bundle.main.path(forResource: "a", ofType: "csv")
            let csvFile: CSV = try! CSV(url: URL(fileURLWithPath: path!))
            try! csvFile.enumerateAsArray { [weak self] array in
                let data = (city: array[1],
                            country: array[4],
                            lat: array[2],
                            lon: array[3])
                citiesData.append(data)
                self?.saveAllCitiesDataToRealm(data: data)
            }
        }
    }
    
    func saveAllCitiesDataToRealm(data: CityData) {
        let realmObject = try! Realm()
        try! realmObject.write {
            let allCitiesData = AllCitiesData()
            allCitiesData.city = data.city
            allCitiesData.country = data.country
            allCitiesData.lat = data.lat
            allCitiesData.lon = data.lon
            realmObject.add(allCitiesData)
        }
    }
    
    func loadDataFromRealm() {
        let allCities = realmObject.objects(AllCitiesData.self)
        if allCities.count == 0 {
            loadDataFromCSV()
        } else {
            for city in allCities {
                let tuple = (city: city.city!,
                             country: city.country!,
                             lat: city.lat!,
                             lon: city.lon!)
                citiesData.append(tuple)
            }
        }
    }
    
    // MARK: - Custom Methods
    func setupUI() {
        skyView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        gradientLayer.colors = [
            UIColor(red: 0, green: 0.64, blue: 1, alpha: 0.75).cgColor,
            UIColor(red: 0, green: 0.82, blue: 1, alpha: 0.5).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.frame = skyView.frame
        skyView.layer.addSublayer(gradientLayer)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.75
        qualityIndexLabel.attributedText = NSMutableAttributedString(string: "QUALITY\nINDEX",
                                                                     attributes: [NSAttributedString.Key.kern: 3.36,
                                                                                  NSAttributedString.Key.paragraphStyle: paragraphStyle])
        
        placesLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
        cityCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 50)
        changeDescriptionLabel()
        setupUIForDifferentCity()
        if viewModel.cityData == nil {
            locManager.requestWhenInUseAuthorization()
            locManager.delegate = self
            getAllSavedCities()
        }
        if isPresentedFromCurrentLocationVC {
            addToFavsLabel.text = "Remove from My Places"
            addToFavsLabel.textColor = UIColor(red: 0.98, green: 0.13, blue: 0.13, alpha: 1.00)
            addToFavImageView.image = UIImage(named: "minusRed")
        }
        view.layoutIfNeeded()
    }
    
    func sortTempratureData() {
        var sortedData: [(temprature: String, id: Int, lat: Double, lon: Double)] = []
        
        for city in self.savedCities {
            let lat: Int = Int(Double(city.lat)!)
            let lon: Int =  Int(Double(city.lon)!)
            for data in self.savedCitiesData {
                if lat == Int(data.lat) && lon == Int(data.lon) {
                    sortedData.append((temprature: data.temprature,
                                       id: data.id,
                                       lat: data.lat,
                                       lon: data.lon))
                }
            }
        }
        self.savedCitiesData.removeAll()
        self.savedCitiesData = sortedData
        self.cityCollectionView.reloadData()
    }
    
    func setupUIForDifferentCity() {
        if viewModel.cityData != nil {
            let lat = Double(viewModel.cityData!.lat)!
            let lon = Double(viewModel.cityData!.lon)!
            getcurrentCityDataWithLatAndLon(lat: lat, lon: lon)
            backButton.isHidden = false
            addtoFavView.isHidden = false
            searchButton.isHidden = true
            placesView.isHidden = true
            cityCollectionView.isHidden = true
            infoButton.isHidden = true
        }
    }
    
    func getcurrentCityDataWithLatAndLon(lat: Double, lon: Double) {
        viewModel.getCurrentCityData(lat: lat, lon: lon) { [weak self] (data) in
            self?.populateUIWithData(data: data)
        }
        viewModel.getCurrentCityAQI(lat: lat, lon: lon) { [weak self] (data) in
            self?.handleAQI(data: data)
        }
        getCityName(lat: lat, lon: lon, completion: { [weak self] cityName in
            self?.cityName.text = cityName
        })
    }
    
    func handleAQI(data: AQIDataModel) {
        let aqi = data.data.current.pollution.aqius
        let aqiColorTextAndBG = getAQIColorTextAndBG(aqi: aqi)
        aqiLabel.text = "\(aqi)"
        aqiLabel.textColor = aqiColorTextAndBG.0.withAlphaComponent(0.7)
        aqiComment.textColor = aqiColorTextAndBG.0
        aqiComment.text = aqiColorTextAndBG.1
        animateBG(bg: aqiColorTextAndBG.2)
        view.layoutIfNeeded()
    }
    
    func animateBG(bg: String) {
        let toImage = UIImage(named: bg)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.transition(with: self.bg,
                              duration: 4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.bg.image = toImage
            },
                              completion: nil)
        }
    }
    
    func populateUIWithData(data: WeatherDataModel) {
        let temperature = data.current.temp.getTempInCelcius()
        tempratureLabel.text = temperature
        //    cityName.text = data.name
        //    countryName.text = data.sys.country
        dayOfTheWeek.text = Date().dayOfWeek()
        currentDate.text = getCurrentDate()
        metricLabel.text = "CELCIUS"
        maxTempLabel.text = data.daily.first?.temp.max.getTempInCelcius()
        minTempLabel.text = data.daily.first?.temp.min.getTempInCelcius()
        if let weather = data.current.weather.first {
            if let GIF = getGIFFromCurrentWeatherID(id: weather.id) {
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               options: .curveEaseInOut,
                               animations: {
                    self.currentWeatherGIF.alpha = 1
                }, completion: nil)
                currentWeatherGIF.setGifImage(GIF)
                weatherDescriptionLabel.text = weather.weatherDescription.capitalizingFirstLetter()
            }
        }
        daysCollectionview.reloadData()
        hourlyCollectionView.reloadData()
    }
    
    func getCityName(lat: Double, lon: Double,
                     completion: @escaping ((_ data: String) -> Void)) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: lat, longitude: lon)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                completion(placemarks?.first?.locality ?? "")
            }
        }
    }
    
    func changeDescriptionLabel() {
        if UIScreen.main.bounds.size.height < 700 {
            weatherDescriptionTopConstraint.constant = -20
            weatherDescriptionLabel.font = weatherDescriptionLabel.font.withSize(25)
            self.view.layoutIfNeeded()
        }
    }
    
    func toggleTapped(isDailyTapped: Bool) {
        UIView.transition(with: toggleImage,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: {
            self.toggleImage.image = isDailyTapped ? UIImage(named: "dailyToggle") : UIImage(named: "hourlyToggle")
        },
                          completion: nil)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.hourlyCollectionView.alpha = isDailyTapped ? 0 : 1
        }, completion: nil)
        
        daysCollectionViewLeadingConstraint.constant = isDailyTapped ? 15 : screenWidth
        UIView.animate(withDuration: 1,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 8,
                       options: .curveEaseInOut,
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func showAllowLocationPopup() {
        let alertVC = UIAlertController(title: "Please allow Location Services",
                                        message: "We need location Services to show data",
                                        preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (_) in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func showNoNetworkPopup() {
        let alertVC = UIAlertController(title: "No Network",
                                        message: "Please check your internet connection",
                                        preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(action)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction func dailyTogglePressed(_ sender: Any) {
        toggleTapped(isDailyTapped: true)
    }
    @IBAction func hourlyTogglePressed(_ sender: Any) {
        toggleTapped(isDailyTapped: false)
    }
    @IBAction func backDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            tempratureLabel.text = tempInFahrenheit(text: tempratureLabel.text)
            maxTempLabel.text = tempInFahrenheit(text: maxTempLabel.text)
            minTempLabel.text = tempInFahrenheit(text: minTempLabel.text)
            metricLabel.text = "FAHRENHEIT"
            tempViewLeadingConstraint.constant = 20
        } else {
            tempratureLabel.text = tempInCelcius(text: tempratureLabel.text)
            maxTempLabel.text = tempInCelcius(text: maxTempLabel.text)
            minTempLabel.text = tempInCelcius(text: minTempLabel.text)
            metricLabel.text = "CELCIUS"
            tempViewLeadingConstraint.constant = 40
        }
    }
    @IBAction func searchTapped(_ sender: Any) {
        if citiesData.count != 0 {
            if let searchLocationViewController = storyboard?.instantiateViewController(withIdentifier: "SearchLocationViewController") as? SearchLocationViewController {
                searchLocationViewController.modalPresentationStyle = .overCurrentContext
                self.present(searchLocationViewController, animated: false, completion: nil)
            }
        }
    }
    @IBAction func addToFavTapped(_ sender: Any) {
        let button = sender as! UIButton
        if isPresentedFromCurrentLocationVC {
            let alertController = UIAlertController(title: "Removed from Favourites", message:
                                                        "\(viewModel.cityData?.city ?? "") \(viewModel.cityData?.country ?? "")",
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alertController, animated: true, completion: nil)
            
            let deletedCityName = viewModel.cityData!.city
            let savedCities = realmObject.objects(SavedCities.self).filter("cityName = '\(deletedCityName)'")
            let vc = self.presentingViewController as! CurrentLocationViewController
            vc.savedCities = vc.savedCities.filter { $0.city != deletedCityName }
            let lat = Int(Double(viewModel.cityData!.lat)!)
            let lon = Int(Double(viewModel.cityData!.lon)!)
            vc.savedCitiesData = vc.savedCitiesData.filter{ Int($0.lat) != lat && Int($0.lon) != lon }
            vc.cityCollectionView.reloadData()
            if savedCities.count > 0 {
                for city in savedCities {
                    try! realmObject.write {
                        realmObject.delete(city)
                    }
                }
            }
        } else {
            let savedCity = SavedCities()
            let vc = self.presentingViewController?.presentingViewController as! CurrentLocationViewController
            savedCity.cityName = viewModel.cityData?.city
            savedCity.lat = viewModel.cityData?.lat
            savedCity.lon = viewModel.cityData?.lon
            let newCity = (city: viewModel.cityData!.city,
                           country: "",
                           lat: viewModel.cityData!.lat,
                           lon: viewModel.cityData!.lon)
            
            if vc.savedCities.contains(where: { $0 == newCity }) {
                let alertController = UIAlertController(title: "Already added to Favourites", message:
                                                            "\(viewModel.cityData?.city ?? "") \(viewModel.cityData?.country ?? "")",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(alertController, animated: true, completion: nil)
            } else {
                try! realmObject.write {
                    realmObject.add(savedCity)
                }
                let alertController = UIAlertController(title: "Added to Favourites", message:
                                                            "\(viewModel.cityData?.city ?? "") \(viewModel.cityData?.country ?? "")",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default))
                self.present(alertController, animated: true, completion: nil)
                vc.savedCities.append(newCity)
                let temp = viewModel.weatherData?.current.temp.getTempInCelcius()
                let id = viewModel.weatherData?.current.weather.first?.id
                let lat = viewModel.weatherData?.lat
                let lon = viewModel.weatherData?.lon
                vc.savedCitiesData.append((temprature: temp!,
                                           id: id!,
                                           lat: lat!,
                                           lon: lon!))
                vc.cityCollectionView.reloadData()
            }
        }
        button.isEnabled = false
    }
    @IBAction func infoButtonTapped(_ sender: Any) {
        if let aboutVC = storyboard?
            .instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController {
            aboutVC.modalPresentationStyle = .fullScreen
            self.present(aboutVC, animated: true, completion: nil)
        }
    }
    
}

// MARK: - UICollectionView
extension CurrentLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case daysCollectionview:
            return (viewModel.weatherData?.daily.count ?? 1)/2
        case cityCollectionView:
            if savedCities.count == 0 {
                return 1
            } else {
                return savedCities.count
            }
        case hourlyCollectionView:
            return viewModel.hourlyCellModels.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == daysCollectionview {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayWeatherCollectionViewCell", for: indexPath) as? DayWeatherCollectionViewCell else { return UICollectionViewCell() }
            if viewModel.weeklyCellModels.count > 0 {
                cell.viewModel = viewModel.weeklyCellModels[indexPath.row]
            }
            cell.contentView.backgroundColor = .clear
            return cell
        }
        if collectionView == cityCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CityCollectionViewCell", for: indexPath) as? CityCollectionViewCell else { return UICollectionViewCell() }
            if savedCities.count == 0 {
                cell.addMoreCitiesView.isHidden = false
            } else {
                cell.addMoreCitiesView.isHidden = true
                if savedCities.count == savedCitiesData.count {
                    cell.cityName.text = savedCities[indexPath.row].city
                    cell.temprature.text = savedCitiesData[indexPath.row].temprature
                    let id = savedCitiesData[indexPath.row].id
                    cell.weatherImage.image = getPNGFromCurrentWeatherID(id: id)
                }
            }
            return cell
        }
        if collectionView == hourlyCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourlyWeatherCollectionViewCell", for: indexPath) as? HourlyWeatherCollectionViewCell else { return UICollectionViewCell() }
            cell.viewModel = viewModel.hourlyCellModels[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == daysCollectionview {
            return CGSize(width: daysCollectionview.frame.width, height: 100)
        } else if collectionView == cityCollectionView {
            return CGSize(width: 200, height: 100)
        } else if collectionView == hourlyCollectionView {
            return CGSize(width: 40, height: 100)
        } else {
            return CGSize.zero
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                   withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == daysCollectionview {
            let selectedIndex_ = Int(round(targetContentOffset.pointee.x/daysCollectionview.frame.size.width))
            daysCollectionview.scrollToItem(at: IndexPath(item: selectedIndex_, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == daysCollectionview {
            for cell in daysCollectionview.visibleCells {
                currentIndexPath = daysCollectionview.indexPath(for: cell)!
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == daysCollectionview {
            return 0
        } else if collectionView == cityCollectionView {
            return 20
        } else if collectionView == hourlyCollectionView {
            return 10
        } else {
            return 0
        }
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView == cityCollectionView  {
            if savedCities.count != 0 {
                let cityData = savedCities[indexPath.row]
                guard let currentLocationViewController = storyboard?.instantiateViewController(withIdentifier: "CurrentLocationViewController") as? CurrentLocationViewController else { return }
                currentLocationViewController.viewModel = CurrentLocationViewModel(cityData: cityData)
                if screenHeight < 700 {
                    currentLocationViewController.modalPresentationStyle = .fullScreen
                }
                currentLocationViewController.isPresentedFromCurrentLocationVC = true
                self.present(currentLocationViewController, animated: true, completion: nil)
            } else {
                if citiesData.count != 0 {
                    if let searchLocationViewController = storyboard?.instantiateViewController(withIdentifier: "SearchLocationViewController") as? SearchLocationViewController {
                        searchLocationViewController.modalPresentationStyle = .overCurrentContext
                        self.present(searchLocationViewController, animated: false, completion: nil)
                    }
                }
            }
        }
    }
}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    func getCurrentLocationWeather() {
        guard let currentLocation = locManager.location
        else { return }
        let lat = Double(currentLocation.coordinate.latitude)
        let lon = Double(currentLocation.coordinate.longitude)
        getcurrentCityDataWithLatAndLon(lat: lat, lon: lon)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            getCurrentLocationWeather()
        } else if status == .denied || status == .restricted {
            showAllowLocationPopup()
        }
    }
}

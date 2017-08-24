//
//  ViewController.swift
//  LocationWithoutLocation
//
//  Created by Mugunth Kumar on 24/8/17.
//  Copyright © 2017 Steinlogic. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreLocation
import MapKit

class ViewController: UIViewController, MKAnnotation, MKMapViewDelegate {

  var coordinate: CLLocationCoordinate2D {
    return location!.coordinate
  }

  @IBOutlet weak var mapView: MKMapView!
  var location: CLLocation?

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    showLocationOnMaps()
  }

  // MARK:- Main Function
  func showLocationOnMaps() {
    guard let address = macAddressOfRouter else {
      let alertController = UIAlertController(title: NSLocalizedString("Mac Address Not Found", comment: ""),
                                              message: NSLocalizedString("If you are not connected to WiFi, open control center, connect to WiFi and tap on Retry", comment: ""),
                                              preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: { _ in

      }))
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default, handler: { [weak self] _ in
        self?.showLocationOnMaps()
      }))
      present(alertController, animated: true, completion: nil)
      return
    }

    guard let url = urlForAddress(address: address) else { return }

    fetchLocationFromURL(url: url) {[weak self] location, error in
      guard let ws = self else { return }
      ws.location = location
      ws.mapView.addAnnotation(ws)
      ws.mapView.setCenter(location!.coordinate, animated: true)
      let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      let region = MKCoordinateRegion(center: location!.coordinate, span: span)
      DispatchQueue.main.async {
        ws.mapView.setRegion(region, animated: true)
      }
    }
  }

  // MARK:- Helpers
  var macAddressOfRouter: String? {
    let supportedInterfaces: NSArray? = CNCopySupportedInterfaces()
    guard let interfaces = supportedInterfaces else { return nil }
    let connectedInterface = interfaces.firstObject as! CFString
    let connectedInterfaceInfo: NSDictionary? = CNCopyCurrentNetworkInfo(connectedInterface)
    guard let info = connectedInterfaceInfo else { return nil }
    return info["BSSID"] as? String
  }

  func urlForAddress(address: String) -> URL? {
    var components = URLComponents(string: "https://api.mylnikov.org/geolocation/wifi")
    components?.queryItems = [URLQueryItem(name: "v", value: "1.1"),
                              //URLQueryItem(name: "data", value: "open"),
      URLQueryItem(name: "bssid", value: address)]
    return components?.url
  }

  func fetchLocationFromURL(url: URL, handler: ((CLLocation?, Error?) -> Void)?) {
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      if let data = data {
        let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        guard let dataDictionary = ((jsonObject as! [String: Any])["data"] as? [String: Any]) else { return }
        if let latitude = dataDictionary["lat"] as? CLLocationDegrees, let longitude = dataDictionary["lon"] as? CLLocationDegrees {
          let location = CLLocation(latitude: latitude, longitude: longitude)
          handler?(location, nil)
        } else {
          handler?(nil, nil)
        }
      } else {
        // API Failed
        handler?(nil, error)
      }
      }.resume()
  }

  // MARK:- Map View Delegates
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "LocationPin") as? MKPinAnnotationView
    if annotationView == nil {
      annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "LocationPin")
      annotationView!.canShowCallout = true
      annotationView!.animatesDrop = true
    }
    return annotationView
  }
}


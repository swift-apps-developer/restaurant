//
//  ShipmentTableViewController.swift
//  restaurant
//
//  Created by love on 6/22/19.
//  Copyright © 2019 love. All rights reserved.
//

import UIKit
import MapKit

class ShipmentTableViewController: UITableViewController, MKMapViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var address: Address?
    
    let restaurantAnnotation = AddressAnnotation(title: "Restaurant", subtitle: "We are awesome", coordinate: CLLocationCoordinate2D(latitude: 51.507229, longitude: -0.127953))
    
    var customerLocation: CLLocationCoordinate2D?
    
    let regionRadius: CLLocationDistance = 1000
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initiateLocation(location: self.restaurantAnnotation.coordinate)
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.revealLocation(sender:)))
        self.mapView.addGestureRecognizer(gesture)
        
        self.mapView.delegate = self
        
        self.addAnnotation(for: restaurantAnnotation)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.updateUI()
    }
    
    func updateUI() {
        if let address = self.address {
            self.titleTextField.text = address.title
            self.fullNameTextField.text = address.fullName
            self.phoneNumberTextField.text = address.phoneNumber
            self.addressTextField.text = address.address
            self.customerLocation = CLLocationCoordinate2D(latitude: address.latitude, longitude: address.longitude)
            
            self.showRouteOnMap(pickupCoordinate: self.restaurantAnnotation.coordinate, destinationCoordinate: CLLocationCoordinate2D(latitude: (self.address?.latitude)!, longitude: (self.address?.longitude)!))
        }
    }

    func checkValidation() -> Address? {
        let addressTitle = self.titleTextField.text ?? ""
        let addressFullName = self.fullNameTextField.text ?? ""
        let addressPhoneNumber = self.phoneNumberTextField.text ?? ""
        let addressLine = self.addressTextField.text ?? ""
        
        var errorMessages = ""
        
        if addressTitle.isEmpty {
            errorMessages += "Title is required\n"
        }
        
        if addressFullName.isEmpty {
            errorMessages += "Full name is required\n"
        }
        
        if addressPhoneNumber.isEmpty {
            errorMessages += "Phone number is required\n"
        }
        
        if addressLine.isEmpty {
            errorMessages += "Address is required\n"
        }
        
        if self.customerLocation == nil {
            errorMessages += "Please mark your location on the map"
        }
        
        if !errorMessages.isEmpty {
            let alert = UIAlertController(title: "Validation Error", message: errorMessages, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
            return nil
        } else {
            
            let address = Address(title: addressTitle, fullName: addressFullName, phoneNumber: addressPhoneNumber, address: addressLine, longitude: (self.customerLocation?.longitude)!, latitude: (self.customerLocation?.latitude)!)
            
            if let addr = self.address {
                address.id = addr.id
            }
            
            return address
        }
        
    }

    @IBAction func saveAddressTapped(_ sender: UIBarButtonItem) {
        guard let address = self.checkValidation() else {return}
        MenuService.shared.saveAddress(with: address)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func revealLocation(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: self.mapView)
        let locationCoordinate = self.mapView.convert(touchLocation, toCoordinateFrom: self.mapView)
        
        let addressAnnotation = AddressAnnotation(title: self.titleTextField.text ?? "New Address", subtitle: self.addressTextField.text ?? "", coordinate: CLLocationCoordinate2D(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude))

        self.customerLocation = addressAnnotation.coordinate
        self.showRouteOnMap(pickupCoordinate: self.restaurantAnnotation.coordinate, destinationCoordinate: addressAnnotation.coordinate)
    }
    
    func addAnnotation(for addressAnnotation: AddressAnnotation) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(addressAnnotation)
    }
    
    func initiateLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegion(center: location, latitudinalMeters: self.regionRadius, longitudinalMeters: self.regionRadius)
        
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.removeOverlays(self.mapView.overlays)
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .any
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

            var rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
            if let first = self.mapView.overlays.first {
                rect = self.mapView.overlays.reduce(first.boundingMapRect, {$0.union($1.boundingMapRect)})
                self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0), animated: true)
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(hexString: "#303C6C")
        renderer.lineWidth = 4.0
        
        return renderer
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

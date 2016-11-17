//
//  PhotoMapViewController.swift
//  Photo Map
//
//  Created by Nicholas Aiwazian on 10/15/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class PhotoMapViewController: UIViewController {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var selectedImage: UIImage?
    var editedImage: UIImage?
    var newLocationWasSet: Bool = false
    var newCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //one degree of latitude is approximately 111 kilometers (69 miles) at all times.
        let sfRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.783333, -122.416667),
                                              MKCoordinateSpanMake(0.1, 0.1))
        mapView.setRegion(sfRegion, animated: false)
        mapView.delegate = self
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if newLocationWasSet {
            
            
            let annotation = PhotoAnnotation()
            annotation.coordinate = newCoordinate!
            annotation.photo = self.selectedImage
            mapView.addAnnotation(annotation)
            
        
            newLocationWasSet = false
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let segueId = segue.identifier {
            
            if segueId == "TagSegue" {
                
                let destVc = segue.destination as! LocationsViewController
                destVc.delegate = self
                
            }
            else if segueId == "FullImageSegue" {
                let destVc = segue.destination as! FullImageViewController
                let image = sender as! UIImage
                destVc.fullImage = image
            }
        }
    }
    

    @IBAction func cameraButtonPressed(_ sender: AnyObject) {
        
        dlog("")
        
        if Platform.isSimulator {
            showPhotoLibrary()
        }
        else {
            showCamera()
        }
        
    }
    
    
    
    func showCamera() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = .camera
        
        self.present(vc, animated: true, completion: {
            dlog("")
        })
    }
    
    func showPhotoLibrary() {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = .photoLibrary
        
        self.present(vc, animated: true, completion: {
            dlog("show complete")
        })
    }

    
}

extension PhotoMapViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let editedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        
        self.selectedImage = originalImage
        self.editedImage = editedImage
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dlog("self.selectedImage: \(self.selectedImage)")
        dismiss(animated: true, completion: {
            
            self.performSegue(withIdentifier: "TagSegue", sender: self)
            
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dlog("")
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        dlog("vc: \(viewController)")
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        dlog("vc: \(viewController)")

    }
}

extension PhotoMapViewController: LocationsViewControllerDelegate {
    func locationsPickedLocation(controller: LocationsViewController, latitude: NSNumber, longitude: NSNumber) {
     
        dlog("lat: \(latitude), lon: \(longitude)")
        
        
        let locationCoordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
        
        self.newLocationWasSet = true
        self.newCoordinate = locationCoordinate
        
        let _ = self.navigationController?.popToViewController(self, animated: true)

    }
}

class PhotoAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var photo: UIImage!
    
    var title: String? {
        return "\(coordinate.latitude)"
    }
    
    var subtitle: String? {
        return "\(coordinate.longitude)"
    }
    
    override var description: String {
        return (title ?? "notitle") + "," + (subtitle ?? "nosubtitle")
    }
}

extension PhotoMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        dlog("")
        let reuseID = "myAnnotationView"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView!.leftCalloutAccessoryView = UIImageView(frame: CGRect(x:0, y:0, width:50, height:50))
            annotationView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        }
        
        let imageView = annotationView?.leftCalloutAccessoryView as! UIImageView
        
        let resizeRenderImageView = UIImageView(frame: CGRect(x:0, y:0, width:45, height:45))
        resizeRenderImageView.layer.borderColor = UIColor.white.cgColor
        resizeRenderImageView.layer.borderWidth = 3.0
        resizeRenderImageView.contentMode = .scaleAspectFill
        resizeRenderImageView.image = (annotation as? PhotoAnnotation)?.photo
        
        UIGraphicsBeginImageContext(resizeRenderImageView.frame.size)
        resizeRenderImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imageView.image = thumbnail
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        dlog("detail clicked")
        
        if let annotation = view.annotation as? PhotoAnnotation {
            let image = annotation.photo
            
            self.performSegue(withIdentifier: "FullImageSegue", sender: image)
            
        }
        
    }
}

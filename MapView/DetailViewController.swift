//
//  DetailViewController.swift
//  MapView - miniproject
//
//  Created by Ruslan Yelguldinov on 27.07.2024.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailPicturesCV.dataSource = self
        detailPicturesCV.delegate = self
        previewMapView.delegate = self
        CVlayout()
        addAnnotation()
        
    }
    
    var resort: Resort!
    
    @IBOutlet weak var detailPicturesCV: UICollectionView!
    @IBOutlet weak var previewMapView: MKMapView!
    
    @IBAction func openFullMapBtn(_ sender: Any) {
//        let vc = storyboard?.instantiateViewController(withIdentifier: "MapViewVC") as? UIViewController
//        navigationController?.pushViewController(vc!, animated: true)
        let listVC = storyboard?.instantiateViewController(withIdentifier: "ListTV") as? ListTableViewController
        guard let mapViewVC = storyboard?.instantiateViewController(withIdentifier: "MapViewVC") as? MapViewViewController else {
            return
        }
        
        mapViewVC.resorts = listVC!.resortsArray
        mapViewVC.selectedResort = self.resort
        
        navigationController?.pushViewController(mapViewVC, animated: true)
    }
    
    var posterImageArray = [UIImage.resort1, UIImage.resort2, UIImage.resort3, UIImage.resort4, UIImage.resort5]
    
    // MARK: CollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return posterImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "detailPicturesCell", for: indexPath)
        
        let detailPictures = cell.viewWithTag(201) as? UIImageView
        detailPictures?.image = posterImageArray[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    func CVlayout() {
        if let layout = detailPicturesCV.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.minimumLineSpacing = 0
                layout.minimumInteritemSpacing = 0
            }
    }
    
    func addAnnotation() {
        guard let resort = resort else { return }
        
        let resortCoordinate = CLLocationCoordinate2D(latitude: resort.latitude, longitude: resort.longitude)
        
        // Настройте аннотацию
        let annotation = MKPointAnnotation()
        annotation.coordinate = resortCoordinate
        annotation.title = resort.name
        previewMapView.addAnnotation(annotation)
        
        // Установите регион карты с увеличением
        let region = MKCoordinateRegion(center: resortCoordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        previewMapView.setRegion(region, animated: true)
    }
    
    // MARK: - MKMapViewDelegate
      
      func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
          let identifier = "ResortAnnotation"
          
          if annotation is MKPointAnnotation {
              var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
              
              if annotationView == nil {
                  annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                  annotationView?.canShowCallout = true
              } else {
                  annotationView?.annotation = annotation
              }
              
//              annotationView?.image = UIImage.housePointer
              let customImage = UIImage.housePointer
              let resizedImage = resizeImage(image: customImage, targetSize: CGSize(width: 50, height: 50))
              annotationView?.image = resizedImage
              
              return annotationView
          }
          
          return nil
      }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
            let size = image.size
            
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            
            // Определяем какой из двух соотношений меньше
            let newSize: CGSize
            if(widthRatio > heightRatio) {
                newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            } else {
                newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
            }
            
            // Сжимаем изображение до нового размера, сохраняя соотношение сторон
            let rect = CGRect(origin: .zero, size: newSize)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            image.draw(in: rect)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage!
        }
    
    
    
}

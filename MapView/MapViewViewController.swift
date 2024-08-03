//
//  ViewController.swift
//  MapView
//
//  Created by Ruslan Yelguldinov on 20.07.2024.
//

import UIKit
import MapKit

class MapViewViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        fullMapView.delegate = self
        addAnnotation()
        
        if let selectedResort = selectedResort {
            focusOnResort(resort: selectedResort)
//            setupFlightRoute()
        }
        
        // Настраиваем долгое нажатие - добавляем новые метки на карту
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction))
        // минимально 2 секунды
        longPress.minimumPressDuration = 2
        fullMapView.addGestureRecognizer(longPress)
        
        // MKMapViewDelegate - чтоб отслеживать нажатие на метки на карте (метод didSelect)
        fullMapView.delegate = self

    }
    
    var resorts: [Resort] = []
    var selectedResort: Resort!
    
    @IBOutlet weak var fullMapView: MKMapView!
    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations[0]
        print(userLocation)
    }
    
    func focusOnResort(resort: Resort) {
           let resortCoordinate = CLLocationCoordinate2D(latitude: resort.latitude, longitude: resort.longitude)
           let region = MKCoordinateRegion(center: resortCoordinate, latitudinalMeters: 5500, longitudinalMeters: 5500)
           fullMapView.setRegion(region, animated: true)
       }
    
    func addAnnotation() {
        
        for resort in resorts {
            let resortCoordinate = CLLocationCoordinate2D(latitude: resort.latitude, longitude: resort.longitude)
            
            // Настройте аннотацию
            let annotation = MKPointAnnotation()
            annotation.coordinate = resortCoordinate
            annotation.title = resort.name
            fullMapView.addAnnotation(annotation)
            
            // Установите регион карты с увеличением
            let region = MKCoordinateRegion(center: resortCoordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
            fullMapView.setRegion(region, animated: true)
        }
        
    }
    // MARK: present BottomSheet
    func presentSheet() {
        let sheetViewController = storyboard?.instantiateViewController(withIdentifier: "BottomSheet") as? BottomSheetViewController
        
        sheetViewController!.modalPresentationStyle = .pageSheet
        
        if let sheet = sheetViewController?.sheetPresentationController {
            let customDetent = UISheetPresentationController.Detent.custom { _ in
                return 150
            }
            sheet.detents = [customDetent]
            sheet.largestUndimmedDetentIdentifier = customDetent.identifier
            
        }
        sheetViewController?.presentationController?.delegate = self
        present(sheetViewController!, animated: true, completion: nil)
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
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        presentSheet()
    }
    // MARK: Add route
    // Вызывается когда нажали на метку на карте
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        print(view.annotation?.title)
        
        // Получаем координаты метки
        let location:CLLocation = CLLocation(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        
        // Считаем растояние до метки от нашего пользователя
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = " "
        formatter.locale = Locale.current
        
        let meters:CLLocationDistance = location.distance(from: userLocation)
        if meters > 1000 {
            let kilometers = meters / 1000
            if let formattedDistance = formatter.string(from: NSNumber(value: kilometers)) {
                distanceLabel.text = "Distance: \(formattedDistance) km"
            }
        } else {
            if let formattedDistance = formatter.string(from: NSNumber(value: meters)) {
                distanceLabel.text = "Distance: \(formattedDistance) m"
            }
        }
        
        // Routing - построение маршрута
        // 1 Координаты начальной точки А и точки B
        let sourceLocation = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        
        let destinationLocation = CLLocationCoordinate2D(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!)
        
        // 2 упаковка в Placemark
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // 3 упаковка в MapItem
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // 4 Запрос на построение маршрута
        let directionRequest = MKDirections.Request()
        // указываем точку А, то есть нашего пользователя
        directionRequest.source = sourceMapItem
        // указываем точку B, то есть метку на карте
        directionRequest.destination = destinationMapItem
        // выбираем на чем будем ехать - на машине
        directionRequest.transportType = .any
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 5 Запускаем просчет маршрута
        directions.calculate {
            (response, error) -> Void in
            
            // Если будет ошибка с маршрутом
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            // Берем первый машрут
            let route = response.routes[0]
            // Рисуем на карте линию маршрута (polyline)
            self.fullMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            // Приближаем карту с анимацией в регион всего маршрута
            let rect = route.polyline.boundingMapRect
            self.fullMapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Настраиваем линию
        let renderer = MKPolylineRenderer(overlay: overlay)
        // Цвет красный
        renderer.strokeColor = UIColor.red
        // Ширина линии
        renderer.lineWidth = 4.0
        
        return renderer
    }
    // MARK: Add custom annotation by long press
    @objc func longPressAction(gestureRecognizer: UIGestureRecognizer) {
        print("gestureRecognizer")
        
        // Получаем точку нажатия на экране
        let touchPoint = gestureRecognizer.location(in: fullMapView)
        
        // Конвертируем точку нажатия на экране в координаты пользователя
        let newCoor: CLLocationCoordinate2D = fullMapView.convert(touchPoint, toCoordinateFrom: fullMapView)
        
        // Создаем метку на карте
        let anotation = MKPointAnnotation()
        anotation.coordinate = newCoor
        
        anotation.title = "Title"
        anotation.subtitle = "subtitle"
        
        fullMapView.addAnnotation(anotation)
    }
    
    /*
    func setupFlightRoute() {
        guard let selectedResort = selectedResort else { return }
        
        let currentLocation = fullMapView.userLocation.coordinate
        let resortCoordinate = CLLocationCoordinate2D(latitude: selectedResort.latitude, longitude: selectedResort.longitude)
        
        // Создаем маршрут вручную
        var coordinates = [currentLocation, resortCoordinate]
        let polyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        fullMapView.addOverlay(polyline, level: .aboveRoads)
    }
    */
    
    
}

// Реализуем делегат, чтобы убрать затемнение
extension MapViewViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationController(_ controller: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
        controller.presentedView?.superview?.subviews.first?.backgroundColor = .clear
    }
    
}

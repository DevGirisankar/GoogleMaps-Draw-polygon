//
//  ViewController.swift
//  GMSMap Draw Polyline
//
//  Created by Giri on 25/10/21.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController {
    var swiped = false
    var lastPoint : CGPoint = .zero {
        didSet {
            arrayPoints.append(lastPoint)
        }
    }
    var lineWidth: CGFloat = 2.0
    var opacity: CGFloat = 1.0
    var arrayPoints = [CGPoint]()
    let polygonRect = GMSMutablePath()
    var isDrawing : Bool = false {
        didSet {
            drawView.isHidden = !isDrawing
            drawButton.isSelected = isDrawing
        }
    }
    @IBOutlet weak var drawButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var drawView: UIView!
    @IBOutlet weak var tempImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
//MARK: - button action
    @IBAction func drawAction(_ sender: Any) {
        isDrawing = !isDrawing
    }
    //MARK:- drawing started
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = false
        arrayPoints.removeAll()
        if let touch = touches.first {
            lastPoint = touch.location(in: self.view)
        }
      }

    func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
        
        UIGraphicsBeginImageContext(view.frame.size)
        let context = UIGraphicsGetCurrentContext()
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        
        context?.move(to: CGPoint.init(x: fromPoint.x, y: fromPoint.y))
        context?.addLine(to: CGPoint.init(x: toPoint.x, y: toPoint.y))
        
        context?.setLineCap(.round)
        context?.setLineWidth(lineWidth)
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setBlendMode(.normal)
        
        guard let context = context else {return}
        context.strokePath()
        
        tempImageView.image = UIGraphicsGetImageFromCurrentImageContext()
        tempImageView.alpha = opacity
        UIGraphicsEndImageContext()
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        swiped = true
        if let touch = touches.first {
             let currentPoint = touch.location(in: view)
             drawLineFrom(fromPoint: lastPoint, toPoint: currentPoint)
           lastPoint = currentPoint
         }
    }
    //MARK:- drawing ended
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !swiped {
          // draw a single point
            drawLineFrom(fromPoint: lastPoint, toPoint: lastPoint)
        }
        tempImageView.image?.draw(in: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), blendMode: .normal, alpha: opacity)
        UIGraphicsEndImageContext()
        tempImageView.image = nil
        convertPointsToCoordinates()
        isDrawing = false
      }
// MARK:- convert CGPoints to Coordinates
    func convertPointsToCoordinates() {
        polygonRect.removeAllCoordinates()
        guard !arrayPoints.isEmpty else {return}
        for touchPoint in arrayPoints {
            let coordinate = mapView.projection.coordinate(for: touchPoint)
            polygonRect.add(coordinate)
        }
        drawPolygons()
    }
    //MAR:- draw Polygons
    func drawPolygons() {
        mapView.clear()
        let polygon = GMSPolygon()
        polygon.geodesic = true
        polygon.path = polygonRect
        polygon.fillColor = #colorLiteral(red: 0.9474907517, green: 0.2350950539, blue: 0.1785519123, alpha: 0.24)
        polygon.strokeColor = UIColor.gray
        polygon.strokeWidth = 1
        polygon.map = mapView
        markCenter()
    }
    //MAR:- add marker in center 
    func markCenter() {
        let center =  arrayPoints.center
        let coordinate = mapView.projection.coordinate(for: center)
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        location.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }
            print(placemark.postalAddressFormatted ?? "")
            DispatchQueue.main.async { [self] in
                let position = coordinate
                let marker = GMSMarker(position: position)
                marker.title = placemark.postalAddressFormatted ?? ""
                marker.map = mapView
            }
        }
    }
}


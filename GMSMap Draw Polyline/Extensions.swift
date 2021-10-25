//
//  helper.swift
//  GMSMap Draw Polyline
//
//  Created by Giri on 25/10/21.
//

import Foundation
import MapKit
import Contacts

// Get location from lat long 
extension CLPlacemark {
    var streetName: String? { thoroughfare }
    var streetNumber: String? { subThoroughfare }
    var city: String? { locality }
    var neighborhood: String? { subLocality }
    var state: String? { administrativeArea }
    var county: String? { subAdministrativeArea }
    var zipCode: String? { postalCode }
    
    var postalAddressFormatted: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter().string(from: postalAddress)
    }
}
extension CLLocation {
    func placemark(completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first, $1) }
    }
}

// To find center of cgpoints
extension Array where Element == CGPoint {
    var center: CGPoint {
        let nr = self.count
        var centerX: CGFloat = 0
        var centerY: CGFloat = 0
        var area = signedPolygonArea
        for i in 0 ..< nr {
            let j = (i + 1) % nr
            let factor1 = self[i].x * self[j].y - self[j].x * self[i].y
            centerX = centerX + (self[i].x + self[j].x) * factor1
            centerY = centerY + (self[i].y + self[j].y) * factor1
        }
        area = area * 6.0
        let factor2 = 1.0/area
        centerX = centerX * factor2
        centerY = centerY * factor2
        let center = CGPoint.init(x: centerX, y: centerY)
        return center
    }
    var signedPolygonArea : CGFloat {
        let nr = self.count
        var area: CGFloat = 0
        for i in 0 ..< nr {
            let j = (i + 1) % nr
            area = area + self[i].x * self[j].y
            area = area - self[i].y * self[j].x
        }
        area = area/2.0
        return area
    }
}

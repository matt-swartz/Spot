//
//  PinRedirectView.swift
//  Spot
//
//  Created by Jin Kim on 11/16/21.
//

import UIKit
import MapKit

class PinRedirectView: MKPinAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = true
        rightCalloutAccessoryView = UIButton(type: .infoLight)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

class EventAnnotation : MKPointAnnotation {
    var event: ReportEvent?
}

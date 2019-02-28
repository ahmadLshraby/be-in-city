//
//  Constants.swift
//  be-in-city
//
//  Created by sHiKoOo on 2/20/19.
//  Copyright © 2019 sHiKoOo. All rights reserved.
//

import Foundation

let apiKey = "30e623e2eaf002f0c5bbe9f25e498791"
let flickrURL = "https://api.flickr.com/services/rest/"
let photoUrl = "https://farm8.staticflickr.com/7810/46423835904_a414e8bafd_c_d.jpg"  // to handle the json from getUrl


let annotationId = "droppablePin"
let cellId = "photoCell"

/*
 https:api.flickr.com/services/rest/?method=flickr.photos.search&api_key=2d635d6b6ee6f903b87e445d9e7f7814&lat=42.8&lon=122.3&radius=1&radius_units=mi&per_page=40&format=json&nojsoncallback=1
 */

func flickrUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumbersOfPhotos number: Int) -> String {
    
    let url = " https:api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    return url
}

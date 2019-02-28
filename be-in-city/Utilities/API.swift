//
//  API.swift
//  be-in-city
//
//  Created by sHiKoOo on 2/20/19.
//  Copyright © 2019 sHiKoOo. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class API: NSObject {
    static let instance = API()
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    
    
    func getUrl(forAnnotation annotation: DroppablePin, handler: @escaping(_ success: Bool) -> Void) {
        imageUrlArray = []  // make it empty to be ready to hold Urls when drop a pin
        
        let params: [String: Any] = [
            "method": "flickr.photos.search",
            "api_key": apiKey,
            "lat": annotation.coordinate.latitude,
            "lon": annotation.coordinate.longitude,
            "radius": "1",
            "radius_units": "mi",
            "per_page": "40",
            "format": "json",
            "nojsoncallback": "1"
        ]
        
        Alamofire.request(flickrURL, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            print(response)
            
            guard let json = response.result.value as? Dictionary<String, Any> else { return }
            let photosDict = json["photos"] as! Dictionary<String, Any>
            let photosDictArray = photosDict["photo"] as! [Dictionary<String, Any>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_c_d.jpg"
                self.imageUrlArray.append(postUrl)
                print(postUrl)
            }
            handler(true)
        }
    }
    
    func getImages(forProgressLbl progressLbl: UILabel, handler: @escaping(_ success: Bool) -> Void) {
        imageArray = []    // make it empty to be ready to hold images from urls when drop a pin
        
        for url in imageUrlArray {
            Alamofire.request(url).responseImage { (response) in
                
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                // to update the progress label
                progressLbl.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                // check that the downloaded images = urls of images then return the handler
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            }
        }
    }
    
    // when swipe down the view it stills downloading data , so we must cancel all sessions when animateDown func
    // and also when dropping a new pin
    func cancelAllSession() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({ $0.cancel()})   // $0 instead of for loop in array ... for task in sessionDataTask  ..   task.cancel()
            downloadData.forEach({ $0.cancel()})
        }
    }
    
}

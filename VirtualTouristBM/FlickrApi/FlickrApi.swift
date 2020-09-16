//
//  FlikrApi.swift
//  VirtualTourist
//
//  Created by Henry Mungalsingh on 08/09/2020.
//  Copyright © 2020 Spared. All rights reserved.
//

import Foundation
class FlickrApi {
    
    static var apiKey = "0ed186377948756ca211aff936ee6341"
    static var method = "flickr.photos.search"
    static var contentType = 1
    static var radius = 10
    static var format = "json&nojsoncallback=1"
    static var searchRange = 10
    static var perPage = 20
    static var pages: Int? = 1

    static let flickrEndpoint = "https://api.flickr.com/services/rest/?"

    class func getPhotos(latitude: Double, longitude: Double, completion: @escaping (PhotoResponse?, Error?) -> Void) {

        let randomInt = Int.random(in: 0..<pages!)
        
        let flickrURL: URL = URL(string: "\(flickrEndpoint)method=\(method)&api_key=\(apiKey)&lat=\(latitude)&lon=\(longitude)&radius=\(radius)&searchRange=\(searchRange)&per_page=\(perPage)&page=\(randomInt)&format=\(format)")!
        
        var request = URLRequest(url: flickrURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                completion(nil, error)
                }
                return
            }
            do {
//                print(String(data: data, encoding: .utf8)!)
                let decoder = JSONDecoder()
                let response = try decoder.decode(PhotoResponse.self, from: data)
                DispatchQueue.main.async {
//                print(response)
                    completion(response, nil)
                }
            } catch {
                DispatchQueue.main.async {
                completion(nil, error)
                print(error)
                }
            }
        }
        task.resume()
    }
    
    
    class func downloadPhotos(photoUrl: String, completion: @escaping (Data, Error?)-> Void) {
        
        
        let task = URLSession.shared.dataTask(with: URL(string: photoUrl)!) { data, response, error in
            if let data = data{
                DispatchQueue.main.async {
                    completion(data, error)
                }
            }else{
                print(error!.localizedDescription)
            }
        }
        task.resume()
    }
    
}

//
//  PhotoResponse.swift
//  VirtualTourist
//
//  Created by Henry Mungalsingh on 08/09/2020.
//  Copyright © 2020 Spared. All rights reserved.
//

import Foundation
struct PhotoResponse: Codable {

    let photos:Photos
    let stat:String
}

struct Photos:Codable {
    let page:Int
    let pages:Int
    let perpage:Int
    let total:String
    let photo:[Photo]
}

struct Photo:Codable {
    let id:String
    let owner:String
    let secret:String
    let server:String
    let farm:Int
    let title:String
    let ispublic:Int
    let isfriend:Int
    let isfamily:Int
}

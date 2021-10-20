//
//  PexelItems.swift
//  
//
//  Created by LuanLing on 6/23/21.
//

import Foundation

struct PexelItems:Decodable {
    let page:Int?
    let per_page:Int?
    let photos:[PexelPhoto]?
}

struct PexelPhoto:Decodable{
    let avg_color:String?
    let height:Int?
    let id:Int?
    let liked:Bool?
    let photographer:String?
    let photographer_id:Int?
    let photographer_url:String?
    let src:PexelPhotoSrc?
    let url:String?
    let width:Int?
}

struct PexelPhotoSrc:Decodable{
    let original:String?
    let large2X:String?
    let large:String?
    let medium:String?
    let small:String?
    let potrait:String?
    let landscape:String?
    let tiny:String?
}

/*
 data structure
 
 {
          "id":7362886,
          "width":6511,
          "height":4341,
          "url":"https://www.pexels.com/photo/a-person-checking-the-gps-on-the-cellphone-7362886/",
          "photographer":"RODNAE Productions",
          "photographer_url":"https://www.pexels.com/@rodnae-prod",
          "photographer_id":3149039,
          "avg_color":"#506067",
          "src":{
             "original":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg",
             "large2x":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg?auto=compress\u0026cs=tinysrgb\u0026dpr=2\u0026h=650\u0026w=940",
             "large":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg?auto=compress\u0026cs=tinysrgb\u0026h=650\u0026w=940",
             "medium":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg?auto=compress\u0026cs=tinysrgb\u0026h=350",
             "small":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg?auto=compress\u0026cs=tinysrgb\u0026h=130",
             "portrait":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg?auto=compress\u0026cs=tinysrgb\u0026fit=crop\u0026h=1200\u0026w=800",
             "landscape":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg?auto=compress\u0026cs=tinysrgb\u0026fit=crop\u0026h=627\u0026w=1200",
             "tiny":"https://images.pexels.com/photos/7362886/pexels-photo-7362886.jpeg?auto=compress\u0026cs=tinysrgb\u0026dpr=1\u0026fit=crop\u0026h=200\u0026w=280"
          },
          "liked":false
       }
 */

//
//  AppleLocation.swift
//  ZXPLocationUtils
//
//  Created by quickplain on 2017/12/20.
//  Copyright © 2017年 quickplain. All rights reserved.
//

import UIKit
import CoreLocation

public class AppleLocation: NSObject, CLLocationManagerDelegate {
    
    public static let sharedInstance = AppleLocation()
    
    var locManager: CLLocationManager = CLLocationManager()
    
    public var latitude: Double?
    public var longitude: Double?
    
    typealias appleLocationDate = (_ text: String) -> ()
    var block: appleLocationDate?
    
//    override init() {
//        super.init()
//        initLocationManager()
//    }
    
    /*
     定位服务管理类CLLocationManager的desiredAccuracy属性表示精准度，有如下6种选择：
     kCLLocationAccuracyBestForNavigation ：精度最高，一般用于导航
     kCLLocationAccuracyBest ： 精确度最佳
     kCLLocationAccuracyNearestTenMeters ：精确度10m以内
     kCLLocationAccuracyHundredMeters ：精确度100m以内
     kCLLocationAccuracyKilometer ：精确度1000m以内
     kCLLocationAccuracyThreeKilometers ：精确度3000m以内
     */
    public func initLocationManager() {
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locManager.distanceFilter = 100 ///设备移动后获得位置信息的最小距离
        locManager.requestWhenInUseAuthorization() ///只在前台开启定位 弹出用户授权对话框，使用程序期间授权（ios8后)
//        requestAlwaysAuthorization//始终授权
//        locManager.allowsBackgroundLocationUpdates = true
        if CLLocationManager.locationServicesEnabled() {
           //允许使用定位服务的话，开启定位服务更新
           locManager.startUpdatingLocation()
        }
    }
    
    ///停止定位
    public func stopLocation() {
        locManager.stopUpdatingLocation()
    }
    
    //委托传回定位，获取最后一个
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //获取最新的坐标
        let currLocation:CLLocation = locations.last!
        print("=====================")
        print("经度：\(currLocation.coordinate.longitude)")
        print("纬度：\(currLocation.coordinate.latitude)")
        print("海拔：\(currLocation.altitude)")
        print("水平精度：\(currLocation.horizontalAccuracy)")
        print("垂直精度：\(currLocation.verticalAccuracy)")
        print("方向：\(currLocation.course)")
        print("速度：\(currLocation.speed)")
        print("=====================")
        
        latitude = currLocation.coordinate.latitude
        longitude = currLocation.coordinate.longitude
        
        self.checkCurrentCity(currLocation)
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位出错拉！！\(error)")
    }
   
    public func checkCurrentCity(_ location: CLLocation) {
        let coder = CLGeocoder()
        coder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            if let placemark = placemarks?.last {
                print("=====================")
                print("地名 == \(String(describing: placemark.name))")
                print("街道 == \(String(describing: placemark.thoroughfare))")
                print("门牌 == \(String(describing: placemark.subThoroughfare))")
                print("区划 == \(String(describing: placemark.subLocality))")
                print("其他行政区域信息（自治区等） == \(String(describing: placemark.subAdministrativeArea))")
                print("邮编 == \(String(describing: placemark.postalCode))")
                print("国家编码 == \(String(describing: placemark.isoCountryCode))")
                print("国家 == \(String(describing: placemark.country))")
                print("海洋 == \(String(describing: placemark.ocean))")
                print("水源，湖泊 == \(String(describing: placemark.inlandWater))")
                print("关联的或利益相关的地标 == \(String(describing: placemark.areasOfInterest))")
                print("城市 == \(String(describing: placemark.locality))")
                print("省份 == \(String(describing: placemark.administrativeArea))")
                print("=====================")
            }
        })
    }
    
    ///两点距离
    public func distanceLocation(currentLocation:CLLocation,targetLocation:CLLocation) -> String {
        let distance = currentLocation.distance(from: targetLocation) as Double
        let dis = NSNumber(value: distance as Double).intValue
        return distanceString(dis)
    }
    
    ///距离自己
    public func userDistanceLocation(_ location:CLLocation) -> String {
        if latitude != nil && longitude != nil {
            let currentLocation = CLLocation(latitude: latitude!, longitude: longitude!)
            let distance = currentLocation.distance(from: location) as Double
            let dis = NSNumber(value: distance as Double).intValue
            return distanceString(dis)
        } else {
            return "定位失败"
        }
    }
    
//    func haveLoacation() -> Bool {
//        if latitude == nil || longitude == nil {
//            updateCurrentLocation()
//            return false
//        } else if latitude > 0 && longitude > 0 {
//            return true
//        } else {
//            return true
//        }
//    }

    fileprivate let units = ["m", "km"]
    
    public func distanceString(_ distance: Int) -> String {
        var distance = distance
        var unitIndex = 0
        if distance > 1000 {
            distance = Int(distance / 1000)
            unitIndex += 1
        }
        if distance > 10000 && unitIndex == 1 {
            print("距离较远 --> \(distance)\(units[unitIndex])")
            return "距离较远"
        }
        return "\(distance)\(units[unitIndex])"
    }
}

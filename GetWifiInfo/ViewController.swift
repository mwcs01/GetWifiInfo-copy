//
//  ViewController.swift
//  GetWifiInfo
//


import UIKit
//import Foundation
import SystemConfiguration.CaptiveNetwork
//import NetworkExtension


class ViewController: UIViewController {
    
    @IBOutlet weak var ssidLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func getSSID() -> String? {
        guard let interface = (CNCopySupportedInterfaces() as? [String])?.first,
            let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interface as CFString) as? [String: Any],
            let ssid = unsafeInterfaceData["SSID"] as? String else{
                return nil
        }
        return ssid
    }
    
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        return address
    }
    
    func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                }
            }
        }
        return ssid
    }
    
    func getSSIDtwo() -> String? {
        let interfaces = CNCopySupportedInterfaces()
        if interfaces == nil {
            //print("Not interfaces")
            return nil
        }
        
        let interfacesArray = interfaces as! [String]
        if interfacesArray.count <= 0 {
            return nil
        }
        let interfaceName = interfacesArray[0] as String
        let unsafeInterfaceData = CNCopyCurrentNetworkInfo(interfaceName as CFString)
        if unsafeInterfaceData == nil {
            return nil
        }
        
        let interfaceData = unsafeInterfaceData as! Dictionary <String,AnyObject>
        return interfaceData["SSID"] as? String
    }
    
    @IBAction func onButtonClick(_ sender: Any) {
        let one = getWiFiSsid();
        let two = getSSIDtwo();
        let three = getSSID();
        ssidLabel.text = one!
        let ip = getWiFiAddress()
        print(ip!)
        print(one!);
        print(two!);
        print(three!);
    }
    
}

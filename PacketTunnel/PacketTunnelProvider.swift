//
//  PacketTunnelProvider.swift
//  PacketTunnel
//
//  Created by admin on 08.05.2026.
//

import NetworkExtension
import SwiftyXrayKit
import OSLog

class PacketTunnelProvider: NEPacketTunnelProvider {
    
    enum PacketTunnelError: Error {
        case defaultError
    }
    
    var xrayClient: XRayTunnel?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PacketTunnel")

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        logger.error("START TUNNEL CALLED")
        
        setTunnelNetworkSettings(getNetworkSettings()) { error in
          guard error == nil else {
              completionHandler(error)
              return
          }
          
          self.startXrayAndSocksProxy(completionHandler)
        }
    }
    
    private func startXrayAndSocksProxy(_ completion: ((Error?)->Void)? = nil) {
      // Path to GeoIP database files (used for routing decisions)
      let geoIpPath = FileManager.default.documentDirectory
      
      // Path to the XRay configuration file
      //let configPath = FileManager.default.documentDirectory.appending(path: "config.json")
      
      // Initialize XRay tunnel with the packet flow from Network Extension
      xrayClient = XRayTunnel(packetFlow: packetFlow)
      
      // Start XRay asynchronously
      Task {
        do {
          // Read the configuration file content
            let config = self.config // try String(contentsOf: configPath, encoding: .utf8)
          
          // Path where the final processed configuration will be saved
          let finalPath = FileManager.default.documentDirectory.appending(path: "config_final.json")
          
          // Start the XRay tunnel with the configuration
          try await xrayClient?.run(dataDir: geoIpPath, config: .json(config), finalConfigPath: finalPath)
          
          // Notify success
          completion?(nil)
        } catch {
          NSLog("error: \(error)")
          // Notify failure
          completion?(error)
        }
      }
    }
    
    //MARK: - Stopping tunnel
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        self.stopTunnel(completionHandler: completionHandler)
    }
    
    private func stopTunnel(completionHandler: @escaping () -> Void) {
      Task {
        // Stop the XRay client gracefully
        await xrayClient?.stop()
        
        // Notify that tunnel has been stopped
        completionHandler()
      }
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    let config = """
        {
          "policy" : {
            "system" : {
              "statsOutboundUplink" : true,
              "statsInboundUplink" : true,
              "statsOutboundDownlink" : true,
              "statsInboundDownlink" : true
            }
          },
          "log" : {
            "loglevel" : "info"
          },
          "outbounds" : [
            {
              "settings" : {
                "address" : "nl3.divpn.ru",
                "port" : 8443,
                "id" : "e8484ce1-10e6-4f89-b106-7ec3cfa111e0",
                "encryption" : "none"
              },
              "protocol" : "vless",
              "streamSettings" : {
                "security" : "reality",
                "network" : "tcp",
                "realitySettings" : {
                  "fingerprint" : "chrome",
                  "publicKey" : "To7Qw__tr0hy1V9-OeMfN_jCcY4pkvA1iOFydCNhzzY",
                  "shortId" : "f5166b9511a02e07",
                  "serverName" : "speed.cloudflare.com",
                  "spiderX" : ""
                },
                "tcpSettings" : {
                  "header" : {
                    "type" : "none"
                  }
                }
              },
              "tag" : "proxy"
            },
            {
              "protocol" : "blackhole",
              "settings" : {
                "response" : {
                  "type" : "none"
                }
              },
              "tag" : "block"
            },
            {
              "settings" : {

              },
              "protocol" : "freedom",
              "tag" : "direct"
            }
          ],
          "inbounds" : [
            {
              "settings" : {
                "udp" : true
              },
              "listen" : "[::1]",
              "protocol" : "socks",
              "port" : 1080,
              "sniffing" : {
                "destOverride" : [
                  "quic",
                  "http",
                  "tls"
                ],
                "routeOnly" : false,
                "enabled" : true
              },
              "tag" : "socks"
            }
          ],
          "id" : "4642BAA6-E9A8-497F-8D35-AB9DD389B3E3",
          "stats" : {

          },
          "remarks" : "divpn"
        }
        """
    
    //MARK: - Subnets
    
    let kVpnSubnetCandidates: [String: String] = [
      "10": "10.111.222.0",
      "172": "172.16.9.1",
      "192": "192.168.20.1",
      "169": "169.254.19.0"
    ]
    
    let kExcludedSubnets = [
      "10.0.0.0/8",
      "100.64.0.0/10",
      "169.254.0.0/16",
      "172.16.0.0/12",
      "192.0.0.0/24",
      "192.0.2.0/24",
      "192.31.196.0/24",
      "192.52.193.0/24",
      "192.88.99.0/24",
      "192.168.0.0/16",
      "192.175.48.0/24",
      "198.18.0.0/15",
      "198.51.100.0/24",
      "203.0.113.0/24",
      "240.0.0.0/4",
      "85.193.84.172/32",
      "91.108.4.0/22",
      "91.108.8.0/21",
      "91.105.192.0/23"
    ]
}

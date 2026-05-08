//
//  PacketTunnelProvider+Configure.swift
//  DiVPN
//
//  Created by admin on 08.05.2026.
//

import NetworkExtension

extension PacketTunnelProvider {
    func getNetworkSettings() -> NEPacketTunnelNetworkSettings {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "::")
        let vpnAddress = selectVpnAddress(interfaceAddresses: getNetworkInterfaceAddresses())
        let ipv4Settings = NEIPv4Settings(addresses: [vpnAddress], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        ipv4Settings.excludedRoutes = getExcludedIpv4Routes()
        settings.ipv4Settings = ipv4Settings
        settings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8"])
        return settings
    }
    
    private func getNetworkInterfaceAddresses() -> [String] {
      var interfaces: UnsafeMutablePointer<ifaddrs>?
      var addresses = [String]()
      
      guard getifaddrs(&interfaces) == 0 else {
        return addresses
      }
      
      var interface = interfaces
      while interface != nil {
        // Only consider IPv4 interfaces.
        if interface!.pointee.ifa_addr.pointee.sa_family == UInt8(AF_INET) {
          let addr = interface!.pointee.ifa_addr!.withMemoryRebound(to: sockaddr_in.self, capacity: 1) { $0.pointee.sin_addr }
          if let ip = String(cString: inet_ntoa(addr), encoding: .utf8) {
            addresses.append(ip)
          }
        }
        interface = interface!.pointee.ifa_next
      }
      
      freeifaddrs(interfaces)
      
      return addresses
    }
    
    private func selectVpnAddress(interfaceAddresses: [String]) -> String {
      var candidates = kVpnSubnetCandidates
      
      for address in interfaceAddresses {
        for subnetPrefix in kVpnSubnetCandidates.keys {
          if address.hasPrefix(subnetPrefix) {
            // The subnet (not necessarily the address) is in use, remove it from our list.
            candidates.removeValue(forKey: subnetPrefix)
          }
        }
      }
      guard !candidates.isEmpty else {
        // Even though there is an interface bound to the subnet candidates, the collision probability
        // with an actual address is low.
        return kVpnSubnetCandidates.randomElement()!.value
      }
      // Select a random subnet from the remaining candidates.
      return candidates.randomElement()!.value
    }
    
    private func getExcludedIpv4Routes() -> [NEIPv4Route] {
      var excludedIpv4Routes = [NEIPv4Route]()
      for cidrSubnet in kExcludedSubnets {
        if let subnet = Subnet.parse(cidrSubnet) {
          let route = NEIPv4Route(destinationAddress: subnet.address, subnetMask: subnet.mask)
          excludedIpv4Routes.append(route)
        }
      }
      return excludedIpv4Routes
    }
}

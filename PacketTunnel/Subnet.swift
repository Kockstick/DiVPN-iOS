//
//  Subnet.swift
//  XrayTest
//
//  Created by Diesperov Konstantin on 20.03.2026.
//

import Foundation

class Subnet: NSObject {
  // Parses a CIDR subnet into a Subnet object. Returns nil on failure.
  public static func parse(_ cidrSubnet: String) -> Subnet? {
    let components = cidrSubnet.components(separatedBy: "/")
    guard components.count == 2 else {
      NSLog("Malformed CIDR subnet")
      return nil
    }
    guard let prefix = UInt16(components[1]) else {
      NSLog("Invalid subnet prefix")
      return nil
    }
    return Subnet(address: components[0], prefix: prefix)
  }

  public var address: String
  public var prefix: UInt16
  public var mask: String

  public init(address: String, prefix: UInt16) {
    self.address = address
    self.prefix = prefix
    let mask = (0xffffffff as UInt32) << (32 - prefix);
    self.mask = mask.IPv4String()
  }
}

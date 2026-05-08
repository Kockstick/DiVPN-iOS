//
//  UInt32Extension.swift
//  XrayTest
//
//  Created by Diesperov Konstantin on 20.03.2026.
//

extension UInt32 {
  // Returns string representation of the integer as an IP address.
  public func IPv4String() -> String {
    let ip = self
    let a = UInt8((ip>>24) & 0xff)
    let b = UInt8((ip>>16) & 0xff)
    let c = UInt8((ip>>8) & 0xff)
    let d = UInt8(ip & 0xff)
    return "\(a).\(b).\(c).\(d)"
  }
}

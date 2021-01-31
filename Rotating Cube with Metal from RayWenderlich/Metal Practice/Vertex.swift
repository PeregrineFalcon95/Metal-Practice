//
//  Vertex.swift
//  Metal Practice
//
//  Created by Mac mini on 29/1/21.
//

import Foundation
struct Vertex{

  var x,y,z: Float     // position data
  var r,g,b,a: Float   // color data

  func floatBuffer() -> [Float] {
    return [x,y,z,r,g,b,a]
  }

}

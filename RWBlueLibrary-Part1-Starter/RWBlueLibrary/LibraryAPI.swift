//
//  LibraryAPI.swift
//  RWBlueLibrary
//
//  Created by Yang Ricardo  on 12/04/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation

final class LibraryAPI {
  // 1 The shared static constant approach gives other objects access to the singleton object LibraryAPI.
  static let shared = LibraryAPI()
  
  // 2 The private initializer prevents creating new instances of LibraryAPI from outside.
  private init() {
    
  }
}

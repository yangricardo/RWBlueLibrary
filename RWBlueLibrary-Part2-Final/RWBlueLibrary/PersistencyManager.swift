/*
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import UIKit

final class PersistencyManager {
  private var albums = [Album]()
  
  init() {
    let savedURL = documents.appendingPathComponent(Filenames.Albums)
    var data = try? Data(contentsOf: savedURL)
    if data == nil, let bundleURL = Bundle.main.url(forResource: Filenames.Albums, withExtension: nil) {
      data = try? Data(contentsOf: bundleURL)
    }

    if let albumData = data,
      let decodedAlbums = try? JSONDecoder().decode([Album].self, from: albumData) {
      albums = decodedAlbums
      saveAlbums()
    }
  }
  
  func getAlbums() -> [Album] {
    return albums
  }
  
  func addAlbum(_ album: Album, at index: Int) {
    if (albums.count >= index) {
      albums.insert(album, at: index)
    } else {
      albums.append(album)
    }
  }
  
  func deleteAlbum(at index: Int) {
    albums.remove(at: index)
  }
  
  private var cache: URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
  }
  
  
  func saveImage(_ image: UIImage, filename: String) {
    let url = cache.appendingPathComponent(filename)
    guard let data = UIImagePNGRepresentation(image) else {
      return
    }
    try? data.write(to: url, options: [])
  }

  func getImage(with filename: String) -> UIImage? {
    let url = cache.appendingPathComponent(filename)
    guard let data = try? Data(contentsOf: url) else {
      return nil
    }
    return UIImage(data: data)
  }
  
  private var documents: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
  private enum Filenames {
    static let Albums = "albums.json"
  }
  func saveAlbums() {
    let url = documents.appendingPathComponent(Filenames.Albums)
    let encoder = JSONEncoder()
    guard let encodedData = try? encoder.encode(albums) else {
      return
    }
    try? encodedData.write(to: url)
  }
  
}

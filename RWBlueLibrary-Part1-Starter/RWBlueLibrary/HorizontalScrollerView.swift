//
//  HorizontalScrollerView.swift
//  RWBlueLibrary
//
//  Created by Yang Ricardo  on 12/04/2018.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

class HorizontalScrollerView: UIView {
  weak var dataSource: HorizontalScrollerViewDataSource?
  weak var delegate: HorizontalScrollerViewDelegate?
  
  // 1 Define a private enum to make it easy to modify the layout at design time. The view’s dimensions inside the scroller will be 100 x 100 with a 10 point margin from its enclosing rectangle.
  private enum ViewConstants {
    static let Padding: CGFloat = 10
    static let Dimensions: CGFloat = 100
    static let Offset: CGFloat = 100
  }
  
  // 2 Create the scroll view containing the views.
  private let scroller = UIScrollView()
  
  // 3 Create an array that holds all the album covers.
  private var contentViews = [UIView]()
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollView()
  }
  
  func initializeScrollView() {
    scroller.delegate = self
    
    //1 Adds the UIScrollView instance to the parent view.
    addSubview(scroller)
    
    //2 Turn off autoresizing masks. This is so you can apply your own constraints
    scroller.translatesAutoresizingMaskIntoConstraints = false
    
    //3 Apply constraints to the scrollview. You want the scroll view to completely fill the HorizontalScrollerView
    NSLayoutConstraint.activate([
      scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scroller.topAnchor.constraint(equalTo: self.topAnchor),
      scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ])
    
    //4 Create a tap gesture recognizer. The tap gesture recognizer detects touches on the scroll view and checks if an album cover has been tapped. If so, it will notify the HorizontalScrollerView delegate. You’ll have a compiler error here because the tap method isn’t implemented yet, you’ll be doing that shortly.
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gesture:)))
    scroller.addGestureRecognizer(tapRecognizer)
  }
  
  // This method retrieves the view for a specific index and centers it
  func scrollToView(at index: Int, animated: Bool = true) {
    let centralView = contentViews[index]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
  }
  
  // This method finds the location of the tap in the scroll view, then the index of the first content view that contains that location, if any.
  @objc func scrollerTapped(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: scroller)
    guard
      let index = contentViews.index(where: { $0.frame.contains(location)})
      else { return }
    
    delegate?.horizontalScrollerView(self, didSelectViewAt: index)
    scrollToView(at: index)
  }
  
  func view(at index :Int) -> UIView {
    return contentViews[index]
  }
  
  func reload() {
    // 1 - Check if there is a data source, if not there is nothing to load.
    guard let dataSource = dataSource else {
      return
    }
    
    //2 - Remove the old content views
    contentViews.forEach { $0.removeFromSuperview() }
    
    // 3 - xValue is the starting point of each view inside the scroller
    var xValue = ViewConstants.Offset
    // 4 - Fetch and add the new views
    contentViews = (0..<dataSource.numberOfViews(in: self)).map {
      index in
      // 5 - add a view at the right position
      xValue += ViewConstants.Padding
      let view = dataSource.horizontalScrollerView(self, viewAt: index)
      view.frame = CGRect(x: CGFloat(xValue), y: ViewConstants.Padding, width: ViewConstants.Dimensions, height: ViewConstants.Dimensions)
      scroller.addSubview(view)
      xValue += ViewConstants.Dimensions + ViewConstants.Padding
      return view
    }
    // 6 Once all the views are in place, set the content offset for the scroll view to allow the user to scroll through all the albums covers.
    scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
  }
  
  private func centerCurrentView() {
    let centerRect = CGRect(
      origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding, y: 0),
      size: CGSize(width: ViewConstants.Padding, height: bounds.height)
    )
    
    guard let selectedIndex = contentViews.index(where: { $0.frame.intersects(centerRect) })
      else { return }
    let centralView = contentViews[selectedIndex]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    delegate?.horizontalScrollerView(self, didSelectViewAt: selectedIndex)
  }
  
  
}

extension HorizontalScrollerView: UIScrollViewDelegate {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
}

protocol HorizontalScrollerViewDataSource: class {
  // Ask the data source how many views it wants to present inside the horizontal scroller
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
  // Ask the data source to return the view that should appear at <index>
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView
}

protocol HorizontalScrollerViewDelegate: class {
  // inform the delegate that the view at <index> has been selected
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int)
}

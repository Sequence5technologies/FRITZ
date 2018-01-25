import Foundation
import UIKit

class BoundingBox {
  let shapeLayer: CAShapeLayer

  init() {
    shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = UIColor.black.cgColor
    shapeLayer.lineWidth = 4
    shapeLayer.isHidden = true
  }

  func addToLayer(_ parent: CALayer) {
    parent.addSublayer(shapeLayer)
  }

  func show(frame: CGRect, label: String, color: UIColor, textColor: UIColor = .black) {
    CATransaction.setDisableActions(true)

    let path = UIBezierPath(rect: frame)
    shapeLayer.path = path.cgPath
    shapeLayer.isHidden = false
  }

  func hide() {
    shapeLayer.isHidden = true
  }
}

import Foundation
import UIKit

class BoundingBoxUtils {
  let blurEffectView : UIVisualEffectView

  init() {
    let blurEffect = UIBlurEffect(style: .light)
    blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.isHidden = true
  }

  func addToLayer(_ view: UIView) {
    view.addSubview(blurEffectView)
  }

  func show(frame: CGRect, label: String, color: UIColor, textColor: UIColor = .black) {
    CATransaction.setDisableActions(true)

    let path = UIBezierPath(rect: frame)
    blurEffectView.frame = path.cgPath.boundingBox
    blurEffectView.isHidden = false
  }

  func hide() {
    blurEffectView.isHidden = true
  }
}

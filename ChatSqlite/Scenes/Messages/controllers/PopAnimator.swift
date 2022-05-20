//
//  PopAnimator.swift
//  ChatSqlite
//
//  Created by LAP11353 on 05/05/2022.
//

import UIKit

protocol PopAnimatableViewController {
    func getView() -> UIView
    func getAnimatableView() -> UIView
    func animatableViewRect() -> CGRect
    func getWindow() -> UIWindow?
    func getSourceSnapshot() -> UIView?
}

class PopAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    init?(presenting: Bool,
          firstVC: PopAnimatableViewController,
          secondVC: PopAnimatableViewController) {
        self.presenting = presenting
        self.firstVC = firstVC
        self.secondVC = secondVC
        self.cellSnapshot = firstVC.getSourceSnapshot()
        guard let win = firstVC.getWindow() ?? secondVC.getWindow() else {
            return nil
        }
        self.sourceRect = firstVC.getAnimatableView().convert(firstVC.getAnimatableView().bounds, to: win)
        
    }
    
    
    let duration = 0.25
    var presenting = true
    
    var firstVC : PopAnimatableViewController
    var secondVC : PopAnimatableViewController
    
    var cellSnapshot : UIView!
    var sourceRect : CGRect
    
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let toView = secondVC.getView()
        
        containerView.addSubview(toView)
        toView.alpha = 0 // transparent toView
        
        guard let window = firstVC.getWindow() ?? secondVC.getWindow(),
              let cellsubSnapshot = firstVC.getAnimatableView().snapshotView(afterScreenUpdates: true),
              let viewSnapshot = secondVC.getAnimatableView().snapshotView(afterScreenUpdates: true) else {
                  transitionContext.completeTransition(true)
                  return
              }
        let backgroundView : UIView
        let fadeView = UIView(frame: containerView.bounds)
        fadeView.backgroundColor = secondVC.getView().backgroundColor
        
        if presenting {
            cellSnapshot = cellsubSnapshot
            backgroundView = UIView(frame: containerView.bounds)
            backgroundView.addSubview(fadeView)
            fadeView.alpha = 0
        } else {
            backgroundView = firstVC.getView().snapshotView(afterScreenUpdates: true) ?? fadeView
//            fadeView.alpha = 1
            backgroundView.addSubview(fadeView)
        }
        
        [backgroundView,cellSnapshot, viewSnapshot].forEach { containerView.addSubview($0)}
        containerView.layoutIfNeeded()
        
        let tosubView = secondVC.getAnimatableView()
        
        let viewRect = tosubView.convert(tosubView.bounds, to: window)
        let trueImagevViewRect = trueFullsize(thumbRect: sourceRect, fullsizeRect: viewRect)
        
        
        let isPresenting = presenting
        
        // Starting Frame
        viewSnapshot.frame = isPresenting ? self.sourceRect : viewRect
        self.cellSnapshot.frame = isPresenting ? self.sourceRect : trueImagevViewRect
        viewSnapshot.alpha = isPresenting ? 0 : 1
        cellSnapshot.alpha = isPresenting ? 1 : 0

        UIView.animateKeyframes(withDuration: duration, delay: 0, options: [.calculationModeCubic], animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1){
                // Ending Frame
                viewSnapshot.frame = isPresenting ? viewRect :self.sourceRect
                self.cellSnapshot.frame = isPresenting ? trueImagevViewRect : self.sourceRect
                fadeView.alpha = isPresenting ? 1 : 0
            }
                // fade animation
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6){
                viewSnapshot.alpha = isPresenting ? 1 : 0
                self.cellSnapshot.alpha = isPresenting ? 0 : 1
            }
            
        }, completion: { _ in
            self.cellSnapshot.removeFromSuperview()
            viewSnapshot.removeFromSuperview()
            backgroundView.removeFromSuperview()
            toView.alpha = 1
            transitionContext.completeTransition(true)
        })
        
    }
    
    func trueFullsize(thumbRect : CGRect, fullsizeRect: CGRect) -> CGRect{
        let scalefactor = fullsizeRect.width / thumbRect.width
        let w = thumbRect.width * scalefactor
        let h = thumbRect.height * scalefactor
//        let x : CGFloat = fullsizeRect.midX - w / 2
        let x : CGFloat = 0
        let y : CGFloat = fullsizeRect.midY - h / 2
        let updated = CGRect(x: x, y: y, width: w, height: h)
        print("before: \(thumbRect)")
        print("scale: \(scalefactor)")
        print("after: \(updated)")

        return updated
    }

}

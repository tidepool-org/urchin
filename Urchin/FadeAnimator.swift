//
//  FadeAnimator.swift
//  urchin
//
//  Created by Ethan Look on 7/22/15.
//  Copyright (c) 2015 Tidepool. All rights reserved.
//

import UIKit

class FadeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
   
    let duration = 0.5
    var presenting = true
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView()
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        containerView!.addSubview(toViewController!.view)
        
        toViewController!.view.alpha = 0.0
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            toViewController!.view.alpha = 1.0
            }) { (completed) -> Void in
                if (completed) {
                    transitionContext.completeTransition(true)
                }
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
}

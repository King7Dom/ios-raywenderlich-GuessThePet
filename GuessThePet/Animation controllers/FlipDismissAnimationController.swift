//
//  FlipDismissAnimationController.swift
//  GuessThePet
//
//  Created by Dominic Cheung on 23/05/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class FlipDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var destinationFrame = CGRect.zero
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.6
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // The transitioning context will provide the view controllers and views participating in the transition.
        guard let containerView = transitionContext.containerView(),
            // Use the appropriate keys to obtain ViewControllers.
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        // Specify the final frame for the “to” view.
        let finalFrame = destinationFrame
        
        // UIView snapshotting captures the CURRENT “from” view and renders it into a lightweight view
        // This lets you animate the view together with its hierarchy.
        let snapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
        snapshot.layer.cornerRadius = 25
        snapshot.layer.masksToBounds = true
        
        // Setup animatedViews on containerView
        // containerView is where all the transition should occur.
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        // We hide the fromVC.view to avoid conflict with snapshot
        fromVC.view.hidden = true
        
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        toVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
        
        /**
         You need the duration of your animations to match up with the duration you’ve declared for the whole transition
         so UIKit can keep things in sync. Hence the usage of transitionDuration(_:)
         */
        let duration = transitionDuration(transitionContext)
        
        UIView.animateKeyframesWithDuration(
            duration, delay: 0, options: .CalculationModeCubic,
            animations: {
                // Scale the frame of the screenshot to the final frame
                UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 1/3, animations: { 
                    snapshot.frame = finalFrame
                })
                // Rotate the snapshot half way from the y-axis to hide it from view
                UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: { 
                    snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
                })
                // Rotate the final view into the final position
                UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: { 
                    toVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                })
            },
            completion: { _ in
                // Safe to reveal the real "from" view
                fromVC.view.hidden = false
                // Remove the snapshot since it’s no longer useful.
                snapshot.removeFromSuperview()
                // Calling completeTransition informs the transitioning context that the animation is complete.
                // UIKit will ensure the final state is consistent and remove the “from” view from the container.
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        )
    }
}

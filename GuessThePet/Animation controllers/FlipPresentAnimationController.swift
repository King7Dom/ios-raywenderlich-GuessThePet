//
//  FlipPresentAnimationController.swift
//  GuessThePet
//
//  Created by Dominic Cheung on 23/05/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class FlipPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    var originFrame = CGRect.zero
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 2.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // The transitioning context will provide the view controllers and views participating in the transition.
        guard let containerView = transitionContext.containerView(),
            // Use the appropriate keys to obtain ViewControllers.
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) else {
                return
        }
        
        // Specify the starting and final frames for the “to” view.
        // In this case, the transition starts from the card’s frame and scales to fill the whole screen.
        let initialFrame = originFrame
        let finalFrame = transitionContext.finalFrameForViewController(toVC)
        
        // UIView snapshotting captures the CURRENT “to” view and renders it into a lightweight view
        // This lets you animate the view together with its hierarchy.
        // The snapshot’s frame starts off as the card’s frame. You also modify the corner radius to match the card.
        let snapshot = toVC.view.snapshotViewAfterScreenUpdates(true)
        snapshot.frame = initialFrame
        snapshot.layer.cornerRadius = 25
        snapshot.layer.masksToBounds = true
        
        // Setup animatedViews on containerView
        // containerView is where all the transition should occur.
        // It contains the fromVC.view already, we just need to add the toVC.view, hidden for now until transition complete
        containerView.addSubview(toVC.view)
        // We want to add the snapshot because this view is used for the transition,
        // toVC.view is the final result view snapshot should rotate out of view and hide from user
        containerView.addSubview(snapshot)
        toVC.view.hidden = true
        
        // Adding perspective and rotation transforms to views
        AnimationHelper.perspectiveTransformForContainerView(containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(M_PI_2)
        
        /**
         You need the duration of your animations to match up with the duration you’ve declared for the whole transition
         so UIKit can keep things in sync. Hence the usage of transitionDuration(_:)
         */ 
        let duration = transitionDuration(transitionContext)
        
        UIView.animateKeyframesWithDuration(
            duration, delay: 0, options: .CalculationModeCubic,
            animations: {
                // Start by rotating the “from” view halfway around its y-axis to hide it from view.
                UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 1/3, animations: {
                    fromVC.view.layer.transform = AnimationHelper.yRotation(-M_PI_2)
                })
                // Reveal the snapshot using the same technique.
                UIView.addKeyframeWithRelativeStartTime(1/3, relativeDuration: 1/3, animations: {
                    snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                })
                // Set the frame of the snapshot to fill the screen.
                UIView.addKeyframeWithRelativeStartTime(2/3, relativeDuration: 1/3, animations: {
                    snapshot.frame = finalFrame
                })
            },
            completion: { _ in
                // Safe to reveal the real “to” view.
                toVC.view.hidden = false
                // Rotate the “from” view back in place; otherwise, it would hidden when transitioning back.
                fromVC.view.layer.transform = AnimationHelper.yRotation(0.0)
                // Remove the snapshot since it’s no longer useful.
                snapshot.removeFromSuperview()
                // Calling completeTransition informs the transitioning context that the animation is complete.
                // UIKit will ensure the final state is consistent and remove the “from” view from the container.
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            }
        )
    }
    
}

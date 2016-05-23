//
//  SwipeInteractionController.swift
//  GuessThePet
//
//  Created by Dominic's Macbook Pro on 23/05/2016.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {

     /// indicates whether an interaction in already in progress.
    var interactionInProgress = false

    private var shouldCompleteTransition = false
    /// interaction controller directly presents and dismisses view controllers, so you hold onto the current view controller in viewController.
    private weak var viewController: UIViewController!

    func wireToViewController(viewController: UIViewController) {
        self.viewController = viewController
        prepareGestureRecognizerInView(viewController.view)
    }

    func handleGesture(gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        // Record the translation in the view and calculate the progress.
        // A Swipe of 200 points will lead to 100% completion, so you use this number to measure the transition’s progress.
        let translation = gestureRecognizer.translationInView(gestureRecognizer.view?.superview)
        var progress = (translation.x / 200)
        // Keep progress within value of 0 and 1
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))

        switch gestureRecognizer.state {
        case .Began:
            // Adjust interactionInProgress accordingly and trigger the dismissal of the view controller.
            interactionInProgress = true
            viewController.dismissViewControllerAnimated(true, completion: nil)

        case .Changed:
            // Determine if the transition should complete when gesture ends
            shouldCompleteTransition = progress > 0.5
            // Continuously call updateInteractiveTransition with the progress amount.
            updateInteractiveTransition(progress)

        case .Cancelled:
            // Update interactionInProgress and roll back the transition.
            interactionInProgress = false
            cancelInteractiveTransition()

        case .Ended:
            interactionInProgress = false

            // Use the current progress of the transition to decide whether to cancel it or finish it for the user.
            if shouldCompleteTransition {
                finishInteractiveTransition()
            } else {
                cancelInteractiveTransition()
            }

        default:
            print("Unsupported")
        }
    }

    /**
     Set up a gesture recognizer in its view.
     
     This will setup the given view with a left edge UIScreenEdgePanGestureRecognizer that triggers handleGesture(_:)

     - parameter view: UIView to be configured
     */
    private func prepareGestureRecognizerInView(view: UIView) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        gesture.edges = .Left
        view.addGestureRecognizer(gesture)
    }
}

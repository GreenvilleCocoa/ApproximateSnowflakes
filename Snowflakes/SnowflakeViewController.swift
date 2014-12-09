//
//  ViewController.swift
//  Snowflakes
//
//  Created by Austin Younts on 12/8/14.
//  Copyright (c) 2014 Greenville Cocoaheads. All rights reserved.
//

import UIKit

class SnowflakeViewController: UIViewController {

    let snowflakeMinSize = 10.0
    let snowflakeMaxSize = 35.0
    let maxAnimationDuration = 15.0
    var snowflakeSizeRange: Double {
        get {
            return snowflakeMaxSize - snowflakeMinSize
        }
    }
    
    let maxSnowflakes = 100
    var snowFlakes: [SnowflakeView] = []
    var snowFlakeTimer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let image = UIImage(named: "winter-wallpaper-22")
        let imageView = UIImageView(image: image)
        
        imageView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        imageView.frame = view.bounds
        imageView.contentMode = .ScaleAspectFill
        
        self.view.insertSubview(imageView, atIndex: 0)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        startSnowing()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        stopSnowing()
    }

    func startSnowing() {
        snowFlakeTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "addSnowflake:", userInfo: nil, repeats: true)
    }
    
    func stopSnowing() {
        snowFlakeTimer?.invalidate()
        snowFlakeTimer = nil
    }
    
    func addSnowflake(sender: NSTimer) {
        if (snowFlakes.count > maxSnowflakes) {
            return
        }
        
        let snowflake = createSnowflake()
        
        self.view.addSubview(snowflake)
        
        snowFlakes.append(snowflake)
        startAnimationForSnowflake(snowflake)
        
    }
    
    func snowflakeRect() -> CGRect {
        let x = arc4random_uniform(UInt32(CGRectGetWidth(view.bounds)))
        let size = Double(arc4random_uniform(UInt32(snowflakeSizeRange))) + snowflakeMinSize
        let y = -Int32(size)
        
        return CGRectMake(CGFloat(x), CGFloat(y), CGFloat(size), CGFloat(size))
    }
    
    func createSnowflake() -> SnowflakeView {
        return SnowflakeView(frame: snowflakeRect())
    }
    
    func animationFactorForSnowflake(snowflake: SnowflakeView) -> Double {
        let size = Double(snowflake.bounds.size.width) + snowflakeMinSize
        return 1.0 / Double(arc4random_uniform(6))
    }
    
    func durationForSnowflake(snowflake: SnowflakeView) -> NSTimeInterval {
        return maxAnimationDuration * animationFactorForSnowflake(snowflake)
    }
    
    func animationsForSnowflake(snowflake: SnowflakeView) -> () -> Void {
        return {
            var frame = snowflake.frame
            frame.origin.y = CGRectGetHeight(self.view.bounds)
            snowflake.frame = frame
        }
    }
    
    func completionForSnowflake(snowflake: SnowflakeView) -> (Bool) -> Void {
        return { (finished: Bool) -> Void in
            snowflake.removeFromSuperview()
            if let index = find(self.snowFlakes, snowflake) {
                self.snowFlakes.removeAtIndex(index)
            }
        }
    }
    
    func startAnimationForSnowflake(snowflake: SnowflakeView) {
        
        UIView.animateWithDuration(durationForSnowflake(snowflake), delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: animationsForSnowflake(snowflake), completion: completionForSnowflake(snowflake))
    }

}


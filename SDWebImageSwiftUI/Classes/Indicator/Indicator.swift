/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SwiftUI

/// A  type to build the indicator
public struct Indicator<T> where T : View {
    var content: (Binding<Bool>, Binding<CGFloat>) -> T
    
    /// Create a indicator with builder
    /// - Parameter builder: A builder to build indicator
    /// - Parameter isAnimating: A Binding to control the animation. If image is during loading, the value is true, else (like start loading) the value is false.
    /// - Parameter progress: A Binding to control the progress during loading. If no progress can be reported, the value is 0.
    /// Associate a indicator when loading image with url
    public init(@ViewBuilder content: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<CGFloat>) -> T) {
        self.content = content
    }
}

/// A provider which provide the indicator status, like `isLoading`, `progress`, so that we use this status to control the indicator showing
/// You should use `@Published` property wrapper in all of these protocol required properties
public protocol IndicatorController : ObservableObject {
    /// A Binding to control the animation. If image is during loading, the value is true, else (like start loading) the value is false.
    var isLoading: Bool { get set }
    
    /// A Binding to control the progress during loading. If no progress can be reported, the value is 0.
    var progress: CGFloat { get set }
}

/// A implementation detail View Modifier with indicator
/// SwiftUI View Modifier construced by using a internal View type which modify the `body`
/// It use type system to represent the view hierarchy, and Swift `some View` syntax to hide the type detail for users
public struct IndicatorViewModifier<T, S> : ViewModifier where T : View, S : IndicatorController {
    
    /// The indicator to control the status management
    @ObservedObject var controller: S
    
    /// The indicator to provide view content
    var indicator: Indicator<T>
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            if controller.isLoading {
                indicator.content($controller.isLoading, $controller.progress)
            } else {
                indicator.content($controller.isLoading, $controller.progress).hidden()
            }
        }
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
extension Indicator where T == ActivityIndicator {
    /// Activity Indicator
    public static var activity: Indicator {
        Indicator { isAnimating, _ in
            ActivityIndicator(isAnimating)
        }
    }
    
    /// Activity Indicator with style
    /// - Parameter style: style
    public static func activity(style: ActivityIndicator.Style) -> Indicator {
        Indicator { isAnimating, _ in
            ActivityIndicator(isAnimating, style: style)
        }
    }
}

extension Indicator where T == ProgressIndicator {
    /// Progress Indicator
    public static var progress: Indicator {
        Indicator { isAnimating, progress in
            ProgressIndicator(isAnimating, progress: progress)
        }
    }
    
    /// Progress Indicator with style
    /// - Parameter style: style
    public static func progress(style: ProgressIndicator.Style) -> Indicator {
        Indicator { isAnimating, progress in
            ProgressIndicator(isAnimating, progress: progress, style: style)
        }
    }
}
#endif

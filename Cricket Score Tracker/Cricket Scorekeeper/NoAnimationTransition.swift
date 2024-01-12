//
//  NoAnimationTransition.swift
//  Cricket Score Tracker
//
//  Created by Vishnu Sreekanth on 1/10/24.
//

import Foundation
import SwiftUI

struct NoAnimationTransition: ViewModifier {
    func body(content: Content) -> some View {
        content
            .transition(AnyTransition.identity)
    }
}

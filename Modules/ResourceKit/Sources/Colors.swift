//
//  Colors.swift
//  ResourceKit
//
//  Created by 이정환 on 1/5/25.
//

import UIKit

public extension UIColor {
    
    // MARK: - Color
    
    /// hex #FFFFFF, r: 255, g: 255, b: 255
    static let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// hex #000000, r: 0, g: 0, b: 0
    static let black = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    // MARK: - Neutral
    
    /// hex #FAFAFA, r: 250, g: 250, b: 250
    static let neutral50 = #colorLiteral(red: 0.984447062, green: 0.9844469428, blue: 0.9844469428, alpha: 1)
    
    /// hex #F5F5F5, r: 245, g: 245, b: 245
    static let neutral100 = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    
    /// hex #E5E5E5, r: 229, g: 229, b: 229
    static let neutral200 = #colorLiteral(red: 0.8980392157, green: 0.8980392157, blue: 0.8980392157, alpha: 1)
    
    /// hex #D4D4D4, r: 212, g: 212, b: 212
    static let neutral300 = #colorLiteral(red: 0.831372549, green: 0.831372549, blue: 0.831372549, alpha: 1)
    
    /// hex #A3A3A3, r: 163, g: 163, b: 163
    static let neutral400 = #colorLiteral(red: 0.6392156863, green: 0.6392156863, blue: 0.6392156863, alpha: 1)
    
    /// hex #737373, r: 115, g: 115, b: 115
    static let neutral500 = #colorLiteral(red: 0.4509803922, green: 0.4509803922, blue: 0.4509803922, alpha: 1)
    
    /// hex #525252, r: 82, g: 82, b: 82
    static let neutral600 = #colorLiteral(red: 0.3215686275, green: 0.3215686275, blue: 0.3215686275, alpha: 1)
    
    /// hex #404040, r: 64, g: 64, b: 64
    static let neutral700 = #colorLiteral(red: 0.2509803922, green: 0.2509803922, blue: 0.2509803922, alpha: 1)
    
    /// hex #262626, r: 38, g: 38, b: 38
    static let neutral800 = #colorLiteral(red: 0.1490196078, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
    
    /// hex #171717, r: 23, g: 23, b: 23
    static let neutral900 = #colorLiteral(red: 0.09019607843, green: 0.09019607843, blue: 0.09019607843, alpha: 1)
    
    /// hex #0A0A0A, r: 10, g: 10, b: 10
    static let neutral950 = #colorLiteral(red: 0.03921568627, green: 0.03921568627, blue: 0.03921568627, alpha: 1)
    
    // MARK: - Blue
    
    /// hex #EFF6FF, r: 239, g: 246, b: 255
    static let blue50 = #colorLiteral(red: 0.937254902, green: 0.9647058824, blue: 1, alpha: 1)
    
    /// hex #DBEAFE, r: 219, g: 234, b: 254
    static let blue100 = #colorLiteral(red: 0.8588235294, green: 0.9176470588, blue: 0.9960784314, alpha: 1)
    
    /// hex #BFDBFE, r: 191, g: 219, b: 254
    static let blue200 = #colorLiteral(red: 0.7490196078, green: 0.8588235294, blue: 0.9960784314, alpha: 1)
    
    /// hex #93C5FD, r: 147, g: 197, b: 253
    static let blue300 = #colorLiteral(red: 0.5764705882, green: 0.7725490196, blue: 0.9921568627, alpha: 1)
    
    /// hex #60A5FA, r: 96, g: 165, b: 250
    static let blue400 = #colorLiteral(red: 0.3764705882, green: 0.6470588235, blue: 0.9803921569, alpha: 1)
    
    /// hex #3B82F6, r: 59, g: 130, b: 246
    static let blue500 = #colorLiteral(red: 0.231372549, green: 0.5098039216, blue: 0.9647058824, alpha: 1)
    
    /// hex #2563EB, r: 37, g: 99, b: 235
    static let blue600 = #colorLiteral(red: 0.1450980392, green: 0.3882352941, blue: 0.9215686275, alpha: 1)
    
    /// hex #1D4ED8, r: 29, g: 78, b: 216
    static let blue700 = #colorLiteral(red: 0.1137254902, green: 0.3058823529, blue: 0.8470588235, alpha: 1)
    
    /// hex #1E40AF, r: 30, g: 64, b: 175
    static let blue800 = #colorLiteral(red: 0.1176470588, green: 0.2509803922, blue: 0.6862745098, alpha: 1)
    
    /// hex #1E3A8A, r: 30, g: 58, b: 138
    static let blue900 = #colorLiteral(red: 0.1176470588, green: 0.2274509804, blue: 0.5411764706, alpha: 1)
    
    /// hex #172554, r: 23, g: 37, b: 84
    static let blue950 = #colorLiteral(red: 0.09019607843, green: 0.1450980392, blue: 0.3294117647, alpha: 1)
    
    // MARK: - Red
    
    /// hex #FEF2F2, r: 254, g: 242, b: 242
    static let red50 = #colorLiteral(red: 0.9960784314, green: 0.9490196078, blue: 0.9490196078, alpha: 1)
    
    /// hex #FEE2E2, r: 254, g: 226, b: 226
    static let red100 = #colorLiteral(red: 0.9960784314, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
    
    /// hex #FECACA, r: 254, g: 202, b: 202
    static let red200 = #colorLiteral(red: 0.9960784314, green: 0.7921568627, blue: 0.7921568627, alpha: 1)
    
    /// hex #FCA5A5, r: 252, g: 165, b: 165
    static let red300 = #colorLiteral(red: 0.9882352941, green: 0.6470588235, blue: 0.6470588235, alpha: 1)
    
    /// hex #F87171, r: 248, g: 113, b: 113
    static let red400 = #colorLiteral(red: 0.9725490196, green: 0.4431372549, blue: 0.4431372549, alpha: 1)
    
    /// hex #EF4444, r: 239, g: 68, b: 68
    static let red500 = #colorLiteral(red: 0.937254902, green: 0.2666666667, blue: 0.2666666667, alpha: 1)
    
    /// hex #DC2626, r: 220, g: 38, b: 38
    static let red600 = #colorLiteral(red: 0.862745098, green: 0.1490196078, blue: 0.1490196078, alpha: 1)
    
    /// hex #B91C1C, r: 185, g: 28, b: 28
    static let red700 = #colorLiteral(red: 0.7254901961, green: 0.1098039216, blue: 0.1098039216, alpha: 1)
    
    /// hex #991B1B, r: 153, g: 27, b: 27
    static let red800 = #colorLiteral(red: 0.6, green: 0.1058823529, blue: 0.1058823529, alpha: 1)
    
    /// hex #7F1D1D, r: 127, g: 29, b: 29
    static let red900 = #colorLiteral(red: 0.4980392157, green: 0.1137254902, blue: 0.1137254902, alpha: 1)
    
    /// hex #450A0A, r: 69, g: 10, b: 10
    static let red950 = #colorLiteral(red: 0.2705882353, green: 0.03921568627, blue: 0.03921568627, alpha: 1)
}

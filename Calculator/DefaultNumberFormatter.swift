//
//  DefaultNumberFormatter.swift
//  Calculator
//
//  Created by Andrij Trubchanin on 1/10/17.
//  Copyright © 2017 Andrij Trubchanin. All rights reserved.
//

import Foundation

class DefaultNumberFormatter: NumberFormatter {
    override init() {
        super.init()
        numberStyle = .decimal
        minimumFractionDigits = 0
        maximumFractionDigits = 6
        minimumIntegerDigits = 1
        notANumberSymbol = "Error"
        groupingSeparator = " "
        //locale = Locale.current
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
    }
}

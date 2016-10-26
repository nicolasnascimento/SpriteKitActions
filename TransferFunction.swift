//
//  TransferFunction.swift
//  QuickTest
//
//  Created by Nicolas Nascimento on 5/5/16.
//  Copyright © 2016 LastLeaf. All rights reserved.
//

import GameKit


// This class can map a one real pole transfer function and a complex poles transfer function
// In the case of one real pole
// G(s) = K/(s - p)
// Where K is the DC gain, and p is the real pole
// In the case of complex poles
// G(s) = K * (Wnˆ2)/(sˆ2 + s*ksi*Wn + Wnˆ2)
// Where K is the DC gain, ksi is the smothing factor, Wn is the natural frequency of the system
// Wd = Wn*sqrt(1 - ksiˆ2) is the smoothed frequency
// Poles of G(s), p1 = -ksi*Wn + jWd, p2 = -ksi*Wn - jWd
/// This class uses the provided parameters to generate a step response of a transfer function

enum TransferFunctionType {
    case complex
    case real
}

class TransferFunction: NSObject {
    
    // Public variables
    var gain: CGFloat = 0.0
    var overshot: CGFloat = 0.0
    var stabilizationTime: CGFloat = 0.0
    var lastEvaluatedValue: CGFloat = 0.0
    
    // Private
    fileprivate var ksi: CGFloat = 0.0
    fileprivate var Wn: CGFloat = 0.0
    fileprivate var pRealPart: CGFloat = 0.0
    fileprivate(set) var type: TransferFunctionType
    
    override var description: String {
        return "G(s) = K * (Wnˆ2)/(sˆ2 + s*ksi*Wn + Wnˆ2) -> G(s) = \(self.gain) * (\(Wn*Wn)/(sˆ2 + s*\(ksi)*\(Wn) + \(Wn*Wn))), with real part of pole being \(pRealPart)"
    }
    init(gain: CGFloat, stabilizationTime: CGFloat) {
        self.gain = gain
        self.type = .real
        self.stabilizationTime = stabilizationTime
        super.init()
        self.generateRealParameters()
    }
    // This initialization generates a complex pole transfer function to be used
    init(gain: CGFloat, overshot: CGFloat, stabilizationTime: CGFloat) {
        self.gain = gain
        self.overshot = overshot
        self.stabilizationTime = stabilizationTime
        self.type = .complex
        super.init()
        self.generateComplexParameters()
    }
    /// Evaluates the value of the inverted laplace transformation of a second degree transffer function, which uses
    /// The provided paramters.
    func evaluateFunctionAtTime(_ time: CGFloat) -> CGFloat {
        switch self.type {
        case .complex:
            let poleContribution = -exp(pRealPart*time)*(cos(Wn*time))
            let value = self.gain*(1.0 + poleContribution)
            self.lastEvaluatedValue = value
            return value
        case .real:
            let normalizedTime = (time/self.stabilizationTime)*4.0
            let poleContribution = -exp(-pRealPart*normalizedTime)
            let value = self.gain*(1.0 + poleContribution)
            self.lastEvaluatedValue = value
            return value
        }
    }
    // MARK - Private
    fileprivate func generateRealParameters() {
        self.pRealPart = 1
    }
    fileprivate func generateComplexParameters() {
        let ksiAux = -log(self.overshot)/CGFloat.pi
        self.ksi = sqrt(ksiAux*ksiAux/(1 + ksiAux*ksiAux))
        self.Wn = 4.0/(self.ksi*CGFloat(self.stabilizationTime))
        // Poles
        self.pRealPart = -ksi*Wn
    }
    
}

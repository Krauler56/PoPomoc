//
//  DashboardViewModel.swift
//  PoPomoc
//
//  Created by Valentin on 16/08/2020.
//

import Foundation
import UIKit

struct DashboardViewModel {
    let type: DashboardModuleType
    let title: String
    let image: UIImage
}

enum DashboardModuleType {
    case trackHelp
    case assistance
    case trackRent
}

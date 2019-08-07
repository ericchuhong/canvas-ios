//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation

@IBDesignable
open class AccessIconView: UIView {
    public enum State {
        case published, unpublished
    }

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var statusIconView: UIImageView!
    @IBOutlet weak var statusIconContainer: UIView!

    public var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }

    public var state: State? {
        didSet {
            switch state {
            case .published?:
                statusIconView.image = .icon(.publish, .solid)
                statusIconView.tintColor = UIColor.named(.backgroundSuccess).ensureContrast(against: .white)
            case .unpublished?:
                statusIconView.image = .icon(.no, .solid)
                statusIconView.tintColor = UIColor.named(.ash)
            case nil:
                statusIconContainer.isHidden = true
            }
        }
    }

    public var published: Bool {
        get { return state == .published }
        set { state = newValue ? .published : .unpublished }
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        statusIconContainer.layer.cornerRadius = 8
        statusIconContainer.clipsToBounds = true
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadFromXib()
    }
}

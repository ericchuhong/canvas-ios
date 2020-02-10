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

import UIKit
import Core

class CourseDetailsViewController: HorizontalMenuViewController {
    private var gradesViewController: GradesViewController!
    private var syllabusViewController: Core.SyllabusViewController!
    private var summaryViewController: Core.SyllabusActionableItemsViewController!
    var courseID: String = ""
    var studentID: String = ""
    var viewControllers: [UIViewController] = []
    var readyToLayoutTabs: Bool = false
    var didLayoutTabs: Bool = false
    var env: AppEnvironment!
    var colorScheme: ColorScheme?
    var replyButton: FloatingButton?
    var replyStarted: Bool = false

    enum MenuItem: Int {
        case grades, syllabus, summary
    }

    lazy var student = env.subscribe(GetSearchRecipients(context: ContextModel(.course, id: courseID), userID: studentID)) { [weak self] in
        self?.messagingReady()
    }

    lazy var teachers = env.subscribe(GetSearchRecipients(context: ContextModel(.course, id: courseID), contextQualifier: .teachers)) { [weak self] in
        self?.messagingReady()
    }

    lazy var courses = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseReady()
    }

    lazy var frontPages = env.subscribe(GetFrontPage(context: ContextModel(.course, id: courseID))) { [weak self] in
        self?.courseReady()
    }

    lazy var tabs = env.subscribe(GetContextTabs(context: ContextModel(.course, id: courseID))) { [weak self] in
        self?.courseReady()
    }

    static func create(courseID: String, studentID: String, env: AppEnvironment = .shared) -> CourseDetailsViewController {
        let controller = CourseDetailsViewController(nibName: nil, bundle: nil)
        controller.env = env
        controller.courseID = courseID
        controller.studentID = studentID
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .named(.backgroundLightest)
        colorScheme = ColorScheme.observee(studentID)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.useContextColor(colorScheme?.color)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Back", comment: ""), style: .plain, target: nil, action: nil)

        delegate = self
        courses.refresh(force: true)
        frontPages.refresh(force: true)
        tabs.refresh(force: true)
        student.refresh()
        teachers.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        readyToLayoutTabs = true
        courseReady()
    }

    func configureGrades() {
        gradesViewController = GradesViewController.create(courseID: courseID, userID: studentID, colorDelegate: self)
        viewControllers.append(gradesViewController)
    }

    func configureSyllabus() {
        syllabusViewController = Core.SyllabusViewController.create(courseID: courseID)
        viewControllers.append(syllabusViewController)
    }

    func configureSummary() {
        summaryViewController = Core.SyllabusActionableItemsViewController(courseID: courseID, sort: GetAssignments.Sort.dueAt, colorDelegate: self)
        viewControllers.append(summaryViewController)
    }

    func configureFrontPage() {
        let vc = CoreWebViewController()
        vc.webView.loadHTMLString(frontPages.first?.body ?? "", baseURL: nil)
        viewControllers.append(vc)
    }

    func configureComposeMessageButton() {
        guard ExperimentalFeature.parentInbox.isEnabled else { return }
        let buttonSize: CGFloat = 56
        let margin: CGFloat = 16
        let bottomMargin: CGFloat = 50

        replyButton = FloatingButton(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        replyButton?.accessibilityLabel = NSLocalizedString("Compose Message", comment: "")
        replyButton?.accessibilityIdentifier = "Grades.composeMessageButton"
        replyButton?.accessibilityTraits.insert(.header)
        replyButton?.setImage(UIImage.icon(.comment, .solid), for: .normal)
        replyButton?.imageEdgeInsets = UIEdgeInsets(top: 17, left: 17, bottom: 15, right: 15)
        replyButton?.tintColor = .named(.white)
        replyButton?.backgroundColor = colorScheme?.color
        if let replyButton = replyButton { view.addSubview(replyButton) }

        let metrics: [String: CGFloat] = ["buttonSize": buttonSize, "margin": margin, "bottomMargin": bottomMargin]
        replyButton?.addConstraintsWithVFL("H:[view(buttonSize)]-(margin)-|", metrics: metrics)
        replyButton?.addConstraintsWithVFL("V:[view(buttonSize)]-(bottomMargin)-|", metrics: metrics)
        replyButton?.addTarget(self, action: #selector(actionReplyButtonClicked(_:)), for: .primaryActionTriggered)
    }

    func courseReady() {
        title = courses.first?.name
        let pending = courses.pending || frontPages.pending || tabs.pending
        if !pending, readyToLayoutTabs, !didLayoutTabs, let course = courses.first {
            didLayoutTabs = true
            configureGrades()
            switch course.defaultView {
            case .wiki:
                if let page = frontPages.first, !page.body.isEmpty {
                    configureFrontPage()
                }
            case .syllabus where course.syllabusBody?.isEmpty == false:
                configureSyllabus()
                configureSummary()
            default:
                let syllabusTab = tabs.first { $0.id == "syllabus" }
                if syllabusTab != nil, course.syllabusBody?.isEmpty == false {
                    configureSyllabus()
                    configureSummary()
                }
            }

            layoutViewControllers()
            configureComposeMessageButton()
        }
    }

    func messagingReady() {
        let pending = teachers.pending || student.pending
        if !pending && replyStarted {
            let name = student.first?.fullName ?? ""
            let tabTitle = titleForSelectedTab() ?? ""
            let template = NSLocalizedString("Regarding: %@, %@", comment: "Regarding <John Doe>, <Grades | Syllabus>")
            let subject = String.localizedStringWithFormat(template, name, tabTitle)
            let context = ContextModel(.course, id: courseID)
            let recipients = teachers.map { APIConversationRecipient(searchRecipient: $0) }
            let r: Route = Route.compose(context: context, recipients: recipients, subject: subject)
            env.router.route(to: r, from: self, options: .modal(embedInNav: true))
            replyButton?.isEnabled = true
        }
    }

    @IBAction func actionReplyButtonClicked(_ sender: UIButton) {
        sender.isEnabled = false
        replyStarted = true
        messagingReady()
    }
}

extension CourseDetailsViewController: ColorDelegate {
    var iconColor: UIColor? {
        return colorScheme?.color
    }
}

extension CourseDetailsViewController: HorizontalPagedMenuDelegate {
    func accessibilityIdentifier(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        var identifier: String
        switch menuItem {
        case .grades: identifier = "grades"
        case .syllabus: identifier = "syllabus"
        case .summary: identifier = "summary"
        }
        return "CourseDetail.\(identifier)MenuItem"
    }

    var menuItemSelectedColor: UIColor? {
        return colorScheme?.color
    }

    func menuItemTitle(at: IndexPath) -> String {
        guard let menuItem = MenuItem(rawValue: at.row) else { return "" }
        switch menuItem {
        case .grades:
            return NSLocalizedString("Grades", comment: "")
        case .syllabus:
            switch courses.first?.defaultView {
            case .wiki:
                return NSLocalizedString("Front Page", comment: "")
            case .syllabus:
                return NSLocalizedString("Syllabus", comment: "")
            default:
                return NSLocalizedString("Syllabus", comment: "")
            }
        case .summary:
            return NSLocalizedString("Summary", comment: "")
        }
    }
}

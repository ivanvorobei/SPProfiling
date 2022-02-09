// The MIT License (MIT)
// Copyright © 2022 Ivan Vorobei (hello@ivanvorobei.by)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import UIKit
import SparrowKit
import NativeUIKit
import SPDiffable
import SFSymbols
import SPAlert

class CurrentProfileController: NativeProfileController {
    
    internal var profileModel: ProfileModel
    
    init() {
        if let currentProfile = ProfileModel.currentProfile {
            self.profileModel = currentProfile
        } else {
            fatalError("Profile scene shoud show only if profile available")
        }
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(DeviceTableCell.self)
        tableView.register(NativeLeftButtonTableViewCell.self)
        
        configureDiffable(sections: content, cellProviders: [.button] + [
            .init(clouser: { tableView, indexPath, item in
                guard let deviceModel = (item as? SPDiffableWrapperItem)?.model as? ProfileDeviceModel else { return nil }
                let cell = self.tableView.dequeueReusableCell(withClass: DeviceTableCell.self, for: indexPath)
                cell.textLabel?.text = deviceModel.name
                cell.detailTextLabel?.text = deviceModel.addedDate.formatted(dateStyle: .medium)
                return cell
            })
        ])
        
        NotificationCenter.default.addObserver(forName: SPProfiling.didReloadedProfile, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            if let profileModel = ProfileModel.currentProfile {
                self.profileModel = profileModel
                self.configureHeader()
                self.diffableDataSource?.updateLayout(animated: true)
            }
        }
        
        configureHeader()
    }
    
    // MARK: - Diffable
    
    internal enum Item: String, CaseIterable {
        
        case change_name
        case devices
        case sign_out
        case delete_account
        
        var section_id: String { rawValue + "_section" }
        var item_id: String { rawValue + "_row" }
    }
    
    private var content: [SPDiffableSection] {
        return [
            .init(
                id: Item.change_name.section_id,
                header: nil,
                footer: SPDiffableTextHeaderFooter(text: Texts.Profile.Actions.Rename.description),
                items: [
                    NativeDiffableLeftButton(
                        id: Item.change_name.item_id,
                        text: Texts.Profile.Actions.Rename.title,
                        icon: .init(.pencil),
                        action: { [weak self] _, _ in
                            guard let self = self else { return }
                            self.showTextFieldToChangeName()
                        }
                    )
                ]
            ),
            .init(
                id: Item.devices.section_id,
                header: SPDiffableTextHeaderFooter(text: Texts.Profile.Devices.header),
                footer: SPDiffableTextHeaderFooter(text: Texts.Profile.Devices.footer),
                items: profileModel.devices.map({ SPDiffableWrapperItem(id: $0.id, model: $0) })
            ),
            .init(
                id: Item.sign_out.section_id,
                header: nil,
                footer: SPDiffableTextHeaderFooter(text: Texts.Profile.Actions.SignOut.description),
                items: [
                    NativeDiffableLeftButton(
                        id: Item.sign_out.item_id,
                        text: Texts.Profile.Actions.SignOut.title,
                        icon: .init(.xmark.squareFill),
                        action: { [weak self] _, indexPath in
                            guard let self = self else { return }
                            let sourceView = self.tableView.cellForRow(at: indexPath) ?? UIView()
                            UIAlertController.confirm(
                                title: Texts.Profile.Actions.SignOut.Confirm.title,
                                description: Texts.Profile.Actions.SignOut.Confirm.description,
                                actionTitle: Texts.Profile.Actions.SignOut.title,
                                cancelTitle: Texts.cancel,
                                desctructive: true,
                                action: { [weak self] in
                                    guard let self = self else { return }
                                    let cell = self.tableView.cellForRow(at: indexPath) as? SPTableViewCell
                                    cell?.setLoading(true)
                                    ProfileModel.currentProfile?.signOut { error in
                                        if let error = error {
                                            SPAlert.present(message: error.localizedDescription, haptic: .error)
                                        } else {
                                            self.dismissAnimated()
                                        }
                                        cell?.setLoading(false)
                                    }
                                },
                                sourceView: sourceView,
                                on: self
                            )
                        }
                    )
                ]
            ),
            .init(
                id: Item.delete_account.section_id,
                header: nil,
                footer: SPDiffableTextHeaderFooter(text: Texts.Profile.Actions.Delete.description),
                items: [
                    NativeDiffableLeftButton(
                        id: Item.delete_account.item_id,
                        text: Texts.Profile.Actions.Delete.title,
                        textColor: .destructiveColor,
                        icon: .init(.trash.fill).withTintColor(.destructiveColor, renderingMode: .alwaysOriginal),
                        action: { [weak self] _, indexPath in
                            guard let self = self else { return }
                            let sourceView = self.tableView.cellForRow(at: indexPath) ?? UIView()
                            UIAlertController.confirmDouble(
                                title: Texts.Profile.Actions.Delete.Confirm.title,
                                description: Texts.Profile.Actions.Delete.Confirm.description,
                                actionTitle: Texts.Profile.Actions.Delete.title,
                                cancelTitle: Texts.cancel,
                                desctructive: true,
                                action: { [weak self] in
                                    guard let self = self else { return }
                                    let cell = self.tableView.cellForRow(at: indexPath) as? SPTableViewCell
                                    cell?.setLoading(true)
                                    self.profileModel.delete { error in
                                        cell?.setLoading(false)
                                        if let error = error {
                                            SPAlert.present(message: error.localizedDescription, haptic: .error)
                                        }
                                    }
                                },
                                sourceView: sourceView,
                                on: self
                            )
                        }
                    )
                ]
            )
        ]
    }
}
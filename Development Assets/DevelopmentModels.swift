// Copyright © 2020 Metabolist. All rights reserved.

import Foundation
import Combine

// swiftlint:disable force_try
private let decoder = MastodonDecoder()
private var cancellables = Set<AnyCancellable>()
private let devInstanceURL = URL(string: "https://mastodon.social")!
private let devIdentityID = UUID(uuidString: "E621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
private let devAccessToken = "DEVELOPMENT_ACCESS_TOKEN"

extension Account {
    static let development = try! decoder.decode(Account.self, from: Data(officialAccountJSON.utf8))
}

extension Instance {
    static let development = try! decoder.decode(Instance.self, from: Data(officialInstanceJSON.utf8))
}

extension IdentityDatabase {
    static func fresh() -> IdentityDatabase { try! IdentityDatabase(inMemory: true) }

    static var development: IdentityDatabase = {
        let db = IdentityDatabase.fresh()

        db.createIdentity(id: devIdentityID, url: devInstanceURL)
            .receive(on: ImmediateScheduler.shared)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        db.updateAccount(.development, forIdentityID: devIdentityID)
            .receive(on: ImmediateScheduler.shared)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        db.updateInstance(.development, forIdentityID: devIdentityID)
            .receive(on: ImmediateScheduler.shared)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        return db
    }()
}

extension AppEnvironment {
    static let development = AppEnvironment(
        session: Session(configuration: .stubbing),
        webAuthSessionType: SuccessfulMockWebAuthSession.self,
        keychainServiceType: MockKeychainService.self)
}

extension IdentitiesService {
    static func fresh(
        identityDatabase: IdentityDatabase = .fresh(),
        keychainService: KeychainService = MockKeychainService(),
        environment: AppEnvironment = .development) -> IdentitiesService {
        IdentitiesService(
            identityDatabase: identityDatabase,
            environment: environment)
    }

    static let development = IdentitiesService(
        identityDatabase: .development,
        environment: .development)
}

extension IdentityService {
    static let development = try! IdentitiesService.development.identityService(id: devIdentityID)
}

extension UserNotificationService {
    static let development = UserNotificationService(userNotificationCenter: .current())
}

extension RootViewModel {
    static let development = RootViewModel(
        appDelegate: AppDelegate(),
        identitiesService: .development,
        userNotificationService: .development)
}

extension AddIdentityViewModel {
    static let development = RootViewModel.development.addIdentityViewModel()
}

extension MainNavigationViewModel {
    static let development = RootViewModel.development.mainNavigationViewModel!
}

#if os(iOS)
extension SecondaryNavigationViewModel {
    static let development = MainNavigationViewModel.development.secondaryNavigationViewModel()
}

extension IdentitiesViewModel {
    static let development = IdentitiesViewModel(identityService: .development)
}
#endif

extension PreferencesViewModel {
    static let development = PreferencesViewModel(identityService: .development)
}

extension PostingReadingPreferencesViewModel {
    static let development = PostingReadingPreferencesViewModel(identityService: .development)
}

// swiftlint:enable force_try
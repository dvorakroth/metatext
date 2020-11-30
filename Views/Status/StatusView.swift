// Copyright © 2020 Metabolist. All rights reserved.

// swiftlint:disable file_length
import Kingfisher
import UIKit

final class StatusView: UIView {
    let avatarImageView = AnimatedImageView()
    let avatarButton = UIButton()
    let infoIcon = UIImageView()
    let infoLabel = UILabel()
    let displayNameLabel = UILabel()
    let accountLabel = UILabel()
    let timeLabel = UILabel()
    let bodyView = StatusBodyView()
    let contextParentTimeLabel = UILabel()
    let timeApplicationDividerLabel = UILabel()
    let applicationButton = UIButton(type: .system)
    let rebloggedByButton = UIButton()
    let favoritedByButton = UIButton()
    let replyButton = UIButton()
    let reblogButton = UIButton()
    let favoriteButton = UIButton()
    let shareButton = UIButton()
    let menuButton = UIButton()
    let buttonsStackView = UIStackView()

    private let containerStackView = UIStackView()
    private let sideStackView = UIStackView()
    private let mainStackView = UIStackView()
    private let nameAccountContainerStackView = UIStackView()
    private let nameAccountTimeStackView = UIStackView()
    private let contextParentTimeApplicationStackView = UIStackView()
    private let contextParentTopNameAccountSpacingView = UIView()
    private let contextParentBottomNameAccountSpacingView = UIView()
    private let interactionsDividerView = UIView()
    private let interactionsStackView = UIStackView()
    private let buttonsDividerView = UIView()
    private let inReplyToView = UIView()
    private let hasReplyFollowingView = UIView()
    private var statusConfiguration: StatusContentConfiguration

    init(configuration: StatusContentConfiguration) {
        self.statusConfiguration = configuration

        super.init(frame: .zero)

        initialSetup()
        applyStatusConfiguration()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StatusView: UIContentView {
    var configuration: UIContentConfiguration {
        get { statusConfiguration }
        set {
            guard let statusConfiguration = newValue as? StatusContentConfiguration else { return }

            self.statusConfiguration = statusConfiguration

            applyStatusConfiguration()
        }
    }
}

extension StatusView: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction) -> Bool {
        switch interaction {
        case .invokeDefaultAction:
            statusConfiguration.viewModel.urlSelected(URL)
            return false
        case .preview: return false
        case .presentActions: return false
        @unknown default: return false
        }
    }
}

private extension StatusView {
    static let actionButtonTitleEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 0)

    var actionButtons: [UIButton] {
        [replyButton, reblogButton, favoriteButton, shareButton, menuButton]
    }

    // swiftlint:disable function_body_length
    func initialSetup() {
        addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.spacing = .defaultSpacing

        infoIcon.tintColor = .secondaryLabel
        infoIcon.setContentCompressionResistancePriority(.required, for: .vertical)

        sideStackView.axis = .vertical
        sideStackView.alignment = .trailing
        sideStackView.spacing = .compactSpacing
        sideStackView.addArrangedSubview(infoIcon)
        sideStackView.addArrangedSubview(UIView())
        containerStackView.addArrangedSubview(sideStackView)

        mainStackView.axis = .vertical
        mainStackView.spacing = .compactSpacing
        containerStackView.addArrangedSubview(mainStackView)

        infoLabel.font = .preferredFont(forTextStyle: .caption1)
        infoLabel.textColor = .secondaryLabel
        infoLabel.adjustsFontForContentSizeCategory = true
        infoLabel.setContentHuggingPriority(.required, for: .vertical)
        mainStackView.addArrangedSubview(infoLabel)

        displayNameLabel.font = .preferredFont(forTextStyle: .headline)
        displayNameLabel.adjustsFontForContentSizeCategory = true
        displayNameLabel.setContentHuggingPriority(.required, for: .horizontal)
        displayNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        nameAccountTimeStackView.addArrangedSubview(displayNameLabel)

        accountLabel.font = .preferredFont(forTextStyle: .subheadline)
        accountLabel.adjustsFontForContentSizeCategory = true
        accountLabel.textColor = .secondaryLabel
        nameAccountTimeStackView.addArrangedSubview(accountLabel)

        timeLabel.font = .preferredFont(forTextStyle: .subheadline)
        timeLabel.adjustsFontForContentSizeCategory = true
        timeLabel.textColor = .secondaryLabel
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        nameAccountTimeStackView.addArrangedSubview(timeLabel)

        nameAccountContainerStackView.spacing = .defaultSpacing
        nameAccountContainerStackView.addArrangedSubview(nameAccountTimeStackView)
        mainStackView.addArrangedSubview(nameAccountContainerStackView)

        mainStackView.addArrangedSubview(bodyView)

        contextParentTimeLabel.font = .preferredFont(forTextStyle: .footnote)
        contextParentTimeLabel.adjustsFontForContentSizeCategory = true
        contextParentTimeLabel.textColor = .secondaryLabel
        contextParentTimeLabel.setContentHuggingPriority(.required, for: .horizontal)
        contextParentTimeApplicationStackView.addArrangedSubview(contextParentTimeLabel)

        timeApplicationDividerLabel.font = .preferredFont(forTextStyle: .footnote)
        timeApplicationDividerLabel.adjustsFontForContentSizeCategory = true
        timeApplicationDividerLabel.textColor = .secondaryLabel
        timeApplicationDividerLabel.text = "•"
        timeApplicationDividerLabel.setContentHuggingPriority(.required, for: .horizontal)
        contextParentTimeApplicationStackView.addArrangedSubview(timeApplicationDividerLabel)

        applicationButton.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
        applicationButton.titleLabel?.adjustsFontForContentSizeCategory = true
        applicationButton.setTitleColor(.secondaryLabel, for: .disabled)
        applicationButton.setContentHuggingPriority(.required, for: .horizontal)
        applicationButton.addAction(
            UIAction { [weak self] _ in
                guard
                    let viewModel = self?.statusConfiguration.viewModel,
                    let url = viewModel.applicationURL
                else { return }

                viewModel.urlSelected(url)
            },
            for: .touchUpInside)
        contextParentTimeApplicationStackView.addArrangedSubview(applicationButton)
        contextParentTimeApplicationStackView.addArrangedSubview(UIView())

        contextParentTimeApplicationStackView.spacing = .compactSpacing
        mainStackView.addArrangedSubview(contextParentTimeApplicationStackView)

        for view in [interactionsDividerView, buttonsDividerView] {
            view.backgroundColor = .opaqueSeparator
            view.heightAnchor.constraint(equalToConstant: .hairline).isActive = true
        }

        mainStackView.addArrangedSubview(interactionsDividerView)
        mainStackView.addArrangedSubview(interactionsStackView)
        mainStackView.addArrangedSubview(buttonsDividerView)

        rebloggedByButton.contentHorizontalAlignment = .leading
        rebloggedByButton.addAction(
            UIAction { [weak self] _ in self?.statusConfiguration.viewModel.rebloggedBySelected() },
            for: .touchUpInside)
        interactionsStackView.addArrangedSubview(rebloggedByButton)

        favoritedByButton.contentHorizontalAlignment = .leading
        favoritedByButton.addAction(
            UIAction { [weak self] _ in self?.statusConfiguration.viewModel.favoritedBySelected() },
            for: .touchUpInside)
        interactionsStackView.addArrangedSubview(favoritedByButton)
        interactionsStackView.distribution = .fillEqually

        favoriteButton.addAction(
            UIAction { [weak self] _ in self?.statusConfiguration.viewModel.toggleFavorited() },
            for: .touchUpInside)

        shareButton.addAction(
            UIAction { [weak self] _ in self?.statusConfiguration.viewModel.shareStatus() },
            for: .touchUpInside)

        menuButton.showsMenuAsPrimaryAction = true
        menuButton.menu = UIMenu(children: [
            UIAction(
                title: NSLocalizedString("report", comment: ""),
                image: UIImage(systemName: "flag"),
                attributes: .destructive) { [weak self] _ in
                self?.statusConfiguration.viewModel.reportStatus()
            }
        ])

        for button in actionButtons {
            button.titleLabel?.font = .preferredFont(forTextStyle: .footnote)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.tintColor = .secondaryLabel
            button.setTitleColor(.secondaryLabel, for: .normal)
            button.titleEdgeInsets = Self.actionButtonTitleEdgeInsets
            buttonsStackView.addArrangedSubview(button)
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: .minimumButtonDimension).isActive = true
        }

        buttonsStackView.distribution = .equalSpacing
        mainStackView.addArrangedSubview(buttonsStackView)

        avatarImageView.layer.cornerRadius = .avatarDimension / 2
        avatarImageView.clipsToBounds = true

        let avatarHeightConstraint = avatarImageView.heightAnchor.constraint(equalToConstant: .avatarDimension)

        avatarHeightConstraint.priority = .justBelowMax

        avatarButton.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.addSubview(avatarButton)
        avatarImageView.isUserInteractionEnabled = true
        avatarButton.setBackgroundImage(.highlightedButtonBackground, for: .highlighted)

        avatarButton.addAction(
            UIAction { [weak self] _ in self?.statusConfiguration.viewModel.accountSelected() },
            for: .touchUpInside)

        for view in [inReplyToView, hasReplyFollowingView] {
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .opaqueSeparator
            view.widthAnchor.constraint(equalToConstant: .hairline).isActive = true
        }

        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: readableContentGuide.topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: readableContentGuide.bottomAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: .avatarDimension),
            avatarHeightConstraint,
            sideStackView.widthAnchor.constraint(equalToConstant: .avatarDimension),
            infoIcon.centerYAnchor.constraint(equalTo: infoLabel.centerYAnchor),
            avatarButton.leadingAnchor.constraint(equalTo: avatarImageView.leadingAnchor),
            avatarButton.topAnchor.constraint(equalTo: avatarImageView.topAnchor),
            avatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            avatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor)
        ])
    }

    func applyStatusConfiguration() {
        let viewModel = statusConfiguration.viewModel
        let isContextParent = viewModel.configuration.isContextParent
        let mutableDisplayName = NSMutableAttributedString(string: viewModel.displayName)

        avatarImageView.kf.setImage(with: viewModel.avatarURL)

        sideStackView.isHidden = isContextParent
        avatarImageView.removeFromSuperview()

        if isContextParent {
            nameAccountContainerStackView.insertArrangedSubview(avatarImageView, at: 0)
        } else {
            sideStackView.insertArrangedSubview(avatarImageView, at: 1)
        }

        NSLayoutConstraint.activate([
            inReplyToView.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            inReplyToView.topAnchor.constraint(equalTo: topAnchor),
            inReplyToView.bottomAnchor.constraint(equalTo: avatarImageView.topAnchor),
            hasReplyFollowingView.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            hasReplyFollowingView.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            hasReplyFollowingView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        inReplyToView.isHidden = !viewModel.configuration.isReplyInContext
        hasReplyFollowingView.isHidden = !viewModel.configuration.hasReplyFollowing

        if viewModel.isReblog {
            infoLabel.attributedText = "status.reblogged-by".localizedBolding(
                displayName: viewModel.rebloggedByDisplayName,
                emoji: viewModel.rebloggedByDisplayNameEmoji,
                label: infoLabel)
            infoIcon.image = UIImage(
                systemName: "arrow.2.squarepath",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small))
            infoLabel.isHidden = false
            infoIcon.isHidden = false
        } else if viewModel.configuration.isPinned {
            infoLabel.text = NSLocalizedString("status.pinned-post", comment: "")
            infoIcon.image = UIImage(
                systemName: "pin",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small))
            infoLabel.isHidden = false
            infoIcon.isHidden = false
        } else {
            infoLabel.isHidden = true
            infoIcon.isHidden = true
        }

        mutableDisplayName.insert(emoji: viewModel.displayNameEmoji, view: displayNameLabel)
        mutableDisplayName.resizeAttachments(toLineHeight: displayNameLabel.font.lineHeight)
        displayNameLabel.attributedText = mutableDisplayName

        nameAccountTimeStackView.axis = isContextParent ? .vertical : .horizontal
        nameAccountTimeStackView.alignment = isContextParent ? .leading : .fill
        nameAccountTimeStackView.spacing = isContextParent ? 0 : .compactSpacing

        contextParentTopNameAccountSpacingView.removeFromSuperview()
        contextParentBottomNameAccountSpacingView.removeFromSuperview()

        if isContextParent {
            nameAccountTimeStackView.insertArrangedSubview(contextParentTopNameAccountSpacingView, at: 0)
            nameAccountTimeStackView.addArrangedSubview(contextParentBottomNameAccountSpacingView)
            contextParentTopNameAccountSpacingView.heightAnchor
                .constraint(equalTo: contextParentBottomNameAccountSpacingView.heightAnchor).isActive = true
        }

        accountLabel.text = viewModel.accountName
        timeLabel.text = viewModel.time
        timeLabel.isHidden = isContextParent

        bodyView.viewModel = viewModel

        contextParentTimeLabel.text = viewModel.contextParentTime
        timeApplicationDividerLabel.isHidden = viewModel.applicationName == nil
        applicationButton.isHidden = viewModel.applicationName == nil
        applicationButton.setTitle(viewModel.applicationName, for: .normal)
        applicationButton.isEnabled = viewModel.applicationURL != nil
        contextParentTimeApplicationStackView.isHidden = !isContextParent

        let noReblogs = viewModel.reblogsCount == 0
        let noFavorites = viewModel.favoritesCount == 0
        let noInteractions = !isContextParent || (noReblogs && noFavorites)

        setAttributedLocalizedTitle(
            button: rebloggedByButton,
            localizationKey: "status.reblogs-count",
            count: viewModel.reblogsCount)
        rebloggedByButton.isHidden = noReblogs
        setAttributedLocalizedTitle(
            button: favoritedByButton,
            localizationKey: "status.favorites-count",
            count: viewModel.favoritesCount)
        favoritedByButton.isHidden = noFavorites

        interactionsDividerView.isHidden = noInteractions
        interactionsStackView.isHidden = noInteractions
        buttonsDividerView.isHidden = !isContextParent

        for button in actionButtons {
            button.contentHorizontalAlignment = isContextParent ? .center : .leading

            if isContextParent {
                button.heightAnchor.constraint(equalToConstant: .minimumButtonDimension).isActive = true
            } else {
                button.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
            }
        }

        setButtonImages(scale: isContextParent ? .medium : .small)

        replyButton.setCountTitle(count: viewModel.repliesCount, isContextParent: isContextParent)
        reblogButton.setCountTitle(count: viewModel.reblogsCount, isContextParent: isContextParent)
        favoriteButton.setCountTitle(count: viewModel.favoritesCount, isContextParent: isContextParent)

        let reblogColor: UIColor = viewModel.reblogged ? .systemGreen : .secondaryLabel

        reblogButton.tintColor = reblogColor
        reblogButton.setTitleColor(reblogColor, for: .normal)
        reblogButton.isEnabled = viewModel.canBeReblogged

        let favoriteColor: UIColor = viewModel.favorited ? .systemYellow : .secondaryLabel

        favoriteButton.tintColor = favoriteColor
        favoriteButton.setTitleColor(favoriteColor, for: .normal)
    }
    // swiftlint:enable function_body_length

    func setButtonImages(scale: UIImage.SymbolScale) {
        replyButton.setImage(UIImage(systemName: "bubble.right",
                                     withConfiguration: UIImage.SymbolConfiguration(scale: scale)), for: .normal)
        reblogButton.setImage(UIImage(systemName: "arrow.2.squarepath",
                                      withConfiguration: UIImage.SymbolConfiguration(scale: scale)), for: .normal)
        favoriteButton.setImage(UIImage(systemName: statusConfiguration.viewModel.favorited ? "star.fill" : "star",
                                        withConfiguration: UIImage.SymbolConfiguration(scale: scale)), for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up",
                                     withConfiguration: UIImage.SymbolConfiguration(scale: scale)), for: .normal)
        menuButton.setImage(UIImage(systemName: "ellipsis",
                                    withConfiguration: UIImage.SymbolConfiguration(scale: scale)), for: .normal)
    }

    func setAttributedLocalizedTitle(button: UIButton, localizationKey: String, count: Int) {
        let localizedTitle = String.localizedStringWithFormat(NSLocalizedString(localizationKey, comment: ""), count)

        button.setAttributedTitle(localizedTitle.countEmphasizedAttributedString(count: count), for: .normal)
        button.setAttributedTitle(
            localizedTitle.countEmphasizedAttributedString(count: count, highlighted: true),
            for: .highlighted)
    }
}

private extension UIButton {
    func setCountTitle(count: Int, isContextParent: Bool) {
        setTitle((isContextParent || count == 0) ? "" : String(count), for: .normal)
    }
}
// swiftlint:enable file_length

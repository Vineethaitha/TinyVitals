//
//  OnboardingViewController.swift
//  TinyVitals
//
//  Created by user45 on 07/11/25.
//

import UIKit

// MARK: - Onboarding Page View

private final class OnboardingPageView: UIView {

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let animationContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        // Animation container — upper portion
        animationContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(animationContainer)

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        titleLabel.alpha = 0
        addSubview(titleLabel)

        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 3
        descriptionLabel.font = .systemFont(ofSize: 17, weight: .regular)
        descriptionLabel.textColor = UIColor.darkGray
        descriptionLabel.alpha = 0
        addSubview(descriptionLabel)

        NSLayoutConstraint.activate([
            animationContainer.topAnchor.constraint(equalTo: topAnchor),
            animationContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            animationContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            animationContainer.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.66),

            titleLabel.topAnchor.constraint(equalTo: animationContainer.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
        ])
    }

    func animateTextIn() {
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 30)
        descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 20)

        UIView.animate(withDuration: 0.7, delay: 0.1, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.titleLabel.alpha = 1
            self.titleLabel.transform = .identity
        }
        UIView.animate(withDuration: 0.7, delay: 0.25, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.descriptionLabel.alpha = 1
            self.descriptionLabel.transform = .identity
        }
    }

    func resetTextForReentry() {
        titleLabel.alpha = 0
        descriptionLabel.alpha = 0
        titleLabel.transform = CGAffineTransform(translationX: 0, y: 30)
        descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 20)
    }
}


// MARK: - Main Onboarding Controller

final class OnboardingViewController: UIViewController {

    // MARK: - Brand Colors
    private let brandPink  = UIColor(red: 237/255, green: 112/255, blue: 153/255, alpha: 1)
    private let brandBlue  = UIColor(red: 112/255, green: 210/255, blue: 237/255, alpha: 1)
    private let brandGreen = UIColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
    private let lightBg    = UIColor.white

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    private let actionButton = UIButton(type: .system)
    private let brandTitleLabel = UILabel()

    private var pages: [OnboardingPageView] = []
    private var currentPage = 0
    private var hasAnimatedPage: [Bool] = [false, false, false]

    // Page 1 elements
    private var chartLayer: CAShapeLayer?
    private var chartDots: [UIView] = []
    private var chartGlowView: UIView?

    // Page 2 elements
    private var featureCards: [UIView] = []

    // Page 3 elements
    private var shieldView: UIImageView?
    private var shieldGlowView: UIView?
    private var orbitingPills: [UIView] = []
    private var orbitLayer: CAShapeLayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = lightBg
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupBrandTitle()
        setupScrollView()
        setupPages()
        setupPageControl()
        setupActionButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBrandTitle()
        triggerPageAnimation(for: 0)
    }

    // MARK: - Brand Title (top)

    private func setupBrandTitle() {
        brandTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        brandTitleLabel.textAlignment = .center
        brandTitleLabel.alpha = 0
        brandTitleLabel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        let text = NSMutableAttributedString()
        let tinyAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: brandPink,
            .font: UIFont(name: "Sigmar-Regular", size: 36) ?? .systemFont(ofSize: 36, weight: .bold)
        ]
        let vitalsAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: brandBlue,
            .font: UIFont(name: "Sigmar-Regular", size: 36) ?? .systemFont(ofSize: 36, weight: .bold)
        ]
        text.append(NSAttributedString(string: "Tiny", attributes: tinyAttr))
        text.append(NSAttributedString(string: "Vitals", attributes: vitalsAttr))
        brandTitleLabel.attributedText = text

        view.addSubview(brandTitleLabel)

        NSLayoutConstraint.activate([
            brandTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            brandTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }

    private func animateBrandTitle() {
        UIView.animate(withDuration: 0.9, delay: 0.1, usingSpringWithDamping: 0.65,
                       initialSpringVelocity: 0.6, options: .curveEaseOut) {
            self.brandTitleLabel.alpha = 1
            self.brandTitleLabel.transform = .identity
        }
    }

    // MARK: - Scroll View

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        scrollView.delegate = self

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: brandTitleLabel.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120),
        ])
    }

    // MARK: - Pages

    private func setupPages() {
        let pageData: [(title: String, titleColor: UIColor, description: String)] = [
            ("Track", brandBlue,
             "Monitor height, weight & milestones\nwith beautiful interactive charts."),
            ("Grow", brandPink,
             "All your child's health records &\nvaccinations, organized beautifully."),
            ("Protect", brandGreen,
             "AI-powered insights to keep your\nlittle one healthy and safe."),
        ]

        for (i, data) in pageData.enumerated() {
            let page = OnboardingPageView()
            page.translatesAutoresizingMaskIntoConstraints = false

            // Title styling
            let titleAttr: [NSAttributedString.Key: Any] = [
                .foregroundColor: data.titleColor,
                .font: UIFont(name: "Sigmar-Regular", size: 38) ?? .systemFont(ofSize: 38, weight: .bold)
            ]
            page.titleLabel.attributedText = NSAttributedString(string: data.title, attributes: titleAttr)
            page.descriptionLabel.text = data.description

            scrollView.addSubview(page)
            pages.append(page)

            NSLayoutConstraint.activate([
                page.topAnchor.constraint(equalTo: scrollView.topAnchor),
                page.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
                page.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
                page.leadingAnchor.constraint(equalTo: i == 0 ? scrollView.leadingAnchor : pages[i - 1].trailingAnchor),
            ])

            if i == pageData.count - 1 {
                page.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
            }
        }
    }

    // MARK: - Page Control

    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = brandPink
        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.12)
        pageControl.isUserInteractionEnabled = false

        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88),
        ])
    }

    // MARK: - Action Button

    private func setupActionButton() {
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = brandPink
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 32, bottom: 16, trailing: 32)
        var attr = AttributedString("Next")
        attr.font = .systemFont(ofSize: 17, weight: .semibold)
        config.attributedTitle = attr
        actionButton.configuration = config
        actionButton.alpha = 0
        actionButton.transform = CGAffineTransform(translationX: 0, y: 40)
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)

        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            actionButton.heightAnchor.constraint(equalToConstant: 54),
        ])

        // Animate button in
        UIView.animate(withDuration: 0.8, delay: 1.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.actionButton.alpha = 1
            self.actionButton.transform = .identity
        }
    }

    @objc private func actionButtonTapped() {
        if currentPage < 2 {
            // Advance to next page
            let nextPage = currentPage + 1
            scrollView.setContentOffset(
                CGPoint(x: scrollView.bounds.width * CGFloat(nextPage), y: 0),
                animated: true
            )
            Haptics.impact(.light)
        } else {
            // Get Started — go to login
            Haptics.impact(.heavy)
            animateButtonPress {
                let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
        }
    }

    private func animateButtonPress(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            self.actionButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.actionButton.transform = .identity
            }) { _ in
                completion()
            }
        }
    }

    private func updateButtonTitle() {
        let title = currentPage == 2 ? "Get Started" : "Next"
        var config = actionButton.configuration
        var attr = AttributedString(title)
        attr.font = .systemFont(ofSize: 17, weight: .semibold)
        config?.attributedTitle = attr

        if currentPage == 2 {
            // Morph to a slightly different style on last page
            config?.baseBackgroundColor = brandGreen
        } else {
            config?.baseBackgroundColor = brandPink
        }

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85,
                       initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.actionButton.configuration = config
            self.actionButton.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.actionButton.transform = .identity
            }
        }
    }

    // MARK: - Page Animation Triggers

    private func triggerPageAnimation(for page: Int) {
        pages[page].animateTextIn()

        switch page {
        case 0: animatePage1_Track()
        case 1: animatePage2_Grow()
        case 2: animatePage3_Protect()
        default: break
        }

        hasAnimatedPage[page] = true
    }

    // ═══════════════════════════════════════════
    // MARK: - PAGE 1: TRACK — Growth Chart
    // ═══════════════════════════════════════════

    private func animatePage1_Track() {
        let container = pages[0].animationContainer
        let bounds = container.bounds
        guard bounds.width > 0 else {
            // Layout not ready — defer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.animatePage1_Track()
            }
            return
        }

        // Glow background
        let glow = UIView(frame: CGRect(x: bounds.midX - 120, y: bounds.midY - 100, width: 240, height: 200))
        glow.backgroundColor = .clear
        glow.alpha = 0

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = glow.bounds
        gradientLayer.colors = [
            brandBlue.withAlphaComponent(0.3).cgColor,
            brandPink.withAlphaComponent(0.15).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.type = .radial
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.cornerRadius = 100
        glow.layer.addSublayer(gradientLayer)
        container.addSubview(glow)
        chartGlowView = glow

        UIView.animate(withDuration: 1.5, delay: 0.3, options: .curveEaseOut) {
            glow.alpha = 1
        }

        // Chart area
        let chartInset: CGFloat = 44
        let chartWidth = bounds.width - chartInset * 2
        let chartHeight: CGFloat = 200
        let chartX = chartInset
        let chartY = bounds.midY - chartHeight / 2 - 10

        // Grid lines (subtle)
        for i in 0...4 {
            let y = chartY + chartHeight * CGFloat(i) / 4
            let line = UIView(frame: CGRect(x: chartX, y: y, width: chartWidth, height: 0.5))
            line.backgroundColor = UIColor.black.withAlphaComponent(0.06)
            line.alpha = 0
            container.addSubview(line)

            UIView.animate(withDuration: 0.5, delay: 0.2 + Double(i) * 0.05, options: .curveEaseOut) {
                line.alpha = 1
            }
        }

        // Y-axis labels
        let yLabels = ["100%", "75%", "50%", "25%", "0%"]
        for (i, text) in yLabels.enumerated() {
            let y = chartY + chartHeight * CGFloat(i) / 4 - 8
            let label = UILabel(frame: CGRect(x: chartX - 40, y: y, width: 34, height: 16))
            label.text = text
            label.font = .monospacedDigitSystemFont(ofSize: 9, weight: .medium)
            label.textColor = UIColor.black.withAlphaComponent(0.35)
            label.textAlignment = .right
            label.alpha = 0
            container.addSubview(label)

            UIView.animate(withDuration: 0.4, delay: 0.3 + Double(i) * 0.06, options: .curveEaseOut) {
                label.alpha = 1
            }
        }

        // X-axis labels
        let xLabels = ["Birth", "3m", "6m", "9m", "12m", "18m"]
        for (i, text) in xLabels.enumerated() {
            let x = chartX + chartWidth * CGFloat(i) / CGFloat(xLabels.count - 1) - 14
            let label = UILabel(frame: CGRect(x: x, y: chartY + chartHeight + 8, width: 28, height: 14))
            label.text = text
            label.font = .monospacedDigitSystemFont(ofSize: 9, weight: .medium)
            label.textColor = UIColor.black.withAlphaComponent(0.35)
            label.textAlignment = .center
            label.alpha = 0
            container.addSubview(label)

            UIView.animate(withDuration: 0.4, delay: 0.5 + Double(i) * 0.06, options: .curveEaseOut) {
                label.alpha = 1
            }
        }

        // Chart path — smooth growth curve
        let dataPoints: [CGPoint] = [
            CGPoint(x: 0.0, y: 0.95),
            CGPoint(x: 0.15, y: 0.70),
            CGPoint(x: 0.30, y: 0.50),
            CGPoint(x: 0.50, y: 0.35),
            CGPoint(x: 0.70, y: 0.22),
            CGPoint(x: 0.85, y: 0.15),
            CGPoint(x: 1.0, y: 0.08),
        ]

        let path = UIBezierPath()
        let absolutePoints = dataPoints.map { pt in
            CGPoint(x: chartX + chartWidth * pt.x, y: chartY + chartHeight * pt.y)
        }

        path.move(to: absolutePoints[0])
        for i in 1..<absolutePoints.count {
            let prev = absolutePoints[i - 1]
            let curr = absolutePoints[i]
            let midX = (prev.x + curr.x) / 2
            path.addCurve(to: curr,
                          controlPoint1: CGPoint(x: midX, y: prev.y),
                          controlPoint2: CGPoint(x: midX, y: curr.y))
        }

        // Gradient fill under curve
        let fillPath = path.copy() as! UIBezierPath
        fillPath.addLine(to: CGPoint(x: chartX + chartWidth, y: chartY + chartHeight))
        fillPath.addLine(to: CGPoint(x: chartX, y: chartY + chartHeight))
        fillPath.close()

        let fillLayer = CAShapeLayer()
        fillLayer.path = fillPath.cgPath
        fillLayer.fillColor = brandBlue.withAlphaComponent(0.12).cgColor
        fillLayer.opacity = 0
        container.layer.addSublayer(fillLayer)

        // Line stroke
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = brandBlue.cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineWidth = 3
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        lineLayer.strokeEnd = 0
        container.layer.addSublayer(lineLayer)
        chartLayer = lineLayer

        // Stroke animation
        let strokeAnim = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnim.fromValue = 0
        strokeAnim.toValue = 1
        strokeAnim.duration = 2.0
        strokeAnim.beginTime = CACurrentMediaTime() + 0.6
        strokeAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        strokeAnim.fillMode = .forwards
        strokeAnim.isRemovedOnCompletion = false
        lineLayer.add(strokeAnim, forKey: "drawLine")

        // Fill fade in
        let fillAnim = CABasicAnimation(keyPath: "opacity")
        fillAnim.fromValue = 0
        fillAnim.toValue = 1
        fillAnim.duration = 1.0
        fillAnim.beginTime = CACurrentMediaTime() + 1.5
        fillAnim.fillMode = .forwards
        fillAnim.isRemovedOnCompletion = false
        fillLayer.add(fillAnim, forKey: "fadeIn")

        // Data point dots with labels
        let dotLabels = ["3.5 kg", "5.8 kg", "7.2 kg", "8.5 kg", "9.1 kg", "9.8 kg", "10.5 kg"]

        for (i, pt) in absolutePoints.enumerated() {
            // Outer glow dot
            let glowDot = UIView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            glowDot.center = pt
            glowDot.backgroundColor = brandBlue.withAlphaComponent(0.2)
            glowDot.layer.cornerRadius = 12
            glowDot.alpha = 0
            glowDot.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            container.addSubview(glowDot)

            // Core dot
            let dot = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            dot.center = pt
            dot.backgroundColor = brandBlue
            dot.layer.cornerRadius = 5
            dot.layer.borderWidth = 2
            dot.layer.borderColor = lightBg.cgColor
            dot.alpha = 0
            dot.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            container.addSubview(dot)
            chartDots.append(dot)

            let delay = 0.6 + (2.0 * Double(i) / Double(absolutePoints.count - 1))
            UIView.animate(withDuration: 0.6, delay: delay,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8,
                           options: .curveEaseOut) {
                dot.alpha = 1
                dot.transform = .identity
                glowDot.alpha = 1
                glowDot.transform = .identity
            } completion: { _ in
                if i == absolutePoints.count - 1 {
                    Haptics.notification(.success)
                    self.startChartIdleAnimation()
                }
            }

            // Tooltip label (show only for a few key points)
            if i == 2 || i == 4 || i == 6 {
                let tooltip = UIView()
                tooltip.backgroundColor = UIColor.white
                tooltip.layer.cornerRadius = 10
                tooltip.layer.cornerCurve = .continuous
                tooltip.layer.shadowColor = UIColor.black.cgColor
                tooltip.layer.shadowOpacity = 0.1
                tooltip.layer.shadowRadius = 8
                tooltip.layer.shadowOffset = CGSize(width: 0, height: 2)
                tooltip.translatesAutoresizingMaskIntoConstraints = false
                tooltip.alpha = 0
                tooltip.transform = CGAffineTransform(scaleX: 0.5, y: 0.5).translatedBy(x: 0, y: 10)
                container.addSubview(tooltip)

                let tooltipLabel = UILabel()
                tooltipLabel.text = dotLabels[i]
                tooltipLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .semibold)
                tooltipLabel.textColor = brandBlue
                tooltipLabel.translatesAutoresizingMaskIntoConstraints = false
                tooltip.addSubview(tooltipLabel)

                NSLayoutConstraint.activate([
                    tooltip.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: pt.x),
                    tooltip.bottomAnchor.constraint(equalTo: container.topAnchor, constant: pt.y - 16),
                    tooltip.heightAnchor.constraint(equalToConstant: 24),

                    tooltipLabel.leadingAnchor.constraint(equalTo: tooltip.leadingAnchor, constant: 8),
                    tooltipLabel.trailingAnchor.constraint(equalTo: tooltip.trailingAnchor, constant: -8),
                    tooltipLabel.centerYAnchor.constraint(equalTo: tooltip.centerYAnchor),
                ])

                UIView.animate(withDuration: 0.5, delay: delay + 0.3,
                               usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5,
                               options: .curveEaseOut) {
                    tooltip.alpha = 1
                    tooltip.transform = .identity
                }
            }
        }
    }

    private func startChartIdleAnimation() {
        for (i, dot) in chartDots.enumerated() {
            let yOffset: CGFloat = [3, -4, 3.5, -3, 4, -3.5, 3][i]
            let duration: TimeInterval = [2.8, 3.1, 2.6, 3.3, 2.9, 3.0, 2.7][i]

            UIView.animate(withDuration: duration, delay: Double(i) * 0.15,
                           options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) {
                dot.transform = CGAffineTransform(translationX: 0, y: yOffset)
            }
        }

        // Glow pulse
        if let glow = chartGlowView {
            UIView.animate(withDuration: 3.0, delay: 0,
                           options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) {
                glow.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                glow.alpha = 0.7
            }
        }
    }

    // ═══════════════════════════════════════════
    // MARK: - PAGE 2: GROW — Tasks-Style Cards
    // ═══════════════════════════════════════════

    private func animatePage2_Grow() {
        let container = pages[1].animationContainer
        let bounds = container.bounds
        guard bounds.width > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.animatePage2_Grow()
            }
            return
        }

        struct CardData {
            let icon: String
            let title: String
            let detail: String
            let color: UIColor
        }

        let cards: [CardData] = [
            CardData(icon: "cross.case.fill", title: "Medical Records",
                     detail: "Store & access anytime", color: brandPink),
            CardData(icon: "syringe.fill", title: "Vaccination Calendar",
                     detail: "Smart reminders & schedules", color: brandBlue),
            CardData(icon: "clock.badge.checkmark.fill", title: "Symptoms Tracker",
                     detail: "Complete history at a glance", color: brandGreen),
        ]

        let cardWidth: CGFloat = bounds.width * 0.72
        let cardHeight: CGFloat = 120

        // Layout: rotation, xOffset, yOffset from center of card area
        let layouts: [(rotation: CGFloat, xOff: CGFloat, yOff: CGFloat)] = [
            (-8, -15, -65),   // top-left tilt
            ( 4,  25, 30),    // center-right tilt
            (-5, -10, 125),   // bottom-left tilt
        ]

        let centerX = bounds.midX
        let centerY = bounds.midY + 15

        for (i, data) in cards.enumerated() {
            let card = buildFeatureCard(
                icon: data.icon, title: data.title,
                detail: data.detail, color: data.color,
                width: cardWidth, height: cardHeight
            )

            let layout = layouts[i]
            card.center = CGPoint(x: centerX + layout.xOff, y: centerY + layout.yOff)

            // Start state: collapsed at center, small, no rotation
            card.alpha = 0
            card.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                .translatedBy(x: 0, y: 80)

            container.addSubview(card)
            featureCards.append(card)

            // Staggered spring entrance
            let delay = 0.3 + Double(i) * 0.18
            let targetRotation = layout.rotation

            UIView.animate(withDuration: 1.0, delay: delay,
                           usingSpringWithDamping: 0.68, initialSpringVelocity: 0.7,
                           options: .curveEaseOut) {
                card.alpha = 1
                card.transform = CGAffineTransform(rotationAngle: targetRotation * .pi / 180)
            } completion: { _ in
                // Haptic on each card landing
                let styles: [UIImpactFeedbackGenerator.FeedbackStyle] = [.light, .medium, .light]
                Haptics.impact(styles[i])

                // Start floating after last card
                if i == cards.count - 1 {
                    self.startCardsFloatingAnimation()
                }
            }
        }
    }

    private func buildFeatureCard(icon: String, title: String, detail: String,
                                  color: UIColor, width: CGFloat, height: CGFloat) -> UIView {
        let card = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        card.backgroundColor = color
        card.layer.cornerRadius = 22
        card.layer.cornerCurve = .continuous

        // Shadow
        card.layer.shadowColor = color.cgColor
        card.layer.shadowOpacity = 0.35
        card.layer.shadowRadius = 20
        card.layer.shadowOffset = CGSize(width: 0, height: 10)

        // Dark pill label
        let pill = UIView()
        pill.backgroundColor = UIColor(white: 0.10, alpha: 0.85)
        pill.layer.cornerRadius = 17
        pill.layer.cornerCurve = .continuous
        pill.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(pill)

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(iconView)

        let pillLabel = UILabel()
        pillLabel.text = title
        pillLabel.font = .systemFont(ofSize: 14, weight: .bold)
        pillLabel.textColor = .white
        pillLabel.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(pillLabel)

        // Detail row
        let detailPill = UIView()
        detailPill.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        detailPill.layer.cornerRadius = 13
        detailPill.layer.cornerCurve = .continuous
        detailPill.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(detailPill)

        let detailIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        detailIcon.tintColor = .white.withAlphaComponent(0.85)
        detailIcon.contentMode = .scaleAspectFit
        detailIcon.translatesAutoresizingMaskIntoConstraints = false
        detailPill.addSubview(detailIcon)

        let detailLabel = UILabel()
        detailLabel.text = detail
        detailLabel.font = .systemFont(ofSize: 13, weight: .medium)
        detailLabel.textColor = .white.withAlphaComponent(0.9)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailPill.addSubview(detailLabel)

        // Shimmer bar
        let shimmer = UIView()
        shimmer.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        shimmer.layer.cornerRadius = 3.5
        shimmer.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(shimmer)

        NSLayoutConstraint.activate([
            pill.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            pill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            pill.heightAnchor.constraint(equalToConstant: 34),

            iconView.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 11),
            iconView.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            pillLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 7),
            pillLabel.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -14),
            pillLabel.centerYAnchor.constraint(equalTo: pill.centerYAnchor),

            detailPill.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            detailPill.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            detailPill.heightAnchor.constraint(equalToConstant: 30),

            detailIcon.leadingAnchor.constraint(equalTo: detailPill.leadingAnchor, constant: 9),
            detailIcon.centerYAnchor.constraint(equalTo: detailPill.centerYAnchor),
            detailIcon.widthAnchor.constraint(equalToConstant: 15),
            detailIcon.heightAnchor.constraint(equalToConstant: 15),

            detailLabel.leadingAnchor.constraint(equalTo: detailIcon.trailingAnchor, constant: 7),
            detailLabel.trailingAnchor.constraint(equalTo: detailPill.trailingAnchor, constant: -14),
            detailLabel.centerYAnchor.constraint(equalTo: detailPill.centerYAnchor),

            shimmer.topAnchor.constraint(equalTo: pill.bottomAnchor, constant: 12),
            shimmer.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            shimmer.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.45),
            shimmer.heightAnchor.constraint(equalToConstant: 7),
        ])

        return card
    }

    private func startCardsFloatingAnimation() {
        let rotations: [CGFloat] = [-8, 4, -5]
        let yOffsets: [CGFloat] = [8, -7, 9]
        let durations: [TimeInterval] = [3.2, 3.5, 3.0]

        for (i, card) in featureCards.enumerated() {
            let baseRotation = rotations[i]
            let yOffset = yOffsets[i]
            let duration = durations[i]

            UIView.animate(withDuration: duration, delay: Double(i) * 0.25,
                           options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) {
                card.transform = CGAffineTransform(rotationAngle: baseRotation * .pi / 180)
                    .translatedBy(x: 0, y: yOffset)
            }
        }
    }

    // ═══════════════════════════════════════════
    // MARK: - PAGE 3: PROTECT — Shield + Orbiting Icons
    // ═══════════════════════════════════════════

    private func animatePage3_Protect() {
        let container = pages[2].animationContainer
        let bounds = container.bounds
        guard bounds.width > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.animatePage3_Protect()
            }
            return
        }

        let centerX = bounds.midX
        let centerY = bounds.midY - 10

        // Radial glow
        let glowSize: CGFloat = 260
        let glowView = UIView(frame: CGRect(x: centerX - glowSize/2, y: centerY - glowSize/2,
                                             width: glowSize, height: glowSize))
        glowView.backgroundColor = .clear
        glowView.alpha = 0

        let radialGradient = CAGradientLayer()
        radialGradient.frame = glowView.bounds
        radialGradient.colors = [
            brandGreen.withAlphaComponent(0.25).cgColor,
            brandGreen.withAlphaComponent(0.08).cgColor,
            UIColor.clear.cgColor
        ]
        radialGradient.type = .radial
        radialGradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        radialGradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        radialGradient.cornerRadius = glowSize / 2
        glowView.layer.addSublayer(radialGradient)
        container.addSubview(glowView)
        shieldGlowView = glowView

        // Orbit ring (subtle dashed circle)
        let orbitRadius: CGFloat = 105
        let orbitPath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY),
                                      radius: orbitRadius,
                                      startAngle: 0, endAngle: .pi * 2, clockwise: true)

        let orbitRing = CAShapeLayer()
        orbitRing.path = orbitPath.cgPath
        orbitRing.strokeColor = UIColor.black.withAlphaComponent(0.08).cgColor
        orbitRing.fillColor = UIColor.clear.cgColor
        orbitRing.lineWidth = 1.5
        orbitRing.lineDashPattern = [4, 6]
        orbitRing.opacity = 0
        container.layer.addSublayer(orbitRing)
        orbitLayer = orbitRing

        // Shield icon
        let shieldConfig = UIImage.SymbolConfiguration(pointSize: 64, weight: .medium)
        let shieldImage = UIImage(systemName: "shield.checkered", withConfiguration: shieldConfig)
        let shield = UIImageView(image: shieldImage)
        shield.tintColor = brandGreen
        shield.contentMode = .scaleAspectFit
        shield.frame = CGRect(x: centerX - 44, y: centerY - 44, width: 88, height: 88)
        shield.alpha = 0
        shield.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        container.addSubview(shield)
        shieldView = shield

        // Shield entrance
        UIView.animate(withDuration: 1.0, delay: 0.3,
                       usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8,
                       options: .curveEaseOut) {
            shield.alpha = 1
            shield.transform = .identity
            glowView.alpha = 1
        } completion: { _ in
            Haptics.impact(.medium)
        }

        // Orbit ring fade in
        let ringFade = CABasicAnimation(keyPath: "opacity")
        ringFade.fromValue = 0
        ringFade.toValue = 1
        ringFade.duration = 0.8
        ringFade.beginTime = CACurrentMediaTime() + 0.6
        ringFade.fillMode = .forwards
        ringFade.isRemovedOnCompletion = false
        orbitRing.add(ringFade, forKey: "fadeIn")

        // Orbiting feature pills
        struct OrbitItem {
            let icon: String
            let title: String
            let color: UIColor
        }

        let orbitItems: [OrbitItem] = [
            OrbitItem(icon: "sparkles", title: "MileStones", color: brandPink),
            OrbitItem(icon: "stethoscope", title: "Symptoms", color: brandBlue),
            OrbitItem(icon: "bell.badge.fill", title: "Smart Alerts", color: UIColor(red: 255/255, green: 179/255, blue: 64/255, alpha: 1)),
            OrbitItem(icon: "waveform.path", title: "Patterns", color: brandGreen),
        ]

        let angleStep = (2 * CGFloat.pi) / CGFloat(orbitItems.count)

        for (i, item) in orbitItems.enumerated() {
            let startAngle = angleStep * CGFloat(i) - .pi / 2 // start from top
            let x = centerX + orbitRadius * cos(startAngle)
            let y = centerY + orbitRadius * sin(startAngle)

            let pill = buildOrbitPill(icon: item.icon, title: item.title, color: item.color)
            pill.center = CGPoint(x: x, y: y)
            pill.alpha = 0
            pill.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
            container.addSubview(pill)
            orbitingPills.append(pill)

            // Entrance animation
            let delay = 0.8 + Double(i) * 0.15
            UIView.animate(withDuration: 0.7, delay: delay,
                           usingSpringWithDamping: 0.65, initialSpringVelocity: 0.7,
                           options: .curveEaseOut) {
                pill.alpha = 1
                pill.transform = .identity
            } completion: { _ in
                Haptics.impact(.light)

                if i == orbitItems.count - 1 {
                    self.startOrbitAnimation(center: CGPoint(x: centerX, y: centerY),
                                              radius: orbitRadius,
                                              items: orbitItems.count)
                    self.startShieldPulse()
                }
            }
        }
    }

    private func buildOrbitPill(icon: String, title: String, color: UIColor) -> UIView {
        let pill = UIView()
        pill.backgroundColor = UIColor.white
        pill.layer.cornerRadius = 18
        pill.layer.cornerCurve = .continuous
        pill.layer.borderWidth = 1
        pill.layer.borderColor = color.withAlphaComponent(0.25).cgColor

        // Shadow
        pill.layer.shadowColor = UIColor.black.cgColor
        pill.layer.shadowOpacity = 0.1
        pill.layer.shadowRadius = 10
        pill.layer.shadowOffset = CGSize(width: 0, height: 3)

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = color
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(iconView)

        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = UIColor(white: 0.2, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        pill.addSubview(label)

        pill.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pill.heightAnchor.constraint(equalToConstant: 36),

            iconView.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 10),
            iconView.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),

            label.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 6),
            label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
            label.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
        ])

        return pill
    }

    private func startOrbitAnimation(center: CGPoint, radius: CGFloat, items: Int) {
        let angleStep = (2 * CGFloat.pi) / CGFloat(items)

        for (i, pill) in orbitingPills.enumerated() {
            let startAngle = angleStep * CGFloat(i) - .pi / 2

            // Gentle bobbing + slow orbit
            let yOffset: CGFloat = [6, -5, 7, -6][i]
            let duration: TimeInterval = [3.0, 3.3, 2.8, 3.5][i]

            UIView.animate(withDuration: duration, delay: Double(i) * 0.2,
                           options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) {
                let newAngle = startAngle + 0.15 // subtle orbit shift
                let newX = center.x + radius * cos(newAngle)
                let newY = center.y + radius * sin(newAngle) + yOffset
                pill.center = CGPoint(x: newX, y: newY)
            }
        }
    }

    private func startShieldPulse() {
        guard let shield = shieldView, let glow = shieldGlowView else { return }

        // Shield gentle pulse
        UIView.animate(withDuration: 2.5, delay: 0,
                       options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) {
            shield.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
        }

        // Glow breathing
        UIView.animate(withDuration: 3.0, delay: 0.3,
                       options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction]) {
            glow.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            glow.alpha = 0.6
        }

        // Orbit ring rotation
        if let ring = orbitLayer {
            let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotation.fromValue = 0
            rotation.toValue = CGFloat.pi * 2
            rotation.duration = 40
            rotation.repeatCount = .infinity
            ring.add(rotation, forKey: "orbitSpin")
        }
    }
}


// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.bounds.width
        guard pageWidth > 0 else { return }

        let progress = scrollView.contentOffset.x / pageWidth
        let newPage = Int(round(progress))

        if newPage != currentPage && newPage >= 0 && newPage < 3 {
            currentPage = newPage
            pageControl.currentPage = newPage

            Haptics.selection()

            updateButtonTitle()

            // Trigger animation for new page if not yet animated
            if !hasAnimatedPage[newPage] {
                triggerPageAnimation(for: newPage)
            }
        }

        // Parallax: update page control tint based on current page colors
        let colors = [brandBlue, brandPink, brandGreen]
        if newPage >= 0 && newPage < 3 {
            pageControl.currentPageIndicatorTintColor = colors[newPage]
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        if page >= 0 && page < 3 && !hasAnimatedPage[page] {
            triggerPageAnimation(for: page)
        }
    }
}

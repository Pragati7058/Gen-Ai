import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/theme_controller.dart';
import '../core/responsive_utils.dart';
import '../core/theme/app_theme.dart';
import '../services/ai_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/gradient_button.dart';
import 'code_generator_screen.dart';
import 'chat_screen.dart';
import 'processing_screen.dart';
import 'project_generator_screen.dart';
import 'quiz_generator_screen.dart';
import 'roadmap_generator_screen.dart';

/// The premium dashboard: prompt input, quick actions and Workshop Demo Mode.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _prompt = TextEditingController();
  final FocusNode _promptFocus = FocusNode();

  static const _quickActions = [
    _QA('Explain a Topic', '📚', 'Explain '),
    _QA('Generate Notes', '📝', 'Generate detailed notes on '),
    _QA('Create Quiz', '🧠', null),
    _QA('Generate Code', '💻', null),
    _QA('Learning Roadmap', '🛣️', null),
    _QA('Project Ideas', '💡', null),
  ];

  static const _demoPrompts = [
    _Demo('Explain Generative AI', '🧠'),
    _Demo('Generate a Flutter Quiz', '🧩'),
    _Demo('Create a Learning Roadmap', '🗺️'),
    _Demo('Generate a Project Idea', '💡'),
    _Demo('Generate Flutter Code', '💻'),
  ];

  @override
  void dispose() {
    _prompt.dispose();
    _promptFocus.dispose();
    super.dispose();
  }

  void _generate() {
    final text = _prompt.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a question or topic to get started.')),
      );
      return;
    }
    final resultType = inferResultType(text);
    final route = resultType == AIResultType.learning
        ? ChatScreen(initialPrompt: text)
        : ProcessingScreen(prompt: text, forcedType: resultType);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => route));
  }

  void _fillPrompt(String text) {
    setState(() => _prompt.text = text);
    _prompt.selection = TextSelection.collapsed(offset: text.length);
    _promptFocus.requestFocus();
  }

  void _open(Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _runDemo(String label) {
    switch (label) {
      case 'Explain Generative AI':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ProcessingScreen(
              prompt: 'Explain Generative AI',
              forcedType: AIResultType.learning,
            ),
          ),
        );
        break;
      case 'Generate a Flutter Quiz':
        _open(const QuizGeneratorScreen());
        break;
      case 'Create a Learning Roadmap':
        _open(const RoadmapGeneratorScreen());
        break;
      case 'Generate a Project Idea':
        _open(const ProjectGeneratorScreen());
        break;
      case 'Generate Flutter Code':
        _open(const CodeGeneratorScreen(defaultPrompt: 'Create a Flutter login screen'));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final aiService = context.read<AIService>();

    final padding = AppResponsive.screenPadding(context);
    final radius = AppResponsive.responsiveRadius(context);
    final isTablet = AppResponsive.isTablet(context);
    final maxContentWidth = AppResponsive.maxContentWidth(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GradientBackground(
        child: SafeArea(
          child: isTablet
              ? _tabletLayout(context, themeController, aiService, padding, radius, maxContentWidth)
              : _phoneLayout(context, themeController, aiService, padding, radius),
        ),
      ),
    );
  }

  Widget _phoneLayout(BuildContext context, ThemeController themeController, 
      AIService aiService, EdgeInsets padding, double radius) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _appBar(context, themeController, aiService, padding),
        ),
        SliverToBoxAdapter(child: _heroTitle(context, padding)),
        SliverToBoxAdapter(child: AppResponsive.verticalSpace(context, multiplier: 2)),
        SliverToBoxAdapter(
            child: _promptCard(context, padding, radius)),
        SliverToBoxAdapter(child: AppResponsive.verticalSpace(context, multiplier: 3)),
        SliverToBoxAdapter(
            child: _sectionHeader(context, 'Quick Actions', '⚡', padding)),
        SliverToBoxAdapter(child: AppResponsive.verticalSpace(context, multiplier: 1)),
        SliverToBoxAdapter(
            child: _quickActionsGrid(context, padding, radius)),
        SliverToBoxAdapter(child: AppResponsive.verticalSpace(context, multiplier: 4)),
        SliverToBoxAdapter(
            child:
                _sectionHeader(context, '🚀 Try Generative AI Live', '', padding)),
        SliverToBoxAdapter(child: AppResponsive.verticalSpace(context, multiplier: 1)),
        SliverToBoxAdapter(child: _demoModeCard(context, padding, radius)),
        SliverToBoxAdapter(child: AppResponsive.verticalSpace(context, multiplier: 3)),
      ],
    );
  }

  Widget _tabletLayout(BuildContext context, ThemeController themeController,
      AIService aiService, EdgeInsets padding, double radius, double maxContentWidth) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: padding,
          child: _phoneLayout(context, themeController, aiService, padding, radius),
        ),
      ),
    );
  }

Widget _appBar(BuildContext context,
    ThemeController themeController, AIService service, EdgeInsets padding) {
  final scheme = Theme.of(context).colorScheme;
  final iconFontSize = AppResponsive.iconSize(context, size: AppIconSize.large);
  final providerFontSize = AppResponsive.responsiveFontSize(context, min: 11, max: 14);
  final demoLabelSize = AppResponsive.responsiveFontSize(context, min: 8, max: 11);
  final iconButtonSize = AppResponsive.iconSize(context, size: AppIconSize.medium);
  final demoLabelH = (AppResponsive.spacing(context, multiplier: 0.25)).toDouble();
  final demoLabelW = (AppResponsive.spacing(context, multiplier: 0.75)).toDouble();
  final badgeRadius = AppResponsive.responsiveRadius(context, size: AppRadiusSize.small);

  return Padding(
    padding: EdgeInsets.fromLTRB(
        padding.left, AppResponsive.spacing(context), padding.right, 0),
    child: Row(
      children: [
        
      
        if (service.isMock) ...[
          AppResponsive.horizontalSpace(context),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: demoLabelW, vertical: demoLabelH),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(badgeRadius),
            ),
            child: Text(
              'DEMO',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: demoLabelSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
        const Spacer(),
        IconButton(
          onPressed: themeController.toggle,
          tooltip: 'Toggle dark mode',
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              themeController.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              key: ValueKey(themeController.isDark),
              size: iconButtonSize,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _heroTitle(BuildContext context, EdgeInsets padding) {
    final scheme = Theme.of(context).colorScheme;
    final helloSize = AppResponsive.responsiveFontSize(context, min: 20, max: 28);
    final questionSize = AppResponsive.responsiveFontSize(context, min: 14, max: 18);
    return Padding(
      padding: EdgeInsets.only(bottom: AppResponsive.spacing(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '  Hello Student 👋',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: helloSize,
                ),
          ),
          AppResponsive.verticalSpace(context, multiplier: 1),
          Text(
            '  What do you want to learn today?',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: questionSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _promptCard(BuildContext context, EdgeInsets padding, double radius) {
    final scheme = Theme.of(context).colorScheme;
    final hintFontSize = AppResponsive.responsiveFontSize(context, min: 13, max: 16);
    final containerRadius = AppResponsive.responsiveRadius(context, size: AppRadiusSize.large);
    final cardPadding = AppResponsive.cardPadding(context);
    final buttonHeight = AppResponsive.buttonHeight(context);
    
    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.subtleGradient,
        borderRadius: BorderRadius.circular(containerRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: containerRadius * 0.9,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _prompt,
            focusNode: _promptFocus,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _generate(),
            maxLines: null,
            decoration: InputDecoration(
              hintText: ' Ask anything... for example: Explain Generative AI',
              hintStyle: TextStyle(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontSize: hintFontSize,
                height: 1.4,
              ),
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: hintFontSize,
              height: 1.4,
              color: scheme.onSurface,
            ),
          ),
          AppResponsive.verticalSpace(context, multiplier: 1),
          GradientButton(
            label: ' Generate with AI',
            icon: Icons.auto_awesome,
            onPressed: _generate,
            height: buttonHeight,
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(
      BuildContext context, String title, String emoji, EdgeInsets padding) {
    final scheme = Theme.of(context).colorScheme;
    final emojiSize = AppResponsive.iconSize(context, size: AppIconSize.medium);
    final titleSize = AppResponsive.responsiveFontSize(context, min: 16, max: 20);
    return Row(
      children: [
        if (emoji.isNotEmpty) ...[
          Text(emoji, style: TextStyle(fontSize: emojiSize)),
          AppResponsive.horizontalSpace(context),
        ],
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: titleSize,
                ),
          ),
        ),
      ],
    );
  }
Widget _quickActionsGrid(
      BuildContext context, EdgeInsets padding, double radius) {
    final crossAxisCount = AppResponsive.gridCrossAxisCount(context,
        minWidthPerTile: 130, minCount: 2, maxCount: 3);
    final spacing = AppResponsive.spacing(context);
    final iconSize = AppResponsive.iconSize(context, size: AppIconSize.large);
    final iconPadding = AppResponsive.spacing(context, multiplier: 1);
    final iconRadius = AppResponsive.responsiveRadius(context, size: AppRadiusSize.small);
    final cardRadius = AppResponsive.responsiveRadius(context, size: AppRadiusSize.medium);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: AppResponsive.gridAspectRatio(context),
      ),
      itemCount: _quickActions.length,
      itemBuilder: (context, index) {
        final action = _quickActions[index];
        return _quickActionCard(context, action, iconSize, iconPadding,
            iconPadding, iconRadius, cardRadius);
      },
    );
  }

  Widget _quickActionCard(BuildContext context, _QA action, double iconSize,
      double paddingH, double paddingV, double iconRadius, double cardRadius) {
    final scheme = Theme.of(context).colorScheme;
    final labelSize = AppResponsive.responsiveFontSize(context, min: 12, max: 14);
    return GestureDetector(
      onTap: () => _handleQuickAction(action),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
        decoration: BoxDecoration(
          gradient: AppColors.subtleGradient,
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize * 1.2,
              height: iconSize * 1.2,
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(iconRadius),
              ),
              child: Center(
                child: Text(action.icon, style: TextStyle(fontSize: iconSize)),
              ),
            ),
            AppResponsive.verticalSpace(context, multiplier: 2),
            Text(
              action.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
                fontSize: labelSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(_QA action) {
    switch (action.label) {
      case 'Create Quiz':
        _open(const QuizGeneratorScreen());
        break;
      case 'Generate Code':
        _open(const CodeGeneratorScreen());
        break;
      case 'Learning Roadmap':
        _open(const RoadmapGeneratorScreen());
        break;
      case 'Project Ideas':
        _open(const ProjectGeneratorScreen());
        break;
      default:
        _fillPrompt(action.fillPrompt ?? '');
    }
  }
Widget _demoModeCard(
      BuildContext context, EdgeInsets padding, double radius) {
    final scheme = Theme.of(context).colorScheme;
    final cardRadius = AppResponsive.responsiveRadius(context, size: AppRadiusSize.large);
    final iconSize = AppResponsive.iconSize(context, size: AppIconSize.medium);
    final fontSize = AppResponsive.responsiveFontSize(context, min: 12, max: 14);
    final demoRadius = AppResponsive.responsiveRadius(context, size: AppRadiusSize.medium);
    final cardPadding = AppResponsive.cardPadding(context);
    final spacerH = AppResponsive.spacing(context);
    
    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        gradient: AppColors.subtleGradient,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('🚀', style: TextStyle(fontSize: iconSize)),
              AppResponsive.horizontalSpace(context),
              Expanded(
                child: Text(
                  'One-click live demos for your workshop',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: scheme.onSurface),
                ),
              ),
            ],
          ),
          AppResponsive.verticalSpace(context, multiplier: 1),
          Text(
            'Tap a prompt to see the full Generative AI flow: prompt → '
            'processing → generated content → interactive experience.',
            style: TextStyle(color: scheme.onSurfaceVariant, fontSize: fontSize),
          ),
          AppResponsive.verticalSpace(context, multiplier: 2),
          ..._demoPrompts.map((demo) => Padding(
                padding: EdgeInsets.only(
                    bottom: AppResponsive.spacing(context)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(demoRadius),
                    gradient: AppColors.brandGradient,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(demoRadius),
                      onTap: () => _runDemo(demo.label),
                      child: Padding(
                        padding: cardPadding,
                        child: Row(
                          children: [
                            Text(demo.icon, style: TextStyle(fontSize: iconSize)),
                            SizedBox(width: spacerH),
                            Expanded(
                              child: Text(
                                demo.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.play_circle_fill_rounded,
                                color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _QA {
  final String label;
  final String icon;
  final String? fillPrompt;
  const _QA(this.label, this.icon, this.fillPrompt);
}

class _Demo {
  final String label;
  final String icon;
  const _Demo(this.label, this.icon);
}

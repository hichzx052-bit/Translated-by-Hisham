import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/app_state.dart';
import '../models/language_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/language_selector.dart';

class VideoTranslationScreen extends StatefulWidget {
  const VideoTranslationScreen({super.key});

  @override
  State<VideoTranslationScreen> createState() => _VideoTranslationScreenState();
}

class _VideoTranslationScreenState extends State<VideoTranslationScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _videoController;
  String? _videoPath;
  bool _isProcessing = false;
  double _progress = 0;
  String _processingStage = '';
  bool _hasResult = false;

  // Subtitle settings
  double _subtitleFontSize = 18;
  String _subtitlePosition = 'bottom'; // top, center, bottom
  Color _subtitleColor = Colors.white;
  Color _subtitleBgColor = Colors.black;
  double _subtitleBgOpacity = 0.7;

  // Dubbing settings
  bool _enableDubbing = false;
  bool _keepBackgroundSounds = true;
  String _dubbingGender = 'male';

  // Watermark
  bool _enableWatermark = true;

  // Expandable panels
  bool _subtitlePanelExpanded = false;
  bool _dubbingPanelExpanded = false;

  // Subtitle color options
  final List<Color> _colorOptions = [
    Colors.white,
    Colors.yellow,
    const Color(0xFF00FF00),
    const Color(0xFF00BFFF),
    const Color(0xFFFF6B6B),
    const Color(0xFFFFD700),
    const Color(0xFFFF69B4),
    const Color(0xFFADD8E6),
  ];

  final List<Color> _bgColorOptions = [
    Colors.black,
    const Color(0xFF1A1A2E),
    const Color(0xFF0D1B2A),
    const Color(0xFF2D1B69),
    Colors.transparent,
  ];

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      setState(() => _videoPath = path);

      _videoController?.dispose();
      _videoController = VideoPlayerController.file(File(path))
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  Future<void> _startTranslation() async {
    if (_videoPath == null) return;

    setState(() {
      _isProcessing = true;
      _progress = 0;
      _processingStage = 'استخراج الصوت...';
    });

    // Stage 1: Extract audio
    for (int i = 0; i <= 25; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) setState(() => _progress = i / 100);
    }

    setState(() => _processingStage = 'ترجمة النص...');

    // Stage 2: Translate
    for (int i = 25; i <= 50; i++) {
      await Future.delayed(const Duration(milliseconds: 80));
      if (mounted) setState(() => _progress = i / 100);
    }

    if (_enableDubbing) {
      setState(() => _processingStage = 'دبلجة الصوت...');
      for (int i = 50; i <= 75; i++) {
        await Future.delayed(const Duration(milliseconds: 80));
        if (mounted) setState(() => _progress = i / 100);
      }
    }

    setState(() => _processingStage = 'تصدير الفيديو...');

    // Stage 3/4: Render
    final start = _enableDubbing ? 75 : 50;
    for (int i = start; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 60));
      if (mounted) setState(() => _progress = i / 100);
    }

    setState(() {
      _isProcessing = false;
      _hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0A0A1A),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _buildVideoArea(),
                        const SizedBox(height: 16),
                        // Language selector
                        _buildLanguageRow(state),
                        const SizedBox(height: 16),
                        // Subtitle settings
                        _buildSubtitlePanel(),
                        const SizedBox(height: 12),
                        // Dubbing settings
                        _buildDubbingPanel(),
                        const SizedBox(height: 12),
                        // Watermark toggle
                        _buildWatermarkToggle(),
                        const SizedBox(height: 16),
                        // Processing progress
                        if (_isProcessing) _buildProcessingCard(),
                        // Action buttons
                        if (!_isProcessing) _buildActionButtons(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.movie_creation_outlined, color: Color(0xFF10B981), size: 24),
          const SizedBox(width: 8),
          const Text(
            'ترجمة فيديو',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
            // Subtitle preview overlay
            if (_hasResult)
              Positioned(
                left: 16,
                right: 16,
                bottom: _subtitlePosition == 'bottom'
                    ? 16
                    : _subtitlePosition == 'center'
                        ? null
                        : null,
                top: _subtitlePosition == 'top'
                    ? 16
                    : _subtitlePosition == 'center'
                        ? null
                        : null,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: _subtitleBgColor.withOpacity(_subtitleBgOpacity),
                    ),
                    child: Text(
                      'مرحباً بالجميع في البث المباشر',
                      style: TextStyle(
                        color: _subtitleColor,
                        fontSize: _subtitleFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            // AI Watermark
            if (_enableWatermark && _hasResult)
              Positioned(
                bottom: 8,
                right: 12,
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    final opacity = 0.4 + (_shimmerController.value * 0.4);
                    return Opacity(
                      opacity: opacity,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6366F1).withOpacity(0.6),
                              const Color(0xFF8B5CF6).withOpacity(0.4),
                            ],
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white70, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Translated by Hisham',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            // Play/pause overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
                child: AnimatedOpacity(
                  opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    color: Colors.black26,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                        ),
                        child: Icon(
                          _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Progress bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF8B5CF6),
                  bufferedColor: Color(0x558B5CF6),
                  backgroundColor: Color(0x33FFFFFF),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // No video selected - picker area
    return GestureDetector(
      onTap: _pickVideo,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.8),
              const Color(0xFF0A0A1A),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF10B981).withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.15),
                    const Color(0xFF059669).withOpacity(0.05),
                  ],
                ),
              ),
              child: const Icon(Icons.video_library_rounded, color: Color(0xFF10B981), size: 40),
            ),
            const SizedBox(height: 14),
            const Text(
              'اضغط لاختيار فيديو',
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Text(
              'MP4 • MOV • AVI • MKV',
              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageRow(AppState state) {
    return Row(
      children: [
        Expanded(
          child: LanguageSelector(
            selectedLanguage: state.sourceLanguage,
            languages: LanguageModel.supportedLanguages,
            onChanged: (l) => state.setSourceLanguage(l),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GestureDetector(
            onTap: () => state.swapLanguages(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
              ),
              child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
            ),
          ),
        ),
        Expanded(
          child: LanguageSelector(
            selectedLanguage: state.targetLanguage,
            languages: LanguageModel.supportedLanguages,
            onChanged: (l) => state.setTargetLanguage(l),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitlePanel() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _subtitlePanelExpanded = !_subtitlePanelExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                    ),
                    child: const Icon(Icons.subtitles, color: Color(0xFF3B82F6), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('إعدادات الترجمة الكتابية',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  AnimatedRotation(
                    turns: _subtitlePanelExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: Colors.white38, size: 22),
                  ),
                ],
              ),
            ),
          ),
          // Content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.white.withOpacity(0.06)),
                  // Font size
                  Row(
                    children: [
                      const Icon(Icons.format_size, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      const Text('حجم الخط', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      const Spacer(),
                      Text('${_subtitleFontSize.toInt()}',
                          style: const TextStyle(color: Color(0xFF818CF8), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Slider(
                    value: _subtitleFontSize,
                    min: 12,
                    max: 48,
                    activeColor: const Color(0xFF8B5CF6),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _subtitleFontSize = v),
                  ),
                  const SizedBox(height: 8),
                  // Position
                  Row(
                    children: [
                      const Icon(Icons.vertical_align_bottom, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      const Text('موضع الترجمة', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _positionChip('أعلى', 'top'),
                      const SizedBox(width: 8),
                      _positionChip('وسط', 'center'),
                      const SizedBox(width: 8),
                      _positionChip('أسفل', 'bottom'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Text color
                  Row(
                    children: [
                      const Icon(Icons.palette_outlined, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      const Text('لون النص', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _colorOptions.map((c) => _colorCircle(c, _subtitleColor, (color) {
                      setState(() => _subtitleColor = color);
                    })).toList(),
                  ),
                  const SizedBox(height: 14),
                  // Background color
                  Row(
                    children: [
                      const Icon(Icons.format_color_fill, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      const Text('خلفية النص', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _bgColorOptions.map((c) => _colorCircle(c, _subtitleBgColor, (color) {
                      setState(() => _subtitleBgColor = color);
                    })).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Background opacity
                  Row(
                    children: [
                      const Text('شفافية الخلفية', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      const Spacer(),
                      Text('${(_subtitleBgOpacity * 100).toInt()}%',
                          style: const TextStyle(color: Color(0xFF818CF8), fontSize: 12)),
                    ],
                  ),
                  Slider(
                    value: _subtitleBgOpacity,
                    min: 0,
                    max: 1,
                    activeColor: const Color(0xFF8B5CF6),
                    inactiveColor: Colors.white12,
                    onChanged: (v) => setState(() => _subtitleBgOpacity = v),
                  ),
                ],
              ),
            ),
            crossFadeState: _subtitlePanelExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildDubbingPanel() {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _dubbingPanelExpanded = !_dubbingPanelExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFA855F7).withOpacity(0.1),
                    ),
                    child: const Icon(Icons.record_voice_over, color: Color(0xFFA855F7), size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('الدبلجة الصوتية',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                  Switch.adaptive(
                    value: _enableDubbing,
                    onChanged: (v) => setState(() => _enableDubbing = v),
                    activeColor: const Color(0xFFA855F7),
                    inactiveTrackColor: Colors.white.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.white.withOpacity(0.06)),
                  // Voice gender
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white38, size: 18),
                      const SizedBox(width: 8),
                      const Text('نوع الصوت', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: _genderChip('رجالي', Icons.face, 'male')),
                      const SizedBox(width: 10),
                      Expanded(child: _genderChip('نسائي', Icons.face_3, 'female')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Keep background sounds
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xFF10B981).withOpacity(0.1),
                        ),
                        child: const Icon(Icons.music_note, color: Color(0xFF10B981), size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الاحتفاظ بأصوات الخلفية',
                                style: TextStyle(color: Colors.white, fontSize: 13)),
                            Text('موسيقى وأصوات بيئية',
                                style: TextStyle(color: Colors.white30, fontSize: 11)),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _keepBackgroundSounds,
                        onChanged: (v) => setState(() => _keepBackgroundSounds = v),
                        activeColor: const Color(0xFF10B981),
                        inactiveTrackColor: Colors.white.withOpacity(0.1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState: (_dubbingPanelExpanded || _enableDubbing)
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildWatermarkToggle() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF6366F1).withOpacity(0.1),
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF6366F1), size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('علامة AI المائية',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                Text('Translated by Hisham',
                    style: TextStyle(color: Colors.white30, fontSize: 11)),
              ],
            ),
          ),
          Switch.adaptive(
            value: _enableWatermark,
            onChanged: (v) => setState(() => _enableWatermark = v),
            activeColor: const Color(0xFF6366F1),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingCard() {
    return GlassContainer(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF8B5CF6).withOpacity(0.1),
          const Color(0xFF6366F1).withOpacity(0.03),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF818CF8),
                  strokeWidth: 2.5,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _processingStage,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                '${(_progress * 100).toInt()}%',
                style: const TextStyle(
                    color: Color(0xFF818CF8), fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          // Stage indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _stageIndicator('استخراج', _progress >= 0.01, _progress >= 0.25),
              _stageIndicator('ترجمة', _progress >= 0.25, _progress >= 0.50),
              if (_enableDubbing)
                _stageIndicator('دبلجة', _progress >= 0.50, _progress >= 0.75),
              _stageIndicator('تصدير', _progress >= (_enableDubbing ? 0.75 : 0.50), _progress >= 1.0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_videoPath != null && !_hasResult)
          GestureDetector(
            onTap: _startTranslation,
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.translate, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'بدء الترجمة',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        if (_hasResult) ...[
          // Export button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ الفيديو في المعرض'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    'تنزيل الفيديو',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // New video button
          GestureDetector(
            onTap: () {
              setState(() {
                _videoController?.dispose();
                _videoController = null;
                _videoPath = null;
                _hasResult = false;
              });
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.video_library_outlined, color: Colors.white.withOpacity(0.5), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'اختيار فيديو آخر',
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Helper widgets
  Widget _positionChip(String label, String value) {
    final selected = _subtitlePosition == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _subtitlePosition = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: selected
                ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                : null,
            color: selected ? null : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorCircle(Color color, Color selected, ValueChanged<Color> onTap) {
    final isSelected = color.value == selected.value;
    return GestureDetector(
      onTap: () => onTap(color),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color == Colors.transparent ? null : color,
          border: Border.all(
            color: isSelected ? const Color(0xFF818CF8) : Colors.white24,
            width: isSelected ? 2.5 : 1,
          ),
          gradient: color == Colors.transparent
              ? const LinearGradient(colors: [Color(0xFF333), Color(0xFF111)])
              : null,
        ),
        child: color == Colors.transparent
            ? const Icon(Icons.block, color: Colors.white38, size: 16)
            : isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
      ),
    );
  }

  Widget _genderChip(String label, IconData icon, String value) {
    final selected = _dubbingGender == value;
    return GestureDetector(
      onTap: () => setState(() => _dubbingGender = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF8B5CF6)])
              : null,
          color: selected ? null : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: selected ? Colors.transparent : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.white54, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stageIndicator(String label, bool active, bool complete) {
    return Column(
      children: [
        Icon(
          complete ? Icons.check_circle : Icons.circle_outlined,
          color: active
              ? (complete ? const Color(0xFF10B981) : const Color(0xFF818CF8))
              : Colors.white.withOpacity(0.15),
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white54 : Colors.white.withOpacity(0.15),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

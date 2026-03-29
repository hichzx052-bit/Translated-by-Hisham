import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

class VideoTranslationScreen extends StatefulWidget {
  const VideoTranslationScreen({super.key});

  @override
  State<VideoTranslationScreen> createState() => _VideoTranslationScreenState();
}

class _VideoTranslationScreenState extends State<VideoTranslationScreen> {
  bool _hasVideo = false;
  bool _isProcessing = false;
  double _progress = 0;
  final List<_Subtitle> _subtitles = [];

  void _pickVideo() async {
    // In real app: use file_picker to select video
    setState(() => _hasVideo = true);
  }

  void _startTranslation() async {
    setState(() => _isProcessing = true);
    // Simulate processing
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) setState(() => _progress = i / 100);
    }
    setState(() {
      _isProcessing = false;
      _subtitles.addAll([
        _Subtitle('00:00:01', '00:00:03', 'Hello everyone', 'مرحباً بالجميع'),
        _Subtitle('00:00:04', '00:00:07', 'Welcome to my stream', 'أهلاً بكم في بثي'),
        _Subtitle('00:00:08', '00:00:11', 'Today we will talk about', 'اليوم سنتحدث عن'),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                  const Text(
                    'ترجمة فيديو',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Video area
                    GestureDetector(
                      onTap: _hasVideo ? null : _pickVideo,
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 2,
                            // dashed border simulated by opacity
                          ),
                        ),
                        child: _hasVideo
                            ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Simulated video area
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFF1E1E3F),
                                          const Color(0xFF0A0A1A),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.play_circle_fill,
                                          color: Colors.white.withOpacity(0.3), size: 64),
                                    ),
                                  ),
                                  // Subtitle overlay
                                  if (_subtitles.isNotEmpty)
                                    Positioned(
                                      bottom: 16,
                                      left: 16,
                                      right: 16,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black.withOpacity(0.7),
                                        ),
                                        child: Text(
                                          _subtitles.first.translated,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF10B981).withOpacity(0.1),
                                    ),
                                    child: const Icon(Icons.video_library, color: Color(0xFF10B981), size: 36),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'اضغط لاختيار فيديو',
                                    style: TextStyle(color: Colors.white54, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'MP4, MOV, AVI',
                                    style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Processing progress
                    if (_isProcessing) ...[
                      GlassContainer(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF818CF8),
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'جاري معالجة الفيديو...',
                                  style: TextStyle(color: Colors.white, fontSize: 14),
                                ),
                                const Spacer(),
                                Text(
                                  '${(_progress * 100).toInt()}%',
                                  style: const TextStyle(color: Color(0xFF818CF8), fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress,
                                backgroundColor: Colors.white.withOpacity(0.06),
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF8B5CF6)),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Translate button
                    if (_hasVideo && !_isProcessing && _subtitles.isEmpty)
                      GestureDetector(
                        onTap: _startTranslation,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                          child: const Center(
                            child: Text(
                              'بدء الترجمة 🎬',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Subtitles list
                    if (_subtitles.isNotEmpty) ...[
                      Row(
                        children: [
                          const Text(
                            'الترجمات',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Text(
                            '${_subtitles.length} سطر',
                            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_subtitles.length, (i) {
                        final sub = _subtitles[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: const Color(0xFF8B5CF6).withOpacity(0.15),
                                      ),
                                      child: Text(
                                        '${sub.start} → ${sub.end}',
                                        style: const TextStyle(color: Color(0xFF818CF8), fontSize: 11),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(sub.original, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13)),
                                const SizedBox(height: 4),
                                Text(sub.translated, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Subtitle {
  final String start;
  final String end;
  final String original;
  final String translated;
  _Subtitle(this.start, this.end, this.original, this.translated);
}

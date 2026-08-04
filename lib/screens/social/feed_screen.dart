import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:any_link_preview/any_link_preview.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../services/feed_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/skeleton_loader.dart';
import 'create_post_screen.dart';
import 'comments_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final FeedService _feedService = FeedService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Configure timeago for Turkish
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<Post> _getSampleRoboticPosts() {
    final now = DateTime.now();

    return [
      Post(
        id: 'sample_1',
        userId: 'devkom_system',
        userName: 'Devkom',
        userRole: 'admin',
        description: '🤖 Tesla Optimus Robotu 130 Bin Dolara Satışa Sunuldu\n\n'
            'Elon Musk\'ın Tesla şirketi, insansı robotu Optimus\'u 130.000 dolar fiyatla '
            'ön sipariş için açtığını duyurdu. Robot, ev işlerinden üretim hatlarına '
            'kadar birçok alanda kullanılabilecek.\n\n'
            '📌 Özellikler:\n'
            '• 40+ eklem ile insan benzeri hareket\n'
            '• 20 kg ağırlık taşıma kapasitesi\n'
            '• Yapay zeka tabanlı öğrenme\n'
            '• 8 saat kesintisiz çalışma\n\n'
            'Tesla, 2026 yılında seri üretime geçmeyi hedefliyor. Robot, endüstriyel '
            'üretimden ev asistanlığına kadar geniş bir kullanım alanına sahip olacak.\n\n'
            'Kaynak: Tesla AI Day 2025',
        imageUrl: null, // Asset kaldırıldı: tesla_optimus.jpg projede yok
        likes: ['user1', 'user2', 'user3', 'user4'],
        commentCount: 0,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'sample_2',
        userId: 'devkom_system',
        userName: 'Devkom',
        userRole: 'admin',
        description: '🇨🇳 Çin\'de İnsansı Robotlar Günlük Hayata Giriyor\n\n'
            'Çin\'in önde gelen teknoloji şirketleri, insansı robotları restoranlardan '
            'hastanelere kadar birçok alanda kullanıma sunmaya başladı.\n\n'
            '🏥 Sağlık Sektörü:\n'
            '• Hasta bakımı ve ilaç dağıtımı\n'
            '• Ameliyat asistanlığı\n'
            '• Yaşlı bakım hizmetleri\n\n'
            '🏪 Hizmet Sektörü:\n'
            '• Restoran servis robotları\n'
            '• Otel resepsiyon görevlileri\n'
            '• Alışveriş merkezi danışmanları\n\n'
            'Şangay\'da 50\'den fazla restoran ve kafe robot garsonlar kullanıyor. '
            'Robotlar, sipariş almaktan yemek servisine kadar tüm süreçleri yönetebiliyor.\n\n'
            'Pazar araştırmalarına göre, Çin\'in robot pazarı 2025 yılında 95 milyar dolara ulaşacak.',
        imageUrl: null,
        likes: ['user5', 'user6', 'user7'],
        commentCount: 0,
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Post(
        id: 'sample_3',
        userId: 'devkom_system',
        userName: 'Devkom',
        userRole: 'admin',
        description: '🦾 3D Yazıcı ile Robot Kol Yapımı: Adım Adım Rehber\n\n'
            'Kendi robot kolunuzu 3D yazıcı kullanarak yapabilirsiniz! İşte temel adımlar:\n\n'
            '1️⃣ Tasarım Aşaması\n'
            '• Fusion 360 veya TinkerCAD kullanın\n'
            '• Eklem noktalarını planlayın\n'
            '• Motor yuvaları ekleyin\n\n'
            '2️⃣ Malzemeler\n'
            '• 6x Servo motor (MG996R)\n'
            '• Arduino Mega veya Raspberry Pi\n'
            '• PLA veya PETG filament\n'
            '• M3 vidalar ve somunlar\n\n'
            '3️⃣ Baskı Ayarları\n'
            '• Dolgu oranı: %20-30\n'
            '• Katman kalınlığı: 0.2mm\n'
            '• Destek yapıları: Gerektiğinde\n\n'
            '4️⃣ Montaj ve Kodlama\n'
            '• Arduino IDE kullanarak servo kontrolü\n'
            '• Kinematik hesaplamalar\n'
            '• Test ve kalibrasyon\n\n'
            'Toplam maliyet: ~2.500₺\nYapım süresi: 15-20 saat\n\n'
            'Detaylı rehber için: https://github.com/EEEngineer/3D-Printed-Robot-Arm',
        imageUrl: null,
        likes: ['user8', 'user9', 'user10', 'user11'],
        commentCount: 0,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      Post(
        id: 'sample_4',
        userId: 'devkom_system',
        userName: 'Devkom',
        userRole: 'admin',
        description: '🧠 MIT\'den Soft Robotik Alanında Çığır Açan Gelişme\n\n'
            'MIT araştırmacıları, kas benzeri hareket edebilen yeni bir soft robot '
            'geliştirdi. Robot, geleneksel sert robotlara göre daha güvenli ve esnek.\n\n'
            '🔬 Yenilikçi Özellikler:\n'
            '• Elektro-hidrolik aktuatörler\n'
            '• İnsan kasına benzer hareket\n'
            '• Kendi ağırlığının 1000 katını kaldırma\n'
            '• Darbe emme kapasitesi\n\n'
            '💡 Kullanım Alanları:\n'
            '• Tıbbi protezler ve egzoskeletler\n'
            '• Arama-kurtarma operasyonları\n'
            '• Hassas nesne manipülasyonu\n'
            '• İnsan-robot iş birliği\n\n'
            'Soft robotik, robotların insanlarla daha güvenli etkileşim kurmasını '
            'sağlıyor. Araştırma, Nature dergisinde yayınlandı.\n\n'
            'Detaylı makale: https://www.nature.com/articles/s41586-024-07894-1',
        imageUrl: null,
        likes: ['user12', 'user13'],
        commentCount: 0,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      Post(
        id: 'sample_5',
        userId: 'devkom_system',
        userName: 'Devkom',
        userRole: 'admin',
        description: '🇹🇷 Türkiye\'de Robotik Kodlama Eğitimi Yaygınlaşıyor\n\n'
            'Milli Eğitim Bakanlığı, 2025-2026 eğitim döneminde robotik kodlama '
            'derslerini 5. sınıftan itibaren zorunlu hale getiriyor.\n\n'
            '📚 Program Detayları:\n'
            '• Haftada 2 saat uygulamalı ders\n'
            '• Arduino ve mBlock eğitimi\n'
            '• STEM laboratuvarları kurulumu\n'
            '• Ulusal robotik yarışmaları\n\n'
            '📊 İstatistikler:\n'
            '• 15.000 okulda STEM atölyesi\n'
            '• 50.000 öğretmen eğitimi\n'
            '• 2 milyon öğrenci ulaşım hedefi\n\n'
            'Pilot uygulamalar 500 okulda başarıyla tamamlandı. Öğrenciler, temel '
            'elektronik devrelerden otonom robotlara kadar birçok proje geliştirdi.\n\n'
            'TÜBİTAK ve üniversitelerle iş birliği ile hazırlanan müfredat, '
            'dünya standartlarında eğitim sunmayı hedefliyor.\n\n'
            'Robotik kodlama ile geleceğin mühendisleri yetişiyor! 🚀',
        imageUrl: null,
        likes: ['user14', 'user15', 'user16', 'user17', 'user18'],
        commentCount: 0,
        createdAt: now.subtract(const Duration(hours: 24)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sosyal Akış',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          if (currentUser != null)
            IconButton(
              icon: const Icon(Icons.add_box_outlined, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePostScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      // TODO: Migrate to Supabase - Stream type mismatch
      body: StreamBuilder<List<dynamic>>(
        stream: _feedService.getPostsStream(limit: 50),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Bir hata oluştu: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const FeedPostSkeleton(),
            );
          }

          var posts = snapshot.data ?? [];

          // Eğer post yoksa veya az sayıda varsa, sabit robotik içerikleri ekle
          if (posts.isEmpty || posts.length < 3) {
            final samplePosts = _getSampleRoboticPosts();
            posts = [...samplePosts, ...posts];
          }

          if (posts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz paylaşım yok',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlk paylaşımı siz yapın!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  if (currentUser != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreatePostScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Paylaşım Yap'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return PostCard(
                  post: posts[index],
                  currentUser: currentUser,
                  feedService: _feedService,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PostCard extends StatefulWidget {
  final Post post;
  final UserModel? currentUser;
  final FeedService feedService;

  const PostCard({
    super.key,
    required this.post,
    required this.currentUser,
    required this.feedService,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.currentUser != null &&
        widget.post.isLikedBy(widget.currentUser!.id);

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _likeAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }

  void _handleLike() async {
    if (widget.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Beğenmek için giriş yapmalısınız')),
      );
      return;
    }

    setState(() {
      _isLiked = !_isLiked;
    });

    _likeAnimationController.forward().then((_) {
      _likeAnimationController.reverse();
    });

    try {
      await widget.feedService.toggleLike(
        widget.post.id,
        widget.currentUser!.id,
      );
    } catch (e) {
      setState(() {
        _isLiked = !_isLiked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bir hata oluştu: $e')),
        );
      }
    }
  }

  void _showComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsScreen(
          post: widget.post,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  void _showOptions() {
    final isOwnPost = widget.currentUser?.id == widget.post.userId;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwnPost) ...[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Düzenle'),
                onTap: () {
                  Navigator.pop(context);
                  _editPost();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Sil'),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('İptal'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _editPost() {
    final controller = TextEditingController(text: widget.post.description);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paylaşımı Düzenle'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Açıklama...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // TODO: Migrate to Supabase - updatePost signature changed
                await widget.feedService.updatePost(
                  widget.post.id,
                  {'description': controller.text},
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paylaşım güncellendi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _deletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paylaşımı Sil'),
        content: const Text('Bu paylaşımı silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // TODO: Migrate to Supabase - deletePost signature changed
                await widget.feedService.deletePost(widget.post.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Paylaşım silindi')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  String _getRoleBadge(String? role) {
    switch (role) {
      case 'admin':
        return '👑 Admin';
      case 'teacher':
        return '👨‍🏫 Öğretmen';
      case 'parent':
        return '👨‍👩‍👧 Veli';
      case 'student':
        return '🎓 Öğrenci';
      default:
        return '';
    }
  }

  /// Extract URLs from text
  String? _extractUrl(String text) {
    final urlPattern = RegExp(
      r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      caseSensitive: false,
    );

    final match = urlPattern.firstMatch(text);
    return match?.group(0);
  }

  /// Launch URL in external browser
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link açılamadı')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundImage: widget.post.userPhotoUrl != null
                  ? CachedNetworkImageProvider(widget.post.userPhotoUrl!)
                  : null,
              child: widget.post.userPhotoUrl == null
                  ? Text(
                      widget.post.userName[0].toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            title: Row(
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (widget.post.userRole != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    _getRoleBadge(widget.post.userRole),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
            subtitle: Text(
              timeago.format(widget.post.createdAt, locale: 'tr'),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: _showOptions,
            ),
          ),

          // Image
          if (widget.post.imageUrl != null)
            widget.post.imageUrl!.startsWith('assets/')
                ? Image.asset(
                    widget.post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 64),
                    ),
                  )
                : CachedNetworkImage(
                    imageUrl: widget.post.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const AspectRatio(
                      aspectRatio: 1,
                      child: SkeletonLoader(height: double.infinity),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error, size: 64),
                    ),
                  ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _likeAnimation,
                  child: IconButton(
                    icon: Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      color: _isLiked ? Colors.red : null,
                    ),
                    onPressed: _handleLike,
                  ),
                ),
                Text(
                  '${widget.post.likes.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: _showComments,
                ),
                Text(
                  '${widget.post.commentCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Description
          if (widget.post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: '${widget.post.userName} ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: widget.post.description),
                  ],
                ),
              ),
            ),

          // Link Preview
          if (widget.post.description.isNotEmpty && _extractUrl(widget.post.description) != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  final url = _extractUrl(widget.post.description)!;
                  _launchUrl(url);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnyLinkPreview(
                      link: _extractUrl(widget.post.description)!,
                      displayDirection: UIDirection.uiDirectionVertical,
                      cache: const Duration(hours: 1),
                      backgroundColor: Colors.white,
                      removeElevation: true,
                      borderRadius: 0,
                      titleStyle: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      bodyStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                      bodyMaxLines: 2,
                      bodyTextOverflow: TextOverflow.ellipsis,
                      errorBody: 'Link önizlemesi yüklenemedi',
                      errorTitle: 'Hata',
                      errorWidget: Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: Colors.grey[600], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _extractUrl(widget.post.description)!,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

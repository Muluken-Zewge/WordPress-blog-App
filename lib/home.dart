import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:html/parser.dart';
import 'package:word_press_api/post_detail_screen.dart';
import 'package:word_press_api/services/ad_mob_service.dart';
import 'package:word_press_api/services/post_service.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final postService = PostService();

  BannerAd? bannerAd;
  final List<BannerAd?> bannerAds = [];

  InterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();
    final postService = PostService();
    postService.fetchPosts();

    createInterstitialAd();
  }

  void createBannerAds(int count) {
    bannerAds.clear();
    for (int i = 0; i < count; i++) {
      final bannerAd = BannerAd(
        size: AdSize.fullBanner,
        adUnitId: AdMobService.bannerAdUnitId!,
        listener: AdMobService.bannerListener,
        request: const AdRequest(),
      );
      bannerAd.load();
      bannerAds.add(bannerAd);
    }
  }

  void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AdMobService.interstitialAdUnitId!,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (ad) => interstitialAd = ad,
            onAdFailedToLoad: (LoadAdError error) => interstitialAd = null));
  }

  void showInterstitialAd() {
    if (interstitialAd != null) {
      interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          createInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          createInterstitialAd();
        },
      );
      interstitialAd!.show();
      interstitialAd = null;
    }
  }

  String stripHtmlTags(String htmlString) {
    final document = parse(htmlString);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BoleNav Blog'),
      ),
      body: Container(
        color: Colors.blue.shade100,
        child: FutureBuilder(
            future: postService.fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No posts available.'));
              } else {
                final posts = snapshot.data!;
                final adCount = posts.length ~/ 5;

                createBannerAds(adCount);

                return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: posts.length + adCount,
                    itemBuilder: (BuildContext context, int index) {
                      if ((index + 1) % 6 == 0) {
                        final adIndex = (index + 1) ~/ 6 - 1;
                        final bannerAd = bannerAds[adIndex];
                        if (bannerAd == null) return const SizedBox.shrink();
                        return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: SizedBox(
                              width: bannerAd.size.width.toDouble(),
                              height: bannerAd.size.height.toDouble(),
                              child: AdWidget(
                                ad: bannerAd,
                              ),
                            ));
                      } else {
                        final adjustedIndex = index - (index ~/ 6);
                        final post = posts[adjustedIndex];
                        DateTime dateTime = DateTime.parse(post.date);
                        String formattedDate =
                            DateFormat('MMMM d, yyyy').format(dateTime);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: Row(children: [
                              SizedBox(
                                  width: 100,
                                  height: 220,
                                  child: Image.network(
                                    post.mediaUrl,
                                    fit: BoxFit.cover,
                                  )),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            post.catagory,
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            post.title,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                                color: Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Hero(
                                          tag: post.title,
                                          child: Text(
                                            stripHtmlTags(post.content),
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                decoration:
                                                    TextDecoration.none),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Align(
                                        alignment: Alignment.bottomLeft,
                                        child: TextButton(
                                          onPressed: () {
                                            showInterstitialAd();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PostDetailScreen(
                                                        post: post),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            "Read Post >>",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        );
                      }
                    });
              }
            }),
      ),
    );
  }
}

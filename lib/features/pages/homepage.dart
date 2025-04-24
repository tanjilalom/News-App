// home_page.dart

import 'package:flutter/material.dart';
import 'package:web_scraping_with_flutter/features/pages/bajus_prices_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/news_screen.dart';
import 'package:web_scraping_with_flutter/features/pages/prothomalo_screen.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildNewsButton(BuildContext context, String title, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RSSFeedWidget(rssUrl: url),
            ),
          );
        },
        child: Text(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Portals'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildNewsButton(context, 'Kaler Kantho', 'https://www.kalerkantho.com/rss.xml'),
            buildNewsButton(context,'Prothom Alo', 'https://www.prothomalo.com/collection/latest'),



            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => GoldSilverRateScreen(),));
            }, child: Text('Bajus')),


            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => NewsListScreen(),));
            }, child: Text('prothom alo'))
            
            
            
            
            // Add more buttons for other news portals here
          ],
        ),
      ),
    );
  }
}

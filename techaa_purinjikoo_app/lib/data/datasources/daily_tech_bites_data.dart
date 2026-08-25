class DailyTechBite {
  final String id;
  final String title;
  final String iconEmoji;
  final String tag;
  final String storyTanglish;
  final String takeaway;
  final int xpReward;

  const DailyTechBite({
    required this.id,
    required this.title,
    required this.iconEmoji,
    required this.tag,
    required this.storyTanglish,
    required this.takeaway,
    this.xpReward = 15,
  });
}

class DailyTechBitesData {
  static List<DailyTechBite> getBites() {
    return [
      const DailyTechBite(
        id: 'bite_whatsapp',
        title: 'How WhatsApp handles 2 Billion users with just 50 Engineers?',
        iconEmoji: '💬',
        tag: 'Scalability',
        storyTanglish: 'WhatsApp-la 200 crore users daily message anupuraanga, aana engineering team size only around 50! Secret enna theriyuma? They used Erlang and FreeBSD. Erlang-la single server-e 20 lakh active connections handle pannum. Heavy frameworks use pannama, simple lightweight actor model architecture vechaanga!',
        takeaway: 'Smart architecture beats hiring 1000 developers.',
      ),

      const DailyTechBite(
        id: 'bite_cloudflare',
        title: 'Cloudflare down aana 20% Internet yen freeze aachu?',
        iconEmoji: '🛡️',
        tag: 'Networking',
        storyTanglish: '2022-la oru single BGP router config mistake-la Discord, Shopify, Canva ellame down aachu. Cloudflare is a Reverse Proxy standing in front of millions of websites for DDoS security & caching. Cloudflare-la error vantha, pinnadi irukra backend servers live-ah irundhalum traffic reach aagadhu!',
        takeaway: 'Reverse Proxies protect websites but create a single point of failure if misconfigured.',
      ),

      const DailyTechBite(
        id: 'bite_git_origin',
        title: 'Why Git was built in just 10 Days by Linus Torvalds?',
        iconEmoji: '🐙',
        tag: 'Open Source',
        storyTanglish: '2005-la Linux kernel developers used a commercial tool called BitKeeper. Free license cancel aanathum, Linux creator Linus Torvalds got furious. 10 days room-kulla lock aagi ezhuthina tool dhaan Git! Today 100% of software companies on earth run on Git.',
        takeaway: 'Great developer tools are born out of solving extreme developer frustration.',
      ),

      const DailyTechBite(
        id: 'bite_cables',
        title: 'Undersea Fiber Cables: How your reels cross the Pacific Ocean',
        iconEmoji: '🌊',
        tag: 'Internet',
        storyTanglish: 'Namma phone-la Instagram reel paakumbothu satellite illa, kadal-kulla 1.4 million kilometers thoorathuku irukkura glass fiber cables dhaan data carry pannuthu! Sharks bite pannama irukka heavy steel armor layer pottu ocean floor-la potrupaanga. Light speed-la total globe connect aaguthu!',
        takeaway: '99% of global internet traffic travels through undersea optical fiber, not satellites.',
      ),
    ];
  }

  static DailyTechBite getTodayBite() {
    final bites = getBites();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return bites[dayOfYear % bites.length];
  }
}

enum Categories {
  classic(
    title: 'Classic',
    bgImageUrl:
        'https://assets.teenvogue.com/photos/623a3806c628b7bd3f666a37/16:9/w_1280,c_limit/BookRoundup_Mar-22_2022_HEADER.jpg',
  ),
  dystopian(
    title: 'Dystopian',
    bgImageUrl:
        'https://www.thecuriousreader.in/wp-content/uploads/2020/06/List-2019-2-_Cover-10-Feminist-Dystopian-Novels-That-Are-Not-%E2%80%98The-Handmaids-Tale%E2%80%99.png',
  ),
  romance(
    title: 'Romance',
    bgImageUrl:
        'https://www.ocregister.com/wp-content/uploads/2023/06/image-2023-06-22T162208.812.jpg?w=978',
  ),
  fantasy(
    title: 'Fantasy',
    bgImageUrl:
        'https://culturefly.co.uk/wp-content/uploads/2021/11/fantasy-books.png',
  ),
  thriller(
    title: 'Thriller',
    bgImageUrl:
        'https://s26162.pcdn.co/wp-content/uploads/sites/2/2018/12/Crime.png',
  ),
  adventure(
    title: 'Adventure',
    bgImageUrl:
        'https://cdn.outsideonline.com/wp-content/uploads/2020/12/11/best-travel-books-2020_h.jpg',
  ),
  postApocalyptic(
    title: 'Post-Apocalyptic',
    bgImageUrl:
        'https://thenerddaily.com/wp-content/uploads/2023/04/10-Post-Apocalyptic-Books-for-Fans-of-The-Last-of-Us.jpg?x91531',
  ),
  sciFi(
    title: 'Sci-fi',
    bgImageUrl:
        'https://spy.com/wp-content/uploads/2020/04/best-science-fiction-books.jpg?w=675',
  ),
  ;

  final String title;
  final String bgImageUrl;

  const Categories({
    required this.title,
    required this.bgImageUrl,
  });
}

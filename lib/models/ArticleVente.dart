class ArticleVente {
  late int id, qteStock;
  late int prixUnitaire;
  late String libelle;

  ArticleVente(
      {required this.id,
      required this.libelle,
      required this.prixUnitaire,
      required this.qteStock});

  /* static List<ArticleVente> getArticlesVente(){
    var x= getArticles();
   } */

  factory ArticleVente.fromJson(dynamic json) {
    return ArticleVente(
        id: json['id'] as int,
        libelle: json['article']['libelle'] as String,
        prixUnitaire: json['prixUnitaire'] as int,
        qteStock: json['stock']['qteStock'] as int);
  }
}

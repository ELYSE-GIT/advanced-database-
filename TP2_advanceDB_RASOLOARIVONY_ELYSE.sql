/* RASOLOARIVONY ELYSE */




/*1.    LISTE DES NOMS, DES PRENOMS ET DES DATES DE NAISSANCE DE TOUS LES ELEVES */
select
    "NOM",
    "PRENOM",       
    "DATE_NAISSANCE"
from "ELEVES";

/*
Result Set 1

NOM	PRENOM	DATE_NAISSANCE
Brisefer	Benoit	10-12-1978
Génial	Olivier	10-04-1978
Jourdan	Gil	28-06-1974
Spring	Jerry	16-02-1974
Tsuno	Yoko	29-10-1977
Lebut	Marc	29-04-1974
Lagaffe	Gaston	08-04-1975
Dubois	Robin	20-04-1976
Walthéry	Natacha	07-09-1977
Danny	Buck	15-02-1973

Download CSV
10 rows selected.          
*/





/*2.    TOUS LES RENSEIGNEMENTS SUR TOUTES LES ACTIVITES */

select *
from "ACTIVITES";

/*
Result Set 2

NIVEAU	NOM	EQUIPE
1	Mini foot	Amc Indus
1	Surf	Les planchistes ...
2	Tennis	Ace Club
3	Tennis	Ace Club
1	Volley ball	Avs80
2	Mini foot	Les as du ballon
2	Volley ball	smash

Download CSV
7 rows selected.

*/





/*3.    LISTE DES SPECIALITES DES PROFESSEURS */
select 
    "SPECIALITE"
from "PROFESSEURS";

/*

Result Set 3

SPECIALITE
poésie
réseau
poo
sql
sql
poo
 - 
sql

Download CSV
8 rows selected.
*/




/*4.    OBTENIR LE NOM ET PRENOM DES ELESVES PESANT MOINS DE 45 KILOS ET INSCRITS EN 1ère ANNEE */

select
    NOM,
    PRENOM 
from ELEVES where (POIDS<=45 and ANNEE=1) or ANNEE=2;

/*
Result Set 4

NOM	PRENOM
Brisefer	Benoit
Génial	Olivier
Jourdan	Gil
Spring	Jerry
Tsuno	Yoko
Lebut	Marc
Dubois	Robin
Danny	Buck

Download CSV
8 rows selected.
*/


/*5.    OBTENIR LE NOM DES ELEVES DONT LE POIDS EST COMPRIS ENTRE 60 ET 80 KG */ 

select
    NOM,
    PRENOM 
from ELEVES where (POIDS>=60 and POIDS<=80);

/* 
Result Set 5

NOM	PRENOM
Jourdan	Gil
Spring	Jerry
Lebut	Marc
Lagaffe	Gaston
Dubois	Robin

Download CSV
5 rows selected.
*/



/*6.    OBTENIR LE NOM DES PROFESSEURS DONT LA SPECIALITE EST "POESIE" ou SQL */
select
    NOM
from PROFESSEURS where (SPECIALITE='poésie' or SPECIALITE='sql');

/*
Result Set 8

NOM
Bottle
Pastecnov
Selector
Pucette

Download CSV
4 rows selected.
*/



/*7.    OBTENIR LE NOM DES ELEVES DONT LE NOM COMMENCE PAR "L */ 
select
    NOM
from ELEVES where NOM LIKE 'L%'

/* 
NOM
Lebut
Lagaffe

Download CSV
2 rows selected.

*/





/*8.   OBTENIR LE NOM DES PROFESSEURS DONT LA SPECIALITE EST INCONNUE */
select
    NOM
from PROFESSEURS where SPECIALITE is null;

/*
Result Set 10

NOM
Francesca

Download CSV

*/



/*9.   OBTENIR LE NOM ET PRENOM DES ELEVES PESANT MOINS DE 45 KG ET INSCRIT EN PREMIERE ANNEE */
select
    NOM,
    PRENOM 
from ELEVES where (POIDS<=45 and ANNEE=1)

/*
Result Set 11

NOM	PRENOM
Brisefer	Benoit
Génial	Olivier
Tsuno	Yoko

Download CSV
3 rows selected.
*/




/*10.   OBTENIR POUR CHAQUE PROFESSEUR, SON NOM ET SA SPECIALITE */
/* Methode 1*/
select 
    NOM, 
    SPECIALITE 
from PROFESSEURS PNoNull where SPECIALITE is not null 
UNION 
select 
    NOM, 
    '***' 
from PROFESSEURS Pnull where SPECIALITE is null;

/* Methode 2*/

select last_name
     , coalesce(commision_pct, 'No Commission')
from employees;

/*
Result Set 16

NOM	SPECIALITE
Bolenov	réseau
Bottle	poésie
Francesca	***
Pastecnov	sql
Pucette	sql
Selector	sql
Tonilaclasse	poo
Vilplusplus	poo

Download CSV
8 rows selected.
*/


/* A PARTIR DE MAINTENANT, ON NE VA PLUS ECRIRE LES OUTPUTS ET ON VA EGALEMENT ECRIRE EN MINUSCULE SYNTAXIQUEMENT*/

/*11.   NOMS ET PRENOMS DES ELEVES QUI PRATIQUENT DU SURF AU NIVEAU 1 AVEC CINQ FACONS DIFFERENTES*/

select ELEVES.NOM , PRENOM from ELEVES join ACTIVITES_PRATIQUEES using(NUM_ELEVE) where NIVEAU = 1  and ACTIVITES_PRATIQUEES.NOM = 'Surf'; 
select eleves.nom , prenom from eleves left join ACTIVITES_PRATIQUEES using(num_eleve) where niveau = 1  and ACTIVITES_PRATIQUEES.nom = 'Surf';
select eleves.nom , prenom from eleves right join ACTIVITES_PRATIQUEES using(num_eleve) where niveau = 1  and ACTIVITES_PRATIQUEES.nom = 'Surf';
select eleves.nom , prenom from eleves full join ACTIVITES_PRATIQUEES on eleves.num_eleve = ACTIVITES_PRATIQUEES.num_eleve where niveau = 1  and ACTIVITES_PRATIQUEES.nom = 'Surf';
select e.nom , e.prenom from eleves e, ACTIVITES_PRATIQUEES a where e.num_eleve = a.num_eleve and a.niveau = 1  and a.nom = 'Surf';

/*12.   Obtenir le nom des élèves de l'équipe AMC INDUS*/
select e.nom from eleves e join (select * from activites_pratiquees natural join activites) using(num_eleve)  where equipe = 'Amc Indus';

/*13.	Obtenir les pairs de noms de professeurs qui ont la même spécialité.*/
select distinct p1.nom, p2.nom , p1.specialite, p2.specialite from professeurs p1 cross join professeurs p2 where p1.specialite = p2.specialite and p1.nom < p2.nom;

/*14.	Pour chaque spécialité sql/SQL, on demande d'obtenir son nom son salaire mensuel actuel et son augmentation mensuelle depuis son salaire de base.*/
select nom, salaire_actuel/12, (salaire_actuel/12) - (salaire_base/12)   from professeurs where specialite = 'sql';

/*15.	Obtenir le nom des professeurs dont l'augmentation relative au salaire de base dépasse 25%.*/
select nom  from professeurs where (salaire_actuel - salaire_base) > (0.25 * salaire_base);

/*16.	Afficher les points de Tsuno obtenus dans chaque cours sur 100 plutôt que sur 20.*/
select nom, points*5 from eleves natural join resultats where nom = 'Tsuno';

/*17.	Obtenir le poids moyen des élèves de 1 ère année.*/
select avg(poids) from eleves where annee = 1;


/*18.	Obtenir le total des points de l'élève numéro 3.*/
select sum(points) from eleves natural join resultats where num_eleve = 3;

/*19.	Obtenir la plus petite et la plus grande cote de l'élève Brisefer.*/
select max(points), min(points) from eleves natural join resultats where nom = 'Brisefer';

/*20.	Obtenir le nombre d'élèves inscrits en deuxième année.*/
select count(nom) from eleves where annee = 2;

/*21. Quelle est l'augmentation mensuelle moyenne des salaires des professeurs de SQL ?*/
select sum((salaire_actuel/12) - (salaire_base/12))/count(nom)   from professeurs where specialite = 'sql';

/*22.	Obtenir l'année de la dernière promotion du professeur Pucette.*/
select SUBSTR(der_prom,7) from professeurs where nom  = 'Pucette';

/*23.	Pour chaque professeur, afficher sa date d'ébauche, sa date de dernière promotion ainsi que le nombre d'années écoulées entre ces deux dates.*/
select nom, date_entree, der_prom , SUBSTR(der_prom,7) - SUBSTR(date_entree,7) from professeurs;

/*24.	Afficher l'âge moyen des élèves. Cet âge moyen sera exprimé en année.*/
select avg(2021 - SUBSTR(date_naissance,7)) from eleves;

/*25.	Afficher le nom des professeurs pour lesquels il s'est écoulé plus de 50 mois entre l'embauche et la première promotion.*/
select nom  from professeurs where (SUBSTR(der_prom,7) - SUBSTR(date_entree,7))*12 > 50;

/*26.	Obtenir la liste des élèves qui auront au moins 24 ans dans moins de 4 mois.*/
select nom from eleves where 2021 - SUBSTR(date_naissance,7) > 24;

/*27.	Obtenir une liste des élèves classés par année et par ordre alphabétique.*/
select nom, annee from eleves order by  annee asc,nom asc;

/*28.	Afficher en ordre décroissant les points de Tsuno obtenus dans chaque cours sur 100 plutôt que sur 20.*/
select  c.nom, sum(points*5) from eleves e join (select * from resultats join cours using(num_cours)) c using(num_eleve) where e.nom = 'Tsuno'  group by c.nom order by sum(points*5) desc;

/*29.	Obtenir pour chaque élève de 1 ère année son nom et sa moyenne.*/
select nom, avg(points) from eleves natural join resultats where annee = 1 group by nom;

/*30.	Obtenir la moyenne des points de chaque élève de l ere année dont le total des points est supérieur à 40.*/
select nom, avg(points),sum(points) from eleves natural join resultats where (annee = 1 ) group by nom having sum(points)>40;

/*31.	Obtenir le maximum parmi les totaux de chaque élève.*/
select sum(points) from eleves natural join resultats group by nom;

/*32.	Obtenir le nom des élèves qui jouent dans l'équipe AMC INDUS.*/
select e.nom from eleves e join (select * from activites_pratiquees natural join activites) using(num_eleve)  where equipe = 'Amc Indus';

/*33.	Quels sont les élèves de 1 ère année dont la moyenne est supérieure à la moyenne de la 1 ère année ?*/
select nom from eleves natural join resultats where (annee = 1) group by nom having  avg(points) >(select avg(points) from eleves natural join resultats where (annee =1));

/*34.	Obtenir le nom et le poids des élèves de 1 ère année plus lourds que n'importe quel élève de 2 ème année.*/
select nom, poids from eleves where annee = 1 and (poids > (select max(poids) from eleves where annee =2));

/*35.	Obtenir le nom et le poids des élèves de 1 ère année plus lourds qu'un élève quelconque de 2 ème année.*/
select nom, poids from eleves where annee = 1 and (poids > (select min(poids) from eleves where annee =2));

/*36.	Obtenir le nom, le poids et l'année des élèves dont le poids est supérieur au poids moyen des élèves étant dans la même année d'études.*/
select  nom, sum(poids), sum(annee) from eleves where (annee = 1) group by nom having avg(poids) >(select avg(poids) from eleves where (annee =1)) union select  nom, sum(poids), sum(annee) from eleves where (annee = 2) group by nom having avg(poids) >(select avg(poids) from eleves where (annee =2))

/*37.	Obtenir le nom des professeurs qui ne donnent pas le cours numéro 1.*/
select distinct nom from professeurs natural join charge where num_cours != 1;

/*38.	Obtenir le nom des élèves de 1 ère année qui ont obtenu plus de 60 % et qui jouent au tennis.*/
select e.nom from eleves e natural join resultats join activites_pratiquees a using(num_eleve) where a.nom = 'Tennis' group by e.nom having avg(points)> 12;

/*39.	Professeurs qui prennent en charge tous les cours de deuxième année ; on demande le Numéro et le nom.*/
select  p.nom , c.nom from professeurs p  join charge using(num_prof)  join cours c using(num_cours) where annee = 2; //PAS FINI

/*40.	Élèves qui pratiquent toutes les activités ; on demande le Numéro et le nom.*/


Name: RASOLOARIVONY ELYSE

/*CONTRAINTES*/

/* 1) */
/*Note d'un étudiant entre 0 et 20*/
ALTER TABLE RESULTATS ADD CONSTRAINT CK_RESULTATS_POINTS CHECK (POINTS BETWEEN '0' AND '20');

/* Le sexe d'un étudiant doit être dans la liste 'm','M','f','F' ou 'Null'*/
ALTER TABLE ELEVES ADD CONSTRAINT CK_ELEVES_SEXE CHECK (SEXE IN ('m','M','f','F','NULL'));

/* 	Contrainte horizontale : Le salaire de base d'un professeur	doit être inférieur au salaire actuel.*/
ALTER TABLE PROFESSEURS ADD CONSTRAINT CK_PROFESSEURS_SALAIRE CHECK (SALIRE_BASE<=SALAIRE_ACTUEL);

/*Contrainte verticale : Le salaire d'un professeur ne doit pas dépasser le double de la moyenne des salaires des enseignants de la même spécialité. */
ALTER TABLE PROFESSEURS ADD CONSTRAINT CK_SALAIRE_DOUBLE CHECK(NUM_PROF IN (SELECT NUM_PROF FROM PROFESSEURS P1 WHERE SALAIRE_ACTUEL<=(SELECT 2*AVG(SALAIRE_ACTUEL) FROM PROFESSEURS P2 GROUP BY SPECIALITE HAVING SPECIALITE=P1.SPECIALITE))); 

/* 2) => Cette contrainte ne marche pas, parce qu’il s’agit d’une contrainte verticale, on a besoin d’un trigger pour l’effectuer. */



/* TRIGGERS : */

/*1.  Créons un trigger permettant de vérifier la contrainte : « Le salaire d'un Professeur ne peut pas diminuer » :*/
CREATE OR REPLACE TRIGGER SALAIRE_DIM      
    BEFORE update of SALAIRE_ACTUEL on PROFESSEURS     
    FOR EACH ROW     
    WHEN (New.SALAIRE_ACTUEL < Old.SALAIRE_ACTUEL)  
declare DIMINUE_SALAIRE exception; 
BEGIN raise DIMINUE_SALAIRE; exception 
when DIMINUE_SALAIRE 
then raise_application_error(-20001,'Le salaire ne peut pas diminuer'); 
end; 
/


/* 2. Gestion automatique de la redondance :*/  
/*création de la table prof_specialite : */
CREATE TABLE PROF_SPECIALITE ( SPECIALITE VARCHAR2(20), NB_PROFESSEURS NUMBER, CONSTRAINT PK_PROF_SPECIALITE PRIMARY KEY(SPECIALITE) );  

/*Créeons  un trigger permettant de remplir et mettre à jour automatiquement cette table suite à chaque opération de MAJ (insertion, suppression, modification) sur la table des professeurs :*/ 
CREATE OR REPLACE TRIGGER MAJProf_SPE 
AFTER INSERT OR DELETE OR UPDATE OF SPECIALITE ON PROFESSEURS 
FOR EACH ROW    
    DECLARE    
    RES1 NUMBER;    
    RES2 NUMBER;    
    BEGIN       
        IF Inserting  THEN      
        SELECT COUNT(SPECIALITE) INTO RES1 FROM PROF_SPECIALITE WHERE 
SPECIALITE =:NEW.SPECIALITE;        
        IF RES1 = 0 THEN        
        INSERT INTO PROF_SPECIALITE VALUES (:NEW.SPECIALITE, 1);        
        ELSE         
        UPDATE PROF_SPECIALITE SET 
        NB_PROFESSEURS = NB_PROFESSEURS+1 
WHERE SPECIALITE=:NEW.SPECIALITE;        
        END IF;      
    END IF;     
   IF Deleting THEN     
   SELECT NB_PROFESSEURS INTO RES2 FROM PROF_SPECIALITE WHERE  
SPECIALITE=:OLD.SPECIALITE;        
        IF RES2 != 0 THEN        
        UPDATE PROF_SPECIALITE  SET NB_PROFESSEURS = NB_PROFESSEURS-1 
WHERE SPECIALITE = :OLD.SPECIALITE;        
        ELSE         
        DELETE FROM PROF_SPECIALITE WHERE SPECIALITE = :OLD.SPECIALITE;        
        END IF;     
    END IF;    
   IF UPDATING THEN  
    if :old.SPECIALITE != :new.SPECIALITE then       
        UPDATE PROF_SPECIALITE SET NB_PROFESSEURS = NB_PROFESSEURS-1 WHERE SPECIALITE=:OLD.SPECIALITE;       
        UPDATE PROF_SPECIALITE SET NB_PROFESSEURS = NB_PROFESSEURS+1 WHERE SPECIALITE=:NEW.SPECIALITE;   
    END IF; 
   END IF;
END;
/





/* Test de trigger sur des exemples mise à jour*/

/*Insertion : */

/* On affiche la table prof_specialite avant de faire l’insertion dans la table professeurs : */
SELECT * FROM PROF_SPECIALITE;

/* On insère des données dans la table professeurs, et on affiche la table prof_specialite : La table prof_specialite est bien mise à jour après l’insertion dans la table professeurs. */
Insert into PROFESSEURS (Num_prof, nom, specialite, Date_entree, Der_prom, Salaire_base, Salaire_actuel)
Values (10,'Marie','sql','22-05-2012','07-02-2015','2000000','2500000');

/*Suppression : */
/* Supprimons la ligne insérée*/
DELETE FROM PROFESSEURS WHERE Num_prof=10;

/*3. Mise à jour en cascade*/
CREATE OR REPLACE TRIGGER MAJ_CHARGE 
AFTER DELETE OR UPDATE OF NUM_PROF ON PROFESSEURS 
FOR EACH ROW  
BEGIN 
    IF DELETING THEN 
        DELETE FROM CHARGE WHERE NUM_PROF=:OLD.NUM_PROF; 
    END IF; 
    IF UPDATING THEN  
        UPDATE CHARGE SET NUM_PROF=:NEW.NUM_PROF where 
        NUM_PROF=:OLD.NUM_PROF; 
    END IF; 
END; 
/

/*Exemple de suppression: On affiche la table charge*/
select * from charge;
delete from professeurs where num_prof=7;
select * from charge;

/*Exemple de update*/
update professeures set num_prof=10 where num_prof=3;
select * from charge;


/*4 Sécurité: enregistrement des accès */

/*Créons la table audit_resultats : */
CREATE TABLE AUDIT_RESULTATS ( UTILISATEUR VARCHAR2(50), DATE_MAJ date, DESC_MAJ VARCHAR2(20), NUM_ELEVE NUMBER (4) NOT NULL, NUM_COURS NUMBER (4) NOT NULL, POINTS NUMBER);

/* Le trigger qui met à jours la table audit_resultats à chaque modification de la table RESULTAT : */
CREATE OR REPLACE TRIGGER MAJ_AUD_RESULTAT 
AFTER INSERT OR DELETE OR UPDATE ON RESULTATS 
FOR EACH ROW 
BEGIN   
    IF DELETING THEN     
        INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)     
        VALUES(USER, SYSDATE, 'DELETE', :OLD.NUM_ELEVE, :OLD.NUM_COURS, :OLD.POINTS);   
    ELSIF INSERTING THEN     
        INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)    
        VALUES(USER, SYSDATE, 'INSERT', :NEW.NUM_ELEVE, :NEW.NUM_COURS, :NEW.POINTS);   
    ELSE    
        INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)     
        VALUES(USER, SYSDATE, 'NOUVEAU', :NEW.NUM_ELEVE, :NEW.NUM_COURS, :NEW.POINTS);     
        INSERT INTO AUDIT_RESULTATS (UTILISATEUR, DATE_MAJ, DESC_MAJ, NUM_ELEVE, NUM_COURS, POINTS)     
        VALUES(USER, SYSDATE, 'ANCIEN', :OLD.NUM_ELEVE, :OLD.NUM_COURS, :OLD.POINTS);   
    END IF; 
END; /

/* Exemple d'insertion : */
select * from audit_resultats;
insert into resultats values (12,5,10);
select * from audit_resultats;

/* Exemple de suppression : */
select * from audit_resultats;
delete from resultats where num_eleve=13;
select * from audit_resultats;

/* Exemple de Update : */
insert into resultats values (15,4,12);
update resultats set points=16 where num_eleve=;
select * from audit_resultats;



/* 5. Confidentialité : */

/*Seul l'utilisateur 'GrandChef' puisse augmenter les salaires des professeurs de plus de 20%. 
Le trigger retourner une erreur (No -20002) et le message 'Modification interdite' 
si la condition n’est pas respectée : */
create or replace trigger modification_GrandChef 
BEFORE UPDATE ON PROFESSEURS 
FOR EACH ROW 
DECLARE   
    v_user VARCHAR(30);   
    salaire NUMBER; 
BEGIN   
    select user into v_user   
    from dual;   
    if (:new.SALAIRE_ACTUEL - :old.SALAIRE_ACTUEL) > (:old.SALAIRE_ACTUEL * 0.2) and v_user != 'GrandChef' THEN     raise_application_error(-20002,'modification interdite');   
    END IF ; 
END; 
/


/*D. FONCTIONS ET PROCEDURES : */

/*1. Une fonction fn_moyenne calculant la moyenne d'un étudiant passé en paramètre : */
CREATE OR REPLACE FUNCTION FN_MOYENNE(PNUM RESULTATS.NUM_ELEVE%TYPE) 
RETURN NUMBER IS MOYENNE NUMBER; 
BEGIN 
    SELECT AVG(POINTS) INTO MOYENNE FROM RESULTATS  WHERE NUM_ELEVE=PNUM; 
    RETURN MOYENNE; 
END; 
/

/* Application, moyenne des notes de l'élève numéro 9 */
select FN_MOYENNE(9) from dual;


/*2. Une procédure pr_resultat permettant d'afficher la moyenne de chaque élève avec la mention adéquate : échec, passable, assez bien, bien, très bien : */
CREATE OR REPLACE PROCEDURE pr_resultat is 
BEGIN 
DECLARE 
CURSOR mesEleves is 
select (select nom|| ' ' ||prenom from eleves where num_eleve = R.num_eleve) as nom, avg(R.points) as moyenne from resultats R group by num_eleve; 
BEGIN         
        FOR eleve in mesEleves LOOP             
            IF eleve.moyenne < 10 THEN                 
                DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Echec');             
            ELSIF eleve.moyenne >= 10 AND eleve.moyenne < 12 THEN                 
                DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Passable');             
            ELSIF eleve.moyenne >= 12 AND eleve.moyenne < 14 THEN                 
                DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Assez Bien');             
            ELSIF eleve.moyenne >= 14 AND eleve.moyenne < 16 THEN                
                 DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Bien');             
            ELSE                 
                 DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Très Bien !');             
            END IF;         
        END LOOP; 
    END; 
END; 
/




/*3. Un package contenant ces fonctions et procédures : */
CREATE OR REPLACE PACKAGE eleves_resultats is     
    FUNCTION FN_MOYENNE(num number) return NUMBER;     
    PROCEDURE pr_resultat; 
END eleves_resultats; 
/ 
CREATE OR REPLACE PACKAGE BODY eleves_resultats IS     
    FUNCTION FN_MOYENNE(num number)      
    RETURN number IS         
        MOYENNE NUMBER;      
    BEGIN         
        SELECT avg(points) into moyenne         
        FROM resultats        
        where NUM_ELEVE = num;         
        RETURN moyenne;      
    END FN_MOYENNE;          
    
    PROCEDURE pr_resultat is     
    BEGIN         
        DECLARE             
            CURSOR mesEleves is             
            select (select nom|| ' ' ||prenom              
            from eleves where num_eleve = R.num_eleve) as nom, avg(R.points) as moyenne             
            from resultats R              
            group by num_eleve;         
        BEGIN             
            FOR eleve in mesEleves LOOP 
                IF eleve.moyenne < 10 THEN                     
                    DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Echec');                 
                ELSIF eleve.moyenne >= 10 AND eleve.moyenne < 12 THEN                     
                    DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Passable');                 
                ELSIF eleve.moyenne >= 12 AND eleve.moyenne < 14 THEN                     
                    DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Assez Bien');                 
                ELSIF eleve.moyenne >= 14 AND eleve.moyenne < 16 THEN                     
                    DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Bien');                 
                ELSE                     
                    DBMS_OUTPUT.PUT_LINE(eleve.nom || ' ' || eleve.moyenne || ' Très Bien !');                 
                END IF;             
            END LOOP;         
    END;     END pr_resultat; 
END eleves_resultats; 
/  


execute ELEVES_RESULTATS.pr_resultat();




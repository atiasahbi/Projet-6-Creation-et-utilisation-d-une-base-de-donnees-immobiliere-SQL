-- 1. Nombre total d’appartements vendus au 1er semestre 2020

SELECT 
	TL.TLocal AS Type_Local, 
	COUNT(*) AS Nbre_Vente
FROM Type_Local AS TL
JOIN Bien_Immobilier USING(CTLocal)
JOIN Vente AS V USING(Idbien)
WHERE V.DateMut >= '2020-01-01' AND V.DateMut < '2020-07-01' AND TL.CTLocal = 2
GROUP BY TL.TLocal;

-- 2. Proportion des ventes d’appartements par le nombre de pièces.

SELECT 
	BI.NomPiePri AS Nombre_Pièces,
	CAST(100 * COUNT (*) / (
		SELECT 
			COUNT(Idbien) 
		FROM Bien_Immobilier 
		WHERE CTLocal = 2)
	AS DECIMAL (10,2)
	) AS Proportion_Ventes_Appartements 
FROM Bien_Immobilier AS BI
WHERE BI.CTLocal = 2
GROUP BY BI.NomPiePri
ORDER BY Proportion_Ventes_Appartements DESC;

-- 3. Liste des 10 départements où le prix du mètre carré est le plus élevé. 

SELECT 
	Co.CDept AS départements,
	CAST(AVG(V.ValeurFon/BI.SurfCzPreLo) AS DECIMAL(10, 2)) AS Prix_Mètre_Carré
FROM Commune Co
 JOIN Adresse AS A USING (CP,Com)
 JOIN Bien_Immobilier AS BI USING (IdAdress)
 JOIN Vente AS V USING (Idbien)
WHERE ValeurFon != 0 AND SurfCzPreLo != 0
GROUP By Co.CDept
ORDER BY Prix_Mètre_Carré DESC LIMIT 10;

--4. Prix moyen du mètre carré d’une maison en Île-de-France :

SELECT 
	CAST(AVG(ValeurFon/SurfCzPreLo) AS DECIMAL(10,2)) AS Prix_M2_Maison_IDF
FROM Commune Co
 JOIN Adresse AS A USING (CP,Com)
 JOIN Bien_Immobilier AS BI USING (IdAdress)
 JOIN Vente AS V USING (Idbien)
WHERE V.ValeurFon != 0 AND BI.SurfCzPreLo != 0
AND BI.CTLocal = '1' AND Co.CDept IN ('75','77','78','94','93','92','91','95') ;

 --5. Liste des 10 appartements les plus chers avec le département et le nombre de mètres carrés :
 
SELECT 
Co.CDept AS N_DEPARTEMENT,
CAST(V.ValeurFon AS DECIMAL (10, 2)) AS PRIX_EN_EURO,
CONCAT(BI.SurfCzPreLo,' m2') AS SURFACE
FROM Commune Co
 JOIN Adresse AS A USING (CP,Com)
 JOIN Bien_Immobilier AS BI USING (IdAdress)
 JOIN Vente AS V USING (Idbien)
WHERE  BI.CTLocal = 2 AND V.ValeurFon != 0 AND BI.SurfCzPreLo!= 0
ORDER BY V.ValeurFon DESC LIMIT 10;

--6. Taux d’évolution du nombre de ventes entre le premier et le deuxième trimestres de 2020:

WITH
Trim1 AS (
		SELECT
 			COUNT(IdBien) AS Nb_Trim1
		FROM Vente 
	    WHERE DateMut >= '2020-01-01' AND DateMut < '2020-04-01'),
Trim2 AS (
		 SELECT 
  		  	COUNT(IdBien) AS Nb_Trim2
		FROM Vente 
		WHERE DateMut < '2020-07-1' AND DateMut >= '2020-04-01')
		
SELECT (100 * (Nb_Trim2 - Nb_Trim1) / Nb_Trim1) AS Evolution_Trim1_Trim2
FROM Trim1,Trim2;

--7. Liste des communes où le nombre de ventes a augmenté d'au moins 20% entre le premier et le second trimestre de 2020.

SELECT
	E.Communes AS Communes,
	E.Evolution
FROM (
	SELECT 
		Co.Com  AS Communes,
		tri1.Venttri1,
		tri2.Venttri2,
		CAST(100 * ((tri2.Venttri2 - tri1.Venttri1) / tri1.Venttri1) AS DECIMAL (15,2)) AS Evolution
	FROM Commune AS Co
	JOIN (
		SELECT 
			Co.Com AS Communes,
			COUNT(V.idbien) AS Venttri2
			FROM Commune AS Co 
			JOIN Adresse AS A USING (CP,Com)
			JOIN Bien_Immobilier AS BI USING (IdAdress)
			JOIN Vente AS V USING (Idbien)
			WHERE  DateMut < '2020-07-1' AND DateMut >= '2020-04-01' AND V.ValeurFon != 0 AND BI.SurfCzPreLo!= 0
			GROUP BY Co.Com
	) AS tri2 ON tri2.Communes = Co.Com
	JOIN (
		SELECT 
			Co.Com  AS Communes,
			COUNT (V.idbien) AS Venttri1
		FROM Commune AS Co
		JOIN Adresse AS A USING (CP,Com)
		JOIN Bien_Immobilier AS BI USING (IdAdress)
		JOIN Vente AS V USING (Idbien)
		WHERE  DateMut >= '2020-01-01' AND DateMut < '2020-04-01' AND V.ValeurFon != 0 AND BI.SurfCzPreLo != 0
		GROUP BY Co.Com
	) AS tri1 ON tri1.Communes = Co.Com
	GROUP BY Co.Com,tri1.Venttri1,tri2.Venttri2
) AS E 
WHERE evolution>20
ORDER BY evolution DESC; 

--8. Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces.

WITH 
Piece2 AS (
	SELECT AVG (valeurfon / SurfCzPreLo) AS prixm2_2Pièces  
	FROM Vente 
	JOIN Bien_immobilier USING (Idbien) 
	JOIN Adresse USING (Idadress) 
	WHERE CTLocal = 2 AND NomPiePri = 2 AND valeurfon!=0 AND SurfCzPreLo!=0), 
Piece3 AS
 	(SELECT avg(valeurfon / SurfCzPreLo) AS prixm2_3Pièces
	 FROM vente 
	JOIN Bien_immobilier USING (idbien) 
	JOIN Adresse USING (idadress) 
 	WHERE CTLocal = 2 AND NomPiePri = 3 AND valeurfon!=0 AND SurfCzPreLo!=0) 
 	
 SELECT (prixm2_3Pièces -prixm2_2Pièces ) / prixm2_2Pièces *100 AS diff_2p_3p
 FROM Piece2, Piece3;

--9. Donnez les moyennes de valeurs foncières pour le top 20 des communes:

SELECT 
	Co.Com AS commune,
	CAST(AVG(V.ValeurFon) AS DECIMAL(10,2)) AS prix_moy
FROM Commune Co
JOIN Adresse AS A USING (CP,Com)
JOIN Bien_Immobilier AS BI USING (IdAdress)
JOIN Vente AS V USING (Idbien)
WHERE V.ValeurFon != 0 AND BI.SurfCzPreLo != 0
GROUP BY Co.Com
ORDER BY prix_moy  DESC LIMIT 20;
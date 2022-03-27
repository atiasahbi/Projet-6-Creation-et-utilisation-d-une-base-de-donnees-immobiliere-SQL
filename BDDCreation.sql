CREATE TABLE Commune (
                CP NVARCHAR(5) NOT NULL,
                Com  VARCHAR(30) NOT NULL,
                CIdCom  INTEGER NOT NULL,
                CCom INTEGER NOT NULL,
                CDept  NVARCHAR(3) NOT NULL,
                CONSTRAINT Commune_pk PRIMARY KEY (CP, Com )
             
);

CREATE TABLE Voie (
                CVoie NVARCHAR(5) NOT NULL,
                Voie  NVARCHAR(30) NOT NULL,
                CONSTRAINT Voie_pk PRIMARY KEY (CVoie)
);       


CREATE TABLE Type_Voie (
                CTVoie INTEGER NOT NULL,
                TVoie  VARCHAR(5),
                CONSTRAINT Type_Voie_pk PRIMARY KEY (CTVoie)
);       

CREATE TABLE Adresse (
                IdAdress INTEGER NOT NULL,
                CTVoie INTEGER NOT NULL,
                CVoie NVARCHAR(5) NOT NULL,
                NumVoie INTEGER,
                BTQ  NVARCHAR(5),
                CP NVARCHAR(5) NOT NULL,
                Com  VARCHAR(30) NOT NULL,
                CONSTRAINT Adresse_pk PRIMARY KEY (IdAdress)
);

ALTER TABLE Adresse ADD CONSTRAINT Commune_Adresse_fk
FOREIGN KEY (CP, Com )
REFERENCES Commune (CP, Com )
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Adresse ADD CONSTRAINT Voie_Adresse_fk
FOREIGN KEY (CVoie)
REFERENCES Voie (CVoie)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Adresse ADD CONSTRAINT Type_Voie_Adresse_fk
FOREIGN KEY (CTVoie)
REFERENCES Type_Voie (CTVoie)
ON DELETE NO ACTION
ON UPDATE NO ACTION;


CREATE TABLE Type_Local (
                CTLocal INTEGER NOT NULL,
                TLocal VARCHAR(25) NOT NULL,
                CONSTRAINT Type_Local_pk PRIMARY KEY (CTLocal)
);


CREATE TABLE Bien_Immobilier (
                Idbien INTEGER NOT NULL,
                IdAdress INTEGER NOT NULL,
                CTLocal INTEGER NOT NULL,
                PreLo  VARCHAR(10) NOT NULL,
                NbreLo  INTEGER NOT NULL,
                SurfCzPreLo DECIMAL(10,2) NOT NULL,
                NomPiePri  INTEGER NOT NULL,
                NatCul VARCHAR(5),
                NatCulSp VARCHAR(5),
                SurfTer INTEGER,
                SurReBat INTEGER,
                CONSTRAINT Bien_Immobilier_pk PRIMARY KEY (Idbien)
);

ALTER TABLE Bien_Immobilier ADD CONSTRAINT Adresse_Bien_Immobilier_fk
FOREIGN KEY (IdAdress)
REFERENCES Adresse (IdAdress)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE Bien_Immobilier ADD CONSTRAINT Type_Local_Bien_Immobilier_fk
FOREIGN KEY (CTLocal)
REFERENCES Type_Local (CTLocal)
ON DELETE NO ACTION
ON UPDATE NO ACTION;


CREATE TABLE Vente (
                IdVente INTEGER NOT NULL,
                NumDisp INTEGER NOT NULL,
                IdBien INTEGER NOT NULL,
                DateMut DATE NOT NULL,
                ValeurFon DECIMAL(15,2),
                CONSTRAINT Vente_pk PRIMARY KEY (IdVente, NumDisp)
);

ALTER TABLE Vente ADD CONSTRAINT Bien_Immobilier_Vente_fk
FOREIGN KEY (IdBien)
REFERENCES Bien_Immobilier (Idbien)
ON DELETE NO ACTION
ON UPDATE NO ACTION;
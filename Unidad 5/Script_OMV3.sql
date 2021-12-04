CREATE ROLE aysp WITH SUPERUSER;

CREATE DATABASE POSGRADO_OM
WITH OWNER = aysp
ENCODING = 'UTF-8';

\c  posgrado_om;

CREATE SCHEMA ESQ AUTHORIZATION aysp;

SET search_path TO ESQ,public;

CREATE DOMAIN ESQ.ClavesD as char (8) NOT NULL 
	CHECK (VALUE ~  '^[\w]+$');
CREATE DOMAIN ESQ.NombresD as varchar (20) NOT NULL
	CHECK (VALUE ~  '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$');
CREATE DOMAIN ESQ.MaternoD as varchar (20) 
	CHECK (VALUE ~  '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$');
CREATE DOMAIN ESQ.CallesD as varchar (30) NOT NULL
	CHECK (VALUE ~  '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$');
CREATE DOMAIN ESQ.NumeroD as char (5)  NULL 
	CHECK (VALUE ~  '^[\w]+$');
CREATE DOMAIN ESQ.MovilesD as char (12) NOT NULL
	CHECK (VALUE ~ '^\d{3}[-]{1}\d{3}[-]{1}\d{4}$');
CREATE DOMAIN ESQ.AsigcadD as varchar (80) NOT NULL
	CHECK (VALUE ~  '^[A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+$');
CREATE DOMAIN ESQ.SemestresD as smallint NOT NULL
	CHECK ((VALUE >= 1) AND (VALUE <= 12));
CREATE DOMAIN ESQ.NotesD as real NOT NULL 
	CHECK ((VALUE >= 0) AND (VALUE <=100) );
CREATE DOMAIN ESQ.ColoniaD as varchar (20) NOT NULL
	CHECK (VALUE ~  '^[A-Za-z0-9ÁÉÍÓÚÜÑáéíóúüñ\s]+$');
CREATE DOMAIN ESQ.PeriodosD as varchar (20) NOT NULL
	CHECK (VALUE ~  '^[A-Za-z0-9-]+$');
CREATE DOMAIN ESQ.NumcasaD as smallint 
        CHECK ((VALUE >=0) AND (VALUE <=1000));


CREATE TABLE ESQ.PLAN_DE_ESTUDIO
(
	    
        clave_plan_estudio PeriodosD,
        nombre_plan AsigcadD,
        credito_ca NumcasaD,
	
	PRIMARY KEY (clave_plan_estudio)

         

);

CREATE TABLE ESQ.Puestos_usuarios
(
	 Usuario_cargo AsigcadD,   
        id_usuario serial,
        
	
	PRIMARY KEY (Usuario_cargo)

         

);

CREATE TABLE ESQ.Personal
(
	    
        control_personal ClavesD,
        password MaternoD,
        nombre_personal NombresD,
    	ApellidoP_personal NombresD, 
	ApellidoM_parsonal MaternoD,
        Calle_personal CallesD,
	NumeroExt_personal NumcasaD,
        NumeroInt_personal NumcasaD,
        CodigoPostal_personal NumeroD,
        Colonia_personal ColoniaD,
        Municipio_personal NombresD,
        Estado_personal NombresD,
        Usuario_cargo AsigcadD, 
	
	PRIMARY KEY (control_personal),
        CONSTRAINT LLAVE_PER FOREIGN KEY (Usuario_cargo) REFERENCES  Puestos_usuarios (Usuario_cargo)

         

);


CREATE TABLE ESQ.ALUMNOS
(
	NControl ClavesD,
        contraseña NombresD,
        clave_plan_estudio PeriodosD,
	Nombre NombresD,
    	ApellidoP NombresD, 
	ApellidoM MaternoD,
	Calle CallesD,
	NumeroExt NumcasaD,
        NumeroInt NumcasaD,
        CodigoPostal NumeroD,
        Colonia ColoniaD,
        Municipio NombresD,
        Estado NombresD,
        Usuario_cargo AsigcadD,
        
        

	PRIMARY KEY (NControl),

        CONSTRAINT LLAVE_Al FOREIGN KEY (clave_plan_estudio) REFERENCES PLAN_DE_ESTUDIO  (clave_plan_estudio)
        ON UPDATE CASCADE
	ON DELETE CASCADE,
        CONSTRAINT LLAVE_PER FOREIGN KEY (Usuario_cargo) REFERENCES  Puestos_usuarios (Usuario_cargo)
);

CREATE TABLE ESQ.TELEFONOS
(
	
        
        NControl ClavesD,
        Telefono MovilesD,
        Tipo_Telefono NombresD,
	
	PRIMARY KEY (NControl,Telefono),
        CONSTRAINT LLAVE_T FOREIGN KEY (NControl) REFERENCES ALUMNOS  (NControl)
        ON UPDATE CASCADE
	ON DELETE CASCADE
);

CREATE TABLE ESQ.DOCUMENTOS 
(
        Ncontrol ClavesD, 
        name_cred PeriodosD, 
        archivo bytea,
        arc_c bytea,
        arc_acta bytea,
   
        PRIMARY KEY (NControl,name_cred),
        CONSTRAINT LLAVE_C FOREIGN KEY (NControl) REFERENCES ALUMNOS
        ON UPDATE CASCADE
	ON DELETE CASCADE

);


CREATE TABLE ESQ.ASIGNATURA
(
	CodigoAsignatura PeriodosD,
        clave_plan_estudio PeriodosD,
        NombreAsignatura AsigcadD,
	Creditos NumcasaD,
        SemestreAsig SemestresD,
	
	PRIMARY KEY (CodigoAsignatura,clave_plan_estudio),
CONSTRAINT LLAVE_ASIG FOREIGN KEY (clave_plan_estudio) REFERENCES PLAN_DE_ESTUDIO (clave_plan_estudio)
ON UPDATE CASCADE
ON DELETE CASCADE
 

);

CREATE TABLE ESQ.Reinscripcion_asignatura
(
        CodigoAsignatura PeriodosD,
	NControl ClavesD,
        Periodo_curso_asig PeriodosD,
        Tipo_curso AsigcadD,
	Semestre_cursa SemestresD,
        Estado_materia AsigcadD,
        Turno AsigcadD,

	PRIMARY KEY (CodigoAsignatura,NControl,Periodo_curso_asig,Tipo_curso),
        CONSTRAINT LLAVE_S FOREIGN KEY (NControl) REFERENCES ALUMNOS (NControl)
        ON UPDATE CASCADE
	ON DELETE CASCADE
);






CREATE TABLE ESQ.NOTAS
(
	NControl ClavesD,
        CodigoAsignatura PeriodosD,
        Periodo_curso_asig PeriodosD,
        Nota NotesD,
        
	

	PRIMARY KEY (NControl,CodigoAsignatura,Periodo_curso_asig ),
	CONSTRAINT LLAVE_N FOREIGN KEY (NControl) REFERENCES alumnos  (NControl)
        
        ON UPDATE CASCADE
	ON DELETE CASCADE
        
);





CREATE OR REPLACE FUNCTION fun_status()
RETURNS TRIGGER AS $$
DECLARE 
contr char(8);
cod varchar(80);
periodo varchar(20);
BEGIN

IF new.Nota < 70 THEN 
   

UPDATE esq.Reinscripcion_asignatura SET Estado_materia = 'No acreditada' 
  where NControl= new.Ncontrol 
  and CodigoAsignatura= new.CodigoAsignatura 
  and Periodo_curso_asig = new.Periodo_curso_asig;
ELSE
  UPDATE esq.Reinscripcion_asignatura SET Estado_materia = 'Acreditada' 
  where NControl= new.Ncontrol 
  and CodigoAsignatura= new.CodigoAsignatura 
  and Periodo_curso_asig = new.Periodo_curso_asig; 

END IF;
RETURN NEW;
END; 
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tr_estado_materia
AFTER INSERT ON esq.NOTAS FOR EACH ROW EXECUTE
PROCEDURE fun_status();



INSERT INTO ESQ.Puestos_usuarios VALUES('Director'),('Jefe Posgrado'),('Secretaria'),('Alumnos');
insert into esq.personal values('50000000','director','jimin','marquez',
'lopez','vicente guerrero',4,4,'96720','mina centro','minatitlan','veracruz','Director');

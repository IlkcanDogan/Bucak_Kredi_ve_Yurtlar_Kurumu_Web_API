-- phpMyAdmin SQL Dump
-- version 4.9.0.1
-- https://www.phpmyadmin.net/
--
-- Anamakine: 127.0.0.1
-- Üretim Zamanı: 17 Oca 2020, 18:00:38
-- Sunucu sürümü: 10.3.16-MariaDB
-- PHP Sürümü: 7.3.7

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Veritabanı: `db_kyk`
--

DELIMITER $$
--
-- Yordamlar
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_BASVURU_DUYURU_LISTELE` (IN `p_ERISIM_KODU` CHAR(32))  BEGIN
SET @ogr_id = (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU);
IF (@ogr_id > 0) THEN
	select BASVURU_ID, BASLIK, ICERIK, date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS , date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from view_ogr_duyuru_liste where BASVURU = 1 and OGR_ID = @ogr_id;
ELSE
	SET @HATA = 1; -- yetkisiz erişim.
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_BASVURU_KURS_LISTELE` (IN `p_ERISIM_KODU` CHAR(32))  BEGIN
SET @ogr_id = (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU);
IF (@ogr_id > 0) THEN
	select BASVURU_ID, BASLIK, date_format(BASVURU_BASLANGIC, '%d.%m.%Y') as BASVURU_BASLANGIC, date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from view_ogr_kurs_liste where OGR_ID = @ogr_id;
ELSE
	SET @HATA = 1; -- yetkisiz erişim.
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_BASVURU_SIL` (IN `p_ERISIM_KODU` CHAR(32), IN `p_BASVURU_TIP` TINYINT UNSIGNED, IN `p_BASVURU_ID` INT UNSIGNED)  BEGIN
SET @ogr_id = (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU);
SET @HATA = 0; -- default hata degeri.

IF (@ogr_id > 0) THEN
	IF (p_BASVURU_TIP = 1) THEN -- Duyuru
		IF EXISTS (select ID from tb_basvuru_duyuru where BASVURU_ID = p_BASVURU_ID and OGR_ID = @ogr_id) THEN
			IF EXISTS (select ID from tb_duyuru where ID = p_BASVURU_ID) THEN
				delete from tb_basvuru_duyuru where BASVURU_ID = p_BASVURU_ID;
			ELSE
				set @HATA = 3; -- Boyle bir basvuru kabul kayıdı yok.
            END IF;
		ELSE
			SET @HATA = 2; -- Zaten başvuru silinmiş.
        END IF;
    ELSEIF (p_BASVURU_TIP = 2) THEN -- Kurs
		IF EXISTS (select ID from tb_basvuru_kurs where BASVURU_ID = p_BASVURU_ID and OGR_ID = @ogr_id) THEN
			IF EXISTS (select ID from tb_kurs where ID = p_BASVURU_ID) THEN
				delete from tb_basvuru_kurs where BASVURU_ID = p_BASVURU_ID;
            ELSE
				set @HATA = 3; -- Boyle bir basvuru kabul kayıdı yok.
            END IF;
		ELSE
			SET @HATA = 2; -- Zaten başvuru silinmiş.
        END IF;
	ELSEIF (p_BASVURU_TIP = 3) THEN	-- Turnuva
		IF EXISTS (select ID from tb_basvuru_turnuva where BASVURU_ID = p_BASVURU_ID and OGR_ID = @ogr_id) THEN
			IF EXISTS (select ID from tb_turnuva where ID = p_BASVURU_ID) THEN
				delete from tb_basvuru_turnuva where BASVURU_ID = p_BASVURU_ID;
            ELSE
				set @HATA = 3; -- Boyle bir basvuru kabul kayıdı yok.
            END IF;
		ELSE
			SET @HATA = 2; -- Zaten başvuru silinmiş.
        END IF;
    END IF;
ELSE	
	SET @HATA = 1; -- doğrulama hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_BASVURU_TURNUVA_LISTELE` (IN `p_ERISIM_KODU` CHAR(32))  BEGIN
SET @ogr_id = (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU);
IF (@ogr_id > 0) THEN
	select BASVURU_ID, BASLIK, date_format(BASVURU_BASLANGIC, '%d.%m.%Y') as BASVURU_BASLANGIC , date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from view_ogr_turnuva_liste where OGR_ID = @ogr_id;
ELSE
	SET @HATA = 1; -- yetkisiz erişim.
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_BASVURU_YAP` (IN `p_ERISIM_KODU` CHAR(32), IN `p_BASVURU_TIP` TINYINT UNSIGNED, IN `p_BASVURU_ID` INT UNSIGNED)  BEGIN
SET @ogr_id = (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU);
SET @HATA = 0; -- default hata degeri.
SET @durum = 2;

IF (@ogr_id > 0) THEN
	IF (p_BASVURU_TIP = 1) THEN -- Duyuru
		IF NOT EXISTS (select ID from tb_basvuru_duyuru where BASVURU_ID = p_BASVURU_ID and OGR_ID = @ogr_id) THEN
			IF EXISTS (select ID from tb_duyuru where ID = p_BASVURU_ID) THEN
				
                set @tarih = (select BASVURU_BITIS from tb_duyuru where ID = p_BASVURU_ID);
				call sp_TARIH_SORGULA(@tarih,@durum);
                IF(@durum = 0) THEN
					insert into tb_basvuru_duyuru(BASVURU_ID,OGR_ID) values(p_BASVURU_ID,@ogr_id);
				ELSE
					set @HATA = 4; -- Başvurular kapandı.
                END IF;
                
			ELSE
				set @HATA = 3; -- Boyle bir basvuru kabul kayıdı yok.
            END IF;
		ELSE
			SET @HATA = 2; -- Zaten başvuru yapılmış.
        END IF;
    ELSEIF (p_BASVURU_TIP = 2) THEN -- Kurs
		IF NOT EXISTS (select ID from tb_basvuru_kurs where BASVURU_ID = p_BASVURU_ID and OGR_ID = @ogr_id) THEN
			IF EXISTS (select ID from tb_kurs where ID = p_BASVURU_ID) THEN
            
				set @tarih = (select BASVURU_BITIS from tb_kurs where ID = p_BASVURU_ID);
				call sp_TARIH_SORGULA(@tarih,@durum);
                IF(@durum = 0) THEN
					insert into tb_basvuru_kurs(BASVURU_ID,OGR_ID) values(p_BASVURU_ID,@ogr_id);
				ELSE
					set @HATA = 4; -- Başvurular kapandı.
                END IF;
                
				-- insert into tb_basvuru_kurs(BASVURU_ID,OGR_ID) values(p_BASVURU_ID,@ogr_id);
            ELSE
				set @HATA = 3; -- Boyle bir basvuru kabul kayıdı yok.
            END IF;
		ELSE
			SET @HATA = 2; -- Zaten başvuru yapılmış.
        END IF;
	ELSEIF (p_BASVURU_TIP = 3) THEN	-- Turnuva
		IF NOT EXISTS (select ID from tb_basvuru_turnuva where BASVURU_ID = p_BASVURU_ID and OGR_ID = @ogr_id) THEN
			IF EXISTS (select ID from tb_turnuva where ID = p_BASVURU_ID) THEN
            
				set @tarih = (select BASVURU_BITIS from tb_turnuva where ID = p_BASVURU_ID);
				call sp_TARIH_SORGULA(@tarih,@durum);
                IF(@durum = 0) THEN
					insert into tb_basvuru_turnuva(BASVURU_ID,OGR_ID) values(p_BASVURU_ID,@ogr_id);
				ELSE
					set @HATA = 4; -- Başvurular kapandı.
                END IF;
                
				-- insert into tb_basvuru_turnuva(BASVURU_ID,OGR_ID) values(p_BASVURU_ID,@ogr_id);
            ELSE
				set @HATA = 3; -- Boyle bir basvuru kabul kayıdı yok.
            END IF;
            
		ELSE
			SET @HATA = 2; -- Zaten başvuru yapılmış.
        END IF;
    END IF;
ELSE	
	SET @HATA = 1; -- doğrulama hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DUYURU_BASLIK` (IN `p_START` INT UNSIGNED)  BEGIN

IF (p_START != 0) THEN
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_duyuru where  ID < p_START ORDER BY ID desc LIMIT 5;
ELSE
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_duyuru ORDER BY ID desc LIMIT 5;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DUYURU_ICERIK` (IN `p_DUYURU_ID` INT UNSIGNED)  BEGIN
	set @goruntulenme = (select GORUNTULENME from tb_duyuru where ID = p_DUYURU_ID);
    update tb_duyuru set GORUNTULENME = @goruntulenme + 1 where ID = p_DUYURU_ID;
    
	select ID, BASLIK, ICERIK, FOTOGRAF, BASVURU, date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_duyuru where ID = p_DUYURU_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ETKINLIK_BASLIK` (IN `p_START` INT UNSIGNED)  BEGIN
IF (p_START != 0) THEN
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_etkinlik where  ID < p_START ORDER BY ID desc LIMIT 5;
ELSE
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_etkinlik ORDER BY ID desc LIMIT 5;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ETKINLIK_ICERIK` (IN `p_ETKINLIK_ID` INT UNSIGNED)  BEGIN
	set @goruntulenme = (select GORUNTULENME from tb_etkinlik where ID = p_ETKINLIK_ID);
    update tb_etkinlik set GORUNTULENME = @goruntulenme + 1 where ID = p_ETKINLIK_ID;
    
	select ID, BASLIK, FOTOGRAF, ICERIK, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_etkinlik where ID = p_ETKINLIK_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_FOTOGRAF` (IN `p_TABLO_ID` INT UNSIGNED, IN `p_KAYIT_ID` INT UNSIGNED)  BEGIN
	select ID, FOTOGRAF from tb_fotograf where TABLO_ID = p_TABLO_ID and KAYIT_ID = p_KAYIT_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GENEL_PAROLA_ONAY` (IN `p_GENEL_PAROLA` VARCHAR(20) charset utf8)  BEGIN
set @HATA = 0;
IF NOT EXISTS (select ID from tb_yonetici where G_PAROLA = p_GENEL_PAROLA) THEN
	set @HATA = 1;
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_KURS` ()  BEGIN
	select ID, KURS_ADI, ICERIK, date_format(BASVURU_BASLANGIC, '%d.%m.%Y') as BASVURU_BASLANGIC, date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_kurs ORDER BY ID desc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_OGR_KAYIT` (IN `p_AD` VARCHAR(60) CHARSET UTF8, IN `p_SOYAD` VARCHAR(60) CHARSET UTF8, IN `p_CEP_TEL` CHAR(11), IN `p_ERISIM_KODU` CHAR(32), IN `p_PLAYER_ID` CHAR(36), IN `p_IP` VARCHAR(15) CHARSET UTF8)  BEGIN
set @HATA = 0;
set @TARIH = (select current_timestamp());
	IF NOT EXISTS (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU) THEN
		IF NOT EXISTS (select ID from tb_ogrenci where CEP_TEL = p_CEP_TEL) THEN
			insert into tb_ogrenci(AD,SOYAD,CEP_TEL,ERISIM_KODU,KAYIT_TARIH,IP) values(p_AD,p_SOYAD,p_CEP_TEL,p_ERISIM_KODU,@TARIH,p_IP);
            set @id = (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU);
		ELSE 
			set @hata = 2; -- CEP_TEL zaten var.
        END IF;
	ELSE
		set @hata = 1; -- ERISIM KODU zaten kayıtlı.
	END IF;
    
    SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_PLAYER_ID_EKLE` (IN `p_ERISIM_KODU` CHAR(32) charset utf8, IN `p_PLAYER_ID` CHAR(36) charset utf8)  BEGIN
SET @HATA = 0;
SET @ID = (SELECT ID FROM tb_ogrenci WHERE ERISIM_KODU = p_ERISIM_KODU);
IF (@ID > 0) THEN
	IF NOT EXISTS(SELECT ID FROM tb_player_id WHERE OGR_ID = @ID and PLAYER_ID = p_PLAYER_ID) THEN
		insert into tb_player_id(OGR_ID,PLAYER_ID) values(@ID,p_PLAYER_ID);
	ELSE
		update tb_player_id set PLAYER_ID = p_PLAYER_ID where OGR_ID = @ID;
    END IF;
ELSE
	SET @HATA = 1;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SOSYAL_BASLIK` (IN `p_START` INT UNSIGNED)  BEGIN

IF (p_START != 0) THEN
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sosyal_sorumluluk where  ID < p_START ORDER BY ID desc LIMIT 5;
ELSE
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sosyal_sorumluluk ORDER BY ID desc LIMIT 5;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SOSYAL_ICERIK` (IN `p_SOSYAL_ID` INT UNSIGNED)  BEGIN
	set @goruntulenme = (select GORUNTULENME from tb_sosyal_sorumluluk where ID = p_SOSYAL_ID);
    update tb_sosyal_sorumluluk set GORUNTULENME = @goruntulenme + 1 where ID = p_SOSYAL_ID;
    
	select ID, BASLIK, FOTOGRAF, ICERIK, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sosyal_sorumluluk where ID = p_SOSYAL_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SPORTIF_BASLIK` (IN `p_START` INT UNSIGNED)  BEGIN

IF (p_START != 0) THEN
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sportif_faaliyet where  ID < p_START ORDER BY ID desc LIMIT 5;
ELSE
	select ID, BASLIK, FOTOGRAF, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sportif_faaliyet ORDER BY ID desc LIMIT 5;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SPORTIF_ICERIK` (IN `p_SPORTIF_ID` INT UNSIGNED)  BEGIN
	set @goruntulenme = (select GORUNTULENME from tb_sportif_faaliyet where ID = p_SPORTIF_ID);
    update tb_sportif_faaliyet set GORUNTULENME = @goruntulenme + 1 where ID = p_SPORTIF_ID;
    
	select ID, BASLIK, FOTOGRAF, ICERIK, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sportif_faaliyet where ID = p_SPORTIF_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TALEP_PROJE` (IN `p_ERISIM_KODU` CHAR(32), IN `p_TP_TIP` TINYINT, IN `p_TP_KONU` TEXT charset utf8, IN `p_TP_ICERIK` TEXT charset utf8)  BEGIN
SET @HATA = 0;
IF EXISTS (select ID from tb_ogrenci where ERISIM_KODU = p_ERISIM_KODU) THEN
	IF (p_TP_TIP = 1) THEN -- proje
		insert into tb_proje(KONU, PROJE) values(p_TP_KONU, p_TP_ICERIK);
	ELSEIF(p_TP_TIP = 2) THEN -- talep
		insert into tb_talep(KONU,TALEP) values(p_TP_KONU,p_TP_ICERIK);
	ELSE
		SET @HATA = 2; -- tip hatasi boyle bir tip yok
	END IF;
ELSE
	SET @HATA = 1; -- erisim kodu hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TARIH_SORGULA` (IN `p_BITIS_TARIH` DATE, OUT `p_DURUM` BIT)  BEGIN
SET @sonuc = (SELECT DATEDIFF(p_BITIS_TARIH ,NOW()));
SET p_DURUM = 1;
if(@sonuc > 0 or @sonuc = 0) THEN
	set p_DURUM= 0;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TURNUVA` ()  BEGIN
	select ID, TURNUVA_ADI, ICERIK, date_format(BASVURU_BASLANGIC, '%d.%m.%Y') as BASVURU_BASLANGIC, date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_turnuva ORDER BY ID desc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YEMEK_LISTESI` (IN `p_GUN` TINYINT)  BEGIN
IF (p_GUN = 1) THEN
	select YEMEK_ADI from tb_pzt;
ELSEIF (p_GUN = 2) THEN
	select YEMEK_ADI from tb_sal;
ELSEIF (p_GUN = 3) THEN
	select YEMEK_ADI from tb_car;
ELSEIF (p_GUN = 4) THEN
	select YEMEK_ADI from tb_per;
ELSEIF (p_GUN = 5) THEN
	select YEMEK_ADI from tb_cum;
ELSEIF (p_GUN = 6) THEN
	select YEMEK_ADI from tb_cmt;
ELSEIF (p_GUN = 7) THEN
	select YEMEK_ADI from tb_paz;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_BASVURU_OGRENCI_LISTE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_KAYIT_TIP` INT UNSIGNED, IN `p_KAYIT_ID` INT UNSIGNED)  BEGIN
IF EXISTS(select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	IF (p_KAYIT_TIP = 1) THEN -- Duyuru
		select TABLO_ID, AD, SOYAD, CEP_TEL from view_basvuru_duyuru_liste where BASVURU_ID = p_KAYIT_ID;
	ELSEIF(p_KAYIT_TIP = 2) THEN -- Kurs
		select TABLO_ID, AD, SOYAD, CEP_TEL from view_basvuru_kurs_liste where BASVURU_ID = p_KAYIT_ID;
	ELSEIF(p_KAYIT_TIP = 3) THEN -- turnuva
		select TABLO_ID, AD, SOYAD, CEP_TEL from view_basvuru_turnuva_liste where BASVURU_ID = p_KAYIT_ID;
	END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_BASVURU_OGRENCI_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_KAYIT_TIP` INT UNSIGNED, IN `p_TABLO_ID` INT UNSIGNED)  BEGIN
set @HATA = 1; -- Bir sorun var.
IF EXISTS(select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	IF (p_KAYIT_TIP = 1) THEN -- Duyuru
        delete from tb_basvuru_duyuru where ID = p_TABLO_ID;
        set @HATA = 0; -- Hata yok
	ELSEIF(p_KAYIT_TIP = 2) THEN -- Kurs
        delete from tb_basvuru_kurs where ID = p_TABLO_ID;
        set @HATA = 0; -- Hata yok
	ELSEIF(p_KAYIT_TIP = 3) THEN -- turnuva
        delete from tb_basvuru_turnuva where ID = p_TABLO_ID;
        set @HATA = 0; -- Hata yok
	END IF;
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_DUYURU_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_DUYURU_BASLIK` VARCHAR(300) charset utf8, IN `p_ICERIK` TEXT charset utf8, IN `p_BASVURU` CHAR(1), IN `p_BASVURU_BITIS_TARIH` DATE)  BEGIN
-- set @HATA = 0;
set @y_id = (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5);
IF (@y_id > 0) THEN
	IF (p_BASVURU = 1) THEN
		insert into tb_duyuru(YONETICI_ID,BASLIK,ICERIK,BASVURU,BASVURU_BITIS) values(@y_id,p_DUYURU_BASLIK,p_ICERIK,1,p_BASVURU_BITIS_TARIH);
    ELSE
		insert into tb_duyuru(YONETICI_ID,BASLIK,ICERIK,BASVURU,BASVURU_BITIS) values(@y_id,p_DUYURU_BASLIK,p_ICERIK,0,'0000-00-00');
    END IF;
    set @HATA = (select ID from tb_duyuru ORDER BY ID DESC LIMIT 1);
else
	set @HATA = 1; -- Yonetici erisim kodu hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_DUYURU_LISTE` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN

IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	select ID, BASLIK, ICERIK, date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS, GORUNTULENME, BASVURU, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_duyuru;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_DUYURU_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_DUYURU_ID` INT UNSIGNED)  BEGIN
set @HATA = 1; -- Bir sorun var.
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	delete from tb_duyuru where ID = p_DUYURU_ID;
    delete from tb_basvuru_duyuru where BASVURU_ID = p_DUYURU_ID;
    set @HATA = 0;
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_ETKINLIK_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_BASLIK` VARCHAR(300) charset utf8, IN `p_ICERIK` TEXT charset utf8)  BEGIN
-- set @HATA = 0;
set @y_id = (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5);
IF (@y_id > 0) THEN
	insert into tb_etkinlik(YONETICI_ID,BASLIK,ICERIK) values(@y_id,p_BASLIK,p_ICERIK);
    set @HATA = (select ID from tb_etkinlik ORDER BY ID DESC LIMIT 1);
else
	set @HATA = 1; -- Yonetici erisim kodu hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_ETKINLIK_LISTE` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN

IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	select ID, BASLIK, ICERIK, GORUNTULENME, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_etkinlik;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_ETKINLIK_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_ETKINLIK_ID` INT UNSIGNED)  BEGIN
set @FOTO_NO = 0; 
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
set @FOTO_NO = (select FOTOGRAF from tb_etkinlik where ID = p_ETKINLIK_ID);
	delete from tb_etkinlik where ID = p_ETKINLIK_ID;
END IF;
SELECT @FOTO_NO;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_FOTOGRAF_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_TABLO_ID` VARCHAR(50), IN `p_KAYIT_ID` VARCHAR(50), IN `p_FOTOGRAF` CHAR(6))  BEGIN
SET @HATA = 0;
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	IF (p_TABLO_ID = 1) THEN -- Etkinlik
		IF EXISTS (select ID from tb_etkinlik where ID = p_KAYIT_ID) THEN
            update tb_etkinlik set FOTOGRAF = p_FOTOGRAF where ID = p_KAYIT_ID;
		ELSE
			SET @HATA = 2; -- kayit id yok
		END IF;
	ELSEIF(p_TABLO_ID = 2) THEN -- Sportif
		IF EXISTS (select ID from tb_sportif_faaliyet where ID = p_KAYIT_ID) THEN
            update tb_sportif_faaliyet set FOTOGRAF = p_FOTOGRAF where ID = p_KAYIT_ID;
		ELSE
			SET @HATA = 2; -- kayit id yok
		END IF;
	ELSEIF(p_TABLO_ID = 3) THEN -- Gonul Bagi/sosyal sorumluluk
    
		IF EXISTS (select ID from tb_sosyal_sorumluluk where ID = p_KAYIT_ID) THEN
            update tb_sosyal_sorumluluk set FOTOGRAF = p_FOTOGRAF where ID = p_KAYIT_ID;
		ELSE
			SET @HATA = 2; -- kayit id yok
		END IF;
	
	ELSEIF(p_TABLO_ID = 4) THEN -- Duyuru
    
		IF EXISTS (select ID from tb_duyuru where ID = p_KAYIT_ID) THEN
            update tb_duyuru set FOTOGRAF = p_FOTOGRAF where ID = p_KAYIT_ID;
		ELSE
			SET @HATA = 2; -- kayit id yok
		END IF;
	
	END IF;
ELSE
	SET @HATA = 1; -- yonetici token hatasi
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_GENEL_PAROLA_DEGISTIR` (IN `p_PAROLA_MD5` CHAR(32), IN `p_YENI_GENEL_PAROLA` CHAR(32))  BEGIN
set @HATA = 0;
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	update tb_yonetici set G_PAROLA = p_YENI_GENEL_PAROLA where PAROLA_MD5 = p_PAROLA_MD5;
ELSE
	SET @HATA = 1; -- parola yanlış
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_GIRIS` (IN `p_KULLANICI_ADI` VARCHAR(20) CHARSET UTF8, IN `p_PAROLA_MD5` CHAR(32))  BEGIN
	select KULLANICI_ADI, AD, SOYAD, G_PAROLA from tb_yonetici 
    where KULLANICI_ADI = p_KULLANICI_ADI and PAROLA_MD5 = p_PAROLA_MD5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_KURS_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_KURS_ADI` VARCHAR(300) charset utf8, IN `p_ICERIK` TEXT charset utf8, IN `p_BASVURU_BASLANGIC_TARIH` DATE, IN `p_BASVURU_BITIS_TARIH` DATE)  BEGIN
set @HATA = 0;
set @y_id = (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5);
IF (@y_id > 0) THEN
    insert into tb_kurs(YONETICI_ID,KURS_ADI,ICERIK,BASVURU_BASLANGIC,BASVURU_BITIS) 
    values(@y_id, p_KURS_ADI, p_ICERIK, p_BASVURU_BASLANGIC_TARIH, p_BASVURU_BITIS_TARIH);
else
	set @HATA = 1; -- Yonetici erisim kodu hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_KURS_LISTE` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN

IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	select ID, KURS_ADI, ICERIK, date_format(BASVURU_BASLANGIC, '%d.%m.%Y') as BASVURU_BASLANGIC , date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_kurs;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_KURS_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_KURS_ID` INT UNSIGNED)  BEGIN
set @HATA = 1; -- Bir sorun var.
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	delete from tb_kurs where ID = p_KURS_ID;
    delete from tb_basvuru_kurs where BASVURU_ID = p_KURS_ID;
    set @HATA = 0;
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_OGR_HESAP_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_OGR_ID` INT UNSIGNED)  BEGIN
set @HATA = 1; -- Bir sorun var.
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
    IF EXISTS (select ID from tb_ogrenci where ID = p_OGR_ID)THEN
        delete from tb_basvuru_duyuru where OGR_ID = p_OGR_ID;
        delete from tb_basvuru_kurs where OGR_ID = p_OGR_ID;
        delete from tb_basvuru_turnuva where OGR_ID = p_OGR_ID;
        delete from tb_player_id where OGR_ID = p_OGR_ID;
        
        delete from tb_ogrenci where ID = p_OGR_ID;        
        set @HATA = 0;
    END IF;    
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_OGR_LISTE` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN

IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	select ID, AD, SOYAD, CEP_TEL, date_format(KAYIT_TARIH, '%d.%m.%Y %H:%i') as KAYIT_TARIH, IP from tb_ogrenci;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_PAROLA_DEGISTIR` (IN `p_PAROLA_MD5` CHAR(32), IN `p_YENI_PAROLA_MD5` CHAR(32))  BEGIN
set @HATA = 0; -- değiştirildi.
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	update tb_yonetici set PAROLA_MD5 = p_YENI_PAROLA_MD5 where PAROLA_MD5 = p_PAROLA_MD5;
ELSE
	SET @HATA = 1; -- parola yanlış
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_SOSYAL_SORUMLULUK_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_BASLIK` VARCHAR(300) charset utf8, IN `p_ICERIK` TEXT charset utf8)  BEGIN
set @y_id = (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5);
IF (@y_id > 0) THEN
	insert into tb_sosyal_sorumluluk(YONETICI_ID,BASLIK,ICERIK) values(@y_id,p_BASLIK,p_ICERIK);
    set @HATA = (select ID from tb_sosyal_sorumluluk ORDER BY ID DESC LIMIT 1);
else
	set @HATA = 1; -- Yonetici erisim kodu hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_SOSYAL_SORUMLULUK_LISTE` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN

IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	select ID, BASLIK, ICERIK, GORUNTULENME, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sosyal_sorumluluk;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_SOSYAL_SORUMLULUK_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_SOSYAL_SORUMLULUK_ID` INT UNSIGNED)  BEGIN
set @FOTO_NO = 0;
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	set @FOTO_NO = (select FOTOGRAF from tb_sosyal_sorumluluk where ID = p_SOSYAL_SORUMLULUK_ID);
	delete from tb_sosyal_sorumluluk where ID = p_SOSYAL_SORUMLULUK_ID;
END IF;
SELECT @FOTO_NO;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_SPORTIF_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_BASLIK` VARCHAR(300) charset utf8, IN `p_ICERIK` TEXT charset utf8)  BEGIN
set @y_id = (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5);
IF (@y_id > 0) THEN
	insert into tb_sportif_faaliyet(YONETICI_ID,BASLIK,ICERIK) values(@y_id,p_BASLIK,p_ICERIK);
    set @HATA = (select ID from tb_sportif_faaliyet ORDER BY ID DESC LIMIT 1);
else
	set @HATA = 1; -- Yonetici erisim kodu hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_SPORTIF_LISTE` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN

IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	select ID, BASLIK, ICERIK, GORUNTULENME, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_sportif_faaliyet;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_SPORTIF_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_SPORTIF_ID` INT UNSIGNED)  BEGIN
set @FOTO_NO = 0; 
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	set @FOTO_NO = (select FOTOGRAF from tb_sportif_faaliyet where ID = p_SPORTIF_ID);
	delete from tb_sportif_faaliyet where ID = p_SPORTIF_ID;
END IF;
SELECT @FOTO_NO;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_TALEP_PROJE_LISTE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_TP_TIP` TINYINT)  BEGIN
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	IF (p_TP_TIP = 1) THEN -- proje
        select ID, KONU, PROJE, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_proje;
	END IF;
    
	IF(p_TP_TIP = 2) THEN -- talep
        select ID, KONU, TALEP, date_format(KAYIT_TARIH, '%d.%m.%Y') as KAYIT_TARIH from tb_talep;
	END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_TALEP_PROJE_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_TP_TIP` TINYINT, IN `p_KAYIT_ID` INT UNSIGNED)  BEGIN
set @HATA = 1; -- Bir sorun var.
IF EXISTS(select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	IF (p_TP_TIP = 1) THEN -- proje
        delete from tb_proje where ID = p_KAYIT_ID;
        set @HATA = 0; -- Hata yok
        
	ELSEIF(p_TP_TIP = 2) THEN -- talep
        delete from tb_talep where ID = p_KAYIT_ID;
        set @HATA = 0; -- Hata yok
	END IF;
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_TURNUVA_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_TURNUVA_ADI` VARCHAR(300) charset utf8, IN `p_ICERIK` TEXT charset utf8, IN `p_BASVURU_BASLANGIC_TARIH` DATE, IN `p_BASVURU_BITIS_TARIH` DATE)  BEGIN
set @HATA = 0;
set @y_id = (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5);
IF (@y_id > 0) THEN
    insert into tb_turnuva(YONETICI_ID,TURNUVA_ADI,ICERIK,BASVURU_BASLANGIC,BASVURU_BITIS) 
    values(@y_id, p_TURNUVA_ADI, p_ICERIK, p_BASVURU_BASLANGIC_TARIH, p_BASVURU_BITIS_TARIH);
else
	set @HATA = 1; -- Yonetici erisim kodu hatası.
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_TURNUVA_LISTE` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN

IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	select ID, TURNUVA_ADI, ICERIK, date_format(BASVURU_BASLANGIC, '%d.%m.%Y') as BASVURU_BASLANGIC, date_format(BASVURU_BITIS, '%d.%m.%Y') as BASVURU_BITIS , date_format(KAYIT_TARIH, '%d.%m.%Y')  as KAYIT_TARIH from tb_turnuva;
END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_TURNUVA_SIL` (IN `p_PAROLA_MD5` CHAR(32), IN `p_TURNUVA_ID` INT UNSIGNED)  BEGIN
set @HATA = 1; -- Bir sorun var.
IF EXISTS (select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	delete from tb_turnuva where ID = p_TURNUVA_ID;
    delete from tb_basvuru_turnuva where BASVURU_ID = p_TURNUVA_ID;
    set @HATA = 0;
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_YEMEK_LISTESI_EKLE` (IN `p_PAROLA_MD5` CHAR(32), IN `p_TIP` TINYINT, IN `p_YEMEK_ADI` VARCHAR(900) charset utf8)  BEGIN
SET @HATA = 0;
IF EXISTS(select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	IF (p_TIP = 1) THEN -- Pazartesi
		insert into tb_pzt(YEMEK_ADI) values(p_YEMEK_ADI);
	END IF;
    
	IF(p_TIP = 2) THEN -- Sali
		insert into tb_sal(YEMEK_ADI) values(p_YEMEK_ADI);
    END IF;
    
    IF(p_TIP = 3) THEN -- Carsamba
		insert into tb_car(YEMEK_ADI) values(p_YEMEK_ADI);
    END IF;
    
    IF(p_TIP = 4) THEN -- Persembe
		insert into tb_per(YEMEK_ADI) values(p_YEMEK_ADI);
    END IF;
    
    IF(p_TIP = 5) THEN -- Cuma
		insert into tb_cum(YEMEK_ADI) values(p_YEMEK_ADI);
    END IF;
    
    IF(p_TIP = 6) THEN -- Cumartesi
		insert into tb_cmt(YEMEK_ADI) values(p_YEMEK_ADI);
    END IF;
    
    IF(p_TIP = 7) THEN -- Pazar
		insert into tb_paz(YEMEK_ADI) values(p_YEMEK_ADI);
    END IF;
    
ELSE
	SET @HATA = 1;
END IF;
SELECT @HATA;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_YONETICI_YEMEK_LISTESI_SIL` (IN `p_PAROLA_MD5` CHAR(32))  BEGIN
SET @HATA = 0;
IF EXISTS(select ID from tb_yonetici where PAROLA_MD5 = p_PAROLA_MD5) THEN
	truncate tb_pzt;
    truncate tb_sal;
    truncate tb_car;
    truncate tb_per;
    truncate tb_cum;
    truncate tb_cmt;
    truncate tb_paz;
ELSE
	SET @HATA = 1;
END IF;
SELECT @HATA;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_basvuru_duyuru`
--

CREATE TABLE `tb_basvuru_duyuru` (
  `ID` int(10) UNSIGNED NOT NULL,
  `BASVURU_ID` int(10) UNSIGNED NOT NULL,
  `OGR_ID` int(10) UNSIGNED NOT NULL,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_basvuru_kurs`
--

CREATE TABLE `tb_basvuru_kurs` (
  `ID` int(10) UNSIGNED NOT NULL,
  `BASVURU_ID` int(10) UNSIGNED NOT NULL,
  `OGR_ID` int(10) UNSIGNED NOT NULL,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_basvuru_turnuva`
--

CREATE TABLE `tb_basvuru_turnuva` (
  `ID` int(10) UNSIGNED NOT NULL,
  `BASVURU_ID` int(10) UNSIGNED NOT NULL,
  `OGR_ID` int(10) UNSIGNED NOT NULL,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_car`
--

CREATE TABLE `tb_car` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YEMEK_ADI` varchar(900) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_car`
--
-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_cmt`
--

CREATE TABLE `tb_cmt` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YEMEK_ADI` varchar(900) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_cmt`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_cum`
--

CREATE TABLE `tb_cum` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YEMEK_ADI` varchar(900) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_cum`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_duyuru`
--

CREATE TABLE `tb_duyuru` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YONETICI_ID` int(10) UNSIGNED NOT NULL,
  `BASLIK` varchar(300) CHARACTER SET utf8 NOT NULL,
  `ICERIK` text CHARACTER SET utf8 NOT NULL,
  `FOTOGRAF` char(6) DEFAULT NULL,
  `BASVURU` int(1) DEFAULT 0,
  `BASVURU_BITIS` date DEFAULT NULL,
  `GORUNTULENME` int(10) UNSIGNED DEFAULT 0,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_duyuru`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_etkinlik`
--

CREATE TABLE `tb_etkinlik` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YONETICI_ID` int(10) UNSIGNED NOT NULL,
  `BASLIK` varchar(300) CHARACTER SET utf8 NOT NULL,
  `ICERIK` text CHARACTER SET utf8 NOT NULL,
  `FOTOGRAF` char(6) DEFAULT NULL,
  `GORUNTULENME` int(10) UNSIGNED DEFAULT 0,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_kurs`
--

CREATE TABLE `tb_kurs` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YONETICI_ID` int(10) UNSIGNED NOT NULL,
  `KURS_ADI` varchar(300) CHARACTER SET utf8 NOT NULL,
  `ICERIK` text CHARACTER SET utf8 NOT NULL,
  `BASVURU_BASLANGIC` date NOT NULL,
  `BASVURU_BITIS` date NOT NULL,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_ogrenci`
--

CREATE TABLE `tb_ogrenci` (
  `ID` int(10) UNSIGNED NOT NULL,
  `AD` varchar(60) CHARACTER SET utf8 NOT NULL,
  `SOYAD` varchar(60) CHARACTER SET utf8 NOT NULL,
  `CEP_TEL` char(11) CHARACTER SET utf8 NOT NULL,
  `ERISIM_KODU` char(32) CHARACTER SET utf8 NOT NULL,
  `KAYIT_TARIH` datetime NOT NULL,
  `IP` varchar(15) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_ogrenci`
--


-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_paz`
--

CREATE TABLE `tb_paz` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YEMEK_ADI` varchar(900) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_paz`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_per`
--

CREATE TABLE `tb_per` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YEMEK_ADI` varchar(900) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_per`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_player_id`
--

CREATE TABLE `tb_player_id` (
  `ID` int(10) UNSIGNED NOT NULL,
  `OGR_ID` int(10) UNSIGNED NOT NULL,
  `PLAYER_ID` char(36) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_proje`
--

CREATE TABLE `tb_proje` (
  `ID` int(10) UNSIGNED NOT NULL,
  `KONU` varchar(100) DEFAULT NULL,
  `PROJE` text CHARACTER SET utf8 NOT NULL,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_proje`
--
-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_pzt`
--

CREATE TABLE `tb_pzt` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YEMEK_ADI` varchar(900) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_pzt`
--


-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_sal`
--

CREATE TABLE `tb_sal` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YEMEK_ADI` varchar(900) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_sal`
--


-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_sosyal_sorumluluk`
--

CREATE TABLE `tb_sosyal_sorumluluk` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YONETICI_ID` int(10) UNSIGNED NOT NULL,
  `BASLIK` varchar(300) CHARACTER SET utf8 NOT NULL,
  `ICERIK` text CHARACTER SET utf8 NOT NULL,
  `FOTOGRAF` char(6) DEFAULT NULL,
  `GORUNTULENME` int(10) UNSIGNED DEFAULT 0,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_sosyal_sorumluluk`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_sportif_faaliyet`
--

CREATE TABLE `tb_sportif_faaliyet` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YONETICI_ID` int(10) UNSIGNED NOT NULL,
  `BASLIK` varchar(300) CHARACTER SET utf8 NOT NULL,
  `ICERIK` text CHARACTER SET utf8 NOT NULL,
  `FOTOGRAF` char(6) DEFAULT NULL,
  `GORUNTULENME` int(10) UNSIGNED DEFAULT 0,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_sportif_faaliyet`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_tablo`
--

CREATE TABLE `tb_tablo` (
  `ID` int(10) UNSIGNED NOT NULL,
  `TABLO_ADI` varchar(100) CHARACTER SET utf8 NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_tablo`
--

INSERT INTO `tb_tablo` (`ID`, `TABLO_ADI`) VALUES
(1, 'Etkinlik'),
(2, 'Gönül Bağı Projeleri (Sosyal Sorumluluk)'),
(3, 'Sportif Faaliyet');

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_talep`
--

CREATE TABLE `tb_talep` (
  `ID` int(10) UNSIGNED NOT NULL,
  `KONU` varchar(100) DEFAULT NULL,
  `TALEP` text CHARACTER SET utf8 NOT NULL,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_talep`
--

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_turnuva`
--

CREATE TABLE `tb_turnuva` (
  `ID` int(10) UNSIGNED NOT NULL,
  `YONETICI_ID` int(10) UNSIGNED NOT NULL,
  `TURNUVA_ADI` varchar(100) CHARACTER SET utf8 NOT NULL,
  `ICERIK` text CHARACTER SET utf8 NOT NULL,
  `BASVURU_BASLANGIC` date NOT NULL,
  `BASVURU_BITIS` date NOT NULL,
  `KAYIT_TARIH` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Tablo için tablo yapısı `tb_yonetici`
--

CREATE TABLE `tb_yonetici` (
  `ID` int(10) UNSIGNED NOT NULL,
  `KULLANICI_ADI` varchar(20) CHARACTER SET utf8 NOT NULL,
  `AD` varchar(60) CHARACTER SET utf8 NOT NULL,
  `SOYAD` varchar(60) CHARACTER SET utf8 NOT NULL,
  `PAROLA_MD5` char(32) CHARACTER SET utf8 NOT NULL,
  `G_PAROLA` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Tablo döküm verisi `tb_yonetici`
--

INSERT INTO `tb_yonetici` (`ID`, `KULLANICI_ADI`, `AD`, `SOYAD`, `PAROLA_MD5`, `G_PAROLA`) VALUES
(1, 'admin', 'İlkcan', 'Doğan', 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx', 'XXXXXXXX');

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_basvuru_duyuru_liste`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_basvuru_duyuru_liste` (
`ID` int(10) unsigned
,`AD` varchar(60)
,`SOYAD` varchar(60)
,`CEP_TEL` char(11)
,`TABLO_ID` int(10) unsigned
,`BASVURU_ID` int(10) unsigned
,`OGR_ID` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_basvuru_kurs_liste`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_basvuru_kurs_liste` (
`ID` int(10) unsigned
,`AD` varchar(60)
,`SOYAD` varchar(60)
,`CEP_TEL` char(11)
,`TABLO_ID` int(10) unsigned
,`BASVURU_ID` int(10) unsigned
,`OGR_ID` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_basvuru_turnuva_liste`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_basvuru_turnuva_liste` (
`ID` int(10) unsigned
,`AD` varchar(60)
,`SOYAD` varchar(60)
,`CEP_TEL` char(11)
,`TABLO_ID` int(10) unsigned
,`BASVURU_ID` int(10) unsigned
,`OGR_ID` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_ogr_duyuru_liste`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_ogr_duyuru_liste` (
`ID` int(10) unsigned
,`BASLIK` varchar(300)
,`ICERIK` text
,`BASVURU` int(1)
,`BASVURU_BITIS` date
,`KAYIT_TARIH` timestamp
,`BASVURU_ID` int(10) unsigned
,`OGR_ID` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_ogr_kurs_liste`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_ogr_kurs_liste` (
`ID` int(10) unsigned
,`BASLIK` varchar(300)
,`BASVURU_BASLANGIC` date
,`BASVURU_BITIS` date
,`KAYIT_TARIH` timestamp
,`BASVURU_ID` int(10) unsigned
,`OGR_ID` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Görünüm yapısı durumu `view_ogr_turnuva_liste`
-- (Asıl görünüm için aşağıya bakın)
--
CREATE TABLE `view_ogr_turnuva_liste` (
`ID` int(10) unsigned
,`BASLIK` varchar(100)
,`BASVURU_BASLANGIC` date
,`BASVURU_BITIS` date
,`KAYIT_TARIH` timestamp
,`BASVURU_ID` int(10) unsigned
,`OGR_ID` int(10) unsigned
);

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_basvuru_duyuru_liste`
--
DROP TABLE IF EXISTS `view_basvuru_duyuru_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_basvuru_duyuru_liste`  AS  select `tb_ogrenci`.`ID` AS `ID`,`tb_ogrenci`.`AD` AS `AD`,`tb_ogrenci`.`SOYAD` AS `SOYAD`,`tb_ogrenci`.`CEP_TEL` AS `CEP_TEL`,`tb_basvuru_duyuru`.`ID` AS `TABLO_ID`,`tb_basvuru_duyuru`.`BASVURU_ID` AS `BASVURU_ID`,`tb_basvuru_duyuru`.`OGR_ID` AS `OGR_ID` from (`tb_ogrenci` join `tb_basvuru_duyuru` on(`tb_ogrenci`.`ID` = `tb_basvuru_duyuru`.`OGR_ID`)) order by `tb_ogrenci`.`ID` desc ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_basvuru_kurs_liste`
--
DROP TABLE IF EXISTS `view_basvuru_kurs_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_basvuru_kurs_liste`  AS  select `tb_ogrenci`.`ID` AS `ID`,`tb_ogrenci`.`AD` AS `AD`,`tb_ogrenci`.`SOYAD` AS `SOYAD`,`tb_ogrenci`.`CEP_TEL` AS `CEP_TEL`,`tb_basvuru_kurs`.`ID` AS `TABLO_ID`,`tb_basvuru_kurs`.`BASVURU_ID` AS `BASVURU_ID`,`tb_basvuru_kurs`.`OGR_ID` AS `OGR_ID` from (`tb_ogrenci` join `tb_basvuru_kurs` on(`tb_ogrenci`.`ID` = `tb_basvuru_kurs`.`OGR_ID`)) order by `tb_ogrenci`.`ID` desc ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_basvuru_turnuva_liste`
--
DROP TABLE IF EXISTS `view_basvuru_turnuva_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_basvuru_turnuva_liste`  AS  select `tb_ogrenci`.`ID` AS `ID`,`tb_ogrenci`.`AD` AS `AD`,`tb_ogrenci`.`SOYAD` AS `SOYAD`,`tb_ogrenci`.`CEP_TEL` AS `CEP_TEL`,`tb_basvuru_turnuva`.`ID` AS `TABLO_ID`,`tb_basvuru_turnuva`.`BASVURU_ID` AS `BASVURU_ID`,`tb_basvuru_turnuva`.`OGR_ID` AS `OGR_ID` from (`tb_ogrenci` join `tb_basvuru_turnuva` on(`tb_ogrenci`.`ID` = `tb_basvuru_turnuva`.`OGR_ID`)) order by `tb_ogrenci`.`ID` desc ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_ogr_duyuru_liste`
--
DROP TABLE IF EXISTS `view_ogr_duyuru_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_ogr_duyuru_liste`  AS  select `tb_duyuru`.`ID` AS `ID`,`tb_duyuru`.`BASLIK` AS `BASLIK`,`tb_duyuru`.`ICERIK` AS `ICERIK`,`tb_duyuru`.`BASVURU` AS `BASVURU`,`tb_duyuru`.`BASVURU_BITIS` AS `BASVURU_BITIS`,`tb_duyuru`.`KAYIT_TARIH` AS `KAYIT_TARIH`,`tb_basvuru_duyuru`.`BASVURU_ID` AS `BASVURU_ID`,`tb_basvuru_duyuru`.`OGR_ID` AS `OGR_ID` from (`tb_duyuru` join `tb_basvuru_duyuru` on(`tb_duyuru`.`ID` = `tb_basvuru_duyuru`.`BASVURU_ID`)) order by `tb_basvuru_duyuru`.`BASVURU_ID` desc ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_ogr_kurs_liste`
--
DROP TABLE IF EXISTS `view_ogr_kurs_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_ogr_kurs_liste`  AS  select `tb_kurs`.`ID` AS `ID`,`tb_kurs`.`KURS_ADI` AS `BASLIK`,`tb_kurs`.`BASVURU_BASLANGIC` AS `BASVURU_BASLANGIC`,`tb_kurs`.`BASVURU_BITIS` AS `BASVURU_BITIS`,`tb_kurs`.`KAYIT_TARIH` AS `KAYIT_TARIH`,`tb_basvuru_kurs`.`BASVURU_ID` AS `BASVURU_ID`,`tb_basvuru_kurs`.`OGR_ID` AS `OGR_ID` from (`tb_kurs` join `tb_basvuru_kurs` on(`tb_kurs`.`ID` = `tb_basvuru_kurs`.`BASVURU_ID`)) order by `tb_basvuru_kurs`.`BASVURU_ID` desc ;

-- --------------------------------------------------------

--
-- Görünüm yapısı `view_ogr_turnuva_liste`
--
DROP TABLE IF EXISTS `view_ogr_turnuva_liste`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_ogr_turnuva_liste`  AS  select `tb_turnuva`.`ID` AS `ID`,`tb_turnuva`.`TURNUVA_ADI` AS `BASLIK`,`tb_turnuva`.`BASVURU_BASLANGIC` AS `BASVURU_BASLANGIC`,`tb_turnuva`.`BASVURU_BITIS` AS `BASVURU_BITIS`,`tb_turnuva`.`KAYIT_TARIH` AS `KAYIT_TARIH`,`tb_basvuru_turnuva`.`BASVURU_ID` AS `BASVURU_ID`,`tb_basvuru_turnuva`.`OGR_ID` AS `OGR_ID` from (`tb_turnuva` join `tb_basvuru_turnuva` on(`tb_turnuva`.`ID` = `tb_basvuru_turnuva`.`BASVURU_ID`)) order by `tb_basvuru_turnuva`.`BASVURU_ID` desc ;

--
-- Dökümü yapılmış tablolar için indeksler
--

--
-- Tablo için indeksler `tb_basvuru_duyuru`
--
ALTER TABLE `tb_basvuru_duyuru`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_basvuru_kurs`
--
ALTER TABLE `tb_basvuru_kurs`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_basvuru_turnuva`
--
ALTER TABLE `tb_basvuru_turnuva`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_car`
--
ALTER TABLE `tb_car`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_cmt`
--
ALTER TABLE `tb_cmt`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_cum`
--
ALTER TABLE `tb_cum`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_duyuru`
--
ALTER TABLE `tb_duyuru`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_etkinlik`
--
ALTER TABLE `tb_etkinlik`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `YONETICI_ID` (`YONETICI_ID`);

--
-- Tablo için indeksler `tb_kurs`
--
ALTER TABLE `tb_kurs`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `YONETICI_ID` (`YONETICI_ID`);

--
-- Tablo için indeksler `tb_ogrenci`
--
ALTER TABLE `tb_ogrenci`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_paz`
--
ALTER TABLE `tb_paz`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_per`
--
ALTER TABLE `tb_per`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_player_id`
--
ALTER TABLE `tb_player_id`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_proje`
--
ALTER TABLE `tb_proje`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_pzt`
--
ALTER TABLE `tb_pzt`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_sal`
--
ALTER TABLE `tb_sal`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_sosyal_sorumluluk`
--
ALTER TABLE `tb_sosyal_sorumluluk`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `YONETICI_ID` (`YONETICI_ID`);

--
-- Tablo için indeksler `tb_sportif_faaliyet`
--
ALTER TABLE `tb_sportif_faaliyet`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `YONETICI_ID` (`YONETICI_ID`);

--
-- Tablo için indeksler `tb_tablo`
--
ALTER TABLE `tb_tablo`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_talep`
--
ALTER TABLE `tb_talep`
  ADD PRIMARY KEY (`ID`);

--
-- Tablo için indeksler `tb_turnuva`
--
ALTER TABLE `tb_turnuva`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `YONETICI_ID` (`YONETICI_ID`);

--
-- Tablo için indeksler `tb_yonetici`
--
ALTER TABLE `tb_yonetici`
  ADD PRIMARY KEY (`ID`);

--
-- Dökümü yapılmış tablolar için AUTO_INCREMENT değeri
--

--
-- Tablo için AUTO_INCREMENT değeri `tb_basvuru_duyuru`
--
ALTER TABLE `tb_basvuru_duyuru`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- Tablo için AUTO_INCREMENT değeri `tb_basvuru_kurs`
--
ALTER TABLE `tb_basvuru_kurs`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tablo için AUTO_INCREMENT değeri `tb_basvuru_turnuva`
--
ALTER TABLE `tb_basvuru_turnuva`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `tb_car`
--
ALTER TABLE `tb_car`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `tb_cmt`
--
ALTER TABLE `tb_cmt`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `tb_cum`
--
ALTER TABLE `tb_cum`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Tablo için AUTO_INCREMENT değeri `tb_duyuru`
--
ALTER TABLE `tb_duyuru`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- Tablo için AUTO_INCREMENT değeri `tb_etkinlik`
--
ALTER TABLE `tb_etkinlik`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Tablo için AUTO_INCREMENT değeri `tb_kurs`
--
ALTER TABLE `tb_kurs`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Tablo için AUTO_INCREMENT değeri `tb_ogrenci`
--
ALTER TABLE `tb_ogrenci`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=348;

--
-- Tablo için AUTO_INCREMENT değeri `tb_paz`
--
ALTER TABLE `tb_paz`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `tb_per`
--
ALTER TABLE `tb_per`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `tb_player_id`
--
ALTER TABLE `tb_player_id`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Tablo için AUTO_INCREMENT değeri `tb_proje`
--
ALTER TABLE `tb_proje`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- Tablo için AUTO_INCREMENT değeri `tb_pzt`
--
ALTER TABLE `tb_pzt`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Tablo için AUTO_INCREMENT değeri `tb_sal`
--
ALTER TABLE `tb_sal`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Tablo için AUTO_INCREMENT değeri `tb_sosyal_sorumluluk`
--
ALTER TABLE `tb_sosyal_sorumluluk`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Tablo için AUTO_INCREMENT değeri `tb_sportif_faaliyet`
--
ALTER TABLE `tb_sportif_faaliyet`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- Tablo için AUTO_INCREMENT değeri `tb_tablo`
--
ALTER TABLE `tb_tablo`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Tablo için AUTO_INCREMENT değeri `tb_talep`
--
ALTER TABLE `tb_talep`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- Tablo için AUTO_INCREMENT değeri `tb_turnuva`
--
ALTER TABLE `tb_turnuva`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Tablo için AUTO_INCREMENT değeri `tb_yonetici`
--
ALTER TABLE `tb_yonetici`
  MODIFY `ID` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Dökümü yapılmış tablolar için kısıtlamalar
--

--
-- Tablo kısıtlamaları `tb_etkinlik`
--
ALTER TABLE `tb_etkinlik`
  ADD CONSTRAINT `tb_etkinlik_ibfk_1` FOREIGN KEY (`YONETICI_ID`) REFERENCES `tb_yonetici` (`ID`);

--
-- Tablo kısıtlamaları `tb_kurs`
--
ALTER TABLE `tb_kurs`
  ADD CONSTRAINT `tb_kurs_ibfk_1` FOREIGN KEY (`YONETICI_ID`) REFERENCES `tb_yonetici` (`ID`);

--
-- Tablo kısıtlamaları `tb_sosyal_sorumluluk`
--
ALTER TABLE `tb_sosyal_sorumluluk`
  ADD CONSTRAINT `tb_sosyal_sorumluluk_ibfk_1` FOREIGN KEY (`YONETICI_ID`) REFERENCES `tb_yonetici` (`ID`);

--
-- Tablo kısıtlamaları `tb_sportif_faaliyet`
--
ALTER TABLE `tb_sportif_faaliyet`
  ADD CONSTRAINT `tb_sportif_faaliyet_ibfk_1` FOREIGN KEY (`YONETICI_ID`) REFERENCES `tb_yonetici` (`ID`);

--
-- Tablo kısıtlamaları `tb_turnuva`
--
ALTER TABLE `tb_turnuva`
  ADD CONSTRAINT `tb_turnuva_ibfk_1` FOREIGN KEY (`YONETICI_ID`) REFERENCES `tb_yonetici` (`ID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

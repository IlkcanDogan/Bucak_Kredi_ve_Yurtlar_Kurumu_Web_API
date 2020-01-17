<?php 

error_reporting(0);
include("fonksiyon.php");

$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];

if ($_metot == "POST") {
	$token = $fonk->TokenOku();
	$eski_parola = $fonk->SifreliTokenCoz($token)[0];

	$yeni_parola = md5($_POST["YENI_PAROLA"]);

	
			

	if(strlen($eski_parola) == 32 && strlen($yeni_parola) == 32 && strlen($_POST["YENI_PAROLA"]) > 0){

		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_YONETICI_PAROLA_DEGISTIR('$eski_parola','$yeni_parola');");

		if ($veri[0]["@HATA"] == 0) {
			$jsonDizi["HATA"] = 0;
			$jsonDizi["TOKEN"] = $fonk->TokenUret($yeni_parola);
		}
		else{
			$jsonDizi["HATA"] = 1;
		}
		echo $fonk->json($jsonDizi);
	}
}
else{
	$fonk->BaslikAyarla(400);
}


 ?>
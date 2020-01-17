<?php 

error_reporting(0);
include("fonksiyon.php");

$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];

if ($_metot == "POST") {
	$token = $fonk->TokenOku();
	$parola_md5 = $fonk->SifreliTokenCoz($token)[0];
	$genel_parola = $_POST["GENEL_PAROLA"];

	if(strlen($parola_md5) == 32 && strlen($genel_parola) >= 8){

		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_YONETICI_GENEL_PAROLA_DEGISTIR('$parola_md5','$genel_parola');");

		if ($veri[0]["@HATA"] == 0) {
			$jsonDizi["HATA"] = 0;
		}
		else{
			$jsonDizi["HATA"] = 1;
		}
		echo $fonk->json($jsonDizi);
	}
	else{
		$fonk->BaslikAyarla(400);
	}
}
else{
	$fonk->BaslikAyarla(400);
}



 ?>
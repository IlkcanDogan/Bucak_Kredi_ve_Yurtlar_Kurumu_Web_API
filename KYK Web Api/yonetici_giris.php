<?php 

include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();
$_metot = $_SERVER['REQUEST_METHOD'];
$jsonDizi = array();

if ($_metot == "POST") {

	$kullanici_adi = $_POST["KULLANICI_ADI"];
	$parola_md5 = md5($_POST["PAROLA"]);

	if(strlen($parola_md5) == 32 && $kullanici_adi != null){

		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_YONETICI_GIRIS('$kullanici_adi','$parola_md5');");

		if ($veri != null) {
			$jsonDizi = array(
				"KULLANICI_ADI" => $veri[0]["KULLANICI_ADI"],
				"AD" => $veri[0]["AD"],
				"SOYAD" => $veri[0]["SOYAD"],
				"G_PAROLA" => $veri[0]["G_PAROLA"],
				"TOKEN" => $fonk->TokenUret($parola_md5)
			);
		}
		else{
			$jsonDizi["HATA"] = 1;
		}

		$fonk->BaslikAyarla(200);
		echo $fonk->json($jsonDizi);
		
	}
}
else{
	$fonk->BaslikAyarla(400);
}


?>
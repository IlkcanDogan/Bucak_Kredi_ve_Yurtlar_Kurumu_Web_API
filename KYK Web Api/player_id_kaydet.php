<?php 
include("fonksiyon.php");

error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];

$player_id = $_GET["PLAYER_ID"];
$token = $_GET["TOKEN"];

$erisim_kodu = $fonk->SifreliTokenCoz($token)[0];

if (strlen($player_id) == 36 && strlen($erisim_kodu) == 32) {
	
	$vt = new Veritabani();
	$hata = $vt->Prosedur("call sp_PLAYER_ID_EKLE('$erisim_kodu','$player_id')");

	if($hata[0]["@HATA"] != 1){

		$jsonDizi["HATA"] = 0;
	}
	else{
		$jsonDizi["HATA"] = 1;
	}
	
	$fonk->BaslikAyarla(200);
	echo $fonk->json($jsonDizi);
}else{
	$fonk->BaslikAyarla(400);
}



 ?>
<?php 

include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi["DATA"] = array();
$token = $fonk->TokenOku();

if ($token != "") {

	$erisim_kodu = $fonk->SifreliTokenCoz($token)[0];
	$tp_tip = $_GET["TP_TIP"];  //TIP 1 = proje , TIP 2 = talep

	if ($tp_tip != "" && $erisim_kodu != "") {
		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_YONETICI_TALEP_PROJE_LISTE('$erisim_kodu','$tp_tip');");

		$fonk->BaslikAyarla(200);

		$jsonDizi["DATA"] = $veri;
		echo $fonk->json($jsonDizi);
	}
}
else{
	$fonk->BaslikAyarla(400);
}



?>
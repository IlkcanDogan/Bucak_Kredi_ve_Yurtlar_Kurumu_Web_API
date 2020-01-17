<?php
include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();
$_metot = $_SERVER['REQUEST_METHOD'];
$jsonDizi = array();
$token = $fonk->TokenOku();

if (true) {

	$tp_tip = $_POST["TP_TIP"];  //TIP 1 = proje , TIP 2 = talep 
	$tp_konu = $_POST["TP_KONU"];
	$tp_icerik = $_POST["TP_ICERIK"];
	$erisim_kodu = $fonk->SifreliTokenCoz($token)[0];

	if ($tp_tip != "" && $tp_icerik != "" && $erisim_kodu != "" && $tp_konu != "" && $erisim_kodu != "") {
		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_TALEP_PROJE('$erisim_kodu','$tp_tip','$tp_konu','$tp_icerik');");

		$hata = $veri[0]["@HATA"];
		$jsonDizi["HATA"] = $hata;

		$fonk->BaslikAyarla(200);
		echo $fonk->json($jsonDizi);
	}
}
else{
	$fonk->BaslikAyarla(400);
}


?>
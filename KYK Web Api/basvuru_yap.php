<?php 

include("fonksiyon.php");

error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();
$token = $_GET["TOKEN"];

if ($token != "") {
	$basvuru_tip = $_GET["BASVURU_TIP"];
	$basvuru_id = $_GET["BASVURU_ID"];
	$erisim_kodu = $fonk->SifreliTokenCoz($token)[0];

	if ($basvuru_tip != "" && $basvuru_id != "" && $erisim_kodu != "") {
		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_BASVURU_YAP('$erisim_kodu','$basvuru_tip','$basvuru_id');");

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

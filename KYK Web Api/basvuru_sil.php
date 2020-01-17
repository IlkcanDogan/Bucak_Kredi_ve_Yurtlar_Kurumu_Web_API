<?php 

include("fonksiyon.php");

$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];
if (true) {
	$basvuru_tip = $_GET["BASVURU_TIP"];
	$basvuru_id = $_GET["BASVURU_ID"];
	$erisim_kodu = $fonk->SifreliTokenCoz($_GET["TOKEN"])[0];

	if ($basvuru_tip != "" && $basvuru_id != "" && $erisim_kodu != "") {
		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_BASVURU_SIL('$erisim_kodu','$basvuru_tip','$basvuru_id');");

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
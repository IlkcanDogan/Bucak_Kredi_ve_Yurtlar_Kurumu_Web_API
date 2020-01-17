<?php 
include("fonksiyon.php");

error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];

if (true) {
    $erisim_kodu = $fonk->SifreliTokenCoz($_GET["TOKEN"])[0];
      
	if (strlen($erisim_kodu) == 32) {
		$vt = new Veritabani();

		$duyuru_liste = $vt->Prosedur("call sp_BASVURU_DUYURU_LISTELE('$erisim_kodu');");
		if ($duyuru_liste != null) {
			foreach ($duyuru_liste as $veri) {
				$sanal_dizi = array(
					"BASVURU_ID" => $veri["BASVURU_ID"],
					"BASLIK" => $veri["BASLIK"],
					"BASVURU_BITIS" => $veri["BASVURU_BITIS"],
					"BASVURU_TIP" => "1"

				);
				array_push($jsonDizi, $sanal_dizi);
			}
		}

		$kurs_liste = $vt->Prosedur("call sp_BASVURU_KURS_LISTELE('$erisim_kodu');");
		if ($kurs_liste != null) {
			foreach ($kurs_liste as $veri) {
				$sanal_dizi = array(
					"BASVURU_ID" => $veri["BASVURU_ID"],
					"BASLIK" => $veri["BASLIK"],
					"BASVURU_BITIS" => $veri["BASVURU_BITIS"],
					"BASVURU_TIP" => "2"

				);
				array_push($jsonDizi, $sanal_dizi);
			}
		}

		$turnuva_liste = $vt->Prosedur("call sp_BASVURU_TURNUVA_LISTELE('$erisim_kodu');");
		if ($turnuva_liste != null) {
			foreach ($turnuva_liste as $veri) {
				$sanal_dizi = array(
					"BASVURU_ID" => $veri["BASVURU_ID"],
					"BASLIK" => $veri["BASLIK"],
					"BASVURU_BITIS" => $veri["BASVURU_BITIS"],
					"BASVURU_TIP" => "3"

				);
				array_push($jsonDizi, $sanal_dizi);
			}
		}

		$fonk->BaslikAyarla(200);
		echo $fonk->json($jsonDizi);
	}
}else{
	$fonk->BaslikAyarla(400);
}



 ?>
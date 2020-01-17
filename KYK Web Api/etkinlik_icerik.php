<?php 

include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();
$_metot = $_SERVER['REQUEST_METHOD'];
$jsonDizi = array();

if (true) {
	$etkinlik_id = $_GET["ID"];

	if ($etkinlik_id != "") {
		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_ETKINLIK_ICERIK('$etkinlik_id');");

		foreach ($veri as $key) {
			if($key["FOTOGRAF"] == null){
				$key["FOTOGRAF"] = 0;
			}
			$sanal_dizi = array(
				"ID" => $key["ID"],
				"BASLIK" => $key["BASLIK"],
				"ICERIK" => $key["ICERIK"],
				"FOTOGRAF" => $urllocal."fotograf/".$key["FOTOGRAF"].".jpg",
				"KAYIT_TARIH" => $key["KAYIT_TARIH"]
			);
			array_push($jsonDizi, $sanal_dizi);
		}

		$fonk->BaslikAyarla(200);
		echo $fonk->json($jsonDizi);
	}
}
else{
	$fonk->BaslikAyarla(400);
}



?>

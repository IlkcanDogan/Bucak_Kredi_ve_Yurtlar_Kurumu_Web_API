<?php 

include("fonksiyon.php");

$fonk = new Fonksiyon();
$fonk->headerEkle();
$_metot = $_SERVER['REQUEST_METHOD'];
$jsonDizi = array();

if (true) {
	$start = $_GET["START"];

	if ($start != "") {
		$vt = new Veritabani();
		$veri = $vt->Prosedur("call sp_SPORTIF_BASLIK('$start');");

		foreach ($veri as $key) {
			if($key["FOTOGRAF"] == null){
				$key["FOTOGRAF"] = 0;
			}
			$sanal_dizi = array(
				"ID" => $key["ID"],
				"BASLIK" => $key["BASLIK"],
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
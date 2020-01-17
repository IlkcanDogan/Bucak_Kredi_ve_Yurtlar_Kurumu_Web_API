<?php 

include("fonksiyon.php");

$fonk = new Fonksiyon();
$fonk->headerEkle();
$_metot = $_SERVER['REQUEST_METHOD'];
$jsonDizi = array();

if (true) {

	$vt = new Veritabani();
	$veri = $vt->Prosedur("call sp_KURS();");

	if ($veri != "") {
		$fonk->BaslikAyarla(200);
		echo $fonk->json($veri);

	}

}
else{
	$fonk->BaslikAyarla(400);
}



?>
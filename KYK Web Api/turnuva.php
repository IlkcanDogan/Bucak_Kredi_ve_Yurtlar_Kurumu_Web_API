<?php 

include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();
$_metot = $_SERVER['REQUEST_METHOD'];
$jsonDizi = array();

if (true) {

	$vt = new Veritabani();
	$veri = $vt->Prosedur("call sp_TURNUVA();");

	if ($veri != "") {
		$fonk->BaslikAyarla(200);
		echo $fonk->json($veri);

	}

}
else{
	$fonk->BaslikAyarla(400);
}



?>
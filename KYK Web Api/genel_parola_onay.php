<?php 
include("fonksiyon.php");
error_reporting(0);

$fonk = new Fonksiyon();
$fonk->headerEkle();


$g_parola = $_GET["GENEL_PAROLA"];

if($g_parola != ""){ //GET

	$fonk->BaslikAyarla(200);

	$vt = new Veritabani();
	$veri = $vt->Prosedur("call sp_GENEL_PAROLA_ONAY('$g_parola');");

	$hata = $veri[0]["@HATA"];
	$dizi["HATA"] = $hata;

	echo $fonk->json($dizi);
}else{
	$fonk->BaslikAyarla(400);
}




 ?>
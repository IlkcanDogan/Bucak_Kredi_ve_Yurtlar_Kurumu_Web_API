<?php 
include("fonksiyon.php");
error_reporting(0);

$fonk = new Fonksiyon();
$fonk->headerEkle();

$dizi = array();

$tokenBarkod = $fonk->TokenOku();
$kod = $fonk->SifreliTokenCoz($tokenBarkod);

if($kod[0] == $ERISIM_KODU){

	$ozel_kod = md5(uniqid());

	$fonk->BaslikAyarla(200);
	
	$dizi["TOKEN"] = $fonk->TokenUret($ozel_kod);

}
else{
	$dizi["TOKEN"] = 1;
}

echo $fonk->json($dizi);


 ?>
<?php 

include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi = array();

$_metot = $_SERVER['REQUEST_METHOD'];

if ($_metot == "POST") {
    $token = $fonk->TokenOku();
    $parola = $fonk->SifreliTokenCoz($token)[0];

    $tablo_id = $_GET["TABLO_ID"];
    $kayit_id = $_GET["KAYIT_ID"];
    $default_foto = $_GET["DEFAULT"];
    


    if (strlen($parola) == 32 && $tablo_id != "" && $kayit_id != "") {

      $fotograf_no = $fonk->KayitFotograf();
      $vt = new Veritabani();
      $veri = $vt->Prosedur("call sp_YONETICI_FOTOGRAF_EKLE('$parola','$tablo_id','$kayit_id','$fotograf_no');");   
      $fonk->BaslikAyarla(200);

      $jsonDizi["HATA"] = $veri[0]["@HATA"];

      echo $fonk->json($jsonDizi);
    }
    else if($default_foto == "default"){
    	$fonk->KayitFotograf(true);

    	$fonk->BaslikAyarla(200);
    	$jsonDizi["HATA"] = 0;
    	echo $fonk->json($jsonDizi);
    }
}
else{
  $fonk->BaslikAyarla(400);
}

?>
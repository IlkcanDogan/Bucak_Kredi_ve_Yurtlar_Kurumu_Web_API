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

    $baslik = $_POST["BASLIK"];
    $icerik = $_POST["ICERIK"];



    if (strlen($parola) == 32) {
      $vt = new Veritabani();

      $veri = $vt->Prosedur("call sp_YONETICI_SPORTIF_EKLE('$parola','$baslik','$icerik');");
      
      $fonk->BaslikAyarla(200);
      $jsonDizi["HATA"] = $veri[0]["@HATA"];

      echo $fonk->json($jsonDizi);
    } 
}
else{
  $fonk->BaslikAyarla(400);
}





?>
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

    $kayit_tip = $_POST["KAYIT_TIP"];
    $kayit_id = $_POST["KAYIT_ID"];


    if (strlen($parola) == 32 && $kayit_tip != "" && $kayit_id != "") {
      $vt = new Veritabani();
      $veri = $vt->Prosedur("call sp_YONETICI_BASVURU_OGRENCI_LISTE('$parola','$kayit_tip','$kayit_id');");
      

      $fonk->BaslikAyarla(200);
      $jsonDizi["DATA"] = $veri;
      echo $fonk->json($jsonDizi);
    } 
}
else{
  $fonk->BaslikAyarla(400);
}



?>
<?php 

include("fonksiyon.php");
error_reporting(0);
$fonk = new Fonksiyon();
$fonk->headerEkle();

$jsonDizi["DATA"] = array();

$_metot = $_SERVER['REQUEST_METHOD'];

if ($_metot == "POST") {
    $token = $fonk->TokenOku();
    $parola = $fonk->SifreliTokenCoz($token)[0];

    if (strlen($parola) == 32) {
      $vt = new Veritabani();
      $veri = $vt->Prosedur("call sp_YONETICI_KURS_LISTE('$parola');");

      if ($veri != "") {      
        $fonk->BaslikAyarla(200);
        
        $jsonDizi["DATA"] = $veri;

        echo $fonk->json($jsonDizi);
      }

    }
}
else{
  $fonk->BaslikAyarla(400);
}



?>
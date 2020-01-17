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

    $secilen_idler = $_POST["SEC"];
    $kayit_tip = $_POST["KAYIT_TIP"];
    $idDizi = explode("+", $secilen_idler);


    if (strlen($parola) == 32) {
      $vt = new Veritabani();
      $hata;
      foreach ($idDizi as $value) {
          $hata = $vt->Prosedur("call sp_YONETICI_BASVURU_OGRENCI_SIL('$parola','$kayit_tip','$value');");
      }
      
      $fonk->BaslikAyarla(200);

      if ($hata != 1) {     
        $jsonDizi["HATA"] = 0;
      }
      else{
        $jsonDizi["HATA"] = 1;
      }

      echo $fonk->json($jsonDizi);
    } 
}
else{
  $fonk->BaslikAyarla(400);
}







?>
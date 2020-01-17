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
    $idDizi = explode("+", $secilen_idler);

    $fonk->BaslikAyarla(200);

    if (strlen($parola) == 32) {
      $vt = new Veritabani();
      $durum = 0; //Hata durumu kontrol edilmiyor.(test için)
      foreach ($idDizi as $value) {
          $foto_no = $vt->Prosedur("call sp_YONETICI_SOSYAL_SORUMLULUK_SIL('$parola','$value');")[0]["@FOTO_NO"];

          if($foto_no != 0){
            if($fonk->fotoSil($foto_no)) $durum = 0;
          }

      }
      
      
      if ($durum != 1) {     
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
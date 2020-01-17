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
      $listeVeri = $vt->Prosedur("call sp_YONETICI_DUYURU_LISTE('$parola');");
      foreach ($listeVeri as $veri) {
        if ($veri["BASVURU_BITIS"] == "00.00.0000") {
            $veri["BASVURU_BITIS"] = "--";
        }
        if($veri["BASVURU"] == 1){
            $veri["BASVURU"] = "Evet";
        }
        else{
            $veri["BASVURU"] = "Hayır";
        }

          $sanal_dizi = array(
            "ID" => $veri["ID"],
            "BASLIK" => $veri["BASLIK"],
            "ICERIK" => $veri["ICERIK"],
            "BASVURU_BITIS" => $veri["BASVURU_BITIS"],
            "GORUNTULENME" => $veri["GORUNTULENME"],
            "BASVURU" => $veri["BASVURU"],
            "KAYIT_TARIH" => $veri["KAYIT_TARIH"]
          );
          array_push($jsonDizi["DATA"], $sanal_dizi);
      }

      if ($veri != "") {
        $fonk->BaslikAyarla(200);

        echo $fonk->json($jsonDizi);
      }

    }
}
else{
    $fonk->BaslikAyarla(400);
}



?>
<?php 

include("fonksiyon.php");


$fonk = new Fonksiyon();
$token = $fonk->TokenUret($ERISIM_KODU);

if(!$token){
    echo "bos";
}else{
 
	$QRkod = new BarcodeQR();
	$QRkod->data_ekle($token);
	$QRkod->draw();
	$QRkod->draw(250, "karekod.png");

}
 

 ?>
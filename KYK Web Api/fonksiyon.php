<?php
error_reporting(0);
include('cipher/Crypt/RSA.php');
$ERISIM_KODU = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
$urllocal = "http://www.domain.site/";
class Veritabani{
	public static $db;
	function __construct($host="localhost",$db_adi="db_kyk",$db_k_adi="root",$db_sifre=""){
		try {
			self::$db = new PDO("mysql:host=$host;dbname=$db_adi;charset=utf8",$db_k_adi,$db_sifre);
		} catch (PDOException $hata) {
			echo "Bağlantı Hatası!";
		}
	}

	function Prosedur($sorgu){
		$veri_dizi = array();

		$s = self::$db->query($sorgu);
		$s->setFetchMode(PDO::FETCH_ASSOC);

		while ($veri = $s->fetch()) {
			array_push($veri_dizi, $veri);
		}

		return $veri_dizi;

	}
}


final class BarcodeQR{
	const API_CHART_URL = "http://chart.apis.google.com/chart";
	private $_data;

	public function draw($size = 250, $filename = null) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, self::API_CHART_URL);
		curl_setopt($ch, CURLOPT_POST, true);
		curl_setopt($ch, CURLOPT_POSTFIELDS, "chs={$size}x{$size}&cht=qr&chl=" . urlencode($this->_data));
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_HEADER, false);
		curl_setopt($ch, CURLOPT_TIMEOUT, 30);
		$img = curl_exec($ch);
		curl_close($ch);
		if($img) {
			if($filename) {
				if(!preg_match("#\.png$#i", $filename)) {
					$filename .= ".png";
				}
				
				return file_put_contents($filename, $img);
			} else {
				header("Content-type: image/png");
				print $img;
				return true;
			}
		}
		return false;
	}

	public function data_ekle($data = null) {
		$this->_data = $data;
	}

}

class Fonksiyon{
	function HttpDurumKodlari($kod){
		$durum = array(
			100 => 'Continue',
			101 => 'Switching Protocols',
			200 => 'OK',
			201 => 'Created',
			202 => 'Accepted',
			203 => 'Non-Authoritative Information',
			204 => 'No Content',
			205 => 'Reset Content',
			206 => 'Partial Content',
			300 => 'Multiple Choices',
			301 => 'Moved Permanently',
			302 => 'Found',
			303 => 'See Other',
			304 => 'Not Modified',
			305 => 'Use Proxy',
			306 => '(Unused)',  
        	307 => 'Temporary Redirect',  
       		400 => 'Bad Request',  
        	401 => 'Unauthorized',  
        	402 => 'Payment Required',  
        	403 => 'Forbidden',  
        	404 => 'Not Found',  
        	405 => 'Method Not Allowed',  
        	406 => 'Not Acceptable',  
        	407 => 'Proxy Authentication Required',  
        	408 => 'Request Timeout',  
        	409 => 'Conflict',  
        	410 => 'Gone',  
        	411 => 'Length Required',  
        	412 => 'Precondition Failed',  
        	413 => 'Request Entity Too Large',  
        	414 => 'Request-URI Too Long',  
        	415 => 'Unsupported Media Type',  
        	416 => 'Requested Range Not Satisfiable',  
        	417 => 'Expectation Failed',  
        	500 => 'Internal Server Error',  
        	501 => 'Not Implemented',  
        	502 => 'Bad Gateway',  
        	503 => 'Service Unavailable',  
        	504 => 'Gateway Timeout',  
        	505 => 'HTTP Version Not Supported');
		return $durum[$kod] ? $durum[$kod] : $durum[500];
	}

	function headerEkle(){
        header("Access-Control-Allow-Origin: *");
        header('Access-Control-Allow-Methods: GET, POST');
        header('Access-Control-Max-Age: 86400');
        header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-Custom-Header');
        $_POST = json_decode(file_get_contents('php://input'), true);
    }

  	function BaslikAyarla($kod){
		header("HTTP/1.1 ".$kod." ".$this->HttpDurumKodlari($kod));
		header("Content-Type: application/json; charset=utf-8");
	}

	function IpBul(){
       if (!empty($_SERVER['HTTP_CLIENT_IP']))  
        {  
            $ip=$_SERVER['HTTP_CLIENT_IP'];  
        }  
        elseif (!empty($_SERVER['HTTP_X_FORWARDED_FOR']))  
        {  
            $ip=$_SERVER['HTTP_X_FORWARDED_FOR'];  
        }  
        else  
        {  
            $ip=$_SERVER['REMOTE_ADDR'];  
        }  
        
        return $ip;  
    }

    function SifreliTokenCoz($token){
    	$SifresizVeri = null;
        $SifrelemeTuru = 'rc4';
        $Anahtar = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        $veri = base64_decode(strtr($token,'-_','+/') . str_repeat('=', 3 - ( 3 + strlen( $token )) % 4 ));
        $SifresizVeri = openssl_decrypt($veri, $SifrelemeTuru, $Anahtar);
        $rsa = new Crypt_RSA();
        $rsa->loadKey(file_get_contents('cipher/privatekey.txt'));
    	$rsa->setEncryptionMode(CRYPT_RSA_ENCRYPTION_PKCS1);
    	$dizi = explode("-", $rsa->decrypt(base64_decode($SifresizVeri)));
        
        if(count($dizi) > 2){
        	$uzunluk = count($dizi);
			$index =$uzunluk - 1; 
			$metin1 = $dizi[$index];
			$a;
			for ($i=0; $i < $index; $i++) { 
				$a = $a."-".$dizi[$i];
			}
			$dizi2[0] = ltrim($a,"-");
			$dizi2[1] = $metin1;
			return $dizi2;
        }
        else{
        	return $dizi;
        }
        
    }

    function TokenUret($data1,$data2 = ""){
    	$veri = $data1.'-'.$data2;
    	$rsa = new Crypt_RSA();
    	$rsa->LoadKey(file_get_contents('cipher/privatekey.txt'));
    	$rsa->LoadKey($rsa->getPublicKey());
    	$rsa->setEncryptionMode(CRYPT_RSA_ENCRYPTION_PKCS1);
    	$sifreliVeri = null;
        $SifrelemeTuru = 'rc4';
        $Anahtar = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
        $token = openssl_encrypt(base64_encode($rsa->encrypt($veri)), $SifrelemeTuru, $Anahtar);
        $token =  rtrim(strtr(base64_encode($token),'+/','-_'),'=');
    	return $token;  
    }

    function TokenOku(){
        $Dizi = array();
        //$_serv = $_SERVER[''];
        $Dizi = apache_request_headers();
        return $Dizi["Authorization"];
    }

    function pushSend($mesaj) {

    	$content      = array(
        	"en" => $mesaj
    	);
    	$fields = array(
        	'app_id' => "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                'large_icon' => 'http://www.domain.site/kyklogo.png',
        	'included_segments' => array(
            	     'All'
        	),
        	'contents' => $content
    	);
    
    	$fields = json_encode($fields);   
    	$ch = curl_init();
    	curl_setopt($ch, CURLOPT_URL, "https://onesignal.com/api/v1/notifications");
    	curl_setopt($ch, CURLOPT_HTTPHEADER, array(
        	'Content-Type: application/json; charset=utf-8',
        	'Authorization: Basic xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
    	));
    	curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
    	curl_setopt($ch, CURLOPT_HEADER, FALSE);
    	curl_setopt($ch, CURLOPT_POST, TRUE);
    	curl_setopt($ch, CURLOPT_POSTFIELDS, $fields);
    	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    
    	$response = curl_exec($ch);
    	curl_close($ch);
    
    	return $response;
	}

    function json($dizi){
		return json_encode($dizi, JSON_UNESCAPED_UNICODE);
	}

    function KayitFotograf($default = false){
        $yukleme_dizini;
        $fotograf_no = null;
        $tip = $_FILES['image']['type'];
        $fotografAdi = basename($_FILES['image']['name']);
        $uzanti = substr($fotografAdi, strrpos($fotografAdi, '.') + 1);
        if($_FILES){
            $yeniFotografNo = rand(100000, 999999);
            $sonuc = 1;
            while ($sonuc == 1) {
                    
                $sonuc = file_exists("fotograf/".$yeniFotografNo.".jpg");
                if($sonuc == 1){
                    $yeniFotografNo = rand(100000, 999999);
                }
                    
            }
            if($default){
                $yukleme_dizini = "fotograf/0.jpg";
            }
            else{
                $yukleme_dizini = "fotograf/".$yeniFotografNo.".jpg";
            }
            
            $fotograf = getimagesize($_FILES['image']['tmp_name']);
            if(!(is_bool($fotograf))){
                if(move_uploaded_file($_FILES['image']['tmp_name'], $yukleme_dizini)){
                    $r = imagecreatefromjpeg($yukleme_dizini);
                    $boyutlar = getimagesize($yukleme_dizini);
                    imagejpeg($r,$yukleme_dizini,100);
                    // chmod($yukleme_dizini,0755);
                    $fotograf_no = $yeniFotografNo;
                }
                else{
                    $fotograf_no = 333;
                }
            }
            else{
                $fotograf_no = 333;
            }
        }
        else{
            $fotograf_no = 333;
        }
        
        return $fotograf_no;
    }

    

    function fotoSil($fotograf_no){
        $durum = False;
        if (unlink('fotograf/'.$fotograf_no.'.jpg')) {
            $durum = True;
        }
        return $durum;
    }




}



?>

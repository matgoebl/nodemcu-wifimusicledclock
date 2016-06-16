// Color Picker
// Source: http://www.heimpel.de/de/index.php?k=5

//Farb-Set als Array
var pCol = new Array();
pCol[1]  = '#FF0000'; 
pCol[2]  = '#00FF00';
pCol[3]  = '#0000FF';
pCol[4]  = '#FFFF00';
pCol[5]  = '#00FFFF';
pCol[6]  = '#FF00FF';
pCol[7]  = '#800000'; 
pCol[8]  = '#008000'; 
pCol[9]  = '#000080'; 
pCol[10] = '#808000'; 
pCol[11] = '#008080'; 
pCol[12] = '#800080'; 
pCol[13] = '#000000';
pCol[14] = '#101010';
pCol[15] = '#808080';
pCol[16] = '#ffffff';

//Palette aufrufen
function buildPalette(div) {

    //Falls palette schon erzeugt, Funktion abbrechen
    if ( document.getElementById("palette"+div) != null ) { 
        document.getElementById("palette"+div).style.display = "none"; //FF
        document.getElementById(div).removeChild(document.getElementById("palette"+div)); 
        return false; 
    }

    //absolutes div dynamische erzeugen, innerhalb relativem div "pickerdiv"
    var crDiv = document.createElement('div'); 
    document.getElementById(div).appendChild(crDiv);
    crDiv.id = 'palette'+div; 
    crDiv.className = 'palette';
    
    //erzeugtes div "palette" sichtbar stellen
    document.getElementById("palette"+div).style.display = "block";
    
    //style-Werte für den unsäglichen Internet-Explorer nachführen (unvollständig)
    if(document.all) {
    document.getElementById("palette"+div).style.position = "absolute"; //IE 
    document.getElementById("palette"+div).style.top      = "-112px";   //IE 
    document.getElementById("palette"+div).style.left     = "18px";     //IE 
    document.getElementById("palette"+div).style.width    = "132px";    //IE 
    document.getElementById("palette"+div).style.paddingRight = "0px";  //IE
    } 

    //div "palette" mit Farbfeldern aus Array füllen
    for(i=1;i<pCol.length;i++) {
        document.getElementById("palette"+div).innerHTML += '<a href="#" onclick="pickc('+"'"+div+"'"+',' + i + ')" class="palettec" style="background:' + pCol[i] + '" title="' + i + '"></a>';
    }
    
    return false;
    
}

function dec2hex(num) {
 return (num+0x100).toString(16).substr(-2).toUpperCase();
}

var rgb_brights=[0, 2, 3, 4, 6, 8, 11, 16, 23, 32, 45, 64, 90, 128, 181, 255];
function getBrightHex(b) {
 var n=0;
 for (var i=0; i < rgb_brights.length; i++) {
  if(b >= rgb_brights[i]) n=i;
 }
 return n.toString(16).toUpperCase();
}

var rgbPattern=[]
//Farbe picken und Palette schliessen
function pickc(div,i) {
    //input feld: wert mit geklickter Farbe füllen
    document.getElementById(div).style.backgroundColor = pCol[i];
    //div "palette" wieder zerstören  
    document.getElementById("palette"+div).style.display = "none"; //FF  
    document.getElementById(div).removeChild(document.getElementById("palette"+div));   

    rgbsplit = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(pCol[i]);
    rgb={
        r: parseInt(rgbsplit[1], 16),
        g: parseInt(rgbsplit[2], 16),
        b: parseInt(rgbsplit[3], 16)
    };
    rgbPattern[div]=rgb;
    //console.log(rgbPattern);
    //espAPI("rgb?r="+rgb.r+"&g="+rgb.g+"&b="+rgb.b+"&n="+div)
    var rgbList=""
    for (var i=0; i < rgbPattern.length; i++) {
     var rgb=rgbPattern[i];
     if(rgb==null) rgb={"r":0,"g":0,"b":0};
     // old api: rgbList=rgbList+","+rgb.r+","+rgb.g+","+rgb.b;
     // newer api: rgbList=rgbList+dec2hex(rgb.r)+dec2hex(rgb.g)+dec2hex(rgb.b)
     // new api:
     rgbList=rgbList+getBrightHex(rgb.r)+getBrightHex(rgb.g)+getBrightHex(rgb.b)
    }
    //rgbList=rgbList.substring(1);
    //use_pwm= document.getElementById("use_pwm").checked ? "1" : "0";
    //espAPI("rgb?pattern="+rgbList+"&pwm="+use_pwm)
    repeat= document.getElementById("repeat").checked ? "1" : "0";
    updateRgb("&p="+rgbList+"&rep="+repeat)
}

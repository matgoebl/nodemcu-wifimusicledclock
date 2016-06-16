 var espAPI_pending=false
 function espAPI(url,updateStatus) {
   document.getElementById("apiurl").firstChild.data=url;
   var http = new XMLHttpRequest();
   http.open("GET", url+"&"+Date.now(), true);
   espAPI_pending=true;
   http.onreadystatechange = function () {
     if (http.readyState == 4) {
       espAPI_pending=false;
     }
   }
   http.send();
   if(updateStatus) {
    document.getElementById("status").style.color="#aaaaaa";
    setTimeout(update,10000);
   }
 }

function updateRgb(params,fast) {
 if(fast&&espAPI_pending) return;
 if(params==null) params=""
 espAPI("rgb?ms="+document.getElementById("speed").value+"&step="+document.getElementById("step").value+params);
}


 function update() {
   var id = document.getElementById("status");
   id.style.color="#888888"
   var http = new XMLHttpRequest();
   http.open("GET", "status?_="+Date.now(), true);
   http.onreadystatechange = function () {
     if (http.readyState == 4) {
       data=JSON.parse(http.responseText);
       id.firstChild.data = JSON.stringify(data,null,2);
       id.style.color="#000000"
//       setTimeout(update,10000);
     }
   }
   http.send();
 }



 window.onload = function() {
   update();
 }

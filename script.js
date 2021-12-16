
function appendData(data) {
    var mainFields = document.getElementById("data");
    // alert(data.length);
    for (var i = 0; i < data.length; i++) {
        var link = document.createElement("th");
        var content = document.createElement("tr")
        // console.log(data.length);
        if(data[i]._source.content==""){
            // console.log(data[i]._source.object_key)
            var filePath = data[i]._source.object_key;
            
        }else{
        var fileName = data[i]._source.object_key;
        console.log("filename:  "+fileName)
        link.innerHTML = "<br><tr><td><a href="+data[i]._source.access_url+">"+data[i]._source.root_handle+"/"+fileName.substring(filePath.length)+"</a></td></tr>" ;
        content.innerHTML="<tr><td>"+ data[i]._source.content +"</td></tr><br>";
        mainFields.appendChild(link);
        mainFields.appendChild(content);
        delete(filePath);
        // data=null;
        stop();
        }
        
    }

}


function search(data) {
    var searchbox = document.getElementById("search");
    // console.log(searchbox);
    var timer =0;
    
    searchbox.addEventListener("keyup", function(event) {
        clearTimeout(timer);
        timer = setTimeout(search, 1);
      });
    
    var keyword = searchbox.value;
    fetch('https://gt0ytth3cc.execute-api.us-east-2.amazonaws.com/opensearch-api-test?q='+keyword)
    .then((response) => {
        if (response.ok) {
            return response.json();
        } else {
            throw new Error("NETWORK RESPONSE ERROR");
        }
    })
    .then(data => {
        if(data.length==0){
            console.log("empty");
        }else{
        console.log(data);
        appendData(data);
        stop;}
        // search(data);
        // console.log(search);
        // displayCocktail(data)
    })
    .catch((error) => console.error("FETCH ERROR:", error));
}

search();
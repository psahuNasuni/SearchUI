
function appendData(data) {
    var mainFields = document.getElementById("mydata");
    // alert(data.length);
    for (var i = 0; i < data.length; i++) {
        var div = document.createElement("div");
        console.log(data.length)
        // var test = 'object_key: ' + data[i].object_key + ' Index : ' + data[i]._index + ' Content : ' + data[i]._source.content;
        // console.log(test);
        document.getElementById("object_key").innerHTML = data[i].object_key;
        document.getElementById("index").innerHTML = data[i]._index;
        document.getElementById("content").innerHTML = data[i]._source.content;
        mainFields.appendChild(div);
        stop();
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
        if(data.length===0){
            console.log("empty");
        }else{
        console.log(data);
        appendData(data);}
        // search(data);
        // console.log(search);
        // displayCocktail(data)
    })
    .catch((error) => console.error("FETCH ERROR:", error));
}

search();
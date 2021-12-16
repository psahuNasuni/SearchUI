function appendData(data) {
    var mainFields = document.getElementById("data");
    mainFields.innerHTML = '';
    var mainFields = document.getElementById("data");
    for (var i = 0; i < data.length; i++) {
        var link = document.createElement("h5");
        var content = document.createElement("div")
        console.log(data.length);
        if (data[i]._source.content != "") {
            console.log(data[i]._source.access_url)
            const file = data[i]._source.access_url.substring(data[i]._source.access_url.lastIndexOf('/') + 1)
            link.innerHTML = "<a class='elasti_link' href=" + data[i]._source.access_url + ">" + file + "</a>" + "<br>";
            content.innerHTML = "<span class='content'>" + data[i].highlight.content[i] + "<br></span>";
            // content.innerHTML = "<span class='content'>" + data[i]._source.content + "<br></span>";
            mainFields.appendChild(link);
            mainFields.appendChild(content);
            stop();
        }

    }

}

function search(data) {
    var searchbox = document.getElementById("search");
    var timer = 0;

    searchbox.addEventListener("keyup", function(event) {
        clearTimeout(timer);
        timer = setTimeout(search, 1);
    });

    var keyword = searchbox.value;
    // fetch('https://gt0ytth3cc.execute-api.us-east-2.amazonaws.com/opensearch-api-test?q=' + keyword)
    fetch('https://2w966j6thk.execute-api.us-east-2.amazonaws.com/dev/search?q=' + keyword)
        .then((response) => {
            if (response.ok) {
                return response.json();
            } else {
                throw new Error("NETWORK RESPONSE ERROR");
            }
        })
        .then(data => {
            if (data.length == 0) {
                console.log("empty");
                appendData(null);
                stop;
            } else {
                console.log(data);
                appendData(data);
                stop;
            }

        })
        .catch((error) => console.error("FETCH ERROR:", error));
}


search();
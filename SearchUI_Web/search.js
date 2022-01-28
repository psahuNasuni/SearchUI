// Update this variable to point to your domain.
var apigatewayendpoint = 'https://hlh4mflagg.execute-api.us-east-2.amazonaws.com/prod/SearchESIndex';
var loadingdiv = $('#loading');
var noresults = $('#noresults');
var resultdiv = $('#results');
var searchbox = $('input#search');
var timer = 0;

// Executes the search function 250 milliseconds after user stops typing
searchbox.keyup(function () {
  clearTimeout(timer);
  timer = setTimeout(search, 500);
});

async function search() {
  // Clear results before searching
  noresults.hide();
  resultdiv.empty();
  loadingdiv.show();
  // Get the query from the user
  let query = searchbox.val();
  // Only run a query if the string contains at least three characters
  if (query.length > 0) {
    // Make the HTTP request with the query as a parameter and wait for the JSON results
    let response = await $.get(apigatewayendpoint, { q: query, size: 25 }, 'json');
	//console.log(response,'response...');
    // Get the part of the JSON response that we care about
    //let results = response['hits']['hits'];
    if (response.length > 0) {
      loadingdiv.hide();
	  noresults.hide();
      // Iterate through the results and write them to HTML
      resultdiv.append('<p>Found ' + response.length + ' results.</p>');
      appendData(resultdiv, response);
    } else {
      noresults.show();
    }
  }
  loadingdiv.hide();
}

function appendData(resultdiv, data) {
    for (var i = 0; i < data.length; i++) {
        var link = document.createElement("h5");
        var content = document.createElement("div");
		
		if (data[i].length > 0) {
			for (var j = 0; j < data[i].length; j++) {
				link.innerHTML = "<a class='elasti_link' href="+data[i][j]._source.access_url+">"+data[i][j]._source.object_key+"</a>" + "<br>" ;
				resultdiv.append(link);
				if (data[i][j].highlight.content.length > 0) {
					for (var k = 0; k < data[i][j].highlight.content.length; k++) {
						content.innerHTML += "<p>" + data[i][j].highlight.content[k] + "</p>";
					}
					resultdiv.append(content);
				}
				stop();
			}
		}
    }
}